# RXPGuides Localizations

Optional language packs for RXPGuides 3.3.5: deDE, esES, frFR, koKR, ruRU, zhCN and zhTW.

## Contents

- `locale/`: compiled language packs.
- `translations/`: translation catalogs, source descriptions and fallback allowlists.
- `Guides/`: guide sources retained on this branch, not automatically synchronized with `main`.
- `tools/` and `tests/`: generation and validation tools.

## Workflow

1. Update translations against an explicitly selected addon source revision.
2. Validate the resulting packs and review their changes.
3. Publish the localization commit, then pin it in `LOCALIZATIONS.lock` on `main`.
4. The next addon release packages the pinned language packs.

## What CI checks

CI validates all seven compiled packs against the addon runtime pinned in `RUNTIME.lock`, including loading, UTF-8, record structure, tokens, locale isolation and companion ZIP packaging.

A passing run does not establish current-guide coverage, translation quality or reproducible source generation. Those require separate checks using matching catalogs and addon sources.

For local artifact validation, run from this branch with Lua 5.1 and a separate addon checkout:

```text
lua5.1 tools/validate-locale-artifacts.lua . <addon-checkout>
```

Use the revision in `RUNTIME.lock` to reproduce this branch's CI. See `translations/README.md` for catalog editing.
