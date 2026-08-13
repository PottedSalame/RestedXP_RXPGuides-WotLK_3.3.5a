# RXPGuides 3.3.5 localization workflow

English guide source is authoritative. Translations are display data and must
never change directives, conditions, IDs, targets, coordinates, guide keys, or
step progression.

## Statuses

- `official`: live names and objectives supplied by the client or verified
  locale databases.
- `reviewed`: an aligned upstream or manually approved translation.
- `machine`: a structurally validated, unreviewed translation. Guide text is
  marked `[MT]`; compact UI controls disclose this status in their tooltip.
- `fallback`: unchanged English, displayed with `[EN]` when it contains prose.

Original English mode bypasses all translated display text and status badges.

Localization source catalogs and compiled payloads live on the repository's
`localizations` branch. `LOCALIZATIONS.lock` on `main` pins the exact commit
used by validation and release packaging. Each locale keeps a deterministic
fallback allowlist under `translations/source` on that branch. It records every
bespoke English sentence still using `[EN]`, its immutable source ID, and
occurrence count. Validation rejects a missing or stale allowlist, so English
exceptions cannot grow unnoticed.

## Commands

Check out the `localizations` branch, then run these from its repository root
with PowerShell 7 or Windows PowerShell:

```powershell
./tools/Export-TranslationUnits335.ps1 -OutputPath ./translation-units.json
./tools/New-TranslationDraft335.ps1 -SourceCatalog ./translation-units.json -Locale zhCN -OutputPath ./zhCN-draft.json
./tools/Import-TranslationMap335.ps1 -SourceCatalog ./translation-units.json -TranslationMap ./translations/source/zhCN-ui-machine.json -OutputPath ./translations/imported/zhCN-ui-machine.json
./tools/Compile-TranslationPack335.ps1 -SourceCatalog ./translation-units.json -TranslationCatalog @('./translations/imported/zhCN-upstream.json','./translations/imported/zhCN-ui-reviewed.json','./translations/imported/zhCN-ui-machine.json') -OutputPath ./locale/GuidePack.zhCN.lua
./tools/Get-TranslationCoverage335.ps1 -SourceCatalog ./translation-units.json -TranslationCatalog ./translations/imported/zhCN-upstream.json -RepoRoot . -Locale zhCN
./tools/Validate-TranslationPacks335.ps1
```

The extractor follows the 3.3.5 manifest, strips guide conditions with the
runtime parser's boundary, deduplicates immutable English, and emits only
repository-relative context. It never emits player, realm, GUID, or machine
paths.

## Safety rules

Translated messages use named tokens such as `{friendly_a}`, `{texture_b}`,
and `{format_c}`. Tokens may move, but none may be changed, duplicated, or
deleted. Compilation rejects stale source, invalid UTF-8, positional format
tokens in tokenized translations, operational guide syntax, altered markup,
unknown source entries, conflicting catalogs, and reserved separators.

Runtime packs are locale-gated and compressed with the bundled LibDeflate
format. CI checks out the commit recorded in `LOCALIZATIONS.lock`, regenerates
its source catalogs and runtime payloads, then checks that the committed output
is deterministic. Passing offline validation does not promote machine text to
reviewed; native corrections must explicitly change the entry status.

## Rollout

Completed companion packs are available for deDE, esES, frFR, ruRU, koKR,
zhCN, and zhTW. A tagged release packages each language as an independent
`RXPGuides_Locale_<locale>` addon. The core addon contains no compiled guide
prose and safely falls back to English when no matching companion is installed.

To publish localization changes, update and validate the `localizations`
branch first, push that commit, then replace `LOCALIZATIONS.lock` on `main`
with its full 40-character commit ID. Never point the lock at an unpushed or
moving branch name: tagged releases must remain reproducible.
