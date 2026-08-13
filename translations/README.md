# 3.3.5 localization catalogs

English guide files are the only parsing and automation source. Files in this
directory contain display data only; they must never be used for quest IDs,
targets, conditions, coordinates, guide keys, or progression.

`imported/` contains committed reviewed and machine-assisted catalogs. Every
entry is tied to the immutable English inventory revision and preserves its
named-token signature. Machine-assisted text remains marked `[MT]` in game;
documented unresolved prose remains English and is marked `[EN]`.

`source/` contains deterministic import descriptions and the exact fallback
allowlist for every completed locale. Existing AceLocale strings are treated
as reviewed. The generated `locale/GuidePack.<locale>.lua` files are compressed
and locale-gated, so only the active client's pack is decompressed and kept.

Completed packs are `deDE`, `esES`, `frFR`, `ruRU`, `koKR`, `zhCN`, and
`zhTW`. Validation requires every pack to resolve all ordinary UI occurrences,
resolve at least 99% of bundled guide-text occurrences, and exactly match its
committed fallback allowlist. This makes each locale independently shippable;
an edit to one catalog cannot silently alter another locale's display data.

The ordinary workflow is:

```powershell
./tools/Export-TranslationUnits335.ps1 -AddonRoot . -OutputPath source.json
./tools/Get-TranslationCoverage335.ps1 -SourceCatalog source.json -TranslationCatalog <catalogs> -RepoRoot . -Locale <locale>
./tools/Compile-TranslationPack335.ps1 -AddonRoot . -SourceCatalog source.json -TranslationCatalog <catalogs>
./tools/Validate-TranslationPacks335.ps1
```

Catalog metadata records translation provenance. Production and validation do
not use API keys, runtime downloads, personal filesystem paths, or network
translation. Traditional Chinese machine prose is generated directly for
`zho_Hant`; it is not copied or mechanically converted from zhCN.
