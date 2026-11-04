# Performance review

The site has bounded, event-driven rendering, but it is not certified as
optimal on all devices. The approximately 190 MiB terrain bundle is an installed
payload, not an initial page download: only visible terrain and spatial overlay
chunks are requested when the Map panel opens.

## Existing safeguards

- No framework runtime or external icon scripts.
- Lazy map modules and assets; four concurrent resource requests, a 192-entry
  cache, cached lower-resolution imagery during zoom, and no idle render loop.
- Coalesced canvas rendering, clustered overlays and a bounded location list.
- Source validation and draft saves are debounced. Undo history and Wowhead
  lookup results are bounded; reference requests are explicit, not per marker.
- Collapse cancels requests; stale document/view responses cannot redraw old data.

## Confirmed work removed

Selecting a step previously reparsed the unchanged document, causing the map
to rebuild waypoint options and invalidate requests. The editor now retains its
parsed document until source or filename changes, including adopting the result
of live form edits. A production-UI regression first reproduced the rebuild and
now verifies stable waypoint nodes during navigation, with invalidation on edits.

Layer toggles use the next render's visible-resource set instead of cancelling
every in-flight tile. Creature/object circles are code-drawn and add no downloads.

## Measure before larger changes

- Large source/form edits still encode document text and reparse the selected
  guide; source editing scans the container. Selection still refreshes lists.
- Draft persistence uses synchronous browser storage; very large drafts can
  exceed browser quota. Downloaded backups remain important.
- During pan/zoom, visible overlay filtering and clustering run on the main
  thread. Dense regions and first-time JSON parsing need low-end-device profiling.
- Cache limits count entries, not decoded bytes. A large JSON chunk is not the
  same memory cost as a texture; do not infer a fixed heap cap from entry count.
- Static-host transfer/compression and real network latency require hosted
  measurements. Loopback tests cannot establish public-site performance.

The regressions check bounded requests, no idle rendering, stable selection,
source-preserving drag/Undo and native terrain at high DPI. They demonstrate
correctness and eliminated repeated work, not a universal frame-rate guarantee.
