// The app's tables and derived data against the R package's, on the synthetic
// sample bundle, the same bundle with the extra session added, and the sample
// seen from the feeder's side. Run with `node --test tests/js`.

import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { readFixture, readSampleSessionFile, compareTable, fixtureDir } from "./helpers.mjs";
import { bundleJs, util, sample, compareResult, run, COLUMNS } from "./parity_lib.mjs";

test("the sample bundle: every table and derived table equals R's", () => {
  const want = readFixture("sample.json.gz");
  assert.equal(want.me, "Sample Player");
  assert.deepEqual(bundleJs.bundlePlayers(sample), want.players);
  assert.deepEqual(compareResult(run(sample, want.me), want), []);
});

test("the sample bundle has the sizes the comparison relies on (six sessions, thousands of strokes)", () => {
  const want = readFixture("sample.json.gz");
  assert.equal(want.derived.sessions.n, 6);
  assert.ok(want.tables.shot_detail.n > 2000);
  assert.ok(want.derived.corrected_rallies.n > 100);
  assert.ok(want.derived.session_metrics.n === 36);
});

test("the same player under another spelling of the name gives the same tables", () => {
  const want = readFixture("sample.json.gz");
  assert.deepEqual(compareResult(run(sample, "  sample PLAYER "), want), []);
});

test("the sample seen from the feeder's side: the sides swap and the tables equal R's", () => {
  const want = readFixture("sample_as_opponent.json.gz");
  assert.equal(want.me, "Sample Opponent");
  assert.deepEqual(compareResult(run(sample, want.me), want), []);
});

const extraPayloads = () => ["sample_session_match.json", "sample_session_stats.json", "sample_session_shots.json"]
  .map((f) => JSON.parse(readSampleSessionFile(f)));

test("the sample bundle with the extra session added: tables, derived tables and merge report equal R's", () => {
  const want = readFixture("sample_plus_session.json.gz");
  const { bundle, report } = bundleJs.bundleAddRaw(sample, extraPayloads(), { token: "synthetic-0007", fetchedAt: "2031-02-01T09:00:00Z" });
  assert.equal(bundle.sessions.length, 7);
  assert.deepEqual(compareResult(run(bundle, want.me), want), []);
  assert.deepEqual(compareTable("merge_report", util.toColumns(report, bundleJs.MERGE_REPORT_COLUMNS), want.merge_report), []);
  assert.deepEqual(bundleJs.bundlePlayers(bundle), want.players);
});

test("adding a session leaves the sessions already in the bundle as they were (and their tables are reused)", () => {
  const before = run(sample, "Sample Player");
  const { bundle } = bundleJs.bundleAddRaw(sample, extraPayloads());
  assert.ok(sample.sessions.every((s, i) => bundle.sessions[i] === s));
  const after = bundleJs.bundleToTables(bundle, "Sample Player");
  assert.equal(after.matches.length, before.tables.matches.length + 1);
  assert.equal(after.matches[0], before.tables.matches[0]);
});

test("a bundle that reaches the rules the sample does not: placeholder speeds, out-of-range net heights, too-fast rallies, two recordings in a day, the feeder's side, a left-handed player, a session with no shots, one that cannot be read", async () => {
  const want = readFixture("stress.json.gz");
  const bytes = new Uint8Array(fs.readFileSync(path.join(fixtureDir, "stress_bundle.json.gz")));
  const stress = await bundleJs.bundleRead(bytes, "stress_bundle.json.gz");
  assert.equal(stress.sessions.length, 7);
  const got = run(stress, want.me, "skip");
  // the reasons are worded differently in R and JavaScript; the sessions skipped, and that they could not be parsed, are compared
  const skippedWant = want.tables.skipped;
  assert.deepEqual(got.tables.skipped.map((s) => s.match_id), skippedWant.cols.match_id);
  assert.ok(got.tables.skipped.every((s, i) => s.reason.startsWith(skippedWant.cols.reason[i].split(":")[0])));
  want.tables.skipped = { ...util.toColumns(got.tables.skipped, COLUMNS.skipped), time: [] };
  assert.deepEqual(compareResult(got, want), []);
  // the paths the bundle was built to reach were taken
  const speeds = got.tables.shot_detail.filter((s) => s.shot_speed_mph === 117.1);
  assert.ok(speeds.length >= 15);
  assert.ok(got.derived.net_clearance.reduce((n, r) => n + r.n_implausible, 0) >= 10);
  assert.equal(Math.max(...got.derived.sessions.map((s) => s.n_parts)), 2);
  assert.ok(got.derived.corrected_rallies.length !== got.tables.rallies.length);
});

test("a session built to sit on the edge of every threshold (just under, on and just over each) equals R's", async () => {
  const want = readFixture("edge.json.gz");
  const bytes = new Uint8Array(fs.readFileSync(path.join(fixtureDir, "edge_bundle.json.gz")));
  const edge = await bundleJs.bundleRead(bytes, "edge_bundle.json.gz");
  const got = run(edge, want.me);
  assert.deepEqual(compareResult(got, want), []);
  // the edges were reached: every drill, a pause-split rally, a dropped rally, a placeholder speed, a net height out of range
  const regimes = new Set(got.tables.shot_segments.map((s) => s.regime));
  for (const r of ["net_volley", "mini_tennis", "forehand_cross_court", "backhand_cross_court", "mixed", "gap"]) assert.ok(regimes.has(r), r);
  assert.ok(got.derived.corrected_rallies.some((r) => /_[a-z]$/.test(r.rally_id)));
  assert.ok(got.derived.corrected_rallies.length < got.tables.rallies.length + got.derived.corrected_rallies.filter((r) => /_[a-z]$/.test(r.rally_id)).length);
  assert.equal(got.tables.shot_detail.filter((s) => s.shot_speed_mph === 117.1).length, 1);
  assert.equal(got.derived.net_clearance.reduce((n, r) => n + r.n_implausible, 0), 2);
});

test("a player who is in no session gives no tables and a reason per session", () => {
  const tables = bundleJs.bundleToTables(sample, "Nobody Here", { onError: "skip" });
  assert.equal(tables.matches.length, 0);
  assert.equal(tables.skipped.length, 6);
  assert.ok(tables.skipped.every((s) => s.reason === "player not in this session"));
  assert.throws(() => bundleJs.bundleDerived(tables), /no sessions to summarise/);
  assert.throws(() => bundleJs.bundleToTables(sample, "   "), /must be a player name/);
});
