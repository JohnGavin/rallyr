#' Ordered stroke-outcome severity: net fault worst, in play best
#'
#' Classifies each stroke by how it ended, in the order: never cleared the net
#' (`"net_fault"`) < cleared but out on both axes (`"out_both_axes"`) <
#' cleared but out on one axis, depth or width (`"out_one_axis"`) < in play
#' (`"in_bounds"`). It does not grade where within the court an in-play
#' stroke landed; see [cross_court_zone_score()] for that.
#'
#' **Net contact is not a fault.** A stroke that touches the net and still
#' crosses is in play. `net_contact` is a logical per stroke ("the ball
#' touched the net"); it is a net fault only when the ball provably never
#' crossed (`hit_court_side` equals `bounce_court_side`). With a contact but
#' an unknown side the answer is `NA`, not a guess. The persisted shot table
#' does not carry a net-contact call, and the vendor's one is unreliable
#' (rallyr#26): leave `net_contact` as `NA` and no stroke is ever called a net
#' fault, so only the out-of-play levels are produced. Supply it once a
#' reliable call exists.
#'
#' A stroke whose bounce depth and width are both unknown is `NA`. If only one
#' axis is known, the unknown one is treated as not out.
#'
#' Vectorised; arguments are recycled to the longest.
#'
#' @param net_contact Logical (or `NA`): did the ball touch the net?
#' @param bounce_location_long,bounce_location_lat Bounce depth and width
#'   zones as persisted by [sv_parse_shots()].
#' @param hit_court_side,bounce_court_side `"near"` / `"far"`, or `NA`.
#' @return An ordered factor the same length as the longest input, levels
#'   `"net_fault"`, `"out_both_axes"`, `"out_one_axis"`, `"in_bounds"`.
#' @export
stroke_outcome_severity <- function(net_contact = NA, bounce_location_long,
                                    bounce_location_lat,
                                    hit_court_side = NA_character_,
                                    bounce_court_side = NA_character_) {
  lv <- c("net_fault", "out_both_axes", "out_one_axis", "in_bounds")
  n <- max(
    length(net_contact), length(bounce_location_long), length(bounce_location_lat),
    length(hit_court_side), length(bounce_court_side)
  )
  nc <- rep_len(as.logical(net_contact), n)
  bl <- rep_len(as.character(bounce_location_long), n)
  bla <- rep_len(as.character(bounce_location_lat), n)
  hs <- rep_len(as.character(hit_court_side), n)
  bs <- rep_len(as.character(bounce_court_side), n)

  touched <- !is.na(nc) & nc
  sides_known <- !is.na(hs) & !is.na(bs)
  net_fault <- touched & sides_known & hs == bs
  net_unknown <- touched & !sides_known
  depth_out <- !is.na(bl) & bl == "out"
  width_out <- !is.na(bla) & bla %in% c("ad_out", "deuce_out")
  zone_unknown <- is.na(bl) & is.na(bla)

  out <- dplyr::case_when(
    net_fault ~ "net_fault",
    net_unknown ~ NA_character_,
    depth_out & width_out ~ "out_both_axes",
    depth_out | width_out ~ "out_one_axis",
    zone_unknown ~ NA_character_,
    TRUE ~ "in_bounds"
  )
  factor(out, levels = lv, ordered = TRUE)
}

#' Where each rally ends: a fault or a pause
#'
#' A rally ends in one of two ways, which the package already knew
#' separately: a stroke that is a fault ([stroke_outcome_severity()] is
#' anything below `"in_bounds"`), or an inter-stroke gap over the drill's pause
#' threshold ([rally_split_gap_sec()], with the same "the stroke after the
#' pause must be the starter's" condition as [rally_pause_splits()] when
#' `split_requires_starter_next` is `TRUE`). This function combines them into
#' one rule on a per-stroke table.
#'
#' For each stroke, in order of precedence: `"fault"` if the stroke itself is
#' a fault; `"pause"` if the gap to the next stroke in the match is a
#' boundary; `"end_of_data"` for the last stroke of a match (no later stroke
#' to compare with, so how that rally ended is unknown); otherwise `NA`.
#' Net faults depend on a net-contact call that is not yet reliable
#' (rallyr#26): if `shot_detail` has no `net_contact` column none are
#' produced, and a fault here means out of play only.
#'
#' Strokes are ordered by `match_id` then `started_at`; the result is in that
#' order. Rally ids are not used, so the rule can be compared with the
#' vendor's own grouping.
#'
#' @param shot_detail A tibble with `match_id`, `started_at`, `player` and
#'   `regime`, and optionally `bounce_location_long`, `bounce_location_lat`,
#'   `net_contact`, `hit_court_side`, `bounce_court_side`.
#' @param params A `dq_params()`-shaped list.
#' @param rally_starter Which `player` value starts rallies (`"host"`).
#' @return `shot_detail` ordered, with `outcome_severity` (see
#'   [stroke_outcome_severity()]), `ends_rally` (logical, never `NA`) and
#'   `end_reason` (`"fault"`, `"pause"`, `"end_of_data"` or `NA`).
#' @export
rally_end_rule <- function(shot_detail, params = dq_params(), rally_starter = "host") {
  need <- c("match_id", "started_at", "player", "regime")
  if (!all(need %in% names(shot_detail))) {
    cli::cli_abort("{.arg shot_detail} needs {.val {need}}.")
  }
  col <- function(nm, type) {
    if (nm %in% names(shot_detail)) shot_detail[[nm]] else rep(type, nrow(shot_detail))
  }
  d <- shot_detail
  d$outcome_severity <- stroke_outcome_severity(
    col("net_contact", NA), col("bounce_location_long", NA_character_),
    col("bounce_location_lat", NA_character_), col("hit_court_side", NA_character_),
    col("bounce_court_side", NA_character_)
  )
  d <- d[order(d$match_id, d$started_at), ]
  next_t <- dplyr::lead(d$started_at)
  next_p <- dplyr::lead(d$player)
  same_match <- !is.na(dplyr::lead(d$match_id)) & dplyr::lead(d$match_id) == d$match_id
  last_in_match <- !same_match
  gap <- ifelse(same_match, as.numeric(difftime(next_t, d$started_at, units = "secs")), NA_real_)
  thr <- rally_split_gap_sec(d$regime, params)
  starter_ok <- if (isTRUE(params$split_requires_starter_next)) next_p %in% rally_starter else TRUE
  pause <- !is.na(gap) & !is.na(thr) & gap > thr & starter_ok
  fault <- !is.na(d$outcome_severity) & d$outcome_severity < "in_bounds"

  d$end_reason <- dplyr::case_when(
    fault ~ "fault",
    pause ~ "pause",
    last_in_match ~ "end_of_data",
    TRUE ~ NA_character_
  )
  d$ends_rally <- !is.na(d$end_reason)
  d
}
