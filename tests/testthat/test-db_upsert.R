# Upsert accepts a frame with a column the stored table lacks (rallyr#7).

local_db <- function(env = parent.frame()) {
  db <- withr::local_tempfile(fileext = ".duckdb", .local_envir = env)
  con <- tennis_db_connect(db)
  withr::defer(DBI::dbDisconnect(con, shutdown = TRUE), envir = env)
  con
}

test_that("upsert adds a missing column, leaving old rows NA (#7)", {
  con <- local_db()
  tennis_db_upsert(con, tibble::tibble(match_id = 1, a = "x"), table = "t")
  tennis_db_upsert(con, tibble::tibble(match_id = 2, a = "y", newcol = 3.5), table = "t")

  out <- DBI::dbGetQuery(con, "SELECT * FROM t ORDER BY match_id")
  expect_equal(nrow(out), 2L)
  expect_true("newcol" %in% names(out))
  expect_true(is.na(out$newcol[1]))
  expect_equal(out$newcol[2], 3.5)
})

test_that("a re-upsert of an existing key replaces rows and fills the new column (#7)", {
  con <- local_db()
  tennis_db_upsert(con, tibble::tibble(match_id = 1, a = "x"), table = "t")
  tennis_db_upsert(con, tibble::tibble(match_id = 1, a = "x2", newcol = TRUE), table = "t")

  out <- DBI::dbGetQuery(con, "SELECT * FROM t")
  expect_equal(nrow(out), 1L)
  expect_equal(out$a, "x2")
  expect_true(out$newcol)
})

test_that("existing columns are never dropped or retyped by an upsert (#7)", {
  con <- local_db()
  tennis_db_upsert(con, tibble::tibble(match_id = 1, a = "x", b = 1), table = "t")
  before <- DBI::dbGetQuery(con, "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 't' ORDER BY column_name")
  # incoming frame lacks `b`: stays in the table, NA for the new row
  tennis_db_upsert(con, tibble::tibble(match_id = 2, a = "y"), table = "t")
  after <- DBI::dbGetQuery(con, "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 't' ORDER BY column_name")
  expect_equal(after, before)
})
