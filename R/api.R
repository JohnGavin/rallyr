#' The derived-data interface and its stability policy
#'
#' Consumers other than the dashboard (scripts, notebooks, models) should read
#' derived data through the `rallyr_*()` functions below, not through the
#' internals they call. Each takes a database connection ([tennis_db_connect()])
#' and returns a tibble stamped with the attribute `schema_version`
#' ([rallyr_schema_version()]). The columns and their types are listed once, in
#' [rallyr_api_schema()], and every result is checked against that list before
#' it is returned.
#'
#' | Function | One row per | Built from |
#' |---|---|---|
#' | `rallyr_sessions()` | session (same-day matches merged) | [merge_same_day_sessions()] |
#' | `rallyr_corrected_rallies()` | rally after data-quality correction | [dq_corrected_rallies()] |
#' | `rallyr_session_metrics()` | session and metric | [session_standard_metrics()] |
#' | `rallyr_net_clearance()` | match and drill | [session_net_clearance_by_drill()] |
#' | `rallyr_stroke_quality()` | session | [stroke_quality_session()] |
#'
#' ## What "corrected source data" means
#'
#' `rallyr_corrected_rallies()` is the corrected rally table: sentinel speeds
#' nulled, rallies split at pauses, implausible rallies left out (see
#' [dq_corrected_rallies()] for the rules). It is a tibble; a non-R client
#' should read the schema from [rallyr_api_schema()] and export the tibble to
#' CSV or Parquet itself. The package does not provide an HTTP layer: build
#' one (for example with plumber2) only when a real non-R or remote consumer
#' exists.
#'
#' ## Stability policy (pre-1.0)
#'
#' - **The contract** is the name and arguments of the functions above and the
#'   name, order and type of each output column ([rallyr_api_schema()]).
#'   Other exported functions are not covered and may change in any release.
#' - **Any change to an output shape bumps the minor version** (`0.N.0`) and
#'   [rallyr_schema_version()], and is listed in `NEWS.md`. That includes
#'   adding, removing, renaming, retyping or reordering a column and changing
#'   what a column means. A patch release never changes a shape.
#' - **Values change without a shape change** when a data-quality threshold is
#'   recalibrated ([dq_params()]): more or fewer rows, different values. That is
#'   expected and noted in `NEWS.md`. Pass `params` explicitly to pin the
#'   thresholds an analysis used.
#' - **From 1.0**, ordinary semantic versioning: a breaking shape change is a
#'   major version.
#'
#' @name rallyr-api
#' @seealso [rallyr_api_schema()], [rallyr_schema_version()]
NULL

#' Schema version of the derived-data interface
#'
#' The single place the version of the output shapes of the `rallyr_*()`
#' functions is defined (see [rallyr-api] for the policy). It is `major.minor`
#' and is bumped, together with the package's minor version before 1.0,
#' whenever any output shape changes.
#'
#' @return A character string such as `"0.1"`.
#' @export
rallyr_schema_version <- function() "0.1"

# One home for the contract: function -> ordered column name / type pairs.
api_schema_spec <- function() {
  spec <- list(
    rallyr_sessions = c(
      session_date = "Date", played_at = "POSIXct", start_times = "character",
      n_parts = "integer", opponent = "character", location = "character",
      duration_min = "numeric", me_shots = "numeric", me_shots_in = "numeric",
      me_run_mi = "numeric", opp_shots = "numeric", opp_run_mi = "numeric",
      fh_speed_mph = "numeric", bh_speed_mph = "numeric", fh_shots = "numeric",
      bh_shots = "numeric", shots_in_pct = "numeric"
    ),
    rallyr_corrected_rallies = c(
      match_id = "integer", rally_id = "character", regime = "character",
      regime_occurrence = "integer", segment_index = "numeric",
      n_shots = "integer", me_shots = "integer", duration_sec = "numeric",
      start_time = "POSIXct", end_time = "POSIXct", speed_kmh = "numeric"
    ),
    rallyr_session_metrics = c(
      session_date = "Date", metric = "character", label = "character",
      unit = "character", value = "numeric", direction = "numeric",
      pct = "numeric"
    ),
    rallyr_net_clearance = c(
      match_id = "integer", regime = "character", me_median_m = "numeric",
      me_n = "integer", opp_median_m = "numeric", opp_n = "integer",
      diff_m = "numeric", n_implausible = "integer"
    ),
    rallyr_stroke_quality = c(
      session_date = "Date", n_strokes = "integer", speed_mph = "numeric",
      zone_score = "numeric", clearance_m = "numeric", z_speed = "numeric",
      z_zone = "numeric", z_clearance = "numeric", quality = "numeric"
    )
  )
  spec
}

