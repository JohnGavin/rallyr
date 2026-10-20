// Browser check: load the built site in a real browser and list EVERY request.
//
//   node tools/check_app_requests.mjs <site_dir> [--fixture]
//
// Serves <site_dir> on 127.0.0.1, opens the home page, an article, a reference
// page and the app, and records every request the browser makes (pages,
// dedicated workers and the service worker included). It fails if any request
// goes to an origin other than the local server (data: and blob: URLs are
// in-page). For the app it waits until a chart has been drawn, then drives it:
// it uploads the synthetic sample bundle and merges one of its sessions again
// (the report must say "unchanged"), so the requests are measured on an app
// that was used, not only on one that started.
//
// Three things make a request leave visible and harmless at once:
//  * Chromium is started with a host-resolver rule that makes every name other
//    than 127.0.0.1 fail to resolve, so an outside request cannot succeed even
//    if the check missed it (a failed request is still recorded);
//  * failed requests and console errors are recorded and listed;
//  * requests made by a service worker are reported only when Playwright's
//    experimental switch PW_EXPERIMENTAL_SERVICE_WORKER_NETWORK_EVENTS is set.
//    It exists in the pinned Playwright (1.49.1: tracked in
//    playwright-core/lib/server/chromium/crServiceWorker.js) and this script
//    sets it, but it is experimental and Chromium-only: without it a service
//    worker's requests would not be seen at all. The positive control below
//    proves it works, by having a service worker call an outside origin.
//
// --fixture: the folder is a test page (tests/fixtures/outside-requests), not
// the site. Only "/" is opened and no chart is awaited. CI runs the check this
// way expecting exit 1 AND the three outside requests (page, worker, service
// worker) named in the output: a positive control, so a green run on the real
// site means the check could have gone red.
//
// Exit codes: 0 = every request was local and the app drew its charts and took
// an upload and a merge; 1 = a request left the site; 3 = indeterminate (the
// app did not draw a chart or could not be driven in time, or the browser could
// not start): the absence of requests means nothing then. Usage errors exit 2.
//
// This is the check that covers the vendored runtime (Shinylive, WebAssembly
// R) that tools/check_site_privacy.R cannot scan, and the workers a <meta>
// policy does not bind. It runs in CI; it needs `npm install playwright` and a
// Chromium (`npx playwright install chromium`).

import http from "node:http";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import zlib from "node:zlib";
import { fileURLToPath } from "node:url";

process.env.PW_EXPERIMENTAL_SERVICE_WORKER_NETWORK_EVENTS = "1";
const { chromium } = await import("playwright");

const args = process.argv.slice(2);
const fixture = args.includes("--fixture");
const siteDir = args.find((a) => !a.startsWith("--"));
if (!siteDir || !fs.existsSync(siteDir)) {
  console.error("Usage: node tools/check_app_requests.mjs <site_dir> [--fixture]");
  process.exit(2);
}
const root = path.resolve(siteDir);
const here = path.dirname(fileURLToPath(import.meta.url));
const sampleBundle = path.resolve(here, "..", "inst", "extdata", "synthetic_sample_bundle.json.gz");
const timeoutMs = Number(process.env.APP_TIMEOUT_MS || 300000);

const types = {
  ".html": "text/html; charset=utf-8", ".js": "text/javascript", ".mjs": "text/javascript",
  ".css": "text/css", ".json": "application/json", ".wasm": "application/wasm",
  ".png": "image/png", ".svg": "image/svg+xml", ".ico": "image/x-icon", ".data": "application/octet-stream",
  ".gz": "application/gzip", ".tgz": "application/gzip", ".map": "application/json",
  ".woff2": "font/woff2", ".ttf": "font/ttf", ".txt": "text/plain", ".md": "text/markdown",
};

const server = http.createServer((req, res) => {
  let rel = decodeURIComponent(new URL(req.url, "http://x").pathname);
  let file = path.join(root, rel);
  if (!file.startsWith(root)) { res.writeHead(403); res.end(); return; }
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, "index.html");
  if (!fs.existsSync(file)) { res.writeHead(404); res.end("not found"); return; }
  res.writeHead(200, { "Content-Type": types[path.extname(file)] || "application/octet-stream" });
  fs.createReadStream(file).pipe(res);
});
await new Promise((r) => server.listen(0, "127.0.0.1", r));
const base = `http://127.0.0.1:${server.address().port}`;

// Three payload files of the sample bundle's first session, as a person would
// save them from the share links (the wrapper object included).
function sampleSessionFiles() {
  const bundle = JSON.parse(zlib.gunzipSync(fs.readFileSync(sampleBundle)).toString("utf8"));
  const s = bundle.sessions[0];
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "rallyr_check_"));
  return ["match", "stats", "shots"].map((k, i) => {
    const p = path.join(dir, `${"abc"[i]}.json`);
    fs.writeFileSync(p, JSON.stringify(s[k]));
    return p;
  });
}

