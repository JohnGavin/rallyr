mk_corrected <- function() {
  tibble::tibble(
    match_id = c(1L, 1L, 1L, 1L, 2L),
    rally_id = c("1", "2", "3_a", "3_b", "1"),
    regime = c("net_volley", "net_volley", "net_volley", "net_volley", "forehand_cross_court"),
    n_shots = c(1L, 5L, 1L, 4L, 6L)
  )
}

test_that("single-stroke rallies are counted per match and drill, not dropped", {
  out <- dq_single_stroke_rallies(mk_corrected())
  nv <- out[out$match_id == 1L, ]
  expect_equal(nv$n_rallies, 4L)
  expect_equal(nv$n_single_stroke, 2L)
  expect_equal(nv$single_stroke_pct, 50)
  fc <- out[out$match_id == 2L, ]
  expect_equal(fc$n_single_stroke, 0L)
  expect_equal(fc$single_stroke_pct, 0)
})

test_that("the input is not filtered: n_rallies covers every row", {
  d <- mk_corrected()
  expect_equal(sum(dq_single_stroke_rallies(d)$n_rallies), nrow(d))
})

test_that("an empty input gives a typed zero-row table", {
  out <- dq_single_stroke_rallies(mk_corrected()[0, ])
  expect_equal(nrow(out), 0L)
  expect_true("n_single_stroke" %in% names(out))
})

test_that("missing columns are an error", {
  expect_error(dq_single_stroke_rallies(tibble::tibble(match_id = 1L)), "n_shots")
})
