#' Session performance metrics on one comparable scale
#'
#' ISSUES.md #32: the tracked session metrics are raw totals in incompatible
#' units (strokes, miles, mph, minutes), so a longer session scores higher on
#' most of them for no reason other than being longer. This function fixes the
#' unit problem in two steps, deliberately kept separate because they answer
#' different questions:
#'
#' 1. **Length-normalisation.** Every metric is defined as a percentage or a
#'    per-minute rate, never a raw total, so a 36-minute session and a
#'    58-minute one are directly comparable. This is the "standardised"
#'    the issue asks for.
#' 2. **Cross-metric comparability.** A percentage and a km/h still cannot be
#'    ranked against each other, so each metric is additionally expressed as
#'    its percentile within its *own* distribution across all sessions. That
#'    is what makes "which metric did this session stand out on?" answerable,
#'    and it is what [session_metric_ranks()] ranks.
#'
#' This is deliberately NOT [session_effort_metrics()], which z-scores four
#' raw metrics and averages them into one composite index. That answers "how
#' hard was this session overall"; this answers "which aspects of this session
#' were strong or weak relative to my own history", and keeps the metrics
#' separate rather than collapsing them.
#'
#' **Direction.** Ranking implies a better/worse axis, and not every metric has
#' one. `direction` is `1` where higher is better, `-1` where lower is better,
#' and `NA` for descriptive metrics with no defensible direction — forehand
#' share is the case in point: an unusually forehand-heavy session is a fact
#' about the drill (ISSUES.md #3), not an achievement. `NA`-direction metrics
#' are returned, so they can still be read and plotted, but [session_metric_ranks()]
#' excludes them from the ranking rather than silently implying they are good.
#'
#' @param m Merged per-session tibble ([merge_same_day_sessions()] output),
#'   ordered chronologically (oldest first), with at least 2 rows.
#' @return A long tibble, one row per session-metric: `session_date`,
#'   `metric` (a short stable key), `label` (display text), `unit`, `value`
#'   (the length-normalised value), `direction` (`1`/`-1`/`NA`) and `pct`
#'   (0-100 percentile of `value` within that metric across sessions).
#' @seealso [session_metric_ranks()] for the per-session ranking the bump
#'   chart plots, and [session_effort_metrics()] for the composite index.
#' @export
session_standard_metrics <- function(m) {
  stopifnot(
    "need at least 2 sessions to place a value within a distribution" = nrow(m) >= 2,
    "m must be pre-sorted chronologically (oldest first)" = !is.unsorted(m$session_date)
  )

  wing_shots <- m$fh_shots + m$bh_shots
  defs <- list(
    list(metric = "accuracy",   label = "Stroke accuracy",  unit = "%",
         direction = 1,  value = m$shots_in_pct),
    list(metric = "stroke_rate", label = "Stroke rate",     unit = "strokes/min",
         direction = 1,  value = m$me_shots / m$duration_min),
    list(metric = "speed",      label = "Stroke speed",     unit = "mph",
         direction = 1,  value = (m$fh_speed_mph + m$bh_speed_mph) / 2),
    list(metric = "run_rate",   label = "Court coverage",   unit = "mi/min",
         direction = 1,  value = m$me_run_mi / m$duration_min),
    list(metric = "shot_share", label = "Share of strokes", unit = "%",
         direction = 1,  value = 100 * m$me_shots / (m$me_shots + m$opp_shots)),
    # No defensible direction: forehand-heavy is a property of the drill
    # (ISSUES.md #3), not a better or worse session. Reported, never ranked.
    list(metric = "fh_share",   label = "Forehand share",   unit = "%",
         direction = NA_real_, value = 100 * m$fh_shots / wing_shots)
  )

  dplyr::bind_rows(lapply(defs, function(d) {
    tibble::tibble(
      session_date = m$session_date,
      metric       = d$metric,
      label        = d$label,
      unit         = d$unit,
      value        = d$value,
      direction    = d$direction,
      pct          = pct_rank(d$value)
    )
  }))
}

#' Percentile rank of each value within a vector, 0-100
#'
#' Ties share their average rank. A vector with no variation maps to 50 for
#' every element — the midpoint — rather than to 0 or 100, neither of which
#' is a defensible reading of "every session was identical".
#'
#' @param x Numeric vector.
#' @return Numeric vector the same length as `x`, in `[0, 100]`; `NA` inputs
#'   stay `NA`.
#' @keywords internal
pct_rank <- function(x) {
  ok <- !is.na(x)
  n <- sum(ok)
  out <- rep(NA_real_, length(x))
  if (n == 0L) return(out)
  if (n == 1L || stats::sd(x[ok]) == 0) {
    out[ok] <- 50
    return(out)
  }
  out[ok] <- 100 * (rank(x[ok], ties.method = "average") - 1) / (n - 1)
  out
}

#' Rank each session's metrics against each other
#'
#' The input for the bump chart (ISSUES.md #32): within each session, the
#' directional metrics from [session_standard_metrics()] are ranked by their
#' percentile, so rank 1 is the aspect that session was strongest on relative
#' to the player's own history. Lines joining one metric's rank across
#' consecutive sessions are what the bump chart draws.
#'
#' Metrics with `direction = NA` are dropped, not ranked — see
#' [session_standard_metrics()] for why. A metric where lower is better has
#' its percentile flipped before ranking, so rank 1 always means "best".
#'
#' @param sm Output of [session_standard_metrics()].
#' @return A tibble with `session_date`, `metric`, `label`, `pct`, `score`
#'   (direction-adjusted percentile) and `rank` (1 = best that session).
#' @export
session_metric_ranks <- function(sm) {
  stopifnot("sm must have a `direction` column" = "direction" %in% names(sm))
  ranked <- sm[!is.na(sm$direction), , drop = FALSE]
  if (nrow(ranked) == 0L) {
    return(tibble::tibble(
      session_date = as.Date(character()), metric = character(),
      label = character(), pct = numeric(), score = numeric(), rank = integer()
    ))
  }
  ranked |>
    dplyr::mutate(score = ifelse(.data$direction < 0, 100 - .data$pct, .data$pct)) |>
    dplyr::group_by(.data$session_date) |>
    # ties.method = "first" keeps ranks a dense 1..k permutation, which a bump
    # chart needs -- "average" would put two lines on a shared fractional row.
    dplyr::mutate(rank = as.integer(rank(-.data$score, ties.method = "first"))) |>
    dplyr::ungroup() |>
    dplyr::select("session_date", "metric", "label", "pct", "score", "rank") |>
    dplyr::arrange(.data$session_date, .data$rank)
}
