# Parsing precision: timestamps keep their fractional seconds (rallyr#14).

test_that("sv_time() keeps millisecond precision (#14)", {
  t1 <- sv_time("2000-01-01T10:00:00.742000Z")
  t0 <- sv_time("2000-01-01T10:00:00Z")
  expect_equal(as.numeric(t1) - as.numeric(t0), 0.742, tolerance = 1e-6)
  expect_equal(as.numeric(sv_time("2000-01-01T10:00:00.5Z")) - as.numeric(t0), 0.5, tolerance = 1e-6)
  expect_true(is.na(sv_time(NULL)))
})

test_that("sv_parse_shots() inter-stroke gaps are not whole seconds (#14)", {
  shots <- list(
    list(id = 1, match_id = 1, pid = 1, started_at = "2000-01-01T10:00:00.250000Z"),
    list(id = 2, match_id = 1, pid = 1, started_at = "2000-01-01T10:00:01.900000Z")
  )
  out <- sv_parse_shots(shots)
  gap <- as.numeric(diff(out$started_at), units = "secs")
  expect_equal(gap, 1.65, tolerance = 1e-6)
})

# ---- persisted precision fields (rallyr#20) --------------------------------

persisted_cols <- c(
  "hit_frame", "hit_court_side", "bounce_court_side", "net_clearance_m",
  "bounce_location_long", "bounce_location_lat",
  "hit_x", "hit_y", "hit_z", "bounce_x", "bounce_y", "bounce_z",
  "hit_velocity_x", "hit_velocity_y", "hit_velocity_z"
)

fake_shot <- function() {
  list(
    id = 7, match_id = 1, pid = 3, player = "guest",
    started_at = "2000-01-01T10:00:00.250000Z",
    hit_velocity = list(3, 4, 12),
    hit_frame = 600,
    hit_court_side = "near", bounce_court_side = "far",
    net_location = list(0.1, 0.2, 1.05),
    bounce_location_long = "deep", bounce_location_lat = "deuce",
    hit_location = list(1.5, -10.25, 0.9),
    bounce_location = list(-2.5, 8.75, 0)
  )
}

test_that("sv_parse_shots() keeps the precision fields (#20)", {
  out <- sv_parse_shots(list(fake_shot()))
  expect_true(all(persisted_cols %in% names(out)))
  expect_equal(out$hit_frame, 600)
  expect_equal(out$hit_court_side, "near")
  expect_equal(out$bounce_court_side, "far")
  expect_equal(out$net_clearance_m, 1.05)
  expect_equal(out$bounce_location_long, "deep")
  expect_equal(out$bounce_location_lat, "deuce")
  expect_equal(c(out$hit_x, out$hit_y, out$hit_z), c(1.5, -10.25, 0.9))
  expect_equal(c(out$bounce_x, out$bounce_y, out$bounce_z), c(-2.5, 8.75, 0))
  # the three raw velocity components, in m/s, as supplied
  expect_equal(c(out$hit_velocity_x, out$hit_velocity_y, out$hit_velocity_z), c(3, 4, 12))
  # the scalar speed is still the vector magnitude: sqrt(9 + 16 + 144) = 13 m/s
  expect_equal(out$shot_speed_mph, round(13 * 2.2369362920544, 1))
})

test_that("a shot without the new fields gives NA, not an error (#20)", {
  out <- sv_parse_shots(list(list(id = 1, match_id = 1, pid = 1, started_at = "2000-01-01T10:00:00Z")))
  expect_true(all(persisted_cols %in% names(out)))
  expect_true(all(is.na(unlist(out[persisted_cols]))))
})

test_that("zero-row shot tables carry the precision fields (#20)", {
  expect_true(all(persisted_cols %in% names(sv_parse_shots(list()))))
  con <- tennis_db_connect(withr::local_tempfile(fileext = ".duckdb"))
  withr::defer(DBI::dbDisconnect(con, shutdown = TRUE))
  expect_true(all(persisted_cols %in% names(tennis_shot_detail(con))))
})

# ---- video elapsed time (rallyr#18) ----------------------------------------

test_that("sv_video_elapsed_sec() is hit_frame / fps (#18)", {
  expect_equal(sv_video_elapsed_sec(sv_fps() * 90), 90)
  expect_equal(sv_video_elapsed_sec(0), 0)
  expect_true(is.na(sv_video_elapsed_sec(NULL)))
  expect_true(is.na(sv_video_elapsed_sec(NA)))
})

test_that("sv_parse_shots() adds video_elapsed_sec from hit_frame (#18)", {
  out <- sv_parse_shots(list(fake_shot()))
  expect_equal(out$video_elapsed_sec, 600 / sv_fps())
  none <- sv_parse_shots(list(list(id = 1, match_id = 1, started_at = "2000-01-01T10:00:00Z")))
  expect_true(is.na(none$video_elapsed_sec))
  expect_true("video_elapsed_sec" %in% names(sv_parse_shots(list())))
  con <- tennis_db_connect(withr::local_tempfile(fileext = ".duckdb"))
  withr::defer(DBI::dbDisconnect(con, shutdown = TRUE))
  expect_true("video_elapsed_sec" %in% names(tennis_shot_detail(con)))
})

test_that("fmt_video_time() gives m:ss, then h:mm:ss past an hour (#18)", {
  expect_equal(fmt_video_time(c(0, 5, 65, 599.6, 3599, 3600, 3725, NA)),
               c("0:00", "0:05", "1:05", "10:00", "59:59", "1:00:00", "1:02:05", "-"))
})
