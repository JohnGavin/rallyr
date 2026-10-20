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

## Segmentation and classification flags

* `segment_session_drills(shots, drill_order)`: drill-first segmentation at
  long pauses, labelled with a caller-supplied order (no default);
  `example_drill_order` is one example routine. `dq_params()` gains
  `min_drill_gap_sec` and `min_drill_segment_shots`.
* `rally_pid_mismatch()`: vendor point grouping versus the derived rally
  rule, per match and drill, ranked by disagreement.
* `flag_net_call_contradicted()`: a separate flag for out calls followed by
  the other side's stroke; `shot_in` is unchanged and its unreliability for
  net contacts is documented (`?sv_shot_in`).
* `flag_hit_type_suspect()`: the baseline player's volleys in a net-volley
  drill, flagged and not relabelled; role-purity metrics are documented as a
  lower bound.
* `dq_single_stroke_rallies()`: counts single-stroke rallies (genuine versus
  split artefact is not distinguishable yet).
* `dq_velocity_shape_rates()`: monitor for replicated-scalar velocity
  vectors (PRESENT / ABSENT / INDETERMINATE).
* `?signal_independence_checklist`: check a candidate signal is independent
  of its target before trusting a strong correlation.

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
