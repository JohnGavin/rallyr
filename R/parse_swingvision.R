#' Parse pasted SwingVision "Rally" session text into a tidy data frame
#'
#' Parses the plain text copied from a SwingVision match/rally page (the
#' rendered stats, not the URL) into one row per match. Handles the app's
#' quirks: value-before-label layout, duplicated `Cross-Court In` labels under
#' both Forehands and Backhands (resolved by tracking the current section),
#' relative dates such as `"Monday"`, and mixed distance units (mi / ft).
#'
#' Multiple pasted views of the same match (e.g. the simple "Groundstrokes"
#' view and the "Advanced" Forehands/Backhands view) share a `played_at` key
#' and are coalesced into a single complete row. Exact duplicates collapse.
#'
#' @param text Character scalar. The pasted text. Sessions may be separated by
#'   lines of `===`; a leading session before the first separator is also read.
#' @param captured_on A `Date` giving the day the text was copied from the web
#'   page. Used to resolve relative dates (`"Monday"`, `"Yesterday"`, `"Today"`)
#'   to absolute dates. Defaults to today.
#' @param me The player name (as it appears in the pasted text) to treat as
#'   "you", i.e. the `me_*` columns below. Required if `text` contains any
#'   session blocks; ignored for empty input.
#'
#' @section Data-quality caveats:
#' `longest_rally` is unreliable: values are implausibly long for a single
#' rally and almost certainly reflect SwingVision merging several consecutive
#' rallies into one (it does not reliably split points during continuous
#' hitting practice). Kept as recorded but do not treat as a true rally length.
#' `shots_per_hour` is labelled as a rate by the app but its magnitude tracks a
#' shots-in count. Prefer `me_shots`, `shots_in_pct`, and the groundstroke
#' accuracy fields for real signal.
#'
#' @return A tibble, one row per unique match, ordered by `played_at`.
#' @importFrom rlang .data
#' @export
parse_swingvision <- function(text, captured_on = Sys.Date(), me) {
  stopifnot(is.character(text), length(text) == 1L)
  captured_on <- as.Date(captured_on)

  blocks <- strsplit(text, "(?m)^={2,}[[:space:]]*$", perl = TRUE)[[1]]
  blocks <- blocks[grepl("Duration", blocks)]
  if (length(blocks) == 0L) {
    return(.empty_matches())
  }
  if (missing(me)) {
    cli::cli_abort(c(
      "x" = "{.arg me} is required when {.arg text} contains session data.",
      "i" = "Pass the player name exactly as it appears in the pasted text."
    ))
  }

  rows <- lapply(blocks, .parse_block, captured_on = captured_on, me = me)
  df <- dplyr::bind_rows(rows)

  # Coalesce rows that describe the same match (same played_at) — takes the
  # first non-NA value per column, merging simple + advanced stat views.
  df <- df |>
    dplyr::group_by(.data$played_at) |>
    dplyr::summarise(
      dplyr::across(dplyr::everything(), ~ .x[which(!is.na(.x))[1]]),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$played_at)

  df
}

# ---- block parser ----------------------------------------------------------

