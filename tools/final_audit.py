import json, re
from collections import Counter
from pathlib import Path

imp = Path("translations/imported")
BEST = {
    "deDE": "deDE-fallback.json",
    "esES": "esES-fallback.json",
    "frFR": "frFR-fallback.json",
    "koKR": "koKR-fallback.json",
    "ruRU": "ruRU-fallback.json",
    "zhCN": "zhCN-fallback.json",
    "zhTW": "zhTW-fallback-machine-fallback.json",
}
WOW_PATTERNS = [
    (re.compile(r"\{[a-z_]+\}"), "{token}"),
    (re.compile(r"\|c[0-9a-fA-F]{8}"), "|cRRGGBBAA"),
    (re.compile(r"\|r"), "|r"),
    (re.compile(r"\|cRXP_[A-Z]+_\|r"), "|cRXP_COLOR_|r"),
    (re.compile(r"\|cRXP_[A-Z]+\|r"), "|cRXP_COLOR|r"),
    (re.compile(r"\|cRXP_[A-Z]+_[^\s|]+\|r"), "|cRXP_Name|r"),
    (re.compile(r"\|cRXP_[A-Z]+_[^\s|]+"), "|cRXP_Name"),
    (re.compile(r"\|T[^|]*\|t"), "|Ttexture|t"),
    (re.compile(r"\|H[^|]*\|h"), "|Hlink|h"),
]
print("Locale    Translated  Corrupted    Pct  Status")
print("-" * 50)
gt = gc = 0
for loc in sorted(BEST.keys()):
    fp = imp / BEST[loc]
    if not fp.exists():
        print(f"{loc:<8} MISSING")
        continue
    with open(fp, "r", encoding="utf-8") as f:
        d = json.load(f)
    units = d.get("units", [])
    total = corrupted = 0
    for u in units:
        s = u.get("message","")
        t = u.get("translation","")
        if not t or t == s: continue
        total += 1
        src = set()
        trs = set()
        for pat, pt in WOW_PATTERNS:
            for m in pat.finditer(s): src.add((pt, m.group(0)))
        for pat, pt in WOW_PATTERNS:
            for m in pat.finditer(t): trs.add((pt, m.group(0)))
        if src - trs:
            corrupted += 1
    pct = (corrupted/max(total,1))*100
    st = "CLEAN" if pct < 2 else ("WARN" if pct < 10 else "DIRTY")
    print(f"{loc:<8} {total:>10} {corrupted:>10} {pct:>5.1f}% {st}")
    gt += total
    gc += corrupted
print("-" * 50)
gp = (gc/max(gt,1))*100
print(f"TOTAL    {gt:>10} {gc:>10} {gp:>5.1f}%")
