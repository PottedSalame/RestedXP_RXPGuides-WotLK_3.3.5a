# RXPGuides 3.3.5 localization

English source controls parsing and automation. Translations change display text only, never quest IDs, targets, conditions, coordinates, guide identities or progress.

## Display status

- `official`: names and objectives from the client or verified locale data.
- `reviewed`: approved translations.
- `machine`: unreviewed translations, marked `[MT]` in guide text or disclosed in UI tooltips.
- `fallback`: English prose marked `[EN]`.

Original English mode bypasses translations and these badges.

## Optional language packs

Packs are available for deDE, esES, frFR, koKR, ruRU, zhCN and zhTW. Releases package each as a separate `RXPGuides_Locale_<locale>` addon. Missing translations fall back to English.

The `localizations` branch contains compiled packs and translation catalogs. Catalog presence alone does not establish that they cover current guides or reproduce the shipped packs.

## Validation and releases

- `RUNTIME.lock` on `localizations` pins the addon runtime used by that branch's CI.
- `LOCALIZATIONS.lock` on `main` pins the localization commit used by addon validation and releases.
- CI checks compiled-pack loading, UTF-8, record structure, token integrity, locale isolation and ZIP packaging.
- These checks do not measure current-guide coverage, assess translation quality or prove deterministic regeneration.

Validate localization changes before publishing their commit. Then update `LOCALIZATIONS.lock` on `main` to that published, full commit ID. Do not use a moving branch name.

## Editing translations

Use a separate addon source checkout and explicitly select its revision. Match catalogs to that English inventory before importing translations or compiling packs. Measure coverage and verify fallback allowlists separately from artifact checks.

Preserve named tokens, markup and operational fields. Do not relabel machine translations as reviewed without review. Keep player data, credentials and machine paths out of catalogs.

See `translations/README.md` on the `localizations` branch for the source workflow. Developer tools are not included in player release ZIPs.
