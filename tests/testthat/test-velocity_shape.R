mk_vel <- function(x, y, z, hit_type = "forehand", player = "guest") {
  tibble::tibble(
    hit_type = hit_type, player = player,
    hit_velocity_x = x, hit_velocity_y = y, hit_velocity_z = z
  )
}

test_that("equal components are replicated; distinct ones are not", {
  s <- mk_vel(c(5, 5, 7, 1), c(5, 6, 7, 2), c(5, 5, 7, 3))
  out <- dq_velocity_shape_rates(s, by = character(0), min_usable = 1)
  expect_equal(out$n_strokes, 4L)
  expect_equal(out$n_usable, 4L)
  expect_equal(out$n_replicated, 2L)
  expect_equal(out$replicated_rate, 0.5)
  expect_equal(out$status, "PRESENT")
})

test_that("the tolerance decides near-equal components", {
  s <- mk_vel(c(5, 5), c(5.0000001, 5.1), c(5, 5))
  expect_equal(dq_velocity_shape_rates(s, by = character(0), min_usable = 1)$n_replicated, 1L)
  expect_equal(dq_velocity_shape_rates(s, by = character(0), tol = 0.5, min_usable = 1)$n_replicated, 2L)
})

test_that("rates are reported per group", {
  s <- dplyr::bind_rows(
    mk_vel(c(5, 6), c(5, 7), c(5, 8), hit_type = "forehand"),
    mk_vel(c(1, 2), c(3, 4), c(5, 6), hit_type = "volley")
  )
  out <- dq_velocity_shape_rates(s, by = "hit_type", min_usable = 1)
  expect_equal(out$hit_type, c("forehand", "volley"))
  expect_equal(out$n_replicated, c(1L, 0L))
  expect_equal(out$status, c("PRESENT", "ABSENT"))
})

test_that("strokes with a missing component are unusable, not replicated", {
  s <- mk_vel(c(5, NA), c(5, 5), c(5, 5))
  out <- dq_velocity_shape_rates(s, by = character(0), min_usable = 1)
  expect_equal(out$n_strokes, 2L)
  expect_equal(out$n_usable, 1L)
  expect_equal(out$n_replicated, 1L)
})

test_that("too few usable strokes is INDETERMINATE, with a reason, never ABSENT", {
  s <- mk_vel(c(1, 2), c(3, 4), c(5, 6))
  out <- dq_velocity_shape_rates(s, by = character(0), min_usable = 10)
  expect_equal(out$status, "INDETERMINATE")
  expect_match(out$reason, "2 usable")
  expect_equal(out$replicated_rate, 0)
  none <- mk_vel(NA_real_, NA_real_, NA_real_)
  expect_equal(dq_velocity_shape_rates(none, by = character(0))$status, "INDETERMINATE")
})

test_that("empty input and missing columns", {
  expect_equal(nrow(dq_velocity_shape_rates(mk_vel(numeric(0), numeric(0), numeric(0)))), 0L)
  expect_error(dq_velocity_shape_rates(tibble::tibble(hit_type = "a")), "hit_velocity_x")
  expect_error(dq_velocity_shape_rates(mk_vel(1, 1, 1), by = "nope"), "nope")
  expect_error(dq_velocity_shape_rates(mk_vel(1, 1, 1), tol = -1), "tol")
})

test_that("non-finite components are unusable and never give an NA status", {
  s <- mk_vel(c(5, Inf, 1), c(5, Inf, 2), c(5, Inf, 3))
  out <- dq_velocity_shape_rates(s, by = character(0), min_usable = 1)
  expect_equal(out$n_strokes, 3L)
  expect_equal(out$n_usable, 2L)
  expect_equal(out$n_replicated, 1L)
  expect_false(anyNA(out$status))
  expect_true(out$status %in% c("PRESENT", "ABSENT", "INDETERMINATE"))
  inf_only <- mk_vel(Inf, -Inf, 1)
  res <- dq_velocity_shape_rates(inf_only, by = character(0), min_usable = 1)
  expect_equal(res$status, "INDETERMINATE")
})

test_that("min_usable must be a single positive whole number", {
  s <- mk_vel(1, 1, 1)
  for (bad in list(0, -1, NA, 1.5, c(1, 2), "a", NULL)) {
    expect_error(dq_velocity_shape_rates(s, min_usable = bad), "min_usable")
  }
})
