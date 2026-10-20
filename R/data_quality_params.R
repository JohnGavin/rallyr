#' Data-quality thresholds — single source of truth
#'
#' Centralises every magic-number threshold used to flag implausible rows
#' (a mean rally stroke speed that's too fast to be real, a rally with too
#' many strokes to plausibly be one continuous point) so they live in one
#' place instead of scattered across chart-generation code, and so they can
#' be recalibrated deliberately as more sessions accumulate.
#'
#' **Stroke limits are per drill and count one player's strokes.**
#' `max_rally_strokes` is a *named list* keyed by regime; the limit applies
#' to the strokes of the player whose practice is being analysed (the "me"
#' side, see [rally_player_strokes()]), not to both players together.
#' `mini_tennis` is a deliberately slow, cooperative warm-up where a long
#' continuous rally is plausible, so it gets the highest limit (50). The
#' single-wing cross-court drills (`forehand_cross_court`,
#' `backhand_cross_court`) get the lowest (20). Every other regime
#' (`net_volley`, and anything not listed) uses `default` (25). Looked up via
#' [rally_stroke_threshold()].
#'
#' These are FLAGS, not corrections -- a flagged row is surfaced for review,
#' never silently dropped, altered, or excluded from the underlying database
#' tables. Only chart-level *display* filtering (with an explicit note of how
#' many rows were excluded and why, see [dq_excluded_count()]) may skip a
#' flagged row.
#'
#' **The stroke limit only flags; it never splits.** The pause rule runs on
#' every rally of a pause-split regime, whether or not the rally is over its
#' limit; a rally or sub-rally still over its limit afterwards is flagged and
#' left out of [dq_corrected_rallies()], never force-split.
#'
#' `max_stroke_gap_sec` is the pause, in seconds, that [find_rally_splits()]
#' treats as a rally boundary. It is a *named list*, one entry per regime in
#' `pause_split_regimes` (cross-court drills 3 s, net-volley 2 s; mini-tennis
#' is never pause-split), looked up via [rally_split_gap_sec()]. A gap must be
#' strictly greater than the threshold to split. There is no `default`.
#'
#' `split_requires_starter_next` (logical): a pause only counts as a rally
#' boundary when the stroke after it is the rally starter's (the feeder, the
#' `"host"` side by default; see the `rally_starter` argument of
#' [dq_corrected_rallies()]), because the feeder starts every rally; a long
#' gap before the other player's stroke is a missed stroke, not a new rally.
#' Set `FALSE` to let the pause alone decide.
#'
#' **A threshold above the observed maximum is not a threshold.** If it sits
#' above every within-rally gap actually seen, the pause rule can never fire
#' and the check cannot vary with its input. Each pause threshold must lie
#' inside the observed gap distribution ([dq_stroke_gaps()]); re-derive it
#' from that distribution when sessions accumulate, and do not raise it just
#' to silence splits.
#'
#' `max_individual_stroke_speed_kmh` (160) flags a rally holding a single
#' implausibly fast stroke that the mean-speed check
#' (`max_mean_stroke_speed_kmh`) dilutes away: one 190 km/h stroke among
#' four 50 km/h strokes averages 78 km/h and passes the mean check. It sits
#' above any plausible recreational stroke and well below tracking
#' artefacts; recalibrate it from the per-rally maximum speed distribution
#' as sessions accumulate.
#'
#' `min_segment_duration_min` (3) is the shortest same-regime run of bins
#' [segment_session_shots()] accepts as a real drill instance; a shorter run
#' is a mis-segmentation artefact and is relabelled `"gap"`. It is distinct
#' from the per-bin `min_shots_per_bin`, which filters single one-minute bins
#' before they are merged.
#'
#' `sentinel_shot_speeds_mph` lists vendor speed readings that are a fixed
#' fallback value, not a measurement: the same exact value repeated across
#' unrelated shots, with a large gap to the next genuine reading. They are
#' nulled (the row stays, see [dq_clean_shot_speed()]). Add a value only
#' after checking for that signature -- an exact repeat plus a sharp gap.
#'
#' `min_net_clearance_m` (-1) and `max_net_clearance_m` (5) bound the plausible
#' net-clearance height in metres ([dq_clean_net_clearance()]). A value
#' outside the range is set to `NA` and flagged, the stroke stays. The bounds
#' are deliberately loose and provisional: the vendor does not state whether
#' the height is above the ground or above the net tape, so they only catch
#' values that cannot be a height at all. Recalibrate them from the observed
#' distribution, not to hide values.
#'
#' @return A named list: `max_mean_stroke_speed_kmh` (numeric),
#'   `max_individual_stroke_speed_kmh` (numeric),
#'   `min_segment_duration_min` (numeric),
#'   `sentinel_shot_speeds_mph` (numeric -- known placeholder speeds),
#'   `max_rally_strokes` (a named list with `default`, `mini_tennis`,
#'   `forehand_cross_court` and `backhand_cross_court`; the "me" side's
#'   strokes), `max_stroke_gap_sec` (a named list with `forehand_cross_court`,
#'   `backhand_cross_court` and `net_volley`, in seconds; look up via
#'   [rally_split_gap_sec()]), `pause_split_regimes` (character -- the
#'   regimes the pause rule splits), and `split_requires_starter_next`
#'   (logical -- a pause only splits a rally when the stroke after it is the
#'   rally starter's), and `min_net_clearance_m` / `max_net_clearance_m`
#'   (numeric -- the plausible net-clearance range in metres).
#' @export
dq_params <- function() {
  list(
    max_mean_stroke_speed_kmh = 100,
    max_individual_stroke_speed_kmh = 160,
    min_segment_duration_min = 3,
    sentinel_shot_speeds_mph = 117.1,
    max_rally_strokes = list(
      default = 25, mini_tennis = 50,
      forehand_cross_court = 20, backhand_cross_court = 20
    ),
    max_stroke_gap_sec = list(
      forehand_cross_court = 3, backhand_cross_court = 3,
      net_volley = 2
    ),
    pause_split_regimes = c("forehand_cross_court", "backhand_cross_court", "net_volley"),
    split_requires_starter_next = TRUE,
    min_net_clearance_m = -1,
    max_net_clearance_m = 5
  )
}

