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

# ---- per-drill limits and the pause rule ----------------------------------

test_that("rally_stroke_threshold() returns each regime's own limit", {
  p <- dq_params()
  expect_equal(rally_stroke_threshold("forehand_cross_court", p), 20)
  expect_equal(rally_stroke_threshold("backhand_cross_court", p), 20)
  expect_equal(rally_stroke_threshold("mini_tennis", p), 50)
  expect_equal(rally_stroke_threshold("net_volley", p), 25)
  # An unlisted regime falls back to `default`; the lookup is vectorised.
  expect_equal(rally_stroke_threshold(c("mixed", "mini_tennis", "gap"), p), c(25, 50, 25))
})

test_that("rally_split_gap_sec() is per regime and NA where no pause split applies", {
  p <- dq_params()
  expect_equal(rally_split_gap_sec("forehand_cross_court", p), 3)
  expect_equal(rally_split_gap_sec("net_volley", p), 2)
  expect_true(is.na(rally_split_gap_sec("mini_tennis", p)))
  expect_equal(rally_split_gap_sec(c("net_volley", "mixed", "backhand_cross_court"), p), c(2, NA, 3))
})

test_that("dq_params() carries the neutral starter-rule parameter", {
  p <- dq_params()
  expect_true(p$split_requires_starter_next)
  expect_named(p, c("max_mean_stroke_speed_kmh", "max_individual_stroke_speed_kmh", "min_segment_duration_min",
                    "max_rally_strokes", "max_stroke_gap_sec", "pause_split_regimes",
                    "split_requires_starter_next"), ignore.order = TRUE)
  expect_setequal(p$pause_split_regimes, c("forehand_cross_court", "backhand_cross_court", "net_volley"))
})

test_that("find_rally_splits() only splits before a starter stroke when is_starter is given", {
  t <- c(0, 1, 6, 7, 12)           # pauses of 1, 5, 1, 5 seconds
  starter <- c(TRUE, FALSE, TRUE, FALSE, FALSE)
  expect_equal(find_rally_splits(t, max_gap_sec = 3), c(2L, 4L))
  # Boundary 4 is followed by a non-starter stroke: not a rally start.
  expect_equal(find_rally_splits(t, max_gap_sec = 3, is_starter = starter), 2L)
  expect_error(find_rally_splits(t, max_gap_sec = 3, is_starter = c(TRUE, FALSE)), "same length")
})

test_that("rally_pause_splits() uses a strict threshold and needs the starter next", {
  # Strokes alternate host, guest, host, guest: the 5 s pause (gap 2) comes
  # before the third stroke, which is the host's -- a rally start.
  r <- mk_rally(c(1, 5, 1), players = c("host", "guest"), regime = "forehand_cross_court")
  expect_equal(rally_pause_splits(r$shots, "forehand_cross_court"), 2L)

  # The same long pause before a "me" (guest) stroke is a missed stroke.
  r2 <- mk_rally(c(5, 1, 1), players = c("host", "guest"), regime = "forehand_cross_court")
  expect_equal(rally_pause_splits(r2$shots, "forehand_cross_court"), integer(0))

  # Strictly greater than: exactly 3 s does not split cross-court, 3.5 s does.
  at <- mk_rally(c(1, 3, 1), regime = "forehand_cross_court")
  over <- mk_rally(c(1, 3.5, 1), regime = "forehand_cross_court")
  expect_equal(rally_pause_splits(at$shots, "forehand_cross_court"), integer(0))
  expect_equal(rally_pause_splits(over$shots, "forehand_cross_court"), 2L)

  # Net-volley uses 2 s.
  nv <- mk_rally(c(1, 2.5, 1), regime = "net_volley")
  expect_equal(rally_pause_splits(nv$shots, "net_volley"), 2L)

  # Mini-tennis (and any unlisted regime) is never pause-split.
  mt <- mk_rally(c(1, 30, 1), regime = "mini_tennis")
  expect_equal(rally_pause_splits(mt$shots, "mini_tennis"), integer(0))

  # The starter rule can be switched off: the pause alone decides.
  p <- dq_params()
  p$split_requires_starter_next <- FALSE
  expect_equal(rally_pause_splits(r2$shots, "forehand_cross_court", p), 1L)
})

test_that("rally_player_strokes() counts only me_side's strokes", {
  r <- mk_rally(rep(1, 9), players = c("host", "guest", "guest"))   # h g g h g g h g g h
  out <- rally_player_strokes(r$rally, r$shots)
  expect_equal(out$me_shots, 6L)
  host <- rally_player_strokes(r$rally, r$shots, me_side = "host")
  expect_equal(host$me_shots, 4L)
  expect_error(rally_player_strokes(r$rally[, c("match_id", "rally_id")], r$shots), "needs")
})

