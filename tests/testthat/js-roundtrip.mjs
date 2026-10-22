// Called by tests/testthat/test-js_app.R: lets R check, with files, that a
// bundle written by one side reads on the other.
//
//   node js-roundtrip.mjs read    <bundle> <out.json> <player>
//        reads a bundle (written by R) and writes what the app made of it
//   node js-roundtrip.mjs rewrite <bundle> <out.json.gz>
//        reads a bundle and writes it again, as the app's "Download" does
//   node js-roundtrip.mjs add     <bundle> <out.json.gz> <report.json> <match> <stats> <shots> <token|-> <fetched_at>
//        adds one session, as the app's "Add session" does, and writes the bundle and the report
//
// The app's code is in the folder named by RALLYR_JS_DIR.

import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const dir = process.env.RALLYR_JS_DIR;
if (!dir) { console.error("RALLYR_JS_DIR is not set"); process.exit(2); }
const load = (f) => import(pathToFileURL(path.join(dir, "js", f)).href);
const bundleJs = await load("bundle.js");

const [mode, input, output, ...rest] = process.argv.slice(2);
const bytes = new Uint8Array(fs.readFileSync(input));
const bundle = await bundleJs.bundleRead(bytes, path.basename(input));

if (mode === "read") {
  const player = rest[0];
  const tables = bundleJs.bundleToTables(bundle, player);
  const derived = bundleJs.bundleDerived(tables);
  fs.writeFileSync(output, JSON.stringify({
    n_sessions: bundle.sessions.length,
    match_ids: bundle.sessions.map((s) => s.match_id),
    players: bundleJs.bundlePlayers(bundle),
    n_matches: tables.matches.length,
    n_shot_detail: tables.shot_detail.length,
    n_rallies: tables.rallies.length,
    n_corrected: derived.corrected_rallies.length,
    accuracy: derived.sessions.map((s) => s.shots_in_pct),
  }));
} else if (mode === "rewrite") {
  fs.writeFileSync(output, await bundleJs.bundleWrite(bundle));
} else if (mode === "add") {
  const [reportFile, match, stats, shots, token, fetchedAt] = rest;
  const payloads = [match, stats, shots].map((f) => JSON.parse(fs.readFileSync(f, "utf8")));
  const out = bundleJs.bundleAddRaw(bundle, payloads, { token: token === "-" ? null : token, fetchedAt });
  fs.writeFileSync(output, await bundleJs.bundleWrite(out.bundle));
  fs.writeFileSync(reportFile, JSON.stringify(out.report));
} else {
  console.error(`unknown mode ${mode}`);
  process.exit(2);
}
