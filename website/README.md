# RXPGuides Tools — local website

Dependency-free HTML, CSS and JavaScript. No build step, npm packages, remote
assets, uploads, hosting registration or automatic publication. Optional live
reference lookups contact Wowhead's WotLK detail endpoint.

See [Interior references](INTERIORS.md) for dungeon/raid imagery, entity actions,
coverage limits and reproducible generation.

## Preview

From the repository root, with Python 3.12 or newer:

```text
py -3 website/tools/serve.py
```

Open `http://127.0.0.1:8765/`. Stop the server with Ctrl+C. On systems where the
Python launcher is absent, use `python3` instead of `py -3`.

To test a GitHub Pages-style subpath:

```text
py -3 website/tools/serve.py --port 8766 --prefix /RXPGuides/
```

Open `http://127.0.0.1:8766/RXPGuides/`. The server binds only to loopback and
serves only this website. Directory listings, traversal, symlinks/junctions and
tool-script requests are rejected. It has no upload endpoint.

## Tests

```text
py -3 website/tools/check.py
py -3 website/tools/browser_tests.py --browser <installed-Chrome-or-Edge-executable>
```

The browser runner uses an existing Chromium browser, an isolated temporary
profile and Python's standard library. It never downloads a browser or driver.
It runs the model and production-UI tests at root and repository-prefix URLs.
Successful scratch outputs are removed; failure evidence stays under `build/`.
It also checks downloaded guide source with the production importer and Lua 5.1
parser fixtures when `--lua-command` is supplied. Exported text is never executed.

For manual browser tests, open `tests/` on the local server. Use the numbered
[acceptance checklist](CHECKLIST.md) before treating the interface as accepted.

## Reference lookup

The editor uses Wowhead WotLK, not the bundled AzerothCore snapshot. IDs and
WotLK links load via the public CORS-enabled `nether.wowhead.com/wotlk/tooltip/`
endpoint. Name search opens Wowhead because its search endpoint does not grant
cross-origin access. There is no proxy or external script. Failures leave manual
editing available. Only entity type/ID is sent for lookup, never guide source;
name queries are sent only when opening the external search link.

The 32-entry session cache stores names and inert tooltip text, not remote HTML,
images or objective-index mappings. Tests mock responses and do not contact
Wowhead. Live availability must be checked separately.
Use `browser_tests.py --browser <executable> --live-wowhead` to explicitly check
four public IDs in the actual editor origin, at both hosting prefixes. This
opt-in test requires internet access; ordinary tests remain entirely local.

## Historical offline data regeneration

```text
py -3 website/tools/extract_data.py --acore-source <authorized-checkout> --output <new-empty-directory>
```

This optional development fixture is no longer the editor's lookup source.
Only the local source checkout is read; SQL is never executed. Compare two fresh
generations and review provenance before replacing `data/`. The extractor uses
the repository's existing SQL reader but does not change its pinned Hardcore
fixtures. Base SQL is not the fully updated running world database.

Outputs contain names/IDs and selected quest facts, not account tables, full
dialogue, secrets, local paths or raw dumps. Source hashes bind the reference
snapshot; catalogue hashes bind directive/map inventories to the addon. Dataset
license notices are retained in `data/`. Website code follows the repository's
GPL-3.0 license; AzerothCore-derived data retains its separate source notice.

## Local terrain and spawn overlays

The editor's Map panel is initially collapsed. It loads static local tiles and
spatial overlay chunks only when opened. Map state is not stored with drafts.
All four continents are supported; expansion-race areas are placed on Kalimdor
and Eastern Kingdoms using the same transforms as the project's HBD335 adapter.
Physical server coordinates, native terrain pixels and zone percentages are
separate domains. WotLK `WorldMapArea.dbc` supplies outdoor zone bounds; canonical
tokens come from this repository. Ambiguous/floor forms and `StormwindClassic` /
`EPLClassic` remain source-only instead of being plotted as Wrath percentages.

The [Ghostlands edge cleanup](TERRAIN_CLEANUP.md) hides reviewed placeholder
pixels with a separate derived layer, without changing terrain coordinates.

Alliance and Horde checkboxes filter affiliated locations and quest actions.
Both start enabled; shared/unknown locations and guide waypoints remain visible.
These are snapshot affiliations, not live reputation or quest eligibility.
Faction filtering runs before clustering and does not refetch terrain or chunks.

`tools/fixtures/overlay-factions.json` pins WotLK faction-group and base-SQL
quest-race facts. Full overlay regeneration consumes this fixture. To refresh
it against the same base snapshot, write to new outputs first:

```text
python website/tools/map_factions.py --acore-source <source> --faction-dbc <FactionTemplate.dbc> --overlays website/map-assets-local/overlays --facts-output build/faction-facts-new.json --output build/faction-overlays-new
```

Review and promote both outputs together. Changed existing SQL inputs are
rejected; unknown affiliation remains shared rather than guessed from names.
The packager verifies faction evidence and generator hashes before publication.

Generated artwork and overlay payloads are committed under `map-assets-local/`
on this standalone website branch. The directory name is retained for compatibility.
The site packager explicitly includes the verified terrain and icon files in its
static output. Visitors
do not need a client. Blizzard artwork remains separately attributed, not
relicensed under this project's software license; this tooling does not establish
redistribution permission. Missing assets leave manual editing available.

