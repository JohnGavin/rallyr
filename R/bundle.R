#' Bundles: a portable file of raw session payloads
#'
#' A *bundle* is one file that holds the **raw** API payloads of every session
#' a person has collected, so the same history can be loaded in R and in the
#' browser app without a database. It is a gzip-compressed JSON document:
#'
#' ```
#' { "schema_version": 1,
#'   "sessions": [ { "match_id": 123, "fetched_at": "...", "token": "...",
#'                   "match": <payload>, "stats": <payload>, "shots": <payload> } ] }
#' ```
#'
#' The three payloads are stored exactly as the share API returned them
#' (`/matches/{token}`, `/matches/{token}/stats`, `/matches/{token}/shots`), so
#' every derived value can be recomputed with the current parsers and rules and
#' nothing is lost to an early parse. Numbers round-trip to 15 significant
#' digits. `token` is optional and only recorded when you supply it.
#'
#' | Function | Purpose |
#' |---|---|
#' | `bundle_new()` | An empty bundle |
#' | `bundle_read()`, `bundle_write()` | Read and write a bundle file |
#' | `bundle_payload_kind()` | Tell a match, stats or shots payload apart by content |
#' | `bundle_add_raw()` | Add one session from its three saved payloads |
#' | `bundle_merge()` | Merge two bundles by `match_id` |
#' | `bundle_players()` | Player names found in a bundle |
#' | `bundle_to_tables()` | Parse a bundle into the tables the metrics read |
#' | `bundle_derived()` | The derived-data interface, from those tables |
#'
#' `bundle_to_tables()` and `bundle_derived()` need no database: they are what
#' the browser app runs.
#'
#' @section Bundle schema version:
#' `schema_version` (see [bundle_schema_version()]) is the version of the file
#' format, separate from [rallyr_schema_version()]. A file with a higher
#' version than this package supports is refused, never read partly.
#'
#' @name rallyr-bundle
#' @seealso [sv_download_raw()] to save the raw payloads in R.
NULL

#' Schema version of the bundle file format
#'
#' @return A single integer (currently `1L`).
#' @export
#' @examples
#' bundle_schema_version()
bundle_schema_version <- function() 1L

#' @rdname rallyr-bundle
#' @return `bundle_new()` returns an empty bundle (class `rallyr_bundle`).
#' @export
bundle_new <- function() {
  structure(
    list(schema_version = bundle_schema_version(), sessions = list()),
    class = "rallyr_bundle"
  )
}

#' @export
print.rallyr_bundle <- function(x, ...) {
  n <- length(x$sessions)
  v <- x$schema_version
  cli::cat_line(cli::format_inline("A rallyr bundle: {n} session{?s} (file format version {v})."))
  invisible(x)
}

# ---- reading JSON ----------------------------------------------------------

# The largest file, and the largest decompressed text, that is read (bytes).
# One home for the number: `options(rallyr.bundle_max_bytes = <bytes>)` changes
# it. 50 MB is far above a real bundle (a few MB) and keeps a browser tab alive.
bundle_max_bytes <- function() {
  v <- getOption("rallyr.bundle_max_bytes", 50 * 1024^2)
  if (!is.numeric(v) || length(v) != 1L || is.na(v) || v <= 0) {
    cli::cli_abort("{.code options(rallyr.bundle_max_bytes)} must be a single positive number of bytes.")
  }
  v
}

bundle_mb <- function(bytes) format(round(bytes / 1024^2, 1), nsmall = 1, trim = TRUE)

