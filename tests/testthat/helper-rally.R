# Small constructors for hand-built rally fixtures (no real data).
#
# `mk_rally()` returns one rally as list(rally = <1-row tibble shaped like
# tennis_rallies()>, shots = <tibble shaped like tennis_shot_detail()>).
# `gaps` are the pauses (seconds) between consecutive strokes, so a rally of
# n strokes takes n - 1 gaps; `players` is recycled to length n.
mk_rally <- function(gaps, players = c("host", "guest"), regime = "net_volley",
                     match_id = 1L, rally_id = 1L, speed_mph = 30,
                     t0 = as.POSIXct("2000-01-01 10:00:00", tz = "UTC")) {
  n <- length(gaps) + 1L
  started <- t0 + c(0, cumsum(gaps))
  shots <- tibble::tibble(
    match_id = match_id, shot_id = seq_len(n), rally_id = rally_id,
    player = rep_len(players, n), started_at = started,
    shot_speed_mph = speed_mph
  )
  rally <- tibble::tibble(
    match_id = match_id, rally_id = rally_id, regime = regime,
    regime_occurrence = 1L, segment_index = 1L, n_shots = n,
    duration_sec = as.numeric(difftime(max(started), min(started), units = "secs")),
    start_time = min(started), end_time = max(started)
  )
  list(rally = rally, shots = shots)
}

# Bind several mk_rally() results (give each a distinct rally_id).
bind_rallies <- function(...) {
  parts <- list(...)
  list(
    rally = dplyr::bind_rows(lapply(parts, `[[`, "rally")),
    shots = dplyr::bind_rows(lapply(parts, `[[`, "shots"))
  )
}

# The rally row with a `me_shots` column (strokes by `me_side`), for callers
# that need it before dq_corrected_rallies() computes it itself.
rally_with_counts <- function(r, me_side = "guest") {
  r$rally$me_shots <- sum(r$shots$player == me_side)
  r$rally
}
