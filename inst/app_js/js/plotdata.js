// What each chart shows, as data. Mirrors R/plots.R: the same rows go into each
// chart, filtered and summarised the same way, so the browser charts and the
// ggplot charts of the R package show the same numbers. charts.js draws them.
//
// Each function returns { title, empty: "message" } when there is nothing to
// show (R: plot_empty()), else { title, ...data }.

import { isNA, rmedian, quantile7, dayNumber } from "./util.js";
import { dqCleanShotSpeed, dqParams, dqStrokeGaps } from "./dq.js";

// mirrors regime_label(): "forehand_cross_court" -> "forehand cross court"
export const regimeLabel = (x) => x.replaceAll("_", " ");

// The drills in the order ggplot's reorder() puts them: by their median,
// smallest first (the first drill is drawn at the bottom); equal medians keep
// alphabetical order.
function drillsByMedian(values) {
  const labels = [...new Set(values.map((v) => v.drill))].sort();
  return labels
    .map((drill) => ({ drill, med: rmedian(values.filter((v) => v.drill === drill).map((v) => v.x)) }))
    .sort((a, b) => a.med - b.med)
    .map((d) => d.drill);
}

// mirrors plot_session_trend(): accuracy, stroke rate and speed per session.
// `dateRange` is two "YYYY-MM-DD" dates (or null for all sessions).
export function trendData(derived, { dateRange = null, metrics = ["accuracy", "stroke_rate", "speed"] } = {}) {
  const title = "Session trends";
  let sm = derived.session_metrics;
  if (sm === null || sm === undefined) return { title, empty: "A trend needs at least two sessions." };
  sm = sm.filter((r) => metrics.includes(r.metric));
  if (dateRange !== null) {
    if (dateRange.length !== 2 || dateRange.some(isNA)) throw new Error("date_range must be two dates.");
    sm = sm.filter((r) => r.session_date >= dateRange[0] && r.session_date <= dateRange[1]);
  }
  sm = sm.filter((r) => !isNA(r.value));
  if (sm.length === 0) return { title, empty: "No sessions in this date range." };
  const panels = [];
  for (const r of sm) {
    const name = `${r.label} (${r.unit})`;
    let p = panels.find((q) => q.name === name);
    if (!p) { p = { name, points: [] }; panels.push(p); }
    p.points.push({ date: r.session_date, day: dayNumber(r.session_date), value: r.value });
  }
  return { title, panels };
}

// mirrors plot_rally_length(): shots per rally, by drill
export function rallyLengthData(derived) {
  const title = "Rally length by drill";
  const r = derived.corrected_rallies;
  if (r === null || r === undefined) return { title, empty: "No rallies in the data." };
  const kept = r.filter((x) => !isNA(x.regime) && x.regime !== "gap");
  if (kept.length === 0) return { title, empty: "No rallies fall in a recognised drill." };
  const pts = kept.map((x) => ({ drill: regimeLabel(x.regime), x: x.n_shots }));
  const drills = drillsByMedian(pts).map((drill) => {
    const xs = pts.filter((p) => p.drill === drill).map((p) => p.x);
    return { drill, values: xs, median: rmedian(xs) };
  });
  return {
    title, drills, xLabel: "Shots per rally (both players; diamond = median)",
    caption: "Rallies after the data-quality corrections.",
  };
}

// mirrors the box of ggplot2::geom_boxplot(): quartiles, whiskers at the last
// value within 1.5 x the inter-quartile range, the rest are outliers.
export function boxStats(values) {
  const v = [...values].sort((a, b) => a - b);
  const q = [0, 0.25, 0.5, 0.75, 1].map((p) => quantile7(v, p));
  const iqr = q[3] - q[1];
  const isOut = (x) => x < q[1] - 1.5 * iqr || x > q[3] + 1.5 * iqr;
  const outliers = v.filter(isOut);
  let [lo, hi] = [q[0], q[4]];
  if (outliers.length > 0) {
    const inside = v.filter((x) => !isOut(x));
    const range = [...[q[1], q[2], q[3]], ...inside];
    lo = Math.min(...range);
    hi = Math.max(...range);
  }
  return { n: v.length, ymin: lo, lower: q[1], middle: q[2], upper: q[3], ymax: hi, outliers };
}

