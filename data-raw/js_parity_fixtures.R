#!/usr/bin/env Rscript

# Writes the reference values the JavaScript app is tested against:
# tests/testthat/fixtures/js_parity/*.json.gz.
#
# The browser app (inst/app_js/) is a plain-JavaScript port of the R functions
# this package uses; the R package is the reference. This script runs the R
# functions on the SYNTHETIC sample bundle and on the extra synthetic session,
# and writes what they return (tables, derived data, merge reports, payload
# kinds, share-link tokens, the numbers each chart is drawn from). The tests in
# tests/js/ read those files and check that the JavaScript gives the same
# values (numbers within a relative 1e-9, text and dates exactly).
#
# Nothing here is typed in by hand: every value comes from running the R code.
#
# Usage (from the package root, inside the project's Nix shell):
#   Rscript data-raw/js_parity_fixtures.R

.args <- commandArgs(trailingOnly = FALSE)
.self <- sub("^--file=", "", .args[grep("^--file=", .args)])
if (length(.self) == 1L && nzchar(.self)) setwd(normalizePath(file.path(dirname(.self), "..")))
pkgload::load_all(quiet = TRUE)

out_dir <- file.path("tests", "testthat", "fixtures", "js_parity")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- writing tables as JSON ----------------------------------------------------

# A column as JSON will carry it: a time as seconds since 1970 (UTC), a date as
# "YYYY-MM-DD" text, whole numbers as numbers; NA becomes null.
col_value <- function(x) {
  if (inherits(x, "POSIXct")) {
    as.numeric(x)
  } else if (inherits(x, "Date")) {
    ifelse(is.na(x), NA_character_, format(x, "%Y-%m-%d"))
  } else if (is.factor(x)) {
    as.character(x)
  } else if (is.integer(x)) {
    as.numeric(x)
  } else {
    x
  }
}

# Which columns are times: the test compares those to 1e-5 s, not relatively.
table_json <- function(df) {
  df <- as.data.frame(df)
  list(
    names = names(df),
    n = jsonlite::unbox(nrow(df)),
    time = names(df)[vapply(df, inherits, logical(1), what = "POSIXct")],
    cols = lapply(df, col_value)
  )
}

write_fixture <- function(x, name) {
  path <- file.path(out_dir, name)
  con <- gzfile(path, "wb")
  writeLines(
    as.character(jsonlite::toJSON(x, auto_unbox = FALSE, na = "null", null = "null", digits = NA, pretty = FALSE)),
    con
  )
  close(con)
  message(sprintf("%s: %.0f KB", name, file.size(path) / 1024))
}

derived_json <- function(d) {
  list(
    sessions = table_json(d$sessions),
    corrected_rallies = if (is.null(d$corrected_rallies)) NULL else table_json(d$corrected_rallies),
    session_metrics = if (is.null(d$session_metrics)) NULL else table_json(d$session_metrics),
    net_clearance = table_json(d$net_clearance),
    stroke_quality = table_json(d$stroke_quality)
  )
}

tables_json <- function(t) {
  list(
    matches = table_json(t$matches),
    shot_segments = table_json(t$shot_segments),
    shot_detail = table_json(t$shot_detail),
    rallies = table_json(t$rallies),
    skipped = table_json(t$skipped)
  )
}

result_json <- function(b, me, on_error = "abort") {
  t <- bundle_to_tables(b, me, on_error = on_error)
  d <- bundle_derived(t)
  list(me = jsonlite::unbox(me), tables = tables_json(t), derived = derived_json(d), players = bundle_players(b))
}

# ---- the data ---------------------------------------------------------------------

sample_file <- system.file("extdata", "synthetic_sample_bundle.json.gz", package = "rallyr")
session_dir <- system.file("extdata", "synthetic_sample_session", package = "rallyr")
extra <- file.path(session_dir, c("sample_session_match.json", "sample_session_stats.json", "sample_session_shots.json"))
sample <- bundle_read(sample_file)
me <- "Sample Player"

# ---- 1. the sample bundle, as the player and as the feeder ---------------------------

main <- result_json(sample, me)

