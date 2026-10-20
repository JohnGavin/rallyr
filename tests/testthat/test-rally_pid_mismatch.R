fixture_pid <- function() {
  # Same match, net-volley drill (2 s pause rule, host starts rallies):
  #   1: untouched; 2: one pause before a host stroke -> split in two;
  #   3: 61 strokes, ~30 by the guest, no pause -> over the 25-stroke limit,
  #      dropped.
  bind_rallies(
    mk_rally(c(1, 1, 1), rally_id = 1L),
    mk_rally(c(1, 5, 1, 1), rally_id = 2L),
    mk_rally(rep(1, 60), rally_id = 3L)
  )
}

test_that("rally_pid_mismatch() counts unchanged, split and dropped groups", {
  f <- fixture_pid()
  out <- rally_pid_mismatch(f$rally, f$shots)
  expect_equal(nrow(out), 1L)
  expect_equal(out$regime, "net_volley")
  expect_equal(out$n_pid_groups, 3L)
  expect_equal(out$n_unchanged, 1L)
  expect_equal(out$n_split, 1L)
  expect_equal(out$n_dropped, 1L)
  expect_equal(out$extra_subrallies, 1L)
  expect_equal(out$disagreement_count, 2L)
  expect_equal(out$disagreement_pct, 66.7)
})

test_that("rows are ranked by disagreement, largest first", {
  a <- fixture_pid()
  b <- bind_rallies(
    mk_rally(c(1, 1, 1), rally_id = 1L, match_id = 2L),
    mk_rally(c(1, 1, 1), rally_id = 2L, match_id = 2L)
  )
  both <- bind_rallies(a, b)
  out <- rally_pid_mismatch(both$rally, both$shots)
  expect_equal(out$match_id, c(1L, 2L))
  expect_equal(out$disagreement_count, c(2L, 0L))
  expect_false(is.unsorted(rev(out$disagreement_count)))
})

test_that("an agreeing dataset reports zero disagreement, not an error", {
  b <- bind_rallies(mk_rally(c(1, 1, 1), rally_id = 1L))
  out <- rally_pid_mismatch(b$rally, b$shots)
  expect_equal(out$disagreement_count, 0L)
  expect_equal(out$disagreement_pct, 0)
})

test_that("a sub-rally id with a letter suffix maps back to its group", {
  f <- bind_rallies(mk_rally(c(1, 5, 1, 5, 1), rally_id = 7L))
  out <- rally_pid_mismatch(f$rally, f$shots)
  expect_equal(out$n_split, 1L)
  expect_equal(out$extra_subrallies, 2L)
})

test_that("an empty input returns a typed zero-row table", {
  f <- fixture_pid()
  out <- rally_pid_mismatch(f$rally[0, ], f$shots[0, ])
  expect_equal(nrow(out), 0L)
  expect_true(all(c("match_id", "regime", "disagreement_count") %in% names(out)))
})

test_that("missing columns are an error", {
  f <- fixture_pid()
  expect_error(rally_pid_mismatch(f$rally[, "match_id"], f$shots), "regime")
})

test_that("a split group whose siblings are partly dropped is still a split", {
  # 60 strokes (30 by the guest, over the 25 limit) | pause | 3 strokes.
  # The pause rule makes two pieces; only the short one survives the limit.
  f <- bind_rallies(mk_rally(c(rep(1, 59), 5, 1, 1), rally_id = 1L))
  out <- rally_pid_mismatch(f$rally, f$shots)
  expect_equal(out$n_unchanged, 0L)
  expect_equal(out$n_split, 1L)
  expect_equal(out$n_dropped, 0L)
  expect_equal(out$extra_subrallies, 1L)
})

test_that("a vendor id that itself ends in _<letter> is not mangled", {
  f <- bind_rallies(mk_rally(c(1, 1, 1), rally_id = "p_a"))
  out <- rally_pid_mismatch(f$rally, f$shots)
  expect_equal(out$n_unchanged, 1L)
  expect_equal(out$n_dropped, 0L)
})

test_that("a group split into more than 26 pieces is counted once", {
  f <- bind_rallies(mk_rally(c(rep(c(1, 5), 27), 1), rally_id = 1L))
  out <- rally_pid_mismatch(f$rally, f$shots)
  expect_equal(out$n_pid_groups, 1L)
  expect_equal(out$n_split, 1L)
  expect_equal(out$extra_subrallies, 27L)
})
