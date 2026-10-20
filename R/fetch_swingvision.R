#' SwingVision public share API base URL
#'
#' This is the vendor's share API, which is undocumented and unofficial: it
#' has no published contract, so its endpoints and fields can change without
#' notice. Everything this package reads from it is parsed defensively (an
#' absent field becomes `NA`).
#' @keywords internal
sv_api_base <- function() "https://api.swing.tennis/v1"

#' Extract a SwingVision share token from a URL or bare token
#'
#' @param x A share URL like `https://swing.vision/matches/sw2-EXAMPLE01` or a
#'   bare token like `sw2-EXAMPLE01`.
#' @return The token string.
#' @export
sv_token <- function(x) {
  x <- trimws(x)
  if (grepl("/", x)) x <- sub("^.*/matches/", "", x)
  x <- sub("[?#].*$", "", x)
  x
}

#' Fetch and parse one match from the SwingVision public share API
#'
#' Given a share URL/token, GETs `/v1/matches/{token}` and
#' `/v1/matches/{token}/stats` and returns one tidy row. These share endpoints
#' are public (no authentication) for matches shared with a link.
#'
#' @param url_or_token A share URL or bare token (see [sv_token()]).
#' @param me The player name (as it appears in the SwingVision payload) to
#'   treat as "you". Required -- this package has no default player, unlike
#'   the private per-user package it was extracted from.
#' @return A one-row tibble (see [sv_parse_match()] for the columns).
#' @export
fetch_swingvision <- function(url_or_token, me) {
  token <- sv_token(url_or_token)
  base <- sv_api_base()
  match <- sv_get(sprintf("%s/matches/%s", base, token))$data
  stats <- sv_get(sprintf("%s/matches/%s/stats", base, token))$data
  sv_parse_match(match, stats, me = me, token = token)
}

#' @keywords internal
sv_get <- function(url) {
  resp <- httr2::request(url) |>
    httr2::req_user_agent("tennis-r personal-stats") |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform()
  httr2::resp_body_json(resp, simplifyVector = FALSE)
}

#' Parse a SwingVision match + stats payload into one tidy row
#'
#' Pure function over already-fetched JSON lists (no network) so it is unit
#' testable against committed fixtures.
#'
#' **Start times are not a stable anchor.** `played_at` (and `start_time`)
#' come from the match-level `started_at` field, which can change between
#' fetches of the same match (by minutes in one observed case). Other
#' candidate fields mean different things: `video_started_at` is when the
#' recording began, `first_point_at` is when the first point was tagged, and
#' the first tracked stroke is later again (set-up and warm-up before any
#' stroke is captured). None is interchangeable with another, so do not use
#' the match-level start as the anchor for "elapsed into session". Prefer a
#' property of the recording itself: `video_elapsed_sec` from the frame
#' number (see [sv_parse_shots()]), or the first tracked stroke's timestamp.
#'
#' @param match The `data` element of `/v1/matches/{token}`.
#' @param stats The `data` element of `/v1/matches/{token}/stats`.
#' @param me Player name (as it appears in the SwingVision payload) to treat
#'   as "you". Required.
#' @param token Optional share token to record for provenance.
#' @return A one-row tibble keyed on `match_id`.
#' @export
sv_parse_match <- function(match, stats, me, token = NA_character_) {
  side <- if (identical(match$guest_name, me)) "guest" else "host"
  opp  <- if (side == "guest") "host" else "guest"

  started <- sv_time(match$started_at)
  ended   <- sv_time(match$ended_at)
  dur_min <- as.integer(floor(as.numeric(match$recording_duration) / 60))

  right_handed <- isTRUE(match[[paste0(side, "_right_handed")]])
  s <- stats[[side]][[1]]            # set 0 = whole-session aggregate
  # For a right-hander the forehand is the right wing; swap if left-handed.
  fh_vel <- if (right_handed) s$average_right_wing_velocity else s$average_left_wing_velocity
  bh_vel <- if (right_handed) s$average_left_wing_velocity  else s$average_right_wing_velocity
  fh_n   <- if (right_handed) s$right_wing else s$left_wing
  bh_n   <- if (right_handed) s$left_wing  else s$right_wing

  me_shots  <- sv_num(match[[paste0(side, "_shot_count")]])
  me_in     <- sv_num(match[[paste0(side, "_shot_in")]])

  tibble::tibble(
    match_id      = sv_num(match$id),
    share_token   = token,
    played_at     = started,
    session_date  = as.Date(started, tz = "Europe/London"),
    start_time    = format(started, "%H:%M", tz = "Europe/London"),
    duration_min  = dur_min,
    sport         = sv_chr(match$sport_type),
    session_type  = sv_chr(match$session_type),
    is_doubles    = isTRUE(match$is_doubles),
    location      = sv_chr(match$court$name),
    surface       = sv_chr(match$court$surface),
    outdoor       = isTRUE(match$court$outdoor),
    latitude      = sv_num(match$latitude),
    longitude     = sv_num(match$longitude),
    opponent      = sv_chr(match[[paste0(opp, "_name")]]),
    me_shots    = me_shots,
    me_shots_in = me_in,
    shots_in_pct  = if (is.na(me_shots) || me_shots == 0) NA_real_ else round(100 * me_in / me_shots, 1),
    me_run_mi   = sv_num(match[[paste0(side, "_distance_run")]]),
    opp_shots     = sv_num(match[[paste0(opp, "_shot_count")]]),
    opp_run_mi    = sv_num(match[[paste0(opp, "_distance_run")]]),
    fh_shots      = sv_num(fh_n),
    bh_shots      = sv_num(bh_n),
    fh_speed_mph  = sv_mph(fh_vel),
    bh_speed_mph  = sv_mph(bh_vel),
    serves        = sv_num(s$serve),
    serves_in     = sv_num(s$serve_in),
    returns       = sv_num(s$first_return) + sv_num(s$second_return),
    winner        = sv_chr(match$winner)
  )
}

