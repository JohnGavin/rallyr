#!/usr/bin/env Rscript

# Assemble the Shiny version of the app (inst/app/app.R) into a folder.
#
#   Rscript tools/assemble_shiny_app.R [--app-dir=<dir>]
#
# The website's app is now plain JavaScript (inst/app_js/, built by
# tools/build_app.R). The Shiny version still runs in R on your own computer:
#
#   shiny::runApp(system.file("app", package = "rallyr"))
#
# This script builds the folder a browser-side R runtime would load: app.R, the
# package code the app can reach (pkg_R/, see tools/app_sources.R), and data/
# (the synthetic sample bundle, the extra session's JSON files and the sample's
# precomputed tables). The tests use it to run the Shiny app from bundled code
# alone, as a clean process, and to check that code for network access. It
# writes into a fresh folder under tempdir() unless --app-dir is given, and
# never inside the repository.

args <- commandArgs(trailingOnly = TRUE)
self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
root <- normalizePath(file.path(dirname(self), ".."))
source(file.path(root, "tools", "app_sources.R"))

app_dir_arg <- sub("^--app-dir=", "", grep("^--app-dir=", args, value = TRUE))
app_build <- if (length(app_dir_arg) == 1L) normalizePath(app_dir_arg, mustWork = FALSE) else file.path(tempdir(), "rallyr_app")
if (dir.exists(app_build)) unlink(app_build, recursive = TRUE)
dir.create(file.path(app_build, "data"), recursive = TRUE)
invisible(file.copy(file.path(root, "inst", "app", "app.R"), file.path(app_build, "app.R")))
invisible(file.copy(
  file.path(root, "inst", "extdata", "synthetic_sample_bundle.json.gz"),
  file.path(app_build, "data", "synthetic_sample_bundle.json.gz")
))
# The extra synthetic session (three raw JSON files) the app offers for download.
dir.create(file.path(app_build, "data", "synthetic_sample_session"))
extra_files <- list.files(file.path(root, "inst", "extdata", "synthetic_sample_session"), full.names = TRUE)
if (length(extra_files) == 0L) stop("inst/extdata/synthetic_sample_session/ holds no files.", call. = FALSE)
invisible(file.copy(extra_files, file.path(app_build, "data", "synthetic_sample_session")))
written <- app_write_sources(
  file.path(root, "R"), file.path(app_build, "pkg_R", "rallyr_app_sources.R")
)

# The synthetic sample's tables and derived data, computed here once with the
# same bundled code the app runs, so the app shows the sample without parsing
# six sessions. Only the sample is precomputed: a bundle the visitor supplies is
# always derived live. The player's name is read from app.R, its one home.
app_lines <- readLines(file.path(app_build, "app.R"), warn = FALSE)
name_line <- grep('^sample_player <- "[^"]+"\\s*$', app_lines, value = TRUE)
if (length(name_line) != 1L) stop("Could not read `sample_player` from app.R.", call. = FALSE)
sample_me <- sub('^sample_player <- "([^"]+)"\\s*$', "\\1", name_line)
local({
  e <- new.env(parent = globalenv())
  e$.data <- rlang::.data
  source(file.path(app_build, "pkg_R", "rallyr_app_sources.R"), local = e)
  tables <- e$bundle_to_tables(
    e$bundle_read(file.path(app_build, "data", "synthetic_sample_bundle.json.gz")),
    sample_me
  )
  saveRDS(
    list(me = sample_me, tables = tables, derived = e$bundle_derived(tables)),
    file.path(app_build, "data", "sample_derived.rds")
  )
})
message(sprintf("Assembled %s with %d package definitions.", app_build, length(written)))
