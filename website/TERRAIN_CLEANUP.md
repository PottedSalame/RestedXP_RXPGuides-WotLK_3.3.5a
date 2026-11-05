# Ghostlands terrain edges

The stock minimap tiles contain opaque navy filler south/east of Ghostlands
and a white eastern border. Flat ocean padding on its southwest edge also
covers terrain near Scarlet Monastery. When the expansion map is placed beside
Eastern Plaguelands, those pixels cover the underlying Eastern Kingdoms terrain.

`map-assets-local/terrain-cleanup/` is a separate derived layer. The original
tiles, receipts, zone bounds, projection offsets and spawn records are unchanged.
Only the Eastern Kingdoms placement of physical map 530 uses the cleaned layer.
This does not invent a seamless geographical connection between the two maps.

The reviewed recipe is `tools/fixtures/ghostlands-terrain.json`:

- 33 native tile coordinates, bound to their original paths and SHA-256 hashes.
- White filler tiles and navy-only bottom border tiles become transparent.
- Partial tiles remove only edge-connected pixels of the two exact navy filler
  colours. Other pixels, including isolated matching terrain pixels, remain.
- Eight reviewed southwest padding tiles become transparent. Tile 42,21 also
  removes edge-connected flat ocean colour, retaining its visible land.
- Reduced zoom tiles are rebuilt from these copies and unchanged siblings,
  so cached fallback resolutions do not bring back the rectangles.

Regenerate into a new directory, never over the original terrain:

```text
python website/tools/map_terrain_cleanup.py --assets website/map-assets-local --converter <installed-ffmpeg> --output build/terrain-cleanup-new
```

Compare two independent runs, then copy the generated directory to
`website/map-assets-local/terrain-cleanup/`. Updated source tiles, placement,
pixel counts or generator code require renewed review/regeneration.

```text
python website/tools/test_terrain_cleanup.py --assets website/map-assets-local --converter <installed-ffmpeg>
python website/tools/browser_terrain_seam.py --browser <installed-Chrome-or-Edge> --output build/terrain-seam-check
python website/tools/browser_terrain_seam.py --browser <installed-Chrome-or-Edge> --output build/scarlet-seam-check --area scarlet
```

The static packager verifies the cleanup recipe, dependencies, complete tile
inventory and hashes. It includes only the verified derived files. Source-only
previews without this layer fall back to original imagery with a brief status
message. No per-frame pixel processing, added polling or coordinate changes are
needed. Client artwork remains attributed to Blizzard Entertainment.