.parse_block <- function(block, captured_on, me) {
  ls <- trimws(strsplit(block, "\n")[[1]])
  ls <- ls[nzchar(ls)]

  # --- header: "Jul 6, 2026 at 01:04 PM|Duration0:36" ---
  hdr <- ls[grepl("Duration", ls)][1]
  left <- trimws(sub("\\|.*$", "", hdr))
  dur_raw <- sub(".*Duration", "", hdr)
  m <- regmatches(left, regexec("^(.*) at (.*)$", left))[[1]]
  datepart <- m[2]
  timepart <- m[3]

  session_date <- .resolve_date(datepart, captured_on)
  time24 <- format(strptime(timepart, "%I:%M %p"), "%H:%M")
  played_at <- as.POSIXct(
    paste(session_date, time24),
    format = "%Y-%m-%d %H:%M", tz = "Europe/London"
  )
  dp <- as.integer(strsplit(dur_raw, ":")[[1]])
  duration_min <- dp[1] * 60L + dp[2]

  # --- sport / location ---
  loc_line <- ls[grepl("Location Icon", ls)][1]
  sport <- trimws(sub(".*Sport Icon", "", sub("\\|.*$", "", loc_line)))
  location <- trimws(sub(".*Location Icon", "", loc_line))

  # --- players: opponent listed first, `me` second ---
  run_idx <- grep("^run", ls)
  names_at <- ls[run_idx - 1]
  me_sel <- which(names_at == me)
  me_i <- if (length(me_sel)) run_idx[me_sel[1]] else run_idx[length(run_idx)]
  opp_candidates <- run_idx[run_idx != me_i]
  opp_i <- if (length(opp_candidates)) opp_candidates[1] else NA_integer_

  me_run_mi <- .run_mi(ls[me_i])
  me_shots <- as.numeric(ls[me_i + 1])
  if (!is.na(opp_i)) {
    opponent <- ls[opp_i - 1]
    opp_run_mi <- .run_mi(ls[opp_i])
    opp_shots <- as.numeric(ls[opp_i + 1])
  } else {
    opponent <- NA_character_
    opp_run_mi <- NA_real_
    opp_shots <- NA_real_
  }

  # --- section-aware stat scan (value precedes its label) ---
  section_headers <- c(
    "Overall", "Serves", "Returns", "Groundstrokes", "Forehands", "Backhands"
  )
  current <- NA_character_
  vals <- stats::setNames(vector("list", length(.stat_cols())), .stat_cols())
  for (i in seq_along(ls)) {
    line <- ls[i]
    if (line %in% section_headers) {
      current <- line
      next
    }
    if (is.na(current)) next
    col <- .metric_map()[[paste0(current, "|", line)]]
    if (!is.null(col) && i > 1L) {
      vals[[col]] <- ls[i - 1L]
    }
  }
  typed <- lapply(names(vals), function(col) .coerce_stat(col, vals[[col]]))
  names(typed) <- names(vals)

  meta <- tibble::tibble(
    played_at = played_at,
    session_date = session_date,
    start_time = time24,
    duration_min = duration_min,
    sport = sport,
    location = location,
    opponent = opponent,
    me_shots = me_shots,
    me_run_mi = me_run_mi,
    opp_shots = opp_shots,
    opp_run_mi = opp_run_mi
  )
  dplyr::bind_cols(meta, tibble::as_tibble(typed))
}

# ---- lookups ---------------------------------------------------------------

.metric_map <- function() {
  list(
    "Overall|Shots In"                = "shots_in_pct",
    "Overall|Shots Per Hour"          = "shots_per_hour",
    "Overall|Longest Rally"           = "longest_rally",
    "Overall|Rallies Above 5 Shots"   = "rallies_above_5_pct",
    "Serves|Serves In (Ad)"           = "serves_in_ad_pct",
    "Serves|Serves In (Deuce)"        = "serves_in_deuce_pct",
    "Serves|Avg Serve Speed (Ad)"     = "serve_speed_ad_mph",
    "Serves|Avg Serve Speed (Deuce)"  = "serve_speed_deuce_mph",
    "Returns|Returns In (Ad)"         = "returns_in_ad_pct",
    "Returns|Returns In (Deuce)"      = "returns_in_deuce_pct",
    "Returns|Avg Return Speed (Ad)"   = "return_speed_ad_mph",
    "Returns|Avg Return Speed (Deuce)" = "return_speed_deuce_mph",
    "Groundstrokes|Forehands In"      = "fh_in_pct",
    "Groundstrokes|Backhands In"      = "bh_in_pct",
    "Groundstrokes|Avg Forehand Speed" = "fh_speed_mph",
    "Groundstrokes|Avg Backhand Speed" = "bh_speed_mph",
    "Forehands|Cross-Court In"        = "fh_cc_in_pct",
    "Forehands|Down-The-Line In"      = "fh_dtl_in_pct",
    "Forehands|Avg Cross-Court Speed" = "fh_cc_speed_mph",
    "Forehands|Avg Down-The-Line Speed" = "fh_dtl_speed_mph",
    "Forehands|Cross-Court Deep"      = "fh_cc_deep_pct",
    "Forehands|Down-The-Line Deep"    = "fh_dtl_deep_pct",
    "Backhands|Cross-Court In"        = "bh_cc_in_pct",
    "Backhands|Down-The-Line In"      = "bh_dtl_in_pct",
    "Backhands|Avg Cross-Court Speed" = "bh_cc_speed_mph",
    "Backhands|Avg Down-The-Line Speed" = "bh_dtl_speed_mph",
    "Backhands|Cross-Court Deep"      = "bh_cc_deep_pct",
    "Backhands|Down-The-Line Deep"    = "bh_dtl_deep_pct"
  )
}