let browser;
const requests = [];
const failed = [];
const consoleErrors = [];
let status = 0;
let step = "starting the browser";
try {
  // CHROME_PATH: use an installed Chrome instead of Playwright's own Chromium.
  // Every name but the local server fails to resolve: an outside request cannot succeed.
  browser = await chromium.launch({
    executablePath: process.env.CHROME_PATH || undefined,
    args: ["--host-resolver-rules=MAP * ~NOTFOUND, EXCLUDE 127.0.0.1"],
  });
  const context = await browser.newContext({ acceptDownloads: true });
  context.on("request", (r) => requests.push({ url: r.url(), by: r.serviceWorker() ? "service-worker" : "page" }));
  context.on("requestfailed", (r) => failed.push(`${r.url()}  [${r.failure() ? r.failure().errorText : "failed"}]`));
  const watch = (page) => {
    page.on("console", (m) => { if (m.type() === "error") consoleErrors.push(m.text().slice(0, 300)); });
    page.on("pageerror", (e) => consoleErrors.push("pageerror: " + String(e).slice(0, 300)));
  };

  const pages = fixture ? ["/"] : ["/", "/articles/dashboard.html", "/reference/rallyr-bundle.html"].filter((p) =>
    fs.existsSync(path.join(root, p === "/" ? "index.html" : p)));
  for (const p of pages) {
    step = `opening ${p}`;
    const page = await context.newPage();
    watch(page);
    await page.goto(base + p, { waitUntil: "load" });
    await page.waitForTimeout(fixture ? 3000 : 1000);
    await page.close();
  }

  let drawn = fixture;   // a fixture has no app to draw
  let driven = fixture;
  if (!fixture) {
    // The app: wait for the first chart (an <img> inside the plot output, in any frame).
    step = "waiting for the app's first chart";
    const page = await context.newPage();
    watch(page);
    await page.goto(base + "/app/", { waitUntil: "load" });
    const deadline = Date.now() + timeoutMs;
    const appFrame = async (selector) => {
      for (const f of page.frames()) {
        try { if (await f.locator(selector).count() > 0) return f; } catch { /* frame navigating */ }
      }
      return null;
    };
    drawn = false;
    while (Date.now() < deadline && !drawn) {
      drawn = (await appFrame("#plot_trend img")) !== null;
      if (!drawn) await page.waitForTimeout(1000);
    }

    if (drawn) {
      // Use the app: upload the sample bundle, then merge one of its sessions again.
      const waitText = async (f, sel, re, label) => {
        step = label;
        const t0 = Date.now();
        while (Date.now() - t0 < 120000) {
          try { if (re.test(await f.locator(sel).innerText({ timeout: 2000 }))) return; } catch { /* not there yet */ }
          await page.waitForTimeout(1000);
        }
        throw new Error(`timed out ${label}`);
      };
      try {
        if (!fs.existsSync(sampleBundle)) throw new Error(`the sample bundle is missing: ${sampleBundle}`);
        const f = await appFrame("#bundle_file");
        if (!f) throw new Error("the app's upload control was not found");
        step = "uploading the sample bundle";
        await f.locator("#bundle_file").setInputFiles(sampleBundle);
        await waitText(f, "#merge_msg", /Loaded a bundle of \d+ session/, "waiting for the bundle upload to be read");
        step = "dropping a session's three files";
        await f.locator("#raw_files").setInputFiles(sampleSessionFiles());
        await waitText(f, "#raw_detect", /shots/, "waiting for the dropped files to be recognised");
        await f.locator("#merge").click();
        await waitText(f, "#merge_summary", /Unchanged\s*1/, "waiting for the merge report to say 'unchanged'");
        driven = true;
      } catch (e) {
        console.error("Could not drive the app while " + step + ": " + (e && e.message ? e.message : e));
      }
    }
    await page.waitForTimeout(2000);
    await page.close();
  }

  const outside = requests.filter((r) => {
    if (r.url.startsWith("data:") || r.url.startsWith("blob:")) return false;
    return new URL(r.url).origin !== base;
  });
  const bySW = requests.filter((r) => r.by === "service-worker").length;
  console.log(`${requests.length} request(s) recorded (${bySW} by a service worker); ${outside.length} to other origins.`);
  const origins = [...new Set(requests.filter((r) => !/^(data|blob):/.test(r.url)).map((r) => new URL(r.url).origin))];
  console.log("Origins seen: " + origins.join(", "));
  if (failed.length > 0) {
    console.log(`${failed.length} failed request(s):`);
    for (const x of [...new Set(failed)].slice(0, 20)) console.log("  failed: " + x);
  }
  if (consoleErrors.length > 0) {
    console.log(`${consoleErrors.length} console error(s):`);
    for (const x of [...new Set(consoleErrors)].slice(0, 20)) console.log("  console: " + x);
  }
  if (outside.length > 0) {
    for (const r of outside) console.error(`  OUTSIDE (${r.by}): ${r.url}`);
    console.error("FAIL: a request left this site.");
    status = 1;
  } else if (!drawn) {
    console.error(`INDETERMINATE: the app did not draw a chart within ${timeoutMs} ms, so the request list says nothing about a running app.`);
    status = 3;
  } else if (!driven) {
    console.error("INDETERMINATE: the app drew its charts but could not be driven through an upload and a merge, so those paths were not observed.");
    status = 3;
  } else {
    console.log("PASS: the app drew its charts, took an upload and a merge, and every request was to this site.");
  }
} catch (e) {
  console.error(`INDETERMINATE (${step}): ` + (e && e.message ? e.message : e));
  status = 3;
} finally {
  if (browser) await browser.close();
  server.close();
}
process.exit(status);
