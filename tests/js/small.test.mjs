// The small functions against R: share-link tokens, payload kinds, fetch times,
// the rules a bundle file must meet, and the four outcomes of a merge. The
// expected values are what the R package returned (data-raw/js_parity_fixtures.R).

import test from "node:test";
import assert from "node:assert/strict";
import { readFixture, readSampleSessionFile, differs } from "./helpers.mjs";
import { bundleJs, sv, util, sample } from "./parity_lib.mjs";

const cases = readFixture("small_cases.json.gz");

test("sv_api_base is the address R uses", () => {
  assert.equal(sv.svApiBase(), cases.api_base);
});

test("share links give the same token as sv_token()", () => {
  assert.ok(cases.token_cases.length >= 10);
  for (const c of cases.token_cases) assert.equal(sv.svToken(c.input), c.token, JSON.stringify(c.input));
});

test("each payload is recognised as R recognises it (match, stats, shots or none)", () => {
  assert.ok(cases.kind_cases.length >= 20);
  const seen = new Set();
  for (const c of cases.kind_cases) {
    const kind = bundleJs.bundleKindParsed(JSON.parse(c.text));
    assert.equal(kind, c.kind === null || c.kind === undefined ? null : c.kind, c.name);
    seen.add(String(kind));
  }
  assert.deepEqual([...seen].sort(), ["match", "null", "shots", "stats"]);
});

test("a fetch time is read to the same instant as bundle_stamp_seconds()", () => {
  for (const c of cases.stamp_cases) {
    const got = bundleJs.bundleStampSeconds(c.input);
    // an instant, so compared to a hundred-thousandth of a second, not relatively
    assert.equal(differs(got, c.seconds, { time: true }), null, `${JSON.stringify(c.input)}: ${got} vs ${c.seconds}`);
  }
});

test("a bundle file reads or is refused as R reads or refuses it", async () => {
  for (const c of cases.validation_cases) {
    let ok = true;
    try {
      await bundleJs.bundleRead(new TextEncoder().encode(c.text), `${c.name}.json`);
    } catch {
      ok = false;
    }
    assert.equal(ok, c.ok, c.name);
  }
});

const payloadsOf = (s) => [s.match, s.stats, s.shots];
const altered = (s) => {
  const copy = JSON.parse(JSON.stringify(s));
  copy.stats.data.guest[0].average_right_wing_velocity += 1;
  return copy;
};
const caseInputs = {
  unchanged: () => [payloadsOf(sample.sessions[0]), null, "2031-02-01T09:00:00Z"],
  unchanged_new_token: () => [payloadsOf(sample.sessions[0]), "synthetic-new", "2031-02-01T09:00:00Z"],
  replaced_newer: () => [payloadsOf(altered(sample.sessions[0])), null, "2031-03-01T00:00:00Z"],
  replaced_tie: () => [payloadsOf(altered(sample.sessions[0])), "synthetic-new", "2030-01-01T00:00:00Z"],
  kept_older: () => [payloadsOf(altered(sample.sessions[0])), null, "2029-01-01T00:00:00Z"],
  replaced_offset: () => [payloadsOf(altered(sample.sessions[0])), null, "2030-01-01T02:00:00+02:00"],
};

test("merging a session: added, unchanged, replaced, kept and a tie give R's report, tokens and fetch times", () => {
  assert.deepEqual(cases.merge_cases.map((c) => c.name).sort(), Object.keys(caseInputs).sort());
  const actions = new Set();
  for (const c of cases.merge_cases) {
    const [payloads, token, fetchedAt] = caseInputs[c.name]();
    const { bundle, report } = bundleJs.bundleAddRaw(sample, payloads, { token, fetchedAt });
    assert.deepEqual(report.map((r) => r.action), c.report.cols.action, c.name);
    assert.deepEqual(report.map((r) => r.match_id), c.report.cols.match_id, c.name);
    assert.deepEqual(report.map((r) => r.existing_fetched_at), c.report.cols.existing_fetched_at, c.name);
    assert.deepEqual(report.map((r) => r.incoming_fetched_at), c.report.cols.incoming_fetched_at, c.name);
    assert.equal(bundle.sessions.length, c.n_sessions, c.name);
    assert.deepEqual(bundle.sessions.map((s) => s.match_id), c.match_ids, c.name);
    assert.deepEqual(bundle.sessions.map((s) => s.token ?? null), c.tokens, c.name);
    assert.deepEqual(bundle.sessions.map((s) => s.fetched_at ?? null), c.fetched_at, c.name);
    const speeds = bundleJs.bundleToTables(bundle, "Sample Player").matches.map((m) => m.fh_speed_mph);
    assert.deepEqual(speeds.map((v, i) => differs(v, c.fh_speed_mph[i])), speeds.map(() => null), c.name);
    actions.add(report[0].action);
  }
  assert.deepEqual([...actions].sort(), ["kept", "replaced", "unchanged"]);
});

test("the merge never changes the bundle it was given", () => {
  const before = JSON.stringify(sample);
  bundleJs.bundleAddRaw(sample, payloadsOf(altered(sample.sessions[0])), { fetchedAt: "2031-03-01T00:00:00Z" });
  assert.equal(JSON.stringify(sample), before);
});

test("three files that are not one session are refused, with a reason", () => {
  const files = ["sample_session_match.json", "sample_session_stats.json", "sample_session_shots.json"].map((f) => JSON.parse(readSampleSessionFile(f)));
  assert.throws(() => bundleJs.bundleAddRaw(sample, files.slice(0, 2)), /exactly three payloads/);
  assert.throws(() => bundleJs.bundleAddRaw(sample, [files[0], files[0], files[2]]), /one match, one stats and one shots/);
  const other = JSON.parse(JSON.stringify(sample.sessions[0].shots));
  assert.throws(() => bundleJs.bundleAddRaw(sample, [files[0], files[1], other]), /do not belong to this match/);
  assert.throws(() => bundleJs.bundleAddRaw(sample, [files[0], files[1], { foo: 1 }]), /Cannot tell what this payload is/);
});

test("a bundle written by the app reads back unchanged, and is gzip", async () => {
  const bytes = await bundleJs.bundleWrite(sample);
  assert.equal(bytes[0], 0x1f);
  assert.equal(bytes[1], 0x8b);
  const again = await bundleJs.bundleRead(bytes, "round trip");
  assert.deepEqual(again, JSON.parse(JSON.stringify(sample)));
  assert.equal(util.toColumns(bundleJs.bundleToTables(again, "Sample Player").matches, ["match_id"]).n, 6);
});

test("a file that is too large, empty or not a bundle is refused with a message that says why", async () => {
  await assert.rejects(bundleJs.bundleRead(new Uint8Array(0), "empty.json"), /is empty/);
  await assert.rejects(bundleJs.bundleRead(new Uint8Array(20), "big.json", 10), /too large/);
  await assert.rejects(bundleJs.bundleRead(new TextEncoder().encode("not json"), "x.json"), /not valid JSON/);
  const gz = await bundleJs.bundleWrite(sample);
  await assert.rejects(bundleJs.bundleRead(gz, "bomb.json.gz", 1000), /too large once uncompressed|too large/);
  await assert.rejects(bundleJs.bundleRead(new Uint8Array([0x1f, 0x8b, 1, 2, 3]), "broken.gz"), /could not be unzipped/);
});
