# Hand-built fixtures only; no real data.
mk_session <- function(block_sizes, gaps_between, within_gap = 2,
                       t0 = as.POSIXct("2000-01-01 10:00:00", tz = "UTC")) {
  t <- t0
  out <- list()
  for (i in seq_along(block_sizes)) {
    out[[i]] <- t + (seq_len(block_sizes[i]) - 1) * within_gap
    t <- max(out[[i]]) + if (i <= length(gaps_between)) gaps_between[i] else 0
  }
  tibble::tibble(started_at = do.call(c, out))
}

test_that("example_drill_order is a documented character constant", {
  expect_type(example_drill_order, "character")
  expect_gte(length(example_drill_order), 2L)
})

test_that("drill_order is required and validated", {
  s <- mk_session(c(20, 20), 90)
  expect_error(segment_session_drills(s), "drill_order")
  expect_error(segment_session_drills(s, drill_order = character(0)), "drill_order")
  expect_error(segment_session_drills(s, drill_order = c("a", NA)), "drill_order")
  expect_error(segment_session_drills(s, drill_order = 1:2), "drill_order")
})

test_that("long pauses split the session and the order labels the segments", {
  s <- mk_session(c(20, 30, 25), c(90, 120))
  out <- segment_session_drills(s, drill_order = c("a", "b", "c"))
  expect_equal(out$drill_index, 1:3)
  expect_equal(out$regime, c("a", "b", "c"))
  expect_equal(out$n_shots, c(20L, 30L, 25L))
  expect_equal(out$regime_occurrence, c(1L, 1L, 1L))
})

test_that("a repeated drill gets an occurrence number", {
  s <- mk_session(c(20, 20, 20), c(90, 90))
  out <- segment_session_drills(s, drill_order = c("a", "b", "a"))
  expect_equal(out$regime_occurrence, c(1L, 1L, 2L))
})

test_that("a pause equal to the threshold splits; one below does not", {
  s <- mk_session(c(15, 15), 60)          # gap = 60 + 2 within-gap step
  expect_equal(nrow(segment_session_drills(s, drill_order = c("a", "b"),
                                           min_drill_gap_sec = 60)), 2L)
  expect_equal(nrow(segment_session_drills(s, drill_order = "a",
                                           min_drill_gap_sec = 500)), 1L)
})

test_that("a count mismatch gives NA labels, never forced labels", {
  s <- mk_session(c(20, 20, 20), c(90, 90))
  out <- segment_session_drills(s, drill_order = c("a", "b"))
  expect_equal(nrow(out), 3L)
  expect_true(all(is.na(out$regime)))
  expect_true(all(out$regime_occurrence == 1L))
})

test_that("an isolated stray stroke between two pauses is merged away", {
  # 20 | 1 | 20 with two long pauses: the 1-stroke segment is not a drill.
  s <- mk_session(c(20, 1, 20), c(90, 100))
  out <- segment_session_drills(s, drill_order = c("a", "b"),
                                min_drill_segment_shots = 10)
  expect_equal(nrow(out), 2L)
  expect_equal(out$regime, c("a", "b"))
  expect_equal(sum(out$n_shots), 41L)
})

test_that("input order does not matter and short input is typed-empty", {
  s <- mk_session(c(20, 20), 90)
  shuffled <- s[sample(nrow(s)), ]
  expect_equal(segment_session_drills(shuffled, drill_order = c("a", "b"))$n_shots,
               c(20L, 20L))
  out <- segment_session_drills(s[1, ], drill_order = c("a", "b"))
  expect_equal(nrow(out), 0L)
  expect_named(out, c("drill_index", "regime", "regime_occurrence",
                      "start_time", "end_time", "n_shots"))
})

test_that("a missing started_at column is an error", {
  expect_error(segment_session_drills(tibble::tibble(x = 1:3), drill_order = "a"),
               "started_at")
})

test_that("dq_params() carries the drill-gap thresholds", {
  expect_equal(dq_params()$min_drill_gap_sec, 60)
  expect_equal(dq_params()$min_drill_segment_shots, 10)
})
