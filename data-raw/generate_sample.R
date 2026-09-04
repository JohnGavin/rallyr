#!/usr/bin/env Rscript

# Generates FAKE match/shot/session data shaped like rallyr's own DuckDB
# schema and writes it to a fresh local file, inst/extdata/synthetic_sample.duckdb
# -- this script never reads any real session data, because rallyr ships no
# real data at all (this is a public template package; see README.md).
#
# Every value here is drawn from a plausible RANDOM distribution chosen by
# hand and documented below -- not fitted or derived from anyone's real
# sessions. This generator only ever consults its own hardcoded ranges (see
# the phase list in `.synthetic_shots_for_match()` below) and this package's
# own PUBLIC documentation of the SwingVision payload shape
# (R/fetch_swingvision.R's sv_parse_match()/sv_parse_shots() column
# contracts).
#
# Ranges chosen (all hand-picked, not fitted):
#   - stroke speed: ground strokes 25-65 mph, volleys 15-35 mph -- plausible
#     club-level hitting-practice speeds
#   - rally length: 2-14 shots typical, occasional short outlier
#   - session duration: 25-70 minutes
#   - shots-in rate: 65-90%
#   - ambient weather: 5-25 degC, 0-25 km/h wind -- a plausible temperate
#     range across a year, not fitted to any specific real session
#
# Session structure mirrors the example drill-phase scheme documented in
# R/segment_shots.R's header (mini_tennis -> net_volley -> forehand
# cross-court -> backhand cross-court -> net_volley) -- one worked example
# of a training-drill structure, not a claim that every user's sessions
# look like this.
#
# Usage (from the rallyr package root):
#   Rscript data-raw/generate_sample.R
#
# See tests/testthat/test-generate_sample.R for the validation that this
# output is structurally plausible SwingVision-shaped data (passes
# segment_session_shots() without erroring).

.args <- commandArgs(trailingOnly = FALSE)
.self <- sub("^--file=", "", .args[grep("^--file=", .args)])
if (length(.self) == 1L && nzchar(.self)) {
  setwd(normalizePath(file.path(dirname(.self), "..")))
}

if (identical(Sys.getenv("SYNTHETIC_SAMPLE_SKIP_LOAD"), "")) {
  pkgload::load_all(quiet = TRUE)
}

