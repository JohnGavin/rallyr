# Snapshot tests against the bundled synthetic sample database.
#
# test-smoke.R checks that the exported functions exist and handle trivial
# edge cases (empty input); it never exercises the actual transform LOGIC
# (rally splitting, data-quality flagging, drill-phase segmentation, effort
# metrics) against real-shaped data. These tests fill that gap: every
# transform function is run against `inst/extdata/synthetic_sample.duckdb`
# (committed, deterministic, zero real session data -- see
# `data-raw/generate_sample.R`'s fixed seed) and its output captured as a
# snapshot. A snapshot test doesn't assert a hand-derived "correct" value --
# it catches an UNINTENDED change to behaviour, which is exactly what this
# package had zero coverage for.
#
# Run `testthat::snapshot_accept("snapshots")` (or `devtools::test()` +
# reviewing the diff) to update snapshots after a deliberate behaviour
# change; a snapshot diff on an otherwise-unrelated change is a signal to
# stop and look, not to blindly accept.

db_path <- system.file("extdata", "synthetic_sample.duckdb", package = "rallyr")
skip_if(!nzchar(db_path), "synthetic_sample.duckdb not built yet -- run data-raw/generate_sample.R")

con <- tennis_db_connect(db_path)
withr::defer(DBI::dbDisconnect(con, shutdown = TRUE), envir = teardown_env())

matches     <- tennis_matches(con)
rallies     <- tennis_rallies(con)
shot_detail <- tennis_shot_detail(con)

test_that("tennis_db_schema() output is stable", {
  schema <- tennis_db_schema(con)
  # Row order from information_schema isn't guaranteed stable across DuckDB
  # versions -- sort before snapshotting so the snapshot reflects real
  # schema changes, not incidental catalogue ordering.
  schema <- schema[order(schema$table_name, schema$column_name), ]
  expect_snapshot(as.data.frame(schema))
})

test_that("merge_same_day_sessions() output is stable", {
  m <- merge_same_day_sessions(matches)
  expect_snapshot(as.data.frame(m))
})

test_that("find_rally_splits() on real shot timing is stable", {
  # The persisted shot_detail schema has no ended_at (see the function's own
  # docs) -- started_at-only is the real, documented usage.
  one_rally <- shot_detail[shot_detail$match_id == shot_detail$match_id[1] &
    shot_detail$rally_id == shot_detail$rally_id[1], ]
  one_rally <- one_rally[order(one_rally$started_at), ]
  skip_if(nrow(one_rally) < 2L, "sample rally too short to test a split")
  splits <- find_rally_splits(one_rally$started_at, max_gap_sec = dq_params()$max_stroke_gap_sec)
  expect_snapshot(splits)
})

test_that("dq_corrected_rallies() on the full sample dataset is stable", {
  corrected <- dq_corrected_rallies(rallies, shot_detail)
  corrected <- corrected[order(corrected$match_id, corrected$rally_id), ]
  expect_snapshot(as.data.frame(corrected))
})

test_that("segment_session_shots() on one match's shots is stable", {
  one_match <- shot_detail[shot_detail$match_id == shot_detail$match_id[1], ]
  # ended_at isn't in the persisted schema (see find_rally_splits()'s docs
  # for the same gap) -- segment_session_shots() requires it unconditionally,
  # so a nominal 1-second stroke duration is synthesised here purely to give
  # the function a well-shaped input; the segmentation logic itself doesn't
  # depend on its precision.
  one_match$ended_at <- one_match$started_at + 1
  segs <- segment_session_shots(one_match)
  expect_snapshot(as.data.frame(segs))
})

test_that("session_effort_metrics() on the full sample dataset is stable", {
  m <- merge_same_day_sessions(matches)
  skip_if(nrow(m) < 2L, "need at least 2 sessions")
  m$me_run_km   <- m$me_run_mi * 1.609344
  m$fh_speed_kmh <- m$fh_speed_mph * 1.609344
  m$bh_speed_kmh <- m$bh_speed_mph * 1.609344
  effort <- session_effort_metrics(m)
  expect_snapshot(as.data.frame(effort[, c("session_date", "z_distance", "z_shots", "z_speed", "z_pace", "effort_z")]))
})

test_that("session_standard_metrics() + session_metric_ranks() on the full sample dataset are stable", {
  m <- merge_same_day_sessions(matches)
  skip_if(nrow(m) < 2L, "need at least 2 sessions")
  sm <- session_standard_metrics(m)
  expect_snapshot(as.data.frame(sm))

  ranks <- session_metric_ranks(sm)
  expect_snapshot(as.data.frame(ranks))
})

test_that("fmt_speed_mph()/fmt_mmss() formatting is stable", {
  expect_snapshot(fmt_speed_mph(c(0, 10.5, 47.3, NA)))
  expect_snapshot(fmt_mmss(c(0, 0.1, 7.5, 62.25, NA)))
})
