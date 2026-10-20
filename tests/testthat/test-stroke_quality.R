# Stroke-quality composite and its trend (rallyr#13). Synthetic rows only.

# One match: strokes alternate me ("guest") / feeder ("host") in one rally.
# `speeds` and `lat` describe the "me" strokes; the feeder always hits "right".
mk_q <- function(match_id, speeds, lat = "deuce", long = "no_mans_land",
                 regime = "forehand_cross_court", clearance = NA_real_) {
  k <- length(speeds)
  me <- tibble::tibble(
    match_id = match_id, rally_id = 1, regime = regime, player = "guest",
    hit_wing = "right", shot_speed_mph = speeds,
    bounce_location_long = long, bounce_location_lat = lat,
    net_clearance_m = clearance
  )
  fd <- me
  fd$player <- "host"
  fd$bounce_location_long <- NA_character_
  fd$bounce_location_lat <- NA_character_
  fd$shot_speed_mph <- 20
  out <- dplyr::bind_rows(me, fd)
  idx <- as.vector(rbind(seq_len(k), k + seq_len(k)))
  out <- out[idx, ]
  out$started_at <- as.POSIXct("2000-01-01 10:00:00", tz = "UTC") +
    seq_len(nrow(out)) + 1000 * match_id
  out
}

mk_matches <- function(ids, dates) {
  tibble::tibble(match_id = ids, session_date = as.Date(dates))
}

test_that("session components: median speed, mean zone value, median clearance (#13)", {
  sd <- mk_q(1, speeds = c(40, 60), lat = c("deuce", "ad"), clearance = c(0.5, 0.7))
  sq <- stroke_quality_session(sd, mk_matches(1, "2000-01-01"))
  expect_equal(nrow(sq), 1L)
  expect_equal(sq$speed_mph, 50)
  # tier_1 = 1 and off_target_width = 0.25 on the 0-1 scale
  expect_equal(sq$zone_score, 0.625)
  expect_equal(sq$clearance_m, 0.6)
  expect_equal(sq$n_strokes, 2L)
})

test_that("same-day matches are pooled into one session (#13)", {
  sd <- dplyr::bind_rows(mk_q(1, c(40, 60)), mk_q(2, c(80)))
  sq <- stroke_quality_session(sd, mk_matches(c(1, 2), c("2000-01-01", "2000-01-01")))
  expect_equal(nrow(sq), 1L)
  expect_equal(sq$speed_mph, 60)
  expect_equal(sq$n_strokes, 3L)
})

test_that("only the me side's cross-court strokes count (#13)", {
  sd <- dplyr::bind_rows(mk_q(1, c(40, 60)), mk_q(1, c(200), regime = "net_volley"))
  sq <- stroke_quality_session(sd, mk_matches(1, "2000-01-01"))
  expect_equal(sq$n_strokes, 2L)
  expect_equal(sq$speed_mph, 50)
})

test_that("components are standardised across sessions and weighted (#13)", {
  sd <- dplyr::bind_rows(mk_q(1, 40), mk_q(2, 50), mk_q(3, 60))
  m <- mk_matches(1:3, c("2000-01-01", "2000-01-08", "2000-01-15"))
  sq <- stroke_quality_session(sd, m, weights = list(speed = 1, zone = 0, clearance = 0))
  expect_equal(sq$z_speed, c(-1, 0, 1))
  expect_equal(sq$quality, c(-1, 0, 1))
  # zone is identical in every session: standardised to 0, not NaN
  expect_equal(sq$z_zone, c(0, 0, 0))
  sq2 <- stroke_quality_session(sd, m, weights = list(speed = 1, zone = 1, clearance = 0))
  expect_equal(sq2$quality, c(-0.5, 0, 0.5))
})

test_that("a missing component is left out and the weights renormalised (#13)", {
  sd <- dplyr::bind_rows(mk_q(1, 40, clearance = 0.5), mk_q(2, 60, clearance = 0.7))
  m <- mk_matches(1:2, c("2000-01-01", "2000-01-08"))
  w <- list(speed = 1, zone = 0, clearance = 1)
  both <- stroke_quality_session(sd, m, weights = w)
  expect_equal(both$quality, both$z_speed / 2 + both$z_clearance / 2)
  sd$net_clearance_m <- NA_real_
  one <- stroke_quality_session(sd, m, weights = w)
  expect_equal(one$quality, one$z_speed)
})

test_that("the default weights live in dq_params() and clearance is not scored (#13)", {
  w <- dq_params()$stroke_quality_weights
  expect_named(w, c("speed", "zone", "clearance"))
  expect_equal(w$clearance, 0)
})

test_that("bad weights are a clear error (#13)", {
  sd <- mk_q(1, 40)
  m <- mk_matches(1, "2000-01-01")
  expect_error(
    stroke_quality_session(sd, m, weights = list(speed = 0, zone = 0, clearance = 0)),
    "weights"
  )
  expect_error(
    stroke_quality_session(sd, m, weights = list(speed = -1, zone = 1, clearance = 0)),
    "weights"
  )
  expect_error(stroke_quality_session(sd, m, weights = list(speed = 1)), "weights")
})

test_that("trend compares each session with the mean of the previous k (#13)", {
  sq <- tibble::tibble(
    session_date = as.Date("2000-01-01") + 7 * (0:4),
    quality = c(1, 2, 4, 8, 16)
  )
  tr <- stroke_quality_trend(sq, windows = c(1, 2, 4))
  g <- function(k) tr[tr$window == k, ]
  expect_equal(g(1)$baseline, c(NA, 1, 2, 4, 8))
  expect_equal(g(2)$baseline, c(NA, NA, 1.5, 3, 6))
  expect_equal(g(4)$baseline, c(NA, NA, NA, NA, 3.75))
  expect_equal(g(1)$delta, c(NA, 1, 2, 4, 8))
  expect_named(tr, c("session_date", "window", "current", "baseline", "delta"))
})

test_that("trend sorts by date and rejects a missing column (#13)", {
  sq <- tibble::tibble(
    session_date = as.Date("2000-01-01") + c(7, 0), quality = c(5, 3)
  )
  tr <- stroke_quality_trend(sq, windows = 1)
  expect_equal(tr$current, c(3, 5))
  expect_equal(tr$baseline, c(NA, 3))
  expect_error(stroke_quality_trend(tibble::tibble(a = 1)), "quality")
})

test_that("strokes with no rally id are not paired with their neighbours (#13)", {
  sd <- mk_q(1, speeds = c(40, 60))
  m <- mk_matches(1, "2000-01-01")
  paired <- stroke_quality_session(sd, m)
  expect_equal(paired$zone_score, 1)
  sd$rally_id <- NA
  unpaired <- stroke_quality_session(sd, m)
  expect_true(is.na(unpaired$zone_score))
  expect_equal(unpaired$speed_mph, 50)
})
