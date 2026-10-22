// The rallyr browser app: the page's behaviour (inst/app/app.R is the same app
// in R; its steps and wording are kept). Everything runs in this tab: files are
// read here, nothing is sent anywhere, and the page makes no requests of its
// own (the sample files come with the page as a script, see sample_data.js).
//
// The calculations are in the other modules of this folder, which mirror the R
// package function by function; this file only connects them to the page.

import {
  bundleNew, bundleRead, bundleWrite, bundleAddRaw, bundleToTables, bundleDerived, bundlePlayers,
  bundleReadText, bundleParseJson, bundlePayloadKind,
} from "./bundle.js";
import { svToken, svApiBase } from "./sv.js";
import {
  chartSessionTrend, chartRallyLength, chartStrokeSpeed, chartNetClearance, chartGapDistribution, formatDate,
} from "./charts.js";
import { dayNumber, dayText } from "./util.js";
import { SAMPLE_BUNDLE_B64, SAMPLE_SESSION_FILES } from "./sample_data.js";

const SAMPLE_PLAYER = "Sample Player";
const $ = (id) => document.getElementById(id);

const state = {
  bundle: null,
  sample: null,
  sourceKind: "sample", // "sample" until the visitor supplies data
  mergeResult: null, // { msg, report }
  raw: [], // the files chosen in step 2: { name, kind, payload }
  result: null, // { derived } or { error }
  resultFor: null, // [bundle, name] the result was computed for
  derivedShown: null, // the derived data the date range was last set for
};

// ---- small helpers -----------------------------------------------------------

const clear = (el) => { while (el.firstChild) el.removeChild(el.firstChild); };

function el(tag, attrs = {}, text = null) {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) node.setAttribute(k, v);
  if (text !== null) node.textContent = text;
  return node;
}

// a two-column table (Metric | Value, or any two headings)
function fillTable(table, heads, rows, numericLast = true) {
  clear(table);
  const head = el("tr");
  for (const h of heads) head.appendChild(el("th", { scope: "col" }, h));
  table.appendChild(head);
  for (const r of rows) {
    const tr = el("tr");
    r.forEach((v, i) => tr.appendChild(el("td", numericLast && i === r.length - 1 && heads.length === 2 ? { class: "num" } : {}, String(v))));
    table.appendChild(tr);
  }
}

function notice(message) {
  const box = el("div", { class: "notice" });
  box.appendChild(el("span", {}, message));
  const close = el("button", { type: "button" }, "Dismiss");
  close.addEventListener("click", () => box.remove());
  box.appendChild(close);
  $("notices").appendChild(box);
}

const decodeBase64 = (b64) => Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
const fileBytes = async (file) => new Uint8Array(await file.arrayBuffer());
const tokenOk = (x) => x !== "" && /^[A-Za-z0-9._~-]+$/.test(x);
const plainError = (e) => String(e && e.message ? e.message : e).replace(/\s+/g, " ");

function saveBlob(bytes, name, type) {
  const url = URL.createObjectURL(new Blob([bytes], { type }));
  const a = el("a", { href: url, download: name });
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 2000);
}

// ---- tabs and theme --------------------------------------------------------------

const TABS = ["charts", "summary", "merge", "about"];
function selectTab(name) {
  for (const t of TABS) {
    $(`tab_${t}`).setAttribute("aria-selected", String(t === name));
    $(`panel_${t}`).hidden = t !== name;
  }
}

function setupTheme() {
  const button = $("theme");
  const dark = () => document.documentElement.dataset.theme === "dark"
    || (document.documentElement.dataset.theme === undefined && window.matchMedia("(prefers-color-scheme: dark)").matches);
  const sync = () => {
    button.setAttribute("aria-pressed", String(dark()));
    button.textContent = dark() ? "Light mode" : "Dark mode";
  };
  button.addEventListener("click", () => {
    document.documentElement.dataset.theme = dark() ? "light" : "dark";
    sync();
  });
  sync();
}

// ---- who you are -------------------------------------------------------------------

// mirrors set_players() of the R app: the names in the bundle, and `keep` as the choice
function setPlayers(bundle, keep = "") {
  const names = [...new Set([...bundlePlayers(bundle), ...(keep ? [keep] : [])])];
  const list = $("players");
  clear(list);
  for (const n of names) list.appendChild(el("option", { value: n }));
  $("me").value = keep;
}

const me = () => $("me").value.trim();

// ---- computing -------------------------------------------------------------------------