.stat_cols <- function() unique(unlist(.metric_map(), use.names = FALSE))

.empty_matches <- function() {
  meta <- tibble::tibble(
    played_at = as.POSIXct(character()), session_date = as.Date(character()),
    start_time = character(), duration_min = integer(), sport = character(),
    location = character(), opponent = character(), me_shots = numeric(),
    me_run_mi = numeric(), opp_shots = numeric(), opp_run_mi = numeric()
  )
  stats_tbl <- tibble::as_tibble(
    stats::setNames(lapply(.stat_cols(), function(...) numeric()), .stat_cols())
  )
  dplyr::bind_cols(meta, stats_tbl)
}

# ---- value coercion --------------------------------------------------------

#' @noRd
.coerce_stat <- function(col, raw) {
  if (is.null(raw) || is.na(raw)) return(NA_real_)
  if (grepl("_pct$", col)) return(.pct(raw))
  if (grepl("_mph$", col)) return(.mph(raw))
  suppressWarnings(as.numeric(gsub("[^0-9.]", "", raw)))
}

.pct <- function(x) {
  if (grepl("^[-]+", trimws(x))) return(NA_real_)
  suppressWarnings(as.numeric(sub("%", "", x)))
}

.mph <- function(x) {
  if (grepl("^[-]", trimws(x))) return(NA_real_)
  suppressWarnings(as.numeric(gsub("[^0-9.]", "", x)))
}

.run_mi <- function(x) {
  x <- sub("^run", "", x)
  num <- suppressWarnings(as.numeric(gsub("[^0-9.]", "", x)))
  if (grepl("ft", x)) num / 5280 else num
}

.resolve_date <- function(datepart, captured_on) {
  datepart <- trimws(datepart)
  # Absolute date like "Jul 6, 2026" — parsed locale-independently.
  m <- regmatches(
    datepart,
    regexec("^([A-Za-z]+) ([0-9]{1,2}), ([0-9]{4})$", datepart)
  )[[1]]
  if (length(m) == 4L) {
    months <- c(jan = 1, feb = 2, mar = 3, apr = 4, may = 5, jun = 6,
                jul = 7, aug = 8, sep = 9, oct = 10, nov = 11, dec = 12)
    mon <- months[tolower(substr(m[2], 1, 3))]
    if (!is.na(mon)) {
      return(as.Date(sprintf("%04d-%02d-%02d",
                             as.integer(m[4]), mon, as.integer(m[3]))))
    }
  }
  wd <- tolower(datepart)
  if (wd == "today") return(captured_on)
  if (wd == "yesterday") return(captured_on - 1L)
  weekdays_en <- c("sunday", "monday", "tuesday", "wednesday",
                   "thursday", "friday", "saturday")
  if (wd %in% weekdays_en) {
    target <- match(wd, weekdays_en) - 1L        # 0 = Sunday, per POSIXlt$wday
    for (back in 1:7) {                          # 1:7 — a weekday name never means today
      cand <- captured_on - back
      if (as.POSIXlt(cand)$wday == target) return(cand)
    }
  }
  as.Date(NA)
}

# Quiet R CMD check on tidy-eval pronoun
utils::globalVariables(".data")
