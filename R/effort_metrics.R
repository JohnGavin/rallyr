#' Session-level "effort" index — standardised composite of raw metrics
#'
#' issue #22: the Summary page showed raw tracked metrics only; there
#' was no single view answering "did the most recent session stand out —
#' positively or negatively — from the rest, and on what?" The raw metrics
#' that plausibly compose physical effort (distance run, stroke volume,
#' stroke speed, pace) are in incompatible units (km, count, km/h,
#' strokes/min), so they can't be added together directly without an
#' arbitrary weighting scheme.
#'
#' The approach here avoids inventing weights: each raw metric is
#' converted to a z-score (how many standard deviations it sits from its
#' own all-time mean), which puts all four on one common, unit-free scale.
#' The four z-scores are then combined with an EQUAL weighting — not
#' because effort is known to split evenly across these four inputs (it
#' isn't), but because there is no external evidence to justify any other
#' weighting, and equal-weighting a standardised composite is the
#' conventional default in that situation. This is a *relative* index
#' (how this session compares to this player's own history), not an
#' absolute physiological measurement — the artifact's caption says so
#' explicitly; see `statistical-reporting`'s numeric-honesty conventions.
#'
#' @param m Merged per-session tibble ([merge_same_day_sessions()] output)
#'   — must include `me_run_km`, `me_shots`, `fh_speed_kmh`,
#'   `bh_speed_kmh`, `duration_min`, ordered chronologically (oldest
#'   first, as every session-ordered object in this project is).
#' @return `m` with 5 new columns: `z_distance`, `z_shots`, `z_speed`,
#'   `z_pace` (each metric's z-score) and `effort_z` (their row mean —
#'   the composite index).
#' @export
session_effort_metrics <- function(m) {
  stopifnot(
    "need at least 2 sessions to compute a standard deviation" = nrow(m) >= 2,
    "m must be pre-sorted chronologically (oldest first)" = !is.unsorted(m$session_date)
  )
  z <- function(x) {
    s <- stats::sd(x, na.rm = TRUE)
    if (is.na(s) || s == 0) return(rep(0, length(x)))  # no variation -> no deviation, not NaN
    (x - mean(x, na.rm = TRUE)) / s
  }

  mean_speed_kmh <- (m$fh_speed_kmh + m$bh_speed_kmh) / 2
  shots_per_min  <- m$me_shots / m$duration_min

  m$z_distance <- z(m$me_run_km)
  m$z_shots    <- z(m$me_shots)
  m$z_speed    <- z(mean_speed_kmh)
  m$z_pace     <- z(shots_per_min)
  m$effort_z   <- rowMeans(cbind(m$z_distance, m$z_shots, m$z_speed, m$z_pace), na.rm = TRUE)
  m
}