#' The columns and types of every derived-data function
#'
#' @return A tibble: `fn` (the function), `column`, `type` (one of
#'   `"character"`, `"numeric"`, `"integer"`, `"logical"`, `"Date"`,
#'   `"POSIXct"`), in output column order. See [rallyr-api].
#' @export
rallyr_api_schema <- function() {
  spec <- api_schema_spec()
  tibble::tibble(
    fn = rep(names(spec), lengths(spec)),
    column = unlist(lapply(spec, names), use.names = FALSE),
    type = unlist(spec, use.names = FALSE)
  )
}

# The schema type name of a column ("POSIXct", "Date", else its first class).
api_col_type <- function(v) {
  if (inherits(v, "POSIXct")) "POSIXct" else if (inherits(v, "Date")) "Date" else class(v)[1]
}

# Check a result against the schema and stamp it. A missing, extra or retyped
# column is an error, never a silent pass-through or coercion. Two lossless
# allowances only: an integer column is widened where "numeric" is declared
# (the database returns whole counts as integer or double depending on the
# data), and a column that is entirely `NA` and untyped (logical) is given its
# declared type, since R has no other way to say "no values" for it.
api_stamp <- function(x, fn) {
  spec <- api_schema_spec()[[fn]]
  if (is.null(spec)) {
    cli::cli_abort("{.val {fn}} is not in the derived-data schema.")
  }
  missing <- setdiff(names(spec), names(x))
  extra <- setdiff(names(x), names(spec))
  if (length(missing) > 0L || length(extra) > 0L) {
    cli::cli_abort(c(
      "x" = "{.fn {fn}} output no longer matches its schema.",
      "i" = "Missing: {.val {missing}}. Unexpected: {.val {extra}}.",
      "i" = "A shape change needs a minor version bump and a new {.fn rallyr_schema_version}; see {.help rallyr-api}."
    ))
  }
  x <- tibble::as_tibble(x)[, names(spec)]
  got <- vapply(x, api_col_type, character(1))
  untyped_na <- vapply(x, function(v) is.logical(v) && all(is.na(v)), logical(1))
  widen <- got == "integer" & spec == "numeric"
  bad <- names(spec)[got != spec & !widen & !(untyped_na & spec != "logical")]
  if (length(bad) > 0L) {
    cli::cli_abort(c(
      "x" = "{.fn {fn}} output no longer matches its schema.",
      "i" = "Wrong type: {.val {paste0(bad, ' (', got[bad], ', expected ', spec[bad], ')')}}.",
      "i" = "A shape change needs a minor version bump and a new {.fn rallyr_schema_version}; see {.help rallyr-api}."
    ))
  }
  for (col in names(spec)[widen]) x[[col]] <- as.numeric(x[[col]])
  for (col in names(spec)[untyped_na & spec != "logical"]) {
    x[[col]] <- switch(spec[[col]],
      character = NA_character_[seq_len(nrow(x))],
      numeric = NA_real_[seq_len(nrow(x))],
      integer = NA_integer_[seq_len(nrow(x))],
      Date = as.Date(NA)[seq_len(nrow(x))],
      POSIXct = as.POSIXct(NA, tz = "UTC")[seq_len(nrow(x))]
    )
  }
  attr(x, "schema_version") <- rallyr_schema_version()
  x
}

#' Derived data from a database connection
#'
#' The documented, stable interface for derived data; see [rallyr-api] for the
#' columns, the stability policy and what each is built from. Each returns a
#' tibble with a `schema_version` attribute.
#'
#' @param con A DBI connection from [tennis_db_connect()].
#' @param params A [dq_params()]-shaped list. Pass one to pin the thresholds
#'   an analysis used.
#' @return A tibble; see [rallyr_api_schema()].
#' @name rallyr_derived
NULL

#' @rdname rallyr_derived
#' @export
rallyr_sessions <- function(con) {
  api_stamp(merge_same_day_sessions(tennis_matches(con)), "rallyr_sessions")
}

#' @rdname rallyr_derived
#' @export
rallyr_corrected_rallies <- function(con, params = dq_params()) {
  out <- dq_corrected_rallies(tennis_rallies(con), tennis_shot_detail(con), params)
  api_stamp(out, "rallyr_corrected_rallies")
}

#' @rdname rallyr_derived
#' @export
rallyr_session_metrics <- function(con) {
  api_stamp(session_standard_metrics(rallyr_sessions(con)), "rallyr_session_metrics")
}

#' @rdname rallyr_derived
#' @export
rallyr_net_clearance <- function(con, params = dq_params()) {
  api_stamp(
    session_net_clearance_by_drill(tennis_shot_detail(con), params),
    "rallyr_net_clearance"
  )
}

#' @rdname rallyr_derived
#' @export
rallyr_stroke_quality <- function(con, params = dq_params()) {
  api_stamp(
    stroke_quality_session(tennis_shot_detail(con), tennis_matches(con), params),
    "rallyr_stroke_quality"
  )
}