test_that("dq_flag_rallies() applies each drill's limit to me_shots only", {
  rally_for <- function(regime, me) {
    tibble::tibble(match_id = 1L, rally_id = 1L, regime = regime, me_shots = me)
  }
  sp <- tibble::tibble(match_id = 1L, rally_id = 1L, speed_kmh = 30)
  flag <- function(regime, me) dq_flag_rallies(rally_for(regime, me), sp)$flag_reason
  # Cross-court: limit 20 (strictly over).
  expect_true(is.na(flag("forehand_cross_court", 20)))
  expect_match(flag("forehand_cross_court", 21), "strokes")
  expect_match(flag("backhand_cross_court", 32), "strokes")
  # Default regimes: 25. Mini-tennis: 50.
  expect_true(is.na(flag("net_volley", 25)))
  expect_match(flag("net_volley", 26), "strokes")
  expect_true(is.na(flag("mini_tennis", 50)))
  expect_match(flag("mini_tennis", 51), "strokes")
  # The reason names no person.
  expect_false(grepl("[A-Z][a-z]+ strokes", flag("net_volley", 26)))
  expect_error(dq_flag_rallies(tibble::tibble(match_id = 1L, rally_id = 1L, regime = "net_volley"), sp), "me_shots")
})

test_that("a pause before a starter stroke splits a rally and each piece is checked against the limit", {
  # A long pause before a host stroke splits an 82-stroke cross-court rally
  # (limit 20 me-strokes): the over-limit piece is dropped, its sibling kept.
  # (Strokes alternate host, guest, so the 43rd stroke, after the pause, is
  # the host's.) Pieces: 42 strokes (21 me) and 40 strokes (20 me).
  gaps <- c(rep(1, 41), 5, rep(1, 39))
  r <- mk_rally(gaps, regime = "forehand_cross_court")        # 82 strokes
  out <- dq_corrected_rallies(r$rally, r$shots)
  expect_true(all(out$me_shots <= 20))
  expect_equal(out$rally_id, "1_b")                           # the 21-stroke piece is left out

  # A short rally pair separated by a qualifying pause: both kept, ids suffixed.
  gaps2 <- c(rep(1, 11), 5, rep(1, 11))                        # 24 strokes: 12 + 12
  r2 <- mk_rally(gaps2, regime = "forehand_cross_court")
  out2 <- dq_corrected_rallies(r2$rally, r2$shots)
  expect_equal(nrow(out2), 2L)
  expect_equal(out2$rally_id, c("1_a", "1_b"))
  expect_equal(sum(out2$n_shots), 24L)
  expect_true(all(out2$me_shots <= 20))
})

test_that("no row of dq_corrected_rallies() exceeds its limit; me_side mirrors", {
  a <- mk_rally(c(rep(1, 11), 5, rep(1, 11)), regime = "net_volley", rally_id = 1L)
  b <- mk_rally(rep(1, 70), regime = "net_volley", rally_id = 2L)
  r <- bind_rallies(a, b)
  out <- dq_corrected_rallies(r$rally, r$shots)
  expect_true(all(out$me_shots <= rally_stroke_threshold(out$regime)))
  expect_false(2L %in% as.integer(sub("_.*", "", out$rally_id)))   # whole over-limit rally left out

  # Swapping the labels and asking for me_side = "host" gives the same rallies.
  swapped <- r$shots
  swapped$player <- ifelse(swapped$player == "guest", "host", "guest")
  mirrored <- dq_corrected_rallies(r$rally, swapped, me_side = "host", rally_starter = "guest")
  expect_equal(mirrored$rally_id, out$rally_id)
  expect_equal(mirrored$me_shots, out$me_shots)
})

# ---- per-stroke implausible-speed flag ------------------------------------

test_that("one implausible stroke in an otherwise normal rally is flagged", {
  rally <- tibble::tibble(match_id = 1L, rally_id = 1:3, regime = "net_volley", me_shots = 5L)
  sp <- tibble::tibble(
    match_id = 1L, rally_id = 1:3,
    speed_kmh = c(70, 70, 70),          # every mean is plausible
    max_speed_kmh = c(150, 161, 200)    # 160 km/h is the per-stroke limit
  )
  out <- dq_flag_rallies(rally, sp)
  expect_equal(dq_params()$max_individual_stroke_speed_kmh, 160)
  expect_true(is.na(out$flag_reason[1]))
  expect_match(out$flag_reason[2], "individual stroke speed > 160 km/h")
  expect_match(out$flag_reason[3], "individual stroke speed > 160 km/h")
})

