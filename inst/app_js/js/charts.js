// The five charts as inline SVG text. They show the data of plotdata.js (the
// same data the R package's ggplot charts show); the look is plain on purpose.
// Colours come from CSS classes (app.css), so a chart follows light and dark
// mode, and the page's content-security policy needs no inline style.
// Each function returns a string holding one <svg> element.

import { dayText, seededRandom } from "./util.js";
import {
  trendData, rallyLengthData, strokeSpeedData, netClearanceData, gapDistributionData,
} from "./plotdata.js";

let W = 720; // the width of the chart being drawn (set by each chart function)
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

// mirrors format(date, "%d %b %Y")
export const formatDate = (iso) => `${iso.slice(8, 10)} ${MONTHS[Number(iso.slice(5, 7)) - 1]} ${iso.slice(0, 4)}`;

const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
const num = (x) => (Math.round(x * 100) / 100).toString();

// round tick positions covering [lo, hi], about `n` of them (as pretty())
export function niceTicks(lo, hi, n = 5) {
  if (!(hi > lo)) return [lo];
  const raw = (hi - lo) / n;
  const mag = 10 ** Math.floor(Math.log10(raw));
  const norm = raw / mag;
  const step = (norm <= 1 ? 1 : norm <= 2 ? 2 : norm <= 5 ? 5 : 10) * mag;
  const out = [];
  for (let t = Math.ceil(lo / step - 1e-9) * step; t <= hi + step * 1e-9; t += step) out.push(Number(t.toPrecision(12)));
  return out;
}

// a linear scale from data [d0, d1] to pixels [r0, r1]
const scale = (d0, d1, r0, r1) => (v) => (d1 === d0 ? (r0 + r1) / 2 : r0 + ((v - d0) / (d1 - d0)) * (r1 - r0));

// the data range widened by 5% each side (ggplot's default expansion)
function expand(lo, hi) {
  if (hi === lo) return [lo - 1, hi + 1];
  const pad = (hi - lo) * 0.05;
  return [lo - pad, hi + pad];
}

function svg(height, label, body) {
  return `<svg class="chart" viewBox="0 0 ${W} ${height}" role="img" aria-label="${esc(label)}">${body}</svg>`;
}

const title = (t) => `<text class="chart-title" x="8" y="20">${esc(t)}</text>`;

// the chart that has nothing to show (R: plot_empty())
function emptyChart(t, message) {
  return svg(160, `${t}: ${message}`, `${title(t)}<text class="chart-note" x="${W / 2}" y="90" text-anchor="middle">${esc(message)}</text>`);
}

const caption = (text, y) => (text ? `<text class="chart-caption" x="8" y="${y}">${esc(text)}</text>` : "");

// grid line and label of an x axis along the bottom of a plot area
function xAxis(ticks, sx, top, bottom, label) {
  return ticks.map((t) => `<line class="gridline" x1="${num(sx(t))}" x2="${num(sx(t))}" y1="${top}" y2="${bottom}"/><text class="tick" x="${num(sx(t))}" y="${bottom + 15}" text-anchor="middle">${esc(label(t))}</text>`).join("");
}

// rows of a discrete axis (the first row at the bottom, as ggplot draws it)
function rowAxis(labels, left, top, rowH, plotRight) {
  return labels.map((l, i) => {
    const y = top + (labels.length - 1 - i) * rowH + rowH / 2;
    return `<line class="gridline" x1="${left}" x2="${plotRight}" y1="${num(y)}" y2="${num(y)}"/><text class="tick" x="${left - 8}" y="${num(y + 4)}" text-anchor="end">${esc(l)}</text>`;
  }).join("");
}

// ---- session trends ------------------------------------------------------------

