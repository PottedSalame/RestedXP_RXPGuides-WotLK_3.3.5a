# RXPGuides Localizations

Translation files and validation tools for RXPGuides multilingual guide packs.

## Structure

- `locale/` — translation files for all supported locales (deDE, esES, frFR, koKR, ruRU, zhCN, zhTW)
- `Guides/` — guide content used to extract reference English strings
- `tools/` — validation and build scripts
- `tests/` — test fixtures

## Workflow

1. Translation updates are committed to this branch
2. CI validates all translations against guide content
3. When ready, update `LOCALIZATIONS.lock` on the `main` branch to the latest commit
4. The next release on `main` automatically packages the pinned locale ZIPs

## Supported Locales

| Code | Language |
|------|----------|
| deDE | German |
| esES | Spanish (Spain) |
| frFR | French |
| koKR | Korean |
| ruRU | Russian |
| zhCN | Simplified Chinese |
| zhTW | Traditional Chinese |