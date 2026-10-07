"""
Translate RXPGuides fallback drafts using googletrans with full WoW markup tokenization.
Placeholders use Unicode brackets ⟨N⟩ that survive translation intact.
"""
import json
import re
import sys
import time
from pathlib import Path
from googletrans import Translator

LOCALES = {
    "deDE": "de", "esES": "es", "frFR": "fr",
    "koKR": "ko", "ruRU": "ru", "zhCN": "zh-cn", "zhTW": "zh-tw",
}

# WoW markup patterns - tokenize longest patterns first via alternation order
WOW_MARKUP = re.compile(r"""
    \|[cC][0-9a-fA-F]{8}         # |cAARRGGBB color
    |\|r                          # |r reset  
    |\|cRXP_[A-Z]+_[A-Z]+\|r     # |cRXP_COLOR_NAME|r (all-caps name)
    |\|cRXP_[A-Z]+_\|r           # |cRXP_COLOR_|r
    |\|cRXP_[A-Z]+\|r            # |cRXP_COLOR|r
    |\|cRXP_[A-Z]+_[^\s|]+\|r    # |cRXP_COLOR_mixedCase|r
    |\|cRXP_[A-Z]+_[^\s|]+       # |cRXP_COLOR_mixedCase (no reset)
    |\|T[^|]*\|t                 # |Ttexture|t
    |\|H[^|]*\|h                 # |Hlink|h
""", re.VERBOSE)

RXP_TOKEN = re.compile(r"\{[a-z_]+\}")
LINK_RE = re.compile(r"\|H.*?\|h(.*?)\|h")
TEXTURE_RE = re.compile(r"\|T.*?\|t")
COLOR_RE = re.compile(r"\|c[0-9a-fA-F]{8}")
RXP_COLOR_RE = re.compile(r"\|cRXP_[A-Z]+_\|r")
RXP_SHORT_RE = re.compile(r"\|cRXP_[A-Z]+\|r")
RXP_NAME_RE = re.compile(r"\|cRXP_[A-Z]+_[^\s|]+\|r")
RXP_OPEN_RE = re.compile(r"\|cRXP_[A-Z]+_[^\s|]+")
RESET_RE = re.compile(r"\|r")
NUM_RE = re.compile(r"-?\d+(?:\.\d+)?")

def has_letters(s):
    for c in s:
        if c.isalpha():
            return True
    return False

def strip_markup(text):
    text = LINK_RE.sub(r"\1", text)
    text = TEXTURE_RE.sub("", text)
    text = RXP_NAME_RE.sub("", text)
    text = RXP_OPEN_RE.sub("", text)
    text = RXP_COLOR_RE.sub("", text)
    text = RXP_SHORT_RE.sub("", text)
    text = COLOR_RE.sub("", text)
    text = RESET_RE.sub("", text)
    return text.strip()

def classify(english, message):
    stripped = message
    for pat in [RXP_TOKEN, LINK_RE, TEXTURE_RE, RXP_NAME_RE, RXP_OPEN_RE,
                RXP_COLOR_RE, RXP_SHORT_RE, COLOR_RE, RESET_RE]:
        stripped = pat.sub("", stripped)
    if not has_letters(stripped):
        return "neutral"
    plain = strip_markup(english)
    if re.match(r"^\[[^\]]+\]$", plain):
        return "official"
    if plain == "test" or re.match(r"^\|cRXP_[A-Z_]+$", plain):
        return "internal"
    if re.match(r"^[A-Z]_\d+(?:_[A-Z]{2})?_[A-Za-z0-9_.-]+$", plain):
        return "internal"
    if re.match(r"^[A-Za-z]+\d+$", plain):
        return "internal"
    if re.match(r"^\d+(?:\.\d+)+(?:a)?$", plain):
        return "internal"
    return "fallback"

def has_translatable_text(message):
    text = message
    for pat in [RXP_TOKEN, NUM_RE, LINK_RE, TEXTURE_RE, RXP_NAME_RE, RXP_OPEN_RE,
                RXP_COLOR_RE, RXP_SHORT_RE, COLOR_RE, RESET_RE]:
        text = pat.sub("", text)
    text = text.strip()
    return bool(text and has_letters(text))

def tokenize_all(message):
    token_map = {}
    counter = [0]
    def replace(m):
        tok = m.group(0)
        ph = f"⟨{counter[0]}⟩"
        token_map[ph] = tok
        counter[0] += 1
        return ph
    tagged = WOW_MARKUP.sub(replace, message)
    tagged = RXP_TOKEN.sub(replace, tagged)
    return tagged, token_map

def detokenize_all(text, token_map):
    for ph, tok in token_map.items():
        text = text.replace(ph, tok)
    return text

def translate_message(message, target_lang, translator, attempt=0):
    if not has_translatable_text(message):
        return None
    tokenized, token_map = tokenize_all(message)
    try:
        result = translator.translate(tokenized, dest=target_lang)
        if result and result.text and result.text.strip() != tokenized.strip():
            return detokenize_all(result.text, token_map)
    except Exception as e:
        if attempt < 2:
            time.sleep(5 * (attempt + 1))
            return translate_message(message, target_lang, translator, attempt + 1)
    return None

def process_draft(draft_path, locale, translator):
    print(f"\n{'='*60}")
    print(f"Processing {locale}")
    with open(draft_path, "r", encoding="utf-8") as f:
        draft = json.load(f)
    target_lang = LOCALES[locale]
    units = draft.get("units", [])
    tcount = scount = fcount = 0
    for i, unit in enumerate(units):
        english = unit.get("english", "")
        message = unit.get("message", english)
        if classify(english, message) != "fallback":
            scount += 1
            continue
        sys.stdout.write(f"  [{i+1}/{len(units)}] ")
        sys.stdout.flush()
        result = translate_message(message, target_lang, translator)
        if result:
            unit["translation"] = result
            tcount += 1
            sys.stdout.write("OK\n")
        else:
            unit["translation"] = message
            fcount += 1
            sys.stdout.write("SKIP\n")
        sys.stdout.flush()
        time.sleep(0.3)
    out = draft_path.replace("-draft.json", "-machine-fallback.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(draft, f, ensure_ascii=False, indent=2)
    print(f"  -> {tcount} translated, {scount} skipped, {fcount} kept English")
    return tcount, scount, fcount

def main():
    root = Path(__file__).resolve().parent.parent
    imports = root / "translations" / "imported"
    translator = Translator()
    locales = sys.argv[1:] if len(sys.argv) > 1 else list(LOCALES.keys())
    totals = {"translated": 0, "skipped": 0, "failed": 0}
    for loc in locales:
        dp = imports / f"{loc}-fallback-draft.json"
        if not dp.exists():
            continue
        t, s, f = process_draft(str(dp), loc, translator)
        totals["translated"] += t
        totals["skipped"] += s
        totals["failed"] += f
    print(f"\nALL DONE: {totals['translated']} translated, {totals['skipped']} skipped, {totals['failed']} kept English")

if __name__ == "__main__":
    main()
