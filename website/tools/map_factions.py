"""Faction overlay facts from authorized base SQL and extracted WotLK DBC data.

Read-only inputs. Affiliation is not reputation, hostility or quest eligibility.
Unclassified/shared entities remain visible with either faction selected.
"""
import argparse
from collections import defaultdict
import importlib.util
import json
from pathlib import Path
import struct
import subprocess

from map_extract import dbc, sha, write
from project_paths import require_addon

FACTS = Path(__file__).with_name('fixtures') / 'overlay-factions.json'
# WotLK playable races: Human/Dwarf/Night Elf/Gnome/Draenei and
# Orc/Undead/Tauren/Troll/Blood Elf. Unknown race bits stay unclassified.
ALLIANCE_RACES, HORDE_RACES = 1101, 690


def validate_facts(facts):
    if facts.get('schema') != 1:
        raise ValueError('Unsupported faction facts')
    for field in ('npcFactions', 'objectFactions', 'questFactions'):
        if not isinstance(facts.get(field), dict):
            raise ValueError('Missing faction facts')
        for key, value in facts[field].items():
            if not key.isdecimal() or int(key) <= 0 or type(value) is not int or value not in (1, 2):
                raise ValueError('Invalid faction evidence')


def validate_overlay(manifest, facts_path=FACTS):
    facts = json.loads(facts_path.read_text(encoding='utf-8'))
    validate_facts(facts)
    if (manifest.get('factionSchema') != 1 or manifest.get('factionFactsHash') != sha(facts_path.read_bytes())
            or manifest.get('questFactions') != facts['questFactions']):
        raise ValueError('Missing or stale faction evidence')
    for name in ('map_factions.py', 'map_overlays.py'):
        if manifest.get('generators', {}).get(name) != sha(Path(__file__).with_name(name).read_bytes()):
            raise ValueError('Stale faction generator')


def race_side(mask):
    if not mask or mask & ~(ALLIANCE_RACES | HORDE_RACES):
        return 0
    sides = bool(mask & ALLIANCE_RACES) + 2 * bool(mask & HORDE_RACES)
    return sides if sides in (1, 2) else 0


def template_sides(data):
    rows, _ = dbc(data)
    result = {}
    for row in rows:
        if len(row) != 56:
            raise ValueError('Expected WotLK FactionTemplate layout')
        values = struct.unpack('<14I', row)
        side = (values[3] & 6) >> 1  # DBCEnums.h: Alliance=2, Horde=4.
        if str(values[0]) in result:
            raise ValueError('Duplicate faction template')
        result[str(values[0])] = side if side in (1, 2) else 0
    return result


def quest_side(quests, facts):
    sides = {facts['questFactions'].get(str(q), 0) for q in quests}
    if not sides or 0 in sides:
        return 0
    return (1 if 1 in sides else 0) | (2 if 2 in sides else 0)


def annotate(record, facts):
    record = dict(record)
    for key in ('faction', 'roleFactions', 'eventRoleFactions'):
        record.pop(key, None)
    side = facts['npcFactions' if record['kind'] == 'npcs' else 'objectFactions'].get(str(record['id']), 0)
    if side:
        record['faction'] = side
    roles = {}
    for field, role in (('starts', 'start'), ('ends', 'end')):
        side = quest_side(record[field], facts)
        if side:
            roles[role] = side
    if roles:
        record['roleFactions'] = roles
    events = defaultdict(list)
    for event, quest in record.get('eventStarts', []):
        events[event].append(quest)
    dynamic = {str(event): {'start': quest_side(quests, facts)} for event, quests in events.items()
               if quest_side(quests, facts)}
    if dynamic:
        record['eventRoleFactions'] = dynamic
    return record


def evidence(record):
    return {key: record[key] for key in ('faction', 'roleFactions', 'eventRoleFactions') if key in record}