// mirrors plot_stroke_speed(): the player's stroke speed by drill, placeholder
// speeds removed
export function strokeSpeedData(derived) {
  const title = "Stroke speed by drill";
  const d = dqCleanShotSpeed(derived.tables.shot_detail, dqParams())
    .filter((r) => r.player === "guest" && !isNA(r.shot_speed_mph) && !isNA(r.regime) && r.regime !== "gap");
  if (d.length === 0) return { title, empty: "No stroke speeds in the data." };
  const pts = d.map((r) => ({ drill: regimeLabel(r.regime), x: r.shot_speed_mph }));
  const drills = drillsByMedian(pts).map((drill) => ({
    drill, ...boxStats(pts.filter((p) => p.drill === drill).map((p) => p.x)),
  }));
  return {
    title, drills, xLabel: "Stroke speed (mph)", caption: "Your strokes only; placeholder speeds removed.",
  };
}

// mirrors plot_net_clearance(): median clearance per session and drill, the
// player ("You") and the feeder
export function netClearanceData(derived) {
  const title = "Net clearance by drill";
  const nc = (derived.net_clearance ?? []).filter((r) => !isNA(r.regime) && r.regime !== "gap");
  const none = { title, empty: "No net-clearance values in the data." };
  if (nc.length === 0) return none;
  const long = [
    ...nc.map((r) => ({ drill: regimeLabel(r.regime), side: "You", x: r.me_median_m })),
    ...nc.map((r) => ({ drill: regimeLabel(r.regime), side: "Feeder", x: r.opp_median_m })),
  ].filter((r) => !isNA(r.x));
  if (long.length === 0) return none;
  // a discrete axis lists its values alphabetically
  const drills = [...new Set(long.map((r) => r.drill))].sort();
  return {
    title, drills, points: long, xLabel: "Median net clearance (m), one point per session",
    caption: "The vendor does not say whether the height is above the ground or the net tape.",
  };
}

// the histogram bins of ggplot2's stat_bin(binwidth, boundary = 0): bins are
// closed on the right (the first one on both sides) with a tiny fuzz so a value
// on an edge falls in the lower bin. Returns [{ xmin, xmax, count }].
export function histogramBins(values, binwidth = 0.25, boundary = 0) {
  const lo = Math.min(...values);
  const hi = Math.max(...values);
  const shift = Math.floor((lo - boundary) / binwidth);
  const origin = boundary + shift * binwidth;
  const maxX = hi + (1 - 1e-8) * binwidth;
  let n = Math.floor((maxX - origin) / binwidth + 1e-10);
  let breaks = Array.from({ length: n + 1 }, (_, i) => origin + i * binwidth);
  if (breaks.length === 1) breaks = [breaks[0], breaks[0] + binwidth];
  const fuzz = 1e-8 * binwidth;
  const fuzzy = breaks.map((b, i) => b + (i === 0 ? -fuzz : fuzz));
  const counts = new Array(breaks.length - 1).fill(0);
  for (const x of values) {
    let k = 0;
    while (k < counts.length - 1 && x > fuzzy[k + 1]) k += 1;
    counts[k] += 1;
  }
  return counts.map((count, k) => ({ xmin: breaks[k], xmax: breaks[k + 1], count }));
}

// mirrors plot_gap_distribution(): the pauses between strokes of a rally, with
// the pauses that split a rally marked
export function gapDistributionData(derived) {
  const title = "Pauses between strokes";
  const gaps = dqStrokeGaps(derived.tables.shot_detail);
  if (gaps.length === 0) return { title, empty: "No within-rally pauses in the data." };
  const p = dqParams();
  const byValue = new Map();
  for (const regime of p.pause_split_regimes) {
    const x = p.max_stroke_gap_sec[regime];
    if (x === undefined) continue;
    if (!byValue.has(x)) byValue.set(x, []);
    byValue.get(x).push(regime);
  }
  const marks = [...byValue.keys()].sort((a, b) => a - b).map((x) => ({
    x,
    label: [...new Set(byValue.get(x).map((n) => regimeLabel(n.replace(/^(forehand|backhand)_/, ""))))].join(", "),
  }));
  const shown = gaps.map((g) => g.gap_sec).filter((g) => g <= 10);
  const beyond = gaps.filter((g) => g.gap_sec > 10).length;
  const bins = shown.length > 0 ? histogramBins(shown) : [];
  const note = beyond > 0 ? ` ${beyond} pause${beyond === 1 ? "" : "s"} over 10 s not shown.` : "";
  return {
    title, bins, marks, nBeyond: beyond, xLabel: "Seconds between consecutive strokes of a rally",
    yLabel: "Pauses", caption: `Dashed lines: the pause that splits a rally.${note}`,
  };
}
