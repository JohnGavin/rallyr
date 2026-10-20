test_that("a bundle round-trips through a file unchanged", {
  b <- sample_bundle()
  path <- withr::local_tempfile(fileext = ".json.gz")
  expect_identical(bundle_write(b, path), path)
  back <- bundle_read(path)
  expect_s3_class(back, "rallyr_bundle")
  expect_identical(back$sessions, b$sessions)
  expect_identical(back$schema_version, bundle_schema_version())
  # the file is gzip (magic bytes 1f 8b)
  expect_identical(readBin(path, "raw", 2L), as.raw(c(0x1f, 0x8b)))
})

test_that("an empty bundle round-trips and plain (uncompressed) JSON is read too", {
  path <- withr::local_tempfile(fileext = ".json.gz")
  bundle_write(bundle_new(), path)
  expect_length(bundle_read(path)$sessions, 0L)

  plain <- withr::local_tempfile(fileext = ".json")
  writeLines('{"schema_version": 1, "sessions": []}', plain)
  expect_length(bundle_read(plain)$sessions, 0L)
})

test_that("single-element arrays and nulls survive the round trip", {
  s <- sample_session(1L)
  s$shots$data <- s$shots$data[1]                      # a one-shot array
  s$shots$data[[1]]$hit_velocity <- list(1.5)          # a one-element array
  s$shots$data[[1]]$extra <- NULL
  s$match$data$note <- NULL
  s$match$data$court$surface <- NULL
  b <- bundle_of(s)
  path <- withr::local_tempfile(fileext = ".json.gz")
  bundle_write(b, path)
  back <- bundle_read(path)
  expect_identical(back$sessions[[1]]$shots, s$shots)
  expect_true(is.list(back$sessions[[1]]$shots$data))
})

# ---- payload detection -----------------------------------------------------

test_that("payload kind is decided by content, not by file name or order", {
  dir <- withr::local_tempdir()
  s <- sample_session(1L)
  p <- write_session_files(s, dir, names = c("zzz.json", "match.json", "1.json"))
  expect_identical(unname(vapply(p, bundle_payload_kind, character(1))), c("match", "stats", "shots"))
  # bare `data` element, without the {"data": ...} wrapper
  q <- write_session_files(s, dir, names = c("d1.json", "d2.json", "d3.json"), wrap = FALSE)
  expect_identical(unname(vapply(q, bundle_payload_kind, character(1))), c("match", "stats", "shots"))
  # an already-parsed list works too
  expect_identical(bundle_payload_kind(s$stats), "stats")
})

test_that("an empty shot list is shots; unrecognised content is an error or NA", {
  expect_identical(bundle_payload_kind(list(data = list())), "shots")
  expect_identical(bundle_payload_kind(list()), "shots")
  odd <- list(data = list(foo = 1, bar = "x"))
  expect_error(bundle_payload_kind(odd), "Cannot tell")
  expect_identical(bundle_payload_kind(odd, strict = FALSE), NA_character_)
  expect_identical(bundle_payload_kind(list(data = 5), strict = FALSE), NA_character_)
  expect_error(bundle_payload_kind(42), "path to a JSON file")
  expect_error(bundle_payload_kind("/no/such/file.json"), "existing file")
})

test_that("a file that is not JSON is an error that says so", {
  p <- withr::local_tempfile(fileext = ".json")
  writeLines("this is not json {", p)
  expect_error(bundle_payload_kind(p), "not valid JSON")
})

test_that("a file whose whole text is a URL or a file path is never followed", {
  # jsonlite::fromJSON() would fetch a URL, or read a file, given as the text.
  # A request shows as a warning from the connection (the host does not exist).
  url_file <- withr::local_tempfile(fileext = ".json")
  writeLines("https://x.example/y", url_file)
  expect_no_warning(expect_error(bundle_payload_kind(url_file), "not valid JSON"))
  expect_no_warning(expect_error(bundle_read(url_file), "not valid JSON"))
  no_newline <- withr::local_tempfile(fileext = ".json")
  cat("https://x.example/y", file = no_newline)
  expect_no_warning(expect_error(bundle_read(no_newline), "not valid JSON"))

  other <- withr::local_tempfile(fileext = ".json")
  writeLines('{"schema_version": 1, "sessions": []}', other)
  path_file <- withr::local_tempfile(fileext = ".json")
  cat(other, file = path_file)   # no newline: the text is exactly an existing path
  expect_error(bundle_read(path_file), "not valid JSON")
  expect_error(bundle_payload_kind(path_file), "not valid JSON")
})