# Text of a file that is either gzip-compressed or plain JSON, refusing a file
# over `max_bytes` and a gzip file that expands past `max_bytes`.
bundle_read_text <- function(path, max_bytes = bundle_max_bytes()) {
  if (!is.numeric(max_bytes) || length(max_bytes) != 1L || is.na(max_bytes) || max_bytes <= 0) {
    cli::cli_abort("{.arg max_bytes} must be a single positive number of bytes.")
  }
  if (!is.character(path) || length(path) != 1L || is.na(path) || !file.exists(path)) {
    cli::cli_abort(c(
      "x" = "{.arg path} must be the path of an existing file.",
      "i" = "Got {.val {if (is.character(path) && length(path) == 1L) path else class(path)}}."
    ))
  }
  size <- file.size(path)
  if (size > max_bytes) {
    cli::cli_abort(c(
      "x" = "The file {.file {path}} is too large ({bundle_mb(size)} MB; the limit is {bundle_mb(max_bytes)} MB).",
      "i" = "A bundle of sessions is a few MB. Check that this is the right file."
    ))
  }
  bytes <- readBin(path, "raw", n = size)
  if (length(bytes) == 0L) {
    cli::cli_abort("The file {.file {path}} is empty.")
  }
  if (length(bytes) >= 2L && bytes[1] == as.raw(0x1f) && bytes[2] == as.raw(0x8b)) {
    con <- gzcon(rawConnection(bytes))
    on.exit(close(con), add = TRUE)
    chunks <- list()
    total <- 0
    repeat {
      chunk <- readBin(con, "raw", n = 1024^2)
      if (length(chunk) == 0L) break
      total <- total + length(chunk)
      if (total > max_bytes) {
        cli::cli_abort(c(
          "x" = "The file {.file {path}} is too large once uncompressed (more than {bundle_mb(max_bytes)} MB).",
          "i" = "A bundle of sessions is a few MB. Check that this is the right file."
        ))
      }
      chunks[[length(chunks) + 1L]] <- chunk
    }
    bytes <- unlist(chunks, use.names = FALSE)
    if (is.null(bytes)) cli::cli_abort("The file {.file {path}} is empty.")
  }
  txt <- rawToChar(bytes)
  Encoding(txt) <- "UTF-8"
  txt
}

# `jsonlite::fromJSON()` treats a string that is a URL or an existing file path
# as something to fetch or read. The text here comes from an uploaded file, so
# it is checked to BE JSON first (`validate()` never fetches or reads), and only
# then parsed: text that is valid JSON is always parsed as JSON.
bundle_parse_json <- function(text, what) {
  ok <- jsonlite::validate(text)
  if (!isTRUE(ok)) {
    detail <- attr(ok, "err")
    if (is.null(detail)) detail <- "the text is not JSON"
    cli::cli_abort(c("x" = "{what} is not valid JSON.", "i" = "{detail}"))
  }
  jsonlite::fromJSON(text, simplifyVector = FALSE)
}

# ---- payload kinds ---------------------------------------------------------

# A payload is the API response ({"data": ...}) or the bare `data` element.
bundle_unwrap <- function(obj) {
  if (is.list(obj) && !is.null(names(obj)) && "data" %in% names(obj)) obj$data else obj
}

# A payload given as a path to a JSON file, or as an already-parsed list.
bundle_as_payload <- function(x, what = "payload", max_bytes = bundle_max_bytes()) {
  if (is.character(x) && length(x) == 1L && !is.na(x)) {
    return(bundle_parse_json(bundle_read_text(x, max_bytes), sprintf("The file %s", x)))
  }
  if (is.list(x)) return(x)
  cli::cli_abort(c(
    "x" = "A {what} must be a path to a JSON file or a parsed list.",
    "i" = "Got an object of class {.cls {class(x)[1]}}."
  ))
}

#' @rdname rallyr-bundle
#' @param x A payload: a path to a saved JSON file, or the parsed list.
#' @param strict If `TRUE` (default) an unrecognised payload is an error; if
#'   `FALSE` it gives `NA`.
#' @return `bundle_payload_kind()` returns `"match"`, `"stats"` or `"shots"`
#'   (the kind is decided by the content, never by the file name). An empty
#'   shot list is read as `"shots"`.
#' @export
bundle_payload_kind <- function(x, strict = TRUE) {
  kind <- bundle_kind_parsed(bundle_as_payload(x))
  if (is.na(kind) && isTRUE(strict)) {
    cli::cli_abort(c(
      "x" = "Cannot tell what this payload is.",
      "i" = "Expected the JSON of {.val /matches/<token>}, {.val /matches/<token>/stats} or {.val /matches/<token>/shots}."
    ))
  }
  kind
}

# The kind of an already-parsed payload; NA when it is none of the three.
bundle_kind_parsed <- function(obj) {
  d <- bundle_unwrap(obj)
  nm <- if (is.list(d)) names(d) else NULL
  kind <- NA_character_
  if (!is.list(d)) {
    kind <- NA_character_
  } else if (length(d) == 0L) {
    if (is.null(nm)) kind <- "shots"
  } else if (is.null(nm)) {
    probe <- d[seq_len(min(5L, length(d)))]
    is_shot <- vapply(probe, function(s) {
      is.list(s) && "player" %in% names(s) && any(c("pid", "hit_type", "match_id") %in% names(s))
    }, logical(1))
    if (all(is_shot)) kind <- "shots"
  } else {
    if ("id" %in% nm && any(c("guest_name", "host_name") %in% nm)) {
      kind <- "match"
    } else if (all(c("host", "guest") %in% nm) && is.list(d$host) && is.list(d$guest)) {
      kind <- "stats"
    }
  }
  kind
}