// mirrors plot_session_trend()
export function chartSessionTrend(derived, { dateRange = null, newestLeft = false, width = 720 } = {}) {
  W = width;
  const d = trendData(derived, { dateRange });
  if (d.empty) return emptyChart(d.title, d.empty);
  const left = 70;
  const right = W - 20;
  const panelH = 100;
  const gap = 36;
  const top0 = 34;
  const days = d.panels.flatMap((p) => p.points.map((q) => q.day));
  const [x0, x1] = expand(Math.min(...days), Math.max(...days));
  const sx0 = scale(x0, x1, left, right);
  const sx = newestLeft ? (v) => sx0(x0 + x1 - v) : sx0;
  const height = top0 + d.panels.length * (panelH + gap) + 24;
  let body = title(d.title);
  d.panels.forEach((p, i) => {
    const top = top0 + gap + i * (panelH + gap) - 14;
    const bottom = top + panelH;
    const vals = p.points.map((q) => q.value);
    const [y0, y1] = expand(Math.min(...vals), Math.max(...vals));
    const sy = scale(y0, y1, bottom, top);
    body += `<text class="strip" x="${left}" y="${top - 8}">${esc(p.name)}</text>`;
    const yt = niceTicks(Math.min(...vals), Math.max(...vals), 3);
    body += yt.map((t) => `<line class="gridline" x1="${left}" x2="${right}" y1="${num(sy(t))}" y2="${num(sy(t))}"/><text class="tick" x="${left - 6}" y="${num(sy(t) + 4)}" text-anchor="end">${t}</text>`).join("");
    const pts = [...p.points].sort((a, b) => a.day - b.day);
    body += `<polyline class="line-me" fill="none" points="${pts.map((q) => `${num(sx(q.day))},${num(sy(q.value))}`).join(" ")}"/>`;
    body += pts.map((q) => `<circle class="pt-me" r="3.5" cx="${num(sx(q.day))}" cy="${num(sy(q.value))}"><title>${esc(formatDate(q.date))}: ${num(q.value)}</title></circle>`).join("");
    if (i === d.panels.length - 1) {
      const lo = Math.ceil(Math.min(x0, x1));
      const ticks = niceTicks(lo, Math.floor(x1), 5).map(Math.round);
      body += xAxis([...new Set(ticks)], sx, bottom, bottom, (t) => formatDate(dayText(t)));
    }
  });
  return svg(height, d.title, body);
}

// ---- strips and boxes by drill ---------------------------------------------------

const rowGeometry = (n) => ({ left: 150, right: W - 20, top: 34, rowH: 44, height: 34 + n * 44 + 70 });

// mirrors plot_rally_length(): a point per rally, the median as a diamond
export function chartRallyLength(derived, { width = 480 } = {}) {
  W = width;
  const d = rallyLengthData(derived);
  if (d.empty) return emptyChart(d.title, d.empty);
  const g = rowGeometry(d.drills.length);
  const all = d.drills.flatMap((r) => r.values);
  const [x0, x1] = expand(Math.min(...all), Math.max(...all));
  const sx = scale(x0, x1, g.left, g.right);
  const step = Math.max(1, Math.ceil((x1 - x0) / 8));
  const ticks = [];
  for (let t = Math.ceil(x0); t <= Math.floor(x1); t += step) ticks.push(t);
  const plotBottom = g.top + d.drills.length * g.rowH;
  const rand = seededRandom(7);
  let body = title(d.title) + rowAxis(d.drills.map((r) => r.drill), g.left, g.top, g.rowH, g.right);
  body += xAxis(ticks, sx, g.top, plotBottom, String);
  d.drills.forEach((r, i) => {
    const cy = g.top + (d.drills.length - 1 - i) * g.rowH + g.rowH / 2;
    body += r.values.map((v) => `<circle class="pt-me soft" r="3" cx="${num(sx(v))}" cy="${num(cy + (rand() * 2 - 1) * 0.18 * g.rowH)}"/>`).join("");
    const mx = sx(r.median);
    body += `<path class="diamond" d="M${num(mx)} ${num(cy - 7)} L${num(mx + 7)} ${num(cy)} L${num(mx)} ${num(cy + 7)} L${num(mx - 7)} ${num(cy)} Z"><title>${esc(r.drill)}: median ${num(r.median)}</title></path>`;
  });
  body += `<text class="axis-label" x="${(g.left + g.right) / 2}" y="${plotBottom + 36}" text-anchor="middle">${esc(d.xLabel)}</text>`;
  body += caption(d.caption, plotBottom + 56);
  return svg(g.height, d.title, body);
}

