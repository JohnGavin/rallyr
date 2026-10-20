#' Stroke-quality composite per session
#'
#' Combines the available per-stroke signals into one number per session, so
#' it can be tracked over time ([stroke_quality_trend()]). Only the "me"
#' side's strokes in the cross-court drills are used (`regimes`), the drills
#' where bounce location is a meaningful signal.
#'
#' Three components are computed per session (same-day matches pooled via
#' `matches$session_date`, so a recording split in two is one session):
#'
#' - `speed_mph`: median stroke speed, after [dq_clean_shot_speed()].
#' - `zone_score`: mean of [zone_score_numeric()] over the strokes
#'   [cross_court_zone_score()] could score (the feeder's next stroke is the
#'   response signal; strokes without one are left out, not counted as 0).
#' - `clearance_m`: median net clearance, after [dq_clean_net_clearance()].
#'
#' Each is standardised across the sessions supplied (z-score; a component
#' with no variation across two or more sessions standardises to 0, never
#' `NaN`; a component present in fewer than two sessions has no spread to
#' standardise against, so its z-score is `NA`, not 0), so the scores are
#' relative to the history passed in, and adding a session changes earlier
#' values. With one session, `quality` is therefore `NA`. The composite `quality` is the weighted mean of the
#' standardised components that are present for that session; a missing
#' component is left out and the weights renormalised, and `quality` is `NA`
#' when no weighted component is present. Weights are `weights`, by default
#' `dq_params()$stroke_quality_weights`.
#'
#' Not yet implemented: the quality of the feeder's strokes (for a relative
#' measure) and an indoor/outdoor split.
#'
#' @param shot_detail A tibble from [tennis_shot_detail()].
#' @param matches A tibble with `match_id` and `session_date`
#'   ([tennis_matches()]).
#' @param params A `dq_params()`-shaped list.
#' @param weights A named list or vector with non-negative `speed`, `zone`
#'   and `clearance` weights, not all zero.
#' @param regimes The drills to include.
#' @param me_side,feeder_side The `player` values for each side.
#' @param feeder_right_handed,me_right_handed Passed to
#'   [cross_court_zone_score()].
#' @return A tibble, one row per session, ordered by date: `session_date`,
#'   `n_strokes`, `speed_mph`, `zone_score`, `clearance_m`, `z_speed`,
#'   `z_zone`, `z_clearance` and `quality`.
#' @export
stroke_quality_session <- function(shot_detail, matches, params = dq_params(),
                                   weights = params$stroke_quality_weights,
                                   regimes = c("forehand_cross_court", "backhand_cross_court"),
                                   me_side = "guest", feeder_side = "host",
                                   feeder_right_handed = TRUE,
                                   me_right_handed = TRUE) {
  comps <- c("speed", "zone", "clearance")
  w <- unlist(weights)
  if (!is.numeric(w) || !setequal(names(w), comps) || anyNA(w) || any(w < 0) || sum(w) <= 0) {
    cli::cli_abort(c(
      "x" = "{.arg weights} must give non-negative {.field speed}, {.field zone} and {.field clearance} weights, not all zero."
    ))
  }
  need <- c("match_id", "rally_id", "regime", "player", "started_at", "hit_wing",
            "shot_speed_mph", "bounce_location_long", "bounce_location_lat",
            "net_clearance_m")
  if (!all(need %in% names(shot_detail))) {
    cli::cli_abort("{.arg shot_detail} needs {.val {need}}.")
  }
  if (!all(c("match_id", "session_date") %in% names(matches))) {
    cli::cli_abort("{.arg matches} needs {.val {c('match_id', 'session_date')}}.")
  }

  d <- shot_detail[, need]
  d <- d[order(d$match_id, d$rally_id, d$started_at), ]
  d <- dplyr::mutate(
    d,
    next_player = dplyr::lead(.data$player),
    next_hit_wing = dplyr::lead(.data$hit_wing),
    .by = c("match_id", "rally_id")
  )
  # Strokes with no rally id would be grouped together and paired with
  # unrelated neighbours: no "next stroke" is known for them.
  no_rally <- is.na(d$rally_id)
  d$next_player[no_rally] <- NA
  d$next_hit_wing[no_rally] <- NA
  d$zone <- zone_score_numeric(cross_court_zone_score(
    d$regime, d$player, d$bounce_location_long, d$bounce_location_lat,
    d$next_player, d$next_hit_wing, feeder_right_handed,
    me_side = me_side, feeder_side = feeder_side, me_right_handed = me_right_handed
  ))
  d <- dq_clean_shot_speed(d, params)
  d <- dq_clean_net_clearance(d, params)
  d <- d[d$player %in% me_side & d$regime %in% regimes, ]
  d <- dplyr::inner_join(
    d, matches[, c("match_id", "session_date")], by = "match_id"
  )
  d$session_date <- as.Date(d$session_date)

  sq <- dplyr::summarise(
    d,
    n_strokes = dplyr::n(),
    speed_mph = stats::median(.data$shot_speed_mph, na.rm = TRUE),
    zone_score = mean(.data$zone, na.rm = TRUE),
    clearance_m = stats::median(.data$net_clearance_m, na.rm = TRUE),
    .by = "session_date"
  )
  sq <- sq[order(sq$session_date), ]
  sq$n_strokes <- as.integer(sq$n_strokes)
  for (col in c("speed_mph", "zone_score", "clearance_m")) {
    sq[[col]][is.nan(sq[[col]]) | is.na(sq[[col]])] <- NA_real_
  }
  sq$z_speed <- quality_z(sq$speed_mph)
  sq$z_zone <- quality_z(sq$zone_score)
  sq$z_clearance <- quality_z(sq$clearance_m)

  z <- cbind(sq$z_speed, sq$z_zone, sq$z_clearance)
  wv <- unname(w[comps])
  have <- !is.na(z)
  num <- rowSums(sweep(ifelse(have, z, 0), 2, wv, `*`))
  den <- rowSums(sweep(have * 1, 2, wv, `*`))
  sq$quality <- ifelse(den > 0, num / den, NA_real_)
  tibble::as_tibble(sq)
}

