#' Data-quality thresholds — single source of truth
#'
#' Centralises every magic-number threshold used to flag implausible rows
#' (a mean rally stroke speed that's too fast to be real, a rally with too
#' many strokes to plausibly be one continuous point) so they live in one
#' place instead of scattered across chart-generation code, and so they can
#' be recalibrated deliberately as more sessions accumulate. See
#' issue #5.
#'
#' `max_rally_strokes` is a *named list*, not a single number: `mini_tennis`
#' is a deliberately slow, cooperative warm-up phase where a long
#' continuous rally is genuinely plausible (see issue #3/#4's review of
#' the 14 rallies already found above the *original* default-regime
#' threshold of 50 strokes — 12 of 14 were `mini_tennis`), so it gets its
#' own, higher threshold. Every other regime uses `default`.
#'
#' **Tightened 2026-09-01 (issue #14 and #28 reopened #14 again): 50/60
#' -> 40/50.** The original 50/60 pair was set from the *first* pass at
#' `split_flagged_rallies()` (its gap-threshold pass only), which at the
#' time found no qualifying gap in the data and so never actually resolved
#' any of those 14 rallies — the thresholds were, in effect, calibrated
#' against unsplit, still-implausible rallies, not against genuinely
#' plausible upper bounds for one continuous point. The user directly
#' reported extreme outliers still coming through into the "Rally length
#' distribution, by session and drill" chart under the old thresholds
#' (>100 strokes for `mini_tennis`, >50 for the other drills) and asked for
#' tighter values (`mini_tennis` 50, other drills 40) — this docstring no
#' longer claims those numbers are independently re-derived from a fresh
#' empirical review (no such review has been re-run since the 2026-08-31
#' one that produced 50/60); they are the user-specified tightened bound,
#' recorded here so the next recalibration starts from a stated number
#' rather than a silently stale one. What DID change materially since
#' 50/60 was set: [dq_corrected_rallies()] (added alongside this
#' tightening) now actually applies `split_flagged_rallies()`'s two-pass
#' split logic to every chart's input data, not just to the Exceptions
#' page's proposal table — so a rally that would have silently stayed
#' above the old, looser thresholds is now either split into plausible
#' sub-rallies or dropped, before any chart ever sees it.
#'
#' These are FLAGS, not corrections — a flagged row is surfaced for human
#' review (see the artifact's Exceptions page), never silently dropped,
#' altered, or excluded from the underlying `tennis.duckdb` tables. Only
#' chart-level *display* filtering (with an explicit on-chart note of how
#' many rows were excluded and why) may skip a flagged row.
#'
#' `max_stroke_gap_sec` (issue #14, corrected #42) is the threshold
#' [find_rally_splits()] uses to propose a split of an over-long,
#' `pid`-grouped rally at a pause independently plausible as a real break in
#' play.
#'
#' **A threshold above the observed maximum is not a threshold.** It was set
#' to 8s on the reasoning that the largest gap actually seen was 5s, so 8
#' sat "comfortably above" it. That made the gap pass structurally incapable
#' of ever firing: measured across the current `shot_detail`, 9,666
#' within-rally gaps run 1s (median) / 4s (p99) / 5s (max), with **zero** at
#' or above 6s. Every rally therefore fell through to the forced pass, and
#' `split_method == "gap_threshold"` could never appear in any output. A
#' check whose result cannot vary with its input is not a check
#' (`checks-must-distinguish-unknown`).
#'
#' Set to **4s**, inside the observed range: 176 of 9,666 gaps (1.8%) reach
#' it. The domain reasoning is the user's and is the right kind: during
#' cooperative drills a pause of more than about 3-4 seconds is far more
#' likely to be a new rally starting than a continuing point. Timestamps
#' have 1-second resolution, so gaps are integers and this must stay an
#' integer to mean what it says.
#'
#' **Constraint for any future recalibration:** the value must lie inside
#' the observed gap distribution (`dq_stroke_gaps()`), and setting it above
#' the observed maximum is a defect, not a conservative choice. Re-derive it
#' from the distribution when sessions accumulate; do not raise it to
#' silence splits.
#'
#' @return A named list: `max_mean_stroke_speed_kmh` (numeric),
#'   `max_rally_strokes` (a named list with `default` and `mini_tennis`),
#'   and `max_stroke_gap_sec` (numeric).
#' @export
dq_params <- function() {
  list(
    max_mean_stroke_speed_kmh = 100,
    max_rally_strokes = list(default = 40, mini_tennis = 50),
    max_stroke_gap_sec = 4
  )
}

