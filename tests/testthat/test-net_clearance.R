# Net-clearance metric (rallyr#22). Synthetic rows only.

clr <- function(match_id, regime, player, m) {
  tibble::tibble(
    match_id = match_id, regime = regime, player = player, net_clearance_m = m
  )
}

test_that("dq_params() carries a clearance plausibility range (#22)", {
  p <- dq_params()
  expect_true(is.numeric(p$min_net_clearance_m) && length(p$min_net_clearance_m) == 1L)
  expect_true(is.numeric(p$max_net_clearance_m) && length(p$max_net_clearance_m) == 1L)
  expect_lt(p$min_net_clearance_m, p$max_net_clearance_m)
})

test_that("implausible clearances are nulled and flagged; the row stays (#22)", {
  sd <- clr(1, "forehand_cross_court", "guest", c(0.5, 1.2, 99, -40, NA, Inf))
  out <- dq_clean_net_clearance(sd)
  expect_equal(nrow(out), nrow(sd))
  expect_equal(out$net_clearance_m, c(0.5, 1.2, NA, NA, NA, NA))
  expect_equal(out$net_clearance_implausible, c(FALSE, FALSE, TRUE, TRUE, FALSE, TRUE))
  expect_false(anyNA(out$net_clearance_implausible))
})

test_that("the threshold comes from params, and a tighter one flags more (#22)", {
  sd <- clr(1, "forehand_cross_court", "guest", c(0.5, 1.2, 2.5))
  p <- dq_params()
  p$max_net_clearance_m <- 2
  out <- dq_clean_net_clearance(sd, p)
  expect_equal(out$net_clearance_implausible, c(FALSE, FALSE, TRUE))
})

test_that("a missing column is a clear error (#22)", {
  expect_error(dq_clean_net_clearance(tibble::tibble(a = 1)), "net_clearance_m")
})

test_that("per-session-per-drill summary uses the median and counts n (#22)", {
  sd <- dplyr::bind_rows(
    # me: median of 0.4, 0.6, 5.0 is 0.6 (a mean would be dragged up)
    clr(1, "forehand_cross_court", "guest", c(0.4, 0.6, 5.0)),
    clr(1, "forehand_cross_court", "host", c(0.8, 1.0)),
    clr(1, "net_volley", "guest", c(0.3)),
    clr(2, "forehand_cross_court", "guest", c(0.5, 0.7))
  )
  out <- session_net_clearance_by_drill(sd)
  r1 <- out[out$match_id == 1 & out$regime == "forehand_cross_court", ]
  expect_equal(r1$me_median_m, 0.6)
  expect_equal(r1$me_n, 3L)
  expect_equal(r1$opp_median_m, 0.9)
  expect_equal(r1$opp_n, 2L)
  expect_equal(r1$diff_m, 0.6 - 0.9)
  # a drill where the feeder has no values: difference is NA, not 0
  r2 <- out[out$match_id == 1 & out$regime == "net_volley", ]
  expect_equal(r2$opp_n, 0L)
  expect_true(is.na(r2$opp_median_m))
  expect_true(is.na(r2$diff_m))
  # a session with no feeder strokes at all keeps its row
  expect_equal(sum(out$match_id == 2), 1L)
  expect_named(out, c(
    "match_id", "regime", "me_median_m", "me_n", "opp_median_m", "opp_n",
    "diff_m", "n_implausible"
  ))
})

test_that("implausible values are cleaned before summarising and counted (#22)", {
  sd <- clr(1, "forehand_cross_court", c("guest", "guest", "guest", "host"), c(0.5, 0.7, 99, 1))
  out <- session_net_clearance_by_drill(sd)
  expect_equal(out$me_median_m, 0.6)
  expect_equal(out$me_n, 2L)
  expect_equal(out$n_implausible, 1L)
})

test_that("rows with no regime are left out of the drill summary (#22)", {
  sd <- clr(1, c(NA, "net_volley"), "guest", c(0.5, 0.6))
  out <- session_net_clearance_by_drill(sd)
  expect_equal(out$regime, "net_volley")
})