#' Null a sentinel (fallback) sensor value without dropping the row
#'
#' Some vendor readings are a fixed placeholder substituted when no real
#' measurement was made. Only the affected field is set to `NA` for the
#' affected rows; the row itself is kept (the event happened, only one
#' measurement of it is untrustworthy) and a logical flag column records which
#' rows were touched, for audit. Detect candidates first: an exact value
#' repeated across otherwise-independent rows, with a sharp gap to the next
#' genuine value. Not every numeric field has this problem.
#'
#' @param df A data frame.
#' @param field Name of the numeric column to clean.
#' @param values Known sentinel values (may be empty).
#' @param tol A value within `tol` of a sentinel counts as that sentinel.
#' @param flag_col Name of the new logical column; defaults to
#'   `paste0(field, "_sentinel")`.
#' @return `df` with `field` nulled where it matched, and `flag_col` (`TRUE`
#'   where nulled, never `NA`).
#' @export
dq_null_sentinel <- function(df, field, values, tol = 0.05, flag_col = paste0(field, "_sentinel")) {
  if (!field %in% names(df)) {
    cli::cli_abort(c(
      "x" = "Column {.field {field}} not found in {.arg df}.",
      "i" = "Available: {.val {names(df)}}."
    ))
  }
  x <- df[[field]]
  hit <- rep(FALSE, length(x))
  for (v in values) {
    hit <- hit | (!is.na(x) & abs(x - v) <= tol)
  }
  x[hit] <- NA
  df[[field]] <- x
  df[[flag_col]] <- hit
  df
}

