# Checks of the browser app's server logic, driven without a browser.
#
# `run_app_checks(app_dir)` is used twice: in-process against inst/app (the
# installed package is used), and in a clean R process against the assembled
# app folder (only the bundled package code is available there), so a
# function the app needs but the closure left out fails the second run.
# Each check uses stopifnot() so it works with or without testthat.

run_app_checks <- function(app_dir) {
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)

  write_payloads <- function(session, dir, id, token) {
    session$match$data$id <- id
    for (i in seq_along(session$shots$data)) session$shots$data[[i]]$match_id <- id
    out <- character(0)
    for (k in c("match", "stats", "shots")) {
      p <- file.path(dir, sprintf("%s_%s.json", token, k))
      writeLines(jsonlite::toJSON(session[[k]], auto_unbox = TRUE, null = "null", digits = NA), p)
      out[k] <- p
    }
    out
  }
  drop_files <- function(paths, names = basename(paths)) {
    data.frame(name = names, size = file.size(paths), type = "application/json", datapath = paths)
  }

  sample_file <- file.path(app_dir, "data", "synthetic_sample_bundle.json.gz")
  if (!file.exists(sample_file)) {
    sample_file <- system.file("extdata", "synthetic_sample_bundle.json.gz", package = "rallyr")
  }
  sample <- bundle_read(sample_file)
  work <- tempfile("appchecks")
  dir.create(work)

  shiny::testServer(app_dir, {
    # 1. The sample shows without any upload, once a name is entered.
    session$setInputs(me = "Sample Player")
    for (k in 1:30) {
      session$setInputs(tick = k)
      if (prime$ready) break
    }
    stopifnot("sample was not read in steps" = isTRUE(prime$ready), prime$total == 6L)
    d <- derived()
    stopifnot(nrow(d$sessions) == 6L, !is.null(d$session_metrics), nrow(d$corrected_rallies) > 0L)
    # every plot renders (a plot that errors has no `src`)
    for (id in c("plot_trend", "plot_rally", "plot_speed", "plot_net", "plot_gap")) {
      stopifnot(
        "a plot did not render" = !is.null(output[[id]]$src),
        "a plot reported an error" = is.null(output[[id]]$error)
      )
    }

    # 2. A name that is not in the data gives a message, not a crash.
    session$setInputs(me = "Nobody At All")
    for (k in 31:60) {
      session$setInputs(tick = k)
      if (prime$ready) break
    }
    err <- tryCatch(derived(), error = function(e) conditionMessage(e))
    stopifnot("unknown name should be reported" = is.character(err) && grepl("No session has a player", err))

    # 3. Dropping three saved files starts a NEW bundle (the sample is not
    #    mixed with the user's data) and the report says "added".
    session$setInputs(me = "Sample Player")
    s1 <- write_payloads(sample$sessions[[1]], work, 7000001, "one")
    session$setInputs(share_url = "https://example.invalid/matches/sw2-EXAMPLE01")
    session$setInputs(raw_files = drop_files(unname(s1)))
    session$setInputs(merge = 1)
    stopifnot(length(bundle()$sessions) == 1L, source_kind() == "user")
    stopifnot(identical(merge_result()$report$action, "added"))
    stopifnot("token not recorded" = identical(bundle()$sessions[[1]]$token, "sw2-EXAMPLE01"))

    # 4. A second session is added to that bundle; the same files again are
    #    reported as unchanged.
    s2 <- write_payloads(sample$sessions[[2]], work, 7000002, "two")
    session$setInputs(raw_files = drop_files(unname(s2)))
    session$setInputs(merge = 2)
    stopifnot(length(bundle()$sessions) == 2L)
    session$setInputs(merge = 3)
    stopifnot(identical(merge_result()$report$action, "unchanged"), length(bundle()$sessions) == 2L)

    # 5. Too few files is refused with the bundle untouched.
    session$setInputs(raw_files = drop_files(unname(s2[1:2])))
    session$setInputs(merge = 4)
    stopifnot(length(bundle()$sessions) == 2L)

    # 6. The download is a bundle that reads back with both sessions.
    path <- output$download
    back <- bundle_read(path)
    stopifnot(length(back$sessions) == 2L)

    # 7. Their own bundle can be uploaded to replace what is shown.
    session$setInputs(bundle_file = drop_files(path, "my_bundle.json.gz"))
    stopifnot(length(bundle()$sessions) == 2L)

    # 8. Text the user controls (file names, player names) is escaped, never
    #    inserted as HTML.
    html_of <- function(x) paste(unlist(x), collapse = " ")
    evil_file <- "<script>alert(1)</script>.json"
    session$setInputs(raw_files = drop_files(unname(s2), c(evil_file, "b.json", "c.json")))
    detect <- html_of(output$raw_detect)
    stopifnot(
      "file name was not escaped" = !grepl("<script>", detect, fixed = TRUE),
      "file name is not shown" = grepl("&lt;script&gt;", detect, fixed = TRUE)
    )
    evil_name <- "<script>alert(2)</script>"
    s3 <- sample$sessions[[3]]
    s3$match$data$guest_name <- evil_name
    p3 <- write_payloads(s3, work, 7000003, "three")
    session$setInputs(raw_files = drop_files(unname(p3)))
    session$setInputs(merge = 5)
    session$setInputs(me = evil_name)
    for (k in 61:100) {
      session$setInputs(tick = k)
      if (prime$ready) break
    }
    stopifnot("the bundle was not updated" = length(bundle()$sessions) == 3L)
    stopifnot("the player was not read" = nrow(derived()$sessions) == 1L)
    for (id in c("status", "merge_msg", "merge_summary", "merge_table", "summary", "sessions", "api_links")) {
      stopifnot(
        "a player name reached the page as HTML" = !grepl("<script>", html_of(output[[id]]), fixed = TRUE)
      )
    }
  })
  invisible(TRUE)
}