#' Fetch and parse per-shot data for one match from the SwingVision share API
#'
#' GETs the undocumented `/v1/matches/{token}/shots` endpoint -- a separate
#' endpoint from [fetch_swingvision()] (session-aggregate). Same public
#' share-token auth model, confirmed live. Per-shot timestamps and hit_type let a
#' session be segmented into its drill parts.
#'
#' @param url_or_token A share URL or bare token (see [sv_token()]).
#' @return A tibble, one row per shot (see [sv_parse_shots()] for columns).
#' @export
fetch_swingvision_shots <- function(url_or_token) {
  token <- sv_token(url_or_token)
  base <- sv_api_base()
  shots <- sv_get(sprintf("%s/matches/%s/shots", base, token))$data
  sv_parse_shots(shots)
}

#' Parse a SwingVision per-shot payload into a tidy one-row-per-shot table
#'
#' Pure function over an already-fetched JSON list (no network) so it is unit
#' testable against committed fixtures. `spin_type` is categorical (e.g.
#' `flat`/`topspin`/`slice`) -- there is no numeric spin-rate field (rpm) in
#' this endpoint, and the vendor's own spreadsheet export is categorical too,
#' so do not look for one (see rallyr#2). A chart or metric that wants a spin
#' rate should show that gap rather than drop the question.
#'
#' `shot_in` is derived from `net_type`/`bounce_location_long`/
#' `bounce_location_lat` (see [sv_shot_in()]) -- the `/shots` payload has no
#' explicit in/out flag. Validated live against `sw2-EXAMPLE01`'s known
#' session-level accuracy (`/stats` endpoint: 589/714 = 82.5%): the
#' bounce/net-derived rate came out 83.6% (597/714) -- close but not exact,
#' so treat `shot_in` as directionally reliable per-shot signal, not a
#' bit-exact reproduction of the `/stats` endpoint's own count.
#'
#' `rally_id` is the payload's own `pid` field, taken as-is (not derived).
#' Verified live against `sw2-EXAMPLE01`: sorted by `started_at`, every `pid`
#' value forms one contiguous run of shots -- SwingVision already segments
#' the match into points/rallies itself, so this does not need a time-gap
#' heuristic. `rally_id` is unique only *within* a `match_id`, not globally
#' -- pair with `match_id` to identify a rally.
#'
#' Beyond the core columns, the shot table keeps the fields later checks
#' need, so they never require a live re-fetch (rallyr#20): `hit_frame` (the
#' video frame number of the stroke), `hit_court_side`/`bounce_court_side`,
#' `net_clearance_m` (see [sv_net_clearance_m()]), the categorical
#' `bounce_location_long`/`bounce_location_lat`, numeric hit and bounce
#' coordinates (`hit_x`/`hit_y`/`hit_z`, `bounce_x`/`bounce_y`/`bounce_z`,
#' as supplied by the API; units are not verified) and the three raw
#' `hit_velocity_*` components (m/s, as supplied) that `shot_speed_mph` is
#' the magnitude of. A field absent from a shot is `NA`. Other raw fields are
#' deliberately not persisted.
#'
#' @param shots The `data` element of `/v1/matches/{token}/shots` -- a list
#'   of shot objects.
#' @return A tibble, one row per shot, sorted by `started_at` ascending.
#' @export
sv_parse_shots <- function(shots) {
  if (length(shots) == 0L) {
    return(tibble::tibble(
      match_id        = numeric(0),
      shot_id         = numeric(0),
      rally_id        = numeric(0),
      player          = character(0),
      started_at      = as.POSIXct(character(0)),
      ended_at        = as.POSIXct(character(0)),
      hit_wing        = character(0),
      hit_type        = character(0),
      spin_type       = character(0),
      shot_speed_mph  = numeric(0),
      shot_in         = logical(0),
      hit_frame            = numeric(0),
      video_elapsed_sec    = numeric(0),
      hit_court_side       = character(0),
      bounce_court_side    = character(0),
      net_clearance_m      = numeric(0),
      bounce_location_long = character(0),
      bounce_location_lat  = character(0),
      hit_x = numeric(0), hit_y = numeric(0), hit_z = numeric(0),
      bounce_x = numeric(0), bounce_y = numeric(0), bounce_z = numeric(0),
      hit_velocity_x = numeric(0), hit_velocity_y = numeric(0), hit_velocity_z = numeric(0)
    ))
  }

  rows <- lapply(shots, function(sh) {
    tibble::tibble(
      match_id       = sv_num(sh$match_id),
      shot_id        = sv_num(sh$id),
      rally_id       = sv_num(sh$pid),
      player         = sv_chr(sh$player),
      started_at     = sv_time(sh$started_at),
      ended_at       = sv_time(sh$ended_at),
      hit_wing       = sv_chr(sh$hit_wing),
      hit_type       = sv_chr(sh$hit_type),
      spin_type      = sv_chr(sh$spin_type),
      shot_speed_mph = sv_speed_mph(sh$hit_velocity),
      shot_in        = sv_shot_in(sh$net_type, sh$bounce_location_long, sh$bounce_location_lat),
      hit_frame            = sv_num(sh$hit_frame),
      video_elapsed_sec    = sv_video_elapsed_sec(sh$hit_frame),
      hit_court_side       = sv_chr(sh$hit_court_side),
      bounce_court_side    = sv_chr(sh$bounce_court_side),
      net_clearance_m      = sv_net_clearance_m(sh$net_location),
      bounce_location_long = sv_chr(sh$bounce_location_long),
      bounce_location_lat  = sv_chr(sh$bounce_location_lat),
      hit_x    = sv_component(sh$hit_location, 1L),
      hit_y    = sv_component(sh$hit_location, 2L),
      hit_z    = sv_component(sh$hit_location, 3L),
      bounce_x = sv_component(sh$bounce_location, 1L),
      bounce_y = sv_component(sh$bounce_location, 2L),
      bounce_z = sv_component(sh$bounce_location, 3L),
      hit_velocity_x = sv_component(sh$hit_velocity, 1L),
      hit_velocity_y = sv_component(sh$hit_velocity, 2L),
      hit_velocity_z = sv_component(sh$hit_velocity, 3L)
    )
  })

  dplyr::bind_rows(rows) |> dplyr::arrange(started_at)
}