# ---- adding a session ------------------------------------------------------

test_that("bundle_add_raw() takes the three files in any order and reports it", {
  dir <- withr::local_tempdir()
  s <- sample_session(1L, id = 5550001)
  f <- write_session_files(s, dir)
  out <- bundle_add_raw(bundle_new(), f[3], f[1], f[2], token = "sw2-EXAMPLE01", fetched_at = "2031-01-01T00:00:00Z")
  expect_length(out$sessions, 1L)
  ses <- out$sessions[[1]]
  expect_equal(ses$match_id, 5550001)
  expect_identical(ses$token, "sw2-EXAMPLE01")
  expect_identical(ses$fetched_at, "2031-01-01T00:00:00Z")
  rep <- attr(out, "merge_report")
  expect_identical(rep$action, "added")
  expect_equal(rep$match_id, 5550001)
  # the stored payloads are the saved ones, so they parse as the sample does
  tb <- bundle_to_tables(out, "Sample Player")
  expect_equal(tb$matches$match_id, 5550001)
})

test_that("bundle_add_raw() leaves out the token field when none is given", {
  s <- sample_session(1L)
  out <- bundle_add_raw(bundle_new(), s$match, s$stats, s$shots)
  expect_null(out$sessions[[1]]$token)
  expect_match(out$sessions[[1]]$fetched_at, "^\\d{4}-\\d{2}-\\d{2}T")
})

test_that("bundle_add_raw() refuses the wrong number or mix of payloads", {
  s <- sample_session(1L)
  expect_error(bundle_add_raw(bundle_new(), s$match, s$stats), "exactly three")
  expect_error(bundle_add_raw(bundle_new(), s$match, s$stats, s$stats), "one match, one stats and one shots")
  expect_error(bundle_add_raw(bundle_new(), s$match, s$stats, list(data = list(x = 1))), "Cannot tell")
  expect_error(bundle_add_raw(list(), s$match, s$stats, s$shots), "must be a bundle")
})

test_that("bundle_add_raw() refuses shots from another match", {
  a <- sample_session(1L)
  b <- sample_session(2L)
  expect_error(bundle_add_raw(bundle_new(), a$match, a$stats, b$shots), "do not belong to this match")
})

# ---- merging ---------------------------------------------------------------

test_that("merging adds new sessions and replaces older copies of the same match", {
  old <- sample_session(1L); old$fetched_at <- "2031-01-01T00:00:00Z"
  new <- old; new$fetched_at <- "2031-06-01T00:00:00Z"
  new$match$data$recording_duration <- 9999   # so the copies differ
  other <- sample_session(2L); other$fetched_at <- "2031-06-01T00:00:00Z"

  m <- bundle_merge(bundle_of(old), bundle_of(new, other))
  rep <- attr(m, "merge_report")
  expect_identical(rep$action, c("replaced", "added"))
  expect_length(m$sessions, 2L)
  expect_identical(m$sessions[[1]]$match$data$recording_duration, 9999)
  expect_identical(rep$existing_fetched_at, c("2031-01-01T00:00:00Z", NA))
})

test_that("an equal fetch time lets the incoming copy replace", {
  a <- sample_session(1L); a$fetched_at <- "2031-01-01T00:00:00Z"
  b <- a; b$match$data$recording_duration <- 1234
  m <- bundle_merge(bundle_of(a), bundle_of(b))
  expect_identical(attr(m, "merge_report")$action, "replaced")
  expect_identical(m$sessions[[1]]$match$data$recording_duration, 1234)
})

test_that("an older incoming copy is kept out, and an identical one is unchanged", {
  new <- sample_session(1L); new$fetched_at <- "2031-06-01T00:00:00Z"
  older <- new; older$fetched_at <- "2031-01-01T00:00:00Z"
  older$match$data$recording_duration <- 1
  m <- bundle_merge(bundle_of(new), bundle_of(older))
  expect_identical(attr(m, "merge_report")$action, "kept")
  expect_identical(m$sessions[[1]], new)

  same <- new; same$fetched_at <- "2032-01-01T00:00:00Z"   # newer stamp, same payloads
  m2 <- bundle_merge(bundle_of(new), bundle_of(same))
  expect_identical(attr(m2, "merge_report")$action, "unchanged")
  expect_identical(m2$sessions[[1]]$fetched_at, "2031-06-01T00:00:00Z")
})

