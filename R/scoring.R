#' Landing-zone score for the cross-court drills
#'
#' Scores where a stroke landed in a cross-court drill, and what the other
#' player had to do with it. For the **forehand cross-court** drill the ideal
#' target is the deep box between the centre line and the singles sideline
#' (the `"deuce"` width), better still when it forces the feeder to answer
#' with a forehand. One tier down is the same width but shallower, still in
#' play. The **backhand cross-court** drill is the mirror image: the `"ad"`
#' width, deep, forcing a feeder backhand.
#'
#' The response signal is the feeder's *actual* next stroke (`next_hit_wing`),
#' a direct observation, rather than a court-geometry model of which wing they
#' would use. It is trusted only when the next stroke really is the feeder's;
#' when the rally ends on this stroke or the alternation breaks (the next
#' stroke is the "me" side again) the tiers that depend on it are `NA`, never
#' a guess. A stroke that lands off the target width, or out of play, needs no
#' response signal and is scored without one.
#'
#' **Provisional tie.** "Deep, non-desired response" and "shallow, desired
#' response" are both `"tier_2"`: the two were never ranked against each other.
#' Change the tie only with an explicit decision.
#'
#' Vectorised: all arguments are recycled to the longest, and the result has
#' that length. (A nested `ifelse()` whose test is a scalar would silently
#' truncate the result to length 1; `feeder_right_handed` is recycled first
#' for that reason, and the tests include a multi-row case.)
#'
#' @param regime Character, the drill (`shot_detail$regime`); only
#'   `"forehand_cross_court"` and `"backhand_cross_court"` are scored.
#' @param player Character, who hit the stroke (`shot_detail$player`); only
#'   `me_side` strokes are scored.
#' @param bounce_location_long,bounce_location_lat The stroke's own bounce
#'   zones (depth and width), as persisted by [sv_parse_shots()].
#' @param next_player,next_hit_wing The next stroke in the same rally
#'   (typically `dplyr::lead()` after grouping by rally and sorting by time).
#' @param feeder_right_handed Logical (scalar or per row): is the feeder
#'   right-handed? Decides whether `hit_wing == "right"` is a forehand.
#'   Not verified per session; the default is `TRUE`.
#' @param me_side,feeder_side The `player` values for the "me" side and the
#'   feeder (`"guest"` / `"host"`, as elsewhere in the package).
#' @param deep_zones Values of `bounce_location_long` that count as deep.
#' @param me_right_handed Logical scalar: is the "me" player right-handed? The
#'   target widths above (`"deuce"` for the forehand drill, `"ad"` for the
#'   backhand drill) are for a right-hander and are swapped when `FALSE`.
#'   Default `TRUE`; not verified per session.
#' @return An ordered factor the same length as the input, `NA` where the
#'   stroke is not a scoreable "me" cross-court stroke or the signal needed is
#'   missing. Levels, worst to best: `"out_of_play"`, `"off_target_width"`,
#'   `"tier_3"`, `"tier_2"`, `"tier_1"`. See [zone_score_numeric()] for a
#'   0-1 value.
#' @export
cross_court_zone_score <- function(regime, player, bounce_location_long,
                                   bounce_location_lat, next_player,
                                   next_hit_wing, feeder_right_handed = TRUE,
                                   me_side = "guest", feeder_side = "host",
                                   deep_zones = "no_mans_land",
                                   me_right_handed = TRUE) {
  lv <- c("out_of_play", "off_target_width", "tier_3", "tier_2", "tier_1")
  n <- max(
    length(regime), length(player), length(bounce_location_long),
    length(bounce_location_lat), length(next_player), length(next_hit_wing)
  )
  rc <- function(x) rep_len(as.character(x), n)
  rg <- rc(regime)
  ply <- rc(player)
  bl <- rc(bounce_location_long)
  bla <- rc(bounce_location_lat)
  np <- rc(next_player)
  nhw <- rc(next_hit_wing)
  rh <- rep_len(as.logical(feeder_right_handed), n)

  scoreable <- !is.na(rg) & rg %in% c("forehand_cross_court", "backhand_cross_court") &
    !is.na(ply) & ply %in% me_side
  fh_drill <- !is.na(rg) & rg == "forehand_cross_court"
  # Target width: deuce for a right-hander's forehand cross-court, mirrored
  # for a left-hander.
  fh_width <- if (isTRUE(me_right_handed)) "deuce" else "ad"
  bh_width <- if (isTRUE(me_right_handed)) "ad" else "deuce"
  target_width <- ifelse(fh_drill, fh_width, bh_width)

  known_zone <- !is.na(bl) & !is.na(bla)
  # Out on either axis alone is out of play, as in stroke_outcome_severity().
  out_of_play <- (!is.na(bl) & bl == "out") | (!is.na(bla) & bla %in% c("ad_out", "deuce_out"))
  in_target <- known_zone & !out_of_play & bla == target_width
  deep <- !is.na(bl) & bl %in% deep_zones

  feeder_fh_letter <- ifelse(rh, "right", "left")
  feeder_wing <- ifelse(is.na(nhw) | is.na(rh), NA_character_,
                        ifelse(nhw == feeder_fh_letter, "forehand", "backhand"))
  response_known <- !is.na(np) & np %in% feeder_side & !is.na(feeder_wing)
  wanted <- ifelse(fh_drill, "forehand", "backhand")
  desired <- response_known & feeder_wing == wanted

  out <- rep(NA_character_, n)
  out[scoreable & out_of_play] <- "out_of_play"
  out[scoreable & known_zone & !out_of_play & !in_target] <- "off_target_width"
  g <- scoreable & in_target & response_known
  out[g & !deep & !desired] <- "tier_3"
  out[g & (deep != desired)] <- "tier_2"
  out[g & deep & desired] <- "tier_1"
  factor(out, levels = lv, ordered = TRUE)
}

#' A 0-1 value for an ordered score factor
#'
#' Maps the levels of an ordered factor such as the result of
#' [cross_court_zone_score()] onto an even 0-1 scale (worst level 0, best
#' level 1), so a score can be averaged or standardised. `NA` stays `NA`.
#'
#' @param x An ordered factor.
#' @return A numeric vector the same length as `x`.
#' @export
zone_score_numeric <- function(x) {
  if (!is.ordered(x)) {
    cli::cli_abort("{.arg x} must be an ordered factor, not {.cls {class(x)}}.")
  }
  k <- nlevels(x)
  if (k < 2L) {
    return(ifelse(is.na(x), NA_real_, 0))
  }
  (as.integer(x) - 1L) / (k - 1L)
}
