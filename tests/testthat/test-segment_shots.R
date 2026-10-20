# Synthetic session: `blocks` is a list of (minutes, host_hit_type) phases of
# shots every 5 s, alternating host / guest. Guest ground strokes are slow
# (mini-tennis speed); a block of host volleys classifies as net_volley.
mk_session <- function(blocks) {
  t0 <- as.POSIXct("2000-01-01 10:00:00", tz = "UTC")
  rows <- list()
  clock <- 0
  for (b in blocks) {
    n <- b$minutes * 12L
    for (j in seq_len(n)) {
      host <- j %% 2L == 0L
      rows[[length(rows) + 1L]] <- tibble::tibble(
        started_at = t0 + clock, ended_at = t0 + clock + 1,
        player = if (host) "host" else "guest",
        hit_type = if (host) b$host_hit else "ground_stroke",
        hit_wing = "right", shot_speed_mph = 20
      )
      clock <- clock + 5
    }
  }
  dplyr::bind_rows(rows)
}

regimes <- function(segs) segs$regime

test_that("a drill segment shorter than the minimum duration is relabelled gap", {
  shots <- mk_session(list(
    list(minutes = 6, host_hit = "ground_stroke"),
    list(minutes = 2, host_hit = "volley"),          # a 2-minute run of net-volley bins
    list(minutes = 6, host_hit = "ground_stroke")
  ))
  expect_equal(dq_params()$min_segment_duration_min, 3)

  with_default <- segment_session_shots(shots)
  expect_equal(regimes(with_default), c("mini_tennis", "gap", "mini_tennis"))

  # Control: with the filter off the same fragment keeps its detected regime.
  no_filter <- segment_session_shots(shots, min_segment_duration_min = 0)
  expect_equal(regimes(no_filter), c("mini_tennis", "net_volley", "mini_tennis"))
})

test_that("a segment at or above the minimum duration keeps its regime", {
  shots <- mk_session(list(
    list(minutes = 6, host_hit = "ground_stroke"),
    list(minutes = 4, host_hit = "volley"),
    list(minutes = 6, host_hit = "ground_stroke")
  ))
  expect_equal(regimes(segment_session_shots(shots)), c("mini_tennis", "net_volley", "mini_tennis"))
})

test_that("min_segment_duration_min is validated", {
  shots <- mk_session(list(list(minutes = 6, host_hit = "ground_stroke")))
  expect_error(segment_session_shots(shots, min_segment_duration_min = NA_real_), "min_segment_duration_min")
  expect_error(segment_session_shots(shots, min_segment_duration_min = -1), "min_segment_duration_min")
  expect_error(segment_session_shots(shots, min_segment_duration_min = c(1, 2)), "min_segment_duration_min")
  expect_error(segment_session_shots(shots, min_segment_duration_min = "3"), "min_segment_duration_min")
})

test_that("adjacent short segments become one gap and segment_index is renumbered", {
  shots <- mk_session(list(
    list(minutes = 2, host_hit = "volley"),          # short net_volley
    list(minutes = 2, host_hit = "ground_stroke"),   # short mini_tennis
    list(minutes = 6, host_hit = "volley")
  ))
  segs <- segment_session_shots(shots)
  expect_equal(regimes(segs), c("gap", "net_volley"))
  expect_equal(segs$segment_index, 1:2)
  expect_equal(segs$n_shots[1], 48L)
  expect_equal(segs$n_shots[1], segs$n_host_shots[1] + segs$n_guest_shots[1])
  expect_equal(segs$start_time[1], min(shots$started_at))
})

test_that("a short final segment is relabelled gap like any other", {
  shots <- mk_session(list(
    list(minutes = 6, host_hit = "ground_stroke"),
    list(minutes = 2, host_hit = "volley")
  ))
  segs <- segment_session_shots(shots)
  expect_equal(regimes(segs), c("mini_tennis", "gap"))
  expect_equal(segs$segment_index, 1:2)
})
