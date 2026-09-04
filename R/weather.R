#' Open-Meteo historical weather API base URL
#'
#' Free, no-auth historical-weather API — see
#' <https://open-meteo.com/en/docs/historical-weather-api>.
#' @keywords internal
weather_api_base <- function() "https://archive-api.open-meteo.com/v1/archive"

#' Fetch one day's hourly temperature + wind for a session's location
#'
#' Every session's `latitude`/`longitude` is already captured by
#' [sv_parse_match()]; this looks up the ambient weather at that location on
#' that date. Fetched for every session regardless of indoor/outdoor — wind
#' is only meaningful outdoors, but temperature is a reasonable proxy for
#' ambient/exertion conditions either way (ISSUES.md #3's fatigue
#' investigation: is the 1st-vs-2nd net-volley rally-length drop actually a
#' temperature confound?).
#'
#' @param lat,lon Session location (`matches$latitude`/`longitude`).
#' @param date A `Date` (or "YYYY-MM-DD" string) — `matches$session_date`.
#' @param tz IANA timezone for the hourly series, so "hour 13" means local
#'   13:00 at the venue, not UTC. Defaults to `"Europe/London"` — this
#'   project's only location so far.
#' @return The parsed JSON payload (`$hourly$time`, `$hourly$temperature_2m`,
#'   `$hourly$wind_speed_10m`, `$hourly$wind_gusts_10m`) — see
#'   [weather_parse()] to reduce it to one row. Gust speed matters as much as
#'   average for tennis (a strong gust disrupts a single shot; the average
#'   doesn't capture that), so both are fetched.
#' @export
fetch_weather <- function(lat, lon, date, tz = "Europe/London") {
  date <- as.character(date)
  url <- sprintf(
    "%s?latitude=%s&longitude=%s&start_date=%s&end_date=%s&hourly=temperature_2m,wind_speed_10m,wind_gusts_10m&timezone=%s",
    weather_api_base(), lat, lon, date, date, utils::URLencode(tz, reserved = TRUE)
  )
  resp <- httr2::request(url) |>
    httr2::req_user_agent("tennis-r personal-stats") |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform()
  httr2::resp_body_json(resp, simplifyVector = FALSE)
}

#' Reduce an Open-Meteo hourly payload to the hour nearest a session start
#'
#' @param payload The list returned by [fetch_weather()] (or an equivalent
#'   hand-built list in tests — see `tests/testthat/test-weather.R`).
#' @param start_time A `"HH:MM"` string (`matches$start_time`).
#' @return A one-row tibble: `temp_c`, `wind_avg_kmh`, `wind_gust_kmh`.
#' @export
weather_parse <- function(payload, start_time) {
  h <- payload$hourly
  if (is.null(h) || length(h$time) == 0L) {
    stop("Open-Meteo payload has no hourly series", call. = FALSE)
  }
  times <- vapply(h$time, function(x) as.character(x), character(1))
  hour_mins <- as.integer(substr(times, 12, 13)) * 60L
  target_min <- as.integer(substr(start_time, 1, 2)) * 60L + as.integer(substr(start_time, 4, 5))
  idx <- which.min(abs(hour_mins - target_min))
  tibble::tibble(
    temp_c       = as.numeric(h$temperature_2m[[idx]]),
    wind_avg_kmh = as.numeric(h$wind_speed_10m[[idx]]),
    wind_gust_kmh = as.numeric(h$wind_gusts_10m[[idx]])
  )
}

#' Fetch + parse weather for one session, in one call
#'
#' @inheritParams fetch_weather
#' @param start_time A `"HH:MM"` string (`matches$start_time`).
#' @return A one-row tibble: `temp_c`, `wind_avg_kmh`, `wind_gust_kmh` (see
#'   [weather_parse()]).
#' @export
sv_session_weather <- function(lat, lon, date, start_time, tz = "Europe/London") {
  payload <- fetch_weather(lat, lon, date, tz = tz)
  weather_parse(payload, start_time)
}
