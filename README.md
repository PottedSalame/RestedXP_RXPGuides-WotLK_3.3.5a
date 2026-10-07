# RXPGuides Localizations

Translation files and validation tools for RXPGuides multilingual guide packs.

## Structure

- `locale/` — translation files for all supported locales (deDE, esES, frFR, koKR, ruRU, zhCN, zhTW)
- `Guides/` — guide content used to extract reference English strings
- `tools/` — validation and build scripts
- `tests/` — test fixtures

## Workflow

1. Translation updates are committed to this branch
2. CI validates the compiled artifacts against the addon runtime pinned in `RUNTIME.lock`
3. When ready, update `LOCALIZATIONS.lock` on the `main` branch to the latest commit
4. The next release on `main` automatically packages the pinned locale ZIPs

## CI scope

This branch currently distributes compiled packs without the original
`translations/source/` and `translations/imported/` catalogs. CI checks all
seven packs using Lua 5.1, bundled LibDeflate, the real addon loader, UTF-8,
record structure, source signatures, protected named tokens, locale isolation,
the reviewed zhCN catalog, and companion ZIP packaging.

These artifact checks do **not** prove current-guide coverage, translation
quality, or deterministic regeneration from source. Those checks require the
matching source catalogs; the source-validation scripts remain available for
that workflow. Do not describe an artifact-only pass as 99% coverage approval.

`RUNTIME.lock` pins the addon commit used for this branch's tests. Update it
deliberately when testing a newer runtime. The addon branch independently checks
the packs selected by its `LOCALIZATIONS.lock` against its own current runtime.
No runtime libraries are duplicated into this branch.

## Supported locale codes

| Code | Language |
|------|----------|
| deDE | German |
| esES | Spanish (Spain) |
| frFR | French |
| koKR | Korean |
| ruRU | Russian |
| zhCN | Simplified Chinese |
| zhTW | Traditional Chinese |