# ---- validation ------------------------------------------------------------

# A fetch time as a UTC instant (seconds since 1970, fractions kept); NA when
# the text is not an ISO-8601 date-time. Accepts a trailing `Z`, a numeric
# offset (`+02:00`, `-0200`, `+02`), fractional seconds, and a bare date
# (read as midnight UTC). A time with no offset is read as UTC.
bundle_stamp_seconds <- function(x) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) return(NA_real_)
  x <- trimws(x)
  m <- regmatches(x, regexec(
    paste0("^(\\d{4}-\\d{2}-\\d{2})(?:[T ](\\d{2}:\\d{2}:\\d{2})(\\.\\d+)?",
           "(Z|[+-]\\d{2}(?::?\\d{2})?)?)?$"),
    x, perl = TRUE
  ))[[1]]
  if (length(m) == 0L) return(NA_real_)
  clock <- if (nzchar(m[3])) m[3] else "00:00:00"
  base <- as.POSIXct(paste(m[2], clock), tz = "UTC", format = "%Y-%m-%d %H:%M:%S")
  if (is.na(base)) return(NA_real_)
  frac <- if (nzchar(m[4])) as.numeric(paste0("0", m[4])) else 0
  off <- m[5]
  shift <- 0
  if (nzchar(off) && off != "Z") {
    digits <- gsub("[^0-9]", "", substring(off, 2L))
    hh <- as.numeric(substr(digits, 1L, 2L))
    mm <- if (nchar(digits) > 2L) as.numeric(substr(digits, 3L, 4L)) else 0
    if (hh > 23 || mm > 59) return(NA_real_)
    shift <- (hh * 3600 + mm * 60) * if (substr(off, 1L, 1L) == "-") -1 else 1
  }
  as.numeric(base) + frac - shift
}

# Seconds of a session's `fetched_at`; -Inf when it has none (the oldest).
bundle_session_stamp <- function(s) {
  if (is.null(s$fetched_at)) -Inf else bundle_stamp_seconds(s$fetched_at)
}

bundle_id_key <- function(id) format(as.numeric(id), scientific = FALSE, trim = TRUE)

bundle_validate <- function(x) {
  bad <- function(msg) cli::cli_abort(c("x" = "Not a valid rallyr bundle.", "i" = msg), .envir = parent.frame())
  if (!is.list(x) || is.null(names(x))) bad("The top level must be a JSON object.")
  v <- x$schema_version
  if (is.null(v) || !is.numeric(v) || length(v) != 1L || is.na(v) || v != round(v) || v < 1) {
    bad("{.field schema_version} is missing or is not a positive whole number.")
  }
  if (v > bundle_schema_version()) {
    cli::cli_abort(c(
      "x" = "This bundle has file format version {v}; this version of rallyr reads up to {bundle_schema_version()}.",
      "i" = "Update rallyr, or export the bundle again from a matching version."
    ))
  }
  if (is.null(x$sessions) || !is.list(x$sessions) ||
        (length(x$sessions) > 0L && !is.null(names(x$sessions)))) {
    bad("{.field sessions} must be a list of sessions.")
  }
  slots <- c("match", "stats", "shots")
  for (i in seq_along(x$sessions)) {
    s <- x$sessions[[i]]
    if (!is.list(s)) bad("Session {i} is not an object.")
    id <- s$match_id
    if (is.null(id) || !is.numeric(id) || length(id) != 1L || is.na(id)) {
      bad("Session {i} has no numeric {.field match_id}.")
    }
    for (slot in slots) {
      if (is.null(s[[slot]])) bad("Session {i} has no {.field {slot}} payload.")
      kind <- bundle_kind_parsed(s[[slot]])
      if (!identical(kind, slot)) {
        bad("In session {i}, the {.field {slot}} payload does not look like a {slot} payload.")
      }
    }
    if (is.na(bundle_session_stamp(s))) {
      bad("Session {i} has a {.field fetched_at} that is not an ISO-8601 date-time (such as 2031-01-01T09:00:00Z).")
    }
    payload_id <- bundle_unwrap(s$match)$id
    if (is.null(payload_id) || !is.numeric(payload_id) || length(payload_id) != 1L ||
          is.na(payload_id) || bundle_id_key(payload_id) != bundle_id_key(id)) {
      bad("In session {i}, {.field match_id} does not match the id inside the match payload.")
    }
    shot_ids <- unlist(lapply(bundle_unwrap(s$shots), function(z) z$match_id))
    if (length(shot_ids) > 0L && (!is.numeric(shot_ids) || any(is.na(shot_ids)) ||
          any(shot_ids != id))) {
      bad("In session {i}, the shots do not belong to the match (their {.field match_id} differs).")
    }
  }
  keys <- vapply(x$sessions, function(s) bundle_id_key(s$match_id), character(1))
  if (anyDuplicated(keys) > 0L) {
    dups <- keys[duplicated(keys)]
    bad("Two sessions share a {.field match_id}: {.val {dups}}.")
  }
  class(x) <- "rallyr_bundle"
  x
}

