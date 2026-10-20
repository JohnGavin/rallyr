#!/usr/bin/env Rscript

# Static privacy check of a built site or app folder.
#
#   Rscript tools/check_site_privacy.R <dir> [--csp-dir=<subdir>] [--allow-origin=<origin>]...
#
# Fails (exit 1) when the code WE ship could make a request to a site other
# than its own, or when the app's pages lack the Content-Security-Policy:
#
#  * `external-resource`: a script, stylesheet, image, frame, media, form or
#    refresh in a page points at another origin;
#  * `network-call`: code calls fetch(), XMLHttpRequest, sendBeacon, WebSocket,
#    EventSource, importScripts or dynamic import(), or (R code) download.file(),
#    url("http..."), curl::, httr::, httr2::, webr::install()/mount(), or reads
#    a table or file straight from a URL;
#  * `unlisted-origin`: code or data names an origin that is not on the
#    navigation allow-list (a link a person may click, never a request);
#  * `csp-missing` / `csp-connect-src`: a page under --csp-dir has no policy, or
#    its connect-src allows more than 'self', blob: and data:.
#
# What this does NOT show: that the vendored runtime (Shinylive, WebAssembly R,
# pkgdown's own assets: the folders in `skip_dirs` and the files in
# `skip_files`; pkgdown.js, for one, fetches the site's own search index, and
# Shinylive's service worker names its default package repositories)
# makes no request to another origin, and a
# <meta> policy does not bind workers. That is what the browser check
# (tools/check_app_requests.mjs) observes. This script covers the code we write.
#
# Exit codes: 0 clean, 1 violations, 2 usage, 3 indeterminate (nothing was
# scanned, or the built-in positive control did not fire).

js_patterns <- c(
  fetch = "\\bfetch\\s*\\(",
  xhr = "XMLHttpRequest",
  beacon = "sendBeacon",
  websocket = "new\\s+WebSocket\\s*\\(",
  eventsource = "new\\s+EventSource\\s*\\(",
  importscripts = "importScripts\\s*\\(",
  dynamic_import = "\\bimport\\s*\\("
)
r_patterns <- c(
  download_file = "download\\.file\\s*\\(",
  url_connection = "\\burl\\s*\\(\\s*[\"']https?:",
  curl = "\\bcurl::",
  httr = "\\bhttr2?::",
  webr_net = "webr::(install|mount)",
  read_from_url = "(readLines|read\\.csv|read_csv|fromJSON|readRDS|scan)\\s*\\(\\s*[\"']https?://"
)
fetching_rel <- "stylesheet|preload|prefetch|preconnect|dns-prefetch|icon|modulepreload|manifest"

line_of <- function(text, pos) {
  1L + lengths(regmatches(substr(text, 1L, pos - 1L), gregexpr("\n", substr(text, 1L, pos - 1L), fixed = TRUE)))
}

violation <- function(file, line, rule, text) {
  data.frame(file = file, line = line, rule = rule, text = substr(trimws(text), 1L, 160), stringsAsFactors = FALSE)
}

origin_of <- function(u) tolower(regmatches(u, regexpr("^(https?:)?//[^/?#\"' ]+", u)))
is_external <- function(u) grepl("^(https?:)?//", trimws(u))

# Pattern hits, as violations.
scan_patterns <- function(text, patterns, file) {
  out <- list()
  for (nm in names(patterns)) {
    m <- gregexpr(patterns[[nm]], text, perl = TRUE)[[1]]
    if (m[1] == -1L) next
    for (pos in m) {
      out[[length(out) + 1L]] <- violation(file, line_of(text, pos), "network-call", substr(text, pos, pos + 60L))
    }
  }
  if (length(out) == 0L) NULL else do.call(rbind, out)
}