test_that("a copy with no fetch time counts as the oldest", {
  with_time <- sample_session(1L); with_time$fetched_at <- "2031-01-01T00:00:00Z"
  without <- with_time; without$fetched_at <- NULL; without$match$data$recording_duration <- 7
  m <- bundle_merge(bundle_of(with_time), bundle_of(without))
  expect_identical(attr(m, "merge_report")$action, "kept")
})

test_that("merging with an empty bundle changes nothing and reports nothing", {
  b <- sample_bundle()
  m <- bundle_merge(b, bundle_new())
  expect_identical(m$sessions, b$sessions)
  expect_equal(nrow(attr(m, "merge_report")), 0L)
  expect_identical(
    names(attr(m, "merge_report")),
    c("match_id", "action", "existing_fetched_at", "incoming_fetched_at")
  )
})

# ---- reading: schema version and malformed input ---------------------------

write_json_file <- function(x, gz = FALSE) {
  p <- withr::local_tempfile(fileext = if (gz) ".json.gz" else ".json", .local_envir = parent.frame())
  txt <- jsonlite::toJSON(x, auto_unbox = TRUE, null = "null", digits = NA)
  if (gz) {
    con <- gzfile(p, "wb"); writeLines(as.character(txt), con); close(con)
  } else {
    writeLines(as.character(txt), p)
  }
  p
}

test_that("the schema version is checked", {
  good <- list(schema_version = 1L, sessions = list())
  expect_s3_class(bundle_read(write_json_file(good)), "rallyr_bundle")

  expect_error(bundle_read(write_json_file(list(sessions = list()))), "schema_version")
  expect_error(bundle_read(write_json_file(list(schema_version = "1", sessions = list()))), "schema_version")
  expect_error(bundle_read(write_json_file(list(schema_version = 1.5, sessions = list()))), "schema_version")
  expect_error(bundle_read(write_json_file(list(schema_version = 0, sessions = list()))), "schema_version")
  expect_error(
    bundle_read(write_json_file(list(schema_version = bundle_schema_version() + 1L, sessions = list()))),
    "file format version"
  )
})

test_that("malformed bundle files are errors, never partial reads", {
  expect_error(bundle_read("/no/such/file.json.gz"), "existing file")

  empty <- withr::local_tempfile()
  file.create(empty)
  expect_error(bundle_read(empty), "empty")

  junk <- withr::local_tempfile()
  writeLines("not json at all", junk)
  expect_error(bundle_read(junk), "not valid JSON")

  expect_error(bundle_read(write_json_file(list(1, 2))), "Not a valid rallyr bundle")
  expect_error(bundle_read(write_json_file(list(schema_version = 1L))), "sessions")
  expect_error(bundle_read(write_json_file(list(schema_version = 1L, sessions = "x"))), "sessions")

  s <- sample_session(1L)
  no_shots <- s; no_shots$shots <- NULL
  expect_error(bundle_read(write_json_file(list(schema_version = 1L, sessions = list(no_shots)))), "no .*shots")
  no_id <- s; no_id$match_id <- NULL
  expect_error(bundle_read(write_json_file(list(schema_version = 1L, sessions = list(no_id)))), "match_id")
  swapped <- s; swapped$match <- s$stats
  expect_error(bundle_read(write_json_file(list(schema_version = 1L, sessions = list(swapped)))), "does not look like")
  expect_error(bundle_read(write_json_file(list(schema_version = 1L, sessions = list("x")))), "not an object")
})

test_that("a bundle with two sessions of the same match is refused", {
  s <- sample_session(1L)
  expect_error(
    bundle_read(write_json_file(list(schema_version = 1L, sessions = list(s, s)))),
    "share a"
  )
})

test_that("bundle functions refuse something that is not a bundle", {
  expect_error(bundle_write(list(), tempfile()), "must be a bundle")
  expect_error(bundle_merge(sample_bundle(), list()), "must be a bundle")
  expect_error(bundle_write(sample_bundle(), c("a", "b")), "single file path")
  expect_error(bundle_to_tables(list(), "x"), "must be a bundle")
})

