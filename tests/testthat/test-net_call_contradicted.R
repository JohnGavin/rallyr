mk_calls <- function(player, shot_in, gap = 1, rally_id = 1L, match_id = 1L) {
  n <- length(player)
  tibble::tibble(
    match_id = match_id, rally_id = rally_id, player = player,
    started_at = as.POSIXct("2000-01-01 10:00:00", tz = "UTC") + (seq_len(n) - 1) * gap,
    shot_in = shot_in
  )
}

test_that("an out call followed by the other side's stroke is contradicted", {
  s <- mk_calls(c("host", "guest", "host", "guest"), c(TRUE, FALSE, TRUE, TRUE))
  out <- flag_net_call_contradicted(s)
  expect_equal(out$net_call_contradicted, c(FALSE, TRUE, FALSE, FALSE))
})

test_that("an out call that ends the rally is not contradicted", {
  s <- mk_calls(c("host", "guest", "host"), c(TRUE, TRUE, FALSE))
  expect_equal(flag_net_call_contradicted(s)$net_call_contradicted,
               c(FALSE, FALSE, FALSE))
})

test_that("a next stroke by the same side does not contradict the call", {
  s <- mk_calls(c("host", "host"), c(FALSE, TRUE))
  expect_false(flag_net_call_contradicted(s)$net_call_contradicted[1])
})

test_that("only the next stroke in the same rally and match counts", {
  s <- dplyr::bind_rows(
    mk_calls("host", FALSE, rally_id = 1L),
    mk_calls("guest", TRUE, rally_id = 2L)
  )
  expect_false(any(flag_net_call_contradicted(s)$net_call_contradicted))
  m <- dplyr::bind_rows(
    mk_calls("host", FALSE, match_id = 1L),
    mk_calls("guest", TRUE, match_id = 2L)
  )
  expect_false(any(flag_net_call_contradicted(m)$net_call_contradicted))
})

test_that("max_gap_sec ignores a next stroke after a long pause", {
  s <- mk_calls(c("host", "guest"), c(FALSE, TRUE), gap = 30)
  expect_true(flag_net_call_contradicted(s)$net_call_contradicted[1])
  expect_false(flag_net_call_contradicted(s, max_gap_sec = 10)$net_call_contradicted[1])
})

test_that("row order is preserved and shot_in is left untouched", {
  s <- mk_calls(c("host", "guest", "host"), c(FALSE, TRUE, TRUE))
  shuffled <- s[c(3, 1, 2), ]
  out <- flag_net_call_contradicted(shuffled)
  expect_equal(out$started_at, shuffled$started_at)
  expect_equal(out$shot_in, shuffled$shot_in)
  expect_equal(out$net_call_contradicted, c(FALSE, TRUE, FALSE))
})

test_that("an NA call is not flagged (unknown is not a contradiction)", {
  s <- mk_calls(c("host", "guest"), c(NA, TRUE))
  expect_false(flag_net_call_contradicted(s)$net_call_contradicted[1])
})

test_that("missing columns are an error", {
  expect_error(flag_net_call_contradicted(tibble::tibble(rally_id = 1)), "player")
})

test_that("sv_shot_in() itself is unchanged: a net contact is still out", {
  expect_false(rallyr:::sv_shot_in("net", "in", "in"))
  expect_true(rallyr:::sv_shot_in("none", "in", "in"))
})