#' Null the sentinel shot speeds listed in [dq_params()]
#'
#' A thin wrapper over [dq_null_sentinel()] for `shot_speed_mph`, using
#' `params$sentinel_shot_speeds_mph`. Adds a `shot_speed_sentinel` flag column.
#' [dq_corrected_rallies()] applies it, so a placeholder speed never enters a
#' rally's mean or maximum while its stroke still counts.
#'
#' @param shot_detail A tibble with `shot_speed_mph`.
#' @param params A `dq_params()`-shaped list.
#' @return `shot_detail` with sentinel speeds set to `NA` and the flag column.
#' @export
dq_clean_shot_speed <- function(shot_detail, params = dq_params()) {
  dq_null_sentinel(
    shot_detail, "shot_speed_mph", params$sentinel_shot_speeds_mph,
    flag_col = "shot_speed_sentinel"
  )
}

#' Look up the max-rally-stroke threshold for a regime
#'
#' The single place the regime -> stroke-limit mapping of [dq_params()]'s
#' `max_rally_strokes` is implemented.
#'
#' @param regime Character vector of regime values (e.g. `rallies$regime`).
#' @param params A `dq_params()`-shaped list.
#' @return A numeric vector, same length as `regime`: the regime's own
#'   threshold if `max_rally_strokes` names it, else `default`.
#' @export
rally_stroke_threshold <- function(regime, params = dq_params()) {
  vals <- unlist(params$max_rally_strokes)
  out <- unname(vals[as.character(regime)])
  out[is.na(out)] <- params$max_rally_strokes$default
  out
}

#' Look up the rally-split pause threshold for a regime
#'
#' The pause (seconds) above which a pause before a rally-starter stroke
#' splits a rally. Only the regimes in `params$pause_split_regimes` have one;
#' any other regime is never pause-split and gets `NA`.
#'
#' @param regime Character vector of regime values (e.g. `rallies$regime`).
#' @param params A `dq_params()`-shaped list.
#' @return A numeric vector, same length as `regime`; `NA` for a regime that
#'   is not pause-split.
#' @export
rally_split_gap_sec <- function(regime, params = dq_params()) {
  regime <- as.character(regime)
  vals <- unlist(params$max_stroke_gap_sec)
  out <- unname(vals[regime])
  out[!regime %in% params$pause_split_regimes] <- NA_real_
  out
}

#' Count one player's strokes in each rally
#'
#' A rally's `n_shots` counts both players' strokes; the stroke limits count
#' the "me" side's only. A stroke belongs to a rally when it is in the same
#' match and carries that rally's `rally_id` (the same rule the split code
#' uses); a stroke with an `NA` `rally_id` belongs to no rally. Only when
#' `shot_detail` has no `rally_id` column at all does it fall back to
#' counting strokes whose `started_at` falls between the rally's `start_time`
#' and `end_time` (inclusive).
#'
#' @param rallies Rally tibble with `match_id`, `rally_id`, `start_time`,
#'   `end_time`.
#' @param shot_detail Per-stroke tibble with `match_id`, `player`,
#'   `started_at`, and normally `rally_id`.
#' @param me_side Which `player` value counts as "me" (`"guest"` by default).
#' @param col Name of the new column (`"me_shots"` by default).
#' @return `rallies` with a new integer column `col` (0 when the player hit
#'   nothing in that rally).
#' @export
rally_player_strokes <- function(rallies, shot_detail, me_side = "guest", col = "me_shots") {
  need_r <- c("match_id", "rally_id", "start_time", "end_time")
  need_s <- c("match_id", "player", "started_at")
  if (!all(need_r %in% names(rallies))) {
    cli::cli_abort("{.arg rallies} needs {.val {need_r}}.")
  }
  if (!all(need_s %in% names(shot_detail))) {
    cli::cli_abort("{.arg shot_detail} needs {.val {need_s}}.")
  }
  rallies[[col]] <- NULL
  mine <- shot_detail[shot_detail$player %in% me_side, ]
  if ("rally_id" %in% names(shot_detail)) {
    # Count by rally_id, as the split code does; strokes with an NA rally_id
    # belong to no rally.
    counts <- mine[!is.na(mine$rally_id), c("match_id", "rally_id")] |>
      dplyr::mutate(rally_id = as.character(.data$rally_id)) |>
      dplyr::count(.data$match_id, .data$rally_id, name = col)
    rallies$.rid_chr <- as.character(rallies$rally_id)
    out <- dplyr::left_join(
      rallies, dplyr::rename(counts, .rid_chr = "rally_id"),
      by = c("match_id", ".rid_chr")
    )
    out$.rid_chr <- NULL
  } else {
    # Fallback only when strokes carry no rally_id: count by time window.
    keys <- rallies[, need_r]
    counts <- dplyr::inner_join(
      keys, mine[, c("match_id", "started_at")],
      by = dplyr::join_by(match_id, dplyr::between(y$started_at, x$start_time, x$end_time))
    ) |>
      dplyr::count(.data$match_id, .data$rally_id, name = col)
    out <- dplyr::left_join(rallies, counts, by = c("match_id", "rally_id"))
  }
  out[[col]] <- as.integer(dplyr::coalesce(out[[col]], 0L))
  out
}

