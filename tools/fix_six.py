import json, re, time
from pathlib import Path
from googletrans import Translator

imp = Path("translations/imported")

# The 6 corrupted entries to fix
CORRUPT_IDS = {
    "deDE-fallback.json": ["c163e412"],
    "zhCN-fallback.json": ["ebed9385", "ea1cabb1", "1ce84637", "0dc89c4e", "b5387038"],
}

WOW_MARKUP = re.compile(r'''
    \|[cC][0-9a-fA-F]{8}
    |\|r
    |\|cRXP_[A-Z]+_[A-Z]+\|r
    |\|cRXP_[A-Z]+_\|r
    |\|cRXP_[A-Z]+\|r
    |\|cRXP_[A-Z]+_[^\s|]+\|r
    |\|cRXP_[A-Z]+_[^\s|]+
    |\|T[^|]*\|t
    |\|H[^|]*\|h
''', re.VERBOSE)
RXP_TOKEN = re.compile(r"\{[a-z_]+\}")

def tokenize(message):
    m = {}
    cnt = [0]
    def rep(mo):
        tok = mo.group(0)
        ph = f"X{cnt[0]}X"
        m[ph] = tok
        cnt[0] += 1
        return ph
    t = WOW_MARKUP.sub(rep, message)
    t = RXP_TOKEN.sub(rep, t)
    # Add space between adjacent placeholders
    t = re.sub(r"(X)(X)", r"\1 \2", t)
    return t, m

def detokenize(text, m):
    # Sort by key length descending to avoid partial matches
    for ph in sorted(m.keys(), key=len, reverse=True):
        text = text.replace(ph, m[ph])
    return text

LANG = {"deDE": "de", "zhCN": "zh-cn"}
translator = Translator()

for filename, ids in CORRUPT_IDS.items():
    fp = imp / filename
    with open(fp, "r", encoding="utf-8") as f:
        d = json.load(f)
    units = d.get("units", [])
    fixed = 0
    for u in units:
        if u.get("id") not in ids:
            continue
        msg = u.get("message", "")
        print(f"  Fixing {u['id']}: {u['english'][:70]}")
        tok, m = tokenize(msg)
        lang = LANG[filename.split("-")[0]]
        try:
            r = translator.translate(tok, dest=lang)
            if r and r.text and r.text.strip() != tok.strip():
                result = detokenize(r.text, m)
                # Verify all source tokens are in result
                src_tokens = set(re.findall(r"\{[a-z_]+\}", msg))
                for pat_re in [r"\|c[0-9a-fA-F]{8}", r"\|r", r"\|cRXP_[^\s|]+\|r?", r"\|T[^|]*\|t", r"\|H[^|]*\|h"]:
                    for m2 in re.finditer(pat_re, msg):
                        src_tokens.add(m2.group(0))
                tr_tokens = set(re.findall(r"\{[a-z_]+\}", result))
                for pat_re in [r"\|c[0-9a-fA-F]{8}", r"\|r", r"\|cRXP_[^\s|]+\|r?", r"\|T[^|]*\|t", r"\|H[^|]*\|h"]:
                    for m2 in re.finditer(pat_re, result):
                        tr_tokens.add(m2.group(0))
                if src_tokens - tr_tokens:
                    print(f"    STILL CORRUPTED, keeping English")
                    u["translation"] = msg
                else:
                    u["translation"] = result
                    print(f"    FIXED: {result[:80]}")
                    fixed += 1
            else:
                u["translation"] = msg
                print(f"    No translation, keeping English")
        except Exception as e:
            u["translation"] = msg
            print(f"    Error: {e}, keeping English")
        time.sleep(0.3)
    with open(fp, "w", encoding="utf-8") as f:
        json.dump(d, f, ensure_ascii=False, indent=2)
    print(f"  {filename}: {fixed}/{len(ids)} fixed")
print("DONE")
