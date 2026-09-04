# Minimal smoke test: confirms the package loads cleanly and its
# public-facing entry points are callable, using the bundled synthetic
# sample data rather than any real session export.

test_that("core exported functions exist and are functions", {
  expect_true(is.function(fetch_swingvision))
  expect_true(is.function(fetch_swingvision_shots))
  expect_true(is.function(sv_parse_match))
  expect_true(is.function(sv_parse_shots))
  expect_true(is.function(parse_swingvision))
  expect_true(is.function(tennis_db_connect))
  expect_true(is.function(tennis_db_upsert))
  expect_true(is.function(tennis_db_schema))
  expect_true(is.function(segment_session_shots))
  expect_true(is.function(dq_flag_rallies))
  expect_true(is.function(dq_corrected_rallies))
  expect_true(is.function(session_effort_metrics))
  expect_true(is.function(session_standard_metrics))
})

test_that("parse_swingvision('') yields a zero-row frame without erroring", {
  df <- parse_swingvision("")
  expect_equal(nrow(df), 0L)
  expect_true("me_shots" %in% names(df))
})

test_that("sv_parse_shots(list()) yields the documented zero-row schema", {
  df <- sv_parse_shots(list())
  expect_equal(nrow(df), 0L)
  expect_true(all(c("match_id", "shot_id", "rally_id", "player") %in% names(df)))
})

test_that("tennis_db_connect()/tennis_db_upsert() round-trip on a temp file", {
  db <- withr::local_tempfile(fileext = ".duckdb")
  con <- tennis_db_connect(db)
  withr::defer(DBI::dbDisconnect(con, shutdown = TRUE))

  fake <- tibble::tibble(match_id = 1, opponent = "Sample Opponent")
  n <- tennis_db_upsert(con, fake, key = "match_id", table = "matches")
  expect_equal(n, 1L)

  schema <- tennis_db_schema(con)
  expect_true("matches" %in% schema$table_name)
})

test_that("the bundled synthetic sample database, if present, matches the schema", {
  db_path <- system.file("extdata", "synthetic_sample.duckdb", package = "rallyr")
  skip_if(!nzchar(db_path), "synthetic_sample.duckdb not built yet -- run data-raw/generate_sample.R")

  con <- tennis_db_connect(db_path)
  withr::defer(DBI::dbDisconnect(con, shutdown = TRUE))
  schema <- tennis_db_schema(con)
  expect_true(all(
    c("matches", "shot_segments", "shot_detail", "rallies", "session_weather") %in% schema$table_name
  ))
  matches <- tennis_matches(con)
  expect_true(nrow(matches) > 0L)
})
