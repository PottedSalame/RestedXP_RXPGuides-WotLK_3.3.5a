# Interior references

Open **Map → Regions** and choose Dungeons, Raids or Underground locations.
Choose a region and a view/section. Search its entity list by name or ID,
select an entry and use **Entity details** to add a target, quest pickup,
quest turn-in or interaction note. Actions use the normal editor Undo history.

## Coverage and limits

The current stock-client inventory contains 51 dungeon entries, 23 raid
entries and 103 underground/shared-interior entries, including the Deeprun
Tram. These provide 3,639 reference views. This is not a claim that every cave
placement or playable floor has a complete map.

- Room sections come from the client's minimap textures. A section number is
  **not a verified floor number**. Some views are small pieces or exterior
  sections; use the section selector to inspect the available artwork.
- Entity lists use AzerothCore base-world spawn and quest-relation records
  for the entire physical instance. They are not live, room-specific, or
  exhaustive inventories of creatures spawned by encounter scripts.
- Shared caves and buildings without a verified spawn-to-interior association
  have no entity list. The separate reference lookup remains available.
- There are no interior entity pins, click-to-create coordinates or waypoint
  dragging. Image pan/zoom never edits guide source. Interior `.goto` support
  requires a separately verified addon coordinate mapping.
- Event-dependent entities remain hidden until their event is selected.
  Other conditional records are labeled, not assumed available to a character.
- No patrol routes, floor connectivity or safe pathfinding are inferred.

## Generation

Use only an authorized local stock client and AzerothCore checkout. Supply
paths explicitly; nothing is downloaded, installed or written to those inputs.

```text
python website/tools/build_map_reader.py --acore-source <source> --acore-build <build> --vcvars <compiler-environment> --output build/interior-reader --interiors
python website/tools/map_interiors.py --client <client> --helper <interior-reader> --converter <ffmpeg> --acore-source <source> --output <new-empty-output-directory>
python website/tools/validate_interiors.py --assets <generated-directory>
```

The generator uses stock archive precedence, WDT/ADT links, WMO area metadata
and client minimap mappings. Custom patch overrides are excluded. Missing or
deleted members stay unavailable; corrupt data fails extraction. Native-sized
textures retain transparent edges; large sheets also have reduced overviews.

Receipts record logical source members, source hashes, source revision and
conversion settings. SQL is read as text, never executed. No account or
character data is read. Client artwork remains Blizzard Entertainment's;
AzerothCore-derived data retains its accompanying GPL-2.0 license.

The reviewed output lives under `website/map-assets-local/interiors/`. Static
packaging verifies its receipts and includes only the required assets and
license. The interior addition is approximately 87 MiB on disk, **not an
initial page download**. Opening a region requests only its catalogue, entity
list, selected view and visible imagery. The 128-entry interior cache and four
concurrent requests are separate from the outdoor cache. There is no idle
render loop; closing the panel cancels requests.

## Tests

```text
python -m unittest discover -s website/tools -p test_interiors.py
python website/tools/validate_interiors.py --assets website/map-assets-local/interiors
python website/tools/browser_interiors.py --browser <installed-Chrome-or-Edge> --output build/interior-check
```

Use `--prefix /RXPGuides/ --site-root <packaged-directory>` for the packaged
browser check. The general browser suite also exercises missing assets,
event gates, stale responses/actions, Undo and shared-cave scope. Tests run
locally and do not deploy the site or modify the addon.
