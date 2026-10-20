# The stroke limit only flags: it never force-splits a rally.

# 60 strokes one second apart in net-volley: no pause anywhere, and well over
# every stroke limit.
over_limit_whole <- function() mk_rally(rep(1, 59), regime = "net_volley")

test_that("an over-limit rally with no qualifying pause is flagged and left whole", {
  r <- over_limit_whole()
  p <- dq_params()
  rallies <- rally_with_counts(r)
  flagged <- dq_flag_rallies(rallies, tibble::tibble(match_id = 1L, rally_id = 1L, speed_kmh = 30))
  expect_match(flagged$flag_reason, "strokes")

  proposal <- split_flagged_rallies(flagged, r$shots, p)
  expect_equal(nrow(proposal), 1L)
  expect_false(proposal$split)
  expect_true(proposal$still_flagged)
  expect_equal(proposal$split_method, "none")
  expect_equal(proposal$new_rally_id, "1")

  corrected <- dq_corrected_rallies(r$rally, r$shots, p)
  expect_equal(nrow(corrected), 0L)
})

test_that("force_splits_until_under() no longer exists", {
  expect_false(exists("force_splits_until_under", envir = asNamespace("rallyr")))
})