def extract_facts(source, faction_dbc, overlays):
    source = source.resolve()
    addon = require_addon()
    spec = importlib.util.spec_from_file_location('faction_sql', addon / 'tools/extract_hardcore_quest_facts335.py')
    reader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reader)
    manifest = json.loads((overlays / 'manifest.json').read_text())
    data = faction_dbc.read_bytes()
    templates = template_sides(data)
    inputs = {'FactionTemplate.dbc': sha(data)}
    def rows(table):
        path = source / 'data/sql/base/db_world' / (table + '.sql')
        digest = sha(path.read_bytes())
        previous = manifest['inputs'].get(table + '.sql')
        if previous and previous != digest:
            raise ValueError('Base snapshot changed: ' + table)
        inputs[table + '.sql'] = digest
        return reader.read_rows(path, lambda _: True)
    missing = set()
    def sides(table):
        result = {}
        for r in rows(table):
            template = str(r['faction'])
            if template != '0' and template not in templates:
                missing.add(int(template))
            side = templates.get(template, 0)
            if side:
                result[str(r['entry'])] = side
        return result
    npcs = sides('creature_template')
    objects = sides('gameobject_template_addon')
    quests = {str(r['ID']): race_side(r['AllowableRaces']) for r in rows('quest_template') if race_side(r['AllowableRaces'])}
    revision = subprocess.check_output(['git', '-c', 'safe.directory='+source.as_posix(), '-C', str(source), 'rev-parse', 'HEAD'], text=True).strip()
    return dict(schema=1, sourceRevision=revision, inputs=inputs, npcFactions=npcs, objectFactions=objects,
                questFactions=quests, unknownTemplates=sorted(missing),
                notice='AzerothCore base SQL, GPL-2.0, and Blizzard WotLK FactionTemplate.dbc. '
                       'Affiliation from factionGroup Alliance/Horde bits; quest audience from AllowableRaces. '
                       'Shared or unknown records remain visible. Not live reputation or availability.',
                source='https://github.com/azerothcore/azerothcore-wotlk/tree/'+revision+'/data/sql/base/db_world')


def enrich(overlays, output, facts_path):
    from map_overlays import overview_records
    from package_site import checked
    if output.resolve() == overlays.resolve() or output.resolve().is_relative_to(overlays.resolve()):
        raise ValueError('Output must be separate from input overlays')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Output must be new or empty')
    facts = json.loads(facts_path.read_text())
    validate_facts(facts)
    manifest = json.loads((overlays / 'manifest.json').read_text())
    for name, digest in facts['inputs'].items():
        if name in manifest['inputs'] and manifest['inputs'][name] != digest:
            raise ValueError('Faction facts belong to another base snapshot')
    groups = defaultdict(list)
    files = {}
    for key, name in sorted(manifest['chunks'].items()):
        data = checked(overlays, name).read_bytes()
        if sha(data) != manifest['files'][name]:
            raise ValueError('Changed overlay input')
        records = [annotate(r, facts) for r in json.loads(data)]
        write(output / name, records)
        files[name] = sha((output / name).read_bytes())
        groups[key.split('/')[0]].extend(records)
    for display, name in manifest['overviews'].items():
        write(output / name, overview_records(groups[display]))
        files[name] = sha((output / name).read_bytes())
    manifest.update(files=files, factionSchema=1, factionFactsHash=sha(facts_path.read_bytes()), questFactions=facts['questFactions'])
    manifest['generators']['map_factions.py'] = sha(Path(__file__).read_bytes())
    manifest['generators']['map_overlays.py'] = sha(Path(__file__).with_name('map_overlays.py').read_bytes())
    write(output / 'manifest.json', manifest)
    (output / 'LICENSE-AzerothCore.txt').write_bytes((overlays / 'LICENSE-AzerothCore.txt').read_bytes())
    print('Faction overlays:', sum(map(len, groups.values())), 'records;', len(files), 'chunks/overviews')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('acore-source', 'faction-dbc', 'overlays', 'facts-output', 'output'):
        parser.add_argument('--'+name, type=Path, required=True)
    args = parser.parse_args()
    if args.facts_output.exists():
        raise ValueError('Facts output must be new')
    write(args.facts_output, extract_facts(args.acore_source, args.faction_dbc, args.overlays))
    enrich(args.overlays, args.output, args.facts_output)