unclass_bundle <- function(x) {
  if (!inherits(x, "rallyr_bundle")) {
    cli::cli_abort(c(
      "x" = "{.arg bundle} must be a bundle.",
      "i" = "Make one with {.fn bundle_new} or {.fn bundle_read}."
    ))
  }
  x
}

# ---- read / write ----------------------------------------------------------

#' @rdname rallyr-bundle
#' @param path For `bundle_read()`, the file to read (gzip or plain JSON); for
#'   `bundle_write()`, the file to write (always gzip-compressed; a name ending
#'   `.json.gz` is conventional).
#' @param max_bytes The largest file, and the largest text once uncompressed,
#'   that `bundle_read()` accepts, in bytes. Defaults to
#'   `getOption("rallyr.bundle_max_bytes", 50 * 1024^2)` (50 MB, far above a
#'   real bundle). A larger file is an error, not a partial read.
#' @return `bundle_read()` returns a bundle. It stops with an error, naming the
#'   problem, for a file that is too large, empty, not JSON, has no or a too-new
#'   `schema_version`, or holds a session whose payloads are missing, are of the
#'   wrong kind or share a `match_id`.
#' @export
bundle_read <- function(path, max_bytes = bundle_max_bytes()) {
  txt <- bundle_read_text(path, max_bytes)
  bundle_validate(bundle_parse_json(txt, sprintf("The file %s", path)))
}

#' @rdname rallyr-bundle
#' @param bundle A bundle ([bundle_new()], [bundle_read()]).
#' @return `bundle_write()` returns `path`, invisibly.
#' @export
bundle_write <- function(bundle, path) {
  bundle <- bundle_validate(unclass_bundle(bundle))
  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    cli::cli_abort("{.arg path} must be a single file path.")
  }
  txt <- jsonlite::toJSON(
    list(schema_version = bundle$schema_version, sessions = unname(bundle$sessions)),
    auto_unbox = TRUE, null = "null", digits = NA, pretty = FALSE
  )
  con <- gzfile(path, "wb")
  writeLines(as.character(txt), con, useBytes = TRUE)
  close(con)
  invisible(path)
}

# ---- adding and merging ----------------------------------------------------

fetched_now <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