// the tables and derived data for the bundle and name now chosen, or a message
// saying why there are none (mirrors tables() and derived() of the R app)
function compute() {
  const name = me();
  if (state.resultFor && state.resultFor[0] === state.bundle && state.resultFor[1] === name) return state.result;
  let result;
  if (name === "") {
    result = { error: "Enter your player name in step 3 to draw the charts." };
  } else {
    try {
      const tables = bundleToTables(state.bundle, name, { onError: "skip" });
      if (tables.matches.length === 0) {
        result = { error: `No session has a player called "${name}". Names in this bundle: ${bundlePlayers(state.bundle).join(", ")}.` };
      } else {
        result = { derived: bundleDerived(tables) };
      }
    } catch (e) {
      result = { error: `Could not work out the charts: ${plainError(e)}` };
    }
  }
  state.result = result;
  state.resultFor = [state.bundle, name];
  return result;
}

// ---- rendering ----------------------------------------------------------------------------

function renderStatus(result) {
  const box = $("status");
  clear(box);
  if (result.error || me() === "") return;
  if (state.sourceKind === "sample") {
    box.appendChild(el("p", { class: "small muted" }, "Showing a synthetic sample. Choose your bundle (step 1) or add a session (step 2) to see your own."));
  }
  const sk = result.derived.tables.skipped;
  if (sk.length > 0) {
    const reasons = [...new Set(sk.map((s) => s.reason))].join("; ");
    box.appendChild(el("p", { class: "small warn" }, `${sk.length} session(s) left out: ${reasons}.`));
  }
}

function message(containerId, text) {
  const c = $(containerId);
  clear(c);
  c.appendChild(el("p", { class: "muted" }, text));
}

function renderTrend(derived) {
  const range = [dayText(Number($("range_from").value)), dayText(Number($("range_to").value))];
  $("range_from_text").textContent = formatDate(range[0]);
  $("range_to_text").textContent = formatDate(range[1]);
  const newestLeft = document.querySelector('input[name="axis_dir"]:checked').value === "new";
  $("plot_trend").innerHTML = chartSessionTrend(derived, { dateRange: range, newestLeft });
}

// the trend window starts as the last three months (mirrors observeEvent(derived()))
function resetRange(derived) {
  const days = derived.sessions.map((s) => dayNumber(s.session_date));
  const lo = Math.min(...days);
  const hi = Math.max(...days);
  const top = Math.max(hi, lo + 1);
  for (const id of ["range_from", "range_to"]) {
    $(id).min = String(lo);
    $(id).max = String(top);
  }
  $("range_from").value = String(Math.max(hi - 91, lo));
  $("range_to").value = String(top);
}

function renderCharts(result) {
  if (result.error) {
    for (const id of ["plot_trend", "plot_rally", "plot_speed", "plot_net", "plot_gap"]) message(id, result.error);
    return;
  }
  const d = result.derived;
  if (state.derivedShown !== d) {
    resetRange(d);
    state.derivedShown = d;
  }
  renderTrend(d);
  $("plot_rally").innerHTML = chartRallyLength(d);
  $("plot_speed").innerHTML = chartStrokeSpeed(d);
  $("plot_net").innerHTML = chartNetClearance(d);
  $("plot_gap").innerHTML = chartGapDistribution(d);
}

function renderSummary(result) {
  const summary = $("summary");
  const sessions = $("sessions");
  if (result.error) {
    clear(summary);
    clear(sessions);
    summary.appendChild(el("caption", {}, result.error));
    return;
  }
  const d = result.derived;
  const s = d.sessions;
  const sum = (c) => s.reduce((n, r) => n + r[c], 0);
  const dates = s.map((r) => r.session_date).sort();
  fillTable(summary, ["Metric", "Value"], [
    ["Sessions (days)", s.length],
    ["Recordings", sum("n_parts")],
    ["Your strokes tracked", d.tables.shot_detail.filter((r) => r.player === "guest").length],
    ["First session", dates[0]],
    ["Last session", dates[dates.length - 1]],
    ["Rallies kept after corrections", d.corrected_rallies === null ? 0 : d.corrected_rallies.length],
  ]);
  const one = (v) => (Number.isNaN(v) ? "" : v.toFixed(1));
  fillTable(sessions, ["Date", "Recordings", "Your strokes", "Accuracy (%)", "Minutes"],
    s.map((r) => [r.session_date, r.n_parts, r.me_shots, one(r.shots_in_pct), r.duration_min]), false);
}

