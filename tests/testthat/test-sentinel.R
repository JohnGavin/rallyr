# Sentinel sensor values are nulled, never dropped (rallyr#30).

test_that("dq_null_sentinel() nulls listed values within tol and keeps every row (#30)", {
  d <- tibble::tibble(id = 1:6, v = c(10, 99.9, 99.96, 20, NA, 99.5))
  out <- dq_null_sentinel(d, "v", values = 99.9, tol = 0.1)
  expect_equal(nrow(out), nrow(d))
  expect_equal(out$v, c(10, NA, NA, 20, NA, 99.5))
  expect_equal(out$v_sentinel, c(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE))
  expect_equal(out$id, d$id)
})

test_that("dq_null_sentinel() supports several sentinels, a custom flag and no-ops (#30)", {
  d <- tibble::tibble(v = c(1, 2, 3, 4))
  out <- dq_null_sentinel(d, "v", values = c(2, 4), flag_col = "bad")
  expect_equal(out$v, c(1, NA, 3, NA))
  expect_equal(out$bad, c(FALSE, TRUE, FALSE, TRUE))
  none <- dq_null_sentinel(d, "v", values = numeric(0))
  expect_equal(none$v, d$v)
  expect_false(any(none$v_sentinel))
})

test_that("dq_null_sentinel() rejects a missing field instead of passing silently (#30)", {
  expect_error(dq_null_sentinel(tibble::tibble(v = 1), "nope", values = 1), "nope")
})

test_that("dq_params() lists the sentinel shot speeds (#30)", {
  expect_true(is.numeric(dq_params()$sentinel_shot_speeds_mph))
  expect_gte(length(dq_params()$sentinel_shot_speeds_mph), 1L)
})

test_that("dq_clean_shot_speed() nulls the params' sentinel speeds only (#30)", {
  s <- dq_params()$sentinel_shot_speeds_mph[1]
  d <- tibble::tibble(shot_speed_mph = c(30, s, 31))
  out <- dq_clean_shot_speed(d)
  expect_equal(out$shot_speed_mph, c(30, NA, 31))
  expect_equal(out$shot_speed_sentinel, c(FALSE, TRUE, FALSE))
  custom <- dq_clean_shot_speed(d, params = list(sentinel_shot_speeds_mph = numeric(0)))
  expect_equal(custom$shot_speed_mph, d$shot_speed_mph)
})

test_that("a sentinel stroke does not drag a rally's speed or drop its stroke (#30)", {
  s <- dq_params()$sentinel_shot_speeds_mph[1]
  r <- mk_rally(rep(1, 5), players = "guest", regime = "mini_tennis")
  r$shots$shot_speed_mph <- c(30, 30, s, 30, 30, 30)
  out <- dq_corrected_rallies(r$rally, r$shots)
  expect_equal(nrow(out), 1L)
  expect_equal(out$speed_kmh, 30 * 1.609344, tolerance = 1e-6)
  expect_equal(out$me_shots, 6L)
})