scan_origins <- function(text, allowed, file) {
  m <- gregexpr("https?://[A-Za-z0-9._-]+(:[0-9]+)?", text, perl = TRUE)[[1]]
  if (m[1] == -1L) return(NULL)
  out <- list()
  for (i in seq_along(m)) {
    found <- tolower(substr(text, m[i], m[i] + attr(m, "match.length")[i] - 1L))
    if (!found %in% allowed) {
      out[[length(out) + 1L]] <- violation(file, line_of(text, m[i]), "unlisted-origin", found)
    }
  }
  if (length(out) == 0L) NULL else do.call(rbind, out)
}

csp_of <- function(html) {
  m <- regmatches(html, regexpr("<meta[^>]*http-equiv=[\"']Content-Security-Policy[\"'][^>]*>", html, ignore.case = TRUE))
  if (length(m) == 0L) return(NA_character_)
  g <- regmatches(m, regexec("content=([\"'])(.*?)\\1", m, perl = TRUE))[[1]]
  if (length(g) < 3L) NA_character_ else g[3]
}

scan_html <- function(html, allowed_resources, file, require_csp) {
  out <- list()
  add <- function(v) if (!is.null(v)) out[[length(out) + 1L]] <<- v
  tags <- gregexpr("<(script|link|img|iframe|source|video|audio|embed|object|track|form|meta)\\b[^>]*>", html, perl = TRUE, ignore.case = TRUE)[[1]]
  if (tags[1] != -1L) {
    for (i in seq_along(tags)) {
      tag <- substr(html, tags[i], tags[i] + attr(tags, "match.length")[i] - 1L)
      name <- tolower(sub("^<([a-zA-Z]+).*", "\\1", tag))
      attrs <- switch(name,
        link = if (grepl(paste0("rel=[\"'][^\"']*(", fetching_rel, ")"), tag, ignore.case = TRUE)) "href" else character(0),
        form = "action",
        meta = if (grepl("http-equiv=[\"']refresh", tag, ignore.case = TRUE)) "content" else character(0),
        object = "data",
        video = c("src", "poster"),
        c("src", "srcset")
      )
      for (a in attrs) {
        m <- regmatches(tag, regexpr(paste0("\\b", a, "=([\"'])(.*?)\\1"), tag, perl = TRUE, ignore.case = TRUE))
        if (length(m) == 0L) next
        value <- sub(paste0("^[A-Za-z]+=[\"'](.*)[\"']$"), "\\1", m)
        urls <- if (a == "content") regmatches(value, regexpr("https?://.*$", value)) else value
        for (u in urls) {
          if (is_external(u) && !origin_of(u) %in% allowed_resources) {
            add(violation(file, line_of(html, tags[i]), "external-resource", paste0("<", name, " ", a, "=", u)))
          }
        }
      }
    }
  }
  # inline scripts: the code on the page itself
  scripts <- gregexpr("(?s)<script\\b[^>]*>(.*?)</script>", html, perl = TRUE, ignore.case = TRUE)[[1]]
  if (scripts[1] != -1L) {
    for (i in seq_along(scripts)) {
      s <- substr(html, scripts[i], scripts[i] + attr(scripts, "match.length")[i] - 1L)
      if (grepl("^<script[^>]*\\bsrc=", s, ignore.case = TRUE)) next
      v <- scan_patterns(s, js_patterns, file)
      if (!is.null(v)) {
        v$line <- v$line + line_of(html, scripts[i]) - 1L
        add(v)
      }
    }
  }
  if (isTRUE(require_csp)) {
    csp <- csp_of(html)
    if (is.na(csp)) {
      add(violation(file, 1L, "csp-missing", "no Content-Security-Policy meta tag"))
    } else {
      directives <- trimws(strsplit(csp, ";", fixed = TRUE)[[1]])
      directive <- function(name) {
        d <- directives[startsWith(directives, paste0(name, " "))]
        if (length(d) == 0L) return(NULL)
        strsplit(trimws(sub(paste0("^", name), "", d[1])), "\\s+")[[1]]
      }
      connect <- directive("connect-src")
      if (is.null(connect) || !all(connect %in% c("'self'", "blob:", "data:"))) {
        add(violation(file, 1L, "csp-connect-src", paste("connect-src:", paste(connect, collapse = " "))))
      }
      default <- directive("default-src")
      if (is.null(default) || !identical(default, "'self'")) {
        add(violation(file, 1L, "csp-connect-src", paste("default-src:", paste(default, collapse = " "))))
      }
    }
  }
  if (length(out) == 0L) NULL else do.call(rbind, out)
}

