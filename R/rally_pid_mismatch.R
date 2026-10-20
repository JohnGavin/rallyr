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
#' Each vendor group falls into exactly one outcome: `unchanged` (one
#' corrected rally), `split` (two or more corrected pieces: the vendor merged
#' several real rallies) or `dropped` (no corrected rally: the group was
#' implausible after the pause rule). A drill whose pause rule never applies
#' (for example a slow cooperative warm-up) can only show `unchanged` or
#' `dropped`, so a low disagreement there says the rule cannot see a boundary,
#' not that the vendor grouping is right.
#'
#' @inheritParams dq_corrected_rallies
#' @return A tibble, one row per `match_id` and `regime`, ordered by
#'   `disagreement_count` then `disagreement_pct` (both descending):
#'   `n_pid_groups`, `n_unchanged`, `n_split`, `n_dropped`,
#'   `extra_subrallies` (pieces created beyond one per split group),
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
  pieces <- tibble::tibble(
    match_id = corrected$match_id,
    orig_rally_id = sub("_[a-z][0-9]*$", "", as.character(corrected$rally_id))
  ) |>
    dplyr::count(.data$match_id, .data$orig_rally_id, name = "n_pieces")

  groups <- tibble::tibble(
    match_id = rallies$match_id,
    orig_rally_id = as.character(rallies$rally_id),
    regime = rallies$regime
  ) |>
    dplyr::left_join(pieces, by = c("match_id", "orig_rally_id")) |>
    dplyr::mutate(n_pieces = dplyr::coalesce(.data$n_pieces, 0L))

  groups |>
    dplyr::summarise(
      n_pid_groups = dplyr::n(),
      n_unchanged = sum(.data$n_pieces == 1L),
      n_split = sum(.data$n_pieces >= 2L),
      n_dropped = sum(.data$n_pieces == 0L),
      extra_subrallies = sum(pmax(.data$n_pieces - 1L, 0L)),
      .by = c("match_id", "regime")
    ) |>
    dplyr::mutate(
      disagreement_count = .data$n_split + .data$n_dropped,
      disagreement_pct = round(100 * .data$disagreement_count / .data$n_pid_groups, 1)
    ) |>
    dplyr::arrange(dplyr::desc(.data$disagreement_count), dplyr::desc(.data$disagreement_pct))
}