#' Derive whether a shot landed in play from net/bounce fields
#'
#' The `/shots` payload has no explicit in/out flag. A shot is treated as
#' out if it hit the net (`net_type == "net"`) or its bounce landed in an
#' out-of-bounds zone (`bounce_location_long == "out"`, or
#' `bounce_location_lat` is `"ad_out"`/`"deuce_out"`). See [sv_parse_shots()]
#' for the live validation against a known session-level accuracy figure.
#'
#' @param net_type,bounce_location_long,bounce_location_lat Raw fields from
#'   one shot object.
#' @return A length-1 logical, `TRUE` unless the shot is judged out.
#' @keywords internal
sv_shot_in <- function(net_type, bounce_location_long, bounce_location_lat) {
  nt  <- sv_chr(net_type)
  bl  <- sv_chr(bounce_location_long)
  bla <- sv_chr(bounce_location_lat)
  out <- isTRUE(nt == "net") || isTRUE(bl == "out") || (bla %in% c("ad_out", "deuce_out"))
  !out
}

# ---- small coercers --------------------------------------------------------

#' Parse a SwingVision ISO-8601 timestamp, keeping sub-second precision
#'
#' The API returns millisecond timestamps such as `"...T10:00:00.742000Z"`.
#' The fraction is kept (`%OS`): per-shot gaps drive rally-boundary
#' detection, so rounding every stroke to the whole second throws away the
#' signal being measured (rallyr#14). The fraction lives in the underlying
#' double; set `options(digits.secs = 3)` only to *print* it.
#'
#' @param x A timestamp string (or character vector), or `NULL`.
#' @return A `POSIXct` in UTC; `NA` for `NULL`.
#' @keywords internal
sv_time <- function(x) {
  if (is.null(x)) return(as.POSIXct(NA))
  as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
}
#' Video frame rate used to turn a frame number into elapsed time
#'
#' **Pinned, not fitted per recording.** The value was calibrated once, from
#' shot frame numbers against shot timestamps across a batch of recordings,
#' where it held to a fraction of a percent for all but one. That one had a
#' recording-hardware fault, and an earlier per-recording fit silently
#' absorbed it into a plausible-looking but wrong rate. Fitting a fresh rate
#' to each recording therefore hides exactly the fault worth seeing: keep
#' this constant, and use [sv_video_drift()] to surface a recording whose
#' timing disagrees with it. Re-derive the constant only from a batch of
#' recordings, never from one.
#'
#' @return A length-1 numeric, frames per second.
#' @keywords internal
sv_fps <- function() 60.006

