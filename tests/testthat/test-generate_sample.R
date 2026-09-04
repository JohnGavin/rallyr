# Validates data-raw/generate_sample.R.
#
# This is a script under data-raw/, not R/, so its functions are sourced
# into a local environment rather than being part of the rallyr NAMESPACE.

source_synthetic_script <- function() {
  env <- new.env(parent = globalenv())
  withr::local_envvar(
    c(SYNTHETIC_SAMPLE_SKIP_LOAD = "1", SYNTHETIC_SAMPLE_SKIP_MAIN = "1"),
    .local_envir = parent.frame()
  )
  path <- testthat::test_path("..", "..", "data-raw", "generate_sample.R")
  skip_if_not(file.exists(path), "generate_sample.R not found")
  sys.source(path, envir = env)
  env
}

test_that("generate_synthetic_sample() produces the expected table shapes", {
  env <- source_synthetic_script()
  data <- env$generate_synthetic_sample(n_sessions = 2, seed = 1)

  expect_named(data, c("matches", "shot_segments", "shot_detail", "rallies", "session_weather"))
  expect_equal(nrow(data$matches), 2L)
  expect_equal(nrow(data$session_weather), 2L)
  expect_true(nrow(data$shot_detail) > 0L)
  expect_true(nrow(data$shot_segments) > 0L)
  expect_true(nrow(data$rallies) > 0L)

  # Column contract matches the real schema (see R/fetch_swingvision.R's
  # sv_parse_match()/sv_parse_shots() and R/db.R's zero-row definitions).
  expect_true(all(c(
    "match_id", "share_token", "played_at", "session_date", "start_time",
    "duration_min", "sport", "location", "latitude", "longitude",
    "opponent", "me_shots", "me_shots_in", "shots_in_pct"
  ) %in% names(data$matches)))
  expect_true(all(c(
    "match_id", "shot_id", "rally_id", "player", "started_at",
    "hit_type", "hit_wing", "spin_type", "shot_speed_mph", "shot_in",
    "segment_index", "regime"
  ) %in% names(data$shot_detail)))
})

test_that("synthetic output is clearly fictional, not shaped like anyone's real data", {
  env <- source_synthetic_script()
  data <- env$generate_synthetic_sample(n_sessions = 2, seed = 2)

  # Locations/opponent are drawn from an explicit "(synthetic)"/"Sample ..."
  # vocabulary -- never a free-form name that could coincide with a real one.
  expect_true(all(grepl("synthetic|Sample", data$matches$location)))
  expect_true(all(data$matches$opponent == "Sample Opponent"))
  expect_true(all(grepl("^synthetic-", data$matches$share_token)))
  # session_date is anchored far in the future (2030+), never a real session date
  expect_true(all(data$matches$session_date >= as.Date("2029-01-01")))
})

test_that("synthetic shots pass segment_session_shots() without erroring", {
  env <- source_synthetic_script()
  data <- env$generate_synthetic_sample(n_sessions = 1, seed = 3)
  segs <- data$shot_segments
  expect_true(nrow(segs) > 0L)
  # At least one non-"gap" regime was detected -- proves the synthetic shot
  # characteristics are plausible enough for the real detection thresholds,
  # not just schema-shaped.
  expect_true(any(segs$regime != "gap"))
})

test_that("synthetic rallies pass dq_flag_rallies() without erroring", {
  env <- source_synthetic_script()
  data <- env$generate_synthetic_sample(n_sessions = 2, seed = 4)

  rally_speed_kmh <- data$shot_detail |>
    dplyr::group_by(match_id, rally_id) |>
    dplyr::summarise(speed_kmh = mean(shot_speed_mph, na.rm = TRUE) * 1.609344, .groups = "drop")

  flagged <- dq_flag_rallies(data$rallies, rally_speed_kmh)
  expect_true("flag_reason" %in% names(flagged))
  expect_equal(nrow(flagged), nrow(data$rallies))
})

test_that("synthetic rallies + shot_detail pass dq_corrected_rallies() without erroring", {
  env <- source_synthetic_script()
  data <- env$generate_synthetic_sample(n_sessions = 2, seed = 5)
  out <- dq_corrected_rallies(data$rallies, data$shot_detail)
  expect_true(is.data.frame(out))
  expect_true(nrow(out) >= nrow(data$rallies))
})

test_that("write_synthetic_sample_db() writes a database matching tennis_db_schema()", {
  env <- source_synthetic_script()
  data <- env$generate_synthetic_sample(n_sessions = 1, seed = 6)

  db <- withr::local_tempfile(fileext = ".duckdb")
  path <- env$write_synthetic_sample_db(data, path = db)
  expect_equal(path, db)
  expect_true(file.exists(db))

  con <- tennis_db_connect(db)
  withr::defer(DBI::dbDisconnect(con, shutdown = TRUE))
  schema <- tennis_db_schema(con)
  expect_true(all(c("matches", "shot_segments", "shot_detail", "rallies", "session_weather") %in% schema$table_name))

  back <- tennis_matches(con)
  expect_equal(nrow(back), 1L)
})