# The numbers the charts are drawn from, read back out of the ggplot objects.
panel_of <- function(p) {
  b <- ggplot2::ggplot_build(p)
  lay <- b$layout$layout
  list(b = b, panel = as.character(lay$panel)[match(b$data[[1]]$PANEL, lay$PANEL)])
}
trend_points <- function(d, range = NULL) {
  p <- plot_session_trend(d, date_range = range)
  pb <- panel_of(p)
  dat <- pb$b$data[[1]]
  list(panel = pb$panel, x = as.numeric(dat$x), y = dat$y)
}
plot_numbers <- function(derived) {
dates <- derived$sessions$session_date
range_mid <- as.character(c(dates[2], dates[5]))

rally_p <- plot_rally_length(derived)
speed_p <- plot_stroke_speed(derived)
net_p <- plot_net_clearance(derived)
gap_p <- plot_gap_distribution(derived)
drill_levels <- function(p) levels(p$data$drill)
speed_box <- ggplot2::layer_data(speed_p, 1)
hist <- ggplot2::layer_data(gap_p, 1)
marks <- gap_p$layers[[2]]$data
rally_med <- ggplot2::layer_data(rally_p, 2)
box_cols <- if ("xmiddle" %in% names(speed_box)) {
  c(min = "xmin", lower = "xlower", middle = "xmiddle", upper = "xupper", max = "xmax")
} else {
  c(min = "ymin", lower = "lower", middle = "middle", upper = "upper", max = "ymax")
}
pos_col <- if ("xmiddle" %in% names(speed_box)) "y" else "x"
speed_order <- order(as.numeric(speed_box[[pos_col]]))
nc_long <- net_p$data
gaps <- dq_stroke_gaps(derived$tables$shot_detail)

list(
  trend = trend_points(derived),
  trend_range = c(list(range = range_mid), trend_points(derived, range_mid)),
  rally = list(
    drills = drill_levels(rally_p),
    values = lapply(drill_levels(rally_p), function(l) sort(rally_p$data$n_shots[rally_p$data$drill == l])),
    medians = as.numeric(rally_med$x[order(as.numeric(rally_med$y))])
  ),
  speed = list(
    drills = drill_levels(speed_p),
    min = as.numeric(speed_box[[box_cols[["min"]]]][speed_order]),
    lower = as.numeric(speed_box[[box_cols[["lower"]]]][speed_order]),
    middle = as.numeric(speed_box[[box_cols[["middle"]]]][speed_order]),
    upper = as.numeric(speed_box[[box_cols[["upper"]]]][speed_order]),
    max = as.numeric(speed_box[[box_cols[["max"]]]][speed_order]),
    n_outliers = vapply(speed_box$outliers[speed_order], length, integer(1))
  ),
  net = list(
    drills = sort(unique(nc_long$drill)),
    points = lapply(sort(unique(nc_long$drill)), function(l) {
      list(
        you = sort(nc_long$median_m[nc_long$drill == l & nc_long$side == "You"]),
        feeder = sort(nc_long$median_m[nc_long$drill == l & nc_long$side == "Feeder"])
      )
    })
  ),
  gap = list(
    xmin = as.numeric(hist$xmin), xmax = as.numeric(hist$xmax), count = as.numeric(hist$count),
    mark_x = as.numeric(marks$x), mark_label = marks$label,
    n_beyond = jsonlite::unbox(sum(gaps$gap_sec > 10)), n_gaps = jsonlite::unbox(nrow(gaps))
  )
)
}
main$plots <- plot_numbers(bundle_derived(bundle_to_tables(sample, me)))
write_fixture(main, "sample.json.gz")

# the same bundle, with the feeder ("Sample Opponent") as the player: the sides swap
write_fixture(result_json(sample, "Sample Opponent"), "sample_as_opponent.json.gz")

# ---- 2. the sample bundle with the extra session added -------------------------------

fetched <- "2031-02-01T09:00:00Z"
added <- bundle_add_raw(sample, extra[1], extra[2], extra[3], token = "synthetic-0007", fetched_at = fetched)
plus <- result_json(added, me)
plus$merge_report <- table_json(attr(added, "merge_report"))
write_fixture(plus, "sample_plus_session.json.gz")

# ---- 2b. a bundle built to reach the rules the sample never triggers ------------------------
#
# The sample has no placeholder speeds, no implausible net heights, no
# too-fast rally, no two sessions on one day, no session with the player on the
# feeder's side, no session without shots and none that cannot be read. This
# one is the sample with those put in (all synthetic). R's own result for it is
# the reference, so the JavaScript is tested on every one of those paths. The
# checks at the end stop the script if a rule did not fire.

stress <- sample
set_shots <- function(s, f) { s$shots$data <- f(s$shots$data); s }
players_of <- function(shots) vapply(shots, function(z) z$player, character(1))

# session 1: placeholder speeds, a rally that is too fast, a rally with one
# impossible stroke, no speed, net heights out of range or absent, balls out
s <- stress$sessions[[1]]
s <- set_shots(s, function(shots) {
  guest <- which(players_of(shots) == "guest")
  host <- which(players_of(shots) == "host")
  for (i in guest[1:15]) shots[[i]]$hit_velocity <- list(52.3466, 0, 0)          # 117.1 mph: the placeholder
  pid_fast <- shots[[guest[60]]]$pid
  for (i in guest[vapply(shots[guest], function(z) z$pid == pid_fast, logical(1))]) shots[[i]]$hit_velocity <- list(30, 0, 0)
  pid_one <- shots[[guest[120]]]$pid
  one <- guest[vapply(shots[guest], function(z) z$pid == pid_one, logical(1))][1]
  shots[[one]]$hit_velocity <- list(50, 0, 0)                                      # one stroke at 180 km/h
  shots[[guest[150]]]$hit_velocity <- list(0, 0, 0)                                # no reading
  shots[[guest[151]]]$hit_velocity <- NULL
  for (i in guest[160:164]) shots[[i]]$net_location <- list(0, 0, 9)
  for (i in guest[165:169]) shots[[i]]$net_location <- list(0, 0, -3)
  for (i in host[10:14]) shots[[i]]$net_location <- list(0, 0, 7.5)
  for (i in guest[170:174]) shots[[i]]$net_location <- NULL
  for (i in guest[180:184]) shots[[i]]$bounce_location_long <- "out"
  for (i in guest[185:189]) shots[[i]]$bounce_location_lat <- "ad_out"
  for (i in guest[190:194]) shots[[i]]$net_type <- "net"
  shots
})
stress$sessions[[1]] <- s

