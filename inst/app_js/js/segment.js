// Splitting a session into drill segments, and the per-match tables built on
// them. Mirrors R/segment_shots.R and bundle_derive_match() in R/bundle.R.

import { isNA, present, rmean, rmedian, rround } from "./util.js";
import { dqParams } from "./dq.js";

export const SEGMENT_COLUMNS = [
  "segment_index", "regime", "start_time", "end_time", "duration_min", "n_shots",
  "n_host_shots", "n_guest_shots", "regime_occurrence", "n_guest_gs_left", "n_guest_gs_right",
  "guest_speed_mean_mph", "guest_speed_median_mph", "guest_in_pct", "match_id",
];

export const RALLY_COLUMNS = [
  "rally_id", "start_time", "end_time", "duration_sec", "n_shots", "segment_index", "regime",
  "regime_occurrence", "match_id",
];

// the shot table of a match: sv_parse_shots() columns without ended_at, plus the
// segment each shot falls in
export const SHOT_DETAIL_COLUMNS = [
  "match_id", "shot_id", "rally_id", "player", "started_at", "hit_wing", "hit_type", "spin_type",
  "shot_speed_mph", "shot_in", "hit_frame", "video_elapsed_sec", "hit_court_side",
  "bounce_court_side", "net_clearance_m", "bounce_location_long", "bounce_location_lat",
  "hit_x", "hit_y", "hit_z", "bounce_x", "bounce_y", "bounce_z",
  "hit_velocity_x", "hit_velocity_y", "hit_velocity_z",
  "segment_index", "regime", "regime_occurrence",
];

const sumWhere = (rows, f) => rows.reduce((n, r) => n + (f(r) ? 1 : 0), 0);

// mirrors segment_session_shots(): one row per detected drill segment.
// `shots` are the rows of svParseShots() of ONE match.
export function segmentSessionShots(shots, guestRightHanded = true, opts = {}) {
  const binMinutes = opts.binMinutes ?? 1;
  const minShotsPerBin = opts.minShotsPerBin ?? 4;
  const volleyShare = opts.volleyShareThreshold ?? 0.4;
  const miniSpeed = opts.miniTennisSpeedMph ?? 35;
  const wingDominance = opts.wingDominanceThreshold ?? 0.7;
  const minSegmentMin = opts.minSegmentDurationMin ?? dqParams().min_segment_duration_min;
  if (typeof minSegmentMin !== "number" || Number.isNaN(minSegmentMin) || minSegmentMin < 0) {
    throw new Error("min_segment_duration_min must be a single non-negative number.");
  }
  if (shots.some((s) => isNA(s.started_at) || isNA(s.ended_at))) {
    // R carries the missing time on into the bins and fails there; a session
    // whose shots lack a time cannot be segmented, so it is reported as such.
    throw new Error("a shot has no start or end time");
  }

  const first = Math.min(...shots.map((s) => s.started_at));
  const byBin = new Map();
  for (const s of shots) {
    const bin = Math.floor((s.started_at - first) / 60 / binMinutes);
    if (!byBin.has(bin)) byBin.set(bin, []);
    byBin.get(bin).push(s);
  }
  const fhLabel = guestRightHanded ? "forehand_cross_court" : "backhand_cross_court";
  const bhLabel = guestRightHanded ? "backhand_cross_court" : "forehand_cross_court";

  const bins = [...byBin.keys()].sort((a, b) => a - b).map((bin) => {
    const g = byBin.get(bin);
    const nHost = sumWhere(g, (s) => s.player === "host");
    const nGuest = sumWhere(g, (s) => s.player === "guest");
    const guestGs = g.filter((s) => s.player === "guest" && s.hit_type === "ground_stroke");
    const hostVolleyFrac = nHost > 0 ? sumWhere(g, (s) => s.player === "host" && s.hit_type === "volley") / nHost : NaN;
    const gsSpeed = guestGs.length > 0 ? rmean(present(guestGs.map((s) => s.shot_speed_mph))) : NaN;
    const rightFrac = guestGs.length > 0 ? sumWhere(guestGs, (s) => s.hit_wing === "right") / guestGs.length : NaN;
    let regime = "mixed";
    if (g.length < minShotsPerBin) regime = "gap";
    else if (!isNA(hostVolleyFrac) && hostVolleyFrac >= volleyShare) regime = "net_volley";
    else if (!isNA(gsSpeed) && gsSpeed < miniSpeed) regime = "mini_tennis";
    else if (!isNA(rightFrac) && rightFrac >= wingDominance) regime = fhLabel;
    else if (!isNA(rightFrac) && rightFrac <= 1 - wingDominance) regime = bhLabel;
    return {
      regime,
      start_time: Math.min(...g.map((s) => s.started_at)),
      end_time: Math.max(...g.map((s) => s.ended_at)),
      n_shots: g.length, n_host: nHost, n_guest: nGuest,
    };
  });

  // contiguous bins of one regime make one segment
  let segs = [];
  for (const b of bins) {
    const last = segs[segs.length - 1];
    if (last && last.regime === b.regime) {
      last.start_time = Math.min(last.start_time, b.start_time);
      last.end_time = Math.max(last.end_time, b.end_time);
      last.n_shots += b.n_shots;
      last.n_host_shots += b.n_host;
      last.n_guest_shots += b.n_guest;
    } else {
      segs.push({
        regime: b.regime, start_time: b.start_time, end_time: b.end_time,
        n_shots: b.n_shots, n_host_shots: b.n_host, n_guest_shots: b.n_guest,
      });
    }
  }
  const minutes = (s) => rround((s.end_time - s.start_time) / 60, 1);
  for (const s of segs) s.duration_min = minutes(s);

  // An implausibly short segment is a mis-segmentation artefact: relabel it
  // "gap"; adjacent gap segments are then merged and the index renumbered.
  for (const s of segs) if (s.regime !== "gap" && s.duration_min < minSegmentMin) s.regime = "gap";
  const merged = [];
  for (const s of segs) {
    const last = merged[merged.length - 1];
    if (last && last.regime === "gap" && s.regime === "gap") {
      last.start_time = Math.min(last.start_time, s.start_time);
      last.end_time = Math.max(last.end_time, s.end_time);
      last.n_shots += s.n_shots;
      last.n_host_shots += s.n_host_shots;
      last.n_guest_shots += s.n_guest_shots;
    } else {
      merged.push({ ...s });
    }
  }
  segs = merged.sort((a, b) => a.start_time - b.start_time);
  return segs.map((s, i) => ({
    segment_index: i + 1, regime: s.regime, start_time: s.start_time, end_time: s.end_time,
    duration_min: minutes(s), n_shots: s.n_shots, n_host_shots: s.n_host_shots,
    n_guest_shots: s.n_guest_shots,
  }));
}

