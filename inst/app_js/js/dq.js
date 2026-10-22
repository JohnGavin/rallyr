// Data-quality rules: thresholds, placeholder speeds, rally splitting, the
// corrected rallies and net clearance. Mirrors R/data_quality_params.R,
// R/rally_split.R and R/net_clearance.R.

import { isNA, present, rmean, rmedian, numToString } from "./util.js";

// mirrors dq_params(): the single source of the thresholds
export function dqParams() {
  return {
    max_mean_stroke_speed_kmh: 100,
    max_individual_stroke_speed_kmh: 160,
    min_segment_duration_min: 3,
    min_drill_gap_sec: 60,
    min_drill_segment_shots: 10,
    sentinel_shot_speeds_mph: [117.1],
    max_rally_strokes: {
      default: 25, mini_tennis: 50, forehand_cross_court: 20, backhand_cross_court: 20,
    },
    max_stroke_gap_sec: { forehand_cross_court: 3, backhand_cross_court: 3, net_volley: 2 },
    pause_split_regimes: ["forehand_cross_court", "backhand_cross_court", "net_volley"],
    split_requires_starter_next: true,
    min_net_clearance_m: -1,
    max_net_clearance_m: 5,
    stroke_quality_weights: { speed: 1, zone: 1, clearance: 0 },
  };
}

const has = (obj, key) => Object.prototype.hasOwnProperty.call(obj, key);

// mirrors dq_clean_shot_speed() / dq_null_sentinel(): a placeholder speed
// becomes missing, the stroke stays. Returns new rows with `shot_speed_sentinel`.
export function dqCleanShotSpeed(rows, params = dqParams(), tol = 0.05) {
  return rows.map((r) => {
    const x = r.shot_speed_mph;
    const hit = !isNA(x) && params.sentinel_shot_speeds_mph.some((v) => Math.abs(x - v) <= tol);
    return { ...r, shot_speed_mph: hit ? NaN : x, shot_speed_sentinel: hit };
  });
}

// mirrors rally_stroke_threshold(): the stroke limit of a drill
export function rallyStrokeThreshold(regime, params = dqParams()) {
  const limits = params.max_rally_strokes;
  return !isNA(regime) && has(limits, regime) ? limits[regime] : limits.default;
}

// mirrors rally_split_gap_sec(): the pause that splits a rally of this drill;
// NaN for a drill that is not pause-split
export function rallySplitGapSec(regime, params = dqParams()) {
  if (isNA(regime) || !params.pause_split_regimes.includes(regime)) return NaN;
  return has(params.max_stroke_gap_sec, regime) ? params.max_stroke_gap_sec[regime] : NaN;
}

// mirrors find_rally_splits(): the 1-based indices i where a split falls
// between stroke i and stroke i + 1.
export function findRallySplits(startedAt, maxGapSec, isStarter = null) {
  const n = startedAt.length;
  if (n < 2) return [];
  if (isStarter !== null && isStarter.length !== n) {
    throw new Error("is_starter must be the same length as started_at.");
  }
  const out = [];
  for (let i = 0; i < n - 1; i += 1) {
    const gap = startedAt[i + 1] - startedAt[i];
    let boundary = gap > maxGapSec;
    if (isStarter !== null) boundary = boundary && isStarter[i + 1] === true;
    if (boundary) out.push(i + 1);
  }
  return out;
}

// mirrors rally_pause_splits()
export function rallyPauseSplits(shots, regime, params = dqParams(), rallyStarter = "host") {
  if (shots.length < 2 || !params.pause_split_regimes.includes(regime)) return [];
  const isStarter = params.split_requires_starter_next ? shots.map((s) => s.player === rallyStarter) : null;
  return findRallySplits(shots.map((s) => s.started_at), rallySplitGapSec(regime, params), isStarter);
}

// mirrors rally_piece_suffix(): a..z, then z27, z28, ...
export const rallyPieceSuffix = (k) => (k <= 26 ? String.fromCharCode(96 + k) : `z${k}`);

const KMH = 1.609344;

// A rally's mean and fastest stroke speed in km/h, from speeds in mph.
function speedsKmh(speeds) {
  const v = present(speeds);
  return { speed: rmean(v) * KMH, max: v.length === 0 ? NaN : Math.max(...v) * KMH };
}

