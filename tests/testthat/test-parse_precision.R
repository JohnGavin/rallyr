# Parsing precision: timestamps keep their fractional seconds (rallyr#14).

test_that("sv_time() keeps millisecond precision (#14)", {
  t1 <- sv_time("2000-01-01T10:00:00.742000Z")
  t0 <- sv_time("2000-01-01T10:00:00Z")
  expect_equal(as.numeric(t1) - as.numeric(t0), 0.742, tolerance = 1e-6)
  expect_equal(as.numeric(sv_time("2000-01-01T10:00:00.5Z")) - as.numeric(t0), 0.5, tolerance = 1e-6)
  expect_true(is.na(sv_time(NULL)))
})

test_that("sv_parse_shots() inter-stroke gaps are not whole seconds (#14)", {
  shots <- list(
    list(id = 1, match_id = 1, pid = 1, started_at = "2000-01-01T10:00:00.250000Z"),
    list(id = 2, match_id = 1, pid = 1, started_at = "2000-01-01T10:00:01.900000Z")
  )
  out <- sv_parse_shots(shots)
  gap <- as.numeric(diff(out$started_at), units = "secs")
  expect_equal(gap, 1.65, tolerance = 1e-6)
})
