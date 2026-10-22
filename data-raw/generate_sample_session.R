#!/usr/bin/env Rscript

# Builds the EXTRA synthetic session, inst/extdata/synthetic_sample_session/:
# one session that is NOT in the bundled sample bundle, saved as the three raw
# JSON files (match, stats, shots) that the browser app's step 2 ("Drop the
# saved JSON files") and bundle_add_raw() accept. It lets someone try "add a
# session" on top of the sample bundle.
#
# Nothing is typed in by hand: the session is the 7th session of the same
# synthetic generator that made the six in the sample bundle
# (data-raw/generate_sample.R, same seed, so sessions 1-6 are the sample's and
# are left alone), written out by the same code that built the bundle's raw
# payloads (data-raw/generate_sample_bundle.R). Like them it holds no real
# session: the players are "Sample Player" and "Sample Opponent".
#
# Usage (from the rallyr package root):
#   Rscript data-raw/generate_sample_session.R

.args <- commandArgs(trailingOnly = FALSE)
.self <- sub("^--file=", "", .args[grep("^--file=", .args)])
if (length(.self) == 1L && nzchar(.self)) {
  setwd(normalizePath(file.path(dirname(.self), "..")))
}

if (identical(Sys.getenv("SYNTHETIC_SESSION_SKIP_LOAD"), "")) {
  pkgload::load_all(quiet = TRUE)
}

# The two generators run no main step when sourced from here.
.root <- getwd()
.skip <- c("SYNTHETIC_SAMPLE_SKIP_LOAD", "SYNTHETIC_SAMPLE_SKIP_MAIN",
           "SYNTHETIC_BUNDLE_SKIP_LOAD", "SYNTHETIC_BUNDLE_SKIP_MAIN")
.old <- Sys.getenv(.skip, unset = NA)
do.call(Sys.setenv, stats::setNames(as.list(rep("1", length(.skip))), .skip))
source(file.path(.root, "data-raw", "generate_sample.R"), local = environment())
source(file.path(.root, "data-raw", "generate_sample_bundle.R"), local = environment())
for (.nm in .skip) {
  if (is.na(.old[[.nm]])) Sys.unsetenv(.nm) else do.call(Sys.setenv, stats::setNames(list(.old[[.nm]]), .nm))
}

#' The extra session's raw payloads
#'
#' @param n_in_bundle How many sessions the sample bundle holds; the extra
#'   session is the next one the generator produces.
#' @return A list with `match`, `stats` and `shots`, each `list(data = ...)`.
#' @keywords internal
.synthetic_extra_session <- function(n_in_bundle = 6L) {
  data <- generate_synthetic_sample(n_sessions = n_in_bundle + 1L)
  id <- max(data$matches$match_id)
  m <- data$matches[data$matches$match_id == id, ]
  shots <- data$shot_detail[data$shot_detail$match_id == id, ]
  .synthetic_raw_for_match(m, shots)
}

#' Write the three payloads as JSON files; returns the paths.
#' @keywords internal
.write_extra_session <- function(raw, dir = "inst/extdata/synthetic_sample_session") {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  paths <- file.path(dir, sprintf("sample_session_%s.json", c("match", "stats", "shots")))
  for (i in seq_along(paths)) {
    writeLines(
      as.character(jsonlite::toJSON(raw[[c("match", "stats", "shots")[i]]],
                                    auto_unbox = TRUE, null = "null", digits = NA)),
      paths[i]
    )
  }
  paths
}

if (identical(Sys.getenv("SYNTHETIC_SESSION_SKIP_MAIN"), "")) {
  paths <- .write_extra_session(.synthetic_extra_session())
  message(paste(sprintf("Wrote %s (%d bytes)", paths, file.size(paths)), collapse = "\n"))
}