#' Generate one match's worth of synthetic per-shot data
#'
#' Builds shots for the five documented drill phases in sequence, each
#' phase's shot characteristics chosen so [segment_session_shots()] can
#' actually detect it (matching the thresholds documented in its own
#' roxygen header) -- this is what makes the output "structurally
#' plausible" rather than merely schema-shaped.
#'
#' @param match_id Synthetic match id.
#' @param session_start POSIXct start time for the first shot.
#' @param rng A seeded `local({...})` RNG scope is assumed by the caller;
#'   this function just calls `sample()`/`runif()` etc. directly.
#' @return A tibble matching [sv_parse_shots()]'s column contract.
#' @keywords internal
.synthetic_shots_for_match <- function(match_id, session_start) {
  phases <- list(
    list(regime = "mini_tennis",           minutes = 4, host_volley = 0.02, guest_speed = c(20, 32), guest_right_frac = 0.5),
    list(regime = "net_volley",             minutes = 5, host_volley = 0.75, guest_speed = c(35, 55), guest_right_frac = 0.5),
    list(regime = "forehand_cross_court",   minutes = 6, host_volley = 0.05, guest_speed = c(40, 62), guest_right_frac = 0.92),
    list(regime = "backhand_cross_court",   minutes = 6, host_volley = 0.05, guest_speed = c(38, 58), guest_right_frac = 0.08),
    list(regime = "net_volley",             minutes = 4, host_volley = 0.70, guest_speed = c(35, 55), guest_right_frac = 0.5)
  )

  shot_id_ctr <- 0L
  rally_id_ctr <- 0L
  t_cursor <- session_start
  rows <- vector("list", length(phases))

  for (i in seq_along(phases)) {
    ph <- phases[[i]]
    n_shots <- max(20L, round(ph$minutes * stats::runif(1, 14, 22)))  # ~14-22 shots/min of play
    phase_rows <- vector("list", n_shots)
    shots_since_rally <- 0L
    rally_id_ctr <- rally_id_ctr + 1L

    for (j in seq_len(n_shots)) {
      shot_id_ctr <- shot_id_ctr + 1L
      player <- if (j %% 2L == 1L) "guest" else "host"
      is_volley <- (player == "host") && (stats::runif(1) < ph$host_volley)
      hit_type <- if (is_volley) "volley" else "ground_stroke"
      if (player == "guest" && hit_type == "ground_stroke") {
        hit_wing <- if (stats::runif(1) < ph$guest_right_frac) "right" else "left"
        speed <- stats::runif(1, ph$guest_speed[1], ph$guest_speed[2])
      } else if (hit_type == "volley") {
        hit_wing <- sample(c("left", "right"), 1L)
        speed <- stats::runif(1, 15, 35)
      } else {
        hit_wing <- sample(c("left", "right"), 1L)
        speed <- stats::runif(1, 25, 60)
      }
      spin_type <- sample(c("flat", "topspin", "slice"), 1L, prob = c(0.3, 0.5, 0.2))
      dur <- stats::runif(1, 0.3, 1.0)
      started_at <- t_cursor
      ended_at <- t_cursor + dur
      t_cursor <- t_cursor + stats::runif(1, 1.0, 3.5)

      shots_since_rally <- shots_since_rally + 1L
      if (shots_since_rally >= sample(2:10, 1L)) {
        rally_id_ctr <- rally_id_ctr + 1L
        shots_since_rally <- 0L
      }

      phase_rows[[j]] <- tibble::tibble(
        match_id       = match_id,
        shot_id        = shot_id_ctr,
        rally_id       = rally_id_ctr,
        player         = player,
        started_at     = started_at,
        ended_at       = ended_at,
        hit_wing       = hit_wing,
        hit_type       = hit_type,
        spin_type      = spin_type,
        shot_speed_mph = round(speed, 1),
        shot_in        = stats::runif(1) < 0.80
      )
    }
    rows[[i]] <- dplyr::bind_rows(phase_rows)
    # A short "gap" between phases -- a real break in play, mirroring the
    # session structure R/segment_shots.R's header documents.
    t_cursor <- t_cursor + stats::runif(1, 45, 90)
  }

  dplyr::bind_rows(rows) |> dplyr::arrange(started_at)
}