// mirrors findInterval(x, vec): how many elements of the sorted `vec` are <= x
function findInterval(x, vec) {
  let lo = 0;
  let hi = vec.length;
  while (lo < hi) {
    const mid = (lo + hi) >> 1;
    if (vec[mid] <= x) lo = mid + 1;
    else hi = mid;
  }
  return lo;
}

// mirrors bundle_derive_match(): segments, per-shot rows and rallies of one
// match whose "guest" side is the player being analysed.
export function bundleDeriveMatch(shots, guestRightHanded = true) {
  const segs = segmentSessionShots(shots, guestRightHanded);
  // the n-th segment of its regime (in segment order)
  const seen = new Map();
  for (const s of segs) {
    seen.set(s.regime, (seen.get(s.regime) ?? 0) + 1);
    s.regime_occurrence = seen.get(s.regime);
  }
  const starts = segs.map((s) => s.start_time);
  const detail = shots.map((sh) => {
    const idx = Math.max(findInterval(sh.started_at, starts), 1);
    const row = {};
    for (const c of SHOT_DETAIL_COLUMNS) row[c] = sh[c];
    row.segment_index = idx;
    row.regime = segs[idx - 1].regime;
    row.regime_occurrence = segs[idx - 1].regime_occurrence;
    return row;
  });

  const matchId = shots[0].match_id;
  const bySeg = new Map(segs.map((s) => [s.segment_index, []]));
  for (const r of detail) bySeg.get(r.segment_index).push(r);
  for (const s of segs) {
    const rows = bySeg.get(s.segment_index);
    const gs = rows.filter((r) => r.player === "guest" && r.hit_type === "ground_stroke" && (r.hit_wing === "left" || r.hit_wing === "right"));
    s.n_guest_gs_left = sumWhere(gs, (r) => r.hit_wing === "left");
    s.n_guest_gs_right = sumWhere(gs, (r) => r.hit_wing === "right");
    const guest = rows.filter((r) => r.player === "guest");
    if (guest.length > 0) {
      const speeds = present(guest.map((r) => r.shot_speed_mph));
      s.guest_speed_mean_mph = rround(rmean(speeds), 1);
      s.guest_speed_median_mph = rround(rmedian(speeds), 1);
      s.guest_in_pct = rround(100 * rmean(guest.map((r) => (r.shot_in ? 1 : 0))), 1);
    } else {
      s.guest_speed_mean_mph = NaN;
      s.guest_speed_median_mph = NaN;
      s.guest_in_pct = NaN;
    }
    s.match_id = matchId;
  }

  // rallies: the shots that carry a rally id, one row per id
  const byRally = new Map();
  for (const sh of shots) {
    if (isNA(sh.rally_id)) continue;
    if (!byRally.has(sh.rally_id)) byRally.set(sh.rally_id, []);
    byRally.get(sh.rally_id).push(sh);
  }
  // the segment most of a rally's shots fall in (the first, on a tie)
  const detailByShot = new Map(shots.map((sh, i) => [sh, detail[i]]));
  const rallies = [...byRally.keys()].sort((a, b) => a - b).map((rid) => {
    const g = byRally.get(rid);
    const start = Math.min(...g.map((s) => s.started_at));
    const end = Math.max(...g.map((s) => s.ended_at));
    const counts = new Map();
    for (const sh of g) {
      const k = detailByShot.get(sh).segment_index;
      counts.set(k, (counts.get(k) ?? 0) + 1);
    }
    let best = null;
    for (const k of [...counts.keys()].sort((a, b) => a - b)) {
      if (best === null || counts.get(k) > counts.get(best)) best = k;
    }
    const seg = segs[best - 1];
    return {
      rally_id: rid, start_time: start, end_time: end,
      duration_sec: Math.max(0, rround(end - start, 1)), n_shots: g.length,
      segment_index: best, regime: seg.regime, regime_occurrence: seg.regime_occurrence,
      match_id: matchId,
    };
  });
  return { segs, shots: detail, rallies };
}