test_that("a bundle file cannot make bundle_read() read some other file", {
  # A string where a payload should be is just wrong content, not a path.
  secret <- withr::local_tempfile()
  writeLines('{"data": {"id": 1, "guest_name": "x"}}', secret)
  s <- sample_session(1L)
  s$match <- secret
  expect_error(bundle_read(write_json_file(list(schema_version = 1L, sessions = list(s)))), "does not look like")
})

# ---- players, tables, derived ---------------------------------------------

test_that("bundle_players() lists the names, most frequent first", {
  expect_setequal(bundle_players(sample_bundle()), c("Sample Player", "Sample Opponent"))
  expect_identical(bundle_players(bundle_new()), character(0))
  a <- sample_session(1L); a$match$data$guest_name <- "Zed"
  b <- sample_session(2L); b$match$data$guest_name <- "Zed"
  c3 <- sample_session(3L)
  expect_identical(bundle_players(bundle_of(a, b, c3))[1], "Sample Opponent")
})

test_that("bundle_to_tables() gives the tables the metrics read, from the sample", {
  tb <- bundle_to_tables(sample_bundle(), "Sample Player")
  expect_named(tb, c("matches", "shot_segments", "shot_detail", "rallies", "skipped"))
  expect_equal(nrow(tb$matches), 6L)
  expect_equal(nrow(tb$skipped), 0L)
  expect_true(all(c("match_id", "shot_id", "rally_id", "player", "started_at", "shot_speed_mph",
                    "shot_in", "regime", "net_clearance_m") %in% names(tb$shot_detail)))
  expect_true(all(c("match_id", "rally_id", "n_shots", "regime") %in% names(tb$rallies)))
  expect_false(is.unsorted(tb$matches$played_at))
})

test_that("the tables from the sample bundle agree with the sample database", {
  db <- system.file("extdata", "synthetic_sample.duckdb", package = "rallyr")
  skip_if(!nzchar(db))
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = db, read_only = TRUE)
  withr::defer(DBI::dbDisconnect(con, shutdown = TRUE))
  m_db <- DBI::dbGetQuery(con, "SELECT * FROM matches ORDER BY match_id")
  s_db <- DBI::dbGetQuery(con, "SELECT * FROM shot_detail ORDER BY match_id, shot_id")

  tb <- bundle_to_tables(sample_bundle(), "Sample Player")
  m <- tb$matches[order(tb$matches$match_id), ]
  s <- tb$shot_detail[order(tb$shot_detail$match_id, tb$shot_detail$shot_id), ]
  for (col in c("me_shots", "me_shots_in", "shots_in_pct", "fh_shots", "bh_shots",
                "fh_speed_mph", "bh_speed_mph", "duration_min", "me_run_mi", "opp_shots")) {
    expect_equal(as.numeric(m[[col]]), as.numeric(m_db[[col]]), info = col)
  }
  expect_identical(as.character(m$session_date), as.character(m_db$session_date))
  expect_equal(nrow(s), nrow(s_db))
  expect_equal(s$shot_speed_mph, s_db$shot_speed_mph)
  expect_identical(s$shot_in, as.logical(s_db$shot_in))
  expect_identical(s$regime, s_db$regime)
  expect_equal(s$net_clearance_m, s_db$net_clearance_m)
})

test_that("either side of a match can be 'me', and names match loosely", {
  b <- sample_bundle()
  guest <- bundle_to_tables(b, "  sample PLAYER ")
  host <- bundle_to_tables(b, "Sample Opponent")
  expect_equal(host$matches$me_shots, guest$matches$opp_shots)
  expect_equal(host$matches$opp_shots, guest$matches$me_shots)
  # the analysed player is always on the "guest" side of the shot table
  n_guest <- sum(guest$shot_detail$player == "guest")
  expect_equal(sum(host$shot_detail$player == "guest"), nrow(host$shot_detail) - n_guest)
})

test_that("a name that is in no session gives an empty, explained result", {
  tb <- bundle_to_tables(sample_bundle(), "Nobody")
  expect_equal(nrow(tb$matches), 0L)
  expect_equal(nrow(tb$skipped), 6L)
  expect_true(all(tb$skipped$reason == "player not in this session"))
  expect_error(bundle_derived(tb), "no sessions")
  expect_error(bundle_to_tables(sample_bundle(), ""), "player name")
  expect_error(bundle_to_tables(sample_bundle(), NA_character_), "player name")
})

