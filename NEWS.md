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

## Parsing precision and persisted fields

* `sv_time()` keeps sub-second precision (`%OS`); per-stroke gaps were
  previously rounded to whole seconds.
* `tennis_db_upsert()` adds columns the stored table lacks (existing rows
  get `NULL`) instead of failing; existing columns are never dropped or
  retyped.
* `sv_parse_shots()` and the shot table persist `hit_frame`,
  `video_elapsed_sec`, `hit_court_side`, `bounce_court_side`,
  `net_clearance_m`, `bounce_location_long`/`_lat`, numeric hit and bounce
  coordinates (`hit_x`..`bounce_z`) and the raw `hit_velocity_x`/`_y`/`_z`.
* `fmt_video_time()` and `sv_video_drift()` (PASS / DRIFT / INDETERMINATE
  check of a recording's frame timing against the pinned rate).
* `dq_null_sentinel()`, `dq_clean_shot_speed()` and
  `dq_params()$sentinel_shot_speeds_mph`: placeholder speeds are set to `NA`
  and flagged, the stroke is kept; `dq_corrected_rallies()` applies them.
* Docs: match start time is not a stable anchor, spin is categorical only.
