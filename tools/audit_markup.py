"""
Audit all fallback translations for WoW markup corruption.
Identifies: |cRXP_*|r, |cFF..., |r, |T...|t, |H...|h, {tokens}
"""
import json, re
from pathlib import Path
from collections import Counter

root = Path(".")
imp = root / "translations" / "imported"

# Best files (picked from our final runs)
BEST = {
    "deDE": "deDE-fallback-machine-fallback.json",
    "esES": "esES-fallback.json",
    "frFR": "frFR-fallback.json",
    "koKR": "koKR-fallback.json",
    "ruRU": "ruRU-fallback.json",
    "zhCN": "zhCN-fallback-machine-fallback.json",
    "zhTW": "zhTW-fallback-machine-fallback.json",
}

# All patterns to verify
WOW_PATTERNS = [
    (re.compile(r"\|c[0-9a-fA-F]{8}"), "|cRRGGBBAA color"),
    (re.compile(r"\|r"), "|r reset"),
    (re.compile(r"\|cRXP_[A-Z]+_\|r"), "|cRXP_COLOR_|r"),
    (re.compile(r"\|cRXP_[A-Z]+\|r"), "|cRXP_COLOR|r"),
    (re.compile(r"\|cRXP_[A-Z]+_[^\s|]+\|r"), "|cRXP_COLOR_Name|r"),
    (re.compile(r"\|cRXP_[A-Z]+_[^\s|]+"), "|cRXP_COLOR_Name (no |r)"),
    (re.compile(r"\|T[^|]*\|t"), "|Ttexture|t"),
    (re.compile(r"\|H[^|]*\|h"), "|Hlink|h"),
    (re.compile(r"\{[a-z_]+\}"), "{RXP_token}"),
]

def extract_markup(text):
    """Return set of (type, markup_string) tuples found in text."""
    found = set()
    for pat, ptype in WOW_PATTERNS:
        for m in pat.finditer(text):
            found.add((ptype, m.group(0)))
    return found

def count_markup(text):
    """Count total markup tokens."""
    count = 0
    for pat, _ in WOW_PATTERNS:
        count += len(pat.findall(text))
    return count

def audit_locale(loc, filename):
    fp = imp / filename
    if not fp.exists():
        print(f"{loc}: FILE MISSING: {filename}")
        return

    with open(fp, "r", encoding="utf-8") as f:
        draft = json.load(f)

    units = draft.get("units", [])
    total_translated = 0
    corrupted = 0
    corruption_kinds = Counter()
    details = []

    for unit in units:
        source = unit.get("message", "")
        translation = unit.get("translation", "")
        if not translation or translation == source:
            continue
        total_translated += 1

        src_markup = extract_markup(source)
        tr_markup = extract_markup(translation)

        # Check: every markup in source should appear in translation
        missing = src_markup - tr_markup
        # Check: translation shouldn't introduce new "fake" markup that's wrong
        # (harder to detect - check if translation has unexpected markup types)

        if missing:
            corrupted += 1
            for ptype, text in missing:
                corruption_kinds[ptype] += 1
            if len(details) < 8:
                details.append({
                    "en": source[:80],
                    "tr": translation[:80],
                    "missing": [(t, m[:40]) for t, m in missing],
                })

    pct = (corrupted / max(total_translated, 1)) * 100
    status = "CLEAN" if pct < 5 else ("WARN" if pct < 15 else "DIRTY")
    print(f"\n{'='*60}")
    print(f"{loc}: {total_translated} translated, {corrupted} corrupted ({pct:.1f}%) [{status}]")
    if corruption_kinds:
        print("  Corruption types:")
        for kind, cnt in corruption_kinds.most_common(5):
            print(f"    {kind}: {cnt}")
    if details:
        print("  Samples:")
        for d in details[:4]:
            print(f"    EN: {d['en']}")
            print(f"    TR: {d['tr']}")
            for t, m in d['missing']:
                print(f"    MISSING: [{t}] {m}")
            print()

for loc in sorted(BEST.keys()):
    audit_locale(loc, BEST[loc])

print("\n" + "=" * 60)
print("DONE")
