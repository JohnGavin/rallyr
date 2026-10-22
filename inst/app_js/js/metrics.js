// Per-session tables: same-day sessions merged, the standard metrics on one
// scale, and the stroke-quality composite. Mirrors merge_same_day_sessions()
// (R/db.R), R/standard_metrics.R, R/scoring.R and R/stroke_quality.R.

import {
  isNA, present, rmean, rmedian, rsd, rsum, rround, rankAverage, orderBy, dayNumber,
} from "./util.js";
import { dqCleanShotSpeed, dqCleanNetClearance, dqParams } from "./dq.js";

export const SESSION_COLUMNS = [
  "session_date", "played_at", "start_times", "n_parts", "opponent", "location", "duration_min",
  "me_shots", "me_shots_in", "me_run_mi", "opp_shots", "opp_run_mi", "fh_speed_mph",
  "bh_speed_mph", "fh_shots", "bh_shots", "shots_in_pct",
];

// R's sum(): missing as soon as one value is
const sumAll = (xs) => (xs.some(isNA) ? NaN : rsum(xs));

// mirrors weighted.mean(x, w, na.rm = TRUE): entries with a missing x are
// dropped first; zero weights contribute nothing
function weightedMean(x, w) {
  const keep = x.map((v, i) => i).filter((i) => !isNA(x[i]));
  const xs = keep.map((i) => x[i]);
  const ws = keep.map((i) => w[i]);
  if (ws.some(isNA)) return NaN;
  const terms = xs.map((v, i) => v * ws[i]).filter((_, i) => ws[i] !== 0);
  return rsum(terms) / rsum(ws);
}

// mirrors merge_same_day_sessions(): one row per day, sorted by time
export function mergeSameDaySessions(matches) {
  const days = new Map();
  for (const m of matches) {
    const k = m.session_date ?? "\u0000NA";
    if (!days.has(k)) days.set(k, []);
    days.get(k).push(m);
  }
  const keys = [...days.keys()].sort((a, b) => (a === "\u0000NA" ? 1 : b === "\u0000NA" ? -1 : a < b ? -1 : a > b ? 1 : 0));
  const rows = keys.map((k) => {
    const g = days.get(k);
    const col = (c) => g.map((m) => m[c]);
    const meShots = sumAll(col("me_shots"));
    const meIn = sumAll(col("me_shots_in"));
    return {
      session_date: g[0].session_date,
      played_at: Math.min(...col("played_at")),
      start_times: col("start_time").slice().sort().join(", "),
      n_parts: g.length,
      opponent: g[0].opponent,
      location: g[0].location,
      duration_min: sumAll(col("duration_min")),
      me_shots: meShots,
      me_shots_in: meIn,
      me_run_mi: sumAll(col("me_run_mi")),
      opp_shots: sumAll(col("opp_shots")),
      opp_run_mi: sumAll(col("opp_run_mi")),
      fh_speed_mph: rround(weightedMean(col("fh_speed_mph"), col("fh_shots")), 1),
      bh_speed_mph: rround(weightedMean(col("bh_speed_mph"), col("bh_shots")), 1),
      fh_shots: sumAll(col("fh_shots")),
      bh_shots: sumAll(col("bh_shots")),
      shots_in_pct: rround((100 * meIn) / meShots, 1),
    };
  });
  return orderBy(rows, (r) => r.played_at);
}

// mirrors pct_rank(): percentile of each value among the others, 0-100
export function pctRank(x) {
  const out = x.map(() => NaN);
  const idx = x.map((v, i) => i).filter((i) => !isNA(x[i]));
  const n = idx.length;
  if (n === 0) return out;
  const vals = idx.map((i) => x[i]);
  if (n === 1 || rsd(vals) === 0) {
    for (const i of idx) out[i] = 50;
    return out;
  }
  const r = rankAverage(vals);
  idx.forEach((i, j) => { out[i] = (100 * (r[j] - 1)) / (n - 1); });
  return out;
}

export const SESSION_METRIC_COLUMNS = ["session_date", "metric", "label", "unit", "value", "direction", "pct"];

