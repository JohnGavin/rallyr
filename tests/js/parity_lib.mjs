// What the parity tests share: the app's modules, the sample bundle, and the
// comparison of a whole result (tables and derived tables) with R's.

import { load, sampleBundleBytes, compareTable } from "./helpers.mjs";

export const bundleJs = await load("bundle.js");
export const util = await load("util.js");
export const segment = await load("segment.js");
export const sv = await load("sv.js");
export const dq = await load("dq.js");
export const metrics = await load("metrics.js");

export const COLUMNS = {
  matches: sv.MATCH_COLUMNS,
  shot_segments: segment.SEGMENT_COLUMNS,
  shot_detail: segment.SHOT_DETAIL_COLUMNS,
  rallies: segment.RALLY_COLUMNS,
  skipped: ["match_id", "reason"],
  sessions: metrics.SESSION_COLUMNS,
  corrected_rallies: dq.CORRECTED_RALLY_COLUMNS,
  session_metrics: metrics.SESSION_METRIC_COLUMNS,
  net_clearance: dq.NET_CLEARANCE_COLUMNS,
  stroke_quality: metrics.STROKE_QUALITY_COLUMNS,
};

export const sample = await bundleJs.bundleRead(sampleBundleBytes(), "the sample bundle");

// every table of a result against the fixture; returns the messages (none
// when the app equals R)
export function compareResult(got, want) {
  const out = [];
  for (const name of ["matches", "shot_segments", "shot_detail", "rallies", "skipped"]) {
    out.push(...compareTable(`tables.${name}`, util.toColumns(got.tables[name], COLUMNS[name]), want.tables[name]));
  }
  for (const name of ["sessions", "corrected_rallies", "session_metrics", "net_clearance", "stroke_quality"]) {
    const rows = got.derived[name];
    if (want.derived[name] === null) {
      if (rows !== null) out.push(`derived.${name}: should be NULL`);
    } else if (rows === null) {
      out.push(`derived.${name}: is NULL, R has ${want.derived[name].n} rows`);
    } else {
      out.push(...compareTable(`derived.${name}`, util.toColumns(rows, COLUMNS[name]), want.derived[name]));
    }
  }
  return out;
}

export function run(bundle, me, onError = "abort") {
  const tables = bundleJs.bundleToTables(bundle, me, { onError });
  return { tables, derived: bundleJs.bundleDerived(tables) };
}
