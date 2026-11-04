"""Reversible, hash-bound Ghostlands placeholder cleanup; original tiles are read-only.

Uses only the installed converter and the already extracted stock tiles. No
geographic transform, resampling of native terrain, or invented artwork.
"""
import argparse
from collections import deque
import json
from pathlib import Path
import re
import subprocess

from map_extract import sha, write, parent_tile

RECIPE = Path(__file__).with_name('fixtures') / 'ghostlands-terrain.json'
NAVY = {(33, 36, 58, 255), (29, 34, 53, 255)}


def mask_pixels(raw, mode):
    if len(raw) != 256 * 256 * 4:
        raise ValueError('Expected one native RGBA tile')
    if mode == 'empty-border':
        return bytes(len(raw)), 65536
    if mode != 'edge-navy':
        raise ValueError('Unknown cleanup rule')
    # Remove only the two reviewed flat-background colours connected to an
    # outer edge. Identically coloured isolated terrain pixels are retained.
    eligible = bytearray(tuple(raw[i:i+4]) in NAVY for i in range(0, len(raw), 4))
    pending = deque()
    for i in range(65536):
        if eligible[i] and (i < 256 or i >= 65280 or i % 256 in (0, 255)):
            pending.append(i)
            eligible[i] = 0
    result = bytearray(raw)
    removed = 0
    while pending:
        i = pending.popleft()
        result[i*4:i*4+4] = b'\0\0\0\0'
        removed += 1
        for j in (i-256, i+256, i-1 if i % 256 else -1, i+1 if i % 256 != 255 else -1):
            if 0 <= j < 65536 and eligible[j]:
                eligible[j] = 0
                pending.append(j)
    return bytes(result), removed


def decode(converter, path):
    return subprocess.check_output([str(converter), '-v', 'error', '-threads', '1', '-i', str(path),
                                    '-frames:v', '1', '-f', 'rawvideo', '-pix_fmt', 'rgba', 'pipe:1'])


def encode(converter, raw, path):
    data = subprocess.run([str(converter), '-v', 'error', '-threads', '1', '-f', 'rawvideo',
        '-pixel_format', 'rgba', '-video_size', '256x256', '-i', 'pipe:0', '-frames:v', '1',
        '-threads', '1', '-c:v', 'libwebp', '-lossless', '1', '-compression_level', '4', '-f', 'webp', 'pipe:1'],
        input=raw, capture_output=True, check=True).stdout
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def checked(root, name):
    from package_site import checked as safe
    return safe(root, name)


