# rallyr 0.0.0.9000

## Breaking changes

* Rally stroke limits are per drill (cross-court 20, default 25,
  mini-tennis 50) and count one player's strokes (`me_shots`, see
  `rally_player_strokes()`), where they previously counted both players'
  strokes against 40/50. `dq_flag_rallies()` now needs a `me_shots` column.
* The stroke limit only flags: `force_splits_until_under()` is removed, so an
  over-limit rally with no qualifying pause is flagged and left out of
  `dq_corrected_rallies()` instead of being split at its largest gap.
* `dq_params()$max_stroke_gap_sec` is now a named list per drill (cross-court
  3 s, net-volley 2 s); mini-tennis is never pause-split. A pause only splits
  a rally when the feeder (`rally_starter = "host"`) hits next
  (`split_requires_starter_next`).

## New

* `rally_stroke_threshold()`, `rally_split_gap_sec()`,
  `rally_player_strokes()`, `find_rally_splits(is_starter = )`; the
  `me_side` and `rally_starter` arguments of `dq_corrected_rallies()`.
* `dq_excluded_count()`: a count of flagged rallies that cannot go negative.
* `dq_params()$max_individual_stroke_speed_kmh`: a rally holding one
  implausibly fast stroke is flagged.
* `segment_session_shots(min_segment_duration_min = )`: a same-regime run
  shorter than 3 minutes becomes a `"gap"`.
