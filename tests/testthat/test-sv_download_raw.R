mock_bodies <- function(s) {
  json <- function(p) as.character(jsonlite::toJSON(p, auto_unbox = TRUE, null = "null", digits = NA))
  list(match = json(s$match), stats = json(s$stats), shots = json(s$shots))
}

test_that("sv_download_raw() saves the three raw payloads, ready for bundle_add_raw()", {
  s <- sample_session(1L, id = 5550002)
  bodies <- mock_bodies(s)
  requested <- character(0)
  local_mocked_bindings(
    sv_get_raw = function(url) {
      requested <<- c(requested, url)
      if (grepl("/stats$", url)) bodies$stats else if (grepl("/shots$", url)) bodies$shots else bodies$match
    }
  )
  dir <- file.path(withr::local_tempdir(), "nested", "out")
  paths <- sv_download_raw("https://swing.vision/matches/sw2-EXAMPLE01?x=1", dir)

  expect_named(paths, c("match", "stats", "shots"))
  expect_true(all(file.exists(paths)))
  expect_identical(
    basename(paths),
    c("sw2-EXAMPLE01_match.json", "sw2-EXAMPLE01_stats.json", "sw2-EXAMPLE01_shots.json")
  )
  expect_identical(
    sub("^.*/v1", "", requested),
    c("/matches/sw2-EXAMPLE01", "/matches/sw2-EXAMPLE01/stats", "/matches/sw2-EXAMPLE01/shots")
  )
  # the files hold the response text unchanged
  expect_identical(readLines(paths[["match"]], warn = FALSE), bodies$match)

  # and are exactly what bundle_add_raw() reads
  b <- bundle_add_raw(bundle_new(), paths[["match"]], paths[["stats"]], paths[["shots"]], token = "sw2-EXAMPLE01")
  expect_equal(b$sessions[[1]]$match_id, 5550002)
})

test_that("sv_download_raw() accepts a bare token and checks its arguments first", {
  called <- FALSE
  local_mocked_bindings(sv_get_raw = function(url) { called <<- TRUE; "{}" })
  expect_error(sv_download_raw("", tempdir()), "share URL or token")
  expect_error(sv_download_raw(NA_character_, tempdir()), "share URL or token")
  expect_error(sv_download_raw(c("a", "b"), tempdir()), "share URL or token")
  expect_error(sv_download_raw("sw2-EXAMPLE01", ""), "directory")
  expect_error(sv_download_raw("https://x.example/matches/a b", tempdir()), "characters")
  expect_error(sv_download_raw("..", tempdir()), "characters")
  expect_false(called)
})

test_that("a failed download writes nothing", {
  local_mocked_bindings(
    sv_get_raw = function(url) cli::cli_abort("The server said no.")
  )
  dir <- file.path(withr::local_tempdir(), "never")
  expect_error(sv_download_raw("sw2-EXAMPLE01", dir), "said no")
  expect_false(dir.exists(dir))
})

test_that("a failure on the 2nd of 3 requests writes nothing and hides the token and URL", {
  s <- sample_session(1L)
  bodies <- mock_bodies(s)
  n <- 0L
  local_mocked_bindings(
    sv_get_raw = function(url) {
      n <<- n + 1L
      if (n == 2L) cli::cli_abort(paste0("Could not connect to ", url, "?key=abc"))
      bodies$match
    }
  )
  dir <- file.path(withr::local_tempdir(), "never")
  err <- tryCatch(sv_download_raw("sw2-EXAMPLE01", dir), error = function(e) e)
  expect_s3_class(err, "error")
  expect_identical(n, 2L)
  expect_false(dir.exists(dir))
  msg <- paste(conditionMessage(err), collapse = " ")
  expect_false(grepl("sw2-EXAMPLE01", msg, fixed = TRUE))
  expect_false(grepl("https?://", msg))
  expect_match(msg, "stats")
})

test_that("a response that is not JSON is refused before anything is written", {
  s <- sample_session(1L)
  bodies <- mock_bodies(s)
  local_mocked_bindings(
    sv_get_raw = function(url) {
      if (grepl("/shots$", url)) "<html>please sign in</html>" else bodies$match
    }
  )
  dir <- file.path(withr::local_tempdir(), "never")
  err <- tryCatch(sv_download_raw("sw2-EXAMPLE01", dir), error = function(e) e)
  expect_s3_class(err, "error")
  expect_false(dir.exists(dir))
  msg <- paste(conditionMessage(err), collapse = " ")
  expect_match(msg, "not JSON")
  expect_match(msg, "shots")
  expect_false(grepl("sign in", msg, fixed = TRUE))
  expect_false(grepl("sw2-EXAMPLE01", msg, fixed = TRUE))
})

test_that("each request has a timeout", {
  seen <- NULL
  httr2::local_mocked_responses(function(req) {
    seen <<- c(seen, req$options$timeout_ms)
    httr2::response(status_code = 200, body = charToRaw("{}"))
  })
  expect_identical(sv_get_raw("https://example.invalid/x"), "{}")
  expect_gt(length(seen), 0L)
  expect_true(all(seen > 0 & seen <= 120000))
})