// mirrors session_standard_metrics(): every metric as a rate or percentage,
// with its percentile among the sessions. Needs two or more sessions, oldest first.
export function sessionStandardMetrics(m) {
  if (m.length < 2) throw new Error("need at least 2 sessions to place a value within a distribution");
  for (let i = 1; i < m.length; i += 1) {
    if (m[i].session_date < m[i - 1].session_date) throw new Error("m must be pre-sorted chronologically (oldest first)");
  }
  const defs = [
    { metric: "accuracy", label: "Stroke accuracy", unit: "%", direction: 1, value: m.map((r) => r.shots_in_pct) },
    { metric: "stroke_rate", label: "Stroke rate", unit: "strokes/min", direction: 1, value: m.map((r) => r.me_shots / r.duration_min) },
    { metric: "speed", label: "Stroke speed", unit: "mph", direction: 1, value: m.map((r) => (r.fh_speed_mph + r.bh_speed_mph) / 2) },
    { metric: "run_rate", label: "Court coverage", unit: "mi/min", direction: 1, value: m.map((r) => r.me_run_mi / r.duration_min) },
    { metric: "shot_share", label: "Share of strokes", unit: "%", direction: 1, value: m.map((r) => (100 * r.me_shots) / (r.me_shots + r.opp_shots)) },
    // no defensible direction: forehand-heavy is a property of the drill
    { metric: "fh_share", label: "Forehand share", unit: "%", direction: NaN, value: m.map((r) => (100 * r.fh_shots) / (r.fh_shots + r.bh_shots)) },
  ];
  const out = [];
  for (const d of defs) {
    const pct = pctRank(d.value);
    m.forEach((r, i) => {
      out.push({
        session_date: r.session_date, metric: d.metric, label: d.label, unit: d.unit,
        value: d.value[i], direction: d.direction, pct: pct[i],
      });
    });
  }
  return out;
}

// ---- zone score and stroke quality ------------------------------------------

const ZONE_LEVELS = ["out_of_play", "off_target_width", "tier_3", "tier_2", "tier_1"];

// mirrors cross_court_zone_score() followed by zone_score_numeric(): 0 (out of
// play) to 1 (deep, to the target width, forcing the wanted response); NaN when
// the stroke cannot be scored. Scalar form of the vectorised R function.
export function crossCourtZoneScore(s, next, opts = {}) {
  const feederRight = opts.feederRightHanded ?? true;
  const meRight = opts.meRightHanded ?? true;
  const meSide = opts.meSide ?? "guest";
  const feederSide = opts.feederSide ?? "host";
  const deepZones = opts.deepZones ?? ["no_mans_land"];

  const rg = s.regime;
  const scoreable = (rg === "forehand_cross_court" || rg === "backhand_cross_court") && s.player === meSide;
  if (!scoreable) return NaN;
  const fhDrill = rg === "forehand_cross_court";
  const fhWidth = meRight ? "deuce" : "ad";
  const bhWidth = meRight ? "ad" : "deuce";
  const targetWidth = fhDrill ? fhWidth : bhWidth;

  const bl = s.bounce_location_long;
  const bla = s.bounce_location_lat;
  const knownZone = !isNA(bl) && !isNA(bla);
  const outOfPlay = (!isNA(bl) && bl === "out") || (!isNA(bla) && (bla === "ad_out" || bla === "deuce_out"));
  if (outOfPlay) return levelValue("out_of_play");
  if (!knownZone) return NaN;
  const inTarget = bla === targetWidth;
  if (!inTarget) return levelValue("off_target_width");

  const deep = deepZones.includes(bl);
  const np = next ? next.player : null;
  const nhw = next ? next.hit_wing : null;
  const feederWing = isNA(nhw) ? null : nhw === (feederRight ? "right" : "left") ? "forehand" : "backhand";
  const responseKnown = !isNA(np) && np === feederSide && feederWing !== null;
  if (!responseKnown) return NaN;
  const wanted = fhDrill ? "forehand" : "backhand";
  const desired = feederWing === wanted;
  if (deep && desired) return levelValue("tier_1");
  if (deep !== desired) return levelValue("tier_2");
  return levelValue("tier_3");
}

