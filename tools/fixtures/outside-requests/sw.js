// A service worker that requests another origin (never resolves: .invalid).
self.addEventListener("install", function () {
  fetch("http://outside-sw.invalid/from-service-worker").catch(function () {});
  self.skipWaiting();
});
self.addEventListener("activate", function (event) {
  event.waitUntil(
    fetch("http://outside-sw.invalid/from-service-worker-activate").catch(function () {})
  );
});
