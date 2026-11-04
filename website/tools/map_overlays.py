"""Spatial snapshot overlays from authorized AzerothCore base SQL, read only."""
import argparse
from collections import defaultdict
import importlib.util
import math
import json
import re
from pathlib import Path
import subprocess
from map_extract import REPO, project, sha, write
from project_paths import require_addon
from map_professions import trainer_professions,trainer_classes,gathering_professions

def npc_roles(flags):
    return [role for bit,role in ((128,'vendor'),(16,'trainer'),(4096,'repair')) if flags & bit]

def exclusion(kind, template):
    # A trigger is a server helper, not a critter or a training dummy.
    # CreatureData.h: CREATURE_FLAG_EXTRA_TRIGGER = 0x80.
    if kind=='npcs' and template.get('flags_extra',0) & 0x80:
        return 'server-trigger flag (0x80)'
    if re.search(r'\bplaceholder\b|\bunused\b|\[obsolete\]',template['name'],re.I):
        return 'explicit placeholder/unused name'
    # Reviewed exact records; never remove real "Test Subject" creatures.
    if kind=='objects' and (template['entry'],template['name']) in ((2558,'Test'),(3523,'TEST Circle of Flame')):
        return 'explicit test object'
    return None

def pool_event_map(event_rows, parent_rows):
    direct={r['pool_entry']:r['eventEntry'] for r in event_rows}
    parents={r['pool_id']:r['mother_pool'] for r in parent_rows}
    def resolve(pool):
        seen=set();result=set()
        while pool is not None:
            if pool in seen:raise ValueError('Cyclic pool ancestry')
            seen.add(pool)
            if pool in direct:result.add(direct[pool])
            pool=parents.get(pool)
        if len(result)>1:raise ValueError('Conflicting event gates in pool ancestry')
        return sorted(result)
    return {pool:resolve(pool) for pool in sorted(set(direct)|set(parents))}

def overview_records(items):
    cells=defaultdict(list)
    for r in items:cells[(math.floor(r['u']/128),math.floor(r['v']/128))].append(r)
    records=[]
    for _,group in sorted(cells.items()):
        combinations=defaultdict(int)
        for r in group:
            dynamic=tuple((event,tuple(roles)) for event,roles in r.get('eventRoles',[]))
            combinations[(tuple(r['roles']),tuple(r.get('events',[])),dynamic)]+=1
        records.append(dict(kind='cluster',u=round(sum(r['u'] for r in group)/len(group),4),
            v=round(sum(r['v'] for r in group)/len(group),4),count=len(group),
            combinations=[[list(roles),count,list(events),[[e,list(rs)] for e,rs in dynamic]]
                for (roles,events,dynamic),count in sorted(combinations.items())],
            roles=sorted({role for r in group for role in r['roles']})))
    return records