#' Elapsed time since the start of the video, from a shot's `hit_frame`
#'
#' Frame 0 is the start of the recorded video, so `hit_frame / fps` is a time
#' a person can type into a video player to find the stroke. It does not
#' depend on the match-level start time, which is not stable across fetches
#' (see [sv_parse_match()]). Video time restarts at 0 for each recording: a
#' stroke is identified by recording plus time, never by time alone. Use
#' [fmt_video_time()] for display.
#'
#' @param hit_frame Raw `hit_frame` field from one shot object (may be
#'   `NULL`).
#' @return A length-1 numeric (seconds), or `NA_real_` if unavailable.
#' @keywords internal
sv_video_elapsed_sec <- function(hit_frame) {
  f <- sv_num(hit_frame)
  if (is.na(f)) return(NA_real_)
  f / sv_fps()
}

#' Check a recording's frame timing against the pinned frame rate
#'
#' Fits the implied frame rate from `(frame, timestamp)` pairs --
#' `(frame_last - frame_first) / (time_last - time_first)` over the earliest
#' and latest pair -- and compares it with [sv_fps()]. It reports a verdict
#' and never re-fits the pinned rate. Three outcomes:
#'
#' * `"PASS"`: the implied rate is within `tol` (relative) of the pinned one.
#' * `"DRIFT"`: it is not; treat the recording as a data-quality problem.
#' * `"INDETERMINATE"`: too few usable pairs, or pairs too close in time, to
#'   say; `reason` says why. This is not a pass.
#'
#' @param frame Numeric frame numbers (`hit_frame`).
#' @param started_at `POSIXct` timestamps of the same shots, same length.
#' @param tol Relative tolerance, default 1%.
#' @param min_pairs Minimum usable (non-`NA`) pairs, default 2.
#' @param min_span_sec Minimum time between the earliest and latest pair, in
#'   seconds, default 60: over a shorter span timestamp noise swamps the fit.
#' @return A one-row tibble: `status`, `implied_fps` (`NA` if
#'   indeterminate), `pinned_fps`, `rel_diff` (implied vs pinned, relative),
#'   `n_pairs`, `reason` (`NA` unless indeterminate).
#' @export
sv_video_drift <- function(frame, started_at, tol = 0.01, min_pairs = 2L, min_span_sec = 60) {
  if (length(frame) != length(started_at)) {
    cli::cli_abort(c(
      "x" = "{.arg frame} and {.arg started_at} must have the same length.",
      "i" = "Got {length(frame)} and {length(started_at)}."
    ))
  }
  pinned <- sv_fps()
  t <- as.numeric(started_at)
  ok <- !is.na(frame) & !is.na(t)
  frame <- as.numeric(frame)[ok]
  t <- t[ok]
  result <- function(status, implied = NA_real_, reason = NA_character_) {
    tibble::tibble(
      status = status, implied_fps = implied, pinned_fps = pinned,
      rel_diff = implied / pinned - 1, n_pairs = length(t), reason = reason
    )
  }
  if (length(t) < min_pairs) {
    return(result("INDETERMINATE", reason = sprintf("%d usable pairs, need %d", length(t), min_pairs)))
  }
  first <- which.min(t)
  last <- which.max(t)
  span <- t[last] - t[first]
  if (span < min_span_sec) {
    return(result("INDETERMINATE", reason = sprintf("pairs span %.1f s, need %.0f s", span, min_span_sec)))
  }
  implied <- (frame[last] - frame[first]) / span
  result(if (abs(implied / pinned - 1) <= tol) "PASS" else "DRIFT", implied)
}

