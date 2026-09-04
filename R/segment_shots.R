#' Segment a session's per-shot data into structural drill phases
#'
#' Detects drill phases from three independent per-shot signals -- host's
#' volley share (net-volley phases), guest ground-stroke speed (a slower
#' warm-up phase), and guest's hit_wing dominance (forehand vs backhand
#' cross-court). Every threshold is a function argument, so this is a
#' generic bin classifier -- but its *defaults* were calibrated against one
#' specific drill routine (mini-tennis warmup, opponent-at-net volleying,
#' forehand cross-court, backhand cross-court, opponent-at-net volleying
#' again), verified against one real session (mini-tennis ground-strokes
#' averaged ~12 m/s vs ~20-23 m/s everywhere else; the two volley phases had
#' host volley shares of 60-85% vs 0% elsewhere; the two cross-court phases
#' showed >85% wing dominance in opposite directions). Treat the default
#' thresholds as a worked example, not a universal calibration -- recompute
#' them for a drill routine that looks different from this one.
#'
#' @param shots A tibble from [sv_parse_shots()] (one match's shots).
#' @param guest_right_handed Is the "guest" player ("me") right-handed?
#'   Determines which wing maps to forehand vs backhand. Default `TRUE` --
#'   the only case seen in this project's data so far.
#' @param bin_minutes Width of the time bin used for regime detection.
#'   Default `1`.
#' @param min_shots_per_bin Minimum total shots in a bin to classify it;
#'   bins below this are `"gap"` (a real break in play, not forced into a
#'   guess). Default `4`.
#' @param volley_share_threshold Host volley-share at/above which a bin is
#'   `"net_volley"`. Default `0.4`.
#' @param mini_tennis_speed_mph Guest ground-stroke mean speed below which
#'   a (non-volley) bin is `"mini_tennis"`. Default `35`.
#' @param wing_dominance_threshold Guest ground-stroke right-wing share
#'   at/above (or at/below `1 - threshold`) which a bin is a cross-court
#'   phase. Default `0.7`.
#' @return A tibble, one row per detected segment (contiguous bins sharing a
#'   regime), ordered by `start_time`: `segment_index`, `regime`
#'   (`"mini_tennis"`/`"net_volley"`/`"forehand_cross_court"`/
#'   `"backhand_cross_court"`/`"mixed"`/`"gap"`), `start_time`, `end_time`,
#'   `duration_min`, `n_shots`, `n_host_shots`, `n_guest_shots`. `"gap"` rows
#'   are real breaks in play (a real segment boundary can fragment into
#'   segment/gap/segment) -- callers should treat `"gap"` as filler, not a
#'   drill phase.
#' @export
segment_session_shots <- function(shots,
                                   guest_right_handed = TRUE,
                                   bin_minutes = 1,
                                   min_shots_per_bin = 4,
                                   volley_share_threshold = 0.4,
                                   mini_tennis_speed_mph = 35,
                                   wing_dominance_threshold = 0.7) {
  bins <- shots |>
    dplyr::mutate(
      bin = floor(as.numeric(difftime(started_at, min(started_at), units = "mins")) / bin_minutes)
    ) |>
    dplyr::group_by(bin) |>
    dplyr::summarise(
      start_time = min(started_at),
      end_time   = max(ended_at),
      n_shots    = dplyr::n(),
      n_host     = sum(player == "host"),
      n_guest    = sum(player == "guest"),
      host_volley_frac = if (n_host > 0) sum(player == "host" & hit_type == "volley") / n_host else NA_real_,
      guest_gs_n     = sum(player == "guest" & hit_type == "ground_stroke"),
      guest_gs_speed = if (guest_gs_n > 0) mean(shot_speed_mph[player == "guest" & hit_type == "ground_stroke"], na.rm = TRUE) else NA_real_,
      guest_right_frac = if (guest_gs_n > 0) sum(player == "guest" & hit_type == "ground_stroke" & hit_wing == "right") / guest_gs_n else NA_real_,
      .groups = "drop"
    ) |>
    dplyr::arrange(bin)

  fh_label <- if (guest_right_handed) "forehand_cross_court" else "backhand_cross_court"
  bh_label <- if (guest_right_handed) "backhand_cross_court" else "forehand_cross_court"

  bins <- bins |>
    dplyr::mutate(
      regime = dplyr::case_when(
        n_shots < min_shots_per_bin ~ "gap",
        !is.na(host_volley_frac) & host_volley_frac >= volley_share_threshold ~ "net_volley",
        !is.na(guest_gs_speed) & guest_gs_speed < mini_tennis_speed_mph ~ "mini_tennis",
        !is.na(guest_right_frac) & guest_right_frac >= wing_dominance_threshold ~ fh_label,
        !is.na(guest_right_frac) & guest_right_frac <= (1 - wing_dominance_threshold) ~ bh_label,
        TRUE ~ "mixed"
      )
    )

  run <- rle(bins$regime)
  bins$segment_index <- rep(seq_along(run$lengths), run$lengths)

  bins |>
    dplyr::group_by(segment_index, regime) |>
    dplyr::summarise(
      start_time    = min(start_time),
      end_time      = max(end_time),
      n_shots       = sum(n_shots),
      n_host_shots  = sum(n_host),
      n_guest_shots = sum(n_guest),
      .groups = "drop"
    ) |>
    dplyr::mutate(duration_min = round(as.numeric(difftime(end_time, start_time, units = "mins")), 1)) |>
    dplyr::relocate(segment_index, regime, start_time, end_time, duration_min,
                     n_shots, n_host_shots, n_guest_shots) |>
    dplyr::arrange(segment_index)
}
