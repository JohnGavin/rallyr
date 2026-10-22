// Bundles: one file holding the raw API payloads of every session. The same
// file format as the R package (R/bundle.R): gzip-compressed JSON
//   { "schema_version": 1, "sessions": [ { "match_id", "fetched_at", "token",
//                                          "match", "stats", "shots" } ] }
// so a bundle written here reads in R and the other way round.
//
// A bundle is a plain object { schema_version, sessions }. R keeps the report of
// a merge as an attribute of the returned bundle; here the merging functions
// return { bundle, report }.

import { orderBy, plainNumber, utcSeconds } from "./util.js";
import { svParseMatch, svParseShots } from "./sv.js";
import { bundleDeriveMatch } from "./segment.js";
import { dqCorrectedRallies, dqParams, sessionNetClearanceByDrill } from "./dq.js";
import { mergeSameDaySessions, sessionStandardMetrics, strokeQualitySession } from "./metrics.js";

// mirrors bundle_schema_version()
export const bundleSchemaVersion = () => 1;

// mirrors bundle_new()
export function bundleNew() {
  return { schema_version: bundleSchemaVersion(), sessions: [] };
}

const isObject = (x) => x !== null && typeof x === "object" && !Array.isArray(x);
const isList = (x) => x !== null && typeof x === "object";
const isNum = (x) => typeof x === "number" && !Number.isNaN(x);

// mirrors bundle_max_bytes(): the largest file, and the largest text once
// uncompressed, that is read (50 MB)
export const bundleMaxBytes = () => 50 * 1024 ** 2;

const mb = (bytes) => (Math.round((bytes / 1024 ** 2) * 10) / 10).toFixed(1);

// ---- reading JSON ------------------------------------------------------------

// Bytes of a gzip file, uncompressed; stops with an error once the text passes
// `maxBytes`.
async function gunzip(bytes, maxBytes, label) {
  const stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream("gzip"));
  const reader = stream.getReader();
  const chunks = [];
  let total = 0;
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      total += value.length;
      if (total > maxBytes) {
        await reader.cancel();
        throw new Error(`The file ${label} is too large once uncompressed (more than ${mb(maxBytes)} MB). A bundle of sessions is a few MB. Check that this is the right file.`);
      }
      chunks.push(value);
    }
  } catch (e) {
    if (String(e.message).startsWith("The file")) throw e;
    throw new Error(`The file ${label} could not be unzipped (${e.message}).`);
  }
  const out = new Uint8Array(total);
  let at = 0;
  for (const c of chunks) { out.set(c, at); at += c.length; }
  return out;
}

// mirrors bundle_read_text(): the text of a file that is gzip-compressed or
// plain JSON, refusing one over `maxBytes` and a gzip file that expands past it.
// `bytes` is a Uint8Array; `label` is the file's name, for messages.
export async function bundleReadText(bytes, label = "this file", maxBytes = bundleMaxBytes()) {
  if (bytes.length > maxBytes) {
    throw new Error(`The file ${label} is too large (${mb(bytes.length)} MB; the limit is ${mb(maxBytes)} MB). A bundle of sessions is a few MB. Check that this is the right file.`);
  }
  if (bytes.length === 0) throw new Error(`The file ${label} is empty.`);
  let raw = bytes;
  if (bytes.length >= 2 && bytes[0] === 0x1f && bytes[1] === 0x8b) {
    raw = await gunzip(bytes, maxBytes, label);
    if (raw.length === 0) throw new Error(`The file ${label} is empty.`);
  }
  const text = new TextDecoder("utf-8").decode(raw);
  return text.charCodeAt(0) === 0xfeff ? text.slice(1) : text;
}

// mirrors bundle_parse_json(): parse text as JSON, saying what it was if not
export function bundleParseJson(text, what) {
  try {
    return JSON.parse(text);
  } catch (e) {
    throw new Error(`${what} is not valid JSON. ${e.message}`);
  }
}

// ---- payload kinds -----------------------------------------------------------

// mirrors bundle_unwrap(): a payload is the API response ({"data": ...}) or the
// bare `data` element
export function bundleUnwrap(obj) {
  return isObject(obj) && "data" in obj ? obj.data : obj;
}