#' Flag rallies whose stroke count or mean stroke speed exceeds threshold
#'
#' @param rallies A tibble with (at least) `regime`, `n_shots`.
#' @param rally_speed_kmh A tibble with (at least) `match_id`, `rally_id`,
#'   `speed_kmh` (mean stroke speed for that rally) — see
#'   `scripts/make_artifact_charts.R`'s `rally_speed_per_rally`.
#' @return `rallies` with a new `flag_reason` character column (`NA` when
#'   not flagged; one row can carry only one reason, stroke-count checked
#'   first).
#' @export
dq_flag_rallies <- function(rallies, rally_speed_kmh) {
  p <- dq_params()
  max_strokes <- ifelse(
    rallies$regime == "mini_tennis",
    p$max_rally_strokes$mini_tennis,
    p$max_rally_strokes$default
  )
  rallies <- dplyr::left_join(rallies, rally_speed_kmh, by = c("match_id", "rally_id"))
  rallies$flag_reason <- dplyr::case_when(
    rallies$n_shots > max_strokes ~ sprintf("rally > %d strokes (regime threshold)", max_strokes),
    !is.na(rallies$speed_kmh) & rallies$speed_kmh > p$max_mean_stroke_speed_kmh ~
      sprintf("mean stroke speed > %d km/h", p$max_mean_stroke_speed_kmh),
    TRUE ~ NA_character_
  )
  rallies
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

#' Propose splits for rallies flagged for an excess stroke count
#'
#' For every rally in `rallies_flagged` currently flagged for exceeding its
#' stroke-count threshold (not the speed threshold — a fast rally isn't a
#' grouping-boundary problem), looks up its shots in `shot_detail` and
#' proposes a split in **two passes**:
#'
#' 1. **Gap-threshold pass** — [find_rally_splits()] against the
#'    calibrated `params$max_stroke_gap_sec` (a genuine, independently
#'    plausible pause). Today's data has none (see `dq_params()`'s docs).
#' 2. **Forced-largest-gap pass** (2026-09-01, issue #14 reopened) —
#'    for any rally STILL over its stroke threshold after pass 1 finds
#'    nothing, split at the single largest internal gap regardless of
#'    whether that gap alone clears the absolute threshold. A rally that
#'    violates `max_rally_strokes` represents more than one real point by
#'    definition; pass 1 alone was silently leaving it unresolved on the
#'    Exceptions page ("no qualifying gap — unsplit" for every one of the
#'    14 flagged rallies) instead of proposing the best available split
#'    point. This is a single split, not recursive re-splitting — a
#'    sub-rally that's still over threshold afterwards is reported as such
#'    (`still_flagged`), not force-resolved further.
#'
#' This is a **proposed** correction for human review (the Exceptions
#' page's before/after table) — it does NOT write anything back to
#' `tennis.duckdb`, and does not feed any other chart. A rally with no
#' internal gap at all (a single-shot artifact — `nrow(shots) < 2`) passes
#' through unsplit, not silently dropped from the output.
#'
#' @param rallies_flagged Output of [dq_flag_rallies()] — must include
#'   `match_id`, `rally_id`, `regime`, `n_shots`, `flag_reason`.
#' @param shot_detail A tibble with (at least) `match_id`, `rally_id`,
#'   `started_at` — see `tennis_shot_detail()` in `R/db.R`.
#' @param params A `dq_params()`-shaped list; pass a custom one to explore a
#'   different threshold.
#' @return A tibble, one row per proposed sub-rally: `match_id` (rally IDs
#'   are only unique WITHIN a match — several flagged rallies can share the
#'   same numeric `rally_id` across different matches, so `match_id` is
#'   required to disambiguate), `orig_rally_id`, `orig_n_shots`,
#'   `new_rally_id`, `new_n_shots`, `split` (logical — was this rally
#'   actually split), `split_method` (`"none"` / `"gap_threshold"` /
#'   `"forced_largest_gap"`), `still_flagged` (logical — does the new
#'   sub-rally still exceed its own regime's stroke threshold).
#' @export
#' Split a rally repeatedly until no fragment exceeds the stroke threshold
#'
#' issue #42. The previous behaviour split an over-long rally **once**,
#' at its single largest internal gap, which leaves any rally longer than
#' twice the threshold still over it — a 121-stroke rally became 91 + 30 and
#' the 91 was reported as "still over threshold" rather than split again.
#' The point-count violation is the trigger to split, so it has to keep
#' being applied until it is no longer violated.
#'
#' Greedy and deterministic: repeatedly take the first fragment still over
#' `max_strokes` and cut it at its own largest internal gap. Terminates
#' because each pass adds one split point and there are at most `n - 1` of
#' them; stops early and returns what it has if a fragment has no interior
#' point left to cut (a run of strokes with no gap between them cannot be
#' divided, and silently pretending otherwise would be worse than reporting
#' it still flagged).
#'
#' @param gaps Numeric gaps between consecutive strokes; `gaps[i]` is the
#'   pause between stroke `i` and `i + 1`, so a split "after `i`" uses index
#'   `i`. Length `n - 1`.
#' @param n Number of strokes in the rally.
#' @param max_strokes Threshold above which a fragment must be split again.
#' @param seed Split indices already decided by the gap-threshold pass. They
#'   are kept and only topped up. Passing them matters: a gap-threshold split
#'   can itself leave a fragment over the threshold (observed on the 8 Jun
#'   rally 42 -- 51 strokes cut into 8 + 43, with 43 still over 40), and
#'   before this the forced pass ran only when the gap pass found *nothing*,
#'   so that fragment was reported "still over threshold" and left alone.
#' @return An increasing integer vector of split indices, possibly empty.
#' @keywords internal
force_splits_until_under <- function(gaps, n, max_strokes, seed = integer(0)) {
  splits <- sort(unique(as.integer(seed)))
  if (n < 2L || max_strokes < 1L) return(splits)
  repeat {
    bounds <- c(0L, splits, n)
    sizes  <- diff(bounds)
    over   <- which(sizes > max_strokes)
    if (length(over) == 0L) break
    k  <- over[1L]
    lo <- bounds[k]
    hi <- bounds[k + 1L]
    cand <- setdiff(seq.int(lo + 1L, hi - 1L), splits)
    if (length(cand) == 0L) break   # nothing left to cut; caller reports it
    # Largest gap wins; ties break toward the fragment's midpoint. Without
    # the tie-break, a fragment whose gaps are all equal (common at 1-second
    # timestamp resolution) splits at its FIRST candidate every pass, shaving
    # one stroke at a time -- 45 stroked becomes 1+1+1+...+43 instead of
    # 22+23. Balanced cuts also need far fewer passes.
    mid  <- (lo + hi) / 2
    best <- cand[order(-gaps[cand], abs(cand - mid))][1L]
    splits <- sort(c(splits, best))
  }
  splits
}

split_flagged_rallies <- function(rallies_flagged, shot_detail, params = dq_params()) {
  stroke_flagged <- rallies_flagged |>
    dplyr::filter(!is.na(flag_reason), grepl("strokes", flag_reason))

  rows <- Map(
    function(mid, rid, regime, orig_n) {
      shots <- shot_detail |>
        dplyr::filter(match_id == mid, rally_id == rid) |>
        dplyr::arrange(started_at)
      max_strokes <- if (regime == "mini_tennis") params$max_rally_strokes$mini_tennis else params$max_rally_strokes$default

      splits <- find_rally_splits(shots$started_at, max_gap_sec = params$max_stroke_gap_sec)
      n_gap_splits <- length(splits)
      method <- if (n_gap_splits > 0L) "gap_threshold" else "none"

      # Pass 2: keep splitting until nothing is over threshold. Seeded with
      # pass 1's splits, so a high-confidence cut that still leaves an
      # over-length fragment gets topped up rather than left flagged.
      if (orig_n > max_strokes && nrow(shots) >= 2L) {
        gaps <- as.numeric(diff(shots$started_at))
        splits <- force_splits_until_under(gaps, nrow(shots), max_strokes, seed = splits)
        method <- if (n_gap_splits == 0L) "forced_largest_gap"
                  else if (length(splits) > n_gap_splits) "gap_threshold_topped_up"
                  else "gap_threshold"
      }

      if (length(splits) == 0L) {
        return(tibble::tibble(
          match_id = mid, orig_rally_id = as.character(rid), orig_n_shots = orig_n, new_rally_id = as.character(rid),
          new_n_shots = orig_n, split = FALSE, split_method = method, still_flagged = orig_n > max_strokes
        ))
      }
      bounds <- c(0L, splits, nrow(shots))
      sizes  <- diff(bounds)
      tibble::tibble(
        match_id = mid, orig_rally_id = as.character(rid), orig_n_shots = orig_n,
        new_rally_id  = sprintf("%s_%s", rid, letters[seq_along(sizes)]),
        new_n_shots   = sizes, split = TRUE, split_method = method, still_flagged = sizes > max_strokes
      )
    },
    stroke_flagged$match_id, stroke_flagged$rally_id, stroke_flagged$regime, stroke_flagged$n_shots
  )

  dplyr::bind_rows(rows)
}

#' The rallies actually usable for plotting — data-quality corrected
#'
#' Single source of truth for "which rallies may feed a chart" (the issue tracker
#' #28, reopening #14 again): every rally-derived chart in
#' `scripts/make_artifact_charts.R` reads from this function's output
#' instead of the raw `rallies` table, so an implausible outlier (too many
#' strokes for one continuous point, or an implausible mean stroke speed —
#' see [dq_flag_rallies()]) is fixed or dropped BEFORE it reaches a chart,
#' not just flagged for a human to notice afterwards on the Exceptions
#' page. [split_flagged_rallies()]'s proposal table (used by that page) is
#' unaffected by this function and continues to read the raw, uncorrected
#' `rallies` table directly — it is deliberately still showing the "before"
#' picture.
#'
#' For every rally, in order:
#'
#' 1. Per-rally mean stroke speed (`speed_kmh`) is computed from `player ==
#'    "guest"` shots only, in km/h — the same pattern
#'    `scripts/make_artifact_charts.R`'s `rally_speed_per_rally` already
#'    used, now centralised here.
#' 2. Rallies are flagged via [dq_flag_rallies()].
#' 3. A rally flagged **only** for an implausible mean speed (not for
#'    stroke count) is a corrupted-tracking problem, not a
#'    rally-boundary/grouping problem — it is dropped outright, unchanged
#'    from the flag-only behaviour `dq_flag_rallies()` already documents.
#' 4. A rally flagged for stroke count gets the same two-pass split
#'    treatment [split_flagged_rallies()] proposes for human review (reusing
#'    [find_rally_splits()] directly rather than duplicating its gap-finding
#'    logic — see that function's own docs) — but instead of just
#'    *reporting* proposed sub-rally sizes, each shot is actually assigned
#'    to a new sub-rally and every downstream stat is recomputed straight
#'    from that shot subset: `n_shots`, `start_time`/`end_time` (min/max
#'    `started_at` in the subset), `duration_sec` (their difference in
#'    seconds), and `speed_kmh` (mean guest `shot_speed_mph` in the subset,
#'    converted to km/h). Each sub-rally gets a new, disambiguated
#'    `rally_id` (`"<orig>_<letter>"`, matching
#'    [split_flagged_rallies()]'s `new_rally_id` convention) — `rally_id` is
#'    therefore always returned as **character**, not numeric, even for
#'    rallies that were never split (`rally_id` alone is only unique WITHIN
#'    a match to begin with; see [tennis_rallies()]).
#' 5. A rally with fewer than 2 shots (can't be split at all), or a
#'    sub-rally that's STILL over its own regime's stroke threshold after
#'    the best-effort split, is dropped — not force-resolved further, and
#'    not silently included. This matches [split_flagged_rallies()]'s
#'    `still_flagged` semantics, applied here as an actual exclusion
#'    instead of a flag for a human to read.
#' 6. Every rally that was never flagged at all passes through unchanged,
#'    with `speed_kmh` attached.
#'
#' @param rallies A tibble from [tennis_rallies()] (or equivalently shaped)
#'   — `match_id`, `rally_id`, `regime`, `regime_occurrence`,
#'   `segment_index`, `n_shots`, `duration_sec`, `start_time`, `end_time`.
#' @param shot_detail A tibble from [tennis_shot_detail()] — `match_id`,
#'   `rally_id`, `player`, `started_at`, `shot_speed_mph`.
#' @param params A `dq_params()`-shaped list; pass a custom one to explore a
#'   different threshold.
#' @return A tibble shaped like `rallies` (`match_id`, `rally_id` —
#'   character, `regime`, `regime_occurrence`, `segment_index`, `n_shots`,
#'   `duration_sec`, `start_time`, `end_time`) plus `speed_kmh`. A rally
#'   present in `rallies` can be ABSENT here — dropped, never silently
#'   merged into another rally's row — when it (or every one of its
#'   best-effort sub-rallies) is still implausible after correction. No row
#'   in the output exceeds its own regime's `max_rally_strokes` threshold.
#' @export
dq_corrected_rallies <- function(rallies, shot_detail, params = dq_params()) {
  rally_speed <- shot_detail |>
    dplyr::filter(player == "guest", !is.na(rally_id)) |>
    dplyr::group_by(match_id, rally_id) |>
    dplyr::summarise(speed_kmh = mean(shot_speed_mph, na.rm = TRUE) * 1.609344, .groups = "drop")

  rallies_flagged <- dq_flag_rallies(rallies, rally_speed)

  unflagged <- rallies_flagged |>
    dplyr::filter(is.na(flag_reason)) |>
    dplyr::mutate(rally_id = as.character(rally_id)) |>
    dplyr::select(
      match_id, rally_id, regime, regime_occurrence, segment_index,
      n_shots, duration_sec, start_time, end_time, speed_kmh
    )

  # Stroke-count-flagged rallies only -- a speed-only flag is a corrupted-
  # tracking problem, not a grouping/splitting problem, and is dropped
  # outright (never reaches `split_pieces` below, so never reappears).
  stroke_flagged <- rallies_flagged |>
    dplyr::filter(!is.na(flag_reason), grepl("strokes", flag_reason))

  split_pieces <- Map(
    function(mid, rid, regime, regime_occurrence, segment_index, orig_n) {
      shots <- shot_detail |>
        dplyr::filter(match_id == mid, rally_id == rid) |>
        dplyr::arrange(started_at)
      max_strokes <- if (regime == "mini_tennis") params$max_rally_strokes$mini_tennis else params$max_rally_strokes$default

      # Same two-pass split-point search as split_flagged_rallies() --
      # reuses find_rally_splits() rather than duplicating its logic.
      splits <- find_rally_splits(shots$started_at, max_gap_sec = params$max_stroke_gap_sec)
      if (orig_n > max_strokes && nrow(shots) >= 2L) {
        gaps <- as.numeric(diff(shots$started_at))
        splits <- force_splits_until_under(gaps, nrow(shots), max_strokes, seed = splits)
      }

      # No qualifying split point (including the < 2 shots case, where
      # find_rally_splits() always returns none) -- can't be resolved, drop.
      if (length(splits) == 0L || nrow(shots) < 2L) {
        return(NULL)
      }

      bounds <- c(0L, splits, nrow(shots))
      sub_rows <- lapply(seq_len(length(bounds) - 1L), function(k) {
        sub_shots  <- shots[(bounds[k] + 1L):bounds[k + 1L], ]
        sub_guest  <- sub_shots[sub_shots$player == "guest", ]
        tibble::tibble(
          match_id          = mid,
          rally_id          = sprintf("%s_%s", rid, letters[k]),
          regime            = regime,
          regime_occurrence = regime_occurrence,
          segment_index     = segment_index,
          n_shots           = nrow(sub_shots),
          duration_sec      = as.numeric(difftime(max(sub_shots$started_at), min(sub_shots$started_at), units = "secs")),
          start_time        = min(sub_shots$started_at),
          end_time          = max(sub_shots$started_at),
          speed_kmh         = if (nrow(sub_guest) > 0L) mean(sub_guest$shot_speed_mph, na.rm = TRUE) * 1.609344 else NA_real_
        )
      })
      dplyr::bind_rows(sub_rows)
    },
    stroke_flagged$match_id, stroke_flagged$rally_id, stroke_flagged$regime,
    stroke_flagged$regime_occurrence, stroke_flagged$segment_index, stroke_flagged$n_shots
  )
  split_result <- dplyr::bind_rows(split_pieces)

  if (nrow(split_result) > 0L) {
    max_strokes_vec <- ifelse(
      split_result$regime == "mini_tennis",
      params$max_rally_strokes$mini_tennis,
      params$max_rally_strokes$default
    )
    # Drop any sub-rally still over its own regime threshold after the
    # best-effort split -- per-row, so a valid sibling sub-rally is kept.
    split_result <- split_result[split_result$n_shots <= max_strokes_vec, ]
  }

  dplyr::bind_rows(unflagged, split_result)
}
