// Small helpers that give plain JavaScript the few R behaviours the port relies
// on: missing values (NA), round(), mean/median/sd, rank, stable ordering and
// R's way of writing a whole number as text.
//
// Missing values: a missing number is NaN, a missing string is null, and
// `isNA()` is true for both (and for undefined). R keeps NA and NaN apart; the
// derived tables never need the difference, and both are written as null.

export const isNA = (x) => x === null || x === undefined || (typeof x === "number" && Number.isNaN(x));

// mirrors is.na() over a vector
export const anyNA = (xs) => xs.some(isNA);

// The numbers of a vector that are not missing (as `x[!is.na(x)]`).
export const present = (xs) => xs.filter((x) => !isNA(x));

// mirrors round(x, digits) of R >= 4.0.0: of the two candidates around x
// (rounded down and up at `digits`), take the nearer one; on an exact tie take
// the one with an even last digit. Math.round() rounds ties up instead.
export function rround(x, digits = 0) {
  if (isNA(x) || !Number.isFinite(x)) return x;
  const p = 10 ** digits;
  const scaled = x * p;
  const lo = Math.floor(scaled);
  const hi = Math.ceil(scaled);
  if (lo === hi) return lo / p;
  const down = lo / p;
  const up = hi / p;
  const dDown = x - down;
  const dUp = up - x;
  if (dDown < dUp) return down;
  if (dUp < dDown) return up;
  return lo % 2 === 0 ? down : up;
}

// Neumaier-compensated sum: the double result is the one R gets by adding in
// long double and rounding once, to within a unit in the last place.
export function rsum(xs) {
  let s = 0;
  let c = 0;
  for (const x of xs) {
    const t = s + x;
    if (Math.abs(s) >= Math.abs(x)) c += s - t + x;
    else c += x - t + s;
    s = t;
  }
  return s + c;
}

// mirrors mean(x) (no NA handling here: callers filter, as with na.rm = TRUE).
// R refines the mean with a second pass; so does this.
export function rmean(xs) {
  const n = xs.length;
  if (n === 0) return NaN;
  const m = rsum(xs) / n;
  if (!Number.isFinite(m)) return m;
  return m + rsum(xs.map((x) => x - m)) / n;
}

// mirrors sd(x): sample standard deviation (n - 1), NaN for fewer than two.
export function rsd(xs) {
  const n = xs.length;
  if (n < 2) return NaN;
  const m = rmean(xs);
  return Math.sqrt(rsum(xs.map((x) => (x - m) ** 2)) / (n - 1));
}

// mirrors median(x, na.rm = TRUE); NaN (NA) for no values.
export function rmedian(xs) {
  const v = present(xs).sort((a, b) => a - b);
  const n = v.length;
  if (n === 0) return NaN;
  const h = Math.floor(n / 2);
  return n % 2 === 1 ? v[h] : (v[h - 1] + v[h]) / 2;
}

// mirrors quantile(x, probs, type = 7) for a sorted, NA-free vector.
export function quantile7(sorted, p) {
  const n = sorted.length;
  const index = 1 + Math.max(n - 1, 0) * p;
  const lo = Math.floor(index);
  const hi = Math.ceil(index);
  let q = sorted[lo - 1];
  const h = index - lo;
  if (index > lo && sorted[hi - 1] !== q) q = (1 - h) * q + h * sorted[hi - 1];
  return q;
}

// mirrors rank(x, ties.method = "average") for an NA-free vector.
export function rankAverage(xs) {
  const order = xs.map((x, i) => i).sort((a, b) => xs[a] - xs[b] || a - b);
  const out = new Array(xs.length);
  let i = 0;
  while (i < order.length) {
    let j = i;
    while (j + 1 < order.length && xs[order[j + 1]] === xs[order[i]]) j += 1;
    const avg = (i + j) / 2 + 1;
    for (let k = i; k <= j; k += 1) out[order[k]] = avg;
    i = j + 1;
  }
  return out;
}

// mirrors rank(-score, ties.method = "first"): 1 = the largest score, ties in
// the order they appear.
export function rankFirstDescending(xs) {
  const order = xs.map((x, i) => i).sort((a, b) => xs[b] - xs[a] || a - b);
  const out = new Array(xs.length);
  order.forEach((idx, r) => { out[idx] = r + 1; });
  return out;
}

// A stable sort by a numeric or string key, missing keys last (as order()).
export function orderBy(rows, key) {
  const idx = rows.map((r, i) => i);
  idx.sort((a, b) => {
    const ka = key(rows[a]);
    const kb = key(rows[b]);
    const na = isNA(ka);
    const nb = isNA(kb);
    if (na || nb) return na === nb ? a - b : na ? 1 : -1;
    if (ka < kb) return -1;
    if (ka > kb) return 1;
    return a - b;
  });
  return idx.map((i) => rows[i]);
}

// mirrors as.character() of a number: a whole number is written in full unless
// the scientific form is shorter (100000 -> "1e+05", 123456 -> "123456").
export function numToString(x) {
  if (isNA(x)) return "NA";
  if (!Number.isFinite(x)) return x > 0 ? "Inf" : "-Inf";
  if (Number.isInteger(x)) {
    const fixed = String(Math.abs(x) < 1e21 ? BigInt(x) : x);
    const digits = fixed.replace("-", "");
    const sig = digits.replace(/0+$/, "");
    const exp = digits.length - 1;
    const mant = sig.length > 1 ? `${sig[0]}.${sig.slice(1)}` : sig;
    const sci = `${x < 0 ? "-" : ""}${mant}e+${String(exp).padStart(2, "0")}`;
    return sci.length < fixed.length ? sci : fixed;
  }
  return String(x);
}

// mirrors format(as.numeric(id), scientific = FALSE, trim = TRUE)
export function plainNumber(x) {
  if (Number.isInteger(x) && Math.abs(x) >= 1e15) return String(BigInt(x));
  return String(x);
}

// Seconds since 1970 of a UTC date and clock time, or NaN when the date does
// not exist. As R's strptime reads a time: seconds go up to 61 (a leap second)
// and 24:00:00 is accepted (and means midnight of the next day).
export function utcSeconds(y, mo, d, h, mi, s) {
  const day = new Date(Date.UTC(y, mo - 1, d));
  if (day.getUTCFullYear() !== y || day.getUTCMonth() !== mo - 1 || day.getUTCDate() !== d) return NaN;
  const clockOk = (h <= 23 && mi <= 59 && s <= 61) || (h === 24 && mi === 0 && s === 0);
  return clockOk ? day.getTime() / 1000 + h * 3600 + mi * 60 + s : NaN;
}

// Days since 1970-01-01 of a "YYYY-MM-DD" date text.
export function dayNumber(iso) {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso);
  if (!m) return NaN;
  return Date.UTC(+m[1], +m[2] - 1, +m[3]) / 86400000;
}

// The inverse: a day number as "YYYY-MM-DD".
export function dayText(n) {
  return new Date(n * 86400000).toISOString().slice(0, 10);
}

// A deterministic pseudo-random sequence (so a chart looks the same every time
// it is drawn; ggplot's jitter is random, the data shown are the same).
export function seededRandom(seed) {
  let s = seed >>> 0;
  return () => {
    s = (s + 0x6d2b79f5) >>> 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Column-wise view of a table of rows, in the given column order: what the
// parity tests compare against the tibbles R writes.
export function toColumns(rows, names) {
  const cols = {};
  for (const n of names) cols[n] = rows.map((r) => (isNA(r[n]) ? null : r[n]));
  return { names: [...names], n: rows.length, cols };
}