#' Flag rallies whose stroke count, mean speed, or single fastest stroke
#' exceeds threshold
#'
#' The third check catches a single implausible stroke hidden inside an
#' otherwise plausible rally, which the mean-speed check alone dilutes away
#' (see [dq_params()]'s `max_individual_stroke_speed_kmh`). `max_speed_kmh`
#' is an OPTIONAL column of `rally_speed_kmh`: without it the check never
#' fires, so callers that do not supply it behave as before.
#'
#' @param rallies A tibble with (at least) `match_id`, `rally_id`, `regime`,
#'   `me_shots` (see [rally_player_strokes()]; the stroke limits count the
#'   "me" side's strokes only).
#' @param rally_speed_kmh A tibble with (at least) `match_id`, `rally_id`,
#'   `speed_kmh` (mean stroke speed for that rally), and OPTIONALLY
#'   `max_speed_kmh` (that rally's single fastest stroke) — see
#'   `scripts/make_artifact_charts.R`'s `rally_speed_per_rally`.
#' @return `rallies` with a new `flag_reason` character column (`NA` when
#'   not flagged; one row can carry only one reason, checked in this order:
#'   stroke count, mean speed, individual stroke speed).
#' @export
dq_flag_rallies <- function(rallies, rally_speed_kmh) {
  if (!"me_shots" %in% names(rallies)) {
    cli::cli_abort("{.arg rallies} needs a {.field me_shots} column (see {.fn rally_player_strokes}).")
  }
  p <- dq_params()
  max_strokes <- rally_stroke_threshold(rallies$regime, p)
  rallies <- dplyr::left_join(rallies, rally_speed_kmh, by = c("match_id", "rally_id"))
  max_speed_flag <- if ("max_speed_kmh" %in% names(rallies)) {
    !is.na(rallies$max_speed_kmh) & rallies$max_speed_kmh > p$max_individual_stroke_speed_kmh
  } else {
    FALSE
  }
  rallies$flag_reason <- dplyr::case_when(
    rallies$me_shots > max_strokes ~ sprintf("rally > %d strokes (drill limit)", as.integer(max_strokes)),
    !is.na(rallies$speed_kmh) & rallies$speed_kmh > p$max_mean_stroke_speed_kmh ~
      sprintf("mean stroke speed > %d km/h", p$max_mean_stroke_speed_kmh),
    max_speed_flag ~
      sprintf("individual stroke speed > %d km/h", as.integer(p$max_individual_stroke_speed_kmh)),
    TRUE ~ NA_character_
  )
  rallies
}