// mirrors plot_stroke_speed(): a box per drill (quartiles, whiskers, outliers)
export function chartStrokeSpeed(derived, { width = 480 } = {}) {
  W = width;
  const d = strokeSpeedData(derived);
  if (d.empty) return emptyChart(d.title, d.empty);
  const g = rowGeometry(d.drills.length);
  const lo = Math.min(...d.drills.map((r) => Math.min(r.ymin, ...r.outliers)));
  const hi = Math.max(...d.drills.map((r) => Math.max(r.ymax, ...r.outliers)));
  const [x0, x1] = expand(lo, hi);
  const sx = scale(x0, x1, g.left, g.right);
  const plotBottom = g.top + d.drills.length * g.rowH;
  let body = title(d.title) + rowAxis(d.drills.map((r) => r.drill), g.left, g.top, g.rowH, g.right);
  body += xAxis(niceTicks(x0, x1, 6), sx, g.top, plotBottom, String);
  d.drills.forEach((r, i) => {
    const cy = g.top + (d.drills.length - 1 - i) * g.rowH + g.rowH / 2;
    const h = g.rowH * 0.375;
    body += `<g><title>${esc(r.drill)}: median ${num(r.middle)} mph, middle half ${num(r.lower)} to ${num(r.upper)}</title>`;
    body += `<line class="box" x1="${num(sx(r.ymin))}" x2="${num(sx(r.lower))}" y1="${num(cy)}" y2="${num(cy)}"/>`;
    body += `<line class="box" x1="${num(sx(r.upper))}" x2="${num(sx(r.ymax))}" y1="${num(cy)}" y2="${num(cy)}"/>`;
    body += `<rect class="box" fill="none" x="${num(sx(r.lower))}" y="${num(cy - h)}" width="${num(sx(r.upper) - sx(r.lower))}" height="${num(2 * h)}"/>`;
    body += `<line class="box thick" x1="${num(sx(r.middle))}" x2="${num(sx(r.middle))}" y1="${num(cy - h)}" y2="${num(cy + h)}"/></g>`;
    body += r.outliers.map((v) => `<circle class="pt-me soft" r="2" cx="${num(sx(v))}" cy="${num(cy)}"/>`).join("");
  });
  body += `<text class="axis-label" x="${(g.left + g.right) / 2}" y="${plotBottom + 36}" text-anchor="middle">${esc(d.xLabel)}</text>`;
  body += caption(d.caption, plotBottom + 56);
  return svg(g.height, d.title, body);
}

