# RXPGuides Custom Guides

Community routes for WoW 3.3.5a. These guides are imported separately, not bundled with the addon.

## Create or edit

Use the [Guide Editor on the website branch](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/tree/website#local-preview) to write a guide or edit existing source. Its Write, Map and Source views share the same document.

In **Guide properties**, enter the server/realm, purpose, zone, description and requirements. The editor saves these as comments and suggests the contribution path. They describe the route; they do not enforce server or character restrictions.

See [Guide authoring](GUIDE_AUTHORING.md) for syntax and examples.

## Import into the addon

1. Use an addon build with **Import format → Website guide source**.
2. Open the Guide Library's **Import** tab and select that format.
3. Paste exported guide text or a supported `Guide.lua`, confirm saving, then choose **Reload guides and UI** when ready.
4. In **Guides**, select **Type → Custom guides** and choose your route.

Keep a source backup. To remove a saved import, select **Delete import**; switch to another guide first if it is active. Older builds can use the editor's companion-addon export instead.

## Contribute

Save the plain guide source as a `.lua` file under:

```text
CustomGuides/<Server-Realm>/<Purpose>/<Zone>/<GuideName>.lua
```

Purposes: **Experience, Gold, Professions, Dungeons, Reputation, Events, PvP, Achievement**.

Use a distinct name under `#group RXPGuides Custom Guides`. Check IDs with the editor's WotLK lookup, test the route on its intended server, and open a pull request targeting **custom-guides**. Include the tested character and any known limitations.
