// Shared by the JavaScript tests: where the app code and the reference values
// are, and how the two are compared.
//
// The reference values are written by the R package (data-raw/js_parity_fixtures.R)
// and committed under tests/testthat/fixtures/js_parity/. A value of the
// JavaScript app must equal R's: numbers within a relative 1e-9 (times within
// 1e-5 seconds), text, dates and missing values exactly.

import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));

// the app's code: inst/app_js in the source tree, or the installed copy
// (the R tests pass its place in RALLYR_JS_DIR)
export const appDir = process.env.RALLYR_JS_DIR || path.resolve(here, "..", "..", "inst", "app_js");
export const fixtureDir = process.env.RALLYR_FIXTURE_DIR || path.resolve(here, "..", "testthat", "fixtures", "js_parity");
export const extdataDir = process.env.RALLYR_EXTDATA_DIR || path.resolve(here, "..", "..", "inst", "extdata");

export const load = (name) => import(pathToFileURL(path.join(appDir, "js", name)).href);

export const readFixture = (name) => JSON.parse(zlib.gunzipSync(fs.readFileSync(path.join(fixtureDir, name))).toString("utf8"));
export const sampleBundleBytes = () => new Uint8Array(fs.readFileSync(path.join(extdataDir, "synthetic_sample_bundle.json.gz")));
export const sampleSessionDir = path.join(extdataDir, "synthetic_sample_session");
export const readSampleSessionFile = (name) => fs.readFileSync(path.join(sampleSessionDir, name), "utf8");

const isMissing = (x) => x === null || x === undefined || (typeof x === "number" && Number.isNaN(x));

// The differences between a value of the app and R's, as short messages (none
// when they are equal). Compares one value.
export function differs(a, b, { time = false } = {}) {
  if (isMissing(a) || isMissing(b)) return isMissing(a) && isMissing(b) ? null : `${a} vs ${b}`;
  if (typeof a === "number" && typeof b === "number") {
    const ok = time ? Math.abs(a - b) <= 1e-5 : Math.abs(a - b) <= 1e-9 * Math.max(1, Math.abs(a), Math.abs(b));
    return ok ? null : `${a} vs ${b}`;
  }
  return a === b ? null : `${JSON.stringify(a)} vs ${JSON.stringify(b)}`;
}

// Compare a table of the app (as { names, n, cols }, see util.toColumns) with
// the table R wrote. Returns the messages; an empty list means identical.
export function compareTable(label, got, want, limit = 5) {
  const out = [];
  if (JSON.stringify(got.names) !== JSON.stringify(want.names)) {
    out.push(`${label}: columns differ: ${got.names.join(",")} vs ${want.names.join(",")}`);
    return out;
  }
  if (got.n !== want.n) {
    out.push(`${label}: ${got.n} rows vs ${want.n}`);
    return out;
  }
  for (const c of want.names) {
    const time = want.time.includes(c);
    let shown = 0;
    for (let i = 0; i < want.n; i += 1) {
      const d = differs(got.cols[c][i], want.cols[c][i], { time });
      if (d !== null) {
        if (shown < limit) out.push(`${label}.${c}[${i}]: ${d}`);
        shown += 1;
      }
    }
    if (shown > limit) out.push(`${label}.${c}: ${shown - limit} more differences`);
  }
  return out;
}

// compare two plain arrays of numbers or text (R: expect_equal on a vector)
export function compareVector(label, got, want, opts = {}) {
  const out = [];
  if (got.length !== want.length) return [`${label}: length ${got.length} vs ${want.length}`];
  got.forEach((g, i) => {
    const d = differs(g, want[i], opts);
    if (d !== null) out.push(`${label}[${i}]: ${d}`);
  });
  return out;
}
