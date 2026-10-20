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
