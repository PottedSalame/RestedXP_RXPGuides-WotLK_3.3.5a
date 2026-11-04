"""Local-only stock 3.3.5 terrain extraction. No downloads or database access."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import re
import struct
import subprocess
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
from project_paths import require_addon
STOCK = ['enUS/patch-enUS-3.MPQ', 'enUS/patch-enUS-2.MPQ', 'enUS/patch-enUS.MPQ',
         'patch-3.MPQ', 'patch-2.MPQ', 'patch.MPQ',
         'enUS/lichking-locale-enUS.MPQ', 'enUS/expansion-locale-enUS.MPQ', 'enUS/locale-enUS.MPQ',
         'lichking.MPQ', 'expansion.MPQ', 'common-2.MPQ', 'common.MPQ']
MAPS = {'Azeroth': (0, 'Eastern Kingdoms'), 'Kalimdor': (1, 'Kalimdor'),
        'Expansion01': (530, 'Outland'), 'Northrend': (571, 'Northrend')}
ORIGIN, TILE = 17066.666666666668, 533.3333333333334
# Same expansion placements as the repository's HBD335 adapter. Coordinates
# are SERVER Y then X here, not percent coordinates on illustrated maps.
EXPANSIONS = [dict(display=0, bounds=[-10133.3, 4800, -2666.67, 16000], shift=[2662.8, -2400]),
              dict(display=1, bounds=[-16000, -6933.33, -8000, 533.33], shift=[17600, 10339.7])]

def project(physical, x, y):
    display, dy, dx = physical, 0, 0
    if physical == 530:
        for region in EXPANSIONS:
            a,b,c,d = region['bounds']
            if a <= y <= c and b <= x <= d:
                display, (dy, dx) = region['display'], region['shift']
                break
    return display, (ORIGIN-y-dy)*256/TILE, (ORIGIN-x-dx)*256/TILE

def regions():
    result = [dict(physical=m, display=m, clip=[0,0,16384,16384], offset=[0,0]) for m in (0,1,530,571)]
    holes = []
    for r in EXPANSIONS:
        a,b,c,d = r['bounds']
        clip = [(ORIGIN-c)*256/TILE,(ORIGIN-d)*256/TILE,(ORIGIN-a)*256/TILE,(ORIGIN-b)*256/TILE]
        holes.append(clip)
        result.append(dict(physical=530, display=r['display'], clip=clip, offset=[-r['shift'][0]*256/TILE,-r['shift'][1]*256/TILE]))
    result[2]['holes'] = holes
    return result

def sha(data):
    return hashlib.sha256(data).hexdigest()

def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, sort_keys=True, separators=(',', ':')) + '\n', encoding='utf-8', newline='\n')

def stock_archives(client):
    data = Path(client) / 'Data'
    files = {p.relative_to(data).as_posix().lower(): p for p in data.rglob('*') if p.suffix.lower() == '.mpq'}
    missing = [name for name in STOCK if name.lower() not in files]
    if missing:
        raise ValueError('Required stock archives missing: ' + ', '.join(missing))
    selected = [files[name.lower()] for name in STOCK]
    excluded = sorted(key for key in files if key not in {s.lower() for s in STOCK})
    return selected, excluded

class Reader:
    def __init__(self, helper, archives):
        self.process = subprocess.Popen([str(Path(helper).resolve()), *map(str, archives)], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        self.sources = {}

    def get(self, name):
        if '\n' in name or '\r' in name:
            raise ValueError('Invalid member')
        self.process.stdin.write(name.encode('ascii') + b'\n')
        self.process.stdin.flush()
        header = self.process.stdout.read(12)
        if len(header) != 12:
            raise ValueError('Archive reader stopped')
        status, archive, length = struct.unpack('<iii', header)
        if status:
            raise ValueError('Archive member failed: %s (status %s)' % (name, status))
        if not 0 < length <= 64 * 1024 * 1024:
            raise ValueError('Invalid member size')
        data = self.process.stdout.read(length)
        if len(data) != length:
            raise ValueError('Truncated member')
        self.sources[name] = {'archive': STOCK[archive], 'sha256': sha(data)}
        return data

    def close(self):
        self.process.stdin.close()
        self.process.stdout.close()
        if self.process.wait() != 0:
            raise ValueError('Archive reader failed')

def dbc(data):
    if len(data) < 20 or data[:4] != b'WDBC':
        raise ValueError('Not a WDBC table')
    count, fields, size, strings = struct.unpack_from('<4I', data, 4)
    if size != fields * 4 or 20 + count * size + strings != len(data):
        raise ValueError('Invalid DBC bounds')
    pool = data[20 + count * size:]
    def text(offset):
        if offset >= len(pool) or b'\0' not in pool[offset:]:
            raise ValueError('Invalid DBC string')
        return pool[offset:].split(b'\0', 1)[0].decode('utf-8')
    return [data[20 + i * size:20 + (i + 1) * size] for i in range(count)], text

def mappings(data):
    result, directory = {}, None
    for line in data.decode('utf-8-sig').splitlines():
        if line.startswith('dir: '):
            directory = line[5:].strip()
        else:
            match = re.fullmatch(r'(?:([^\s]+)[\\/])?map(\d\d)_(\d\d)\.blp\s+([\da-fA-F]+\.blp)', line.strip())
            if match and (match[1] or directory) in MAPS:
                key = (match[1] or directory, int(match[2]), int(match[3]))
                if key in result and result[key] != match[4]:
                    raise ValueError('Conflicting terrain mapping')
                result[key] = match[4]
    if {k[0] for k in result} != set(MAPS):
        raise ValueError('Missing continent terrain mappings')
    return result

def texture(data):
    """Validate BLP2 mip zero; return FFmpeg input format and decoded bytes.

    Paletted alpha is decoded here; DXT is placed in a bounded DDS container
    and decoded by the installed converter. Never upscale a source tile.
    """
    if len(data) < 148 or data[:4] != b'BLP2':
        raise ValueError('Unsupported texture: expected BLP2')
    kind = struct.unpack_from('<I', data, 4)[0]
    encoding, depth, alpha, mips = data[8:12]
    width, height = struct.unpack_from('<II', data, 12)
    offset, length = struct.unpack_from('<I', data, 20)[0], struct.unpack_from('<I', data, 84)[0]
    if kind != 1 or width != 256 or height != 256 or offset < 148 or offset + length > len(data):
        raise ValueError('Unsupported or malformed minimap dimensions/mip')
    pixels = width * height
    payload = data[offset:offset + length]
    if encoding == 1:
        if depth not in (0, 1, 4, 8) or offset < 1172 or length != pixels + (pixels * depth + 7) // 8:
            raise ValueError('Malformed paletted BLP2')
        rgba = bytearray(pixels * 4)
        for i, index in enumerate(payload[:pixels]):
            b, g, r, _ = data[148 + index * 4:152 + index * 4]
            a = 255 if not depth else ((payload[pixels + i * depth // 8] >> ((i * depth) % 8)) & ((1 << depth)-1)) * 255 // ((1 << depth)-1)
            rgba[i*4:i*4+4] = bytes((r, g, b, a))
        return 'rawvideo', bytes(rgba)
    if encoding == 2 and depth in (0, 1, 4, 8) and alpha in (0, 1, 7):
        fourcc = b'DXT1' if alpha == 0 else b'DXT3' if alpha == 1 else b'DXT5'
        expected = pixels // (2 if fourcc == b'DXT1' else 1)
        if length != expected:
            raise ValueError('Malformed DXT blocks')
        header = struct.pack('<7I', 124, 0x81007, height, width, length, 0, 0) + b'\0' * 44
        header += struct.pack('<II4s5I', 32, 4, fourcc, 0, 0, 0, 0, 0)
        header += struct.pack('<5I', 0x1000, 0, 0, 0, 0)
        return 'dds_pipe', b'DDS ' + header + payload
    raise ValueError('Unsupported BLP2 encoding')

def convert(converter, data, output):
    fmt, source = texture(data)
    output.parent.mkdir(parents=True, exist_ok=True)
    if fmt == 'dds_pipe':
        # FFmpeg's DDS demuxer requires a seekable input. Own exactly one
        # temporary file per conversion; never remove caller-owned outputs.
        with tempfile.NamedTemporaryFile(suffix='.dds', dir=output.parent, delete=False) as temp:
            temp.write(source)
            name = Path(temp.name)
        try:
            result = subprocess.run([str(converter), '-v','error','-threads','1','-i',str(name),'-frames:v','1',
                '-threads','1','-c:v','libwebp','-lossless','1','-compression_level','4','-f','webp','pipe:1'],capture_output=True,check=True).stdout
        finally:
            name.unlink()
        output.write_bytes(result)
        return sha(result)
    command = [str(converter), '-v', 'error', '-threads', '1', '-f', fmt]
    if fmt == 'rawvideo':
        command += ['-pixel_format', 'rgba', '-video_size', '256x256']
    command += ['-i', 'pipe:0', '-frames:v', '1', '-threads', '1', '-c:v', 'libwebp', '-lossless', '1', '-compression_level', '4', '-f', 'webp', 'pipe:1']
    result = subprocess.run(command, input=source, capture_output=True, check=True).stdout
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(result)
    return sha(result)

def zone_data(reader):
    rows, string = dbc(reader.get('DBFilesClient\\WorldMapArea.dbc'))
    catalogue = json.loads((REPO / 'website/data/catalogue.json').read_text(encoding='utf-8'))['maps']
    # Runtime aliases use compact filenames for several Wrath zones.
    aliases = {'Barrens':'The Barrens', 'Sunwell':'Isle of Quel\'Danas', 'Expansion01':'Outland',
        'Azeroth':'Eastern Kingdoms', 'Stormwind':'Stormwind City', 'SilvermoonCity':'Silvermoon City',
        'Ogrimmar':'Orgrimmar', 'Undercity':'Undercity', 'Darnassis':'Darnassus',
        'AzuremystIsle':'Azuremyst Isle', 'BloodmystIsle':'Bloodmyst Isle', 'EversongWoods':'Eversong Woods',
        'Netherstorm':'Netherstorm', 'Hellfire':'Hellfire Peninsula', 'ShadowmoonValley':'Shadowmoon Valley',
        'HrothgarsLanding':"Hrothgar's Landing", 'IcecrownGlacier':'Icecrown', 'TheExodar':'The Exodar',
        'Alterac':'Alterac Mountains','Arathi':'Arathi Highlands','Tirisfal':'Tirisfal Glades','Silverpine':'Silverpine Forest',
        'Hilsbrad':'Hillsbrad Foothills','Hinterlands':'The Hinterlands','Elwynn':'Elwynn Forest','Redridge':'Redridge Mountains',
        'Stranglethorn':'Stranglethorn Vale','Dustwallow':'Dustwallow Marsh','Aszhara':'Azshara','LakeWintergrasp':'Wintergrasp'}
    compact = lambda s: re.sub('[^a-z0-9]', '', s.lower())
    by_name = {compact(name): name for name in catalogue}
    zones = []
    for row in rows:
        values = struct.unpack('<' + 'I'*(len(row)//4), row)
        physical = values[1]
        if physical not in (0, 1, 530, 571) or values[9]:
            continue
        internal = string(values[3])
        token = aliases.get(internal, by_name.get(compact(internal)))
        if not token or token not in catalogue:
            continue
        left, right, top, bottom = struct.unpack_from('<4f', row, 16)
        if left <= right or top <= bottom:
            continue
        # These aliases apply a Classic→Wrath affine conversion in UI/Map.lua;
        # do not silently treat them as ordinary WotLK percentages.
        zones.append({'id': values[0], 'token': token, 'aliases': sorted(k for k,v in catalogue.items() if v == catalogue[token] and k not in ('StormwindClassic','EPLClassic')),
            'physical': physical, 'bounds': [left, top, right, bottom], 'internal': internal})
    return sorted(zones, key=lambda z: z['id'])

def parent_tile(converter, children, output):
    command = [str(converter), '-v', 'error', '-threads', '1']
    for child in children:
        command += ['-i', str(child)]
    filters = ';'.join('[%s:v]scale=128:128:flags=area,format=rgba[t%s]' % (i,i) for i in range(4))
    filters += ';[t0][t1][t2][t3]xstack=inputs=4:layout=0_0|128_0|0_128|128_128[out]'
    command += ['-filter_complex_threads', '1', '-filter_complex', filters, '-map', '[out]', '-frames:v', '1',
                '-threads', '1', '-c:v', 'libwebp', '-lossless', '1', '-compression_level', '4', '-f', 'webp', 'pipe:1']
    data = subprocess.run(command, capture_output=True, check=True).stdout
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(data)
    return sha(data)

def generate(args, reader, tiles, zones, excluded):
    output = args.output.resolve()
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a new or empty output directory; old evidence is never overwritten')
    output.mkdir(parents=True, exist_ok=True)
    files, levels = {}, {}
    blank = output / 'tiles/blank.webp'
    blank.parent.mkdir(parents=True, exist_ok=True)
    blank.write_bytes(subprocess.run([str(args.converter), '-v','error','-f','rawvideo','-pixel_format','rgba','-video_size','256x256',
        '-i','pipe:0','-frames:v','1','-threads','1','-c:v','libwebp','-lossless','1','-f','webp','pipe:1'], input=b'\0'*(256*256*4), capture_output=True, check=True).stdout)
    files['tiles/blank.webp'] = sha(blank.read_bytes())
    # Durotar first: no continent-sized images, at most four conversions queued.
    ordered = sorted(tiles, key=lambda k: (not(k[0]=='Kalimdor' and 35<=k[1]<=47 and 28<=k[2]<=36), k))
    with ThreadPoolExecutor(max_workers=4) as pool:
        pending = []
        seen = {}
        for index,key in enumerate(ordered):
            name, x, y = key
            source = tiles[key]
            if source not in seen:
                data = reader.get('Textures\\Minimap\\' + source)
                path = 'tiles/base/' + source[:-4] + '.webp'
                seen[source] = path
                pending.append((path, pool.submit(convert, args.converter, data, output/path)))
            levels.setdefault(str(MAPS[name][0]), {}).setdefault('6', {})[f'{x},{y}'] = seen[source]
            if len(pending) >= 4:
                path, task = pending.pop(0)
                files[path] = task.result()
            if index % 500 == 0:
                print('Terrain members:', index, '/', len(tiles), flush=True)
        for path, task in pending:
            files[path] = task.result()
        for physical, pyramid in sorted(levels.items()):
            for level in range(5,-1,-1):
                previous = pyramid[str(level+1)]
                current = pyramid[str(level)] = {}
                parents = sorted({(int(k.split(',')[0])//2,int(k.split(',')[1])//2) for k in previous})
                pending = []
                for x,y in parents:
                    path = f'tiles/{physical}/{level}/{x}_{y}.webp'
                    current[f'{x},{y}'] = path
                    children = [output/previous.get(f'{2*x+dx},{2*y+dy}', 'tiles/blank.webp') for dy in range(2) for dx in range(2)]
                    pending.append((path,pool.submit(parent_tile,args.converter,children,output/path)))
                    if len(pending)>=4:
                        p,t = pending.pop(0); files[p]=t.result()
                for p,t in pending:
                    files[p]=t.result()
            print('Pyramid complete:', physical, flush=True)
    for z in zones:
        left,top,right,bottom=z['bounds']
        z['display']=project(z['physical'],(top+bottom)/2,(left+right)/2)[0]
    manifest = dict(schema=1,tileSize=256,maxZoom=6,origin=ORIGIN,tileWorldSize=TILE,
        continents=[dict(id=number,name=name) for number,name in MAPS.values()], zones=zones,regions=regions(),tiles=levels,
        notice='Local stock client artwork; public redistribution not approved. Terrain is not a traversability map.')
    write(output/'manifest.json',manifest)
    files['manifest.json']=sha((output/'manifest.json').read_bytes())
    version=subprocess.check_output([str(args.converter),'-version'],text=True).splitlines()[0]
    write(output/'receipt.json',dict(schema=1,stockOrder=STOCK,excluded=excluded,members=reader.sources,files=files,
        converter=version,settings='256 native; WebP lossless compression 4; area-reduced pyramids',
        generators={p.name:sha(p.read_bytes()) for p in (Path(__file__),Path(__file__).with_name('map_archive.cpp'))},
        coordinates={'DB/wotlk/db.lua':sha((require_addon()/'DB/wotlk/db.lua').read_bytes()),'libs/HBD335/HereBeDragons-335.lua':sha((require_addon()/'libs/HBD335/HereBeDragons-335.lua').read_bytes())},
        source='Authorized local stock 3.3.5a client. Blizzard Entertainment artwork, not relicensed by this tool.'))
    print('Complete:', len(tiles), 'terrain tiles;', len(zones), 'mapped outdoor areas', flush=True)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ('client', 'helper', 'converter', 'output'):
        parser.add_argument('--' + key, type=Path, required=True)
    parser.add_argument('--inspect', action='store_true')
    args = parser.parse_args()
    archives, excluded = stock_archives(args.client)
    reader = Reader(args.helper, archives)
    try:
        trs = reader.get('Textures\\Minimap\\md5translate.trs')
        tiles = mappings(trs)
        zones = zone_data(reader)
        if args.inspect:
            print(json.dumps({'tiles': {name: sum(k[0] == name for k in tiles) for name in MAPS}, 'zones': zones, 'sample': list(tiles.items())[:3]}, indent=2))
            return
        generate(args, reader, tiles, zones, excluded)
    finally:
        reader.close()

if __name__ == '__main__':
    main()