// mirrors dq_corrected_rallies(): the rallies a chart may use. Sentinel speeds
// are nulled; each rally is flagged (too many strokes, mean speed, one stroke
// too fast); speed-only flags are dropped; the pause rule splits the rest;
// anything still over its limit is left out.
export function dqCorrectedRallies(rallies, shotDetail, params = dqParams(), meSide = "guest", rallyStarter = "host") {
  const shots = dqCleanShotSpeed(shotDetail, params);
  const mine = shots.filter((s) => s.player === meSide && !isNA(s.rally_id));

  // me_shots and speeds per (match, rally), as rally_player_strokes() and the
  // per-rally summary do
  const perRally = new Map();
  for (const s of mine) {
    const k = `${s.match_id}|${numToString(s.rally_id)}`;
    if (!perRally.has(k)) perRally.set(k, []);
    perRally.get(k).push(s.shot_speed_mph);
  }

  // dq_flag_rallies() uses the default thresholds (it takes no params argument)
  const p = dqParams();
  const flagged = rallies.map((r) => {
    const speeds = perRally.get(`${r.match_id}|${numToString(r.rally_id)}`);
    const meShots = speeds ? speeds.length : 0;
    const sp = speeds ? speedsKmh(speeds) : { speed: NaN, max: NaN };
    const maxStrokes = rallyStrokeThreshold(r.regime, p);
    let flag = null;
    if (meShots > maxStrokes) flag = `rally > ${Math.trunc(maxStrokes)} strokes (drill limit)`;
    else if (!isNA(sp.speed) && sp.speed > p.max_mean_stroke_speed_kmh) flag = `mean stroke speed > ${p.max_mean_stroke_speed_kmh} km/h`;
    else if (!isNA(sp.max) && sp.max > p.max_individual_stroke_speed_kmh) flag = `individual stroke speed > ${Math.trunc(p.max_individual_stroke_speed_kmh)} km/h`;
    return { ...r, me_shots: meShots, speed_kmh: sp.speed, flag_reason: flag };
  });

  // a speed-only flag is a tracking problem, not a grouping one: dropped.
  // Everything else (unflagged, or flagged for strokes) gets the pause rule.
  const candidates = flagged.filter((r) => r.flag_reason === null || r.flag_reason.includes("strokes"));

  const byRally = new Map();
  for (const s of shots) {
    const k = `${s.match_id}|${numToString(s.rally_id)}`;
    if (!byRally.has(k)) byRally.set(k, []);
    byRally.get(k).push(s);
  }

  const unsplit = [];
  const splitRows = [];
  for (const r of candidates) {
    const group = byRally.get(`${r.match_id}|${numToString(r.rally_id)}`) ?? [];
    const ordered = group
      .map((s, i) => [s, i])
      .sort((a, b) => (isNA(a[0].started_at) ? 1 : 0) - (isNA(b[0].started_at) ? 1 : 0) || a[0].started_at - b[0].started_at || a[1] - b[1])
      .map((x) => x[0]);
    const splits = rallyPauseSplits(ordered, r.regime, params, rallyStarter);
    if (splits.length === 0) {
      if (r.flag_reason === null) {
        unsplit.push({
          match_id: r.match_id, rally_id: numToString(r.rally_id), regime: r.regime,
          regime_occurrence: r.regime_occurrence, segment_index: r.segment_index,
          n_shots: r.n_shots, me_shots: r.me_shots, duration_sec: r.duration_sec,
          start_time: r.start_time, end_time: r.end_time, speed_kmh: r.speed_kmh,
        });
      }
      continue;
    }
    const bounds = [0, ...splits, ordered.length];
    const maxStrokes = rallyStrokeThreshold(r.regime, params);
    for (let k = 0; k < bounds.length - 1; k += 1) {
      const sub = ordered.slice(bounds[k], bounds[k + 1]);
      const subMe = sub.filter((s) => s.player === meSide);
      const times = sub.map((s) => s.started_at);
      const lo = Math.min(...times);
      const hi = Math.max(...times);
      const sp = subMe.length > 0 ? speedsKmh(subMe.map((s) => s.shot_speed_mph)) : { speed: NaN, max: NaN };
      // a piece still over its own limit, or with an implausible speed, is left out
      const okMean = isNA(sp.speed) || sp.speed <= params.max_mean_stroke_speed_kmh;
      const okMax = isNA(sp.max) || sp.max <= params.max_individual_stroke_speed_kmh;
      if (subMe.length <= maxStrokes && okMean && okMax) {
        splitRows.push({
          match_id: r.match_id, rally_id: `${numToString(r.rally_id)}_${rallyPieceSuffix(k + 1)}`,
          regime: r.regime, regime_occurrence: r.regime_occurrence, segment_index: r.segment_index,
          n_shots: sub.length, me_shots: subMe.length, duration_sec: hi - lo,
          start_time: lo, end_time: hi, speed_kmh: sp.speed,
        });
      }
    }
  }
  return [...unsplit, ...splitRows];
}