test_that("the mean-speed and stroke-count reasons take precedence over the per-stroke one", {
  rally <- tibble::tibble(match_id = 1L, rally_id = 1:2, regime = "net_volley", me_shots = c(5L, 40L))
  sp <- tibble::tibble(match_id = 1L, rally_id = 1:2, speed_kmh = c(120, 70), max_speed_kmh = c(200, 200))
  out <- dq_flag_rallies(rally, sp)
  expect_match(out$flag_reason[1], "mean stroke speed")
  expect_match(out$flag_reason[2], "strokes")
})

test_that("max_speed_kmh is optional: callers without it keep the old behaviour", {
  rally <- tibble::tibble(match_id = 1L, rally_id = 1L, regime = "net_volley", me_shots = 5L)
  sp <- tibble::tibble(match_id = 1L, rally_id = 1L, speed_kmh = 70)
  expect_true(is.na(dq_flag_rallies(rally, sp)$flag_reason))
})

test_that("dq_corrected_rallies() drops a rally holding one implausible stroke", {
  r <- mk_rally(rep(1, 9), players = c("host", "guest"), regime = "net_volley")
  # Mean of the 5 'me' strokes is 48 mph (77 km/h); one stroke is 120 mph (193 km/h).
  r$shots$shot_speed_mph[r$shots$player == "guest"][1] <- 120
  expect_equal(nrow(dq_corrected_rallies(r$rally, r$shots)), 0L)
  # Control: the same rally without the extreme stroke passes through.
  r$shots$shot_speed_mph[] <- 30
  expect_equal(nrow(dq_corrected_rallies(r$rally, r$shots)), 1L)
})

test_that("an over-limit rally that also has a speed artefact: the artefact piece is dropped after the split", {
  # 80 strokes (40 me, over the net-volley limit of 25), one qualifying pause
  # before a feeder stroke: two pieces of 20 me-strokes. The flag reason is
  # "strokes" (it takes precedence), so the speed checks must be re-applied
  # to each piece.
  r <- mk_rally(c(rep(1, 39), 5, rep(1, 39)), regime = "net_volley")
  me <- which(r$shots$player == "guest")
  r$shots$shot_speed_mph[me[1]] <- 120        # 193 km/h, inside piece a
  out <- dq_corrected_rallies(r$rally, r$shots)
  expect_equal(out$rally_id, "1_b")
  expect_true(all(out$speed_kmh < 100))

  # Control: without the artefact both pieces survive.
  r$shots$shot_speed_mph[me[1]] <- 30
  expect_equal(dq_corrected_rallies(r$rally, r$shots)$rally_id, c("1_a", "1_b"))
})

test_that("a split piece whose mean speed is implausible is dropped; its sibling is kept", {
  r <- mk_rally(c(rep(1, 39), 5, rep(1, 39)), regime = "net_volley")
  second <- r$shots$started_at >= min(r$shots$started_at) + 39 + 5
  # 65 mph = 104.6 km/h mean in piece b only (no stroke over 160 km/h).
  r$shots$shot_speed_mph[second & r$shots$player == "guest"] <- 65
  out <- dq_corrected_rallies(r$rally, r$shots)
  expect_equal(out$rally_id, "1_a")
})

# ---- the "N of M rallies excluded" count -----------------------------------

test_that("dq_excluded_count() is never negative when a flagged rally splits into survivors", {
  # 80 strokes (40 me, over the net-volley limit of 25) with one qualifying
  # pause before a feeder stroke: two pieces of 20 me-strokes, both kept.
  r <- mk_rally(c(rep(1, 39), 5, rep(1, 39)), regime = "net_volley")
  corrected <- dq_corrected_rallies(r$rally, r$shots)
  expect_equal(nrow(corrected), 2L)

  flagged <- dq_flag_rallies(
    rally_with_counts(r),
    tibble::tibble(match_id = 1L, rally_id = 1L, speed_kmh = 30)
  )
  expect_equal(sum(!is.na(flagged$flag_reason)), 1L)
  # The row-count difference the count replaces: it goes negative here.
  expect_lt(sum(!is.na(flagged$flag_reason)) - nrow(corrected), 0L)
  expect_equal(dq_excluded_count(flagged), 1L)
  expect_gte(dq_excluded_count(flagged), 0L)
})

test_that("dq_excluded_count() counts raw flagged rallies and validates its input", {
  f <- tibble::tibble(rally_id = 1:4, flag_reason = c(NA, "rally > 25 strokes (drill limit)", NA, "mean stroke speed > 100 km/h"))
  expect_equal(dq_excluded_count(f), 2L)
  expect_equal(dq_excluded_count(f[0, ]), 0L)
  expect_error(dq_excluded_count(tibble::tibble(rally_id = 1L)), "flag_reason")
})
