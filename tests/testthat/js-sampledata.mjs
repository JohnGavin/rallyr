// Called by tests/testthat/test-js_app.R: the sample data the build writes into
// the app (js/sample_data.js) must be the files under inst/extdata, byte for byte
// (the bundle) and value for value (the three JSON files of the extra session).
//
//   node js-sampledata.mjs <built app folder> <inst/extdata folder>
//
// Prints "SAMPLE DATA OK" or stops with the first difference.

import fs from "node:fs";
import path from "node:path";
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";

const [appDir, extdata] = process.argv.slice(2);
const data = await import(pathToFileURL(path.join(appDir, "js", "sample_data.js")).href);

const bundle = new Uint8Array(fs.readFileSync(path.join(extdata, "synthetic_sample_bundle.json.gz")));
const decoded = Uint8Array.from(atob(data.SAMPLE_BUNDLE_B64), (c) => c.charCodeAt(0));
assert.equal(decoded.length, bundle.length, "the sample bundle has a different length");
assert.ok(decoded.every((b, i) => b === bundle[i]), "the sample bundle differs");

assert.deepEqual(Object.keys(data.SAMPLE_SESSION_FILES).sort(), ["match", "shots", "stats"]);
for (const [kind, file] of Object.entries(data.SAMPLE_SESSION_FILES)) {
  assert.equal(file.name, `sample_session_${kind}.json`);
  const original = fs.readFileSync(path.join(extdata, "synthetic_sample_session", file.name), "utf8");
  assert.deepEqual(JSON.parse(file.text), JSON.parse(original), `${file.name} differs`);
}
console.log("SAMPLE DATA OK");
