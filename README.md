# RXPGuides Tools website

This independent `website` branch contains the tools hub, guide editor, static
terrain and client icons. It has no parent commits or addon source history.
The addon remains on `main`.

The editor has **Write**, **Map** and **Source** views, with a searchable step
outline and instruction details alongside them. File and Export menus group
document actions; source problems link directly to the affected line.

The editor also includes [dungeon, raid and underground references](website/INTERIORS.md),
with searchable instance entities and view-only interior imagery.

## Local preview

From this checkout, using an installed Python 3.12 or newer:

```text
python website/tools/serve.py
```

Open the printed loopback URL. No server database, WoW client or external build
dependencies are required to use the committed site and artwork.
The default address is `http://127.0.0.1:8765/`. Keep the terminal open while
testing; press Ctrl+C to stop. See the [performance review](website/PERFORMANCE.md)
for existing safeguards and remaining measurement work.

## Prepare GitHub Pages files

```text
python website/tools/package_site.py --assets website/map-assets-local --output build/pages
python website/tools/serve.py --site-root build/pages --prefix /RXPGuides/
```

Publish the **contents of `build/pages`**, not this entire branch. The packager
includes terrain and icons while excluding developer tools, tests and historical
provenance. These local commands do not upload anything.

## Automatic deployment

In GitHub **Settings → Pages**, select **GitHub Actions**. The
`Deploy website to GitHub Pages` workflow tests, packages and publishes each push
to `website`; it does not modify `main`. No client files, database or addon
checkout are needed by the deployment workflow.

The `github-pages` environment must allow deployments from `website`. Check
workflow results under **Actions** and the published URL under **Settings → Pages**.
Re-run a failed workflow after resolving any permissions or environment rules.

## Development and regeneration

See [website documentation](website/README.md) and the
[acceptance checklist](website/CHECKLIST.md). Browser checks use an already
installed Chrome or Edge; no dependencies are downloaded.

Checks against the real addon parser and regeneration from addon definitions
require a separate addon checkout. Set `RXP_ADDON_ROOT` to that checkout's path
in your shell before running them. No machine-specific path is committed.
Do not copy the addon onto this branch. Generated data retains its original
provenance; the three original generator sources are kept under
`website/tools/baseline/` for checking those historical hashes.

The extracted client artwork belongs to Blizzard Entertainment and is not
relicensed under the project's software license. See [credits](website/credits.html).

A normal Git clone may fetch both branches. To fetch only the addon, use
`git clone --single-branch --branch main <repository-url>`.
