#' Charts of a bundle's derived data
#'
#' Five charts, each a [ggplot2::ggplot()] built from the list that
#' [bundle_derived()] returns. They are what the vignette and the browser app
#' show, so both read the same way. The text and grid colours are mid-tone and
#' the backgrounds transparent, so the charts stay legible on a light or a dark
#' page.
#'
#' | Function | Shows |
#' |---|---|
#' | `plot_session_trend()` | Accuracy, stroke rate and speed per session |
#' | `plot_rally_length()` | Shots per rally, by drill |
#' | `plot_stroke_speed()` | Your stroke speed, by drill |
#' | `plot_net_clearance()` | Median net clearance per session and drill, you and the feeder |
#' | `plot_gap_distribution()` | Pauses between strokes, with the rally-split thresholds |
#'
#' A chart that has nothing to show (for instance a trend with one session)
#' says so in the plot area instead of failing.
#'
#' @param derived The list returned by [bundle_derived()].
#' @param date_range For `plot_session_trend()`: two dates; only sessions in the
#'   range are drawn. `NULL` (default) draws all of them.
#' @param metrics For `plot_session_trend()`: which of the metric keys from
#'   [session_standard_metrics()] to draw.
#' @return A `ggplot` object.
#' @name rallyr-plots
NULL

plot_need_ggplot2 <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    cli::cli_abort(c(
      "x" = "The {.pkg ggplot2} package is needed to draw charts.",
      "i" = "Install it, or use the tables in the {.fn bundle_derived} result directly."
    ))
  }
}

plot_theme <- function() {
  grey <- "#737c86"
  faint <- "#737c8644"
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = grey),
      axis.text = ggplot2::element_text(colour = grey),
      axis.title = ggplot2::element_text(colour = grey),
      plot.title = ggplot2::element_text(colour = grey, face = "bold", size = 13),
      plot.subtitle = ggplot2::element_text(colour = grey),
      strip.text = ggplot2::element_text(colour = grey, face = "bold"),
      legend.text = ggplot2::element_text(colour = grey),
      legend.title = ggplot2::element_text(colour = grey),
      panel.grid.major = ggplot2::element_line(colour = faint),
      panel.grid.minor = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = NA, colour = NA),
      panel.background = ggplot2::element_rect(fill = NA, colour = NA),
      legend.background = ggplot2::element_rect(fill = NA, colour = NA),
      legend.position = "bottom"
    )
}

plot_empty <- function(title, msg) {
  ggplot2::ggplot() +
    ggplot2::annotate("text", x = 0, y = 0, label = msg, colour = "#737c86", size = 4.5) +
    ggplot2::labs(title = title) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(colour = "#737c86", face = "bold", size = 13),
      plot.background = ggplot2::element_rect(fill = NA, colour = NA)
    )
}

# "forehand_cross_court" -> "forehand cross court"
regime_label <- function(x) gsub("_", " ", x, fixed = TRUE)

plot_derived_ok <- function(derived) {
  if (!is.list(derived) || !"tables" %in% names(derived)) {
    cli::cli_abort(c(
      "x" = "{.arg derived} must be the result of {.fn bundle_derived}."
    ))
  }
}

# Okabe-Ito: distinguishable by people with colour-vision differences.
plot_colours <- c(me = "#0072B2", feeder = "#E69F00")

#' @rdname rallyr-plots
#' @export
plot_session_trend <- function(derived, date_range = NULL, metrics = c("accuracy", "stroke_rate", "speed")) {
  plot_need_ggplot2()
  plot_derived_ok(derived)
  title <- "Session trends"
  sm <- derived$session_metrics
  if (is.null(sm)) {
    return(plot_empty(title, "A trend needs at least two sessions."))
  }
  sm <- sm[sm$metric %in% metrics, ]
  if (!is.null(date_range)) {
    if (length(date_range) != 2L || anyNA(date_range)) {
      cli::cli_abort("{.arg date_range} must be two dates.")
    }
    dr <- as.Date(date_range)
    sm <- sm[sm$session_date >= dr[1] & sm$session_date <= dr[2], ]
  }
  sm <- sm[!is.na(sm$value), ]
  if (nrow(sm) == 0L) {
    return(plot_empty(title, "No sessions in this date range."))
  }
  sm$panel <- factor(sprintf("%s (%s)", sm$label, sm$unit), levels = unique(sprintf("%s (%s)", sm$label, sm$unit)))
  ggplot2::ggplot(sm, ggplot2::aes(x = .data$session_date, y = .data$value)) +
    ggplot2::geom_line(colour = plot_colours[["me"]], linewidth = 0.6) +
    ggplot2::geom_point(colour = plot_colours[["me"]], size = 2.2) +
    ggplot2::facet_wrap(ggplot2::vars(.data$panel), scales = "free_y", ncol = 1) +
    ggplot2::labs(title = title, x = NULL, y = NULL) +
    plot_theme()
}