#' @rdname rallyr-bundle
#' @param ... For `bundle_add_raw()`, the three payloads of ONE session, each a
#'   path to a saved JSON file or a parsed list, in any order: the kind of each
#'   is detected from its content ([bundle_payload_kind()]). Exactly one of
#'   each kind is required, and the shots must belong to the match.
#' @param token Optional share token to record with the session.
#' @param fetched_at When the payloads were fetched (an ISO-8601 date-time, such
#'   as `"2031-01-01T09:00:00Z"`; a numeric offset and fractional seconds are
#'   accepted, and a time with no offset is read as UTC); defaults to now.
#'   [bundle_merge()] compares these as instants to decide which copy of a
#'   session is newer. A value that is not a date-time is an error.
#' @return `bundle_add_raw()` returns the bundle with the session added (or
#'   replacing the same `match_id`), with the merge report in
#'   `attr(., "merge_report")` (see [bundle_merge()]).
#' @export
bundle_add_raw <- function(bundle, ..., token = NA_character_, fetched_at = fetched_now()) {
  bundle <- bundle_validate(unclass_bundle(bundle))
  payloads <- list(...)
  if (length(payloads) != 3L) {
    cli::cli_abort(c(
      "x" = "Supply exactly three payloads: the match, its stats and its shots.",
      "i" = "Got {length(payloads)}. Add one session at a time."
    ))
  }
  kinds <- vapply(payloads, bundle_payload_kind, character(1))
  if (!setequal(kinds, c("match", "stats", "shots")) || anyDuplicated(kinds) > 0L) {
    cli::cli_abort(c(
      "x" = "The three payloads must be one match, one stats and one shots payload.",
      "i" = "Detected: {.val {kinds}}."
    ))
  }
  objs <- stats::setNames(lapply(payloads, bundle_as_payload), kinds)
  match_d <- bundle_unwrap(objs$match)
  id <- match_d$id
  if (is.null(id) || !is.numeric(id)) {
    cli::cli_abort("The match payload has no numeric {.field id}.")
  }
  shot_ids <- unique(unlist(lapply(bundle_unwrap(objs$shots), function(s) s$match_id)))
  if (length(shot_ids) > 0L && !all(shot_ids == id)) {
    cli::cli_abort(c(
      "x" = "The shots do not belong to this match.",
      "i" = "The files look like they come from different sessions; add one session's three files together."
    ))
  }
  session <- list(match_id = id)
  if (!is.na(token)) session$token <- as.character(token)
  session$fetched_at <- as.character(fetched_at)
  session$match <- objs$match
  session$stats <- objs$stats
  session$shots <- objs$shots
  incoming <- bundle_new()
  incoming$sessions <- list(session)
  bundle_merge(bundle, incoming)
}

#' @rdname rallyr-bundle
#' @param y A bundle to merge into `bundle`.
#' @return `bundle_merge()` returns a bundle. A session of `y` whose `match_id`
#'   is new is **added**; one already present **replaces** the existing copy
#'   when its `fetched_at` is the same instant or newer (a tie goes to the
#'   incoming copy), and is otherwise **kept** out (the existing copy is
#'   newer); an identical payload is **unchanged** (the existing copy and its
#'   `fetched_at` stay). A copy with no `fetched_at` counts as the oldest. On
#'   **replaced** and **unchanged**, the session keeps the incoming `token` if
#'   it has one, otherwise the existing one. The
#'   report, one row per session of `y`, is in `attr(., "merge_report")` with
#'   columns `match_id`, `action` (`"added"`, `"replaced"`, `"kept"` or
#'   `"unchanged"`), `existing_fetched_at` and `incoming_fetched_at`.
#' @export
bundle_merge <- function(bundle, y) {
  x <- bundle_validate(unclass_bundle(bundle))
  y <- bundle_validate(unclass_bundle(y))
  keys <- vapply(x$sessions, function(s) bundle_id_key(s$match_id), character(1))
  fetched <- function(s) if (is.null(s$fetched_at)) "" else as.character(s$fetched_at)
  # The incoming token wins when it has one; otherwise the existing one stays.
  token_of <- function(incoming, existing) {
    if (!is.null(incoming$token)) incoming$token else existing$token
  }
  rows <- vector("list", length(y$sessions))
  for (i in seq_along(y$sessions)) {
    s <- y$sessions[[i]]
    k <- bundle_id_key(s$match_id)
    pos <- match(k, keys)
    if (is.na(pos)) {
      x$sessions[[length(x$sessions) + 1L]] <- s
      keys <- c(keys, k)
      action <- "added"
      old <- NA_character_
    } else {
      old_s <- x$sessions[[pos]]
      old <- fetched(old_s)
      if (identical(old_s$match, s$match) && identical(old_s$stats, s$stats) &&
            identical(old_s$shots, s$shots)) {
        x$sessions[[pos]]$token <- token_of(s, old_s)
        action <- "unchanged"
      } else if (bundle_session_stamp(s) >= bundle_session_stamp(old_s)) {
        s$token <- token_of(s, old_s)
        x$sessions[[pos]] <- s
        action <- "replaced"
      } else {
        action <- "kept"
      }
    }
    rows[[i]] <- tibble::tibble(
      match_id = as.numeric(s$match_id), action = action,
      existing_fetched_at = if (is.na(old) || !nzchar(old)) NA_character_ else old,
      incoming_fetched_at = fetched(s)
    )
  }
  report <- if (length(rows) > 0L) {
    dplyr::bind_rows(rows)
  } else {
    tibble::tibble(
      match_id = numeric(0), action = character(0),
      existing_fetched_at = character(0), incoming_fetched_at = character(0)
    )
  }
  class(x) <- "rallyr_bundle"
  attr(x, "merge_report") <- report
  x
}

