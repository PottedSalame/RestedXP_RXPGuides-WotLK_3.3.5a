import json, sys
from pathlib import Path

root = Path(".")
imports = root / "translations" / "imported"
files = {
    "esES": "esES-fallback.json",
    "deDE": "deDE-fallback-machine-fallback.json",
    "frFR": "frFR-fallback-machine-fallback.json",
    "koKR": "koKR-fallback-machine-fallback.json",
    "ruRU": "ruRU-fallback-machine-fallback.json",
    "zhCN": "zhCN-fallback-machine-fallback.json",
    "zhTW": "zhTW-fallback-machine-fallback.json",
}
for loc, fn in sorted(files.items()):
    fp = imports / fn
    if not fp.exists():
        print(f"{loc}: MISSING")
        continue
    with open(fp, "r", encoding="utf-8") as f:
        d = json.load(f)
    units = d.get("units", [])
    total = len(units)
    translated = sum(1 for u in units if u.get("translation","") and u["translation"] != u.get("message",""))
    kept = total - translated
    sample = None
    for u in units:
        t = u.get("translation","")
        if t and t != u.get("message",""):
            sample = (u["english"][:60], t[:60])
            break
    en, tr = sample if sample else ("N/A", "N/A")
    print(f"{loc}: {translated}T/{kept}F ({total} total) | EN: {en} | TR: {tr}")
