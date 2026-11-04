"""Spatial snapshot overlays from authorized AzerothCore base SQL, read only."""
import argparse
from collections import defaultdict
import importlib.util
import math
from pathlib import Path
import subprocess
from map_extract import REPO, project, sha, write
from project_paths import require_addon

def npc_roles(flags):
    return [role for bit,role in ((128,'vendor'),(16,'trainer'),(4096,'repair')) if flags & bit]

def extract(source, output):
    source, output = source.resolve(), output.resolve()
    if output.exists() and any(output.iterdir()):
        raise ValueError('Output must be new or empty')
    addon=require_addon()
    spec = importlib.util.spec_from_file_location('sql', addon/'tools/extract_hardcore_quest_facts335.py')
    reader = importlib.util.module_from_spec(spec); spec.loader.exec_module(reader)
    inputs = {}
    def rows(table):
        path = source/'data/sql/base/db_world'/(table+'.sql')
        inputs[table+'.sql']=sha(path.read_bytes())
        return reader.read_rows(path,lambda _: True)
    revision=subprocess.check_output(['git','-c','safe.directory='+source.as_posix(),'-C',str(source),'rev-parse','HEAD'],text=True).strip()
    chunks=defaultdict(list)
    counts={}
    for kind, table in [('npcs','creature'),('objects','gameobject')]:
        templates={r['entry']:r for r in rows(table+'_template')}
        starts, ends = defaultdict(list),defaultdict(list)
        for r in rows(table+'_queststarter'): starts[r['id']].append(r['quest'])
        for r in rows(table+'_questender'): ends[r['id']].append(r['quest'])
        event={r['guid'] for r in rows('game_event_'+table)}
        pools={r['guid'] for r in rows('pool_'+table)}
        vendors, trainers=set(),set()
        if kind=='npcs':
            vendors={r['entry'] for r in rows('npc_vendor')}
            trainers={r['ID'] for r in rows('npc_trainer')} | {r['CreatureId'] for r in rows('creature_default_trainer')}
        count=0
        for r in rows(table):
            if r['map'] not in (0,1,530,571): continue
            ids=[r['id1'],r['id2'],r['id3']] if kind=='npcs' else [r['id']]
            for entry in dict.fromkeys(n for n in ids if n):
                t=templates.get(entry)
                if not t: raise ValueError('Spawn without template: '+str(entry))
                roles=[]
                if starts[entry]: roles.append('start')
                if ends[entry]: roles.append('end')
                if kind=='npcs':
                    flags=r['npcflag'] or t['npcflag']
                    roles.extend(npc_roles(flags))
                    roles.append('creature')
                else: roles.append('object')
                notes=[]
                if r['guid'] in event: notes.append('event-dependent')
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
                chunks[key].append(dict(key=f'{kind}:{r["guid"]}:{entry}',kind=kind,id=entry,name=t['name'],
                    physical=physical,x=x,y=y,u=round(u,4),v=round(v,4),roles=roles,notes=notes,
                    starts=sorted(set(starts[entry])),ends=sorted(set(ends[entry]))))
                count+=1
        counts[kind]=count
    files={}
    index={}
    overview=defaultdict(lambda:defaultdict(list))
    for key,records in sorted(chunks.items()):
        name=key+'.json'
        write(output/name,sorted(records,key=lambda r:r['key']))
        files[name]=sha((output/name).read_bytes())
        index[key]=name
        for r in records:
            overview[key.split('/')[0]][(math.floor(r['u']/128),math.floor(r['v']/128))].append(r)
    overviews={}
    for display,cells in sorted(overview.items()):
        records=[]
        for key,items in sorted(cells.items()):
            combinations=defaultdict(int)
            for r in items: combinations[tuple(r['roles'])]+=1
            records.append(dict(kind='cluster',u=round(sum(r['u'] for r in items)/len(items),4),
                v=round(sum(r['v'] for r in items)/len(items),4),count=len(items),
                combinations=[[list(roles),count] for roles,count in sorted(combinations.items())],
                roles=sorted({role for r in items for role in r['roles']})))
        name=f'overview/{display}.json';write(output/name,records);files[name]=sha((output/name).read_bytes());overviews[display]=name
    license=(source/'LICENSE').read_text(encoding='utf-8')
    if 'Version 2, June 1991' not in license: raise ValueError('Review changed license')
    (output/'LICENSE-AzerothCore.txt').write_text(license,encoding='utf-8',newline='\n')
    notice='AzerothCore snapshot spawn/home locations. Base SQL only; updates/modules not applied. Not live positions or character-specific availability. AzerothCore contributors, GPL-2.0; https://github.com/azerothcore/azerothcore-wotlk/tree/'+revision+'/data/sql/base/db_world'
    write(output/'manifest.json',dict(schema=1,chunkSize=512,chunks=index,overviews=overviews,counts=counts,sourceRevision=revision,
        inputs=inputs,files=files,notice=notice,generators={p.name:sha(p.read_bytes()) for p in (Path(__file__),Path(__file__).with_name('map_extract.py'),addon/'tools/extract_hardcore_quest_facts335.py')}))
    print(counts,'chunks:',len(chunks))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--acore-source',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    extract(args.acore_source,args.output)
