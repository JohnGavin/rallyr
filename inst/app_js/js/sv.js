// Parsing of the SwingVision share-API payloads (the match, stats and shots
// JSON). Each function says which R function it mirrors (R/fetch_swingvision.R).
//
// Tables are arrays of plain row objects. A time is a number of seconds since
// 1970-01-01 UTC (fractions kept); a date is "YYYY-MM-DD" text; a missing
// number is NaN and a missing string is null (see util.js).

import { isNA, orderBy, rround, utcSeconds } from "./util.js";

// mirrors sv_api_base()
export const svApiBase = () => "https://api.swing.tennis/v1";

// mirrors sv_token()
export function svToken(x) {
  let t = String(x).replace(/^[ \t\r\n]+|[ \t\r\n]+$/g, "");
  if (t.includes("/")) t = t.replace(/^[\s\S]*\/matches\//, "");
  return t.replace(/[?#][\s\S]*$/, "");
}

// mirrors sv_fps(): the pinned video frame rate
export const svFps = () => 60.006;

// ---- small coercers (sv_num, sv_chr, sv_mph, sv_speed_mph, sv_component) ----

// mirrors sv_num()
export function svNum(x) {
  if (x === null || x === undefined) return NaN;
  if (typeof x === "number") return x;
  if (typeof x === "boolean") return x ? 1 : 0;
  if (typeof x === "string") {
    const t = x.trim();
    return t === "" ? NaN : Number(t);
  }
  return NaN;
}

// mirrors sv_chr()
export function svChr(x) {
  if (x === null || x === undefined) return null;
  if (Array.isArray(x)) return null;
  if (typeof x === "string") return x;
  if (typeof x === "boolean") return x ? "TRUE" : "FALSE";
  if (typeof x === "number") return String(x);
  return null;
}

// mirrors sv_mph(): metres per second -> miles per hour (0 means "no reading")
export function svMph(velocityMs) {
  const v = svNum(velocityMs);
  return isNA(v) || v === 0 ? NaN : rround(v * 2.2369362920544, 1);
}

// mirrors sv_speed_mph(): the magnitude of a velocity vector, in mph
export function svSpeedMph(vec) {
  if (vec === null || vec === undefined) return NaN;
  const parts = Array.isArray(vec) ? vec : typeof vec === "object" ? Object.values(vec) : [vec];
  if (parts.length === 0) return NaN;
  const vals = parts.map((x) => (x === null || x === undefined ? NaN : svNum(x)));
  if (vals.some(Number.isNaN)) return NaN;
  return svMph(Math.sqrt(vals.reduce((s, v) => s + v * v, 0)));
}

// mirrors sv_component(): the i-th (1-based) element of a numeric vector field
export function svComponent(v, i) {
  if (v === null || v === undefined) return NaN;
  const parts = Array.isArray(v) ? v : typeof v === "object" ? Object.values(v) : [v];
  if (parts.length < i || parts[i - 1] === null || parts[i - 1] === undefined) return NaN;
  return svNum(parts[i - 1]);
}

// mirrors sv_time(): an ISO-8601 time ("2030-01-05T16:00:02.606471Z") as seconds
// since 1970, fraction kept; NaN for anything else (as R's NA).
export function svTime(x) {
  if (x === null || x === undefined || typeof x !== "string") return NaN;
  const m = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(\.\d+)?Z$/.exec(x);
  if (!m) return NaN;
  const base = utcSeconds(+m[1], +m[2], +m[3], +m[4], +m[5], +m[6]);
  return base + (m[7] ? Number(`0${m[7]}`) : 0);
}

// ---- Europe/London calendar parts of an instant ----------------------------

let londonFormat = null;
function londonParts(seconds) {
  if (londonFormat === null) {
    londonFormat = new Intl.DateTimeFormat("en-GB", {
      timeZone: "Europe/London", year: "numeric", month: "2-digit", day: "2-digit",
      hour: "2-digit", minute: "2-digit", hourCycle: "h23",
    });
  }
  const parts = {};
  for (const p of londonFormat.formatToParts(new Date(Math.floor(seconds) * 1000))) parts[p.type] = p.value;
  return parts;
}

// mirrors as.Date(x, tz = "Europe/London"): the London calendar date
export function londonDate(seconds) {
  if (isNA(seconds)) return null;
  const p = londonParts(seconds);
  return `${p.year}-${p.month}-${p.day}`;
}

// mirrors format(x, "%H:%M", tz = "Europe/London")
export function londonClock(seconds) {
  if (isNA(seconds)) return null;
  const p = londonParts(seconds);
  return `${p.hour}:${p.minute}`;
}

// ---- the match row ----------------------------------------------------------

export const MATCH_COLUMNS = [
  "match_id", "share_token", "played_at", "session_date", "start_time", "duration_min", "sport",
  "session_type", "is_doubles", "location", "surface", "outdoor", "latitude", "longitude",
  "opponent", "me_shots", "me_shots_in", "shots_in_pct", "me_run_mi", "opp_shots", "opp_run_mi",
  "fh_shots", "bh_shots", "fh_speed_mph", "bh_speed_mph", "serves", "serves_in", "returns", "winner",
];

const isTrue = (x) => x === true;

// mirrors sv_parse_match(): one tidy row for the player `me` (named exactly as
// in the payload). `match` and `stats` are the `data` elements of the payloads.
export function svParseMatch(match, stats, me, token = null) {
  const side = match.guest_name === me ? "guest" : "host";
  const opp = side === "guest" ? "host" : "guest";

  const started = svTime(match.started_at);
  if (match.recording_duration === undefined || match.recording_duration === null) {
    throw new Error("the match has no recording_duration");
  }
  const durMin = Math.floor(svNum(match.recording_duration) / 60);

  const rightHanded = isTrue(match[`${side}_right_handed`]);
  const sideStats = stats && stats[side];
  const s = (Array.isArray(sideStats) ? sideStats[0] : undefined) || {};
  const fhVel = rightHanded ? s.average_right_wing_velocity : s.average_left_wing_velocity;
  const bhVel = rightHanded ? s.average_left_wing_velocity : s.average_right_wing_velocity;
  const fhN = rightHanded ? s.right_wing : s.left_wing;
  const bhN = rightHanded ? s.left_wing : s.right_wing;

  const meShots = svNum(match[`${side}_shot_count`]);
  const meIn = svNum(match[`${side}_shot_in`]);
  const court = match.court && typeof match.court === "object" ? match.court : {};

  return {
    match_id: svNum(match.id),
    share_token: token,
    played_at: started,
    session_date: londonDate(started),
    start_time: londonClock(started),
    duration_min: durMin,
    sport: svChr(match.sport_type),
    session_type: svChr(match.session_type),
    is_doubles: isTrue(match.is_doubles),
    location: svChr(court.name),
    surface: svChr(court.surface),
    outdoor: isTrue(court.outdoor),
    latitude: svNum(match.latitude),
    longitude: svNum(match.longitude),
    opponent: svChr(match[`${opp}_name`]),
    me_shots: meShots,
    me_shots_in: meIn,
    shots_in_pct: isNA(meShots) || meShots === 0 ? NaN : rround((100 * meIn) / meShots, 1),
    me_run_mi: svNum(match[`${side}_distance_run`]),
    opp_shots: svNum(match[`${opp}_shot_count`]),
    opp_run_mi: svNum(match[`${opp}_distance_run`]),
    fh_shots: svNum(fhN),
    bh_shots: svNum(bhN),
    fh_speed_mph: svMph(fhVel),
    bh_speed_mph: svMph(bhVel),
    serves: svNum(s.serve),
    serves_in: svNum(s.serve_in),
    returns: svNum(s.first_return) + svNum(s.second_return),
    winner: svChr(match.winner),
  };
}

// ---- the shots ----------------------------------------------------------------

// mirrors the columns of sv_parse_shots()
export const SHOT_COLUMNS = [
  "match_id", "shot_id", "rally_id", "player", "started_at", "ended_at", "hit_wing", "hit_type",
  "spin_type", "shot_speed_mph", "shot_in", "hit_frame", "video_elapsed_sec", "hit_court_side",
  "bounce_court_side", "net_clearance_m", "bounce_location_long", "bounce_location_lat",
  "hit_x", "hit_y", "hit_z", "bounce_x", "bounce_y", "bounce_z",
  "hit_velocity_x", "hit_velocity_y", "hit_velocity_z",
];

// mirrors sv_shot_in(): TRUE unless the shot hit the net or bounced out
export function svShotIn(netType, bounceLong, bounceLat) {
  const nt = svChr(netType);
  const bl = svChr(bounceLong);
  const bla = svChr(bounceLat);
  const out = nt === "net" || bl === "out" || bla === "ad_out" || bla === "deuce_out";
  return !out;
}

// mirrors sv_parse_shots(): one row per shot, sorted by start time (stable,
// shots with no start time last).
export function svParseShots(shots) {
  const rows = shots.map((sh) => {
    const hitFrame = svNum(sh.hit_frame);
    return {
      match_id: svNum(sh.match_id),
      shot_id: svNum(sh.id),
      rally_id: svNum(sh.pid),
      player: svChr(sh.player),
      started_at: svTime(sh.started_at),
      ended_at: svTime(sh.ended_at),
      hit_wing: svChr(sh.hit_wing),
      hit_type: svChr(sh.hit_type),
      spin_type: svChr(sh.spin_type),
      shot_speed_mph: svSpeedMph(sh.hit_velocity),
      shot_in: svShotIn(sh.net_type, sh.bounce_location_long, sh.bounce_location_lat),
      hit_frame: hitFrame,
      video_elapsed_sec: hitFrame / svFps(),
      hit_court_side: svChr(sh.hit_court_side),
      bounce_court_side: svChr(sh.bounce_court_side),
      net_clearance_m: svComponent(sh.net_location, 3),
      bounce_location_long: svChr(sh.bounce_location_long),
      bounce_location_lat: svChr(sh.bounce_location_lat),
      hit_x: svComponent(sh.hit_location, 1),
      hit_y: svComponent(sh.hit_location, 2),
      hit_z: svComponent(sh.hit_location, 3),
      bounce_x: svComponent(sh.bounce_location, 1),
      bounce_y: svComponent(sh.bounce_location, 2),
      bounce_z: svComponent(sh.bounce_location, 3),
      hit_velocity_x: svComponent(sh.hit_velocity, 1),
      hit_velocity_y: svComponent(sh.hit_velocity, 2),
      hit_velocity_z: svComponent(sh.hit_velocity, 3),
    };
  });
  return orderBy(rows, (r) => r.started_at);
}
