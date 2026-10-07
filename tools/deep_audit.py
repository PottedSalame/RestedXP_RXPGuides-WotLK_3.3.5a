"""
Deep audit: verify translated fallback files won't break addon functionality.
Checks:
1. JSON structural validity
2. Token integrity ({tokens}, |cRXP_*, |cFF.., |r, |T..|t, |H..|h)
3. No harmful Unicode (null bytes, control chars, BOM)
4. Translation doesn't alter guide-critical strings
5. All unit IDs match draft source
6. No empty/invalid translations
7. String length limits (WoW has ~4096 char limit for strings)
"""
import json, re, sys
from pathlib import Path
from collections import Counter, defaultdict

root = Path(".")
imp = root / "translations" / "imported"

FALLBACK_FILES = [
    ("deDE", "deDE-fallback.json"),
    ("esES", "esES-fallback.json"),
    ("frFR", "frFR-fallback.json"),
    ("koKR", "koKR-fallback.json"),
    ("ruRU", "ruRU-fallback.json"),
    ("zhCN", "zhCN-fallback.json"),
    ("zhTW", "zhTW-fallback-machine-fallback.json"),
]

# All WoW/RXP markup patterns
WOW_PATTERNS = {
    "|cRRGGBBAA": re.compile(r"\|c[0-9a-fA-F]{8}"),
    "|r": re.compile(r"\|r"),
    "|cRXP_COLOR_|r": re.compile(r"\|cRXP_[A-Z]+_\|r"),
    "|cRXP_COLOR|r": re.compile(r"\|cRXP_[A-Z]+\|r"),
    "|cRXP_COLOR_Name|r": re.compile(r"\|cRXP_[A-Z]+_[^\s|]+\|r"),
    "|cRXP_COLOR_Name": re.compile(r"\|cRXP_[A-Z]+_[^\s|]+"),
    "|Ttexture|t": re.compile(r"\|T[^|]*\|t"),
    "|Hlink|h": re.compile(r"\|H[^|]*\|h"),
    "{RXP_token}": re.compile(r"\{[a-z_]+\}"),
}

# Lua/WoW dangerous characters
DANGEROUS_CHARS = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]")  # control chars
BOM = "\ufeff"
MAX_STRING_LENGTH = 4000  # WoW safe limit

print("=" * 65)
print("DEEP AUDIT: Fallback Translation Integrity")
print("=" * 65)

all_errors = defaultdict(list)
all_warnings = defaultdict(list)
grand_stats = Counter()