# session 2: moved to the evening of session 1's day (two recordings, one session)
shift_time <- function(x, delta) format(as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC") + delta, "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
s <- stress$sessions[[2]]
delta <- as.numeric(difftime(as.POSIXct("2030-01-05 20:00:00", tz = "UTC"),
                             as.POSIXct(s$match$data$started_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"), units = "secs"))
s$match$data$started_at <- shift_time(s$match$data$started_at, delta)
s$match$data$ended_at <- shift_time(s$match$data$ended_at, delta)
s <- set_shots(s, function(shots) {
  for (i in seq_along(shots)) {
    shots[[i]]$started_at <- shift_time(shots[[i]]$started_at, delta)
    shots[[i]]$ended_at <- shift_time(shots[[i]]$ended_at, delta)
  }
  shots
})
stress$sessions[[2]] <- s

# session 3: a left-handed player
stress$sessions[[3]]$match$data$guest_right_handed <- FALSE

# session 4: the player on the feeder's side (guest and host swapped throughout)
swap_name <- function(nm) ifelse(grepl("^guest_", nm), sub("^guest_", "host_", nm), ifelse(grepl("^host_", nm), sub("^host_", "guest_", nm), nm))
s <- stress$sessions[[4]]
names(s$match$data) <- swap_name(names(s$match$data))
names(s$stats$data) <- ifelse(names(s$stats$data) == "guest", "host", "guest")
s <- set_shots(s, function(shots) {
  for (i in seq_along(shots)) shots[[i]]$player <- if (shots[[i]]$player == "guest") "host" else "guest"
  shots
})
stress$sessions[[4]] <- s

# session 5: no shots at all
stress$sessions[[5]] <- set_shots(stress$sessions[[5]], function(shots) list())

# session 6: cannot be read (no recording duration)
stress$sessions[[6]]$match$data$recording_duration <- NULL

# session 7: the extra session with no token and no fetch time
extra_payload <- lapply(extra, jsonlite::fromJSON, simplifyVector = FALSE)
kinds <- vapply(extra_payload, bundle_payload_kind, character(1))
names(extra_payload) <- kinds
stress$sessions[[7]] <- list(
  match_id = extra_payload$match$data$id, match = extra_payload$match,
  stats = extra_payload$stats, shots = extra_payload$shots
)

stress_file <- file.path(out_dir, "stress_bundle.json.gz")
bundle_write(stress, stress_file)
stress <- bundle_read(stress_file)

stress_tables <- bundle_to_tables(stress, me, on_error = "skip")
stress_derived <- bundle_derived(stress_tables)
detail <- dq_clean_shot_speed(stress_tables$shot_detail)
id1 <- stress$sessions[[1]]$match_id
fast <- stress_tables$rallies$rally_id[stress_tables$rallies$match_id == id1]
stopifnot(
  "no placeholder speed was flagged" = sum(detail$shot_speed_sentinel) >= 15,
  "no net height was out of range" = sum(stress_derived$net_clearance$n_implausible) >= 10,
  "no strokes without a speed" = sum(is.na(detail$shot_speed_mph)) > sum(detail$shot_speed_sentinel),
  "two recordings did not merge into one session" = max(stress_derived$sessions$n_parts) == 2L,
  "the unreadable session was not skipped" = nrow(stress_tables$skipped) >= 1L &&
    any(grepl("could not be parsed", stress_tables$skipped$reason)),
  "a player-not-in-session row is missing or wrong" = !anyNA(stress_tables$skipped$reason),
  "fewer rallies corrected than raw: nothing was dropped" = nrow(stress_derived$corrected_rallies) != nrow(stress_tables$rallies)
)
message(sprintf("stress: %d sessions read, %d skipped (%s)", nrow(stress_tables$matches), nrow(stress_tables$skipped),
                paste(stress_tables$skipped$reason, collapse = " | ")))
stress_result <- result_json(stress, me, on_error = "skip")
stress_result$plots <- plot_numbers(stress_derived)
stopifnot("the stress bundle has no box-plot outlier" = any(stress_result$plots$speed$n_outliers > 0))
write_fixture(stress_result, "stress.json.gz")

# ---- 2c. a session built to sit ON the edge of every threshold ----------------------------
#
# Random-looking data rarely land exactly on a threshold, so a wrong threshold
# (> for >=, 0.5 for 0.4) can pass a comparison on the sample. This session is
# built minute by minute so that bins and rallies fall exactly on, just under and
# just over each rule: the net-volley share (0.4), the mini-tennis speed (35 mph),
# wing dominance (0.7 / 0.3), the fewest strokes in a bin (4), the shortest
# segment (3 min), the pause that splits a rally (3 s cross-court, 2 s
# net-volley, only before the feeder's stroke), the stroke limits per drill
# (20, 25, 50), the mean speed (100 km/h) and one stroke's speed (160 km/h), the
# placeholder speed (117.1 mph), the net-height range (-1 to 5 m), and every
# landing-zone tier. R's result for it is the reference. The checks at the end
# stop the script if a case did not land where it was designed to.

edge <- local({
  id <- 9100001
  shots <- list()
  nid <- 0L
  npid <- 0L
  registry <- list()
  ts <- function(ms) {
    s <- as.integer(ms %/% 1000)
    sprintf("2030-03-02T%02d:%02d:%02d.%03d000Z", 10L + s %/% 3600L, (s %/% 60L) %% 60L, s %% 60L, as.integer(ms %% 1000))
  }
  add <- function(ms, player, pid, mph = 40, type = "ground_stroke", wing = "right", dur = 600,
                  long = "baseline", lat = "deuce", net_z = 1.2, no_speed = FALSE) {
    nid <<- nid + 1L
    s <- list(
      id = nid, match_id = id, pid = pid, player = player, started_at = ts(ms), ended_at = ts(ms + dur),
      hit_wing = wing, hit_type = type, spin_type = "flat", hit_velocity = list(mph / 2.2369362920544, 0, 0),
      bounce_location_long = long, bounce_location_lat = lat, hit_frame = round(ms / 1000 * 60.006),
      hit_court_side = "near", bounce_court_side = "far", net_location = list(0, 0, net_z),
      hit_location = list(0, 0, 1), bounce_location = list(0, 0, 0)
    )
    if (no_speed) s$hit_velocity <- NULL
    if (is.na(net_z)) s$net_location <- NULL
    if (is.na(long)) s$bounce_location_long <- NULL
    if (is.na(lat)) s$bounce_location_lat <- NULL
    shots[[length(shots) + 1L]] <<- s
  }
  zone_cycle <- list(
    list(long = "no_mans_land", lat = "deuce", host_wing = "right"), list(long = "no_mans_land", lat = "deuce", host_wing = "left"),
    list(long = "baseline", lat = "deuce", host_wing = "right"), list(long = "baseline", lat = "deuce", host_wing = "left"),
    list(long = "no_mans_land", lat = "ad", host_wing = "right"), list(long = "out", lat = "deuce", host_wing = "right"),
    list(long = "baseline", lat = "ad_out", host_wing = "left"), list(long = NA_character_, lat = "deuce", host_wing = "right"),
    list(long = "no_mans_land", lat = "ad", host_wing = "left"), list(long = "baseline", lat = "deuce_out", host_wing = "right"),
    list(long = "no_mans_land", lat = NA_character_, host_wing = "left")
  )
  # `n_min` whole minutes of `pairs` guest-then-host pairs each; `host_volley` and
  # `guest_right` of them (per minute) are a volley / a right-wing stroke.
  # first_at / last_end (ms from the block's start) pin the segment's length.
  block <- function(label, start_min, n_min, pairs = 10L, host_volley = 0L, guest_right = pairs %/% 2L, mph = 40,
                    singles = 0L, first_at = 1000, last_end = NULL, zones = FALSE) {
    t0 <- start_min * 60000
    step <- floor(54000 / pairs)
    for (m in seq_len(n_min)) {
      for (p in seq_len(pairs)) {
        base <- t0 + (m - 1) * 60000 + (if (m == 1 && p == 1) first_at else 1000) + (p - 1) * step
        npid <<- npid + 1L
        z <- if (zones) zone_cycle[[(npid %% length(zone_cycle)) + 1L]] else list(long = "baseline", lat = "deuce", host_wing = "left")
        add(base, "guest", npid, mph = mph, wing = if (p <= guest_right) "right" else "left", long = z$long, lat = z$lat)
        add(base + 1000, "host", npid, mph = 30, type = if (p <= host_volley) "volley" else "ground_stroke", wing = z$host_wing)
      }
      for (k in seq_len(singles)) {
        npid <<- npid + 1L
        add(t0 + (m - 1) * 60000 + 30000 + k * 3000, "guest", npid, mph = mph, wing = "left")
      }
    }
    if (!is.null(last_end)) shots[[length(shots)]]$ended_at <<- ts(t0 + last_end)
    registry[[label]] <<- list(from = t0, to = t0 + n_min * 60000)
    start_min + n_min
  }
  # one rally of the given shape ("ghg..."), `gaps` ms between starts
  rally <- function(start_ms, pattern, gaps = 1000, mph = 40, host_type = "ground_stroke", wing = "right", nets = NULL) {
    npid <<- npid + 1L
    chars <- strsplit(pattern, "")[[1]]
    n <- length(chars)
    starts <- start_ms + c(0, cumsum(rep_len(gaps, n - 1L)))
    g <- 0L
    for (i in seq_len(n)) {
      if (chars[i] == "g") {
        g <- g + 1L
        sp <- rep_len(mph, 1e4)[g]
        add(starts[i], "guest", npid, mph = if (is.na(sp)) 40 else sp, wing = wing, no_speed = is.na(sp),
            net_z = if (is.null(nets)) 1.2 else rep_len(nets, 1e4)[g])
      } else {
        add(starts[i], "host", npid, mph = 30, type = host_type, wing = "left")
      }
    }
    list(pid = npid, end = starts[n] + 600)
  }
  alt <- function(n_guest) paste0(strrep("gh", n_guest - 1L), "g")
  # gaps with `before` (the position of the stroke after the pause) set to `ms`
  pause <- function(n, before, ms) { g <- rep(1000, n - 1L); g[before - 1L] <- ms; g }

  cases <- list()
  specials <- function(label, start_min, n_min, items) {
    cursor <- start_min * 60000 + 1500
    for (it in items) {
      r <- do.call(rally, c(list(start_ms = cursor), it$args))
      cases[[it$name]] <<- r$pid
      cursor <- r$end + 2000
    }
    if (cursor > (start_min + n_min) * 60000 - 1000) stop("the special rallies of ", label, " run past their block", call. = FALSE)
  }

  cur <- 0
  # segment rules: three minutes each, pinned to exactly 3 min (180 s)
  seg <- function(label, ...) cur <<- block(label, cur, 3, first_at = 0, last_end = 180000, ...)
  seg("V1: volley share 10/25 = 0.40", pairs = 25L, host_volley = 10L, guest_right = 12L)
  seg("V2: volley share 9/25", pairs = 25L, host_volley = 9L, guest_right = 12L)
  seg("V3: volley share 11/25", pairs = 25L, host_volley = 11L, guest_right = 12L)
  seg("M1: speed 34.9", mph = 34.9)
  seg("M2: speed 35.0", mph = 35.0)
  seg("M3: speed 35.1", mph = 35.1)
  seg("W1: right wing 7/10 = 0.7", guest_right = 7L)
  seg("W2: right wing 6/10", guest_right = 6L)
  seg("W3: right wing 3/10 = 0.3", guest_right = 3L)
  seg("W4: right wing 4/10", guest_right = 4L)
  seg("G1: 4 strokes a minute", pairs = 2L, guest_right = 1L)
  seg("G2: 3 strokes a minute", pairs = 1L, singles = 1L, guest_right = 1L)
  # segment length: 3.0 min, 2.95 min, 2.9 min of net-volley, each between mixed blocks
  seg("S1", guest_right = 5L)
  seg("D1: length 3.00 min", host_volley = 5L, guest_right = 5L)
  seg("S2", guest_right = 5L)
  cur <- block("D2: length 2.95 min", cur, 3, host_volley = 5L, guest_right = 5L, first_at = 0, last_end = 177000)
  seg("S3", guest_right = 5L)
  cur <- block("D3: length 2.90 min", cur, 3, host_volley = 5L, guest_right = 5L, first_at = 0, last_end = 174000)
  seg("S4", guest_right = 5L)
  # lengths whose tenth of a minute is a tie (3.05 and 3.15 sit just under their tie in binary: R rounds them down)
  cur <- block("D4: length 3.05 min", cur, 3, host_volley = 5L, guest_right = 5L, first_at = 0, last_end = 183000)
  seg("S5", guest_right = 5L)
  cur <- block("D5: length 3.15 min", cur, 3, host_volley = 5L, guest_right = 5L, first_at = 0, last_end = 189000)
  seg("S6", guest_right = 5L)

  # rally rules, forehand cross-court
  fh <- cur
  cur <- block("FH", cur, 8, guest_right = 10L, zones = TRUE)
  specials("FH", fh, 8, list(
    list(name = "f1 no pause", args = list(pattern = "ghghgh")),
    list(name = "f2 3.000 s before the feeder", args = list(pattern = "ghghgh", gaps = pause(6, 4, 3000))),
    list(name = "f3 3.001 s before the feeder", args = list(pattern = "ghghgh", gaps = pause(6, 4, 3001))),
    list(name = "f4 3.5 s before the player", args = list(pattern = "ghghgh", gaps = pause(6, 3, 3500))),
    list(name = "f5 two pauses", args = list(pattern = "ghghghg", gaps = { g <- rep(1000, 6); g[c(1, 3)] <- 3200; g })),
    list(name = "f6 20 strokes", args = list(pattern = alt(20))),
    list(name = "f7 21 strokes", args = list(pattern = alt(21))),
    list(name = "f8 21 strokes, one pause", args = list(pattern = alt(21), gaps = pause(41, 22, 3500))),
    list(name = "f9 42 strokes, one pause", args = list(pattern = alt(42), gaps = pause(83, 42, 3500))),
    list(name = "f10 mean 62.1 mph", args = list(pattern = "ghghg", mph = 62.1)),
    list(name = "f11 mean 62.2 mph", args = list(pattern = "ghghg", mph = 62.2)),
    list(name = "f12 one stroke 99.4 mph", args = list(pattern = "ghghg", mph = c(40, 99.4, 40))),
    list(name = "f13 one stroke 99.5 mph", args = list(pattern = "ghghg", mph = c(40, 99.5, 40))),
    list(name = "f14 placeholder 117.1", args = list(pattern = "ghghg", mph = c(40, 117.1, 40))),
    list(name = "f15 117.2 mph", args = list(pattern = "ghghg", mph = c(40, 117.2, 40))),
    list(name = "f16 117.0 mph", args = list(pattern = "ghghg", mph = c(40, 117.0, 40))),
    list(name = "f17 no speed", args = list(pattern = "ghghg", mph = NA_real_)),
    list(name = "f18 fast piece after a pause", args = list(pattern = "ghghhghg", mph = c(62.2, 62.2, 40, 40), gaps = pause(8, 5, 3500))),
    list(name = "f19 net heights", args = list(pattern = alt(6), nets = c(-1, -1.01, 5, 5.01, NA, 1))),
    list(name = "f20 41 strokes, pieces of 20 and 21", args = list(pattern = alt(41), gaps = pause(81, 40, 3500)))
  ))
  # backhand cross-court
  bh <- cur
  cur <- block("BH", cur, 4, guest_right = 0L, zones = TRUE)
  specials("BH", bh, 4, list(
    list(name = "b1 20 strokes", args = list(pattern = alt(20), wing = "left")),
    list(name = "b2 21 strokes", args = list(pattern = alt(21), wing = "left")),
    list(name = "b3 3.000 s before the feeder", args = list(pattern = "ghghgh", gaps = pause(6, 4, 3000), wing = "left")),
    list(name = "b4 3.001 s before the feeder", args = list(pattern = "ghghgh", gaps = pause(6, 4, 3001), wing = "left"))
  ))
  # net volley
  nv <- cur
  cur <- block("NV", cur, 5, host_volley = 5L, guest_right = 5L)
  specials("NV", nv, 5, list(
    list(name = "n1 25 strokes", args = list(pattern = alt(25), host_type = "volley")),
    list(name = "n2 26 strokes", args = list(pattern = alt(26), host_type = "volley")),
    list(name = "n3 2.000 s before the feeder", args = list(pattern = "ghghgh", gaps = pause(6, 4, 2000), host_type = "volley")),
    list(name = "n4 2.001 s before the feeder", args = list(pattern = "ghghgh", gaps = pause(6, 4, 2001), host_type = "volley"))
  ))
  # mini-tennis: never split by a pause
  mi <- cur
  cur <- block("MINI", cur, 5, mph = 30)
  specials("MINI", mi, 5, list(
    list(name = "m1 50 strokes", args = list(pattern = alt(50), mph = 30)),
    list(name = "m2 51 strokes", args = list(pattern = alt(51), mph = 30)),
    list(name = "m3 3.5 s before the feeder", args = list(pattern = "ghghgh", gaps = pause(6, 4, 3500), mph = 30))
  ))

  base <- sample$sessions[[1]]
  m <- base$match
  m$data$id <- id
  m$data$started_at <- ts(0)
  m$data$ended_at <- ts(cur * 60000)
  m$data$recording_duration <- cur * 60
  list(
    session = list(
      match_id = id, token = "synthetic-edge", fetched_at = "2030-03-03T00:00:00Z",
      match = m, stats = base$stats, shots = list(data = shots)
    ),
    cases = cases, blocks = registry
  )
})

edge_bundle <- bundle_new()
edge_bundle$sessions <- list(edge$session)
edge_file <- file.path(out_dir, "edge_bundle.json.gz")
bundle_write(edge_bundle, edge_file)
edge_bundle <- bundle_read(edge_file)
edge_tables <- bundle_to_tables(edge_bundle, me)
edge_derived <- bundle_derived(edge_tables)
edge_cor <- edge_derived$corrected_rallies
edge_detail <- dq_clean_shot_speed(edge_tables$shot_detail)
kept <- function(name) as.character(edge$cases[[name]]) %in% edge_cor$rally_id
pieces <- function(name) sort(edge_cor$rally_id[startsWith(edge_cor$rally_id, paste0(edge$cases[[name]], "_"))])
regime_in <- function(prefix) {
  b <- edge$blocks[[grep(paste0("^", prefix), names(edge$blocks))]]
  t0 <- as.numeric(as.POSIXct("2030-03-02 10:00:00", tz = "UTC"))
  sel <- edge_detail$started_at >= t0 + b$from / 1000 + 5 & edge_detail$started_at < t0 + b$to / 1000 - 5
  unique(edge_detail$regime[sel])
}
rally_regime <- function(name) edge_cor$regime[edge_cor$rally_id == as.character(edge$cases[[name]])]
expected_regime <- c(
  "V1" = "net_volley", "V2" = "mixed", "V3" = "net_volley", "M1" = "mini_tennis", "M2" = "mixed", "M3" = "mixed",
  "W1" = "forehand_cross_court", "W2" = "mixed", "W3" = "backhand_cross_court", "W4" = "mixed",
  "G1" = "mixed", "G2" = "gap", "D1" = "net_volley", "D3" = "gap", "D4" = "net_volley", "D5" = "net_volley",
  "S1" = "mixed", "S2" = "mixed", "S3" = "mixed", "S4" = "mixed", "S5" = "mixed", "S6" = "mixed"
)
for (b in names(expected_regime)) {
  got <- regime_in(b)
  if (!identical(got, expected_regime[[b]])) stop("edge block ", b, ": expected ", expected_regime[[b]], ", R gives ", paste(got, collapse = "/"), call. = FALSE)
}
message("edge: segment D2 (2.95 min) is ", paste(regime_in("D2"), collapse = "/"), " in R")
cases_ok <- c(
  f1 = TRUE, f2 = TRUE, f4 = TRUE, f6 = TRUE, f7 = FALSE, f9 = FALSE, f10 = TRUE, f11 = FALSE, f12 = TRUE, f13 = FALSE,
  f14 = TRUE, f15 = FALSE, f16 = FALSE, f17 = TRUE, f19 = TRUE, b1 = TRUE, b2 = FALSE, b3 = TRUE,
  n1 = TRUE, n2 = FALSE, n3 = TRUE, m1 = TRUE, m2 = FALSE, m3 = TRUE
)
for (k in names(cases_ok)) {
  nm <- grep(paste0("^", k, " "), names(edge$cases), value = TRUE)
  if (!identical(kept(nm), cases_ok[[k]])) stop("edge rally '", nm, "': kept should be ", cases_ok[[k]], call. = FALSE)
}
for (k in c("f3", "f8", "f18", "f20", "b4", "n4")) {
  nm <- grep(paste0("^", k, " "), names(edge$cases), value = TRUE)
  p <- pieces(nm)
  if (length(p) < 1L) stop("edge rally '", nm, "' was not split into kept pieces", call. = FALSE)
  if (kept(nm)) stop("edge rally '", nm, "' was kept whole", call. = FALSE)
}
stopifnot(
  "f3 should give two pieces" = length(pieces(grep("^f3 ", names(edge$cases), value = TRUE))) == 2L,
  "f5 should give pieces" = length(pieces(grep("^f5 ", names(edge$cases), value = TRUE))) >= 2L,
  "f8 should give two pieces" = length(pieces(grep("^f8 ", names(edge$cases), value = TRUE))) == 2L,
  "f18 should keep one piece" = length(pieces(grep("^f18 ", names(edge$cases), value = TRUE))) == 1L,
  "f20 should keep the piece of 20 and drop the piece of 21" = length(pieces(grep("^f20 ", names(edge$cases), value = TRUE))) == 1L,
  "the regimes of the rally blocks are not as designed" = identical(
    c(rally_regime("f1 no pause"), rally_regime("b1 20 strokes"), rally_regime("n1 25 strokes"), rally_regime("m1 50 strokes")),
    c("forehand_cross_court", "backhand_cross_court", "net_volley", "mini_tennis")
  ),
  "a placeholder speed was not found" = sum(edge_detail$shot_speed_sentinel) == 1L,
  "exactly two net heights (-1.01 and 5.01) should be out of range" = sum(edge_derived$net_clearance$n_implausible) == 2L
)
# every landing-zone tier is reached by the cycle of bounce zones (checked on R's own score)
tiers <- local({
  d <- edge_tables$shot_detail
  d <- d[order(d$match_id, d$rally_id, d$started_at), ]
  d <- dplyr::mutate(d, next_player = dplyr::lead(player), next_hit_wing = dplyr::lead(hit_wing), .by = c("match_id", "rally_id"))
  as.character(cross_court_zone_score(d$regime, d$player, d$bounce_location_long, d$bounce_location_lat,
                                     d$next_player, d$next_hit_wing))
})
stopifnot("not every landing-zone tier was reached" = all(c("out_of_play", "off_target_width", "tier_3", "tier_2", "tier_1") %in% tiers))
write_fixture(result_json(edge_bundle, me), "edge.json.gz")

# ---- 3. merge cases: added, unchanged, replaced, kept, a tie -----------------------------

s1 <- sample$sessions[[1]]
altered <- function(s) {
  s$stats$data$guest[[1]]$average_right_wing_velocity <- s$stats$data$guest[[1]]$average_right_wing_velocity + 1
  s
}
add_case <- function(name, s, token, fetched_at) {
  out <- bundle_add_raw(sample, s$match, s$stats, s$shots, token = token, fetched_at = fetched_at)
  list(
    name = jsonlite::unbox(name),
    report = table_json(attr(out, "merge_report")),
    n_sessions = jsonlite::unbox(length(out$sessions)),
    match_ids = vapply(out$sessions, function(x) x$match_id, numeric(1)),
    tokens = vapply(out$sessions, function(x) if (is.null(x$token)) NA_character_ else x$token, character(1)),
    fetched_at = vapply(out$sessions, function(x) if (is.null(x$fetched_at)) NA_character_ else x$fetched_at, character(1)),
    fh_speed_mph = bundle_to_tables(out, me)$matches$fh_speed_mph
  )
}
merge_cases <- list(
  add_case("unchanged", s1, NA_character_, "2031-02-01T09:00:00Z"),
  add_case("unchanged_new_token", s1, "synthetic-new", "2031-02-01T09:00:00Z"),
  add_case("replaced_newer", altered(s1), NA_character_, "2031-03-01T00:00:00Z"),
  add_case("replaced_tie", altered(s1), "synthetic-new", "2030-01-01T00:00:00Z"),
  add_case("kept_older", altered(s1), NA_character_, "2029-01-01T00:00:00Z"),
  add_case("replaced_offset", altered(s1), NA_character_, "2030-01-01T02:00:00+02:00")
)

# ---- 4. payload kinds, share-link tokens, bundle validation --------------------------------

kind_cases <- list(
  list(name = "match, wrapped", text = jsonlite::toJSON(s1$match, auto_unbox = TRUE, null = "null", digits = NA)),
  list(name = "match, bare", text = jsonlite::toJSON(s1$match$data, auto_unbox = TRUE, null = "null", digits = NA)),
  list(name = "stats, wrapped", text = jsonlite::toJSON(s1$stats, auto_unbox = TRUE, null = "null", digits = NA)),
  list(name = "stats, bare", text = jsonlite::toJSON(s1$stats$data, auto_unbox = TRUE, null = "null", digits = NA)),
  list(name = "shots, wrapped", text = jsonlite::toJSON(list(data = s1$shots$data[1:3]), auto_unbox = TRUE, null = "null", digits = NA)),
  list(name = "shots, bare", text = jsonlite::toJSON(s1$shots$data[1:3], auto_unbox = TRUE, null = "null", digits = NA)),
  list(name = "empty list", text = "[]"),
  list(name = "empty object", text = "{}"),
  list(name = "wrapped empty list", text = '{"data":[]}'),
  list(name = "wrapped null", text = '{"data":null}'),
  list(name = "numbers", text = "[1,2,3]"),
  list(name = "a number", text = "5"),
  list(name = "an unknown object", text = '{"foo":1}'),
  list(name = "id only", text = '{"id":1}'),
  list(name = "match, minimal", text = '{"id":1,"host_name":"A"}'),
  list(name = "stats, minimal", text = '{"host":{},"guest":[]}'),
  list(name = "stats, host null", text = '{"host":null,"guest":{}}'),
  list(name = "stats, host a number", text = '{"host":1,"guest":{}}'),
  list(name = "shot, minimal", text = '[{"player":"guest","pid":1}]'),
  list(name = "shot without a pid, type or match", text = '[{"player":"guest"}]'),
  list(name = "shot without a player", text = '[{"pid":1}]'),
  list(name = "null element", text = "[null]"),
  list(name = "one good shot, one bad", text = '[{"player":"guest","pid":1},5]')
)
kind_cases <- lapply(kind_cases, function(k) {
  f <- tempfile(fileext = ".json")
  writeLines(as.character(k$text), f)
  list(
    name = jsonlite::unbox(k$name), text = jsonlite::unbox(as.character(k$text)),
    kind = jsonlite::unbox(bundle_payload_kind(f, strict = FALSE))
  )
})

token_inputs <- c(
  "https://swing.vision/matches/sw2-EXAMPLE01", "sw2-EXAMPLE01", "  https://swing.vision/matches/sw2-EXAMPLE01?foo=1#frag  ",
  "synthetic-0001", "https://swing.vision/matches/synthetic-0001/", "https://x.example/other/path",
  "sw2-EXAMPLE01?x=1", "sw2-EXAMPLE01#top", "", "/matches/abc", "a/matches/b/matches/c", "\thttps://s.v/matches/tok\n",
  "https://swing.vision/matches/synthetic-0001/stats", "matches/abc"
)
token_cases <- lapply(token_inputs, function(x) list(input = jsonlite::unbox(x), token = jsonlite::unbox(sv_token(x))))

# Bundles that must read, and ones that must not (a small session keeps them short).
mini <- sample$sessions[[1]]
mini$shots$data <- mini$shots$data[1:3]
as_text <- function(sessions, version = 1, extra = list()) {
  x <- c(list(schema_version = version, sessions = sessions), extra)
  as.character(jsonlite::toJSON(x, auto_unbox = TRUE, null = "null", digits = NA))
}
mod <- function(f) { s <- mini; f(s) }
no_id <- mod(function(s) { s$match_id <- NULL; s })
bad_slot <- mod(function(s) { s$stats <- NULL; s })
wrong_kind <- mod(function(s) { s$stats <- s$match; s })
bad_stamp <- mod(function(s) { s$fetched_at <- "yesterday"; s })
offset_stamp <- mod(function(s) { s$fetched_at <- "2031-01-01T09:00:00+02:00"; s })
bare_date <- mod(function(s) { s$fetched_at <- "2031-01-01"; s })
no_stamp <- mod(function(s) { s$fetched_at <- NULL; s })
id_mismatch <- mod(function(s) { s$match$data$id <- 5; s })        # only the match payload disagrees with match_id
id_mismatch_top <- mod(function(s) { s$match_id <- 5; s })         # match_id disagrees with the payload and the shots
shots_other <- mod(function(s) { s$shots$data[[2]]$match_id <- 5; s })
validation_cases <- list(
  list(name = "a valid bundle", text = as_text(list(mini)), ok = TRUE),
  list(name = "no sessions", text = as_text(list()), ok = TRUE),
  list(name = "a time with an offset", text = as_text(list(offset_stamp)), ok = TRUE),
  list(name = "a bare date", text = as_text(list(bare_date)), ok = TRUE),
  list(name = "no fetched_at", text = as_text(list(no_stamp)), ok = TRUE),
  list(name = "a newer file format", text = as_text(list(), version = 2), ok = FALSE),
  list(name = "format version zero", text = as_text(list(), version = 0), ok = FALSE),
  list(name = "format version 1.5", text = as_text(list(), version = 1.5), ok = FALSE),
  list(name = "no schema_version", text = '{"sessions":[]}', ok = FALSE),
  list(name = "no sessions list", text = '{"schema_version":1}', ok = FALSE),
  list(name = "not an object", text = "[]", ok = FALSE),
  list(name = "not JSON", text = "{nope", ok = FALSE),
  list(name = "a session with no match_id", text = as_text(list(no_id)), ok = FALSE),
  list(name = "a session with no stats", text = as_text(list(bad_slot)), ok = FALSE),
  list(name = "a payload of the wrong kind", text = as_text(list(wrong_kind)), ok = FALSE),
  list(name = "a fetched_at that is not a time", text = as_text(list(bad_stamp)), ok = FALSE),
  list(name = "a match payload whose id differs from match_id", text = as_text(list(id_mismatch)), ok = FALSE),
  list(name = "a match_id that differs from the payload and the shots", text = as_text(list(id_mismatch_top)), ok = FALSE),
  list(name = "shots of another match", text = as_text(list(shots_other)), ok = FALSE),
  list(name = "two sessions with one match_id", text = as_text(list(mini, mini)), ok = FALSE)
)
# check each case against R, so the expectation is R's, not ours
validation_cases <- lapply(validation_cases, function(v) {
  f <- tempfile(fileext = ".json")
  writeLines(v$text, f)
  r_ok <- !inherits(tryCatch(bundle_read(f), error = function(e) e), "error")
  if (!identical(r_ok, v$ok)) stop("Expectation for '", v$name, "' differs from R: R says ", r_ok, call. = FALSE)
  list(name = jsonlite::unbox(v$name), text = jsonlite::unbox(v$text), ok = jsonlite::unbox(r_ok))
})

write_fixture(list(
  api_base = jsonlite::unbox(sv_api_base()),
  merge_cases = merge_cases,
  kind_cases = kind_cases,
  token_cases = token_cases,
  validation_cases = validation_cases,
  stamp_cases = lapply(
    c("2031-01-01T09:00:00Z", "2031-01-01T09:00:00.5Z", "2031-01-01T09:00:00+02:00", "2031-01-01T09:00:00-0230",
      "2031-01-01 09:00:00", "2031-01-01", "2031-01-01T09:00:00", "2031-02-30T09:00:00Z", "2031-01-01T24:00:00Z",
      "2031-01-01T09:00:00+25:00", "yesterday", "2031-1-1", " 2031-01-01T09:00:00Z "),
    function(x) list(input = jsonlite::unbox(x), seconds = jsonlite::unbox(bundle_stamp_seconds(x)))
  )
), "small_cases.json.gz")
