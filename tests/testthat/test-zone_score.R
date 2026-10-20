# Cross-court landing-zone score (rallyr#24). Synthetic rows only.

zs <- function(...) {
  d <- tibble::tibble(...)
  cross_court_zone_score(
    d$regime, d$player, d$bounce_location_long, d$bounce_location_lat,
    d$next_player, d$next_hit_wing
  )
}

test_that("each tier is scored from depth, width and the feeder's next wing (#24)", {
  out <- zs(
    regime = "forehand_cross_court", player = "guest",
    bounce_location_long = c("no_mans_land", "no_mans_land", "service_box", "service_box", "no_mans_land", "no_mans_land"),
    bounce_location_lat = c("deuce", "deuce", "deuce", "deuce", "ad", "deuce_out"),
    next_player = "host",
    next_hit_wing = c("right", "left", "right", "left", "right", "right")
  )
  expect_equal(
    as.character(out),
    c("tier_1", "tier_2", "tier_2", "tier_3", "off_target_width", "out_of_play")
  )
  expect_s3_class(out, "ordered")
  expect_equal(
    levels(out),
    c("out_of_play", "off_target_width", "tier_3", "tier_2", "tier_1")
  )
})

test_that("backhand cross-court mirrors: ad side, feeder backhand wanted (#24)", {
  out <- zs(
    regime = "backhand_cross_court", player = "guest",
    bounce_location_long = "no_mans_land",
    bounce_location_lat = c("ad", "ad", "deuce"),
    next_player = "host", next_hit_wing = c("left", "right", "left")
  )
  expect_equal(as.character(out), c("tier_1", "tier_2", "off_target_width"))
})

test_that("the result is as long as the input, not truncated to length 1 (#24)", {
  n <- 7L
  out <- cross_court_zone_score(
    rep("forehand_cross_court", n), rep("guest", n),
    rep("no_mans_land", n), rep("deuce", n),
    rep("host", n), c("right", "left", "right", "left", "right", "left", "right")
  )
  expect_length(out, n)
  expect_equal(
    as.character(out),
    c("tier_1", "tier_2", "tier_1", "tier_2", "tier_1", "tier_2", "tier_1")
  )
  # a per-row handedness vector must work as well as a scalar
  out2 <- cross_court_zone_score(
    rep("forehand_cross_court", 2), rep("guest", 2),
    rep("no_mans_land", 2), rep("deuce", 2),
    rep("host", 2), c("right", "right"),
    feeder_right_handed = c(TRUE, FALSE)
  )
  expect_equal(as.character(out2), c("tier_1", "tier_2"))
})

test_that("a left-handed feeder swaps which hit_wing is the forehand (#24)", {
  out <- cross_court_zone_score(
    "forehand_cross_court", "guest", "no_mans_land", "deuce", "host", "left",
    feeder_right_handed = FALSE
  )
  expect_equal(as.character(out), "tier_1")
})

test_that("no response signal means NA, never a guess (#24)", {
  out <- zs(
    regime = "forehand_cross_court", player = "guest",
    bounce_location_long = "no_mans_land", bounce_location_lat = "deuce",
    next_player = c(NA, "guest", "host"),   # rally ended / alternation broke / ok
    next_hit_wing = c(NA, "right", NA)       # ... / ... / wing missing
  )
  expect_true(all(is.na(out)))
})

test_that("only the 'me' side's cross-court strokes are scored (#24)", {
  out <- zs(
    regime = c("net_volley", "mini_tennis", "forehand_cross_court", NA),
    player = c("guest", "guest", "host", "guest"),
    bounce_location_long = "no_mans_land", bounce_location_lat = "deuce",
    next_player = "host", next_hit_wing = "right"
  )
  expect_true(all(is.na(out)))
})

test_that("unknown bounce zone is NA, not a score (#24)", {
  out <- zs(
    regime = "forehand_cross_court", player = "guest",
    bounce_location_long = c(NA, "no_mans_land"),
    bounce_location_lat = c("deuce", NA),
    next_player = "host", next_hit_wing = "right"
  )
  expect_true(all(is.na(out)))
})

test_that("zone_score_numeric maps levels onto 0..1 (#24)", {
  x <- cross_court_zone_score(
    rep("forehand_cross_court", 3), "guest",
    c("no_mans_land", "service_box", "service_box"),
    c("deuce", "deuce", "deuce_out"), "host", c("right", "left", NA)
  )
  v <- zone_score_numeric(x)
  expect_equal(v[1], 1)
  expect_equal(v[2], 0.5)
  expect_equal(v[3], 0)  # out of play needs no response signal
  expect_equal(zone_score_numeric(factor("out_of_play", levels = levels(x), ordered = TRUE)), 0)
})

test_that("a depth of 'out' alone is out of play even with an unknown width (#24)", {
  out <- zs(
    regime = "forehand_cross_court", player = "guest",
    bounce_location_long = c("out", "no_mans_land"),
    bounce_location_lat = c(NA, NA),
    next_player = "host", next_hit_wing = "right"
  )
  expect_equal(as.character(out), c("out_of_play", NA))
})

test_that("a left-handed me side mirrors the target widths (#24)", {
  args <- list(
    regime = c("forehand_cross_court", "backhand_cross_court"), player = "guest",
    bounce_location_long = "no_mans_land",
    bounce_location_lat = c("ad", "deuce"),
    next_player = "host", next_hit_wing = c("right", "left")
  )
  right <- do.call(cross_court_zone_score, args)
  expect_equal(as.character(right), c("off_target_width", "off_target_width"))
  left <- do.call(cross_court_zone_score, c(args, list(me_right_handed = FALSE)))
  expect_equal(as.character(left), c("tier_1", "tier_1"))
})