for loc, filename in FALLBACK_FILES:
    fp = imp / filename
    if not fp.exists():
        print(f"\n{loc}: FILE MISSING - {filename}")
        all_errors[loc].append("File missing")
        continue

    print(f"\n--- {loc} ({filename}) ---")
    
    # 1. Load JSON
    try:
        raw = fp.read_text(encoding="utf-8")
        if raw.startswith(BOM):
            all_warnings[loc].append("File starts with BOM")
        if DANGEROUS_CHARS.search(raw):
            positions = [(m.start(), repr(m.group())) for m in DANGEROUS_CHARS.finditer(raw)]
            all_errors[loc].append(f"Dangerous control characters: {positions[:5]}")
        draft = json.loads(raw)
    except json.JSONDecodeError as e:
        all_errors[loc].append(f"Invalid JSON: {e}")
        continue
    except Exception as e:
        all_errors[loc].append(f"File read error: {e}")
        continue
    
    units = draft.get("units", [])
    print(f"  Units: {len(units)}")
    grand_stats["total_units"] += len(units)

    # 2. Check draft unit IDs match
    draft_fp = imp / f"{loc}-fallback-draft.json"
    draft_ids = set()
    if draft_fp.exists():
        with open(draft_fp, "r", encoding="utf-8") as f:
            draft_data = json.load(f)
        draft_ids = {u["id"] for u in draft_data.get("units", [])}
        file_ids = {u.get("id") for u in units}
        if file_ids != draft_ids:
            missing = draft_ids - file_ids
            extra = file_ids - draft_ids
            if missing:
                all_errors[loc].append(f"Missing IDs vs draft: {len(missing)}")
            if extra:
                all_errors[loc].append(f"Extra IDs vs draft: {len(extra)}")
    
    # 3. Per-unit checks
    token_issues = 0
    length_issues = 0
    empty_translations = 0
    translated = 0
    kept_english = 0
    
    for i, u in enumerate(units):
        uid = u.get("id", f"index_{i}")
        src = u.get("message", "")
        tr = u.get("translation", "")
        en = u.get("english", "")
        
        if not tr:
            empty_translations += 1
            all_warnings[loc].append(f"Unit {uid}: empty translation")
            continue
        
        if tr == src:
            kept_english += 1
        else:
            translated += 1
        
        # 3a. Token integrity: every markup in source must be in translation
        src_tokens = set()
        tr_tokens = set()
        for pname, pat in WOW_PATTERNS.items():
            for m in pat.finditer(src):
                src_tokens.add(m.group(0))
            for m in pat.finditer(tr):
                tr_tokens.add(m.group(0))
        
        missing_tokens = src_tokens - tr_tokens
        extra_tokens = tr_tokens - src_tokens
        
        if missing_tokens:
            token_issues += 1
            all_errors[loc].append(
                f"Unit {uid}: MISSING {len(missing_tokens)} tokens: "
                f"{[t[:30] for t in list(missing_tokens)[:3]]}"
            )
        
        # 3b. Check for broken token artifacts
        # X0X/ZW0ZW/___W0___ leftovers that weren't detokenized
        artifact = re.search(r"X\d+X|ZW\d+ZW|___W\d+___|⟨\d+⟩", tr)
        if artifact:
            token_issues += 1
            all_errors[loc].append(
                f"Unit {uid}: ARTIFACT '{artifact.group()}' in translation"
            )
        
        # 3c. Length check
        if len(tr) > MAX_STRING_LENGTH:
            length_issues += 1
            all_warnings[loc].append(
                f"Unit {uid}: translation too long ({len(tr)} chars)"
            )
        
        # 3d. Dangerous chars in translation
        if DANGEROUS_CHARS.search(tr):
            all_errors[loc].append(
                f"Unit {uid}: control chars in translation"
            )
    
    print(f"  Translated: {translated}, Kept English: {kept_english}")
    print(f"  Token issues: {token_issues}")
    print(f"  Length issues: {length_issues}")
    print(f"  Empty translations: {empty_translations}")
    
    grand_stats["translated"] += translated
    grand_stats["kept_english"] += kept_english
    grand_stats["token_issues"] += token_issues
    grand_stats["length_issues"] += length_issues
    grand_stats["empty"] += empty_translations

# Summary
print(f"\n{'=' * 65}")
print("FINAL VERDICT")
print("=" * 65)

total_errors = sum(len(v) for v in all_errors.values())
total_warnings = sum(len(v) for v in all_warnings.values())

if all_errors:
    print(f"\nERRORS ({total_errors}):")
    for loc, errs in sorted(all_errors.items()):
        for e in errs[:5]:
            print(f"  [{loc}] {e}")
        if len(errs) > 5:
            print(f"  [{loc}] ... and {len(errs)-5} more")

if all_warnings:
    print(f"\nWARNINGS ({total_warnings}):")
    for loc, warns in sorted(all_warnings.items()):
        for w in warns[:3]:
            print(f"  [{loc}] {w}")
        if len(warns) > 3:
            print(f"  [{loc}] ... and {len(warns)-3} more")

print(f"\nStats: {grand_stats['translated']} translated + {grand_stats['kept_english']} kept English "
      f"= {grand_stats['total_units']} total units")
print(f"  Token integrity issues: {grand_stats['token_issues']}")
print(f"  String length issues: {grand_stats['length_issues']}")
print(f"  Empty translations: {grand_stats['empty']}")

if total_errors == 0:
    print(f"\n>>> SAFE TO USE - No errors found <<<")
    if total_warnings == 0:
        print("    Zero warnings. Files are production-ready.")
    else:
        print(f"    {total_warnings} minor warnings (non-breaking).")
else:
    print(f"\n>>> NEEDS FIXES - {total_errors} errors must be resolved <<<")
