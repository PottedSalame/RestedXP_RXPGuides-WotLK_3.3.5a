# Translation catalogs

These files contain display text only. English addon source remains authoritative for parsing and automation.

- `imported/`: reviewed and machine-assisted translation catalogs.
- `source/`: source descriptions, translation inputs and fallback allowlists.
- `../locale/GuidePack.<locale>.lua`: compiled, locale-gated packs.

Machine translations remain marked `[MT]`; untranslated English prose uses `[EN]`. Preserve source identities, named tokens and markup when editing.

## Source workflow

Use a separate addon checkout at an explicitly chosen revision. Do not assume this branch's guide copies or existing catalogs match current `main`.

1. Extract the English inventory with `Export-TranslationUnits335.ps1`, passing `-AddonRoot` and a separate `-OutputPath`.
2. Reconcile translation catalogs and fallback allowlists with that inventory. Resolve stale entries rather than changing revision labels alone.
3. Compile with `Compile-TranslationPack335.ps1`, supplying the matching source catalog, translation catalogs, addon root and output path.
4. Measure coverage with `Get-TranslationCoverage335.ps1` and review fallback entries. Run source validation separately and compare independent builds before claiming reproducibility.
5. Run compiled-artifact and packaging checks before publication.

Current CI checks the compiled artifacts. It does not guarantee 99% guide coverage, complete UI coverage or an up-to-date fallback allowlist.

Keep provenance in catalog metadata. Do not include API keys, player information or personal paths. Runtime packs require no online translation service.
