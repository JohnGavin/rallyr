// Browser check: load the built site in a real browser and list EVERY request.
//
//   node tools/check_app_requests.mjs <site_dir>
//
// Serves <site_dir> on 127.0.0.1, opens the home page, an article, a reference
// page and the app, and records every request the browser makes (pages,
// workers and the service worker included). It fails if any request goes to an
// origin other than the local server (data: and blob: URLs are in-page).
// For the app it also waits until a chart has been drawn, so "no request" is
// measured on an app that actually ran, not on one that failed to start.
//
// Exit codes: 0 = every request was local and the app drew its chart;
// 1 = a request left the site; 3 = indeterminate (the app did not draw a chart
// in time, or the browser could not start): the absence of requests means
// nothing then. Usage errors exit 2.
//
// This is the check that covers the vendored runtime (Shinylive, WebAssembly
// R) that tools/check_site_privacy.R cannot scan, and the workers a <meta>
// policy does not bind. It runs in CI; it needs `npm install playwright` and a
// Chromium (`npx playwright install chromium`).

import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { chromium } from "playwright";

const siteDir = process.argv[2];
if (!siteDir || !fs.existsSync(siteDir)) {
  console.error("Usage: node tools/check_app_requests.mjs <site_dir>");
  process.exit(2);
}
const root = path.resolve(siteDir);
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

let browser;
const requests = [];
let status = 0;
try {
  browser = await chromium.launch();
  const context = await browser.newContext();
  context.on("request", (r) => requests.push({ url: r.url(), by: r.serviceWorker() ? "service-worker" : "page" }));

  const pages = ["/", "/articles/dashboard.html", "/reference/rallyr-bundle.html"].filter((p) =>
    fs.existsSync(path.join(root, p === "/" ? "index.html" : p)));
  for (const p of pages) {
    const page = await context.newPage();
    await page.goto(base + p, { waitUntil: "load" });
    await page.waitForTimeout(1000);
    await page.close();
  }

  // The app: wait for the first chart (an <img> inside the plot output, in any frame).
  const page = await context.newPage();
  await page.goto(base + "/app/", { waitUntil: "load" });
  const deadline = Date.now() + timeoutMs;
  let drawn = false;
  while (Date.now() < deadline && !drawn) {
    for (const f of page.frames()) {
      try {
        if (await f.locator("#plot_trend img").count() > 0) { drawn = true; break; }
      } catch { /* frame navigating: try again */ }
    }
    if (!drawn) await page.waitForTimeout(1000);
  }
  await page.waitForTimeout(2000);
  await page.close();

  const outside = requests.filter((r) => {
    if (r.url.startsWith("data:") || r.url.startsWith("blob:")) return false;
    return new URL(r.url).origin !== base;
  });
  console.log(`${requests.length} request(s) recorded; ${outside.length} to other origins.`);
  const origins = [...new Set(requests.filter((r) => !/^(data|blob):/.test(r.url)).map((r) => new URL(r.url).origin))];
  console.log("Origins seen: " + origins.join(", "));
  if (outside.length > 0) {
    for (const r of outside) console.error(`  OUTSIDE (${r.by}): ${r.url}`);
    console.error("FAIL: a request left this site.");
    status = 1;
  } else if (!drawn) {
    console.error(`INDETERMINATE: the app did not draw a chart within ${timeoutMs} ms, so the request list says nothing about a running app.`);
    status = 3;
  } else {
    console.log("PASS: the app drew its charts and every request was to this site.");
  }
} catch (e) {
  console.error("INDETERMINATE: " + (e && e.message ? e.message : e));
  status = 3;
} finally {
  if (browser) await browser.close();
  server.close();
}
process.exit(status);