// mirrors plot_net_clearance(): the median of each session, you and the feeder
export function chartNetClearance(derived, { width = 480 } = {}) {
  W = width;
  const d = netClearanceData(derived);
  if (d.empty) return emptyChart(d.title, d.empty);
  const g = rowGeometry(d.drills.length);
  const [x0, x1] = expand(Math.min(...d.points.map((p) => p.x)), Math.max(...d.points.map((p) => p.x)));
  const sx = scale(x0, x1, g.left, g.right);
  const plotBottom = g.top + d.drills.length * g.rowH;
  const rand = seededRandom(11);
  let body = title(d.title) + rowAxis(d.drills.map((r) => r), g.left, g.top, g.rowH, g.right);
  body += xAxis(niceTicks(x0, x1, 6), sx, g.top, plotBottom, String);
  for (const p of d.points) {
    const row = d.drills.indexOf(p.drill);
    const cy = g.top + (d.drills.length - 1 - row) * g.rowH + g.rowH / 2 + (rand() * 2 - 1) * 0.15 * g.rowH;
    const cx = sx(p.x);
    body += p.side === "You"
      ? `<circle class="pt-me" r="4" cx="${num(cx)}" cy="${num(cy)}"><title>You, ${esc(p.drill)}: ${num(p.x)} m</title></circle>`
      : `<path class="pt-feeder" d="M${num(cx)} ${num(cy - 5)} L${num(cx + 5)} ${num(cy + 4)} L${num(cx - 5)} ${num(cy + 4)} Z"><title>Feeder, ${esc(p.drill)}: ${num(p.x)} m</title></path>`;
  }
  const ly = plotBottom + 52;
  body += `<text class="axis-label" x="${(g.left + g.right) / 2}" y="${plotBottom + 34}" text-anchor="middle">${esc(d.xLabel)}</text>`;
  body += `<circle class="pt-me" r="4" cx="${W / 2 - 60}" cy="${ly - 4}"/><text class="tick" x="${W / 2 - 50}" y="${ly}">You</text>`;
  body += `<path class="pt-feeder" d="M${W / 2 + 20} ${ly - 9} L${W / 2 + 25} ${ly} L${W / 2 + 15} ${ly} Z"/><text class="tick" x="${W / 2 + 32}" y="${ly}">Feeder</text>`;
  body += caption(d.caption, plotBottom + 74);
  return svg(g.height + 18, d.title, body);
}

// mirrors plot_gap_distribution(): a histogram of the pauses, the rally-split
// pauses as dashed lines
export function chartGapDistribution(derived, { width = 480 } = {}) {
  W = width;
  const d = gapDistributionData(derived);
  if (d.empty) return emptyChart(d.title, d.empty);
  const left = 60;
  const right = W - 20;
  const top = 34;
  const bottom = 250;
  const xs = d.bins.length > 0 ? [d.bins[0].xmin, d.bins[d.bins.length - 1].xmax] : [0, 10];
  const [x0, x1] = expand(Math.min(xs[0], ...d.marks.map((m) => m.x)), Math.max(xs[1], ...d.marks.map((m) => m.x)));
  const sx = scale(x0, x1, left, right);
  const maxCount = Math.max(1, ...d.bins.map((b) => b.count));
  const sy = scale(0, maxCount * 1.05, bottom, top);
  let body = title(d.title);
  body += niceTicks(0, maxCount, 5).map((t) => `<line class="gridline" x1="${left}" x2="${right}" y1="${num(sy(t))}" y2="${num(sy(t))}"/><text class="tick" x="${left - 6}" y="${num(sy(t) + 4)}" text-anchor="end">${t}</text>`).join("");
  body += xAxis(niceTicks(0, x1, 6).filter((t) => t >= x0), sx, top, bottom, String);
  body += d.bins.filter((b) => b.count > 0).map((b) => `<rect class="bar" x="${num(sx(b.xmin))}" y="${num(sy(b.count))}" width="${num(sx(b.xmax) - sx(b.xmin))}" height="${num(bottom - sy(b.count))}"><title>${num(b.xmin)} to ${num(b.xmax)} s: ${b.count}</title></rect>`).join("");
  for (const m of d.marks) {
    body += `<line class="mark" x1="${num(sx(m.x))}" x2="${num(sx(m.x))}" y1="${top}" y2="${bottom}"/>`;
    body += `<text class="mark-label" transform="translate(${num(sx(m.x) - 5)} ${top + 6}) rotate(-90)" text-anchor="end">${esc(`${m.label}: ${m.x} s`)}</text>`;
  }
  body += `<text class="axis-label" x="${(left + right) / 2}" y="${bottom + 36}" text-anchor="middle">${esc(d.xLabel)}</text>`;
  body += `<text class="axis-label" transform="translate(16 ${(top + bottom) / 2}) rotate(-90)" text-anchor="middle">${esc(d.yLabel)}</text>`;
  body += caption(d.caption, bottom + 58);
  return svg(bottom + 70, d.title, body);
}