// mirrors bundle_kind_parsed(): "match", "stats" or "shots"; null when it is
// none of the three
export function bundleKindParsed(obj) {
  const d = bundleUnwrap(obj);
  if (Array.isArray(d)) {
    if (d.length === 0) return "shots";
    const probe = d.slice(0, 5);
    const allShots = probe.every((s) => isObject(s) && "player" in s && ("pid" in s || "hit_type" in s || "match_id" in s));
    return allShots ? "shots" : null;
  }
  if (isObject(d)) {
    const nm = Object.keys(d);
    if (nm.length === 0) return null;
    if (nm.includes("id") && (nm.includes("guest_name") || nm.includes("host_name"))) return "match";
    if (nm.includes("host") && nm.includes("guest") && isList(d.host) && isList(d.guest)) return "stats";
  }
  return null;
}

// mirrors bundle_payload_kind() for an already-parsed payload; `strict` makes an
// unrecognised payload an error (otherwise null)
export function bundlePayloadKind(obj, strict = true) {
  const kind = bundleKindParsed(obj);
  if (kind === null && strict) {
    throw new Error('Cannot tell what this payload is. Expected the JSON of "/matches/<token>", "/matches/<token>/stats" or "/matches/<token>/shots".');
  }
  return kind;
}

// ---- validation ---------------------------------------------------------------

// mirrors bundle_stamp_seconds(): a fetch time as seconds since 1970 (fractions
// kept); NaN when it is not an ISO-8601 date-time. Accepts a trailing Z, a
// numeric offset (+02:00, -0200, +02), fractional seconds and a bare date
// (midnight UTC); a time with no offset is read as UTC.
export function bundleStampSeconds(x) {
  if (typeof x !== "string") return NaN;
  const t = x.replace(/^[ \t\r\n]+|[ \t\r\n]+$/g, "");
  const m = /^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2}):(\d{2})(\.\d+)?(Z|[+-]\d{2}(?::?\d{2})?)?)?$/.exec(t);
  if (!m) return NaN;
  const [h, mi, s] = m[4] === undefined ? [0, 0, 0] : [+m[4], +m[5], +m[6]];
  const base = utcSeconds(+m[1], +m[2], +m[3], h, mi, s);
  if (Number.isNaN(base)) return NaN;
  const frac = m[7] ? Number(`0${m[7]}`) : 0;
  let shift = 0;
  const off = m[8];
  if (off && off !== "Z") {
    const digits = off.slice(1).replace(/[^0-9]/g, "");
    const hh = Number(digits.slice(0, 2));
    const mm = digits.length > 2 ? Number(digits.slice(2, 4)) : 0;
    if (hh > 23 || mm > 59) return NaN;
    shift = (hh * 3600 + mm * 60) * (off[0] === "-" ? -1 : 1);
  }
  return base + frac - shift;
}

// mirrors bundle_session_stamp(): -Infinity for a session with no fetched_at
// (the oldest possible)
export const bundleSessionStamp = (s) => (s.fetched_at === undefined || s.fetched_at === null ? -Infinity : bundleStampSeconds(s.fetched_at));

// mirrors bundle_id_key(): a match id as text, never in scientific form
export const bundleIdKey = (id) => plainNumber(Number(id));