# Returns a data frame of violations (zero rows if clean); attribute `n_files`
# is the number of files scanned.
check_site_privacy <- function(dir, allowed_navigation = character(0), allowed_resources = character(0),
                               csp_dir = NULL,
                               skip_dirs = c("shinylive", "deps", "node_modules", ".git"),
                               skip_files = c("search.json", "sitemap.xml", "pkgdown.yml", "pkgdown.js", "lightswitch.js", "katex-auto.js", "shinylive-sw.js")) {
  files <- list.files(dir, recursive = TRUE, full.names = TRUE, all.files = TRUE)
  rel <- substring(files, nchar(dir) + 2L)
  parts <- strsplit(rel, "/", fixed = TRUE)
  skip <- vapply(parts, function(p) any(p[-length(p)] %in% skip_dirs), logical(1)) | basename(files) %in% skip_files
  files <- files[!skip]
  rel <- rel[!skip]
  keep <- grepl("\\.(html?|js|mjs|css|R|json)$", files, ignore.case = TRUE)
  files <- files[keep]
  rel <- rel[keep]
  allowed <- tolower(c(allowed_navigation, allowed_resources))
  out <- list()
  for (i in seq_along(files)) {
    text <- paste(readLines(files[i], warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    ext <- tolower(tools::file_ext(files[i]))
    if (ext %in% c("html", "htm")) {
      require_csp <- !is.null(csp_dir) && startsWith(rel[i], paste0(csp_dir, "/"))
      v <- scan_html(text, tolower(allowed_resources), rel[i], require_csp)
    } else {
      body <- if (ext == "r") paste(grep("^\\s*#", strsplit(text, "\n", fixed = TRUE)[[1]], value = TRUE, invert = TRUE), collapse = "\n") else text
      v <- rbind(
        scan_patterns(body, js_patterns, rel[i]),
        scan_patterns(body, r_patterns, rel[i]),
        scan_origins(body, allowed, rel[i])
      )
    }
    if (!is.null(v) && nrow(v) > 0L) out[[length(out) + 1L]] <- v
  }
  res <- if (length(out) == 0L) violation(character(0), integer(0), character(0), character(0)) else do.call(rbind, out)
  rownames(res) <- NULL
  attr(res, "n_files") <- length(files)
  res
}

# A positive control: files that each break one rule must be caught, and
# clean files must pass. Returns the names of the rules that did NOT fire (or
# fired on clean input); character(0) means the checker works.
check_site_privacy_selftest <- function() {
  d <- tempfile("privacy_selftest")
  dir.create(file.path(d, "app"), recursive = TRUE)
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  writeLines(c(
    "<html><head>",
    "<script src=\"https://evil.example/x.js\"></script>",
    "<link rel=\"stylesheet\" href=\"//evil.example/s.css\">",
    "<img src=\"https://evil.example/p.png\">",
    "<script>fetch('/ok')</script>",
    "</head></html>"
  ), file.path(d, "page.html"))
  writeLines("var x = new XMLHttpRequest(); var u = 'https://evil.example/y';", file.path(d, "bad.js"))
  writeLines("download.file(\"https://evil.example/z\", \"f\")", file.path(d, "bad.R"))
  writeLines("<html><head></head></html>", file.path(d, "app", "index.html"))
  writeLines(
    "<html><head><meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self'; connect-src 'self' https://evil.example\"></head></html>",
    file.path(d, "app", "loose.html")
  )
  bad <- check_site_privacy(d, allowed_navigation = "https://ok.example", csp_dir = "app")
  expected <- c(
    "external-resource" = "page.html", "network-call" = "bad.js", "unlisted-origin" = "bad.js",
    "network-call" = "bad.R", "csp-missing" = "app/index.html", "csp-connect-src" = "app/loose.html"
  )
  failed <- character(0)
  for (i in seq_along(expected)) {
    if (!any(bad$rule == names(expected)[i] & bad$file == expected[[i]])) {
      failed <- c(failed, paste(names(expected)[i], "in", expected[[i]], "not detected"))
    }
  }
  if (!any(bad$rule == "network-call" & bad$file == "page.html")) failed <- c(failed, "inline fetch() in page.html not detected")

  clean <- tempfile("privacy_selftest_clean")
  dir.create(file.path(clean, "app"), recursive = TRUE)
  on.exit(unlink(clean, recursive = TRUE), add = TRUE)
  writeLines("<html><head><script src=\"app.js\"></script><a href=\"https://elsewhere.example\">x</a></head></html>", file.path(clean, "ok.html"))
  writeLines("var x = 1; // a link: https://ok.example/page", file.path(clean, "ok.js"))
  writeLines(
    "<html><head><meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self'; connect-src 'self' blob: data:\"></head></html>",
    file.path(clean, "app", "index.html")
  )
  ok <- check_site_privacy(clean, allowed_navigation = "https://ok.example", csp_dir = "app")
  if (nrow(ok) > 0L) failed <- c(failed, paste("clean input was flagged:", paste(ok$rule, ok$file, collapse = "; ")))
  failed
}

main <- function(args) {
  dir <- args[!startsWith(args, "--")]
  if (length(dir) != 1L || !dir.exists(dir)) {
    message("Usage: check_site_privacy.R <dir> [--csp-dir=<subdir>] [--allow-origin=<origin>]...")
    return(2L)
  }
  failed <- check_site_privacy_selftest()
  if (length(failed) > 0L) {
    message("INDETERMINATE: the checker's own positive control failed:\n  ", paste(failed, collapse = "\n  "))
    return(3L)
  }
  self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  root <- normalizePath(file.path(dirname(self), ".."))
  # One home for the API address: the package's own definition.
  source(file.path(root, "tools", "app_sources.R"), local = TRUE)
  defs <- app_collect_definitions(file.path(root, "R"))
  api_fn <- eval(parse(text = defs$sv_api_base$text))
  api_origin <- origin_of(api_fn())
  # The site's own address (its pages and redirects may name themselves).
  site_url <- sub("^url:\\s*(\\S+).*$", "\\1", grep("^url:", readLines(file.path(root, "_pkgdown.yml")), value = TRUE)[1])
  site_origin <- origin_of(site_url)
  extra <- sub("^--allow-origin=", "", grep("^--allow-origin=", args, value = TRUE))
  csp_dir <- sub("^--csp-dir=", "", grep("^--csp-dir=", args, value = TRUE))
  res <- check_site_privacy(
    normalizePath(dir),
    allowed_navigation = c(api_origin, "https://github.com", site_origin, extra),
    allowed_resources = site_origin,
    csp_dir = if (length(csp_dir) == 1L) csp_dir else NULL
  )
  n <- attr(res, "n_files")
  if (n == 0L) {
    message("INDETERMINATE: no files to scan under ", dir)
    return(3L)
  }
  if (nrow(res) > 0L) {
    message(sprintf("FAIL: %d violation(s) in %d file(s) scanned:", nrow(res), n))
    for (i in seq_len(nrow(res))) {
      message(sprintf("  %s:%d  [%s]  %s", res$file[i], res$line[i], res$rule[i], res$text[i]))
    }
    return(1L)
  }
  message(sprintf("PASS: %d file(s) scanned; no external request, no unlisted origin%s.", n,
                  if (length(csp_dir) == 1L) ", policy present" else ""))
  0L
}

if (sys.nframe() == 0L) quit(status = main(commandArgs(trailingOnly = TRUE)))