function renderMerge() {
  const r = state.mergeResult;
  $("merge_msg").textContent = r === null ? "Nothing merged yet." : r.msg;
  const summary = $("merge_summary");
  const table = $("merge_table");
  clear(summary);
  clear(table);
  if (r === null) return;
  const rep = r.report ?? [];
  const count = (a) => rep.filter((x) => x.action === a).length;
  fillTable(summary, ["Metric", "Value"], [
    ["Sessions in bundle", state.bundle.sessions.length],
    ["Added", count("added")],
    ["Replaced by a newer copy", count("replaced")],
    ["Kept (existing is newer)", count("kept")],
    ["Unchanged", count("unchanged")],
  ]);
  if (rep.length > 0) fillTable(table, ["Match", "Action"], rep.map((x) => [String(x.match_id), x.action]), false);
}

function renderAll() {
  const result = compute();
  renderStatus(result);
  renderCharts(result);
  renderSummary(result);
  renderMerge();
}

// ---- 1. past sessions ------------------------------------------------------------------------

async function onBundleChosen(event) {
  const file = event.target.files[0];
  if (!file) return;
  try {
    const res = await bundleRead(await fileBytes(file), file.name);
    state.bundle = res;
    state.sourceKind = "user";
    state.mergeResult = { msg: `Loaded a bundle of ${res.sessions.length} session(s). Enter your name in step 3.`, report: null };
    $("bundle_name").textContent = file.name;
    setPlayers(res);
    renderAll();
    selectTab("merge");
  } catch (e) {
    notice(`Could not read that bundle: ${plainError(e)}`);
  }
  event.target.value = "";
}

function onReset(event) {
  event.preventDefault();
  state.bundle = state.sample;
  state.sourceKind = "sample";
  state.mergeResult = null;
  $("bundle_name").textContent = "bundle .json.gz (optional)";
  setPlayers(state.sample, SAMPLE_PLAYER);
  renderAll();
}

// ---- 2. latest session --------------------------------------------------------------------------

function renderApiLinks() {
  const box = $("api_links");
  clear(box);
  const url = $("share_url").value.trim();
  if (url === "") return;
  const tok = svToken(url);
  if (!tokenOk(tok)) {
    box.appendChild(el("p", { class: "error small" }, "That does not look like a share link."));
    return;
  }
  const base = svApiBase();
  box.appendChild(el("p", { class: "small" }, "Open each link, save the page as a .json file, then drop the three files below."));
  const ol = el("ol", { class: "small" });
  for (const [k, path] of [["match", `/matches/${tok}`], ["stats", `/matches/${tok}/stats`], ["shots", `/matches/${tok}/shots`]]) {
    const li = el("li");
    li.appendChild(el("a", { href: `${base}${path}`, target: "_blank", rel: "noopener noreferrer" }, k));
    ol.appendChild(li);
  }
  box.appendChild(ol);
}

const NEED = ["match", "stats", "shots"];

// The "Add session" button: enabled, and drawn so it is noticed, once exactly one
// match, one stats and one shots file are recognised.
function updateMergeButton(afterMerge = false) {
  const button = $("merge");
  const hint = $("merge_hint");
  const counts = Object.fromEntries(NEED.map((k) => [k, state.raw.filter((f) => f.kind === k).length]));
  const unknown = state.raw.filter((f) => f.kind === null);
  const ready = state.raw.length === 3 && NEED.every((k) => counts[k] === 1);
  button.disabled = !ready;
  button.classList.toggle("ready", ready && !afterMerge);
  hint.classList.toggle("ready", ready && !afterMerge);
  if (afterMerge) {
    hint.textContent = "Session added. Use “Download updated bundle” to save it.";
  } else if (state.raw.length === 0) {
    hint.textContent = "Choose the three files in step 2 first.";
  } else if (ready) {
    hint.textContent = "All three files are recognised. Press “Add session to bundle” to add the session.";
  } else {
    const missing = NEED.filter((k) => counts[k] === 0);
    const extra = NEED.filter((k) => counts[k] > 1);
    const parts = [`${NEED.filter((k) => counts[k] === 1).length} of 3 files recognised.`];
    if (unknown.length > 0) parts.push(`Not recognised: ${unknown.map((f) => f.name).join(", ")}.`);
    if (missing.length > 0) parts.push(`Still needed: ${missing.join(", ")}.`);
    if (extra.length > 0) parts.push(`Choose one only: ${extra.join(", ")}.`);
    hint.textContent = parts.join(" ");
  }
}

function renderRawDetect() {
  const table = $("raw_detect");
  if (state.raw.length === 0) { clear(table); return; }
  fillTable(table, ["File", "Detected"], state.raw.map((f) => [f.name, f.kind === null ? "not recognised" : f.kind]), false);
}

