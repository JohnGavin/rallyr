test_that("the app's server logic works with the package attached", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("ggplot2")
  app <- system.file("app", package = "rallyr")
  skip_if(!nzchar(app), "app folder not found")
  source(test_path("app-checks.R"), local = TRUE)
  expect_true(run_app_checks(app))
})

test_that("the app works in a clean process from the assembled folder (bundled code only)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("ggplot2")
  build <- test_path("..", "..", "tools", "build_app.R")
  skip_if_not(file.exists(build), "tools/ is not part of the installed package")
  rscript <- file.path(R.home("bin"), "Rscript")
  app <- withr::local_tempdir()
  out <- suppressWarnings(system2(
    rscript, c(shQuote(normalizePath(build)), "--assemble-only", shQuote(paste0("--app-dir=", app))),
    stdout = TRUE, stderr = TRUE
  ))
  expect_true(file.exists(file.path(app, "pkg_R", "rallyr_app_sources.R")), info = paste(out, collapse = "\n"))
  # the sample files the page offers, and the precomputed sample
  expect_setequal(
    list.files(file.path(app, "data", "synthetic_sample_session")),
    list.files(system.file("extdata", "synthetic_sample_session", package = "rallyr"))
  )
  expect_true(file.exists(file.path(app, "data", "synthetic_sample_bundle.json.gz")))
  pre <- readRDS(file.path(app, "data", "sample_derived.rds"))
  expect_identical(pre$me, "Sample Player")
  expect_equal(nrow(pre$derived$sessions), 6L)
  res <- suppressWarnings(system2(
    rscript,
    c(shQuote(normalizePath(test_path("app-sourced-driver.R"))), shQuote(app),
      shQuote(normalizePath(test_path("app-checks.R")))),
    stdout = TRUE, stderr = TRUE
  ))
  expect_true(any(grepl("APP CHECKS OK", res, fixed = TRUE)), info = paste(res, collapse = "\n"))
})

test_that("the app's package code has no way to reach the network or a database", {
  source_tools <- test_path("..", "..", "tools", "app_sources.R")
  skip_if_not(file.exists(source_tools), "tools/ is not part of the installed package")
  env <- new.env()
  sys.source(source_tools, envir = env)
  r_dir <- test_path("..", "..", "R")
  cl <- env$app_closure(r_dir)
  all_defs <- env$app_collect_definitions(r_dir)
  all_text <- vapply(all_defs, function(d) d$text, character(1))
  # Network and database code exists in the package ...
  network <- names(all_defs)[grepl("httr2::|curl::", all_text)]
  database <- names(all_defs)[grepl("duckdb::", all_text)]
  expect_true(length(network) > 0L && length(database) > 0L)
  # ... and none of it is reachable from the app.
  expect_false(any(c(network, database, "fetch_swingvision", "sv_download_raw") %in% cl$names))
  text <- vapply(cl$defs, function(d) d$text, character(1))
  expect_false(any(grepl("httr2::|curl::|duckdb::|download\\.file|DBI::", text)))
})

test_that("the packages the export must bundle are derived from the code", {
  source_tools <- test_path("..", "..", "tools", "app_sources.R")
  skip_if_not(file.exists(source_tools), "tools/ is not part of the installed package")
  env <- new.env()
  sys.source(source_tools, envir = env)
  app_file <- test_path("..", "..", "inst", "app", "app.R")
  skip_if_not(file.exists(app_file), "inst/ app source not found")
  refs <- env$app_package_refs(test_path("..", "..", "R"), app_file)
  # what the closure and the app use
  expect_true(all(c("cli", "dplyr", "ggplot2", "jsonlite", "rlang", "tibble", "shiny", "bslib") %in% refs))
  # not the network or database code that is left out of the app
  expect_false(any(c("httr2", "duckdb", "DBI", "curl") %in% refs))

  # a package named by a function the app reaches is picked up; one named only
  # by a function it cannot reach, in a comment or in a string, is not
  r_dir <- withr::local_tempdir()
  writeLines(c(
    "reached <- function() zzzpkg::f()",
    "unreached <- function() yyypkg::g()",
    "# commented::out()",
    "text <- function() 'strpkg::h()'"
  ), file.path(r_dir, "a.R"))
  app <- withr::local_tempfile(fileext = ".R")
  writeLines(c("library(shiny)", "library(nonedot, character.only = TRUE)", "# library(commentedpkg)",
               "x <- appqualified::f()"), app)
  out <- env$app_package_refs(r_dir, app, entry = c("reached", "text"))
  expect_true(all(c("zzzpkg", "shiny", "appqualified") %in% out))
  expect_false(any(c("yyypkg", "commented", "strpkg", "nonedot", "commentedpkg") %in% out))
})

test_that("the runtime's own packages are read from the export, or reported as unknown", {
  source_tools <- test_path("..", "..", "tools", "app_sources.R")
  skip_if_not(file.exists(source_tools), "tools/ is not part of the installed package")
  env <- new.env()
  sys.source(source_tools, envir = env)
  dest <- withr::local_tempdir()
  expect_null(env$app_runtime_packages(dest))
  dir.create(file.path(dest, "shinylive", "webr"), recursive = TRUE)
  writeLines(
    '{"files":[{"filename":"/cli/DESCRIPTION","start":0,"end":1},{"filename":"/cli/NAMESPACE","start":1,"end":2},{"filename":"/shiny/DESCRIPTION","start":2,"end":3}]}',
    file.path(dest, "shinylive", "webr", "library.js.metadata")
  )
  got <- env$app_runtime_packages(dest)
  expect_true(all(c("cli", "shiny", "stats", "utils") %in% got))
  expect_false("ggplot2" %in% got)
  writeLines("not json", file.path(dest, "shinylive", "webr", "library.js.metadata"))
  expect_null(env$app_runtime_packages(dest))
})