// mirrors bundle_validate(): returns the bundle, or stops saying what is wrong
export function bundleValidate(x) {
  const bad = (msg) => { throw new Error(`Not a valid rallyr bundle. ${msg}`); };
  if (!isObject(x)) bad("The top level must be a JSON object.");
  const v = x.schema_version;
  if (!isNum(v) || v !== Math.round(v) || v < 1) bad("schema_version is missing or is not a positive whole number.");
  if (v > bundleSchemaVersion()) {
    throw new Error(`This bundle has file format version ${v}; this version of rallyr reads up to ${bundleSchemaVersion()}. Update rallyr, or export the bundle again from a matching version.`);
  }
  if (!Array.isArray(x.sessions)) bad("sessions must be a list of sessions.");
  const slots = ["match", "stats", "shots"];
  x.sessions.forEach((s, k) => {
    const i = k + 1;
    if (!isObject(s)) bad(`Session ${i} is not an object.`);
    const id = s.match_id;
    if (!isNum(id)) bad(`Session ${i} has no numeric match_id.`);
    for (const slot of slots) {
      if (s[slot] === undefined || s[slot] === null) bad(`Session ${i} has no ${slot} payload.`);
      if (bundleKindParsed(s[slot]) !== slot) bad(`In session ${i}, the ${slot} payload does not look like a ${slot} payload.`);
    }
    if (Number.isNaN(bundleSessionStamp(s))) {
      bad(`Session ${i} has a fetched_at that is not an ISO-8601 date-time (such as 2031-01-01T09:00:00Z).`);
    }
    const payloadId = (bundleUnwrap(s.match) || {}).id;
    if (!isNum(payloadId) || bundleIdKey(payloadId) !== bundleIdKey(id)) {
      bad(`In session ${i}, match_id does not match the id inside the match payload.`);
    }
    const shots = bundleUnwrap(s.shots);
    const shotIds = shots.map((z) => (isObject(z) ? z.match_id : undefined)).filter((z) => z !== undefined && z !== null);
    if (shotIds.length > 0 && (!shotIds.every(isNum) || shotIds.some((z) => z !== id))) {
      bad(`In session ${i}, the shots do not belong to the match (their match_id differs).`);
    }
  });
  const keys = x.sessions.map((s) => bundleIdKey(s.match_id));
  const dup = keys.filter((k, i) => keys.indexOf(k) !== i);
  if (dup.length > 0) bad(`Two sessions share a match_id: ${[...new Set(dup)].map((k) => `"${k}"`).join(", ")}.`);
  return x;
}

// ---- read / write ---------------------------------------------------------------

// mirrors bundle_read(): a bundle from the bytes of a file (gzip or plain JSON)
export async function bundleRead(bytes, label = "this file", maxBytes = bundleMaxBytes()) {
  const text = await bundleReadText(bytes, label, maxBytes);
  return bundleValidate(bundleParseJson(text, `The file ${label}`));
}

// Bytes of gzip-compressed data.
async function gzip(bytes) {
  const cs = new CompressionStream("gzip");
  const writer = cs.writable.getWriter();
  writer.write(bytes);
  writer.close();
  return new Uint8Array(await new Response(cs.readable).arrayBuffer());
}

// mirrors bundle_write(): the bytes of the gzip-compressed bundle file
export async function bundleWrite(bundle) {
  bundleValidate(bundle);
  const text = JSON.stringify({ schema_version: bundle.schema_version, sessions: bundle.sessions });
  return gzip(new TextEncoder().encode(`${text}\n`));
}

// ---- adding and merging ------------------------------------------------------------

// mirrors fetched_now(): now, as "2031-01-01T09:00:00Z"
export const fetchedNow = () => new Date().toISOString().replace(/\.\d{3}Z$/, "Z");

// deep equality of two parsed JSON values (R's identical() on the parsed lists)
export function jsonEqual(a, b) {
  if (a === b) return true;
  if (typeof a !== typeof b || a === null || b === null || typeof a !== "object") return false;
  if (Array.isArray(a) !== Array.isArray(b)) return false;
  if (Array.isArray(a)) return a.length === b.length && a.every((v, i) => jsonEqual(v, b[i]));
  const ka = Object.keys(a);
  const kb = Object.keys(b);
  return ka.length === kb.length && ka.every((k) => Object.prototype.hasOwnProperty.call(b, k) && jsonEqual(a[k], b[k]));
}

