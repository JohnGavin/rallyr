#' Count single-stroke rallies per match and drill
#'
#' A few percent of corrected rallies can have exactly one stroke, and two
#' different causes produce the same shape:
#'
#' 1. **Genuine**: a feed is played and the very next stroke ends the point
#'    (into the net or out).
#' 2. **Artifact**: a split cut lands next to a rally's own start or end,
#'    leaving a one-stroke scrap as a by-product of resolving an over-long
#'    vendor group.
#'
#' Telling them apart would need the in/out call of the single stroke
#' (`shot_in == FALSE` is consistent with cause 1, `TRUE` more with cause 2),
#' and that call is not yet trustworthy (see the "Known unreliability"
#' section of [sv_shot_in()]). Until it is, this function only REPORTS how many
#' there are. Do not drop single-stroke rallies wholesale, and do not treat
#' them as valid data points either.
#'
#' @param rallies A tibble of rallies with `match_id`, `regime` and `n_shots`,
#'   typically the output of [dq_corrected_rallies()]. `n_shots` counts both
#'   players' strokes.
#' @return A tibble, one row per `match_id` and `regime`: `n_rallies`,
#'   `n_single_stroke` (rallies with `n_shots == 1`) and `single_stroke_pct`
#'   (percent of rallies, one decimal). Zero rows for empty input.
#' @export
dq_single_stroke_rallies <- function(rallies) {
  need <- c("match_id", "regime", "n_shots")
  if (!all(need %in% names(rallies))) {
    cli::cli_abort(c(
      "x" = "{.arg rallies} needs {.val {need}}.",
      "i" = "Missing: {.val {setdiff(need, names(rallies))}}."
    ))
  }
  if (nrow(rallies) == 0L) {
    return(tibble::tibble(
      match_id = rallies$match_id[0], regime = rallies$regime[0],
      n_rallies = integer(0), n_single_stroke = integer(0),
      single_stroke_pct = numeric(0)
    ))
  }
  rallies |>
    dplyr::summarise(
      n_rallies = dplyr::n(),
      n_single_stroke = sum(.data$n_shots %in% 1L),
      .by = c("match_id", "regime")
    ) |>
    dplyr::mutate(single_stroke_pct = round(100 * .data$n_single_stroke / .data$n_rallies, 1))
}
