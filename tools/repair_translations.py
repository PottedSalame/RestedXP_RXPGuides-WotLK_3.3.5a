"""
Repair corrupted markup in fallback translations.
- deDE: MyMemory replaced {tokens} with T0/T1/T2 etc. Map them back.
- zhCN: Adjacent {tokens} merged, leaving artifact like ⟩N⟩. Restore them.
"""
import json, re
from pathlib import Path
from collections import defaultdict

root = Path(".")
imp = root / "translations" / "imported"

# deDE: MyMemory corruptions - token → mangled forms seen
# We find corrupted tokens by comparing source vs translation markup
RXP_TOKEN_RE = re.compile(r"\{[a-z_]+\}")

def extract_tokens(text):
    return RXP_TOKEN_RE.findall(text)

def extract_all_wow_markup(text):
    """Extract all WoW markup and RXP tokens in order."""
    pat = re.compile(r"""
        \|[cC][0-9a-fA-F]{8}
        |\|r
        |\|cRXP_[A-Z]+_[A-Z]+\|r
        |\|cRXP_[A-Z]+_\|r
        |\|cRXP_[A-Z]+\|r
        |\|cRXP_[A-Z]+_[^\s|]+\|r
        |\|cRXP_[A-Z]+_[^\s|]+
        |\|T[^|]*\|t
        |\|H[^|]*\|h
        |\{[a-z_]+\}
    """, re.VERBOSE)
    return pat.findall(text)

def repair_deDE_translation(source, translation):
    """MyMemory replaced {tokens} with T0/T1/T2 patterns. Map them back."""
    src_tokens = extract_tokens(source)
    if not src_tokens:
        return translation, False

    # Find T0, T1, T2... patterns in translation
    # These appear as standalone T followed by digit(s), often flanked by spaces
    t_pattern = re.compile(r'\bT(\d+)\b')
    tr_t_matches = t_pattern.findall(translation)

    if not tr_t_matches:
        return translation, False

    # Build mapping: T0 → first token from source, T1 → second, etc.
    fixed = False
    used_indices = set()
    for t_match in t_pattern.finditer(translation):
        idx = int(t_match.group(1))
        if idx < len(src_tokens) and idx not in used_indices:
            old = t_match.group(0)
            new = src_tokens[idx]
            translation = translation.replace(old, new, 1)
            used_indices.add(idx)
            fixed = True

    return translation, fixed

def repair_zhCN_artifacts(translation):
    """Fix Google Translate artifacts where ⟩N⟩ appears instead of ⟨N⟩."""
    # Pattern: a digit surrounded by ⟩ on both sides: ⟩N⟩
    # This means ⟨N⟩ was corrupted - the ⟨ was dropped
    artifact_re = re.compile(r'⟩\s*(\d+)\s*⟩')

    fixed = False
    for m in artifact_re.finditer(translation):
        # Replace ⟩N⟩ with ⟨N⟩ (the original placeholder)
        old = m.group(0)
        new = f"⟨{m.group(1)}⟩"
        translation = translation.replace(old, new, 1)
        fixed = True

    # Also check for ⟩N (dangling) that should be ⟨N⟩  
    # (harder to fix without context)
    return translation, fixed

def repair_locale(loc, filename):
    fp = imp / filename
    if not fp.exists():
        print(f"{loc}: FILE MISSING")
        return

    with open(fp, "r", encoding="utf-8") as f:
        draft = json.load(f)

    units = draft.get("units", [])
    fixed_count = 0
    total_translated = 0

    for unit in units:
        source = unit.get("message", "")
        translation = unit.get("translation", "")
        if not translation or translation == source:
            continue
        total_translated += 1
        was_fixed = False

        if loc == "deDE":
            translation, was_fixed = repair_deDE_translation(source, translation)

        if loc == "zhCN":
            translation, was_fixed = repair_zhCN_artifacts(translation)

        if was_fixed:
            unit["translation"] = translation
            fixed_count += 1

    # Save repaired
    out = fp.with_name(f"{fp.stem}-repaired.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(draft, f, ensure_ascii=False, indent=2)

    pct = (fixed_count / max(total_translated, 1)) * 100
    print(f"{loc}: {fixed_count}/{total_translated} repaired ({pct:.1f}%) -> {out.name}")

# Fix deDE and zhCN
repair_locale("deDE", "deDE-fallback-machine-fallback.json")
repair_locale("zhCN", "zhCN-fallback-machine-fallback.json")
print("DONE")
