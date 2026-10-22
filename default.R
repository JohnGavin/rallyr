# Nix environment for the `rallyr` package (generated via rix).
# Regenerate default.nix (from a shell that has rix) with:
#   (cd <rallyr checkout> && nix-shell <path-to-a-rix-shell>/default.nix --run "Rscript default.R")
# NB angle brackets, not quote characters, in comments (Nix parses quotes in comments).

library(rix)

r_pkgs <- c(
  # runtime (DESCRIPTION Imports)
  "cli", "DBI", "dplyr", "duckdb", "httr2", "jsonlite", "rlang", "tibble",
  # DESCRIPTION Suggests (app, charts, vignette)
  "bslib", "ggplot2", "knitr", "rmarkdown", "shiny",
  # dev / test (DESCRIPTION Suggests + tooling)
  "pkgload", "testthat", "withr", "devtools", "roxygen2", "rcmdcheck"
) |>
  unique() |>
  sort()

# Pinned date: bump only deliberately.
rix(
  date = "2026-02-02",
  project_path = ".",
  overwrite = TRUE,
  r_pkgs = r_pkgs,
  # pandoc: rmarkdown needs it to build the vignette in R CMD check.
  # nodejs: the browser app is plain JavaScript; the tests that compare it with
  # the R functions (tests/testthat/test-js_parity.R) run it with node.
  system_pkgs = c("pandoc", "nodejs"),
  ide = "none"
)

cli::cli_alert_info("Generated default.nix for rallyr via rix.")