// mirrors bundle_add_raw(): add one session from its three parsed payloads
// (a match, its stats and its shots, in any order). Returns { bundle, report }.
export function bundleAddRaw(bundle, payloads, { token = null, fetchedAt = fetchedNow() } = {}) {
  bundleValidate(bundle);
  if (payloads.length !== 3) {
    throw new Error(`Supply exactly three payloads: the match, its stats and its shots. Got ${payloads.length}. Add one session at a time.`);
  }
  const kinds = payloads.map((p) => bundlePayloadKind(p));
  if (new Set(kinds).size !== 3 || !["match", "stats", "shots"].every((k) => kinds.includes(k))) {
    throw new Error(`The three payloads must be one match, one stats and one shots payload. Detected: ${kinds.map((k) => `"${k}"`).join(", ")}.`);
  }
  const objs = {};
  kinds.forEach((k, i) => { objs[k] = payloads[i]; });
  const id = bundleUnwrap(objs.match).id;
  if (!isNum(id)) throw new Error("The match payload has no numeric id.");
  const shotIds = [...new Set(bundleUnwrap(objs.shots).map((s) => (isObject(s) ? s.match_id : undefined)).filter((z) => z !== undefined && z !== null))];
  if (shotIds.length > 0 && !shotIds.every((z) => z === id)) {
    throw new Error("The shots do not belong to this match. The files look like they come from different sessions; add one session's three files together.");
  }
  const session = { match_id: id };
  if (token !== null && token !== undefined) session.token = String(token);
  session.fetched_at = String(fetchedAt);
  session.match = objs.match;
  session.stats = objs.stats;
  session.shots = objs.shots;
  return bundleMerge(bundle, { schema_version: bundleSchemaVersion(), sessions: [session] });
}

// mirrors bundle_merge(): a session of `y` with a new match_id is added; one
// already present replaces the existing copy when its fetched_at is the same
// instant or newer, and is otherwise kept out; an identical payload is
// unchanged. Returns { bundle, report } (R: the report is attr "merge_report").
export function bundleMerge(bundle, y) {
  const x = bundleValidate(bundle);
  bundleValidate(y);
  const sessions = x.sessions.slice();
  const keys = sessions.map((s) => bundleIdKey(s.match_id));
  const fetched = (s) => (s.fetched_at === undefined || s.fetched_at === null ? "" : String(s.fetched_at));
  // the incoming token wins when it has one; otherwise the existing one stays
  const tokenOf = (incoming, existing) => (incoming.token !== undefined && incoming.token !== null ? incoming.token : existing.token);
  const withToken = (s, token) => {
    const copy = { ...s };
    if (token === undefined || token === null) delete copy.token;
    else copy.token = token;
    return copy;
  };
  const report = [];
  for (const s of y.sessions) {
    const k = bundleIdKey(s.match_id);
    const pos = keys.indexOf(k);
    let action;
    let old = null;
    if (pos < 0) {
      sessions.push(s);
      keys.push(k);
      action = "added";
    } else {
      const oldS = sessions[pos];
      old = fetched(oldS);
      if (jsonEqual(oldS.match, s.match) && jsonEqual(oldS.stats, s.stats) && jsonEqual(oldS.shots, s.shots)) {
        sessions[pos] = withToken(oldS, tokenOf(s, oldS));
        action = "unchanged";
      } else if (bundleSessionStamp(s) >= bundleSessionStamp(oldS)) {
        sessions[pos] = withToken(s, tokenOf(s, oldS));
        action = "replaced";
      } else {
        action = "kept";
      }
    }
    report.push({
      match_id: Number(s.match_id), action,
      existing_fetched_at: old === null || old === "" ? null : old,
      incoming_fetched_at: fetched(s),
    });
  }
  return { bundle: { schema_version: x.schema_version, sessions }, report };
}

export const MERGE_REPORT_COLUMNS = ["match_id", "action", "existing_fetched_at", "incoming_fetched_at"];

// ---- players -------------------------------------------------------------------------

// mirrors bundle_players(): the player names in a bundle's matches, most
// frequent first (equal counts in alphabetical order)
export function bundlePlayers(bundle) {
  const counts = new Map();
  for (const s of bundle.sessions) {
    const d = bundleUnwrap(s.match) || {};
    for (const n of [d.guest_name, d.host_name]) {
      if (typeof n === "string" && n !== "") counts.set(n, (counts.get(n) ?? 0) + 1);
    }
  }
  const collator = new Intl.Collator("en");
  return [...counts.keys()].sort((a, b) => counts.get(b) - counts.get(a) || collator.compare(a, b));
}

// ---- bundle -> tables ----------------------------------------------------------------------

// mirrors bundle_my_side(): "guest" or "host", whichever side of the match is
// `me` (compared without regard to case or surrounding spaces); null for neither
export function bundleMySide(match, me) {
  const norm = (z) => (typeof z === "string" ? z.replace(/^[ \t\r\n]+|[ \t\r\n]+$/g, "").toLowerCase() : null);
  if (norm(match.guest_name) !== null && norm(match.guest_name) === norm(me)) return "guest";
  if (norm(match.host_name) !== null && norm(match.host_name) === norm(me)) return "host";
  return null;
}

