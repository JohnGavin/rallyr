#' Format a speed in mph as "X km/h (Y mph)", both rounded to the nearest integer
#'
#' Single source of truth for the km/h-primary, mph-in-brackets speed display
#' used across `dashboard.qmd` and `scripts/make_artifact_charts.R`, so the
#' two surfaces can't drift to different precision or unit order.
#'
#' @param mph A numeric vector of speeds in mph. `NA` becomes `"-"`.
#' @return A character vector, e.g. `"76 km/h (47 mph)"`.
#' @export
fmt_speed_mph <- function(mph) {
  ifelse(is.na(mph), "-", sprintf("%.0f km/h (%.0f mph)", mph * 1.609344, mph))
}

#' Format decimal minutes as "Xm YYs" (minutes and seconds, never a decimal)
#'
#' Single source of truth for drill-duration display (issue #40 -- "how
#' long each drill lasts in minutes and seconds", not decimal minutes like
#' "7.5"). Used as a `scale_*_continuous(labels = fmt_mmss)` axis formatter
#' in `scripts/make_artifact_charts.R`'s duration charts, and available for
#' any other duration display that should read the same way.
#'
#' @param minutes A numeric vector of durations in decimal minutes (as
#'   stored in `shot_segments.duration_min` / [tennis_segments()]). `NA`
#'   becomes `"-"`.
#' @return A character vector, e.g. `"7m 30s"`, `"0m 06s"`.
#' @export
fmt_mmss <- function(minutes) {
  total_sec <- round(minutes * 60)
  ifelse(is.na(minutes), "-", sprintf("%dm %02ds", total_sec %/% 60, total_sec %% 60))
}
