#' Save the raw share-API payloads of one session to disk
#'
#' Fetches the three payloads of a shared session (`/matches/{token}`,
#' `/stats` and `/shots`) and writes each, unparsed, to a JSON file. Use it to
#' keep the raw data, or to feed [bundle_add_raw()] and the browser app. This
#' is the R equivalent of the three links the app shows you to open and save by
#' hand: R is not limited by the browser's cross-origin rule, a web page is.
#'
#' The files are named `<token>_match.json`, `<token>_stats.json` and
#' `<token>_shots.json`. The share API is undocumented and unofficial (see
#' [sv_api_base()]), so it can change without notice.
#'
#' @param url_or_token A share URL or bare token (see [sv_token()]).
#' @param dir Directory to write into; created if it does not exist.
#' @return A named character vector of the three file paths (`match`, `stats`,
#'   `shots`), invisibly.
#' @export
#' @examples
#' \dontrun{
#' files <- sv_download_raw("https://swing.vision/matches/sw2-EXAMPLE01", tempdir())
#' bundle <- bundle_add_raw(bundle_new(), files[["match"]], files[["stats"]], files[["shots"]])
#' bundle_write(bundle, "my_sessions.json.gz")
#' }
sv_download_raw <- function(url_or_token, dir) {
  if (!is.character(url_or_token) || length(url_or_token) != 1L || is.na(url_or_token) ||
        !nzchar(trimws(url_or_token))) {
    cli::cli_abort("{.arg url_or_token} must be a share URL or token.")
  }
  if (!is.character(dir) || length(dir) != 1L || is.na(dir) || !nzchar(dir)) {
    cli::cli_abort("{.arg dir} must be a directory path.")
  }
  token <- sv_token(url_or_token)
  if (!grepl("^[A-Za-z0-9._~-]+$", token) || token %in% c(".", "..")) {
    cli::cli_abort(c(
      "x" = "The token has characters a share token does not use.",
      "i" = "Pass the URL or token exactly as shared."
    ))
  }
  base <- sv_api_base()
  urls <- c(
    match = sprintf("%s/matches/%s", base, token),
    stats = sprintf("%s/matches/%s/stats", base, token),
    shots = sprintf("%s/matches/%s/shots", base, token)
  )
  # All three are fetched and checked before anything is written. Messages
  # name the payload (match, stats, shots), never the token or the URL.
  bodies <- lapply(names(urls), function(k) {
    body <- tryCatch(
      sv_get_raw(urls[[k]]),
      error = function(e) {
        detail <- sv_redact(conditionMessage(e), c(urls[[k]], token, base))
        cli::cli_abort(c("x" = "Could not fetch the {k} payload.", "i" = "{detail}"), call = NULL)
      }
    )
    if (!is.character(body) || length(body) != 1L || !isTRUE(jsonlite::validate(body))) {
      cli::cli_abort(c(
        "x" = "The {k} response is not JSON, so nothing was saved.",
        "i" = "The link may have expired, or the share may be private."
      ), call = NULL)
    }
    body
  })
  names(bodies) <- names(urls)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  paths <- file.path(dir, sprintf("%s_%s.json", token, names(urls)))
  names(paths) <- names(urls)
  for (k in names(urls)) {
    writeLines(bodies[[k]], paths[[k]], useBytes = TRUE)
  }
  invisible(paths)
}

# `text` with every string in `secrets` (and any URL) replaced by "<redacted>".
sv_redact <- function(text, secrets) {
  text <- paste(text, collapse = " ")
  for (z in secrets[nzchar(secrets)]) text <- gsub(z, "<redacted>", text, fixed = TRUE)
  gsub("https?://[^[:space:]\"')>]+", "<redacted>", text)
}

# The body of a GET, as text, with no parsing.
sv_get_raw <- function(url) {
  resp <- httr2::request(url) |>
    httr2::req_user_agent("rallyr (https://github.com/JohnGavin/rallyr)") |>
    httr2::req_timeout(30) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform()
  httr2::resp_body_string(resp)
}
