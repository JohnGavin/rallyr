// The numbers each chart is drawn from, against the numbers of the R package's
// ggplot charts (read back out of the plot objects, see
// data-raw/js_parity_fixtures.R), and a check that every chart draws.
// Two bundles: the synthetic sample, and the one built to reach the rules the
// sample does not (it has box-plot outliers, for one).

import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import assert from "node:assert/strict";
import { readFixture, compareVector, load, fixtureDir } from "./helpers.mjs";
import { bundleJs, sample, run } from "./parity_lib.mjs";

const plotdata = await load("plotdata.js");
const charts = await load("charts.js");

const stressBundle = await bundleJs.bundleRead(new Uint8Array(fs.readFileSync(path.join(fixtureDir, "stress_bundle.json.gz"))), "stress");
const sets = [
  { label: "the sample", fixture: readFixture("sample.json.gz"), derived: run(sample, "Sample Player").derived },
  { label: "the stress bundle", fixture: readFixture("stress.json.gz"), derived: run(stressBundle, "Sample Player", "skip").derived },
];
const want = sets[0].fixture.plots;
const derived = sets[0].derived;

for (const { label, fixture, derived: d } of sets) {
  const w = fixture.plots;

  test(`${label}: session trends have the same points in the same panels, with and without a date range`, () => {
    for (const [name, expected, range] of [["all sessions", w.trend, null], ["a date range", w.trend_range, w.trend_range.range]]) {
      const t = plotdata.trendData(d, { dateRange: range });
      const panel = t.panels.flatMap((p) => p.points.map(() => p.name));
      assert.deepEqual(panel, expected.panel, name);
      assert.deepEqual(compareVector(`${name} x`, t.panels.flatMap((p) => p.points.map((q) => q.day)), expected.x), []);
      assert.deepEqual(compareVector(`${name} y`, t.panels.flatMap((p) => p.points.map((q) => q.value)), expected.y), []);
    }
    assert.ok(w.trend_range.x.length < w.trend.x.length, "the date range must leave some sessions out");
    assert.ok(w.trend_range.x.length > 0);
  });

  test(`${label}: rally length has the drills in the same order, every rally's length and the medians`, () => {
    const r = plotdata.rallyLengthData(d);
    assert.deepEqual(r.drills.map((x) => x.drill), w.rally.drills);
    r.drills.forEach((x, i) => {
      assert.deepEqual(compareVector(x.drill, [...x.values].sort((a, b) => a - b), w.rally.values[i]), []);
    });
    assert.deepEqual(compareVector("medians", r.drills.map((x) => x.median), w.rally.medians), []);
  });

  test(`${label}: stroke speed has the drills in the same order and the same boxes`, () => {
    const s = plotdata.strokeSpeedData(d);
    assert.deepEqual(s.drills.map((x) => x.drill), w.speed.drills);
    for (const [mine, theirs] of [["ymin", "min"], ["lower", "lower"], ["middle", "middle"], ["upper", "upper"], ["ymax", "max"]]) {
      assert.deepEqual(compareVector(theirs, s.drills.map((x) => x[mine]), w.speed[theirs]), []);
    }
    assert.deepEqual(s.drills.map((x) => x.outliers.length), w.speed.n_outliers);
  });

  test(`${label}: net clearance has the same points for you and the feeder in each drill`, () => {
    const n = plotdata.netClearanceData(d);
    assert.deepEqual(n.drills, w.net.drills);
    n.drills.forEach((drill, i) => {
      const side = (s) => n.points.filter((p) => p.drill === drill && p.side === s).map((p) => p.x).sort((a, b) => a - b);
      assert.deepEqual(compareVector(`${drill} you`, side("You"), [].concat(w.net.points[i].you)), []);
      assert.deepEqual(compareVector(`${drill} feeder`, side("Feeder"), [].concat(w.net.points[i].feeder)), []);
    });
  });

  test(`${label}: the pauses between strokes have the same histogram bins and rally-split marks`, () => {
    const g = plotdata.gapDistributionData(d);
    assert.deepEqual(compareVector("xmin", g.bins.map((b) => b.xmin), w.gap.xmin), []);
    assert.deepEqual(compareVector("xmax", g.bins.map((b) => b.xmax), w.gap.xmax), []);
    assert.deepEqual(g.bins.map((b) => b.count), w.gap.count);
    assert.deepEqual(g.marks.map((m) => m.x), w.gap.mark_x);
    assert.deepEqual(g.marks.map((m) => m.label), w.gap.mark_label);
    assert.equal(g.nBeyond, w.gap.n_beyond);
    assert.equal(g.bins.reduce((n, b) => n + b.count, 0) + g.nBeyond, w.gap.n_gaps);
  });
}

