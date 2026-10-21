#' Checklist: is a candidate signal independent of what it predicts?
#'
#' Read this before adopting any new derived signal for a rally boundary, a
#' drill boundary or a fault call.
#'
#' A candidate field can look excellent on paper (much higher precision and
#' recall than any alternative) because it is a near-restatement of the thing
#' being predicted under another name. The cautionary case: while looking for
#' an independent signal for where a rally really starts, one field matched
#' with very high accuracy, but almost every positive value coincided exactly
#' with the start of the vendor's own point-grouping field, the same grouping
#' the detector was meant to corroborate or replace. Its accuracy was not
#' independent evidence; it re-exposed the vendor's own boundary logic, and
#' adopting it would add nothing that reusing the vendor's field directly would
#' not already give.
#'
#' A second case: a side-of-court field that looks like an independent
#' cross-check of a net call agreed with the wrong call on exactly the shots
#' that needed correcting, because it shares the tracking error behind the net
#' flag (see the "Known unreliability" section of [sv_shot_in()]).
#'
#' **Before trusting a strong correlation, check each of these:**
#'
#' 1. **Derivation.** How was the candidate field produced? Is it computed
#'    from, or by the same detector as, the target?
#' 2. **Coincidence.** Do its positive values line up one-to-one with the
#'    target's boundaries (or errors)? A near-perfect overlap is a warning, not
#'    a result.
#' 3. **Shared cause.** If the target is wrong, would the candidate be wrong
#'    in the same places? Test on cases where the target is known to be wrong
#'    (for example video-checked mistakes), not only on cases where it is
#'    right.
#' 4. **Added information.** Does the candidate separate cases the target
#'    does not already separate? If a plain reuse of the target would score
#'    the same, the candidate adds nothing.
#' 5. **Ground truth.** Is there any label that does not come from the
#'    vendor's pipeline, even a small hand-checked sample per drill type?
#'
#' A candidate that fails 1 or 3 is not independent evidence, however high its
#' score. Say so in the documentation of whatever uses it.
#'
#' @name signal_independence_checklist
#' @aliases signal_independence_checklist
#' @examples
#' # Documentation only: see ?signal_independence_checklist
NULL