async function onRawChosen(event) {
  const files = [...event.target.files];
  state.raw = [];
  for (const file of files) {
    let kind = null;
    let payload = null;
    try {
      payload = bundleParseJson(await bundleReadText(await fileBytes(file), file.name), `The file ${file.name}`);
      kind = bundlePayloadKind(payload, false);
    } catch {
      kind = null;
    }
    state.raw.push({ name: file.name, kind, payload });
  }
  $("raw_name").textContent = files.length === 0 ? "the match, stats and shots files" : `${files.length} file(s) chosen`;
  renderRawDetect();
  updateMergeButton();
}

function onMerge() {
  const byKind = (k) => state.raw.find((f) => f.kind === k);
  if (!NEED.every((k) => state.raw.filter((f) => f.kind === k).length === 1) || state.raw.length !== 3) {
    notice("Drop exactly one match, one stats and one shots file (see the table). Add one session at a time.");
    return;
  }
  const base = state.sourceKind === "sample" ? bundleNew() : state.bundle;
  const url = $("share_url").value.trim();
  const token = tokenOk(svToken(url)) ? svToken(url) : null;
  let out;
  try {
    out = bundleAddRaw(base, NEED.map((k) => byKind(k).payload), { token });
  } catch (e) {
    notice(`Could not add the session: ${plainError(e)}`);
    return;
  }
  state.mergeResult = {
    msg: state.sourceKind === "sample" ? "Started a new bundle: the synthetic sample is not mixed with your data." : "Session added.",
    report: out.report,
  };
  state.bundle = out.bundle;
  state.sourceKind = "user";
  setPlayers(out.bundle, me());
  renderAll();
  updateMergeButton(true);
  selectTab("merge");
}

// ---- 4. download -----------------------------------------------------------------------------------

async function onDownload() {
  try {
    const d = new Date();
    const stamp = `${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, "0")}${String(d.getDate()).padStart(2, "0")}`;
    saveBlob(await bundleWrite(state.bundle), `rallyr_bundle_${stamp}.json.gz`, "application/gzip");
  } catch (e) {
    notice(`Could not write the bundle: ${plainError(e)}`);
  }
}

// ---- the sample files -----------------------------------------------------------------------------------

function setupSampleDownloads() {
  $("dl_sample_bundle").addEventListener("click", () => saveBlob(decodeBase64(SAMPLE_BUNDLE_B64), "rallyr_sample_bundle.json.gz", "application/gzip"));
  for (const k of NEED) {
    const name = SAMPLE_SESSION_FILES[k].name;
    $(`dl_sample_${k}`).addEventListener("click", () => saveBlob(new TextEncoder().encode(SAMPLE_SESSION_FILES[k].text), name, "application/json"));
  }
}

// ---- start --------------------------------------------------------------------------------------------------

async function start() {
  setupTheme();
  for (const t of TABS) $(`tab_${t}`).addEventListener("click", () => selectTab(t));
  setupSampleDownloads();
  $("bundle_file").addEventListener("change", onBundleChosen);
  $("reset").addEventListener("click", onReset);
  $("share_url").addEventListener("input", renderApiLinks);
  $("raw_files").addEventListener("change", onRawChosen);
  $("merge").addEventListener("click", onMerge);
  $("download").addEventListener("click", onDownload);
  let timer = null;
  $("me").addEventListener("input", () => {
    clearTimeout(timer);
    timer = setTimeout(renderAll, 250);
  });
  $("range_from").addEventListener("input", () => {
    if (Number($("range_from").value) > Number($("range_to").value)) $("range_to").value = $("range_from").value;
    if (state.result && state.result.derived) renderTrend(state.result.derived);
  });
  $("range_to").addEventListener("input", () => {
    if (Number($("range_to").value) < Number($("range_from").value)) $("range_from").value = $("range_to").value;
    if (state.result && state.result.derived) renderTrend(state.result.derived);
  });
  for (const r of document.querySelectorAll('input[name="axis_dir"]')) {
    r.addEventListener("change", () => { if (state.result && state.result.derived) renderTrend(state.result.derived); });
  }

  try {
    state.sample = await bundleRead(decodeBase64(SAMPLE_BUNDLE_B64), "the sample bundle");
    state.bundle = state.sample;
    setPlayers(state.sample, SAMPLE_PLAYER);
    renderAll();
    document.documentElement.dataset.ready = "true";
  } catch (e) {
    notice(`Could not load the synthetic sample: ${plainError(e)}`);
  }
}

start();
