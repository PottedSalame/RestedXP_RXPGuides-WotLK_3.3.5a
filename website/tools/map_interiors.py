"""Read-only stock interior imagery and AzerothCore entity-reference extraction.

Images are reference sheets, not calibrated floors. No source/client/SQL writes.
"""
import argparse
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
import importlib.util
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from map_extract import Reader, stock_archives, dbc, sha, write
from map_icons import decode
from map_overlays import exclusion, npc_roles, pool_event_map
from project_paths import require_addon


def convert_interior(converter,data,path):
    w,h,fmt,raw=decode(data)
    path.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='decode-',dir=path.parent) as folder:
        source=Path(folder)/('tile.'+fmt);source.write_bytes(raw)
        command=[str(converter),'-v','error','-threads','1']
        if fmt=='rawvideo':command+=['-f','rawvideo','-pixel_format','rgba','-video_size',f'{w}x{h}']
        command+=['-i',str(source),'-frames:v','1','-threads','1','-c:v','libwebp','-lossless','1','-compression_level','4','-f','webp','pipe:1']
        result=subprocess.check_output(command)
    path.write_bytes(result)
    return sha(result),w,h


def overview(converter,output,view,files):
    if len(view['tiles'])<=64:return
    blank='tiles/'+sha(b'interior transparent padding')[:32]+'.webp'
    if blank not in files:
        result=subprocess.run([str(converter),'-v','error','-f','rawvideo','-pixel_format','rgba','-video_size','256x256',
            '-i','pipe:0','-frames:v','1','-threads','1','-c:v','libwebp','-lossless','1','-compression_level','4','-f','webp','pipe:1'],
            input=bytes(256*256*4),capture_output=True,check=True).stdout
        (output/blank).write_bytes(result);files[blank]=sha(result)
    previous=view['tiles'];unit=256
    while len(previous)>64:
        unit*=2;current={}
        for x,y in sorted({tuple(int(n)//2 for n in key.split(',')) for key in previous}):
            name='tiles/'+sha(f'interior overview:{view["id"]}:{unit}:{x}:{y}'.encode())[:32]+'.webp'
            if name in files:raise ValueError('Overview identity collision')
            command=[str(converter),'-v','error','-threads','1']
            for dy in range(2):
                for dx in range(2):command+=['-i',str(output/previous.get(f'{x*2+dx},{y*2+dy}',{'path':blank})['path'])]
            filters=';'.join(f'[{i}:v]format=rgba,pad=256:256:0:0:color=black@0,scale=128:128:flags=area[t{i}]' for i in range(4))
            filters+=';[t0][t1][t2][t3]xstack=inputs=4:layout=0_0|128_0|0_128|128_128[out]'
            result=subprocess.check_output(command+['-filter_complex_threads','1','-filter_complex',filters,'-map','[out]',
                '-frames:v','1','-threads','1','-c:v','libwebp','-lossless','1','-compression_level','4','-f','webp','pipe:1'])
            (output/name).write_bytes(result);files[name]=sha(result);current[f'{x},{y}']=dict(path=name,width=256,height=256)
        previous=current
    view['overview']=dict(unit=unit,tiles=previous)


def chunks(data):
    pos=0
    while pos<len(data):
        if pos+8>len(data):raise ValueError('Truncated map chunk')
        tag=data[pos:pos+4][::-1].decode('ascii')
        size=struct.unpack_from('<I',data,pos+4)[0]
        if size>64*1024*1024 or pos+8+size>len(data):raise ValueError('Invalid map chunk bounds')
        yield tag,data[pos+8:pos+8+size]
        pos+=8+size


def table(reader,name):
    rows,text=dbc(reader.get('DBFilesClient\\'+name+'.dbc'))
    return [struct.unpack('<'+'I'*(len(row)//4),row) for row in rows],text


def texture_index(data):
    terrain=defaultdict(dict);rooms=defaultdict(lambda:defaultdict(dict))
    for line in data.decode('utf-8-sig').splitlines():
        match=re.fullmatch(r'(.+)\s+([0-9a-fA-F]{32}\.blp)',line.strip())
        if not match:continue
        name=match[1].replace('/','\\');source=match[2].lower()
        t=re.fullmatch(r'([^\\]+)\\map(\d\d)_(\d\d)\.blp',name,re.I)
        w=re.fullmatch(r'(WMO\\.+)_(\d{3})_(\d\d)_(\d\d)\.blp',name,re.I)
        if t:target=terrain[t[1].lower()];key=(int(t[2]),int(t[3]))
        elif w:target=rooms['world\\'+w[1].lower()+'.wmo'][int(w[2])];key=(int(w[3]),int(w[4]))
        else:continue
        if max(key)>63:raise ValueError('Unsupported interior grid')
        if key in target and target[key]!=source:raise ValueError('Conflicting interior tile')
        target[key]=source
    return terrain,rooms


def optional(reader,name):
    try:return reader.get(name)
    except ValueError as error:
        # Absent/deleted assets are explicitly unavailable, not substituted.
        if str(error).endswith(('(status -10)','(status -20)')):return None
        raise


def sql_reader(source):
    path=require_addon()/'tools/extract_hardcore_quest_facts335.py'
    spec=importlib.util.spec_from_file_location('interior_sql',path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    inputs={}
    def rows(name):
        file=source/'data/sql/base/db_world'/(name+'.sql');inputs[name+'.sql']=sha(file.read_bytes())
        return module.read_rows(file,lambda _:True)
    return rows,inputs,path


def inventory(reader,instances):
    maps,text=table(reader,'Map')
    maps={v[0]:dict(id='map-'+str(v[0]),physical=v[0],name=text(v[5]),internal=text(v[1]),
                   category='underground' if v[0]==369 else 'raids' if v[2]==2 else 'dungeons',views=[],areaIds=[])
          for v in maps if ((v[2] in (1,2) and v[0] in instances) or v[0]==369) and v[0]!=169 and not re.search('unused|test|development',text(v[5]),re.I)}
    areas,text=table(reader,'AreaTable')
    areas={v[0]:dict(name=text(v[11]),physical=v[1],parent=v[2]) for v in areas if not re.search('unused|do not use|test|development',text(v[11]),re.I)}
    wmo_rows,_=table(reader,'WMOAreaTable');root_areas=defaultdict(set)
    for v in wmo_rows:
        if v[10] in areas:root_areas[v[1]].add(v[10])
    terrain,rooms=texture_index(reader.get('Textures\\Minimap\\md5translate.trs'))
    links=defaultdict(set);unavailable=[]
    # A WDT's explicit root association is stronger than guessing filenames.
    for number,region in sorted(maps.items()):
        folder=region['internal'];data=optional(reader,f'World\\Maps\\{folder}\\{folder}.wdt')
        occupied=set(terrain.get(folder.lower(),{}))
        if data:
            for tag,body in chunks(data):
                if tag=='MWMO':
                    for name in body.decode('utf-8').strip('\0').split('\0'):
                        if name:links[name.lower()].add(number)
                if tag=='MAIN':
                    if len(body)!=64*64*8:raise ValueError('Invalid WDT tile inventory')
                    occupied.update((i%64,i//64) for i in range(4096) if struct.unpack_from('<I',body,i*8)[0]&1)
        if terrain.get(folder.lower()):
            region['views'].append(('overview','Terrain overview',terrain[folder.lower()]))
        for x,y in sorted(occupied):
            tile=optional(reader,f'World\\Maps\\{folder}\\{folder}_{x}_{y}.adt')
            if tile:
                for tag,body in chunks(tile):
                    if tag=='MWMO':
                        for name in body.decode('utf-8').strip('\0').split('\0'):
                            if name:links[name.lower()].add(number)
    underground=[]
    for root,groups in sorted(rooms.items()):
        # Include dungeon pieces and explicit cave/underground/city interiors,
        # not the many houses, transports, decorative buildings or test assets.
        relevant=bool(links.get(root)) or any(s in root for s in ('\\dungeon\\','cave','\\undercity\\','\\dalaran\\','\\ironforge\\'))
        if not relevant or any(s in root for s in ('\\test','gm_dungeon','dragonisles')):continue
        data=optional(reader,root)
        if not data:
            unavailable.append(dict(source=root,reason='Root metadata absent in stock archive'));continue
        headers=[body for tag,body in chunks(data) if tag=='MOHD']
        if len(headers)!=1 or len(headers[0])<64:raise ValueError('Invalid WMO root header')
        area_ids=sorted(root_areas[struct.unpack_from('<I',headers[0],32)[0]])
        linked=set(links[root]) or {areas[a]['physical'] for a in area_ids if areas[a]['physical'] in maps}
        stem=root.rsplit('\\',1)[-1][:-4]
        views=[(sha(root.encode())[:16]+'-'+str(group),f'{stem} — section {group:03d}',tiles) for group,tiles in sorted(groups.items())]
        for number in linked:
            maps[number]['views'].extend(views);maps[number]['areaIds'].extend(area_ids)
        world_areas=[a for a in area_ids if areas[a]['physical'] in (0,1,530,571)]
        # Shared caves without area metadata are still honest reference sheets;
        # they get no inferred world location or entity associations.
        subterranean=any(s in root for s in ('cave','barrow','crypt','goldmine','mine','tunnel','subway','undercity','dalaran','ironforge','sinkhole','den.wmo'))
        if subterranean and world_areas and not any(s in root for s in ('pvp_','arena','facade')):
            names=sorted({areas[a]['name'] for a in world_areas if areas[a]['name']})
            underground.append(dict(id='wmo-'+sha(root.encode())[:16],category='underground',
                name=(' / '.join(names[:3]) if names else stem.replace('_',' '))+' — '+stem,
                physical=None,areaIds=world_areas,source=root,views=views,
                shared=True,entityScope='No verified spawn-to-interior association; use reference lookup.'))
    regions=[*maps.values(),*underground]
    for r in regions:
        r['areaIds']=sorted(set(r['areaIds']))
        r['coordinateSupport']=False
        if r['physical'] is not None:r['entityScope']='Entire instance; floor/room and live availability unverified.'
    return sorted(regions,key=lambda r:(r['category'],r['name'],r['id'])),unavailable


def entities(rows,physical_maps):
    events={r['eventEntry']:dict(id=r['eventEntry'],name=r['description'],holiday=r['holiday']) for r in rows('game_event')}
    pool_events=pool_event_map(rows('game_event_pool'),rows('pool_pool'))
    result=defaultdict(list);excluded=defaultdict(int)
    for kind,table_name in [('npcs','creature'),('objects','gameobject')]:
        templates={r['entry']:r for r in rows(table_name+'_template')}
        starts,ends=defaultdict(set),defaultdict(set)
        for r in rows(table_name+'_queststarter'):starts[r['id']].add(r['quest'])
        for r in rows(table_name+'_questender'):ends[r['id']].add(r['quest'])
        gates=defaultdict(set)
        for r in rows('game_event_'+table_name):gates[r['guid']].add(r['eventEntry'])
        pools={r['guid']:r['pool_entry'] for r in rows('pool_'+table_name)}
        quest_events=defaultdict(list)
        for r in rows('game_event_'+table_name+'_quest'):quest_events[r['id']].append([r['eventEntry'],r['quest']])
        flags=defaultdict(list)
        if kind=='npcs':
            for r in rows('game_event_npcflag'):flags[r['guid']].append([r['eventEntry'],npc_roles(r['npcflag'])])
        grouped={}
        for r in rows(table_name):
            if r['map'] not in physical_maps:continue
            ids=[r['id1'],r['id2'],r['id3']] if kind=='npcs' else [r['id']]
            for entry in sorted(set(i for i in ids if i)):
                t=templates[entry];reason=exclusion(kind,t)
                if reason:excluded[(kind,entry,t['name'],reason)]+=1;continue
                roles=(['start'] if starts[entry] else [])+(['end'] if ends[entry] else [])
                roles+=(npc_roles(r['npcflag'] or t['npcflag'])+['creature']) if kind=='npcs' else ['object']
                notes=[]
                if r['phaseMask']!=1:notes.append('phase mask '+str(r['phaseMask']))
                if r['spawnMask']!=1:notes.append('spawn mask '+str(r['spawnMask']))
                if r['guid'] in pools:notes.append('pooled')
                if r.get('MovementType'):notes.append('moving / home spawn')
                if len(set(ids)-{0})>1:notes.append('alternate entry')
                if r.get('spawntimesecs',0)<0:notes.append('conditional spawn')
                event_ids=sorted(gates[r['guid']]|set(pool_events.get(pools.get(r['guid']),[])))
                dynamic=sorted(flags[r['guid']])
                key=(r['map'],entry,json.dumps([roles,notes,event_ids,dynamic]))
                if key not in grouped:
                    grouped[key]=dict(kind=kind,id=entry,name=t['name'],roles=roles,notes=notes,events=event_ids,
                        starts=sorted(starts[entry]),ends=sorted(ends[entry]),eventStarts=sorted(quest_events[entry]),eventRoles=dynamic,count=0)
                grouped[key]['count']+=1
        for (physical,_,_),record in sorted(grouped.items()):result[physical].append(record)
    return result,[events[k] for k in sorted(events)], [dict(kind=k,id=i,name=n,reason=r,count=c) for (k,i,n,r),c in sorted(excluded.items())]


def generate(args):
    output=args.output.resolve()
    if any(p.is_symlink() or p.is_junction() for p in (output,*output.parents)):raise ValueError('Linked output refused')
    if output.exists() and any(output.iterdir()):raise ValueError('Output must be new or empty')
    rows,sql_inputs,sql_tool=sql_reader(args.acore_source.resolve())
    instances={r['map'] for r in rows('instance_template')}
    archives,excluded=stock_archives(args.client);reader=Reader(args.helper,archives)
    try:
        regions,unavailable=inventory(reader,instances)
        if args.inspect:
            print(json.dumps(dict(regions=[dict(id=r['id'],name=r['name'],views=len(r['views']),category=r['category']) for r in regions],
                textures=len({s for r in regions for _,_,ts in r['views'] for s in ts.values()}),unavailable=unavailable),indent=2));return
        output.mkdir(parents=True,exist_ok=True)
        sources=sorted({s for r in regions for _,_,ts in r['views'] for s in ts.values()})
        files={};sizes={};missing=set()
        with ThreadPoolExecutor(max_workers=4) as pool:
            pending=[]
            for i,source in enumerate(sources):
                raw=optional(reader,'Textures\\Minimap\\'+source)
                if raw is None:missing.add(source);continue
                name='tiles/'+source[:-4]+'.webp'
                pending.append((name,pool.submit(convert_interior,args.converter,raw,output/name)))
                if len(pending)>=4:
                    p,task=pending.pop(0);digest,w,h=task.result();files[p]=digest;sizes[p]=[w,h]
                if i%200==0:print('Interior textures',i,'/',len(sources),flush=True)
            for p,task in pending:
                digest,w,h=task.result();files[p]=digest;sizes[p]=[w,h]
        views={}
        for region in regions:
            selected=[]
            for key,title,tiles in region['views']:
                view_id=region['id']+'-'+key if key=='overview' else key
                if view_id not in views:
                    available={xy:source for xy,source in tiles.items() if source not in missing}
                    if not available:continue
                    minx=min(x for x,y in tiles);miny=min(y for x,y in tiles)
                    maxx=max(x for x,y in tiles);maxy=max(y for x,y in tiles)
                    if (maxx-minx+1)*(maxy-miny+1)>4096:raise ValueError('Oversized interior sheet')
                    entries={f'{x-minx},{y-miny}':dict(path='tiles/'+s[:-4]+'.webp',width=sizes['tiles/'+s[:-4]+'.webp'][0],height=sizes['tiles/'+s[:-4]+'.webp'][1]) for (x,y),s in sorted(available.items())}
                    views[view_id]=dict(id=view_id,title=title,width=max(int(k.split(',')[0])*256+t['width'] for k,t in entries.items()),height=max(int(k.split(',')[1])*256+t['height'] for k,t in entries.items()),
                        tiles=entries,
                        incomplete=len(available)!=len(tiles))
                selected.append(view_id)
            region['views']=list(dict.fromkeys(selected))
            if not selected:region['imageryUnavailable']=True
        for key,view in sorted(views.items()):
            overview(args.converter,output,view,files)
            name='views/'+key+'.json';write(output/name,view);files[name]=sha((output/name).read_bytes())
        data,events,exclusions=entities(rows,{r['physical'] for r in regions if r['physical'] is not None})
        for region in regions:
            region['views']=[dict(id=k,title=views[k]['title'],path='views/'+k+'.json') for k in region['views']]
            if region['physical'] is not None:
                name='entities/'+str(region['physical'])+'.json';records=data[region['physical']]
                write(output/name,records);files[name]=sha((output/name).read_bytes());region['entities']=name;region['entityCount']=len(records)
        revision=subprocess.check_output(['git','-c','safe.directory='+args.acore_source.resolve().as_posix(),'-C',str(args.acore_source),'rev-parse','HEAD'],text=True).strip()
        manifest=dict(schema=1,regions=regions,events=events,notice='Stock client reference images; sections are not calibrated floors. Entities: offline AzerothCore base snapshot, not live or floor-specific.',
            unavailable=unavailable,missingTextures=sorted(missing),exclusions=exclusions)
        write(output/'manifest.json',manifest);files['manifest.json']=sha((output/'manifest.json').read_bytes())
        license=(args.acore_source/'LICENSE').read_bytes()
        if b'Version 2, June 1991' not in license:raise ValueError('Review changed AzerothCore license')
        (output/'LICENSE-AzerothCore.txt').write_bytes(license);files['LICENSE-AzerothCore.txt']=sha(license)
        generators=[Path(__file__),Path(__file__).with_name('map_extract.py'),Path(__file__).with_name('map_overlays.py'),Path(__file__).with_name('map_icons.py'),Path(__file__).with_name('map_archive.cpp'),Path(__file__).with_name('interior_archive.cpp'),sql_tool]
        write(output/'receipt.json',dict(schema=1,files=files,members=reader.sources,excludedArchives=excluded,sqlInputs=sql_inputs,sourceRevision=revision,
            generators={p.name:sha(p.read_bytes()) for p in generators},converter=subprocess.check_output([str(args.converter),'-version'],text=True).splitlines()[0],
            notice='Blizzard Entertainment client artwork; AzerothCore snapshot data GPL-2.0. Read-only extraction; no world coordinate calibration.'))
        print('Complete:',len(regions),'regions;',len(views),'reference views;',len(sources)-len(missing),'unique textures',flush=True)
    finally:reader.close()


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('client','helper','converter','acore-source','output'):parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--inspect',action='store_true')
    generate(parser.parse_args())