# ---- players ---------------------------------------------------------------

#' @rdname rallyr-bundle
#' @return `bundle_players()` returns the player names that appear in the
#'   bundle's matches, most frequent first.
#' @export
bundle_players <- function(bundle) {
  bundle <- unclass_bundle(bundle)
  nm <- unlist(lapply(bundle$sessions, function(s) {
    d <- bundle_unwrap(s$match)
    c(d$guest_name, d$host_name)
  }))
  nm <- nm[!is.na(nm) & nzchar(nm)]
  if (length(nm) == 0L) return(character(0))
  names(sort(table(nm), decreasing = TRUE))
}

# ---- bundle -> tables ------------------------------------------------------

# Which side ("guest"/"host") of a match is `me`; NA when neither name matches.
bundle_my_side <- function(match, me) {
  norm <- function(z) tolower(trimws(as.character(z)))
  if (identical(norm(match$guest_name), norm(me))) return("guest")
  if (identical(norm(match$host_name), norm(me))) return("host")
  NA_character_
}

# Zero-row versions of the three derived tables, for a bundle with no shots.
bundle_empty_tables <- function() {
  shots <- sv_parse_shots(list())
  shots$ended_at <- NULL
  shots$match_id <- integer(0)
  shots$segment_index <- integer(0)
  shots$regime <- character(0)
  shots$regime_occurrence <- numeric(0)
  list(
    shot_segments = tibble::tibble(
      match_id = integer(0), segment_index = integer(0), regime = character(0),
      regime_occurrence = numeric(0), start_time = as.POSIXct(character(0), tz = "UTC"),
      end_time = as.POSIXct(character(0), tz = "UTC"), duration_min = numeric(0),
      n_shots = numeric(0), n_host_shots = numeric(0), n_guest_shots = numeric(0),
      n_guest_gs_left = numeric(0), n_guest_gs_right = numeric(0),
      guest_speed_mean_mph = numeric(0), guest_speed_median_mph = numeric(0),
      guest_in_pct = numeric(0)
    ),
    shot_detail = shots,
    rallies = tibble::tibble(
      match_id = integer(0), rally_id = numeric(0),
      start_time = as.POSIXct(character(0), tz = "UTC"),
      end_time = as.POSIXct(character(0), tz = "UTC"), duration_sec = numeric(0),
      n_shots = numeric(0), segment_index = numeric(0), regime = character(0),
      regime_occurrence = numeric(0)
    )
  )
}

# Segments, per-shot rows and rallies for one match, in the shape of the
# stored tables (so the same derived-data functions read either source).
bundle_derive_match <- function(shots, guest_right_handed = TRUE) {
  segs <- segment_session_shots(shots, guest_right_handed = guest_right_handed)
  segs <- segs |>
    dplyr::group_by(.data$regime) |>
    dplyr::mutate(regime_occurrence = match(.data$segment_index, sort(unique(.data$segment_index)))) |>
    dplyr::ungroup() |>
    as.data.frame()

  shots$segment_index <- pmax(findInterval(shots$started_at, segs$start_time), 1L)
  shots$regime <- segs$regime[shots$segment_index]
  shots$regime_occurrence <- segs$regime_occurrence[shots$segment_index]

  wing_counts <- shots |>
    dplyr::filter(.data$player == "guest", .data$hit_type == "ground_stroke", .data$hit_wing %in% c("left", "right")) |>
    dplyr::group_by(.data$segment_index) |>
    dplyr::summarise(
      n_guest_gs_left  = sum(.data$hit_wing == "left"),
      n_guest_gs_right = sum(.data$hit_wing == "right"),
      .groups = "drop"
    )
  guest_stats <- shots |>
    dplyr::filter(.data$player == "guest") |>
    dplyr::group_by(.data$segment_index) |>
    dplyr::summarise(
      guest_speed_mean_mph   = round(mean(.data$shot_speed_mph, na.rm = TRUE), 1),
      guest_speed_median_mph = round(stats::median(.data$shot_speed_mph, na.rm = TRUE), 1),
      guest_in_pct           = round(100 * mean(.data$shot_in), 1),
      .groups = "drop"
    )
  segs <- segs |>
    dplyr::left_join(wing_counts, by = "segment_index") |>
    dplyr::left_join(guest_stats, by = "segment_index")
  segs$n_guest_gs_left  <- ifelse(is.na(segs$n_guest_gs_left), 0L, segs$n_guest_gs_left)
  segs$n_guest_gs_right <- ifelse(is.na(segs$n_guest_gs_right), 0L, segs$n_guest_gs_right)
  segs$match_id <- shots$match_id[1]

  detail_cols <- names(bundle_empty_tables()$shot_detail)

  mode_num <- function(x) as.numeric(names(sort(table(x), decreasing = TRUE))[1])
  rallies <- shots |>
    dplyr::filter(!is.na(.data$rally_id)) |>
    dplyr::group_by(.data$rally_id) |>
    dplyr::summarise(
      start_time    = min(.data$started_at),
      end_time      = max(.data$ended_at),
      duration_sec  = pmax(0, round(as.numeric(difftime(max(.data$ended_at), min(.data$started_at), units = "secs")), 1)),
      n_shots       = dplyr::n(),
      segment_index = mode_num(.data$segment_index),
      .groups = "drop"
    ) |>
    dplyr::left_join(
      dplyr::select(segs, "segment_index", "regime", "regime_occurrence"),
      by = "segment_index"
    )
  rallies$match_id <- shots$match_id[1]

  list(
    segs = tibble::as_tibble(segs),
    shots = tibble::as_tibble(shots[, detail_cols]),
    rallies = tibble::as_tibble(rallies)
  )
}