test_that("a session that cannot be parsed aborts, or is skipped and listed", {
  bad <- sample_session(2L)
  bad$stats$data$guest <- list()          # no whole-session set to read
  b <- bundle_of(sample_session(1L), bad)
  expect_error(bundle_to_tables(b, "Sample Player"))
  tb <- bundle_to_tables(b, "Sample Player", on_error = "skip")
  expect_equal(nrow(tb$matches), 1L)
  expect_match(tb$skipped$reason, "could not be parsed")
  expect_equal(tb$skipped$match_id, bad$match_id)
})

test_that("a session with no shots gives a match row and no shot rows", {
  s <- sample_session(1L)
  s$shots$data <- list()
  tb <- bundle_to_tables(bundle_of(s), "Sample Player")
  expect_equal(nrow(tb$matches), 1L)
  expect_equal(nrow(tb$shot_detail), 0L)
  expect_equal(nrow(tb$rallies), 0L)
  d <- bundle_derived(tb)
  expect_null(d$corrected_rallies)
  expect_null(d$session_metrics)
})

test_that("the cache remembers sessions and is keyed by player", {
  b <- sample_bundle()
  cache <- new.env()
  first <- bundle_to_tables(b, "Sample Player", cache = cache)
  expect_length(ls(cache), 6L)
  # poison one cached entry: a second call must use the cache, not recompute
  key <- ls(cache)[1]
  poisoned <- get(key, cache)
  poisoned$matches$me_shots <- -1
  assign(key, poisoned, envir = cache)
  second <- bundle_to_tables(b, "Sample Player", cache = cache)
  expect_true(-1 %in% second$matches$me_shots)
  # another player does not read that entry
  other <- bundle_to_tables(b, "Sample Opponent", cache = cache)
  expect_false(-1 %in% other$matches$me_shots)
  expect_length(ls(cache), 12L)
  expect_error(bundle_to_tables(b, "Sample Player", cache = "no"), "environment")
})

test_that("bundle_derived() returns the five derived-data tables with their schema", {
  d <- bundle_derived(bundle_to_tables(sample_bundle(), "Sample Player"))
  expect_named(d, c("sessions", "corrected_rallies", "session_metrics", "net_clearance",
                    "stroke_quality", "tables"))
  expect_equal(nrow(d$sessions), 6L)
  for (nm in setdiff(names(d), "tables")) {
    expect_identical(attr(d[[nm]], "schema_version"), rallyr_schema_version(), info = nm)
  }
  expect_equal(nrow(d$stroke_quality), 6L)
  expect_error(bundle_derived(list()), "bundle_to_tables")
})

test_that("one session gives no trend table but everything else", {
  d <- bundle_derived(bundle_to_tables(bundle_of(sample_session(1L)), "Sample Player"))
  expect_null(d$session_metrics)
  expect_equal(nrow(d$sessions), 1L)
  expect_gt(nrow(d$corrected_rallies), 0L)
})

test_that("adding a session by file gives the same tables as the stored one", {
  dir <- withr::local_tempdir()
  s <- sample_session(3L)
  f <- write_session_files(s, dir)
  built <- bundle_add_raw(bundle_new(), f[1], f[2], f[3], fetched_at = s$fetched_at)
  a <- bundle_to_tables(built, "Sample Player")
  b <- bundle_to_tables(bundle_of(s), "Sample Player")
  expect_equal(a$shot_detail$shot_speed_mph, b$shot_detail$shot_speed_mph)
  expect_equal(a$matches$me_shots, b$matches$me_shots)
  expect_identical(a$shot_detail$regime, b$shot_detail$regime)
})

test_that("print() of a bundle says how many sessions it holds", {
  expect_output(print(sample_bundle()), "6 session")
})

