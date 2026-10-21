# Run in a clean R process (Rscript <this file> <app_dir> <checks_file>): loads
# only what the browser would have, then runs the app checks. The rallyr
# package itself is deliberately not attached.
args <- commandArgs(trailingOnly = TRUE)
app_dir <- args[1]
checks <- args[2]
for (p in c("shiny", "bslib", "ggplot2")) {
  library(p, character.only = TRUE)
}
stopifnot(!"package:rallyr" %in% search())
.data <- rlang::.data
source(file.path(app_dir, "pkg_R", "rallyr_app_sources.R"), local = globalenv())
source(checks)
run_app_checks(app_dir)
cat("APP CHECKS OK\n")