#' Count the rallies a data-quality flag touched
#'
#' The "N of M rallies excluded" figure shown next to a chart. It counts the
#' raw rallies that were flagged (`sum(!is.na(flag_reason))`), NOT a
#' row-count difference such as `n_flagged - nrow(corrected)`: a flagged
#' rally that [dq_corrected_rallies()] splits into two surviving sub-rallies
#' increases the corrected row count, so that difference can go negative
#' ("-5 of 937 rallies excluded"). Compute the flagged set once with
#' [dq_flag_rallies()] and reuse this count for every chart and audit table.
#' "Excluded" means flagged, i.e. a rally the data-quality checks object to;
#' it does not mean the rally is absent from [dq_corrected_rallies()], since a
#' flagged rally can still contribute surviving sub-rallies after a split.
#'
#' @param rallies_flagged Output of [dq_flag_rallies()] (needs a
#'   `flag_reason` column).
#' @return A single non-negative integer.
#' @export
dq_excluded_count <- function(rallies_flagged) {
  if (!"flag_reason" %in% names(rallies_flagged)) {
    cli::cli_abort(c(
      "x" = "{.arg rallies_flagged} needs a {.field flag_reason} column.",
      "i" = "Build it with {.fn dq_flag_rallies}."
    ))
  }
  sum(!is.na(rallies_flagged$flag_reason))
}

#' Inter-stroke gap times within every rally
#'
#' The full distribution `dq_params()`'s `max_stroke_gap_sec` threshold was
#' calibrated against — one row per consecutive within-rally pause, so a
#' rally of `n` strokes contributes `n - 1` rows. Used both to justify the
#' threshold (see `dq_params()`'s docs) and to draw the calibration chart on
#' the artifact's Exceptions page.
#'
#' @param shot_detail A tibble with (at least) `match_id`, `rally_id`,
#'   `started_at` — see `tennis_shot_detail()` in `R/db.R`.
#' @return A tibble: `match_id`, `rally_id`, `gap_sec`.
#' @export
dq_stroke_gaps <- function(shot_detail) {
  d <- shot_detail |>
    dplyr::filter(!is.na(rally_id)) |>
    dplyr::arrange(match_id, rally_id, started_at) |>
    dplyr::group_by(match_id, rally_id) |>
    dplyr::mutate(gap_sec = as.numeric(difftime(started_at, dplyr::lag(started_at), units = "secs"))) |>
    dplyr::ungroup() |>
    dplyr::filter(!is.na(gap_sec))
  dplyr::select(d, match_id, rally_id, gap_sec)
}

#' Pause-rule split points for one rally
#'
#' The single place the rally-boundary rule is applied, shared by
#' [split_flagged_rallies()] and [dq_corrected_rallies()] so the two cannot
#' disagree. A boundary after stroke `i` needs BOTH a pause strictly over
#' [rally_split_gap_sec()] AND -- when `params$split_requires_starter_next`
#' is `TRUE` -- stroke `i + 1` to belong to the rally starter. Only the
#' regimes in `params$pause_split_regimes` are split. The stroke limit plays
#' no part: it only flags.
#'
#' @param shots One rally's strokes, ordered by `started_at`, with `player`.
#' @param regime The rally's regime (a single string).
#' @param params A `dq_params()`-shaped list.
#' @param rally_starter Which `player` value starts rallies (`"host"`).
#' @return An integer vector of split indices as in [find_rally_splits()].
#' @keywords internal
rally_pause_splits <- function(shots, regime, params = dq_params(), rally_starter = "host") {
  if (nrow(shots) < 2L || !regime %in% params$pause_split_regimes) {
    return(integer(0))
  }
  is_starter <- if (isTRUE(params$split_requires_starter_next)) shots$player %in% rally_starter else NULL
  find_rally_splits(
    shots$started_at,
    max_gap_sec = rally_split_gap_sec(regime, params),
    is_starter = is_starter
  )
}