# z-score; NA everywhere when fewer than 2 sessions have a value (no spread to
# standardise against, so 0 would be a claim); no variation across 2 or more
# -> 0 for present values; NA stays NA.
quality_z <- function(x) {
  ok <- !is.na(x)
  out <- rep(NA_real_, length(x))
  if (sum(ok) < 2L) return(out)
  s <- stats::sd(x[ok])
  out[ok] <- if (is.na(s) || s == 0) 0 else (x[ok] - mean(x[ok])) / s
  out
}

#' Stroke-quality trend: this session against the previous k
#'
#' For each session and each window `k`, the composite `quality` of the
#' session (`current`), the mean of the previous `k` sessions (`baseline`) and
#' `delta = current - baseline`. The baseline is `NA` unless `k` earlier
#' sessions exist and all have a value: a short history is not silently
#' averaged as if it were a full window. Sessions are sorted by date first.
#'
#' @param sq Output of [stroke_quality_session()] (needs `session_date` and
#'   `quality`).
#' @param windows Window sizes in sessions, by default 1, 2, 4 and 8: unique,
#'   finite whole numbers of at least 1 (anything else is an error).
#' @return A tibble, one row per session and window: `session_date`,
#'   `window`, `current`, `baseline`, `delta`.
#' @export
stroke_quality_trend <- function(sq, windows = c(1, 2, 4, 8)) {
  if (!all(c("session_date", "quality") %in% names(sq))) {
    cli::cli_abort("{.arg sq} needs {.field session_date} and {.field quality}.")
  }
  if (!is.numeric(windows) || length(windows) < 1L || !all(is.finite(windows)) ||
        any(windows < 1) || any(windows != round(windows)) || anyDuplicated(windows) > 0L) {
    cli::cli_abort(c(
      "x" = "{.arg windows} must be unique, finite whole numbers of at least 1."
    ))
  }
  sq <- sq[order(sq$session_date), ]
  n <- nrow(sq)
  rows <- lapply(as.integer(windows), function(k) {
    base <- vapply(seq_len(n), function(i) {
      if (i <= k) return(NA_real_)
      mean(sq$quality[(i - k):(i - 1L)])
    }, numeric(1))
    tibble::tibble(
      session_date = sq$session_date, window = k, current = sq$quality,
      baseline = base, delta = sq$quality - base
    )
  })
  dplyr::bind_rows(rows)
}
