# Fixtures for the bundle tests: the committed SYNTHETIC sample bundle, and
# helpers that write its payloads out as separate JSON files (as a person
# would save them from the three API links).

sample_bundle_path <- function() {
  system.file("extdata", "synthetic_sample_bundle.json.gz", package = "rallyr")
}

sample_bundle <- function() bundle_read(sample_bundle_path())

# One sample session, re-keyed to `id` (all of its shots too).
sample_session <- function(i = 1L, id = NULL) {
  s <- sample_bundle()$sessions[[i]]
  if (!is.null(id)) {
    s$match_id <- id
    s$match$data$id <- id
    for (k in seq_along(s$shots$data)) s$shots$data[[k]]$match_id <- id
  }
  s
}

# Write a session's three payloads as JSON files named by `names`
# (deliberately not saying which is which); returns the paths.
write_session_files <- function(s, dir, names = c("a.json", "b.json", "c.json"), wrap = TRUE) {
  payloads <- list(s$match, s$stats, s$shots)
  paths <- file.path(dir, names)
  for (i in 1:3) {
    p <- payloads[[i]]
    if (!wrap) p <- p$data
    writeLines(jsonlite::toJSON(p, auto_unbox = TRUE, null = "null", digits = NA), paths[i])
  }
  paths
}

bundle_of <- function(...) {
  b <- bundle_new()
  b$sessions <- list(...)
  b
}
