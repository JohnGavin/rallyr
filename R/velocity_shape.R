#' Rate of replicated-scalar velocity vectors, by group
#'
#' Some strokes carry a hit-velocity vector whose three components are the
#' same number (a scalar copied into every slot), so the vector's direction is
#' not a measurement. This monitor reports how often that happens, per group,
#' from the raw components the shot table persists (`hit_velocity_x`/`_y`/`_z`,
#' see [sv_parse_shots()]). Run it as sessions accumulate to see whether the
#' pattern correlates with stroke type, and whether it correlates with player
#' once stroke type is held fixed (group by both, as the default does).
#'
#' A stroke is **replicated** when the largest difference between its three
#' components is at most `tol`. A stroke with any missing component is not
#' usable and is neither counted as replicated nor as not. An all-zero vector
#' counts as replicated (its components are equal); check separately whether
#' you want zero vectors treated as missing.
#'
#' Reporting has three outcomes, never two: `"PRESENT"` (at least one
#' replicated stroke among the usable ones), `"ABSENT"` (usable strokes, none
#' replicated) and `"INDETERMINATE"` (fewer than `min_usable` usable strokes,
#' so a zero or a rate would say nothing; `reason` says why). An
#' indeterminate group is not a clean one.
#'
#' @param shots A tibble with `hit_velocity_x`, `hit_velocity_y`,
#'   `hit_velocity_z` and the columns named in `by`.
#' @param by Character vector of grouping columns. Default
#'   `c("hit_type", "player")`; add `"match_id"` for a per-session table, or
#'   pass `character(0)` for one overall row.
#' @param tol Largest allowed difference between components for a stroke to
#'   count as replicated; non-negative, default `1e-6`.
#' @param min_usable Minimum usable strokes for a group to be judged,
#'   default `10`.
#' @return A tibble, one row per group: the `by` columns, `n_strokes`,
#'   `n_usable`, `n_replicated`, `replicated_rate` (`n_replicated / n_usable`,
#'   `NA` when `n_usable` is 0), `status` and `reason` (`NA` unless
#'   indeterminate). Zero rows for empty input.
#' @export
dq_velocity_shape_rates <- function(shots, by = c("hit_type", "player"),
                                    tol = 1e-6, min_usable = 10L) {
  comps <- c("hit_velocity_x", "hit_velocity_y", "hit_velocity_z")
  need <- c(comps, by)
  if (!all(need %in% names(shots))) {
    cli::cli_abort(c(
      "x" = "{.arg shots} needs {.val {need}}.",
      "i" = "Missing: {.val {setdiff(need, names(shots))}}."
    ))
  }
  if (!is.numeric(tol) || length(tol) != 1L || is.na(tol) || tol < 0) {
    cli::cli_abort("{.arg tol} must be a single non-negative number.")
  }
  x <- shots[[comps[1]]]
  y <- shots[[comps[2]]]
  z <- shots[[comps[3]]]
  usable <- !is.na(x) & !is.na(y) & !is.na(z)
  spread <- pmax(x, y, z) - pmin(x, y, z)
  d <- shots[, by, drop = FALSE]
  d$.usable <- usable
  d$.replicated <- usable & spread <= tol

  if (nrow(d) == 0L) {
    out <- tibble::as_tibble(d[0, by, drop = FALSE])
    out$n_strokes <- integer(0)
    out$n_usable <- integer(0)
    out$n_replicated <- integer(0)
    out$replicated_rate <- numeric(0)
    out$status <- character(0)
    out$reason <- character(0)
    return(out)
  }
  res <- dplyr::summarise(
    d,
    n_strokes = dplyr::n(),
    n_usable = sum(.data$.usable),
    n_replicated = sum(.data$.replicated),
    .by = dplyr::all_of(by)
  )
  res$replicated_rate <- ifelse(res$n_usable > 0L, res$n_replicated / res$n_usable, NA_real_)
  res$status <- dplyr::case_when(
    res$n_usable < min_usable ~ "INDETERMINATE",
    res$n_replicated > 0L ~ "PRESENT",
    TRUE ~ "ABSENT"
  )
  res$reason <- ifelse(
    res$status == "INDETERMINATE",
    sprintf("%d usable strokes, need %d", res$n_usable, as.integer(min_usable)),
    NA_character_
  )
  if (length(by) > 0L) {
    res <- dplyr::arrange(res, dplyr::across(dplyr::all_of(by)))
  }
  res
}