test_that("the committed sample bundle is the one the generator builds", {
  skip_if(!nzchar(sample_bundle_path()))
  db <- system.file("extdata", "synthetic_sample.duckdb", package = "rallyr")
  skip_if(!nzchar(db))
  script <- test_path("..", "..", "data-raw", "generate_sample_bundle.R")
  skip_if_not(file.exists(script), "data-raw/ is not part of the installed package")
  env <- new.env(parent = globalenv())
  withr::local_envvar(c(SYNTHETIC_BUNDLE_SKIP_LOAD = "1", SYNTHETIC_BUNDLE_SKIP_MAIN = "1"))
  sys.source(script, envir = env)
  # compare as files would: through one write and read (numbers keep 15 digits)
  path <- withr::local_tempfile(fileext = ".json.gz")
  bundle_write(env$.synthetic_sample_bundle(db), path)
  expect_identical(bundle_read(path)$sessions, sample_bundle()$sessions)
})

test_that("the sample bundle holds only synthetic content", {
  b <- sample_bundle()
  names_in <- bundle_players(b)
  expect_true(all(grepl("^Sample ", names_in)))
  expect_true(all(vapply(b$sessions, function(s) grepl("^synthetic-", s$token), logical(1))))
  expect_true(all(vapply(b$sessions, function(s) {
    as.Date(substr(s$match$data$started_at, 1, 10)) >= as.Date("2029-01-01")
  }, logical(1))))
})

# ---- fetch times are compared as times ---------------------------------------

test_that("fetch times are compared as instants: offsets, fractions and Z", {
  base <- sample_session(1L)
  differ <- function(s) { s$match$data$recording_duration <- 4321; s }
  stamp <- function(s, at) { s$fetched_at <- at; s }
  action <- function(old, new) {
    attr(bundle_merge(bundle_of(stamp(base, old)), bundle_of(stamp(differ(base), new))), "merge_report")$action
  }
  # 10:00 at +02:00 is 08:00Z, EARLIER than 09:00Z (string order says later)
  expect_identical(action("2031-01-01T09:00:00Z", "2031-01-01T10:00:00+02:00"), "kept")
  # 10:00 at -02:00 is 12:00Z, later than 09:00Z
  expect_identical(action("2031-01-01T09:00:00Z", "2031-01-01T10:00:00-02:00"), "replaced")
  expect_identical(action("2031-01-01T09:00:00Z", "2031-01-01T10:00:00-0200"), "replaced")
  # fractional seconds
  expect_identical(action("2031-01-01T09:00:00.500Z", "2031-01-01T09:00:00.250Z"), "kept")
  expect_identical(action("2031-01-01T09:00:00.250Z", "2031-01-01T09:00:00.500Z"), "replaced")
  # the same instant written two ways ties, and a tie replaces
  expect_identical(action("2031-01-01T09:00:00Z", "2031-01-01T11:00:00+02:00"), "replaced")
})

test_that("an unreadable fetch time is refused with a clear message", {
  s <- sample_session(1L)
  for (bad in c("yesterday", "2031-13-45T00:00:00Z", "", "2031-01-01T25:00:00Z")) {
    s$fetched_at <- bad
    expect_error(bundle_merge(bundle_new(), bundle_of(s)), "fetched_at", info = bad)
  }
  s$fetched_at <- 12345
  expect_error(bundle_validate(bundle_of(s)), "fetched_at")
  expect_error(
    bundle_add_raw(bundle_new(), sample_session(1L)$match, sample_session(1L)$stats,
                   sample_session(1L)$shots, fetched_at = "garbage"),
    "fetched_at"
  )
})

# ---- the per-session cache sees the content ----------------------------------

test_that("a same-stamp replacement does not read a stale cache entry", {
  a <- sample_session(1L); a$fetched_at <- "2031-01-01T00:00:00Z"
  b <- a
  b$shots$data <- b$shots$data[-1]            # one shot fewer, same match, same stamp
  cache <- new.env()
  first <- bundle_to_tables(bundle_of(a), "Sample Player", cache = cache)
  second <- bundle_to_tables(bundle_of(b), "Sample Player", cache = cache)
  expect_equal(nrow(second$shot_detail), nrow(first$shot_detail) - 1L)
  expect_length(ls(cache), 2L)
})

# ---- a session's ids agree ---------------------------------------------------