def extract(source, output, profession_facts):
    source, output = source.resolve(), output.resolve()
    if output.exists() and any(output.iterdir()):
        raise ValueError('Output must be new or empty')
    addon=require_addon()
    spec = importlib.util.spec_from_file_location('sql', addon/'tools/extract_hardcore_quest_facts335.py')
    reader = importlib.util.module_from_spec(spec); spec.loader.exec_module(reader)
    inputs = {}
    facts=json.loads(profession_facts.read_text(encoding='utf-8'))
    if facts['schema']!=1:raise ValueError('Unsupported profession facts')
    inputs['profession-facts.json']=sha(profession_facts.read_bytes())
    def rows(table):
        path = source/'data/sql/base/db_world'/(table+'.sql')
        inputs[table+'.sql']=sha(path.read_bytes())
        return reader.read_rows(path,lambda _: True)
    revision=subprocess.check_output(['git','-c','safe.directory='+source.as_posix(),'-C',str(source),'rev-parse','HEAD'],text=True).strip()
    chunks=defaultdict(list)
    counts={}
    excluded=defaultdict(int)
    events={r['eventEntry']:dict(id=r['eventEntry'],name=r['description'],holiday=r['holiday']) for r in rows('game_event')}
    pool_events=pool_event_map(rows('game_event_pool'),rows('pool_pool'))
    used_events=set()
    # The SQL reader yields once; these small tables have multiple consumers.
    assignments=list(rows('creature_default_trainer'))
    trainer_rows=list(rows('trainer'))
    professions=trainer_professions(trainer_rows,rows('trainer_spell'),assignments)
    classes=trainer_classes(trainer_rows,assignments)
    for kind, table in [('npcs','creature'),('objects','gameobject')]:
        templates={r['entry']:r for r in rows(table+'_template')}
        starts, ends = defaultdict(list),defaultdict(list)
        for r in rows(table+'_queststarter'): starts[r['id']].append(r['quest'])
        for r in rows(table+'_questender'): ends[r['id']].append(r['quest'])
        event=defaultdict(set)
        for r in rows('game_event_'+table):event[r['guid']].add(r['eventEntry'])
        pools={r['guid']:r['pool_entry'] for r in rows('pool_'+table)}
        event_starts=defaultdict(list)
        for r in rows('game_event_'+table+'_quest'):event_starts[r['id']].append([r['eventEntry'],r['quest']])
        event_flags=defaultdict(list)
        if kind=='npcs':
            for r in rows('game_event_npcflag'):event_flags[r['guid']].append([r['eventEntry'],npc_roles(r['npcflag'])])
        vendors, trainers=set(),set()
        if kind=='npcs':
            vendors={r['entry'] for r in rows('npc_vendor')}
            trainers={r['ID'] for r in rows('npc_trainer')} | {r['CreatureId'] for r in assignments}
        count=0
        for r in rows(table):
            if r['map'] not in (0,1,530,571): continue
            ids=[r['id1'],r['id2'],r['id3']] if kind=='npcs' else [r['id']]
            for entry in dict.fromkeys(n for n in ids if n):
                t=templates.get(entry)
                if not t: raise ValueError('Spawn without template: '+str(entry))
                reason=exclusion(kind,t)
                if reason:
                    excluded[(kind,entry,t['name'],reason)]+=1
                    continue
                roles=[]
                if starts[entry]: roles.append('start')
                if ends[entry]: roles.append('end')
                if kind=='npcs':
                    flags=r['npcflag'] or t['npcflag']
                    roles.extend(npc_roles(flags))
                    if 'trainer' in roles:
                        roles.extend(professions.get(entry,[]))
                        if entry in classes:roles.append(classes[entry])
                    roles.append('creature')
                else:
                    roles.extend(gathering_professions(t,facts))
                    roles.append('object')
                notes=[]
                spawn_events=sorted(event[r['guid']] | set(pool_events.get(pools.get(r['guid']),[])))
                if spawn_events: notes.append('event-dependent')
                if r['guid'] in pools: notes.append('pooled')
                if r['phaseMask'] != 1: notes.append('phase mask '+str(r['phaseMask']))
                if r['spawnMask'] != 1: notes.append('spawn mask '+str(r['spawnMask']))
                if kind=='npcs':
                    if r['MovementType']: notes.append('moving / home position')
                    if len([n for n in ids if n])>1: notes.append('alternate entry')
                    if 'vendor' in roles and entry not in vendors: notes.append('vendor inventory not established')
                    if 'trainer' in roles and entry not in trainers: notes.append('trainer curriculum not established')
                if r.get('spawntimesecs',0)<0: notes.append('conditional spawn')
                physical=r['map']; x,y=r['position_x'],r['position_y']
                display,u,v=project(physical,x,y)
                # 512 native terrain pixels per chunk, independently of SQL zone IDs.
                key=f'{display}/{math.floor(u/512)}_{math.floor(v/512)}'
                record=dict(key=f'{kind}:{r["guid"]}:{entry}',kind=kind,id=entry,name=t['name'],
                    physical=physical,x=x,y=y,u=round(u,4),v=round(v,4),roles=roles,notes=notes,
                    starts=sorted(set(starts[entry])),ends=sorted(set(ends[entry])))
                if spawn_events:record['events']=spawn_events
                dynamic=defaultdict(set)
                for e,rs in event_flags[r['guid']]:dynamic[e].update(rs)
                for rs in dynamic.values():
                    if 'trainer' in rs:
                        rs.update(professions.get(entry,[]))
                        if entry in classes:rs.add(classes[entry])
                for e,q in event_starts[entry]:dynamic[e].add('start')
                if event_starts[entry]:record['eventStarts']=sorted(event_starts[entry])
                if dynamic:record['eventRoles']=[[e,sorted(rs)] for e,rs in sorted(dynamic.items()) if rs]
                used_events.update(abs(e) for e in spawn_events)
                used_events.update(dynamic)
                chunks[key].append(record)
                count+=1
        counts[kind]=count
    files={}
    index={}
    overview=defaultdict(list)
    for key,records in sorted(chunks.items()):
        name=key+'.json'
        write(output/name,sorted(records,key=lambda r:r['key']))
        files[name]=sha((output/name).read_bytes())
        index[key]=name
        overview[key.split('/')[0]].extend(records)
    overviews={}
    for display,items in sorted(overview.items()):
        records=overview_records(items)
        name=f'overview/{display}.json';write(output/name,records);files[name]=sha((output/name).read_bytes());overviews[display]=name
    license=(source/'LICENSE').read_text(encoding='utf-8')
    if 'Version 2, June 1991' not in license: raise ValueError('Review changed license')
    (output/'LICENSE-AzerothCore.txt').write_text(license,encoding='utf-8',newline='\n')
    notice='AzerothCore snapshot spawn/home locations. Base SQL only; updates/modules not applied. Not live positions or character-specific availability. AzerothCore contributors, GPL-2.0; https://github.com/azerothcore/azerothcore-wotlk/tree/'+revision+'/data/sql/base/db_world'
    if used_events-set(events):raise ValueError('Missing event definitions: '+str(sorted(used_events-set(events))))
    write(output/'manifest.json',dict(schema=2,chunkSize=512,chunks=index,overviews=overviews,counts=counts,sourceRevision=revision,
        events=[events[e] for e in sorted(used_events)],
        professions=facts['professions'],
        exclusions=[dict(kind=k,id=i,name=n,reason=r,count=c) for (k,i,n,r),c in sorted(excluded.items())],
        inputs=inputs,files=files,notice=notice,generators={p.name:sha(p.read_bytes()) for p in (Path(__file__),Path(__file__).with_name('map_extract.py'),Path(__file__).with_name('map_professions.py'),addon/'tools/extract_hardcore_quest_facts335.py')}))
    print(counts,'chunks:',len(chunks))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--acore-source',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--profession-facts',type=Path,default=Path(__file__).resolve().parents[1]/'map-assets-local/icons/profession-facts.json')
    args=parser.parse_args()
    extract(args.acore_source,args.output,args.profession_facts)