# Sub-rally suffix: a..z, then z27, z28, ... (never NA, so ids stay unique).
rally_piece_suffix <- function(k) ifelse(k <= 26L, letters[pmin(k, 26L)], sprintf("z%d", k))

#' Propose the pause-rule split of every rally, for human review
#'
#' Runs the pause rule ([rally_pause_splits()]) on EVERY rally of a
#' pause-split regime -- not only the ones over their stroke limit -- because
#' the vendor's own grouping (`pid`) can merge real rallies well under the
#' limit. Other regimes are never split; rallies flagged only for speed are
#' skipped (dropped, not a grouping problem).
#'
#' Output covers every rally the rule splits (one row per sub-rally), plus
#' every rally still over its stroke limit that has NO qualifying pause (one
#' unsplit row, `still_flagged` `TRUE`). **The stroke limit only flags:
#' nothing is force-split.** Unsplit rallies within their limit are omitted.
#'
#' A **proposal** for human review: nothing is written back to the database.
#'
#' @param rallies_flagged Output of [dq_flag_rallies()] -- must include
#'   `match_id`, `rally_id`, `regime`, `flag_reason`.
#' @param shot_detail A tibble with (at least) `match_id`, `rally_id`,
#'   `player`, `started_at` -- see `tennis_shot_detail()` in `R/db.R`.
#' @param params A `dq_params()`-shaped list; pass a custom one to explore a
#'   different threshold.
#' @param me_side Which `player` value counts as "me" (`"guest"`).
#' @param rally_starter Which `player` value starts rallies (`"host"`).
#' @return A tibble, one row per sub-rally: `match_id` (rally IDs are only
#'   unique WITHIN a match), `orig_rally_id`, `orig_n_shots`, `new_rally_id`,
#'   `new_n_shots` (the "me" side's strokes, as for every limit), `split`
#'   (logical), `split_method` (`"none"` / `"gap_threshold"`),
#'   `still_flagged` (logical -- does the sub-rally still exceed its own
#'   regime's stroke threshold).
#' @keywords internal
split_flagged_rallies <- function(rallies_flagged, shot_detail, params = dq_params(),
                                  me_side = "guest", rally_starter = "host") {
  candidates <- rallies_flagged |>
    dplyr::filter(is.na(flag_reason) | grepl("strokes", flag_reason))

  rows <- Map(
    function(mid, rid, regime) {
      shots <- shot_detail |>
        dplyr::filter(match_id == mid, rally_id == rid) |>
        dplyr::arrange(started_at)
      max_strokes <- rally_stroke_threshold(regime, params)
      is_me <- as.numeric(shots$player %in% me_side)
      orig_n <- sum(is_me)

      splits <- rally_pause_splits(shots, regime, params, rally_starter)

      if (length(splits) == 0L) {
        if (orig_n <= max_strokes) {
          return(NULL)   # nothing to review
        }
        return(tibble::tibble(
          match_id = mid, orig_rally_id = as.character(rid), orig_n_shots = orig_n,
          new_rally_id = as.character(rid), new_n_shots = orig_n,
          split = FALSE, split_method = "none", still_flagged = TRUE
        ))
      }
      bounds <- c(0L, splits, nrow(shots))
      sizes  <- diff(c(0, cumsum(is_me))[bounds + 1L])
      tibble::tibble(
        match_id = mid, orig_rally_id = as.character(rid), orig_n_shots = orig_n,
        new_rally_id  = sprintf("%s_%s", rid, rally_piece_suffix(seq_along(sizes))),
        new_n_shots   = sizes, split = TRUE, split_method = "gap_threshold",
        still_flagged = sizes > max_strokes
      )
    },
    candidates$match_id, candidates$rally_id, candidates$regime
  )

  dplyr::bind_rows(rows)
}