#' Derive shot_segments/shot_detail/rallies for one match, using the same
#' exported [segment_session_shots()] a real caller would use, rather than
#' duplicating its detection logic.
#' @keywords internal
.derive_segments <- function(shots) {
  segs <- segment_session_shots(shots)
  segs <- segs |>
    dplyr::group_by(regime) |>
    dplyr::mutate(regime_occurrence = match(segment_index, sort(unique(segment_index)))) |>
    dplyr::ungroup() |>
    as.data.frame()

  seg_idx <- findInterval(shots$started_at, segs$start_time)
  shots$segment_index <- pmax(seg_idx, 1L)
  shots$regime <- segs$regime[shots$segment_index]
  shots$regime_occurrence <- segs$regime_occurrence[shots$segment_index]

  wing_counts <- shots |>
    dplyr::filter(player == "guest", hit_type == "ground_stroke", hit_wing %in% c("left", "right")) |>
    dplyr::group_by(segment_index) |>
    dplyr::summarise(
      n_guest_gs_left  = sum(hit_wing == "left"),
      n_guest_gs_right = sum(hit_wing == "right"),
      .groups = "drop"
    )
  guest_stats <- shots |>
    dplyr::filter(player == "guest") |>
    dplyr::group_by(segment_index) |>
    dplyr::summarise(
      guest_speed_mean_mph   = round(mean(shot_speed_mph, na.rm = TRUE), 1),
      guest_speed_median_mph = round(stats::median(shot_speed_mph, na.rm = TRUE), 1),
      guest_in_pct           = round(100 * mean(shot_in), 1),
      .groups = "drop"
    )
  segs <- segs |>
    dplyr::left_join(wing_counts, by = "segment_index") |>
    dplyr::left_join(guest_stats, by = "segment_index")
  segs$n_guest_gs_left  <- ifelse(is.na(segs$n_guest_gs_left),  0L, segs$n_guest_gs_left)
  segs$n_guest_gs_right <- ifelse(is.na(segs$n_guest_gs_right), 0L, segs$n_guest_gs_right)
  segs$match_id <- shots$match_id[1]

  shot_rows <- shots[, c(
    "match_id", "shot_id", "rally_id", "player", "started_at", "hit_type", "hit_wing", "spin_type",
    "shot_speed_mph", "shot_in", "segment_index", "regime", "regime_occurrence"
  )]

  mode_num <- function(x) as.numeric(names(sort(table(x), decreasing = TRUE))[1])
  rallies <- shots |>
    dplyr::filter(!is.na(rally_id)) |>
    dplyr::group_by(rally_id) |>
    dplyr::summarise(
      start_time    = min(started_at),
      end_time      = max(ended_at),
      duration_sec  = pmax(0, round(as.numeric(difftime(max(ended_at), min(started_at), units = "secs")), 1)),
      n_shots       = dplyr::n(),
      segment_index = mode_num(segment_index),
      .groups = "drop"
    ) |>
    dplyr::left_join(dplyr::select(segs, segment_index, regime, regime_occurrence), by = "segment_index")
  rallies$match_id <- shots$match_id[1]

  list(segs = segs, shots = shot_rows, rallies = rallies)
}

