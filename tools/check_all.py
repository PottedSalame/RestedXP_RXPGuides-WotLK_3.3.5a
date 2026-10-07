import json
from pathlib import Path

root = Path(".")
imports = root / "translations" / "imported"
# Check the -fallback.json files (new googletrans output)
files = {
    "deDE (mymemory)": "deDE-fallback-machine-fallback.json",
    "esES (googletrans)": "esES-fallback.json",
    "frFR (googletrans)": "frFR-fallback.json",
    "koKR (googletrans)": "koKR-fallback.json",
    "ruRU (googletrans)": "ruRU-fallback.json",
    "zhCN (googletrans)": "zhCN-fallback.json",
    "zhTW (googletrans)": "zhTW-fallback.json",
}
for label, fn in sorted(files.items()):
    fp = imports / fn
    if not fp.exists():
        print(f"{label}: MISSING")
        continue
    with open(fp, "r", encoding="utf-8") as f:
        d = json.load(f)
    units = d.get("units", [])
    total = len(units)
    translated = sum(1 for u in units if u.get("translation","") and u.get("translation") != u.get("message",""))
    kept = total - translated
    sample = None
    for u in units:
        t = u.get("translation","")
        if t and t != u.get("message",""):
            sample = (u["english"][:60], t[:60])
            break
    en, tr = sample if sample else ("N/A", "N/A")
    print(f"{label}: {translated}T/{kept}F ({total}) | {en} -> {tr}")
