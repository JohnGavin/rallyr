skip_if_not_installed("ggplot2")

sample_derived <- function() bundle_derived(bundle_to_tables(sample_bundle(), "Sample Player"))

# Build the plot (forces the ggplot2 layers and their data) and return it.
built <- function(p) {
  expect_s3_class(p, "ggplot")
  ggplot2::ggplot_build(p)
  p
}

test_that("each chart builds from the sample", {
  d <- sample_derived()
  trend <- built(plot_session_trend(d))
  expect_equal(nrow(trend$data), 18L)               # 3 metrics x 6 sessions
  rally <- built(plot_rally_length(d))
  expect_false("gap" %in% rally$data$regime)
  speed <- built(plot_stroke_speed(d))
  expect_true(all(speed$data$shot_speed_mph > 0))
  built(plot_net_clearance(d))
  gaps <- built(plot_gap_distribution(d))
  expect_gt(nrow(gaps$data), 0L)
})

test_that("the trend honours the date range and the metric choice", {
  d <- sample_derived()
  first_two <- as.Date(c("2030-01-01", "2030-01-13"))
  p <- plot_session_trend(d, date_range = first_two, metrics = "accuracy")
  expect_equal(nrow(p$data), 2L)
  expect_true(all(p$data$metric == "accuracy"))
  expect_error(plot_session_trend(d, date_range = as.Date("2030-01-01")), "two dates")
})

test_that("a chart with nothing to show says so instead of failing", {
  d <- sample_derived()
  p <- plot_session_trend(d, date_range = as.Date(c("2000-01-01", "2000-02-01")))
  expect_s3_class(p, "ggplot")
  expect_match(p$layers[[1]]$aes_params$label, "No sessions")

  one <- bundle_derived(bundle_to_tables(bundle_of(sample_session(1L)), "Sample Player"))
  p1 <- plot_session_trend(one)
  expect_match(p1$layers[[1]]$aes_params$label, "at least two")

  s <- sample_session(1L); s$shots$data <- list()
  none <- bundle_derived(bundle_to_tables(bundle_of(s), "Sample Player"))
  expect_match(plot_rally_length(none)$layers[[1]]$aes_params$label, "No rallies")
  expect_match(plot_stroke_speed(none)$layers[[1]]$aes_params$label, "No stroke speeds")
  expect_match(plot_gap_distribution(none)$layers[[1]]$aes_params$label, "No within-rally")
})

test_that("the gap chart marks the thresholds from dq_params()", {
  d <- sample_derived()
  p <- plot_gap_distribution(d)
  marks <- p$layers[[2]]$data
  expect_setequal(marks$x, unique(unlist(dq_params()$max_stroke_gap_sec)))
})

test_that("the charts refuse input that is not from bundle_derived()", {
  expect_error(plot_session_trend(list()), "bundle_derived")
  expect_error(plot_gap_distribution(NULL), "bundle_derived")
})

test_that("a chart can be written to a file", {
  d <- sample_derived()
  f <- withr::local_tempfile(fileext = ".png")
  ggplot2::ggsave(f, plot_rally_length(d), width = 5, height = 3, dpi = 50)
  expect_gt(file.size(f), 1000)
})
