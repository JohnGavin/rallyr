# sv_parse_shots() builds each column once across all shots. The result must
# be IDENTICAL to the original one-tibble-per-shot implementation, kept here
# as the reference.

reference_parse_shots <- function(shots) {
  rows <- lapply(shots, function(sh) {
    tibble::tibble(
      match_id       = sv_num(sh$match_id),
      shot_id        = sv_num(sh$id),
      rally_id       = sv_num(sh$pid),
      player         = sv_chr(sh$player),
      started_at     = sv_time(sh$started_at),
      ended_at       = sv_time(sh$ended_at),
      hit_wing       = sv_chr(sh$hit_wing),
      hit_type       = sv_chr(sh$hit_type),
      spin_type      = sv_chr(sh$spin_type),
      shot_speed_mph = sv_speed_mph(sh$hit_velocity),
      shot_in        = sv_shot_in(sh$net_type, sh$bounce_location_long, sh$bounce_location_lat),
      hit_frame            = sv_num(sh$hit_frame),
      video_elapsed_sec    = sv_video_elapsed_sec(sh$hit_frame),
      hit_court_side       = sv_chr(sh$hit_court_side),
      bounce_court_side    = sv_chr(sh$bounce_court_side),
      net_clearance_m      = sv_net_clearance_m(sh$net_location),
      bounce_location_long = sv_chr(sh$bounce_location_long),
      bounce_location_lat  = sv_chr(sh$bounce_location_lat),
      hit_x    = sv_component(sh$hit_location, 1L),
      hit_y    = sv_component(sh$hit_location, 2L),
      hit_z    = sv_component(sh$hit_location, 3L),
      bounce_x = sv_component(sh$bounce_location, 1L),
      bounce_y = sv_component(sh$bounce_location, 2L),
      bounce_z = sv_component(sh$bounce_location, 3L),
      hit_velocity_x = sv_component(sh$hit_velocity, 1L),
      hit_velocity_y = sv_component(sh$hit_velocity, 2L),
      hit_velocity_z = sv_component(sh$hit_velocity, 3L)
    )
  })
  dplyr::bind_rows(rows) |> dplyr::arrange(started_at)
}

test_that("sv_parse_shots() is identical to the per-shot reference on every sample session", {
  b <- sample_bundle()
  expect_length(b$sessions, 6L)
  for (s in b$sessions) {
    sh <- s$shots$data
    expect_gt(length(sh), 100L)
    expect_identical(sv_parse_shots(sh), reference_parse_shots(sh))
  }
})

test_that("sv_parse_shots() is identical to the reference when fields are missing", {
  sh <- sample_bundle()$sessions[[1]]$shots$data[1:12]
  sh[[1]]$hit_velocity <- NULL
  sh[[2]]$net_location <- NULL
  sh[[3]]$hit_location <- list(1, 2)
  sh[[4]]$bounce_location <- NULL
  sh[[5]]$net_type <- "net"
  sh[[6]]$player <- NULL
  sh[[7]]$hit_frame <- NULL
  sh[[8]]$pid <- NULL
  sh[[9]]$hit_velocity <- c(0, 0, 0)
  sh[[10]]$started_at <- "2030-01-01T10:00:00Z"
  sh[[11]]$bounce_location_lat <- "ad_out"
  sh[[12]]$hit_velocity <- list(1, NULL, 3)
  expect_identical(sv_parse_shots(sh), reference_parse_shots(sh))
  one <- sh[1]
  expect_identical(sv_parse_shots(one), reference_parse_shots(one))
})

test_that("the sample's tables and derived data are identical to those of the original code", {
  # fixtures/sample_tables_derived_reference.rds was made with the code as it
  # was BEFORE the speed-up (bundle_to_tables() and bundle_derived() on the
  # sample bundle, player "Sample Player"). It is synthetic data only.
  ref <- readRDS(test_path("fixtures", "sample_tables_derived_reference.rds"))
  tb <- bundle_to_tables(sample_bundle(), "Sample Player")
  expect_identical(tb, ref$tables)
  d <- bundle_derived(tb)
  expect_identical(d[setdiff(names(d), "tables")], ref$derived)
})

test_that("a whole sample bundle is read quickly", {
  skip_on_cran()
  b <- sample_bundle()
  elapsed <- unname(system.time(bundle_to_tables(b, "Sample Player"))[["elapsed"]])
  # The per-shot implementation took about 5 s natively; the limit is generous
  # so a slow machine does not fail it.
  expect_lt(elapsed, 2)
})
