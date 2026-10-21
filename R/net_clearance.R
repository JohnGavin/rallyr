#' Null implausible net-clearance heights without dropping the stroke
#'
#' `net_clearance_m` is the third component of the vendor's `net_location`
#' (see [sv_net_clearance_m()]). **The vendor does not state whether it is
#' the height above the ground or above the net tape**, so it is reported as
#' supplied and only a loose plausibility range is applied
#' (`min_net_clearance_m` / `max_net_clearance_m` in [dq_params()]). A value
#' outside the range, or not finite, is set to `NA` and flagged in
#' `net_clearance_implausible`; the row is kept (the stroke happened, only
#' one measurement of it is untrustworthy). A value that was already `NA` is
#' not flagged: nothing was supplied.
#'
#' @param shot_detail A tibble with `net_clearance_m`.
#' @param params A `dq_params()`-shaped list.
#' @return `shot_detail` with `net_clearance_m` nulled where implausible and a
#'   logical `net_clearance_implausible` (never `NA`).
#' @export
dq_clean_net_clearance <- function(shot_detail, params = dq_params()) {
  if (!"net_clearance_m" %in% names(shot_detail)) {
    cli::cli_abort(c(
      "x" = "Column {.field net_clearance_m} not found in {.arg shot_detail}.",
      "i" = "Available: {.val {names(shot_detail)}}."
    ))
  }
  x <- shot_detail$net_clearance_m
  bad <- !is.na(x) & (!is.finite(x) | x < params$min_net_clearance_m | x > params$max_net_clearance_m)
  x[bad] <- NA_real_
  shot_detail$net_clearance_m <- x
  shot_detail$net_clearance_implausible <- bad
  shot_detail
}

#' Median net clearance per session and drill, me versus the feeder
#'
#' One row per `match_id` and drill (`regime`): the median clearance in
#' metres and the number of values behind it for the "me" side and for the
#' feeder (`opp_*`), and the difference (`diff_m`, me minus feeder, `NA` when
#' either side has no value). The median is used, not the mean, because of the
#' tail of implausible values. Values are cleaned with
#' [dq_clean_net_clearance()] first; `n_implausible` counts those nulled,
#' both sides together. Rows with no regime are left out. Clearance is most
#' meaningful for the cross-court drills and a weaker signal at short range.
#'
#' Join `session_date` from [tennis_matches()] by `match_id`, and combine
#' same-day matches with care: medians do not add.
#'
#' @param shot_detail A tibble with `match_id`, `regime`, `player` and
#'   `net_clearance_m` (see [tennis_shot_detail()]).
#' @param params A `dq_params()`-shaped list.
#' @param me_side,feeder_side The `player` values for each side.
#' @return A tibble: `match_id`, `regime`, `me_median_m`, `me_n`,
#'   `opp_median_m`, `opp_n`, `diff_m`, `n_implausible`.
#' @export
session_net_clearance_by_drill <- function(shot_detail, params = dq_params(),
                                           me_side = "guest", feeder_side = "host") {
  need <- c("match_id", "regime", "player", "net_clearance_m")
  if (!all(need %in% names(shot_detail))) {
    cli::cli_abort("{.arg shot_detail} needs {.val {need}}.")
  }
  d <- dq_clean_net_clearance(shot_detail[, need], params)
  d <- d[!is.na(d$regime), ]
  d$side <- dplyr::case_when(
    d$player %in% me_side ~ "me",
    d$player %in% feeder_side ~ "opp",
    TRUE ~ NA_character_
  )
  keys <- dplyr::summarise(
    d, n_implausible = sum(.data$net_clearance_implausible),
    .by = c("match_id", "regime")
  )
  side_stats <- function(side) {
    s <- d[!is.na(d$side) & d$side == side & !is.na(d$net_clearance_m), ]
    s <- dplyr::summarise(
      s, med = stats::median(.data$net_clearance_m), n = dplyr::n(),
      .by = c("match_id", "regime")
    )
    names(s) <- c("match_id", "regime", paste0(side, c("_median_m", "_n")))
    s
  }
  out <- keys |>
    dplyr::left_join(side_stats("me"), by = c("match_id", "regime")) |>
    dplyr::left_join(side_stats("opp"), by = c("match_id", "regime"))
  out$me_n <- as.integer(dplyr::coalesce(out$me_n, 0L))
  out$opp_n <- as.integer(dplyr::coalesce(out$opp_n, 0L))
  out$diff_m <- out$me_median_m - out$opp_median_m
  out$n_implausible <- as.integer(out$n_implausible)
  out[, c("match_id", "regime", "me_median_m", "me_n", "opp_median_m", "opp_n",
          "diff_m", "n_implausible")] |>
    dplyr::arrange(.data$match_id, .data$regime)
}
