# The derived-data interface and its contract (rallyr#8), against the bundled
# synthetic sample only.

db_path <- system.file("extdata", "synthetic_sample.duckdb", package = "rallyr")
skip_if(!nzchar(db_path), "synthetic_sample.duckdb not built yet")

# A temporary copy, so the bundled file is never opened for writing.
tmp <- withr::local_tempfile(fileext = ".duckdb")
file.copy(db_path, tmp)
con <- tennis_db_connect(tmp)
withr::defer(DBI::dbDisconnect(con, shutdown = TRUE))

api_fns <- c(
  "rallyr_sessions", "rallyr_corrected_rallies", "rallyr_session_metrics",
  "rallyr_net_clearance", "rallyr_stroke_quality"
)

type_of <- function(x) {
  if (inherits(x, "POSIXct")) "POSIXct" else if (inherits(x, "Date")) "Date" else class(x)[1]
}

test_that("the schema version is a major.minor string with one home (#8)", {
  v <- rallyr_schema_version()
  expect_type(v, "character")
  expect_match(v, "^[0-9]+\\.[0-9]+$")
})

test_that("rallyr_api_schema() lists every API function, columns unique (#8)", {
  s <- rallyr_api_schema()
  expect_named(s, c("fn", "column", "type"))
  expect_setequal(unique(s$fn), api_fns)
  expect_false(anyDuplicated(s[, c("fn", "column")]) > 0)
  expect_true(all(s$type %in% c("character", "numeric", "integer", "logical", "Date", "POSIXct")))
})

test_that("the exported rallyr_*() functions are exactly the documented ones (#8)", {
  ex <- getNamespaceExports("rallyr")
  expect_setequal(
    grep("^rallyr_", ex, value = TRUE),
    c(api_fns, "rallyr_schema_version", "rallyr_api_schema")
  )
})

test_that("each API function returns its declared columns and types, stamped (#8)", {
  s <- rallyr_api_schema()
  for (fn in api_fns) {
    out <- get(fn)(con)
    expect_s3_class(out, "tbl_df")
    expect_gt(nrow(out), 0L)
    expect_identical(attr(out, "schema_version"), rallyr_schema_version())
    want <- s[s$fn == fn, ]
    expect_identical(names(out), want$column, label = paste(fn, "columns"))
    expect_identical(
      vapply(out, type_of, character(1), USE.NAMES = FALSE), want$type,
      label = paste(fn, "types")
    )
  }
})

test_that("shape drift is refused, not passed through silently (#8)", {
  good <- rallyr_net_clearance(con)
  expect_error(api_stamp(good[, -1], "rallyr_net_clearance"), "match_id")
  expect_error(api_stamp(good, "rallyr_not_a_function"), "rallyr_not_a_function")
})

test_that("dq_params can be passed through to the API (#8)", {
  p <- dq_params()
  p$max_rally_strokes$default <- 1
  p$max_rally_strokes$mini_tennis <- 1
  p$max_rally_strokes$forehand_cross_court <- 1
  p$max_rally_strokes$backhand_cross_court <- 1
  strict <- rallyr_corrected_rallies(con, params = p)
  loose <- rallyr_corrected_rallies(con)
  expect_lt(nrow(strict), nrow(loose))
})
