"""Read authorized offline SQL and repo metadata; never execute SQL or use a DB.

Standard library only. Explicit input roots; generated output contains no local
paths, credentials, timestamps, account tables or server configuration.
"""
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
from project_paths import require_addon


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8", newline="\n")


def extract(acore, output):
    acore = acore.resolve()
    sql = acore / "data/sql/base/db_world"
    addon = require_addon()
    spec = importlib.util.spec_from_file_location("rxp_sql_reader", addon / "tools/extract_hardcore_quest_facts335.py")
    reader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reader)
    revision = subprocess.check_output(["git", "-c", "safe.directory=" + acore.as_posix(), "-C", str(acore), "rev-parse", "HEAD"], text=True).strip()
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("A full source revision is required")
    license_text = (acore / "LICENSE").read_text(encoding="utf-8")
    if "Version 2, June 1991" not in license_text:
        raise ValueError("Source license changed; review attribution before generating")
    inputs = {}

    def rows(table):
        path = sql / (table + ".sql")
        inputs["data/sql/base/db_world/" + path.name] = digest(path)
        return reader.read_rows(path, lambda _: True)

    output.mkdir(parents=True, exist_ok=True)
    counts = {}
    for kind, table, key in (("npcs", "creature_template", "entry"), ("items", "item_template", "entry"), ("objects", "gameobject_template", "entry")):
        data = sorted([[r[key], r["name"]] for r in rows(table)])
        if len({row[0] for row in data}) != len(data):
            raise ValueError("Duplicate entity ID: " + table)
        write_json(output / (kind + ".json"), data)
        counts[kind] = len(data)
    addons = {r["ID"]: {key: r[key] for key in ("AllowableClasses", "PrevQuestID", "NextQuestID", "ExclusiveGroup", "RequiredSkillID", "RequiredSkillPoints")} for r in rows("quest_template_addon")}
    relations = defaultdict(lambda: defaultdict(list))
    for table in ("creature_queststarter", "creature_questender", "gameobject_queststarter", "gameobject_questender"):
        for row in rows(table):
            relations[row["quest"]][table].append(row["id"])
    shards, names = defaultdict(dict), []
    for row in rows("quest_template"):
        qid = row["ID"]
        names.append([qid, row["LogTitle"]])
        selected = {key: row[key] for key in ("MinLevel", "QuestLevel", "AllowableRaces", "QuestSortID", "RewardNextQuest")}
        selected["prerequisiteFields"] = addons.get(qid, {})
        selected["relations"] = {key: sorted(set(value)) for key, value in relations[qid].items()}
        selected["objectiveFacts"] = {key: value for key, value in row.items() if key.startswith(("RequiredNpcOrGo", "RequiredItem", "ObjectiveText")) and value not in (0, "", None)}
        if str(qid) in shards[qid // 1000]:
            raise ValueError("Duplicate quest ID")
        shards[qid // 1000][str(qid)] = selected
    names.sort()
    write_json(output / "quests.json", names)
    counts["quests"] = len(names)
    for shard, data in sorted(shards.items()):
        write_json(output / "quests" / (str(shard) + ".json"), data)
    runtime = addon / "tests/runtime-surface.json"
    maps_path = addon / "DB/wotlk/db.lua"
    surface = json.loads(runtime.read_text(encoding="utf-8"))
    map_text = maps_path.read_text(encoding="utf-8").split("addon.mapId = {", 1)[1].split("\n}", 1)[0]
    maps = {}
    for name, number in re.findall(r'\["([^"\\]+)"\]\s*=\s*(\d+)', map_text):
        if name in maps and maps[name] != int(number):
            raise ValueError("Conflicting map alias")
        maps[name] = int(number)
    write_json(output / "catalogue.json", {"directives": sorted(set(surface["directives"] + surface["directiveAliases"])), "maps": maps,
        "sources": {"tests/runtime-surface.json": digest(runtime), "DB/wotlk/db.lua": digest(maps_path)}})
    notice = ("RXPGuides Tools reference data\n\n"
        "Offline AzerothCore base snapshot; SQL updates and custom modules are not applied.\n"
        "Template presence is not proof that a quest is offered. Objective slots are not verified client leaderboard indices.\n"
        "Names, IDs and selected quest facts derived from AzerothCore contributors' world SQL.\n"
        "Source: https://github.com/azerothcore/azerothcore-wotlk/tree/" + revision + "/data/sql/base/db_world\n"
        "Source license notice: GNU General Public License version 2; see LICENSE-AzerothCore.txt.\n"
        "Directive/map aliases derived from this RXPGuides repository; project license GPL version 3.\n"
        "No player data, credentials, source-machine paths or full dialogue are included.\n")
    (output / "NOTICE.txt").write_text(notice, encoding="utf-8", newline="\n")
    (output / "LICENSE-AzerothCore.txt").write_text(license_text, encoding="utf-8", newline="\n")
    files = {p.relative_to(output).as_posix(): digest(p) for p in sorted(output.rglob("*")) if p.is_file() and p.name != "manifest.json"}
    write_json(output / "manifest.json", {"schemaVersion": 1, "sourceRevision": revision, "scope": "offline base snapshot; updates/modules not applied",
        "counts": counts, "inputs": inputs, "files": files, "generator": {"website/tools/extract_data.py": digest(Path(__file__)), "tools/extract_hardcore_quest_facts335.py": digest(addon / "tools/extract_hardcore_quest_facts335.py")}})
    return counts


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--acore-source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True, help="New or empty output directory; prevents stale generated shards")
    args = parser.parse_args()
    if args.output.exists() and any(args.output.iterdir()):
        parser.error("Output must be a new or empty directory; compare fresh generations before replacing reviewed data")
    print(json.dumps(extract(args.acore_source, args.output), sort_keys=True))
