# The extra synthetic session (inst/extdata/synthetic_sample_session/): the
# three raw JSON files of ONE session that is not in the sample bundle, for
# trying "add a session" on top of it.

extra_session_files <- function() {
  dir <- system.file("extdata", "synthetic_sample_session", package = "rallyr")
  list.files(dir, pattern = "\\.json$", full.names = TRUE)
}

test_that("the extra session ships as three JSON files", {
  files <- extra_session_files()
  expect_length(files, 3L)
  kinds <- vapply(files, bundle_payload_kind, character(1))
  expect_setequal(unname(kinds), c("match", "stats", "shots"))
})

test_that("the extra session merges into the sample bundle to give 7 sessions", {
  b <- sample_bundle()
  expect_length(b$sessions, 6L)
  out <- do.call(bundle_add_raw, c(list(b), as.list(extra_session_files())))
  expect_length(out$sessions, 7L)
  expect_identical(attr(out, "merge_report")$action, "added")
  # it is a session the bundle does not hold
  ids <- vapply(b$sessions, function(s) bundle_id_key(s$match_id), character(1))
  expect_false(bundle_id_key(out$sessions[[7]]$match_id) %in% ids)
  # and it can be computed and charted like the others
  tb <- bundle_to_tables(out, "Sample Player")
  expect_equal(nrow(tb$matches), 7L)
  d <- bundle_derived(tb)
  expect_equal(nrow(d$sessions), 7L)
})

test_that("the extra session parses on its own and merges with bundle_merge()", {
  one <- do.call(bundle_add_raw, c(list(bundle_new()), as.list(extra_session_files())))
  expect_length(one$sessions, 1L)
  merged <- bundle_merge(sample_bundle(), one)
  expect_length(merged$sessions, 7L)
  tb <- bundle_to_tables(one, "Sample Player")
  expect_gt(nrow(tb$shot_detail), 100L)
})

test_that("the extra session holds only synthetic names and tokens", {
  txt <- vapply(extra_session_files(), function(f) paste(readLines(f, warn = FALSE), collapse = "\n"), character(1))
  all_txt <- paste(txt, collapse = "\n")
  m <- bundle_unwrap(bundle_as_payload(grep("match", extra_session_files(), value = TRUE)))
  expect_identical(m$guest_name, "Sample Player")
  expect_identical(m$host_name, "Sample Opponent")
  expect_match(m$court$name, "synthetic")
  # the date is the synthetic anchor's, not a real one
  expect_gte(as.Date(substr(m$started_at, 1, 10)), as.Date("2029-01-01"))
  # no link, no share-token-shaped string, no other person's name
  expect_false(grepl("https?://", all_txt))
  expect_false(grepl("sw[0-9]-[A-Za-z0-9]+", all_txt))
  names_in <- unique(unlist(regmatches(all_txt, gregexpr('"(guest|host)_name":"[^"]*"', all_txt))))
  expect_setequal(names_in, c('"guest_name":"Sample Player"', '"host_name":"Sample Opponent"'))
})

test_that("the committed files are what the generator makes (not hand-edited)", {
  skip_on_cran()
  script <- test_path("..", "..", "data-raw", "generate_sample_session.R")
  skip_if_not(file.exists(script), "data-raw/ is not part of the installed package")
  script <- normalizePath(script)
  root <- dirname(dirname(script))
  withr::local_envvar(c(SYNTHETIC_SESSION_SKIP_LOAD = "1", SYNTHETIC_SESSION_SKIP_MAIN = "1"))
  env <- new.env(parent = globalenv())
  withr::with_dir(root, sys.source(script, envir = env))
  dir <- withr::local_tempdir()
  fresh <- env$.write_extra_session(env$.synthetic_extra_session(), dir)
  for (p in fresh) {
    committed <- system.file("extdata", "synthetic_sample_session", basename(p), package = "rallyr")
    expect_identical(readLines(p, warn = FALSE), readLines(committed, warn = FALSE), info = basename(p))
  }
})
