#!/usr/bin/env Rscript

# Build the browser app.
#
#   Rscript tools/build_app.R [site_dir] [--assemble-only] [--app-dir=<dir>]
#
# 1. Assembles an app folder (default _app_build/): app.R, the package code
#    the app can reach (pkg_R/, see tools/app_sources.R) and the synthetic
#    sample bundle (data/).
# 2. Exports it with shinylive into <site_dir>/app (default _site/), the
#    Shinylive runtime and the WebAssembly R packages it needs being copied
#    next to it, so the page loads nothing from other sites.
# 3. Adds the Content-Security-Policy (inst/app/csp.txt) to the exported pages.
#
# --assemble-only stops after step 1 (used where shinylive is not installed).

args <- commandArgs(trailingOnly = TRUE)
assemble_only <- "--assemble-only" %in% args
pos <- args[!startsWith(args, "--")]
site_dir <- if (length(pos) >= 1L) pos[1] else "_site"

self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
root <- normalizePath(file.path(dirname(self), ".."))
source(file.path(root, "tools", "app_sources.R"))

app_dir_arg <- sub("^--app-dir=", "", grep("^--app-dir=", args, value = TRUE))
app_build <- if (length(app_dir_arg) == 1L) normalizePath(app_dir_arg, mustWork = FALSE) else file.path(root, "_app_build")
if (dir.exists(app_build)) unlink(app_build, recursive = TRUE)
dir.create(file.path(app_build, "data"), recursive = TRUE)
invisible(file.copy(file.path(root, "inst", "app", "app.R"), file.path(app_build, "app.R")))
invisible(file.copy(
  file.path(root, "inst", "extdata", "synthetic_sample_bundle.json.gz"),
  file.path(app_build, "data", "synthetic_sample_bundle.json.gz")
))
written <- app_write_sources(
  file.path(root, "R"), file.path(app_build, "pkg_R", "rallyr_app_sources.R")
)
message(sprintf("Assembled %s with %d package definitions.", app_build, length(written)))
if (assemble_only) quit(status = 0)

if (!requireNamespace("shinylive", quietly = TRUE)) {
  message("The shinylive package is not installed: cannot export (exit 3 = indeterminate).")
  quit(status = 3)
}

dest <- normalizePath(site_dir, mustWork = FALSE)
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
shinylive::export(app_build, dest, subdir = "app")

csp <- trimws(readLines(file.path(root, "inst", "app", "csp.txt"), warn = FALSE))
meta <- sprintf('<meta http-equiv="Content-Security-Policy" content="%s">', csp)
for (page in c(file.path(dest, "app", "index.html"), file.path(dest, "app", "edit", "index.html"))) {
  if (!file.exists(page)) next
  html <- paste(readLines(page, warn = FALSE), collapse = "\n")
  if (grepl("Content-Security-Policy", html, fixed = TRUE)) next
  if (!grepl("<head[^>]*>", html)) stop("No <head> found to add the CSP to in ", page, call. = FALSE)
  html <- sub("(<head[^>]*>)", paste0("\\1\n", gsub("\\", "\\\\", meta, fixed = TRUE)), html)
  writeLines(html, page)
  message("Added the CSP to ", page)
}
message("Exported the app to ", file.path(dest, "app"))