# One session's tables for the player `me`; NULL when `me` is not in the match.
bundle_session_tables <- function(s, me) {
  match <- bundle_unwrap(s$match)
  side <- bundle_my_side(match, me)
  if (is.na(side)) return(NULL)
  me_exact <- match[[paste0(side, "_name")]]
  row <- sv_parse_match(
    match, bundle_unwrap(s$stats), me = me_exact,
    token = if (is.null(s$token)) NA_character_ else as.character(s$token)
  )
  # The derived-data schema types `match_id` as integer (as the database
  # returns it); keep it a double only when an id would not fit.
  fits <- !is.na(row$match_id) && abs(row$match_id) <= .Machine$integer.max && row$match_id == round(row$match_id)
  if (fits) row$match_id <- as.integer(row$match_id)
  shots <- sv_parse_shots(bundle_unwrap(s$shots))
  out <- list(matches = row, shot_segments = NULL, shot_detail = NULL, rallies = NULL)
  if (nrow(shots) == 0L) return(out)
  shots$match_id <- row$match_id
  if (side == "host") {
    # Downstream code treats "guest" as the player being analysed.
    shots$player <- ifelse(
      shots$player == "host", "guest",
      ifelse(shots$player == "guest", "host", shots$player)
    )
  }
  right_handed <- !isFALSE(match[[paste0(side, "_right_handed")]])
  derived <- bundle_derive_match(shots, guest_right_handed = right_handed)
  out$shot_segments <- derived$segs
  out$shot_detail <- derived$shots
  out$rallies <- derived$rallies
  out
}

