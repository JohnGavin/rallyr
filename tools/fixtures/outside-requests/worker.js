// A dedicated worker that requests another origin (never resolves: .invalid).
fetch("http://outside-worker.invalid/from-worker").catch(function () {});