Use only already-installed tools and authorized local inputs:

```text
py -3 website/tools/build_map_reader.py --acore-source <source> --acore-build <build> --vcvars <vcvarsall.bat> --output build/website-map-tools
py -3 website/tools/map_extract.py --client <client> --helper build/website-map-tools/map_archive.exe --converter <ffmpeg> --output website/map-assets-local
py -3 website/tools/map_overlays.py --acore-source <source> --output website/map-assets-local/overlays
py -3 website/tools/build_map_reader.py --acore-source <source> --acore-build <build> --vcvars <vcvarsall.bat> --output build/website-map-tools --icons
py -3 website/tools/map_icons.py --client <client> --helper build/website-map-tools/icon_archive.exe --converter <ffmpeg> --output website/map-assets-local/icons
```

Extraction requires new/empty output directories and never overwrites earlier
evidence. `map_extract.py` defines highest-priority-first stock archive order:
English locale patches 3/2/base, common patches 3/2/base, locale expansion/base
archives, then Lich King, Burning Crusade and common base archives. Other MPQs,
including custom patch names, are excluded and listed in the local receipt.
The same order resolves texture mappings, BLP members and zone metadata.
Missing/deleted members and unsupported delta patches fail visibly.

The helper links the local AzerothCore libmpq (GPL-2.0-or-later), zlib and bzip2
libraries. It uses their existing read-only archive API; no archive files are
modified. `map_archive.cpp` and its synthetic MPQ tests use the authorized
libmpq hash/block definitions and algorithms. AzerothCore source license and
attribution accompany generated overlay data. Generator receipts record member,
recipe, coordinate-source and output hashes without machine paths or timestamps.

Native BLP2 paletted/DXT images become lossless 256-pixel WebP tiles; lower zooms
are area-reduced, never artificially enlarged. Conversion has four workers and
does not assemble whole continents in memory. The browser has four concurrent
requests and a 192-entry LRU cache, coalesces paints, and aborts stale requests.
The square viewport uses proportional, pointer-centered wheel zoom with a short
transition (disabled for reduced-motion preferences). Maximum zoom magnifies the
native tiles eightfold; it does not add terrain detail. Panning retains in-flight
visible tiles; cached resolutions fill gaps during zoom. Rendering stops at rest.
Low-zoom overlay summaries avoid loading every individual spawn at once. Their
positions are cluster centroids; zoom in for exact snapshot home positions.
Client icons identify quest starters/turn-ins, vendors, trainers and repairs.
Repair roles use the NPC repair flag, independently of the vendor flag.

Overlay generation reads base SQL as text. It does not connect to a database,
apply updates or inspect account/character tables. Flags and quest relations can
give one entity several roles. Generic creatures/objects start hidden. Vendor
inventories, trainer eligibility, patrols, loot sources and live availability are
not inferred. Wowhead remains a separate explicit detail lookup.

Additional checks:

```text
py -3 website/tools/test_maps.py --helper build/website-map-tools/map_archive.exe --acore-source <source> --assets website/map-assets-local
py -3 website/tools/browser_maps.py --browser <installed-Chrome-or-Edge> --output build/maps-browser --prefix /RXPGuides/
py -3 website/tools/browser_maps.py --browser <installed-Chrome-or-Edge> --output build/maps-browser-hidpi --scale 2
```

The latter uses an isolated headless browser and loopback-only DevTools for real
pointer/paint tests, not a downloaded driver. Its explicitly requested output
contains screenshots and diagnostics; browser profiles are private scratch.
Source-only browser tests use synthetic metadata, so CI need not ship client art.

## Format and architecture

- `guide-editor/model.js`: lossless spans, restricted Lua container scanner,
  basic validation, text operations and guide-source exports. No Lua execution.
- `guide-editor/app.js`: reactive native DOM controls, preview and local drafts.
  Field edits reparse only the selected guide and update affected views without
  recreating inputs or changing caret/focus. Validation and storage are debounced;
  source edits use the full scanner. No framework or build step is required.
- `guide-editor/wowhead.js`: strict WotLK links, bounded data-only lookup and
  inert text conversion. No external scripts, HTML insertion or game state.
- `guide-editor/map-model.js`: projection, waypoint spans, clustering and bounded
  cancellation-aware resources; `map-view.js`: lazy canvas and accessible controls.
- `tools/`: offline data extraction, safe loopback preview and verification.

Source text is the interchange format. Local draft metadata is only browser
state, not a replacement guide format. Downloaded guide text is imported through
the addon's Website guide source format. Advanced/dynamic registrations are source-only;
unrecognized directives remain intact.

This orphan branch is separate from the addon on `main`. Prepare a Pages
payload with the following command (output must be a new or empty directory):

```text
py -3 website/tools/package_site.py --assets website/map-assets-local --output build/pages-preview
py -3 website/tools/serve.py --site-root build/pages-preview --prefix /RXPGuides/
```

This copies an explicit static-file allowlist, verifies terrain/overlay/icon
hashes, and includes all four continents under `map-assets/`. The output excludes
tools, tests, raw client files, private archive inventories and source-only data.
It works at `/` or a repository subpath. Deploy the **contents of this output**,
not `website/` or the repository root. A source-only checkout cannot recreate
client imagery from scratch in CI, but the committed assets can be packaged directly.
The command does not upload, configure Pages, commit or push.