test("the stress bundle has box-plot outliers and the sample has none, so both cases are compared", () => {
  assert.ok(sets[1].fixture.plots.speed.n_outliers.some((n) => n > 0));
  assert.ok(sets[0].fixture.plots.speed.n_outliers.every((n) => n === 0));
});

test("histogram bins close on the right, as ggplot's do: a pause of exactly 1 s is in the bin below 1", () => {
  const bins = plotdata.histogramBins([0, 0.25, 1, 1.0000000001, 1.2, 9.75, 10]);
  assert.equal(bins[0].count, 2);          // 0 and 0.25
  assert.equal(bins[3].count, 2);          // 1 and 1.0000000001 (inside the fuzz)
  assert.equal(bins[3].xmax, 1);
  assert.equal(bins[bins.length - 1].count, 1);
});

test("every chart is drawn as an SVG, and says plainly when there is nothing to show", () => {
  for (const { derived: d } of sets) {
    const all = [
      charts.chartSessionTrend(d), charts.chartSessionTrend(d, { newestLeft: true }),
      charts.chartRallyLength(d), charts.chartStrokeSpeed(d), charts.chartNetClearance(d), charts.chartGapDistribution(d),
    ];
    for (const s of all) {
      assert.match(s, /^<svg class="chart" viewBox="0 0 (720|480) \d+"/);
      assert.match(s, /<\/svg>$/);
      assert.doesNotMatch(s, /NaN|undefined|Infinity/);
      assert.doesNotMatch(s, /style=/, "inline style would break the page's content-security policy");
    }
    assert.match(all[2], /forehand cross court/);
    assert.match(all[5], /cross court: 3 s/);
    assert.notEqual(all[0], all[1]);   // reversing the axis changes the picture, not the data
  }
  const one = { ...derived, session_metrics: null, corrected_rallies: null, net_clearance: [], tables: { ...derived.tables, shot_detail: [] } };
  assert.match(charts.chartSessionTrend(one), /A trend needs at least two sessions\./);
  assert.match(charts.chartRallyLength(one), /No rallies in the data\./);
  assert.match(charts.chartStrokeSpeed(one), /No stroke speeds in the data\./);
  assert.match(charts.chartNetClearance(one), /No net-clearance values in the data\./);
  assert.match(charts.chartGapDistribution(one), /No within-rally pauses in the data\./);
  assert.match(charts.chartSessionTrend(derived, { dateRange: ["1999-01-01", "1999-02-01"] }), /No sessions in this date range\./);
});

test("the trend with the newest session on the left puts the last date first, and the dates read the same", () => {
  const labels = (s) => [...s.matchAll(/class="tick" x="([\d.]+)" y="[\d.]+" text-anchor="middle">(\d\d \w{3} \d{4})</g)]
    .map((m) => [Number(m[1]), m[2]]).sort((p, q) => p[0] - q[0]).map((p) => p[1]);
  const a = labels(charts.chartSessionTrend(derived));
  const b = labels(charts.chartSessionTrend(derived, { newestLeft: true }));
  assert.ok(a.length >= 3);
  assert.equal(a.length, b.length);
  const day = (t) => Date.parse(`${t} UTC`);
  assert.ok(day(a[0]) < day(a[a.length - 1]), "oldest on the left by default");
  assert.ok(day(b[0]) > day(b[b.length - 1]), "newest on the left when asked");
});

test("a date range that leaves out sessions draws fewer points, all inside the range", () => {
  const t = plotdata.trendData(derived, { dateRange: want.trend_range.range });
  assert.ok(t.panels[0].points.length < derived.sessions.length);
  assert.ok(t.panels[0].points.every((p) => p.date >= want.trend_range.range[0] && p.date <= want.trend_range.range[1]));
});
