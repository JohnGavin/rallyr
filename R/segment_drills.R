#' One example drill routine, for use as `drill_order`
#'
#' A character vector naming the drills of one particular routine, in the
#' order they are practised: a slow cooperative warm-up (`"warm_up"`), a
#' net-volley drill, a forehand cross-court drill, a backhand cross-court
#' drill, and a second net-volley drill. It is **one example**, not a default
#' and not a claim about how sessions are run: [segment_session_drills()] has
#' no default `drill_order`, so every caller states their own routine. Use
#' this constant only when your sessions follow the same routine; otherwise
#' pass your own vector. Drill names are free-form labels; the pause rules in
#' [dq_params()] are keyed by regime name, so use the regime names they
#' expect for the drills you want pause-split.
#'
#' @format A character vector of length 5.
#' @examples
#' example_drill_order
#' @export
example_drill_order <- c(
  "warm_up", "net_volley", "forehand_cross_court",
  "backhand_cross_court", "net_volley"
)

#' Split a session into drills using long pauses and a known drill order
#'
#' Drill-first segmentation. When every session follows the same drill order
#' and the player rests between drills, the pause between drills is far
#' longer than any pause inside a drill. This function cuts the session at
#' those long pauses and labels the resulting segments with the order the
#' caller supplies, instead of guessing each drill from per-bin stroke
#' statistics (compare [segment_session_shots()], which does the latter).
#'
#' **No default order.** `drill_order` is required: the labels are only as
#' true as the caller's claim about their routine. [example_drill_order]
#' is one example routine.
#'
#' **A spurious extra boundary is merged away first.** A single stray stroke
#' sitting between two real transition pauses would otherwise form its own
#' one-stroke "segment" and inflate the count. Before labelling, any segment
#' with fewer than `min_drill_segment_shots` strokes is merged into the
#' neighbour it is separated from by the smaller pause (the weaker evidence of
#' a real transition), repeating until no segment is that small.
#'
#' **When the order does not fit, nothing is forced.** If the number of
#' segments after the merge differs from `length(drill_order)`, every
#' `regime` is `NA_character_` and the caller decides what to do. Typical
#' causes are a session recorded as two separate recordings (an extra long
#' pause) and a transition whose rest was shorter than `min_drill_gap_sec`
#' (a missing boundary). Lowering the threshold to rescue one session can
#' split a drill elsewhere, so this function does not search for a missing
#' boundary.
#'
#' The pause threshold is data-dependent: check it against the observed gap
#' distribution of your own sessions (see [dq_stroke_gaps()]) so that no
#' genuine within-drill gap reaches it and every transition clears it.
#'
#' @param shots A tibble with (at least) a `started_at` `POSIXct` column for
#'   ONE match, e.g. from [sv_parse_shots()]. Need not be sorted; `NA`
#'   timestamps are an error.
#' @param drill_order Character vector of drill names in the order they are
#'   practised. Required, no default. Names may repeat.
#' @param min_drill_gap_sec A gap of at least this many seconds between
#'   consecutive strokes is a drill boundary. Default from [dq_params()].
#' @param min_drill_segment_shots Segments with fewer strokes than this are
#'   merged away (see above). Default from [dq_params()].
#' @return A tibble, one row per segment in chronological order:
#'   `drill_index`, `regime` (from `drill_order`, or `NA` when the segment
#'   count does not match), `regime_occurrence` (1 for the first time a
#'   drill name appears, 2 for the second, and so on; always 1 when `regime`
#'   is `NA`), `start_time`, `end_time`, `n_shots`. Zero rows when `shots`
#'   has fewer than 2 rows.
#' @export
segment_session_drills <- function(shots, drill_order,
                                   min_drill_gap_sec = dq_params()$min_drill_gap_sec,
                                   min_drill_segment_shots = dq_params()$min_drill_segment_shots) {
  if (missing(drill_order) || !is.character(drill_order) || length(drill_order) < 1L ||
        anyNA(drill_order)) {
    cli::cli_abort(c(
      "x" = "{.arg drill_order} must be a character vector of drill names with no {.val NA}.",
      "i" = "There is no default: state your own routine (see {.var example_drill_order})."
    ))
  }
  if (!"started_at" %in% names(shots)) {
    cli::cli_abort("{.arg shots} needs a {.field started_at} column.")
  }
  if (anyNA(shots$started_at)) {
    cli::cli_abort("{.field started_at} must not contain {.val NA}.")
  }
  empty <- tibble::tibble(
    drill_index       = integer(0),
    regime            = character(0),
    regime_occurrence = integer(0),
    start_time        = as.POSIXct(character(0), tz = "UTC"),
    end_time          = as.POSIXct(character(0), tz = "UTC"),
    n_shots           = integer(0)
  )
  if (nrow(shots) < 2L) {
    return(empty)
  }

  shots <- shots[order(shots$started_at), ]
  n <- nrow(shots)
  gaps <- as.numeric(diff(shots$started_at), units = "secs")
  boundary_after <- which(gaps >= min_drill_gap_sec)

  repeat {
    bounds <- c(0L, boundary_after, n)
    sizes <- diff(bounds)
    n_segs_now <- length(sizes)
    tiny <- which(sizes < min_drill_segment_shots)
    if (n_segs_now <= 1L || length(tiny) == 0L) break
    i <- tiny[1L]
    left_gap  <- if (i > 1L) gaps[boundary_after[i - 1L]] else Inf
    right_gap <- if (i < n_segs_now) gaps[boundary_after[i]] else Inf
    boundary_after <- boundary_after[-(if (left_gap <= right_gap) i - 1L else i)]
  }

  bounds <- c(0L, boundary_after, n)
  n_segs <- length(bounds) - 1L
  order_fits <- n_segs == length(drill_order)
  regime <- if (order_fits) drill_order else rep(NA_character_, n_segs)
  occurrence <- if (order_fits) as.integer(stats::ave(seq_len(n_segs), regime, FUN = seq_along)) else rep(1L, n_segs)

  rows <- lapply(seq_len(n_segs), function(i) {
    idx <- (bounds[i] + 1L):bounds[i + 1L]
    tibble::tibble(
      drill_index       = i,
      regime            = regime[i],
      regime_occurrence = occurrence[i],
      start_time        = shots$started_at[idx[1L]],
      end_time          = shots$started_at[idx[length(idx)]],
      n_shots           = length(idx)
    )
  })
  dplyr::bind_rows(rows)
}
