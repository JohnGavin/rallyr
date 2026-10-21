mk_types <- function(player, hit_type, regime) {
  tibble::tibble(player = player, hit_type = hit_type, regime = regime)
}

test_that("the baseline side's volleys in a net-volley drill are suspect", {
  s <- mk_types(
    c("host", "guest", "guest", "host", "guest"),
    c("volley", "volley", "ground_stroke", "serve", "volley"),
    "net_volley"
  )
  out <- flag_hit_type_suspect(s)
  expect_equal(out$hit_type_suspect, c(FALSE, TRUE, FALSE, FALSE, TRUE))
})

test_that("volleys outside a net-volley drill are not flagged", {
  s <- mk_types(c("guest", "guest"), "volley",
                c("forehand_cross_court", "net_volley"))
  expect_equal(flag_hit_type_suspect(s)$hit_type_suspect, c(FALSE, TRUE))
})

test_that("me_side and net_regimes are configurable", {
  s <- mk_types(c("host", "guest"), "volley", "drill_x")
  out <- flag_hit_type_suspect(s, me_side = "host", net_regimes = "drill_x")
  expect_equal(out$hit_type_suspect, c(TRUE, FALSE))
})

test_that("NA fields are never flagged", {
  s <- mk_types(c("guest", NA, "guest"), c("volley", "volley", NA),
                c(NA, "net_volley", "net_volley"))
  expect_equal(flag_hit_type_suspect(s)$hit_type_suspect, c(FALSE, FALSE, FALSE))
})

test_that("hit_type itself is not changed", {
  s <- mk_types("guest", "volley", "net_volley")
  expect_equal(flag_hit_type_suspect(s)$hit_type, "volley")
})

test_that("missing columns are an error", {
  expect_error(flag_hit_type_suspect(tibble::tibble(player = "guest")), "hit_type")
})