#' @rdname rallyr-plots
#' @export
plot_rally_length <- function(derived) {
  plot_need_ggplot2()
  plot_derived_ok(derived)
  title <- "Rally length by drill"
  r <- derived$corrected_rallies
  if (is.null(r)) return(plot_empty(title, "No rallies in the data."))
  r <- r[!is.na(r$regime) & r$regime != "gap", ]
  if (nrow(r) == 0L) return(plot_empty(title, "No rallies fall in a recognised drill."))
  r$drill <- stats::reorder(regime_label(r$regime), r$n_shots, FUN = stats::median)
  ggplot2::ggplot(r, ggplot2::aes(x = .data$n_shots, y = .data$drill)) +
    ggplot2::geom_jitter(height = 0.18, width = 0, alpha = 0.35, size = 1.6, colour = plot_colours[["me"]]) +
    ggplot2::stat_summary(fun = stats::median, geom = "point", shape = 18, size = 4, colour = plot_colours[["feeder"]]) +
    ggplot2::scale_x_continuous(breaks = function(l) {
      seq(ceiling(l[1]), floor(l[2]), by = max(1, ceiling(diff(l) / 8)))
    }) +
    ggplot2::labs(
      title = title, x = "Shots per rally (both players; diamond = median)", y = NULL,
      caption = "Rallies after the data-quality corrections."
    ) +
    plot_theme()
}

#' @rdname rallyr-plots
#' @export
plot_stroke_speed <- function(derived) {
  plot_need_ggplot2()
  plot_derived_ok(derived)
  title <- "Stroke speed by drill"
  d <- dq_clean_shot_speed(derived$tables$shot_detail)
  d <- d[d$player == "guest" & !is.na(d$shot_speed_mph) & !is.na(d$regime) & d$regime != "gap", ]
  if (nrow(d) == 0L) return(plot_empty(title, "No stroke speeds in the data."))
  d$drill <- stats::reorder(regime_label(d$regime), d$shot_speed_mph, FUN = stats::median)
  ggplot2::ggplot(d, ggplot2::aes(x = .data$shot_speed_mph, y = .data$drill)) +
    ggplot2::geom_boxplot(
      colour = plot_colours[["me"]], fill = NA, outlier.alpha = 0.3, outlier.size = 1
    ) +
    ggplot2::labs(
      title = title, x = "Stroke speed (mph)", y = NULL,
      caption = "Your strokes only; placeholder speeds removed."
    ) +
    plot_theme()
}

#' @rdname rallyr-plots
#' @export
plot_net_clearance <- function(derived) {
  plot_need_ggplot2()
  plot_derived_ok(derived)
  title <- "Net clearance by drill"
  nc <- derived$net_clearance
  nc <- nc[!is.na(nc$regime) & nc$regime != "gap", ]
  if (nrow(nc) == 0L) return(plot_empty(title, "No net-clearance values in the data."))
  long <- dplyr::bind_rows(
    tibble::tibble(regime = nc$regime, side = "You", median_m = nc$me_median_m),
    tibble::tibble(regime = nc$regime, side = "Feeder", median_m = nc$opp_median_m)
  )
  long <- long[!is.na(long$median_m), ]
  if (nrow(long) == 0L) return(plot_empty(title, "No net-clearance values in the data."))
  long$drill <- regime_label(long$regime)
  ggplot2::ggplot(long, ggplot2::aes(x = .data$median_m, y = .data$drill, colour = .data$side, shape = .data$side)) +
    ggplot2::geom_point(
      position = ggplot2::position_jitter(height = 0.15, width = 0), size = 2.4, alpha = 0.8
    ) +
    ggplot2::scale_colour_manual(values = c(You = plot_colours[["me"]], Feeder = plot_colours[["feeder"]])) +
    ggplot2::labs(
      title = title, x = "Median net clearance (m), one point per session", y = NULL,
      colour = NULL, shape = NULL,
      caption = "The vendor does not say whether the height is above the ground or the net tape."
    ) +
    plot_theme()
}

#' @rdname rallyr-plots
#' @export
plot_gap_distribution <- function(derived) {
  plot_need_ggplot2()
  plot_derived_ok(derived)
  title <- "Pauses between strokes"
  gaps <- dq_stroke_gaps(derived$tables$shot_detail)
  if (nrow(gaps) == 0L) return(plot_empty(title, "No within-rally pauses in the data."))
  p <- dq_params()
  thr <- unlist(p$max_stroke_gap_sec)
  thr <- thr[names(thr) %in% p$pause_split_regimes]
  by_value <- split(names(thr), thr)
  marks <- tibble::tibble(
    x = as.numeric(names(by_value)),
    label = vapply(by_value, function(n) {
      paste(unique(regime_label(sub("^(forehand|backhand)_", "", n))), collapse = ", ")
    }, character(1))
  )
  shown <- gaps[gaps$gap_sec <= 10, ]
  n_beyond <- sum(gaps$gap_sec > 10)
  ggplot2::ggplot(shown, ggplot2::aes(x = .data$gap_sec)) +
    ggplot2::geom_histogram(binwidth = 0.25, boundary = 0, fill = plot_colours[["me"]], alpha = 0.75) +
    ggplot2::geom_vline(
      data = marks, ggplot2::aes(xintercept = .data$x),
      colour = plot_colours[["feeder"]], linetype = "dashed", linewidth = 0.7
    ) +
    ggplot2::geom_text(
      data = marks, ggplot2::aes(x = .data$x, y = Inf, label = paste0(.data$label, ": ", .data$x, " s")),
      colour = plot_colours[["feeder"]], angle = 90, hjust = 1.05, vjust = -0.4, size = 3.4
    ) +
    ggplot2::labs(
      title = title, x = "Seconds between consecutive strokes of a rally", y = "Pauses",
      caption = paste0(
        "Dashed lines: the pause that splits a rally.",
        if (n_beyond > 0L) {
          sprintf(" %d pause%s over 10 s not shown.", n_beyond, if (n_beyond == 1L) "" else "s")
        } else {
          ""
        }
      )
    ) +
    plot_theme()
}
