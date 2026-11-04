"""Verify committed interior reference data without a client or database."""
import json
from pathlib import Path
import re
from map_extract import sha

PATH = r'(?:manifest\.json|LICENSE-AzerothCore\.txt|entities/\d+\.json|views/[a-z0-9-]+\.json|tiles/[0-9a-f]{32}\.webp)'


def validate(root):
    root = root.resolve()
    receipt = json.loads((root / 'receipt.json').read_text(encoding='utf-8'))
    if receipt.get('schema') != 1 or not isinstance(receipt.get('files'), dict):
        raise ValueError('Unsupported interior receipt')
    payload = {}
    for name, digest in receipt['files'].items():
        if not re.fullmatch(PATH, name):
            raise ValueError('Unexpected interior path: ' + name)
        path = root / name
        if any(p.is_symlink() or p.is_junction() for p in (path, *path.parents)):
            raise ValueError('Linked interior asset')
        raw = path.read_bytes()
        if sha(raw) != digest:
            raise ValueError('Changed interior asset: ' + name)
        payload[name] = raw
    for name, digest in receipt.get('generators', {}).items():
        if '/' in name or '\\' in name:
            raise ValueError('Invalid generator identity')
        local = Path(__file__).with_name(name)
        if local.exists() and sha(local.read_bytes()) != digest:
            raise ValueError('Stale interior generator: ' + name)
    def data(name):
        if name not in payload:
            raise ValueError('Unreceipted interior reference: ' + name)
        return json.loads(payload[name])
    def tiles(entries, unit, width, height):
        if not entries or len(entries) > 4096:
            raise ValueError('Invalid interior tiles')
        for key, tile in entries.items():
            if not re.fullmatch(r'\d+,\d+', key):
                raise ValueError('Invalid interior tile position')
            x, y = map(int, key.split(','))
            if x * unit >= width or y * unit >= height:
                raise ValueError('Interior tile outside sheet')
            if tile['path'] not in payload or not tile['path'].startswith('tiles/'):
                raise ValueError('Unreceipted interior image')
            if any(type(tile[d]) is not int or tile[d] not in (4, 8, 16, 32, 64, 128, 256) for d in ('width', 'height')):
                raise ValueError('Unsupported interior dimensions')
    manifest = data('manifest.json')
    if manifest.get('schema') != 1 or 'LICENSE-AzerothCore.txt' not in payload:
        raise ValueError('Missing interior manifest/license')
    regions = manifest['regions']
    if set(r['category'] for r in regions) != {'dungeons', 'raids', 'underground'}:
        raise ValueError('Missing interior categories')
    ids = set(); visited = set()
    events = {e['id'] for e in manifest['events']}
    for region in regions:
        if region['id'] in ids or region.get('coordinateSupport') is not False:
            raise ValueError('Duplicate or calibrated interior region')
        ids.add(region['id'])
        if region.get('entities'):
            if region['physical'] is None or region['entities'] != f"entities/{region['physical']}.json":
                raise ValueError('Foreign interior entities')
            for item in data(region['entities']):
                if item['kind'] not in ('npcs', 'objects') or type(item['id']) is not int or item['id'] <= 0:
                    raise ValueError('Invalid interior entity')
                if set(item) != {'kind','id','name','roles','notes','events','starts','ends','eventStarts','eventRoles','count'}:
                    raise ValueError('Unexpected interior entity fields')
                if not set(abs(e) for e in item['events']) <= events:
                    raise ValueError('Unknown interior event')
        for entry in region['views']:
            if entry['path'] != 'views/' + entry['id'] + '.json':
                raise ValueError('Foreign interior view')
            if entry['path'] in visited:
                continue
            visited.add(entry['path']); sheet = data(entry['path'])
            if sheet['id'] != entry['id'] or any(type(sheet[d]) is not int or not 0 < sheet[d] <= 16384 for d in ('width', 'height')):
                raise ValueError('Invalid interior sheet')
            tiles(sheet['tiles'], 256, sheet['width'], sheet['height'])
            if len(sheet['tiles']) > 64:
                small = sheet.get('overview', {})
                if small.get('unit') not in (512,1024,2048,4096,8192,16384) or len(small.get('tiles', {})) > 64:
                    raise ValueError('Missing bounded interior overview')
                tiles(small['tiles'], small['unit'], sheet['width'], sheet['height'])
    if visited != {n for n in payload if n.startswith('views/')}:
        raise ValueError('Unreferenced interior sheets')
    return payload


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assets', type=Path, required=True)
    args = parser.parse_args()
    files = validate(args.assets)
    print('Verified', len(files), 'interior files;', sum(map(len, files.values())), 'bytes')
