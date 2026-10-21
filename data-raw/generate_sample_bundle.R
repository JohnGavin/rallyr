#!/usr/bin/env Rscript

# Builds the bundled SYNTHETIC sample bundle, inst/extdata/synthetic_sample_bundle.json.gz,
# from the synthetic sample database (inst/extdata/synthetic_sample.duckdb).
# Like that database, it contains no real session: every value was drawn from
# hand-picked random ranges by data-raw/generate_sample.R.
#
# The bundle holds RAW-shaped API payloads (match, stats, shots) per session,
# so loading it exercises exactly the code path a real bundle takes. The
# payloads are written in the shape the parsers read (see sv_parse_match() and
# sv_parse_shots()). Fields the sample database does not hold are filled with
# fixed, obviously fictional values: the two player names, a right-handed
# player, and a stroke duration of 0.6 s.
#
# Usage (from the rallyr package root):
#   Rscript data-raw/generate_sample_bundle.R

.args <- commandArgs(trailingOnly = FALSE)
.self <- sub("^--file=", "", .args[grep("^--file=", .args)])
if (length(.self) == 1L && nzchar(.self)) {
  setwd(normalizePath(file.path(dirname(.self), "..")))
}

if (identical(Sys.getenv("SYNTHETIC_BUNDLE_SKIP_LOAD"), "")) {
  pkgload::load_all(quiet = TRUE)
}

SAMPLE_PLAYER <- "Sample Player"
SAMPLE_FEEDER <- "Sample Opponent"
SAMPLE_FETCHED_AT <- "2030-01-01T00:00:00Z"

.iso <- function(x) format(as.POSIXct(x, tz = "UTC"), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
.num_or_null <- function(x) if (length(x) == 0L || is.na(x)) NULL else as.numeric(x)

#' One synthetic match's raw payloads, shaped like the share API's responses
#'
#' @param m One row of the `matches` table.
#' @param shots That match's rows of the `shot_detail` table.
#' @return A list with `match`, `stats` and `shots`, each `list(data = ...)`.
#' @keywords internal
.synthetic_raw_for_match <- function(m, shots) {
  mph <- 2.2369362920544
  start <- as.POSIXct(m$played_at, tz = "UTC")
  match <- list(
    id = as.numeric(m$match_id),
    started_at = .iso(start),
    ended_at = .iso(start + m$duration_min * 60),
    recording_duration = m$duration_min * 60 + 5,
    sport_type = m$sport,
    session_type = m$session_type,
    is_doubles = isTRUE(as.logical(m$is_doubles)),
    court = list(name = m$location, surface = m$surface, outdoor = isTRUE(as.logical(m$outdoor))),
    latitude = .num_or_null(m$latitude),
    longitude = .num_or_null(m$longitude),
    guest_name = SAMPLE_PLAYER,
    host_name = SAMPLE_FEEDER,
    guest_right_handed = TRUE,
    host_right_handed = TRUE,
    guest_shot_count = as.numeric(m$me_shots),
    guest_shot_in = as.numeric(m$me_shots_in),
    guest_distance_run = as.numeric(m$me_run_mi),
    host_shot_count = as.numeric(m$opp_shots),
    host_distance_run = as.numeric(m$opp_run_mi),
    winner = m$winner
  )
  wing_set <- function(fh_n, bh_n, fh_mph, bh_mph) {
    list(list(
      serve = 0, serve_in = 0, first_return = 0, second_return = 0,
      right_wing = as.numeric(fh_n), left_wing = as.numeric(bh_n),
      average_right_wing_velocity = fh_mph / mph, average_left_wing_velocity = bh_mph / mph
    ))
  }
  stats <- list(
    guest = wing_set(m$fh_shots, m$bh_shots, m$fh_speed_mph, m$bh_speed_mph),
    host = wing_set(0, 0, 0, 0)
  )
  shots <- shots[order(shots$started_at), ]
  shot_list <- lapply(seq_len(nrow(shots)), function(i) {
    s <- shots[i, ]
    t0 <- as.POSIXct(s$started_at, tz = "UTC")
    in_play <- isTRUE(as.logical(s$shot_in))
    long <- s$bounce_location_long
    # A shot in play cannot have bounced "out"; keep the payload consistent
    # with the stored in/out flag.
    if (in_play && identical(long, "out")) long <- "baseline"
    out <- list(
      id = as.numeric(s$shot_id), match_id = as.numeric(m$match_id), pid = as.numeric(s$rally_id),
      player = s$player, started_at = .iso(t0), ended_at = .iso(t0 + 0.6),
      hit_wing = s$hit_wing, hit_type = s$hit_type, spin_type = s$spin_type,
      hit_velocity = c(s$hit_velocity_x, s$hit_velocity_y, s$hit_velocity_z),
      bounce_location_long = long, bounce_location_lat = s$bounce_location_lat,
      hit_frame = as.numeric(s$hit_frame),
      hit_court_side = s$hit_court_side, bounce_court_side = s$bounce_court_side,
      net_location = c(0, 0, s$net_clearance_m),
      hit_location = c(s$hit_x, s$hit_y, s$hit_z),
      bounce_location = c(s$bounce_x, s$bounce_y, s$bounce_z)
    )
    if (!in_play) out$net_type <- "net"
    out
  })
  list(match = list(data = match), stats = list(data = stats), shots = list(data = shot_list))
}

#' Build the sample bundle from the synthetic sample database
#' @param db Path to the synthetic sample database.
#' @return A bundle.
#' @keywords internal
.synthetic_sample_bundle <- function(db = "inst/extdata/synthetic_sample.duckdb") {
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = db, read_only = TRUE)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  matches <- DBI::dbGetQuery(con, "SELECT * FROM matches ORDER BY played_at")
  detail <- DBI::dbGetQuery(con, "SELECT * FROM shot_detail")
  detail$started_at <- as.POSIXct(detail$started_at, tz = "UTC")
  bundle <- bundle_new()
  for (i in seq_len(nrow(matches))) {
    m <- matches[i, ]
    raw <- .synthetic_raw_for_match(m, detail[detail$match_id == m$match_id, ])
    bundle <- bundle_add_raw(
      bundle, raw$match, raw$stats, raw$shots,
      token = m$share_token, fetched_at = SAMPLE_FETCHED_AT
    )
  }
  structure(bundle, merge_report = NULL)
}

if (identical(Sys.getenv("SYNTHETIC_BUNDLE_SKIP_MAIN"), "")) {
  out <- "inst/extdata/synthetic_sample_bundle.json.gz"
  bundle_write(.synthetic_sample_bundle(), out)
  message(sprintf("Wrote %s (%d bytes)", out, file.size(out)))
}
