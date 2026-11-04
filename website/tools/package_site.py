"""Build a static Pages payload with verified terrain/icons; never deploy or upload."""
import argparse
import json
from pathlib import Path
import re
from map_extract import REPO, sha, write
from map_professions import PROFESSIONS,CLASSES

ROOT=REPO/'website'
STATIC=['index.html','help.html','credits.html','style.css','guide-editor/index.html',
        'guide-editor/app.js','guide-editor/model.js','guide-editor/wowhead.js','guide-editor/workspace.js',
        'guide-editor/map-model.js','guide-editor/map-view.js','guide-editor/map-markers.js','guide-editor/interior-view.js','data/catalogue.json',
        'data/LICENSE-AzerothCore.txt','data/NOTICE.txt']
NOTICE='World of Warcraft client artwork: Blizzard Entertainment. Extracted and converted; not relicensed by RXPGuides. Terrain is not a traversability map.'

def checked(root,name):
    if not isinstance(name,str) or not re.fullmatch(r'[A-Za-z0-9_.,/\-]+',name) or '..' in name or name.startswith('/'):
        raise ValueError('Unsafe asset path')
    path=root/name
    if not path.resolve().is_relative_to(root.resolve()) or any(p.is_symlink() or p.is_junction() for p in (path,*path.parents) if p.is_relative_to(root)):
        raise ValueError('Asset escapes source directory')
    return path

def verified(root,receipt,extension):
    result={}
    for name,expected in receipt['files'].items():
        if not name.endswith(extension):raise ValueError('Unexpected asset type: '+name)
        path=checked(root,name);data=path.read_bytes()
        if sha(data)!=expected:raise ValueError('Changed asset: '+name)
        result[name]=data
    return result

def package(assets,output,root=ROOT):
    assets=assets.resolve();root=root.resolve();output=output.absolute()
    if any(p.is_symlink() or p.is_junction() for p in (output,*output.parents)):
        raise ValueError('Output may not contain links')
    output=output.resolve()
    if output==assets or output.is_relative_to(root) or assets.is_relative_to(output):
        raise ValueError('Output must be separate from website and asset inputs')
    if output.exists() and any(output.iterdir()):raise ValueError('Output must be new or empty')
    terrain=json.loads((assets/'receipt.json').read_text())
    overlay=json.loads((assets/'overlays/manifest.json').read_text())
    icons=json.loads((assets/'icons/manifest.json').read_text())
    if terrain['schema']!=1 or overlay['schema']!=2 or icons['schema']!=1:raise ValueError('Unsupported asset schema')
    icon_names={'start','end','vendor','trainer','repair'}|{'profession-'+key for _,key,_,_ in PROFESSIONS}|{'class-'+key for _,key,_ in CLASSES}
    if set(icons['icons'])!=icon_names:raise ValueError('Missing client icons')
    facts=(assets/'icons/profession-facts.json').read_bytes()
    if sha(facts)!=icons.get('factsHash') or sha(facts)!=overlay.get('inputs',{}).get('profession-facts.json'):
        raise ValueError('Changed or mismatched profession facts')
    payload={name:checked(root,name).read_bytes() for name in STATIC}
    payload['LICENSE-RXPGuides.txt']=(REPO/'LICENSE').read_bytes()
    payload['map-assets/icons/profession-facts.json']=facts
    from validate_interiors import validate as validate_interiors
    for name,data in validate_interiors(assets/'interiors').items():
        payload['map-assets/interiors/'+name]=data
    for prefix,source,receipt,ext in [('',assets,terrain,('.webp','.json')),
        ('overlays/',assets/'overlays',overlay,('.json',)),('icons/',assets/'icons',icons,('.webp',))]:
        patterns={'':r'(?:manifest\.json|tiles/blank\.webp|tiles/base/[0-9a-f]{32}\.webp|tiles/(?:0|1|530|571)/[0-6]/\d+_\d+\.webp)',
                  'overlays/':r'(?:(?:0|1|530|571)/-?\d+_-?\d+|overview/(?:0|1|530|571))\.json',
                  'icons/':r'(?:'+'|'.join(sorted(icon_names))+r')\.webp'}
        for name,data in verified(source,receipt,ext).items():
            if not re.fullmatch(patterns[prefix],name):raise ValueError('Unexpected payload path: '+name)
            payload['map-assets/'+prefix+name]=data
    manifest=json.loads(payload['map-assets/manifest.json'])
    if any(r.get('physical')==530 and r.get('display')==0 for r in manifest.get('regions',[])):
        from map_terrain_cleanup import validate
        cleanup_bytes=checked(assets,'terrain-cleanup/manifest.json').read_bytes()
        cleanup=json.loads(cleanup_bytes)
        validate(assets,cleanup)
        payload['map-assets/terrain-cleanup/manifest.json']=cleanup_bytes
        for name,data in verified(assets/'terrain-cleanup',cleanup,('.webp',)).items():
            payload['map-assets/terrain-cleanup/'+name]=data
    if set(manifest['tiles'])!={'0','1','530','571'}:raise ValueError('Missing terrain continent')
    for levels in manifest['tiles'].values():
        for tiles in levels.values():
            for name in tiles.values():
                checked(assets,name)
                if 'map-assets/'+name not in payload:raise ValueError('Unreceipted terrain tile')
    for name in [*overlay['chunks'].values(),*overlay['overviews'].values()]:
        if 'map-assets/overlays/'+name not in payload:raise ValueError('Unreceipted overlay')
    for role,entry in icons['icons'].items():
        if entry['path']!=role+'.webp' or 'map-assets/icons/'+entry['path'] not in payload:raise ValueError('Unreceipted icon')
    manifest['notice']=NOTICE
    def encoded(data):return (json.dumps(data,ensure_ascii=False,sort_keys=True,separators=(',',':'))+'\n').encode('utf-8')
    payload['map-assets/manifest.json']=encoded(manifest)
    payload['map-assets/overlays/manifest.json']=encoded(overlay)
    payload['map-assets/overlays/LICENSE-AzerothCore.txt']=(assets/'overlays/LICENSE-AzerothCore.txt').read_bytes()
    payload['map-assets/icons/manifest.json']=encoded({key:icons[key] for key in ('schema','icons','files','members','notice')})
    name='guide-editor/map-view.js';old=b"../map-assets-local/";new=b"../map-assets/"
    if payload[name].count(old)!=1:raise ValueError('Review changed map asset URL')
    payload[name]=payload[name].replace(old,new)
    payload['.nojekyll']=b''
    output.mkdir(parents=True,exist_ok=True)
    for name,data in sorted(payload.items()):
        path=output/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
    receipt={'schema':1,'files':{name:sha(data) for name,data in sorted(payload.items())},
             'bytes':sum(map(len,payload.values())),'sourceReceipts':{name:sha((assets/name).read_bytes()) for name in ('receipt.json','overlays/manifest.json','icons/manifest.json','interiors/receipt.json')},
             'notice':NOTICE}
    write(output/'site-receipt.json',receipt)
    print(len(payload),'static files;',receipt['bytes'],'bytes; client terrain and icons included; not deployed')
    return receipt

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assets',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    a=parser.parse_args();package(a.assets,a.output)
