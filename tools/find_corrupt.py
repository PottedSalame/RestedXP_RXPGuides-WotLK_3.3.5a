import json, re
from pathlib import Path

imp = Path("translations/imported")
BEST = {
    "deDE": "deDE-fallback.json",
    "zhCN": "zhCN-fallback.json",
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

for loc in sorted(BEST.keys()):
    fp = imp / BEST[loc]
    with open(fp, "r", encoding="utf-8") as f:
        d = json.load(f)
    units = d.get("units", [])
    for i, u in enumerate(units):
        s = u.get("message","")
        t = u.get("translation","")
        if not t or t == s: continue
        src = []
        trs = []
        for pat, pt in WOW_PATTERNS:
            for m in pat.finditer(s): src.append((pt, m.group(0), m.start(), m.end()))
        for pat, pt in WOW_PATTERNS:
            for m in pat.finditer(t): trs.append((pt, m.group(0)))
        src_set = set((pt, v) for pt, v, _, _ in src)
        trs_set = set((pt, v) for pt, v in trs)
        missing = src_set - trs_set
        if missing:
            print(f"--- {loc} unit[{i}] ---")
            print(f"  ID: {u.get('id','?')}")
            print(f"  EN: {u.get('english','')[:120]}")
            print(f"  SRC: {s[:200]}")
            print(f"  TR:  {t[:200]}")
            for pt, v in missing:
                print(f"  MISSING: [{pt}] {v}")
            print()
