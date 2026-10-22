// The comparison itself must be able to fail. Each test below changes ONE value
// of a copy of the reference (or of the app's result) and checks that the
// comparison names it; the unchanged copy passes. Without these, a green parity
// run could mean the comparison sees nothing.

import test from "node:test";
import assert from "node:assert/strict";
import { readFixture } from "./helpers.mjs";
import { sample, compareResult, run } from "./parity_lib.mjs";

const fixture = () => readFixture("sample.json.gz");
const got = () => run(sample, "Sample Player");

test("control: the untouched reference and result agree", () => {
  assert.deepEqual(compareResult(got(), fixture()), []);
});

test("a number changed in the reference (one stroke speed) is reported", () => {
  const want = fixture();
  want.tables.shot_detail.cols.shot_speed_mph[10] += 0.5;
  const found = compareResult(got(), want);
  assert.equal(found.length, 1);
  assert.match(found[0], /tables\.shot_detail\.shot_speed_mph\[10\]/);
});

test("a change smaller than the tolerance is not reported, one just above it is", () => {
  const want = fixture();
  const v = want.derived.sessions.cols.shots_in_pct[0];
  want.derived.sessions.cols.shots_in_pct[0] = v * (1 + 5e-10);
  assert.deepEqual(compareResult(got(), want), []);
  want.derived.sessions.cols.shots_in_pct[0] = v * (1 + 5e-9);
  assert.match(compareResult(got(), want).join("\n"), /derived\.sessions\.shots_in_pct\[0\]/);
});

test("a time off by a hundredth of a second is reported", () => {
  const want = fixture();
  want.tables.shot_detail.cols.started_at[3] += 0.01;
  assert.match(compareResult(got(), want).join("\n"), /shot_detail\.started_at\[3\]/);
});

test("a text value changed in the reference (a drill name) is reported", () => {
  const want = fixture();
  want.tables.shot_detail.cols.regime[0] = "mixed";
  const found = compareResult(got(), want);
  assert.match(found.join("\n"), /shot_detail\.regime\[0\]/);
});

test("a date changed in the reference is reported", () => {
  const want = fixture();
  want.derived.sessions.cols.session_date[2] = "2030-02-31";
  assert.match(compareResult(got(), want).join("\n"), /sessions\.session_date\[2\]/);
});

test("a value that is missing in one and present in the other is reported", () => {
  const want = fixture();
  want.tables.matches.cols.share_token[1] = null;
  assert.match(compareResult(got(), want).join("\n"), /matches\.share_token\[1\]/);
});

test("a missing row and a renamed column are reported", () => {
  const rows = fixture();
  rows.tables.rallies.n -= 1;
  assert.match(compareResult(got(), rows).join("\n"), /tables\.rallies: \d+ rows vs \d+/);
  const cols = fixture();
  cols.derived.net_clearance.names[2] = "median_me";
  assert.match(compareResult(got(), cols).join("\n"), /columns differ/);
});

test("a change in the app's own result is reported too (the check reads the app's values)", () => {
  const result = got();
  result.tables.shot_detail[7].hit_wing = result.tables.shot_detail[7].hit_wing === "left" ? "right" : "left";
  result.derived.corrected_rallies[0].speed_kmh += 1;
  const found = compareResult(result, fixture()).join("\n");
  assert.match(found, /shot_detail\.hit_wing\[7\]/);
  assert.match(found, /corrected_rallies\.speed_kmh\[0\]/);
});