export const CORRECTED_RALLY_COLUMNS = [
  "match_id", "rally_id", "regime", "regime_occurrence", "segment_index", "n_shots", "me_shots",
  "duration_sec", "start_time", "end_time", "speed_kmh",
];

// mirrors dq_stroke_gaps(): the pause between consecutive strokes of each rally
export function dqStrokeGaps(shotDetail) {
  const rows = shotDetail.filter((s) => !isNA(s.rally_id));
  const groups = new Map();
  for (const s of rows) {
    const k = `${s.match_id}|${s.rally_id}`;
    if (!groups.has(k)) groups.set(k, { match_id: s.match_id, rally_id: s.rally_id, shots: [] });
    groups.get(k).shots.push(s);
  }
  const out = [];
  const ordered = [...groups.values()].sort((a, b) => a.match_id - b.match_id || a.rally_id - b.rally_id);
  for (const g of ordered) {
    const t = g.shots.map((s) => s.started_at).sort((a, b) => a - b);
    for (let i = 1; i < t.length; i += 1) {
      const gap = t[i] - t[i - 1];
      if (!isNA(gap)) out.push({ match_id: g.match_id, rally_id: g.rally_id, gap_sec: gap });
    }
  }
  return out;
}

// mirrors dq_clean_net_clearance(): an implausible height becomes missing
export function dqCleanNetClearance(rows, params = dqParams()) {
  return rows.map((r) => {
    const x = r.net_clearance_m;
    const bad = !isNA(x) && (!Number.isFinite(x) || x < params.min_net_clearance_m || x > params.max_net_clearance_m);
    return { ...r, net_clearance_m: bad ? NaN : x, net_clearance_implausible: bad };
  });
}

export const NET_CLEARANCE_COLUMNS = [
  "match_id", "regime", "me_median_m", "me_n", "opp_median_m", "opp_n", "diff_m", "n_implausible",
];

// mirrors session_net_clearance_by_drill(): median clearance per match and
// drill, the player against the feeder
export function sessionNetClearanceByDrill(shotDetail, params = dqParams(), meSide = "guest", feederSide = "host") {
  const d = dqCleanNetClearance(
    shotDetail.map((r) => ({ match_id: r.match_id, regime: r.regime, player: r.player, net_clearance_m: r.net_clearance_m })),
    params,
  ).filter((r) => !isNA(r.regime));
  const keys = new Map();
  for (const r of d) {
    const k = `${r.match_id}|${r.regime}`;
    if (!keys.has(k)) keys.set(k, { match_id: r.match_id, regime: r.regime, n_implausible: 0, me: [], opp: [] });
    const g = keys.get(k);
    if (r.net_clearance_implausible) g.n_implausible += 1;
    if (!isNA(r.net_clearance_m)) {
      if (r.player === meSide) g.me.push(r.net_clearance_m);
      else if (r.player === feederSide) g.opp.push(r.net_clearance_m);
    }
  }
  const out = [...keys.values()].map((g) => {
    const me = g.me.length > 0 ? rmedian(g.me) : NaN;
    const opp = g.opp.length > 0 ? rmedian(g.opp) : NaN;
    return {
      match_id: g.match_id, regime: g.regime, me_median_m: me, me_n: g.me.length,
      opp_median_m: opp, opp_n: g.opp.length, diff_m: me - opp, n_implausible: g.n_implausible,
    };
  });
  // arrange(match_id, regime): numbers ascending, text in code-point order
  return out.sort((a, b) => a.match_id - b.match_id || (a.regime < b.regime ? -1 : a.regime > b.regime ? 1 : 0));
}
