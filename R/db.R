#' Connect to the tennis DuckDB database
#'
#' @param path Path to the DuckDB file. Defaults to `tennis.duckdb` in the
#'   current working directory.
#' @return A DBI connection. Close it with [DBI::dbDisconnect()] (pass
#'   `shutdown = TRUE`).
#' @export
tennis_db_connect <- function(path = "tennis.duckdb") {
  DBI::dbConnect(duckdb::duckdb(), dbdir = path)
}

#' Upsert rows into a database table (idempotent)
#'
#' Writes rows to `table` (default `"matches"`). Rows are keyed on `key`
#' (default `match_id`, the SwingVision match id from [fetch_swingvision()]):
#' any existing rows with a matching key are deleted and replaced, so
#' re-fetching a previous week is a no-op (or an in-place correction). A
#' one-to-many key (several rows sharing one `key` value, e.g. several
#' segments per `match_id`) works the same way — every existing row for that
#' key is deleted, then all of the new rows are appended.
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @param matches A tibble from [fetch_swingvision()] (or [parse_swingvision()]
#'   with `key = "played_at"`), or any other tibble to upsert into `table`.
#' @param key Name of the key column. Defaults to `"match_id"`.
#' @param table Name of the destination table. Defaults to `"matches"`.
#' @return Invisibly, the number of rows written.
#' @export
tennis_db_upsert <- function(con, matches, key = "match_id", table = "matches") {
  if (nrow(matches) == 0L) return(invisible(0L))
  stopifnot(key %in% names(matches))
  matches <- as.data.frame(matches)
  for (col in names(matches)) {
    if (inherits(matches[[col]], "POSIXct") || inherits(matches[[col]], "Date")) {
      matches[[col]] <- as.character(matches[[col]])
    }
  }

  if (!DBI::dbExistsTable(con, table)) {
    DBI::dbWriteTable(con, table, matches)
    return(invisible(nrow(matches)))
  }

  keys <- unique(matches[[key]])
  DBI::dbExecute(
    con,
    sprintf(
      "DELETE FROM %s WHERE %s IN (?)",
      DBI::dbQuoteIdentifier(con, table),
      DBI::dbQuoteIdentifier(con, key)
    ),
    params = list(keys)
  )
  DBI::dbAppendTable(con, table, matches)
  invisible(nrow(matches))
}

#' Read the matches table back as a tibble
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @return A tibble of all stored matches, ordered by `played_at`.
#' @export
tennis_matches <- function(con) {
  if (!DBI::dbExistsTable(con, "matches")) return(parse_swingvision(""))
  out <- DBI::dbGetQuery(con, "SELECT * FROM matches ORDER BY played_at")
  tibble::as_tibble(out)
}

#' Read the shot_segments table back as a tibble
#'
#' Drill-phase segments per match, as written by `scripts/update_segments.R`
#' (one or more rows per `match_id`, from [segment_session_shots()] plus
#' `n_guest_gs_left`/`n_guest_gs_right` wing counts and guest speed/accuracy
#' stats — see that script for how those extra columns are derived).
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @return A tibble of all stored segments, ordered by `match_id`,
#'   `segment_index`. Empty (zero-row, correctly-typed) if the table doesn't
#'   exist yet.
#' @export
tennis_segments <- function(con) {
  if (!DBI::dbExistsTable(con, "shot_segments")) {
    return(tibble::tibble(
      match_id           = numeric(0),
      segment_index       = integer(0),
      regime              = character(0),
      regime_occurrence   = numeric(0),
      start_time          = as.POSIXct(character(0)),
      end_time            = as.POSIXct(character(0)),
      duration_min        = numeric(0),
      n_shots             = numeric(0),
      n_host_shots        = numeric(0),
      n_guest_shots       = numeric(0),
      n_guest_gs_left     = numeric(0),
      n_guest_gs_right    = numeric(0),
      guest_speed_mean_mph   = numeric(0),
      guest_speed_median_mph = numeric(0),
      guest_in_pct            = numeric(0)
    ))
  }
  out <- DBI::dbGetQuery(con, "SELECT * FROM shot_segments ORDER BY match_id, segment_index")
  tibble::as_tibble(out) |>
    dplyr::mutate(
      start_time = as.POSIXct(start_time, tz = "UTC"),
      end_time   = as.POSIXct(end_time, tz = "UTC")
    )
}

#' Read the shot_detail table back as a tibble
#'
#' Per-shot rows tagged with their drill-phase segment and rally, as written
#' by `scripts/update_segments.R`: one row per shot per match, with
#' `segment_index`/`regime` joined on from that match's `shot_segments` rows,
#' and `rally_id` from the shot's own `pid` field (see [sv_parse_shots()]).
#' This is the pooled, shot-level source for distribution/percentile views
#' (e.g. shot-speed spread within each regime) — [tennis_segments()] only
#' has per-segment summary statistics, not the underlying shots.
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @return A tibble of all stored shot rows. Empty (zero-row, correctly-typed)
#'   if the table doesn't exist yet.
#' @export
tennis_shot_detail <- function(con) {
  if (!DBI::dbExistsTable(con, "shot_detail")) {
    return(tibble::tibble(
      match_id       = numeric(0),
      shot_id        = numeric(0),
      rally_id       = numeric(0),
      player         = character(0),
      started_at     = as.POSIXct(character(0)),
      hit_type       = character(0),
      hit_wing       = character(0),
      spin_type      = character(0),
      shot_speed_mph = numeric(0),
      shot_in        = logical(0),
      segment_index  = integer(0),
      regime         = character(0),
      regime_occurrence = numeric(0)
    ))
  }
  out <- DBI::dbGetQuery(con, "SELECT * FROM shot_detail")
  tibble::as_tibble(out) |>
    dplyr::mutate(
      shot_in    = as.logical(shot_in),
      started_at = as.POSIXct(started_at, tz = "UTC")
    )
}

#' Read the rallies table back as a tibble
#'
#' One row per rally (point), as written by `scripts/update_segments.R` from
#' the shots' own `rally_id` (SwingVision's `pid` field — see
#' [sv_parse_shots()]): `n_shots`, `duration_sec`, and the `regime` the
#' rally sits within (the mode of its shots' regimes).
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @return A tibble of all stored rallies, ordered by `match_id`, `rally_id`.
#'   Empty (zero-row, correctly-typed) if the table doesn't exist yet.
#' @export
tennis_rallies <- function(con) {
  if (!DBI::dbExistsTable(con, "rallies")) {
    return(tibble::tibble(
      match_id     = numeric(0),
      rally_id     = numeric(0),
      start_time   = as.POSIXct(character(0)),
      end_time     = as.POSIXct(character(0)),
      duration_sec = numeric(0),
      n_shots      = numeric(0),
      segment_index = numeric(0),
      regime       = character(0),
      regime_occurrence = numeric(0)
    ))
  }
  out <- DBI::dbGetQuery(con, "SELECT * FROM rallies ORDER BY match_id, rally_id")
  tibble::as_tibble(out) |>
    dplyr::mutate(
      start_time = as.POSIXct(start_time, tz = "UTC"),
      end_time   = as.POSIXct(end_time, tz = "UTC")
    )
}

#' Read the session_weather table back as a tibble
#'
#' One row per match, as written by `scripts/update_weather.R` from the
#' Open-Meteo historical-weather API (see [fetch_weather()],
#' [sv_session_weather()]): ambient `temp_c`, `wind_avg_kmh` and
#' `wind_gust_kmh` for the hour
#' nearest that session's start time, at that session's location
#' (`matches$latitude`/`longitude`). Fetched for every session regardless of
#' indoor/outdoor — see `R/weather.R`'s header for why.
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @return A tibble of all stored session weather, ordered by `match_id`.
#'   Empty (zero-row, correctly-typed) if the table doesn't exist yet.
#' @export
tennis_weather <- function(con) {
  if (!DBI::dbExistsTable(con, "session_weather")) {
    return(tibble::tibble(
      match_id      = numeric(0),
      temp_c        = numeric(0),
      wind_avg_kmh  = numeric(0),
      wind_gust_kmh = numeric(0)
    ))
  }
  out <- DBI::dbGetQuery(con, "SELECT * FROM session_weather ORDER BY match_id")
  tibble::as_tibble(out)
}

#' Read the manual indoor/outdoor override
#'
#' The SwingVision API's `court.outdoor` field is a single venue-level
#' profile, not a per-session value, and is wrong for most sessions at a
#' venue with both indoor and outdoor courts — see issue #2. Until a
#' reliable per-session API field exists, indoor/outdoor is recorded here by
#' hand (verified per session by inspecting that session's video thumbnail),
#' as the single source of truth for every consumer (currently
#' `scripts/make_artifact_charts.R`; `dashboard.qmd` may adopt it too).
#'
#' @param path Path to the override file, `session_date,TRUE|FALSE` per line.
#'   Defaults to `data-raw/indoor_overrides.txt`, resolved relative to the
#'   current working directory (repo root — callers `setwd()` there first,
#'   matching [tennis_db_connect()] and `scripts/update_db.R`).
#' @return A named logical vector, keyed by `session_date` formatted
#'   `"YYYY-MM-DD"`.
#' @export
read_indoor_overrides <- function(path = "data-raw/indoor_overrides.txt") {
  if (!file.exists(path)) {
    stop("Indoor override file not found: ", path, call. = FALSE)
  }
  lines <- trimws(readLines(path, warn = FALSE))
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  if (length(lines) == 0L) {
    stop("Indoor override file has no data rows: ", path, call. = FALSE)
  }

  parts <- strsplit(lines, ",", fixed = TRUE)
  bad <- lengths(parts) != 2L
  if (any(bad)) {
    stop(
      "Malformed indoor-override line(s) (expected 'date,TRUE|FALSE'): ",
      paste(lines[bad], collapse = "; "),
      call. = FALSE
    )
  }

  dates <- trimws(vapply(parts, `[[`, character(1), 1L))
  vals  <- trimws(vapply(parts, `[[`, character(1), 2L))

  parsed_dates <- as.Date(dates, format = "%Y-%m-%d")
  if (anyNA(parsed_dates)) {
    stop(
      "Unparseable date(s) in indoor override file: ",
      paste(dates[is.na(parsed_dates)], collapse = "; "),
      call. = FALSE
    )
  }
  if (!all(vals %in% c("TRUE", "FALSE"))) {
    stop(
      "Indoor override values must be TRUE or FALSE, got: ",
      paste(unique(vals[!vals %in% c("TRUE", "FALSE")]), collapse = "; "),
      call. = FALSE
    )
  }
  if (anyDuplicated(dates) != 0L) {
    stop(
      "Duplicate session_date(s) in indoor override file: ",
      paste(unique(dates[duplicated(dates)]), collapse = "; "),
      call. = FALSE
    )
  }

  out <- vals == "TRUE"
  names(out) <- dates
  out
}

#' Introspect the database schema (structure only, never data)
#'
#' Returns table and column names/types from DuckDB's
#' `information_schema.columns`, with zero relationship to row count or row
#' values. Safe to publish alongside a public package template (the issue tracker
#' #9/#31) even though `con` may point at the real, private `tennis.duckdb`
#' — the return carries only column definitions, never a data value or a
#' count of rows. Also the natural building block for a derived-data API
#' (issue #44), since a consumer of that API needs to know the shape of
#' what it can query before querying it.
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @return A tibble with one row per (table, column): `table_name`,
#'   `column_name`, `data_type`, `ordinal_position` (1-based position within
#'   the table). Empty (zero-row, correctly-typed) if the database has no
#'   user tables yet.
#' @export
tennis_db_schema <- function(con) {
  out <- DBI::dbGetQuery(
    con,
    "SELECT table_name, column_name, data_type, ordinal_position
     FROM information_schema.columns
     WHERE table_schema = 'main'
     ORDER BY table_name, ordinal_position"
  )
  tibble::as_tibble(out)
}

#' Merge same-day matches into one session (display-only)
#'
#' SwingVision records a long practice as several back-to-back "matches" (a
#' recording stopped and restarted mid-session produces two `match_id`s for
#' what was one continuous session — e.g. 6 Jul 2026 is 13:04 + 13:50).
#' Anything reporting on session-level trends (dashboards, artifacts, charts)
#' MUST call this before aggregating or plotting per-session data, or the
#' split parts silently double-count as two sessions. The database itself
#' stays per-match — this merge is display-only and never written back.
#'
#' Counts, distance and duration sum across parts. Shot-in accuracy is
#' recomputed from the pooled totals (not averaged per-part). Forehand/
#' backhand speed is shot-count-weighted, computed from the per-match vectors
#' before those columns are summed (`dplyr::summarise()` lets later columns
#' see already-reduced earlier ones, so the weighting step must come first).
#'
#' @param matches A tibble from [tennis_matches()] (one row per `match_id`).
#' @return A tibble with one row per `session_date`, plus `n_parts` (how many
#'   matches merged) and `start_times` (every part's start time, comma-joined).
#' @export
merge_same_day_sessions <- function(matches) {
  matches |>
    dplyr::mutate(
      played_at = as.POSIXct(played_at, tz = "Europe/London"),
      session_date = as.Date(session_date)
    ) |>
    dplyr::group_by(session_date) |>
    dplyr::summarise(
      played_at     = min(played_at),
      start_times   = paste(sort(start_time), collapse = ", "),
      n_parts       = dplyr::n(),
      opponent      = dplyr::first(opponent),
      location      = dplyr::first(location),
      duration_min  = sum(duration_min),
      me_shots    = sum(me_shots),
      me_shots_in = sum(me_shots_in),
      me_run_mi   = sum(me_run_mi),
      opp_shots     = sum(opp_shots),
      opp_run_mi    = sum(opp_run_mi),
      # Weighted by shot count — MUST precede the fh_shots/bh_shots sums below.
      fh_speed_mph  = round(stats::weighted.mean(fh_speed_mph, fh_shots, na.rm = TRUE), 1),
      bh_speed_mph  = round(stats::weighted.mean(bh_speed_mph, bh_shots, na.rm = TRUE), 1),
      fh_shots      = sum(fh_shots),
      bh_shots      = sum(bh_shots),
      .groups = "drop"
    ) |>
    dplyr::mutate(shots_in_pct = round(100 * me_shots_in / me_shots, 1)) |>
    dplyr::arrange(played_at)
}
