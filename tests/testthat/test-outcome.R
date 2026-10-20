# Stroke-outcome severity and the rally-end rule (rallyr#12). Synthetic rows.

sev <- function(...) {
  d <- tibble::tibble(...)
  stroke_outcome_severity(
    d$net_contact, d$bounce_location_long, d$bounce_location_lat,
    d$hit_court_side, d$bounce_court_side
  )
}

test_that("severity is ordered net fault < out both axes < out one axis < in (#12)", {
  out <- sev(
    net_contact = c(TRUE, FALSE, FALSE, FALSE, FALSE),
    bounce_location_long = c(NA, "out", "out", "no_mans_land", "no_mans_land"),
    bounce_location_lat = c(NA, "ad_out", "deuce", "deuce_out", "deuce"),
    hit_court_side = "near",
    bounce_court_side = c("near", "far", "far", "far", "far")
  )
  expect_equal(
    as.character(out),
    c("net_fault", "out_both_axes", "out_one_axis", "out_one_axis", "in_bounds")
  )
  expect_s3_class(out, "ordered")
  expect_equal(levels(out), c("net_fault", "out_both_axes", "out_one_axis", "in_bounds"))
  expect_true(out[1] < out[2] && out[2] < out[3] && out[3] < out[5])
})

test_that("a net contact that crossed is not a fault; unknown sides are NA (#12)", {
  out <- sev(
    net_contact = c(TRUE, TRUE, TRUE),
    bounce_location_long = "no_mans_land", bounce_location_lat = "deuce",
    hit_court_side = c("near", "near", NA),
    bounce_court_side = c("far", "near", "far")   # crossed / never crossed / unknown
  )
  expect_equal(as.character(out), c("in_bounds", "net_fault", NA))
})

test_that("without a net-contact call nothing is a net fault (#12, #26)", {
  out <- stroke_outcome_severity(
    net_contact = NA, bounce_location_long = c("no_mans_land", NA),
    bounce_location_lat = c("deuce", NA)
  )
  expect_equal(as.character(out), c("in_bounds", NA))
})

test_that("the result is as long as the input (#12)", {
  n <- 6L
  out <- stroke_outcome_severity(
    FALSE, rep("out", n), rep("deuce", n), "near", "far"
  )
  expect_length(out, n)
  expect_true(all(out == "out_one_axis"))
})

# ---- rally_end_rule ----------------------------------------------------------

mk_shots <- function(t, players, regime = "forehand_cross_court",
                     long = "no_mans_land", lat = "deuce", match_id = 1L) {
  tibble::tibble(
    match_id = match_id,
    started_at = as.POSIXct("2000-01-01 10:00:00", tz = "UTC") + t,
    player = players, regime = regime,
    bounce_location_long = long, bounce_location_lat = lat
  )
}

test_that("a fault ends the rally on that stroke (#12)", {
  sd <- mk_shots(c(0, 1, 2), c("host", "guest", "host"),
                 long = c("no_mans_land", "no_mans_land", "out"))
  out <- rally_end_rule(sd)
  expect_equal(out$end_reason, c(NA, NA, "fault"))
  expect_equal(out$ends_rally, c(FALSE, FALSE, TRUE))
})

test_that("a pause before the feeder's stroke ends the rally on the stroke before (#12)", {
  sd <- mk_shots(c(0, 1, 9, 10), c("host", "guest", "host", "guest"))
  out <- rally_end_rule(sd)
  expect_equal(out$end_reason, c(NA, "pause", NA, "end_of_data"))
})

test_that("a long gap before the other player's stroke is a missed stroke, not a boundary (#12)", {
  sd <- mk_shots(c(0, 1, 9), c("host", "guest", "guest"))
  out <- rally_end_rule(sd)
  expect_true(is.na(out$end_reason[2]))
  p <- dq_params()
  p$split_requires_starter_next <- FALSE
  expect_equal(rally_end_rule(sd, p)$end_reason[2], "pause")
})

test_that("pause thresholds follow the regime; mini-tennis is never pause-ended (#12)", {
  # 2.5 s: over the net-volley limit (2 s), under the cross-court one (3 s)
  nv <- rally_end_rule(mk_shots(c(0, 2.5), c("guest", "host"), regime = "net_volley"))
  cc <- rally_end_rule(mk_shots(c(0, 2.5), c("guest", "host")))
  mt <- rally_end_rule(mk_shots(c(0, 20), c("guest", "host"), regime = "mini_tennis"))
  expect_equal(nv$end_reason[1], "pause")
  expect_true(is.na(cc$end_reason[1]))
  expect_true(is.na(mt$end_reason[1]))
})

test_that("a fault takes precedence over a pause on the same stroke (#12)", {
  sd <- mk_shots(c(0, 1, 9), c("host", "guest", "host"),
                 long = c("no_mans_land", "out", "no_mans_land"))
  expect_equal(rally_end_rule(sd)$end_reason[2], "fault")
})

test_that("matches are ordered by time and ended separately (#12)", {
  sd <- dplyr::bind_rows(
    mk_shots(c(5, 0), c("guest", "host"), match_id = 2L),
    mk_shots(c(0, 1), c("host", "guest"), match_id = 1L)
  )
  out <- rally_end_rule(sd)
  expect_equal(out$match_id, c(1L, 1L, 2L, 2L))
  expect_equal(out$end_reason[c(2, 4)], c("end_of_data", "end_of_data"))
})

test_that("rally_end_rule() names a missing column (#12)", {
  expect_error(rally_end_rule(tibble::tibble(match_id = 1)), "started_at")
})

test_that("equal timestamps keep input order, so the result is deterministic (#12)", {
  sd <- mk_shots(c(0, 0, 0, 5), c("host", "guest", "host", "guest"),
                 long = c("no_mans_land", "no_mans_land", "out", "no_mans_land"))
  sd$tag <- c("a", "b", "c", "d")
  out <- rally_end_rule(sd)
  expect_equal(out$tag, c("a", "b", "c", "d"))
  expect_equal(out$end_reason, c(NA, NA, "fault", "end_of_data"))
  # the same rows in another order of equal-time strokes follow that order
  rev_in <- rally_end_rule(sd[c(3, 1, 2, 4), ])
  expect_equal(rev_in$tag, c("c", "a", "b", "d"))
})