test_that("a session's match_id must equal its match payload id and its shots' ids", {
  s <- sample_session(1L)
  wrong_id <- s; wrong_id$match_id <- s$match_id + 1
  expect_error(bundle_validate(bundle_of(wrong_id)), "does not match")
  no_payload_id <- s; no_payload_id$match$data$id <- NULL
  expect_error(bundle_validate(bundle_of(no_payload_id)), "Cannot|no .*id|does not look like")
  foreign <- s; foreign$shots$data[[2]]$match_id <- s$match_id + 7
  expect_error(bundle_validate(bundle_of(foreign)), "shots .*do not belong|belong")
  # a read bundle is checked too
  path <- withr::local_tempfile(fileext = ".json.gz")
  con <- gzfile(path, "wb")
  writeLines(as.character(jsonlite::toJSON(
    list(schema_version = 1L, sessions = list(wrong_id)), auto_unbox = TRUE, null = "null", digits = NA
  )), con)
  close(con)
  expect_error(bundle_read(path), "does not match")
  # two sessions for one match are still refused
  expect_error(bundle_validate(bundle_of(s, s)), "share a")
})

# ---- the tie rule and tokens on replace --------------------------------------

test_that("a replaced or unchanged session keeps the incoming token, else the existing one", {
  old <- sample_session(1L); old$fetched_at <- "2031-01-01T00:00:00Z"; old$token <- "sw2-OLD00001"
  new_token <- old; new_token$token <- "sw2-NEW00001"
  no_token <- old; no_token$token <- NULL

  # unchanged payload, incoming token wins; the existing fetch time stays
  m <- bundle_merge(bundle_of(old), bundle_of(new_token))
  expect_identical(attr(m, "merge_report")$action, "unchanged")
  expect_identical(m$sessions[[1]]$token, "sw2-NEW00001")
  expect_identical(m$sessions[[1]]$fetched_at, "2031-01-01T00:00:00Z")
  # unchanged payload, no incoming token: the existing one stays
  m <- bundle_merge(bundle_of(old), bundle_of(no_token))
  expect_identical(m$sessions[[1]]$token, "sw2-OLD00001")

  changed <- no_token; changed$match$data$recording_duration <- 99   # same stamp: a tie
  m <- bundle_merge(bundle_of(old), bundle_of(changed))
  expect_identical(attr(m, "merge_report")$action, "replaced")
  expect_identical(m$sessions[[1]]$token, "sw2-OLD00001")
  expect_identical(m$sessions[[1]]$match$data$recording_duration, 99)
  changed$token <- "sw2-NEW00002"
  m <- bundle_merge(bundle_of(old), bundle_of(changed))
  expect_identical(m$sessions[[1]]$token, "sw2-NEW00002")
})

# ---- size limits ---------------------------------------------------------------

test_that("the default size cap is one documented, overridable number", {
  expect_identical(bundle_max_bytes(), 50 * 1024^2)
  withr::local_options(rallyr.bundle_max_bytes = 1234)
  expect_identical(bundle_max_bytes(), 1234)
  withr::local_options(rallyr.bundle_max_bytes = "lots")
  expect_error(bundle_max_bytes(), "rallyr.bundle_max_bytes")
})

test_that("a file over the cap is refused with a friendly message", {
  path <- withr::local_tempfile(fileext = ".json.gz")
  bundle_write(sample_bundle(), path)
  expect_error(bundle_read(path, max_bytes = 100), "too large")
  expect_s3_class(bundle_read(path, max_bytes = 10 * 1024^2), "rallyr_bundle")
  withr::local_options(rallyr.bundle_max_bytes = 100)
  expect_error(bundle_read(path), "too large")
  expect_error(bundle_payload_kind(path), "too large")
})

test_that("a small file that expands past the cap is refused while reading it", {
  bomb <- withr::local_tempfile(fileext = ".json.gz")
  con <- gzfile(bomb, "wb")
  writeLines(strrep("a", 200000L), con)
  close(con)
  expect_lt(file.size(bomb), 1000)
  expect_error(bundle_read(bomb, max_bytes = 5000), "uncompressed|decompress|expands")
  # under the cap the same file is read, and then rejected for being no bundle
  expect_error(bundle_read(bomb, max_bytes = 10 * 1024^2), "not valid JSON")
})

test_that("a cap that is not a positive number is an error", {
  path <- withr::local_tempfile(fileext = ".json.gz")
  bundle_write(bundle_new(), path)
  expect_error(bundle_read(path, max_bytes = -1), "max_bytes")
  expect_error(bundle_read(path, max_bytes = NA_real_), "max_bytes")
})
