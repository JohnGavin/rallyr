#' Find within-rally split points from stroke timing gaps
#'
#' A rally's shots are grouped by the SwingVision API's own `pid` field,
#' taken as-is with no time-gap heuristic (see `ISSUES.md` #3). This can
#' silently merge two or more real rallies into one `pid` run when play
#' actually stopped and restarted between them, producing an implausible
#' stroke count for a single continuous point (see `ISSUES.md` #5, point 4:
#' "the actual re-grouping/splitting algorithm for a flagged over-long
#' rally... Not yet solved").
#'
#' This is a **pure, dependency-free** function: given ordered per-stroke
#' timestamps for ONE rally, it finds the point(s) where the pause between
#' one stroke and the next is implausibly large for a live point — i.e.
#' where a split is more likely than a genuine single rally. It performs NO
#' database access and makes NO empirical threshold decision itself; the
#' caller supplies `max_gap_sec`.
#'
#' @param started_at Ordered (ascending) vector of stroke start timestamps
#'   (`POSIXct`, `Date`, or numeric seconds) for one rally.
#' @param ended_at Ordered vector of stroke end timestamps, same length as
#'   `started_at`. Optional — when `NULL` (default), the gap is computed
#'   between consecutive `started_at` values instead. This default exists
#'   because, as of this writing, the persisted `shot_detail` table (see
#'   `R/db.R`'s `tennis_shot_detail()`) stores only `started_at` per shot —
#'   there is no `ended_at` column in the real schema. Pass `ended_at`
#'   explicitly only once/if a stroke-end timestamp becomes available; doing
#'   so gives a more accurate gap (excludes the stroke's own swing duration
#'   from the pause) and is exercised by this function's own tests, but is
#'   not required for it to work against the current schema.
#' @param max_gap_sec Numeric threshold in seconds. A gap strictly greater
#'   than this is treated as a likely rally boundary. Not derived by this
#'   function — pass the project's calibrated threshold (see
#'   `ISSUES.md` #5).
#' @return Integer vector of split-point indices `i`, each satisfying
#'   `1 <= i < length(started_at)`, meaning "a split occurs between stroke
#'   `i` and stroke `i + 1`". A rally with `k` qualifying gaps splits into
#'   `k + 1` sub-rallies. Empty (`integer(0)`) when no gap exceeds the
#'   threshold, or when fewer than 2 strokes are supplied.
#' @export
find_rally_splits <- function(started_at, ended_at = NULL, max_gap_sec) {
  n <- length(started_at)
  if (n < 2L) {
    return(integer(0))
  }
  if (!is.null(ended_at) && length(ended_at) != n) {
    cli::cli_abort(c(
      "x" = "{.arg started_at} and {.arg ended_at} must be the same length.",
      "i" = "Got {length(started_at)} and {length(ended_at)}."
    ))
  }

  gap_end   <- if (is.null(ended_at)) started_at[-n] else ended_at[-n]
  gap_start <- started_at[-1]
  gaps_sec  <- as.numeric(gap_start) - as.numeric(gap_end)

  which(gaps_sec > max_gap_sec)
}
