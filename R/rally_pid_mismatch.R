#' Compare the vendor's point grouping with the derived rally rule
#'
#' The vendor groups strokes into points (`pid`, stored as `rally_id`). The
#' package's working rally definition is [dq_corrected_rallies()]: the
#' vendor's grouping, with a long pause before the rally starter's stroke
#' splitting a group and an implausible group dropped. This function compares
#' the two, per match and drill, and ranks the disagreements largest first so
#' the biggest mismatches can be checked against video rather than reasoned
#' about informally.
#'
#' Each vendor group falls into exactly one outcome: `unchanged` (no pause
#' boundary, and it survives), `split` (the pause rule cut it into two or more
#' pieces and at least one survives: the vendor merged several real rallies;
#' a split whose siblings were partly dropped still counts as split) or
#' `dropped` (no corrected rally: the group was implausible). A drill whose pause rule never applies
#' (for example a slow cooperative warm-up) can only show `unchanged` or
#' `dropped`, so a low disagreement there says the rule cannot see a boundary,
#' not that the vendor grouping is right.
#'
#' @inheritParams dq_corrected_rallies
#' @return A tibble, one row per `match_id` and `regime`, ordered by
#'   `disagreement_count` then `disagreement_pct` (both descending):
#'   `n_pid_groups`, `n_unchanged`, `n_split`, `n_dropped`,
#'   `extra_subrallies` (pieces the pause rule made beyond one, per surviving
#'   split group),
#'   `disagreement_count` (`n_split + n_dropped`) and `disagreement_pct`
#'   (percent of vendor groups, one decimal). Zero rows for empty input.
#' @export
rally_pid_mismatch <- function(rallies, shot_detail, params = dq_params(),
                               me_side = "guest", rally_starter = "host") {
  need <- c("match_id", "rally_id", "regime")
  if (!all(need %in% names(rallies))) {
    cli::cli_abort(c(
      "x" = "{.arg rallies} needs {.val {need}}.",
      "i" = "Missing: {.val {setdiff(need, names(rallies))}}."
    ))
  }
  empty <- tibble::tibble(
    match_id = rallies$match_id[0], regime = rallies$regime[0],
    n_pid_groups = integer(0), n_unchanged = integer(0), n_split = integer(0),
    n_dropped = integer(0), extra_subrallies = integer(0),
    disagreement_count = integer(0), disagreement_pct = numeric(0)
  )
  if (nrow(rallies) == 0L) {
    return(empty)
  }

  corrected <- dq_corrected_rallies(rallies, shot_detail, params, me_side, rally_starter)
  kept <- paste(corrected$match_id, as.character(corrected$rally_id), sep = "\r")

  # Per vendor group: how many pieces the pause rule makes (before any piece
  # is dropped), and how many of the expected ids survive in the corrected
  # table. Expected ids are built with rally_piece_suffix() (the single source
  # of the id format) rather than parsed back out of the corrected ids, so a
  # vendor id that itself ends in "_<letter>" cannot be mistaken for a piece.
  per_group <- Map(
    function(mid, rid, regime) {
      shots <- shot_detail[shot_detail$match_id == mid & shot_detail$rally_id == rid, ]
      shots <- shots[order(shots$started_at), ]
      n_made <- length(rally_pause_splits(shots, regime, params, rally_starter)) + 1L
      ids <- if (n_made >= 2L) {
        sprintf("%s_%s", rid, rally_piece_suffix(seq_len(n_made)))
      } else {
        as.character(rid)
      }
      c(n_made = n_made, n_kept = sum(paste(mid, ids, sep = "\r") %in% kept))
    },
    rallies$match_id, rallies$rally_id, rallies$regime
  )
  per_group <- do.call(rbind, per_group)

  groups <- tibble::tibble(
    match_id = rallies$match_id,
    regime = rallies$regime,
    n_made = as.integer(per_group[, "n_made"]),
    n_kept = as.integer(per_group[, "n_kept"])
  )

  groups |>
    dplyr::summarise(
      n_pid_groups = dplyr::n(),
      n_unchanged = sum(.data$n_kept >= 1L & .data$n_made < 2L),
      n_split = sum(.data$n_kept >= 1L & .data$n_made >= 2L),
      n_dropped = sum(.data$n_kept == 0L),
      extra_subrallies = sum(ifelse(.data$n_kept >= 1L, .data$n_made - 1L, 0L)),
      .by = c("match_id", "regime")
    ) |>
    dplyr::mutate(
      disagreement_count = .data$n_split + .data$n_dropped,
      disagreement_pct = round(100 * .data$disagreement_count / .data$n_pid_groups, 1)
    ) |>
    dplyr::arrange(dplyr::desc(.data$disagreement_count), dplyr::desc(.data$disagreement_pct))
}