#' Net-clearance height, in metres, from a shot's `net_location`
#'
#' The third element of `net_location` is the ball's height as it crosses the
#' net plane. The value is raw and not cleaned: no plausibility threshold is
#' applied here (see [dq_clean_net_clearance()]). The vendor does not state
#' whether it is above the ground or above the net tape.
#'
#' @param net_location Raw `net_location` field (a list/vector, or `NULL`).
#' @return A length-1 numeric (metres), or `NA_real_` if unavailable.
#' @keywords internal
sv_net_clearance_m <- function(net_location) sv_component(net_location, 3L)

#' The `i`-th element of a raw numeric vector field, or `NA`
#' @param v A list/vector field from one shot object, or `NULL`.
#' @param i Element index.
#' @return A length-1 numeric.
#' @keywords internal
sv_component <- function(v, i) {
  if (is.null(v) || length(v) < i || is.null(v[[i]])) return(NA_real_)
  sv_num(v[[i]])
}
#' @keywords internal
sv_num <- function(x) if (is.null(x)) NA_real_ else as.numeric(x)
#' @keywords internal
sv_chr <- function(x) if (is.null(x) || length(x) == 0) NA_character_ else as.character(x)
#' @keywords internal
sv_mph <- function(velocity_ms) {
  v <- sv_num(velocity_ms)
  if (is.na(v) || v == 0) NA_real_ else round(v * 2.2369362920544, 1)
}
#' @keywords internal
sv_speed_mph <- function(velocity_vec) {
  if (is.null(velocity_vec) || length(velocity_vec) == 0L) return(NA_real_)
  vals <- vapply(velocity_vec, function(x) if (is.null(x)) NA_real_ else as.numeric(x), numeric(1))
  if (anyNA(vals)) return(NA_real_)
  sv_mph(sqrt(sum(vals^2)))
}