#' @rdname rallyr-bundle
#' @param me The player to analyse, as named in the payloads (matched without
#'   regard to case or surrounding spaces). Either side of a match can be "me";
#'   the tables always put that player on the `"guest"` side, which is what the
#'   metrics assume.
#' @param on_error `"abort"` (default) stops at the first session that cannot
#'   be parsed; `"skip"` leaves it out and lists it in `$skipped`.
#' @param cache `NULL`, or an environment used to remember each session's
#'   tables (keyed by match, fetch time, a hash of the three payloads and `me`), so that adding one session
#'   does not recompute the others.
#' @return `bundle_to_tables()` returns a list: `matches`, `shot_segments`,
#'   `shot_detail` and `rallies` (tibbles shaped like the stored tables read by
#'   the database functions) and `skipped` (a tibble: `match_id`, `reason`) for
#'   sessions that do not include `me`, or that failed under
#'   `on_error = "skip"`.
#' @export
bundle_to_tables <- function(bundle, me, on_error = c("abort", "skip"), cache = NULL) {
  bundle <- bundle_validate(unclass_bundle(bundle))
  on_error <- match.arg(on_error)
  if (!is.character(me) || length(me) != 1L || is.na(me) || !nzchar(trimws(me))) {
    players <- bundle_players(bundle)
    cli::cli_abort(c(
      "x" = "{.arg me} must be a player name.",
      "i" = "Names in this bundle: {.val {players}}."
    ))
  }
  if (!is.null(cache) && !is.environment(cache)) {
    cli::cli_abort("{.arg cache} must be NULL or an environment.")
  }
  pieces <- list()
  skipped <- list()
  for (s in bundle$sessions) {
    key <- paste(
      bundle_id_key(s$match_id), if (is.null(s$fetched_at)) "" else s$fetched_at,
      rlang::hash(list(s$match, s$stats, s$shots)), tolower(trimws(me)), sep = "|"
    )
    if (!is.null(cache) && exists(key, envir = cache, inherits = FALSE)) {
      res <- get(key, envir = cache, inherits = FALSE)
    } else {
      res <- if (on_error == "abort") {
        bundle_session_tables(s, me)
      } else {
        tryCatch(
          bundle_session_tables(s, me),
          error = function(e) structure(list(), reason = conditionMessage(e))
        )
      }
      if (!is.null(cache)) assign(key, if (is.null(res)) NA else res, envir = cache)
    }
    if (is.null(res) || (length(res) == 1L && is.na(res[[1]][1]))) {
      skipped[[length(skipped) + 1L]] <- tibble::tibble(
        match_id = as.numeric(s$match_id), reason = "player not in this session"
      )
    } else if (length(res) == 0L) {
      skipped[[length(skipped) + 1L]] <- tibble::tibble(
        match_id = as.numeric(s$match_id),
        reason = paste("could not be parsed:", attr(res, "reason"))
      )
    } else {
      pieces[[length(pieces) + 1L]] <- res
    }
  }
  bind <- function(name) {
    parts <- lapply(pieces, `[[`, name)
    parts <- parts[!vapply(parts, is.null, logical(1))]
    if (length(parts) == 0L) NULL else dplyr::bind_rows(parts)
  }
  matches <- bind("matches")
  if (is.null(matches)) matches <- parse_swingvision("")
  matches <- matches[order(matches$played_at), ]
  empty <- bundle_empty_tables()
  or_empty <- function(x, name) if (is.null(x)) empty[[name]] else x
  list(
    matches = matches,
    shot_segments = or_empty(bind("shot_segments"), "shot_segments"),
    shot_detail = or_empty(bind("shot_detail"), "shot_detail"),
    rallies = or_empty(bind("rallies"), "rallies"),
    skipped = if (length(skipped) > 0L) {
      dplyr::bind_rows(skipped)
    } else {
      tibble::tibble(match_id = numeric(0), reason = character(0))
    }
  )
}

#' @rdname rallyr-bundle
#' @param tables The list returned by `bundle_to_tables()`.
#' @param params A [dq_params()]-shaped list.
#' @return `bundle_derived()` returns a list: the five derived-data tibbles of
#'   [rallyr-api] (`sessions`, `corrected_rallies`, `session_metrics`,
#'   `net_clearance`, `stroke_quality`, each stamped with the schema version)
#'   and `tables`. `session_metrics` is `NULL` with fewer than two sessions
#'   (a percentile needs a distribution) and `corrected_rallies` is `NULL`
#'   when there are no rallies. It stops with an error when `tables` has no
#'   sessions.
#' @export
bundle_derived <- function(tables, params = dq_params()) {
  need <- c("matches", "shot_segments", "shot_detail", "rallies")
  if (!is.list(tables) || !all(need %in% names(tables))) {
    cli::cli_abort(c(
      "x" = "{.arg tables} must be the result of {.fn bundle_to_tables}.",
      "i" = "It needs {.val {need}}."
    ))
  }
  if (nrow(tables$matches) == 0L) {
    cli::cli_abort(c(
      "x" = "There are no sessions to summarise.",
      "i" = "Check the player name against {.fn bundle_players}."
    ))
  }
  sessions <- api_stamp(merge_same_day_sessions(tables$matches), "rallyr_sessions")
  corrected <- if (nrow(tables$rallies) > 0L) {
    api_stamp(dq_corrected_rallies(tables$rallies, tables$shot_detail, params), "rallyr_corrected_rallies")
  } else {
    NULL
  }
  metrics <- if (nrow(sessions) >= 2L) {
    api_stamp(session_standard_metrics(sessions), "rallyr_session_metrics")
  } else {
    NULL
  }
  list(
    sessions = sessions,
    corrected_rallies = corrected,
    session_metrics = metrics,
    net_clearance = api_stamp(
      session_net_clearance_by_drill(tables$shot_detail, params), "rallyr_net_clearance"
    ),
    stroke_quality = api_stamp(
      stroke_quality_session(tables$shot_detail, tables$matches, params), "rallyr_stroke_quality"
    ),
    tables = tables
  )
}