const levelValue = (lv) => ZONE_LEVELS.indexOf(lv) / (ZONE_LEVELS.length - 1);

// mirrors quality_z(): z-score; missing when fewer than two values; 0 for all
function qualityZ(x) {
  const idx = x.map((v, i) => i).filter((i) => !isNA(x[i]));
  const out = x.map(() => NaN);
  if (idx.length < 2) return out;
  const vals = idx.map((i) => x[i]);
  const s = rsd(vals);
  const mu = rmean(vals);
  idx.forEach((i, j) => { out[i] = isNA(s) || s === 0 ? 0 : (vals[j] - mu) / s; });
  return out;
}

export const STROKE_QUALITY_COLUMNS = [
  "session_date", "n_strokes", "speed_mph", "zone_score", "clearance_m", "z_speed", "z_zone",
  "z_clearance", "quality",
];

// mirrors stroke_quality_session(): one composite per session from the
// player's cross-court strokes
export function strokeQualitySession(shotDetail, matches, params = dqParams(), opts = {}) {
  const weights = opts.weights ?? params.stroke_quality_weights;
  const regimes = opts.regimes ?? ["forehand_cross_court", "backhand_cross_court"];
  const meSide = opts.meSide ?? "guest";
  const comps = ["speed", "zone", "clearance"];
  const w = comps.map((c) => weights[c]);
  if (w.some((v) => typeof v !== "number" || Number.isNaN(v) || v < 0) || rsum(w) <= 0) {
    throw new Error("weights must give non-negative speed, zone and clearance weights, not all zero.");
  }

  // order by match, rally, time (rows with no rally last), then pair each
  // stroke with the next one of the same rally
  const sorted = orderBy(
    orderBy(orderBy(shotDetail, (r) => r.started_at), (r) => r.rally_id),
    (r) => r.match_id,
  );
  const next = sorted.map(() => null);
  for (let i = 0; i < sorted.length - 1; i += 1) {
    const a = sorted[i];
    const b = sorted[i + 1];
    if (!isNA(a.rally_id) && a.match_id === b.match_id && a.rally_id === b.rally_id) next[i] = b;
  }
  const zone = sorted.map((r, i) => crossCourtZoneScore(r, next[i], { meSide }));
  const rows = sorted.map((r, i) => ({ ...r, zone: zone[i] }));
  const cleaned = dqCleanNetClearance(dqCleanShotSpeed(rows, params), params)
    .filter((r) => r.player === meSide && regimes.includes(r.regime));

  const dateOf = new Map(matches.map((m) => [m.match_id, m.session_date]));
  const bySession = new Map();
  for (const r of cleaned) {
    if (!dateOf.has(r.match_id)) continue;
    const d = dateOf.get(r.match_id);
    if (!bySession.has(d)) bySession.set(d, []);
    bySession.get(d).push(r);
  }
  const sq = orderBy([...bySession.entries()].map(([d, g]) => ({
    session_date: d,
    n_strokes: g.length,
    speed_mph: g.some((r) => !isNA(r.shot_speed_mph)) ? rmedian(g.map((r) => r.shot_speed_mph)) : NaN,
    zone_score: present(g.map((r) => r.zone)).length > 0 ? rmean(present(g.map((r) => r.zone))) : NaN,
    clearance_m: g.some((r) => !isNA(r.net_clearance_m)) ? rmedian(g.map((r) => r.net_clearance_m)) : NaN,
  })), (r) => r.session_date);

  const zs = qualityZ(sq.map((r) => r.speed_mph));
  const zz = qualityZ(sq.map((r) => r.zone_score));
  const zc = qualityZ(sq.map((r) => r.clearance_m));
  return sq.map((r, i) => {
    const z = [zs[i], zz[i], zc[i]];
    let num = 0;
    let den = 0;
    z.forEach((v, j) => {
      if (!isNA(v)) { num += v * w[j]; den += w[j]; }
    });
    return { ...r, z_speed: zs[i], z_zone: zz[i], z_clearance: zc[i], quality: den > 0 ? num / den : NaN };
  });
}

// the day number of a session date, for charts
export const sessionDay = (iso) => dayNumber(iso);