#' Generate a full synthetic dataset: matches, shot_segments, shot_detail,
#' rallies, session_weather -- matching the real `tennis.duckdb` schema
#' (see [tennis_db_schema()]).
#'
#' @param n_sessions Number of synthetic sessions to generate.
#' @param seed RNG seed, for reproducibility of the synthetic set only.
#' @return A named list of tibbles: `matches`, `shot_segments`,
#'   `shot_detail`, `rallies`, `session_weather`.
#' @note This lives in `scripts/`, not `R/`, so roxygen2 never collates it —
#'   these functions are script-local helpers, not part of the `tennis`
#'   package NAMESPACE.
generate_synthetic_sample <- function(n_sessions = 6, seed = 20260903) {
  withr::local_seed(seed)

  base_date <- as.Date("2030-01-05")  # arbitrary far-future anchor, never a real session date
  match_ids <- 9000000L + seq_len(n_sessions)

  matches_rows    <- vector("list", n_sessions)
  segs_rows       <- vector("list", n_sessions)
  shots_rows      <- vector("list", n_sessions)
  rallies_rows    <- vector("list", n_sessions)
  weather_rows    <- vector("list", n_sessions)

  locations <- c("Sample Tennis Club (synthetic)", "Sample Sports Centre (synthetic)")

  for (i in seq_len(n_sessions)) {
    match_id <- match_ids[i]
    session_date <- base_date + (i - 1L) * 7L
    start_hour <- sample(9:18, 1L)
    session_start <- as.POSIXct(
      paste(session_date, sprintf("%02d:00:00", start_hour)),
      tz = "UTC"
    )

    shots <- .synthetic_shots_for_match(match_id, session_start)
    derived <- .derive_segments(shots)
    segs_rows[[i]]  <- derived$segs
    shots_rows[[i]] <- derived$shots
    rallies_rows[[i]] <- derived$rallies

    duration_min <- as.integer(round(as.numeric(
      difftime(max(shots$ended_at), min(shots$started_at), units = "mins")
    )))
    guest_shots <- shots[shots$player == "guest", ]
    host_shots  <- shots[shots$player == "host", ]
    guest_in    <- sum(guest_shots$shot_in)
    fh <- guest_shots[guest_shots$hit_type == "ground_stroke" & guest_shots$hit_wing == "right", ]
    bh <- guest_shots[guest_shots$hit_type == "ground_stroke" & guest_shots$hit_wing == "left", ]

    matches_rows[[i]] <- tibble::tibble(
      match_id      = match_id,
      share_token   = sprintf("synthetic-%04d", i),
      played_at     = session_start,
      session_date  = session_date,
      start_time    = format(session_start, "%H:%M", tz = "UTC"),
      duration_min  = duration_min,
      sport         = "tennis",
      session_type  = "hit",
      is_doubles    = FALSE,
      location      = sample(locations, 1L),
      surface       = sample(c("hard", "clay"), 1L, prob = c(0.85, 0.15)),
      outdoor       = sample(c(TRUE, FALSE), 1L),
      latitude      = round(stats::runif(1, 50.0, 53.0), 4),   # broad GB-ish box, not a real venue
      longitude     = round(stats::runif(1, -2.0, 0.5), 4),
      opponent      = "Sample Opponent",
      me_shots    = nrow(guest_shots),
      me_shots_in = guest_in,
      shots_in_pct  = round(100 * guest_in / nrow(guest_shots), 1),
      me_run_mi   = round(stats::runif(1, 0.3, 1.1), 2),
      opp_shots     = nrow(host_shots),
      opp_run_mi    = round(stats::runif(1, 0.3, 1.1), 2),
      fh_shots      = nrow(fh),
      bh_shots      = nrow(bh),
      fh_speed_mph  = round(mean(fh$shot_speed_mph, na.rm = TRUE), 1),
      bh_speed_mph  = round(mean(bh$shot_speed_mph, na.rm = TRUE), 1),
      serves        = 0,
      serves_in     = 0,
      returns       = 0,
      winner        = "draw"
    )

    weather_rows[[i]] <- tibble::tibble(
      match_id      = match_id,
      temp_c        = round(stats::runif(1, 5, 25), 1),
      wind_avg_kmh  = round(stats::runif(1, 0, 15), 1),
      wind_gust_kmh = round(stats::runif(1, 5, 25), 1)
    )
  }

  list(
    matches         = dplyr::bind_rows(matches_rows),
    shot_segments   = dplyr::bind_rows(segs_rows),
    shot_detail     = dplyr::bind_rows(shots_rows),
    rallies         = dplyr::bind_rows(rallies_rows),
    session_weather = dplyr::bind_rows(weather_rows)
  )
}

#' Write a generated synthetic dataset to a fresh local DuckDB file.
#' @param data Output of [generate_synthetic_sample()].
#' @param path Destination `.duckdb` path. Overwritten if it already exists.
write_synthetic_sample_db <- function(data, path = "inst/extdata/synthetic_sample.duckdb") {
  if (file.exists(path)) file.remove(path)
  wal <- paste0(path, ".wal")
  if (file.exists(wal)) file.remove(wal)

  con <- tennis_db_connect(path)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  tennis_db_upsert(con, data$matches, key = "match_id", table = "matches")
  tennis_db_upsert(con, data$shot_segments, key = "match_id", table = "shot_segments")
  tennis_db_upsert(con, data$shot_detail, key = "match_id", table = "shot_detail")
  tennis_db_upsert(con, data$rallies, key = "match_id", table = "rallies")
  tennis_db_upsert(con, data$session_weather, key = "match_id", table = "session_weather")
  invisible(path)
}

if (identical(Sys.getenv("SYNTHETIC_SAMPLE_SKIP_MAIN"), "")) {
  data <- generate_synthetic_sample()
  out_path <- write_synthetic_sample_db(data)
  message(sprintf(
    "Wrote synthetic sample: %d match(es), %d segment(s), %d shot(s), %d rall(y/ies), %d weather row(s) -> %s",
    nrow(data$matches), nrow(data$shot_segments), nrow(data$shot_detail),
    nrow(data$rallies), nrow(data$session_weather), out_path
  ))
}
