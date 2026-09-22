#' SwingVision public share API base URL
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
#' share-token auth model, confirmed live. See issue #1 and #3 for how
#' this was found and what it unblocks (per-shot timestamps + hit_type let a
#' session be segmented into its drill parts).
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
#' `flat`/`topspin`/`slice`) -- there is no numeric spin-rate field in this
#' endpoint (see issue #1).
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
      shot_in         = logical(0)
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
      shot_in        = sv_shot_in(sh$net_type, sh$bounce_location_long, sh$bounce_location_lat)
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

#' @keywords internal
sv_time <- function(x) {
  if (is.null(x)) return(as.POSIXct(NA))
  as.POSIXct(sub("\\.\\d+Z$", "Z", x), format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
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