#' The rallies actually usable for plotting — data-quality corrected
#'
#' Single source of truth for "which rallies may feed a chart": every
#' rally-derived chart reads from this function's output instead of the raw
#' `rallies` table, so an implausible outlier is fixed or dropped BEFORE it
#' reaches a chart, not just flagged for a human to notice afterwards.
#' [split_flagged_rallies()]'s proposal table is unaffected by this function
#' and continues to show the "before" picture.
#'
#' For every rally, in order:
#'
#' 0. Sentinel (placeholder) shot speeds are set to `NA`
#'    ([dq_clean_shot_speed()]); the stroke itself stays.
#' 1. The "me" side's strokes are counted per rally (`me_shots`, see
#'    [rally_player_strokes()]) and the per-rally mean stroke speed
#'    (`speed_kmh`) is computed from those strokes only, in km/h.
#' 2. Rallies are flagged via [dq_flag_rallies()].
#' 3. A rally flagged **only** for an implausible mean speed is a
#'    corrupted-tracking problem, not a grouping problem -- it is dropped
#'    outright. The same holds for a rally holding a single implausibly fast
#'    stroke (`max_individual_stroke_speed_kmh`).
#' 4. **The pause rule runs on every other rally of a pause-split regime
#'    (cross-court and net-volley), flagged or not**: a pause strictly over
#'    [rally_split_gap_sec()] before a rally-starter stroke is a boundary
#'    ([rally_pause_splits()]). Each shot is assigned to a new sub-rally and
#'    `n_shots`, `me_shots`, `start_time`/`end_time`, `duration_sec` and
#'    `speed_kmh` are recomputed from that subset. Sub-rally ids are
#'    `"<orig>_<letter>"`; `rally_id` is always returned as **character**.
#' 5. The stroke limit only FLAGS. There is no forced split: a rally, or a
#'    sub-rally, still over its regime's limit (including a rally with no
#'    qualifying pause) is left out and stays flagged. A valid sibling
#'    sub-rally is kept. Because a stroke-count flag hides any speed reason,
#'    each sub-rally is also re-checked against the mean-speed and
#'    individual-stroke-speed limits and dropped if it fails either.
#' 6. Every unflagged rally with no qualifying pause passes through
#'    unchanged, with `speed_kmh` attached.
#'
#' @param rallies A tibble from [tennis_rallies()] (or equivalently shaped)
#'   — `match_id`, `rally_id`, `regime`, `regime_occurrence`,
#'   `segment_index`, `n_shots`, `duration_sec`, `start_time`, `end_time`.
#' @param shot_detail A tibble from [tennis_shot_detail()] — `match_id`,
#'   `rally_id`, `player`, `started_at`, `shot_speed_mph`.
#' @param params A `dq_params()`-shaped list; pass a custom one to explore a
#'   different threshold.
#' @param me_side Which `player` value counts as "me" (`"guest"`).
#' @param rally_starter Which `player` value starts rallies (`"host"`, the
#'   feeder).
#' @return A tibble shaped like `rallies` (`rally_id` — character) plus
#'   `speed_kmh` and `me_shots`. A rally present in `rallies` can be ABSENT
#'   here -- dropped, never silently merged into another rally's row -- when
#'   it (or a sub-rally) is still implausible after the pause split. No row
#'   exceeds its own regime's `max_rally_strokes` threshold.
#' @export
dq_corrected_rallies <- function(rallies, shot_detail, params = dq_params(),
                                 me_side = "guest", rally_starter = "host") {
  # Placeholder speeds are nulled first (the stroke still counts).
  shot_detail <- dq_clean_shot_speed(shot_detail, params)
  rallies <- rally_player_strokes(rallies, shot_detail, me_side)
  rally_speed <- shot_detail |>
    dplyr::filter(player %in% me_side, !is.na(rally_id)) |>
    dplyr::group_by(match_id, rally_id) |>
    dplyr::summarise(
      speed_kmh = mean(shot_speed_mph, na.rm = TRUE) * 1.609344,
      max_speed_kmh = if (all(is.na(shot_speed_mph))) NA_real_ else max(shot_speed_mph, na.rm = TRUE) * 1.609344,
      .groups = "drop"
    )

  rallies_flagged <- dq_flag_rallies(rallies, rally_speed)

  # A speed-only flag is a corrupted-tracking problem, not a grouping
  # problem: dropped outright, never split. Everything else -- unflagged or
  # stroke-count-flagged -- gets the pause rule.
  candidates <- rallies_flagged |>
    dplyr::filter(is.na(flag_reason) | grepl("strokes", flag_reason))

  split_pieces <- Map(
    function(mid, rid, regime, regime_occurrence, segment_index) {
      shots <- shot_detail |>
        dplyr::filter(match_id == mid, rally_id == rid) |>
        dplyr::arrange(started_at)

      splits <- rally_pause_splits(shots, regime, params, rally_starter)
      if (length(splits) == 0L) {
        return(NULL)
      }

      bounds <- c(0L, splits, nrow(shots))
      sub_rows <- lapply(seq_len(length(bounds) - 1L), function(k) {
        sub_shots <- shots[(bounds[k] + 1L):bounds[k + 1L], ]
        sub_me    <- sub_shots[sub_shots$player %in% me_side, ]
        tibble::tibble(
          match_id          = mid,
          rally_id          = sprintf("%s_%s", rid, rally_piece_suffix(k)),
          regime            = regime,
          regime_occurrence = regime_occurrence,
          segment_index     = segment_index,
          n_shots           = nrow(sub_shots),
          me_shots          = nrow(sub_me),
          duration_sec      = as.numeric(difftime(max(sub_shots$started_at), min(sub_shots$started_at), units = "secs")),
          start_time        = min(sub_shots$started_at),
          end_time          = max(sub_shots$started_at),
          speed_kmh         = if (nrow(sub_me) > 0L) mean(sub_me$shot_speed_mph, na.rm = TRUE) * 1.609344 else NA_real_,
          max_speed_kmh     = if (nrow(sub_me) > 0L && !all(is.na(sub_me$shot_speed_mph))) max(sub_me$shot_speed_mph, na.rm = TRUE) * 1.609344 else NA_real_
        )
      })
      dplyr::bind_rows(sub_rows)
    },
    candidates$match_id, candidates$rally_id, candidates$regime,
    candidates$regime_occurrence, candidates$segment_index
  )
  was_split    <- !vapply(split_pieces, is.null, logical(1))
  split_result <- dplyr::bind_rows(split_pieces)

  if (nrow(split_result) > 0L) {
    max_strokes_vec <- rally_stroke_threshold(split_result$regime, params)
    # A sub-rally still over its own regime's limit stays flagged and is left
    # out -- per-row, so a valid sibling is kept.
    # The same goes for the speed checks: a rally flagged for its stroke count
    # carries only that reason, so a speed artefact is re-checked per piece.
    ok_mean <- is.na(split_result$speed_kmh) | split_result$speed_kmh <= params$max_mean_stroke_speed_kmh
    ok_max  <- is.na(split_result$max_speed_kmh) | split_result$max_speed_kmh <= params$max_individual_stroke_speed_kmh
    split_result <- split_result[split_result$me_shots <= max_strokes_vec & ok_mean & ok_max, ]
    split_result$max_speed_kmh <- NULL
  } else if ("max_speed_kmh" %in% names(split_result)) {
    split_result$max_speed_kmh <- NULL
  }

  # Unflagged and no qualifying pause: passes through unchanged. Flagged and
  # no qualifying pause: not split, left out (still flagged).
  unsplit_ok <- candidates[!was_split & is.na(candidates$flag_reason), ] |>
    dplyr::mutate(rally_id = as.character(rally_id)) |>
    dplyr::select(
      match_id, rally_id, regime, regime_occurrence, segment_index,
      n_shots, me_shots, duration_sec, start_time, end_time, speed_kmh
    )

  dplyr::bind_rows(unsplit_ok, split_result)
}
