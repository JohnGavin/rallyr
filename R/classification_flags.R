#' Flag out calls that play contradicts
#'
#' The in/out classification `shot_in` ([sv_shot_in()]) is unreliable for net
#' contacts (see the "Known unreliability" section there). This function adds
#' a SEPARATE flag, `net_call_contradicted`, and leaves `shot_in` exactly as
#' parsed: a stroke is flagged when it was called out (`shot_in` is `FALSE`)
#' and the very next stroke of the same rally was hit by the OTHER side. A
#' ball that really ended the point is not returned, so play continuing is
#' evidence the out call was wrong.
#'
#' What the flag is not:
#'
#' * It is a one-way check. `TRUE` means the call is probably wrong; `FALSE`
#'   does NOT confirm the call, because a genuinely wrong call can end a rally
#'   anyway (for example the last stroke before a pause).
#' * It flags any out call, whether the call came from a net contact or a
#'   bounce position, because the persisted shot table keeps the combined
#'   result, not the raw net field. Read it as "this out call is contradicted",
#'   not "this net call is".
#' * Whether the next stroke belongs to the same live rally is taken from the
#'   vendor's own grouping (`rally_id`), which has its own errors (see
#'   [rally_pid_mismatch()]); `max_gap_sec` drops continuations after a long
#'   pause.
#' * A stroke with an `NA` call is not flagged: unknown is not a
#'   contradiction.
#'
#' @param shots A tibble with `rally_id`, `player`, `started_at` and `shot_in`
#'   (`match_id` is used when present, since `rally_id` is only unique within
#'   a match).
#' @param max_gap_sec A next stroke later than this many seconds after the
#'   called stroke does not count as continued play. Default `Inf` (any next
#'   stroke in the rally counts).
#' @return `shots`, in its original row order, with a logical column
#'   `net_call_contradicted` (never `NA`).
#' @export
flag_net_call_contradicted <- function(shots, max_gap_sec = Inf) {
  need <- c("rally_id", "player", "started_at", "shot_in")
  if (!all(need %in% names(shots))) {
    cli::cli_abort(c(
      "x" = "{.arg shots} needs {.val {need}}.",
      "i" = "Missing: {.val {setdiff(need, names(shots))}}."
    ))
  }
  n <- nrow(shots)
  grp <- if ("match_id" %in% names(shots)) {
    paste(shots$match_id, shots$rally_id, sep = "\r")
  } else {
    as.character(shots$rally_id)
  }
  ord <- order(grp, as.numeric(shots$started_at))
  g <- grp[ord]
  nxt <- c(ord[-1L], NA_integer_)
  same_rally <- c(g[-1L] == g[-n], FALSE)
  if (n == 0L) {
    same_rally <- logical(0)
  }
  out <- rep(FALSE, n)
  cur <- ord
  other_side <- same_rally & !is.na(nxt) &
    shots$player[cur] != shots$player[ifelse(is.na(nxt), cur, nxt)]
  gap <- as.numeric(shots$started_at[ifelse(is.na(nxt), cur, nxt)]) - as.numeric(shots$started_at[cur])
  called_out <- shots$shot_in[cur] %in% FALSE
  out[cur] <- (other_side & called_out & gap <= max_gap_sec) %in% TRUE
  shots$net_call_contradicted <- out
  shots
}

#' Flag stroke-type labels that are probably wrong at the net
#'
#' In a drill where one player volleys at the net and the other plays from
#' the baseline, true volleys by the baseline player are rare (at most one or
#' two per drill in the observed play), so most `hit_type == "volley"` labels
#' on that side are the vendor classifier's mistakes. This function adds a
#' logical flag, `hit_type_suspect`, for exactly those strokes: the
#' baseline player's (`me_side`) volleys inside a net-volley drill. It does
#' NOT relabel anything: `hit_type` is left as parsed, because there is no
#' independent ground truth here to re-derive a corrected label from.
#'
#' @section Role purity is an undercount:
#' Any per-role composition metric (for example "share of the net player's
#' strokes that are volleys") should be read as a plausible LOWER bound, not
#' a precise measurement. The vendor classifier confuses adjacent stroke
#' types in both directions: a real share of the net player's volleys are
#' labelled as a stroke type used to open a rally, and a real share of the
#' baseline player's strokes are labelled as volleys. Both confusions push the
#' measured purity of each role below what direct observation suggests. Report
#' such a metric together with this caveat, and with the count of
#' `hit_type_suspect` strokes where it is shown.
#'
#' @param shots A tibble with `player`, `hit_type` and `regime` (a drill
#'   label per stroke, e.g. joined from [segment_session_drills()]).
#' @param me_side Which `player` value is the baseline player (`"guest"`).
#' @param net_regimes Character vector of regime values that are net-volley
#'   drills (`"net_volley"`).
#' @return `shots` with a logical column `hit_type_suspect` (never `NA`).
#' @export
flag_hit_type_suspect <- function(shots, me_side = "guest", net_regimes = "net_volley") {
  need <- c("player", "hit_type", "regime")
  if (!all(need %in% names(shots))) {
    cli::cli_abort(c(
      "x" = "{.arg shots} needs {.val {need}}.",
      "i" = "Missing: {.val {setdiff(need, names(shots))}}."
    ))
  }
  shots$hit_type_suspect <-
    (shots$player %in% me_side) & (shots$hit_type %in% "volley") & (shots$regime %in% net_regimes)
  shots
}