// mirrors bundle_session_tables(): one session's tables for the player `me`;
// null when `me` is not in the match
export function bundleSessionTables(s, me) {
  const match = bundleUnwrap(s.match);
  const side = bundleMySide(match, me);
  if (side === null) return null;
  const meExact = match[`${side}_name`];
  const row = svParseMatch(match, bundleUnwrap(s.stats), meExact, s.token === undefined || s.token === null ? null : String(s.token));
  const shots = svParseShots(bundleUnwrap(s.shots));
  const out = { matches: row, shot_segments: null, shot_detail: null, rallies: null };
  if (shots.length === 0) return out;
  for (const sh of shots) {
    sh.match_id = row.match_id;
    // downstream code treats "guest" as the player being analysed
    if (side === "host") sh.player = sh.player === "host" ? "guest" : sh.player === "guest" ? "host" : sh.player;
  }
  const rightHanded = match[`${side}_right_handed`] !== false;
  const derived = bundleDeriveMatch(shots, rightHanded);
  out.shot_segments = derived.segs;
  out.shot_detail = derived.shots;
  out.rallies = derived.rallies;
  return out;
}

// per-session results already computed, by the session object (a session that
// changes is a new object) and the player
const sessionCache = new WeakMap();

// mirrors bundle_to_tables(): parse a bundle into the tables the metrics read.
// `onError: "skip"` leaves a session that cannot be parsed out and lists it in
// `skipped`. Results are remembered per session, so adding one session does not
// recompute the others (R: the `cache` argument).
export function bundleToTables(bundle, me, { onError = "abort", cache = true } = {}) {
  bundleValidate(bundle);
  if (typeof me !== "string" || me.trim() === "") {
    const players = bundlePlayers(bundle).map((p) => `"${p}"`).join(", ");
    throw new Error(`me must be a player name. Names in this bundle: ${players}.`);
  }
  const meKey = me.replace(/^[ \t\r\n]+|[ \t\r\n]+$/g, "").toLowerCase();
  const pieces = [];
  const skipped = [];
  for (const s of bundle.sessions) {
    let res;
    let perMe = cache ? sessionCache.get(s) : null;
    if (perMe && perMe.has(meKey)) {
      res = perMe.get(meKey);
    } else {
      try {
        res = bundleSessionTables(s, me);
      } catch (e) {
        if (onError === "abort") throw e;
        res = { error: e.message };
      }
      if (cache) {
        if (!perMe) { perMe = new Map(); sessionCache.set(s, perMe); }
        perMe.set(meKey, res);
      }
    }
    if (res === null) {
      skipped.push({ match_id: Number(s.match_id), reason: "player not in this session" });
    } else if (res.error !== undefined) {
      skipped.push({ match_id: Number(s.match_id), reason: `could not be parsed: ${res.error}` });
    } else {
      pieces.push(res);
    }
  }
  const bind = (name) => pieces.flatMap((p) => p[name] ?? []);
  const matches = orderBy(pieces.map((p) => p.matches), (r) => r.played_at);
  return {
    matches,
    shot_segments: bind("shot_segments"),
    shot_detail: bind("shot_detail"),
    rallies: bind("rallies"),
    skipped,
  };
}

// mirrors bundle_derived(): the derived-data tables the charts read. Needs at
// least one session in `tables`.
export function bundleDerived(tables, params = dqParams()) {
  if (tables.matches.length === 0) {
    throw new Error("There are no sessions to summarise. Check the player name against the names in the bundle.");
  }
  const sessions = mergeSameDaySessions(tables.matches);
  const corrected = tables.rallies.length > 0 ? dqCorrectedRallies(tables.rallies, tables.shot_detail, params) : null;
  const metrics = sessions.length >= 2 ? sessionStandardMetrics(sessions) : null;
  return {
    sessions,
    corrected_rallies: corrected,
    session_metrics: metrics,
    net_clearance: sessionNetClearanceByDrill(tables.shot_detail, params),
    stroke_quality: strokeQualitySession(tables.shot_detail, tables.matches, params),
    tables,
  };
}