def validate(assets, cleanup, recipe=RECIPE):
    """Verify the optional derived layer without weakening original receipts."""
    plan = json.loads(recipe.read_text())
    source = checked(assets, 'manifest.json').read_bytes()
    manifest = json.loads(source)
    if cleanup.get('schema') != 1 or cleanup.get('sourceManifest') != sha(source) or plan['sourceManifest'] != sha(source):
        raise ValueError('Stale terrain cleanup source')
    if cleanup.get('region') != plan['region'] or plan['region'] not in manifest['regions'] or cleanup.get('recipe') != sha(recipe.read_bytes()):
        raise ValueError('Stale terrain cleanup recipe or region')
    expected_generators = {p.name:sha(p.read_bytes()) for p in (Path(__file__), Path(__file__).with_name('map_extract.py'))}
    if cleanup.get('generators') != expected_generators:
        raise ValueError('Stale terrain cleanup generator')
    original = manifest['tiles']['530']
    keys = {e['key'] for e in plan['tiles']}
    expected_files, expected_inputs = set(), {e['source']:e['sha256'] for e in plan['tiles']}
    if set(cleanup.get('tiles', {})) != set(map(str, range(7))) or set(cleanup.get('originalTiles', {})) != set(map(str, range(7))):
        raise ValueError('Incomplete terrain cleanup levels')
    for level in range(6, -1, -1):
        entries, sources = cleanup['tiles'][str(level)], cleanup['originalTiles'][str(level)]
        if set(entries) != keys or set(sources) != keys:
            raise ValueError('Unexpected terrain cleanup tiles')
        for key in keys:
            name = entries[key]
            if not re.fullmatch(r'[0-6]/\d+_\d+\.webp', name) or name != f'{level}/'+key.replace(',', '_')+'.webp' or sources[key] != original[str(level)][key]:
                raise ValueError('Invalid terrain cleanup mapping')
            expected_files.add(name)
        parents = {','.join(str(int(n)//2) for n in key.split(',')) for key in keys}
        if level:
            for key in parents:
                x, y = map(int, key.split(','))
                for dy in range(2):
                    for dx in range(2):
                        child = f'{x*2+dx},{y*2+dy}'
                        if child not in keys:
                            name = original[str(level)].get(child, 'tiles/blank.webp')
                            expected_inputs[name] = sha(checked(assets, name).read_bytes())
        keys = parents
    if set(cleanup.get('files', {})) != expected_files or cleanup.get('inputs') != expected_inputs:
        raise ValueError('Incomplete terrain cleanup receipt')
    for name, expected in expected_inputs.items():
        if sha(checked(assets, name).read_bytes()) != expected:
            raise ValueError('Changed terrain cleanup input')
    for name, expected in cleanup['files'].items():
        if sha(checked(assets/'terrain-cleanup', name).read_bytes()) != expected:
            raise ValueError('Changed terrain cleanup output')


def generate(assets, converter, output, recipe=RECIPE):
    assets, output = assets.resolve(), output.resolve()
    if output == assets or output.is_relative_to(assets) or assets.is_relative_to(output):
        raise ValueError('Output must be separate from the original assets')
    if any(p.is_symlink() or p.is_junction() for p in (output, *output.parents)):
        raise ValueError('Output may not contain links')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Output must be new or empty')
    plan = json.loads(recipe.read_text())
    manifest_bytes = checked(assets, 'manifest.json').read_bytes()
    manifest = json.loads(manifest_bytes)
    if plan['schema'] != 1 or sha(manifest_bytes) != plan['sourceManifest']:
        raise ValueError('Terrain manifest changed; review cleanup before regeneration')
    region = next(r for r in manifest['regions'] if r['physical'] == 530 and r['display'] == 0)
    if region != plan['region']:
        raise ValueError('Terrain placement changed')
    levels = manifest['tiles']['530']
    inputs, prepared = {}, []
    # Validate every reviewed source and pixel count before writing output.
    for entry in plan['tiles']:
        key = entry['key']
        if any(key == p[0] for p in prepared):
            raise ValueError('Duplicate cleanup tile')
        name = levels['6'][key]
        data = checked(assets, name).read_bytes()
        if name != entry['source'] or sha(data) != entry['sha256']:
            raise ValueError('Reviewed source tile changed: ' + key)
        raw, count = mask_pixels(decode(converter, assets/name), entry['mode'])
        if count != entry['removedPixels']:
            raise ValueError('Reviewed mask changed: ' + key)
        inputs[name] = sha(data)
        prepared.append((key, raw))
    output.mkdir(parents=True, exist_ok=True)
    replacements = {str(level): {} for level in range(7)}
    originals = {str(level): {} for level in range(7)}
    files = {}
    for key, raw in prepared:
        name = '6/' + key.replace(',', '_') + '.webp'
        encode(converter, raw, output/name)
        replacements['6'][key] = name
    for level in range(5, -1, -1):
        previous = replacements[str(level+1)]
        parents = sorted({tuple(int(n)//2 for n in key.split(',')) for key in previous})
        for x, y in parents:
            children = []
            for dy in range(2):
                for dx in range(2):
                    key = f'{x*2+dx},{y*2+dy}'
                    if key in previous:
                        children.append(output/previous[key])
                    else:
                        name = levels[str(level+1)].get(key, 'tiles/blank.webp')
                        path = checked(assets, name)
                        inputs[name] = sha(path.read_bytes())
                        children.append(path)
            name = f'{level}/{x}_{y}.webp'
            (output/name).parent.mkdir(parents=True, exist_ok=True)
            parent_tile(converter, children, output/name)
            replacements[str(level)][f'{x},{y}'] = name
    for level, entries in replacements.items():
        for key, name in entries.items():
            originals[level][key] = levels[level][key]
            files[name] = sha((output/name).read_bytes())
    result = dict(schema=1, region=region, sourceManifest=sha(manifest_bytes),
        originalTiles=originals, tiles=replacements, files=files, inputs=inputs,
        recipe=sha(recipe.read_bytes()), generators={Path(__file__).name:sha(Path(__file__).read_bytes()),
            'map_extract.py':sha(Path(__file__).with_name('map_extract.py').read_bytes())},
        converter=subprocess.check_output([str(converter), '-version'], text=True).splitlines()[0],
        notice='Blizzard Entertainment stock artwork. Reviewed empty Ghostlands borders made transparent; no terrain or markers moved.')
    write(output/'manifest.json', result)
    print(len(prepared), 'reviewed native tiles;', len(files), 'cleaned tiles including reduced zoom levels')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('assets', 'converter', 'output'):
        parser.add_argument('--'+name, type=Path, required=True)
    args = parser.parse_args()
    generate(args.assets, args.converter, args.output)
