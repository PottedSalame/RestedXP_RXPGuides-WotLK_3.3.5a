"""Extract five stock client UI icons, read-only. Does not grant an artwork license."""
import argparse
from pathlib import Path
import struct
import subprocess
import tempfile
from map_extract import Reader, stock_archives, sha, write

MEMBERS = {
    'start': r'Interface\GossipFrame\AvailableQuestIcon.blp',
    'end': r'Interface\GossipFrame\ActiveQuestIcon.blp',
    'vendor': r'Interface\GossipFrame\VendorGossipIcon.blp',
    'trainer': r'Interface\GossipFrame\TrainerGossipIcon.blp',
    'repair': r'Interface\Minimap\Tracking\Repair.blp',
}

def decode(data):
    if len(data)<148 or data[:4]!=b'BLP2' or struct.unpack_from('<I',data,4)[0]!=1:
        raise ValueError('Unsupported icon texture')
    encoding,depth,alpha,_=data[8:12]
    w,h=struct.unpack_from('<II',data,12)
    offset=struct.unpack_from('<I',data,20)[0];length=struct.unpack_from('<I',data,84)[0]
    if not (4<=w<=256 and 4<=h<=256 and w&(w-1)==0 and h&(h-1)==0) or offset<148 or offset+length>len(data):
        raise ValueError('Invalid icon dimensions or mip bounds')
    pixels=w*h;payload=data[offset:offset+length]
    if encoding==1 and depth in (0,1,4,8):
        if offset<1172 or length!=pixels+(pixels*depth+7)//8:raise ValueError('Invalid palette bounds')
        rgba=bytearray(pixels*4)
        for i,index in enumerate(payload[:pixels]):
            b,g,r,_=data[148+4*index:152+4*index]
            a=255 if not depth else ((payload[pixels+i*depth//8]>>((i*depth)%8))&((1<<depth)-1))*255//((1<<depth)-1)
            rgba[4*i:4*i+4]=bytes((r,g,b,a))
        return w,h,'rawvideo',bytes(rgba)
    if encoding==2 and depth in (0,1,4,8) and alpha in (0,1,7):
        fourcc=b'DXT1' if alpha==0 else b'DXT3' if alpha==1 else b'DXT5'
        if length!=pixels//(2 if alpha==0 else 1):raise ValueError('Invalid DXT length')
        header=struct.pack('<7I',124,0x81007,h,w,length,0,0)+bytes(44)
        header+=struct.pack('<II4s5I',32,4,fourcc,0,0,0,0,0)+struct.pack('<5I',0x1000,0,0,0,0)
        return w,h,'dds',b'DDS '+header+payload
    raise ValueError('Unsupported icon encoding')

def extract(client,helper,converter,output):
    if output.exists() and any(output.iterdir()):raise ValueError('Output must be new or empty')
    output.mkdir(parents=True,exist_ok=True)
    archives,excluded=stock_archives(client);reader=Reader(helper,archives);icons={};files={}
    try:
        for role,member in MEMBERS.items():
            w,h,fmt,raw=decode(reader.get(member))
            with tempfile.TemporaryDirectory(prefix='icon-',dir=output) as scratch:
                path=Path(scratch)/('input.'+fmt);path.write_bytes(raw)
                command=[str(converter),'-v','error','-threads','1']
                if fmt=='rawvideo':command+=['-f','rawvideo','-pixel_format','rgba','-video_size',f'{w}x{h}']
                command+=['-i',str(path),'-frames:v','1','-threads','1','-c:v','libwebp','-lossless','1','-compression_level','4','-f','webp','pipe:1']
                converted=subprocess.check_output(command)
            name=role+'.webp';(output/name).write_bytes(converted);files[name]=sha(converted)
            icons[role]={'path':name,'width':w,'height':h}
    finally:reader.close()
    write(output/'manifest.json',dict(schema=1,icons=icons,files=files,members=reader.sources,excluded=excluded,
        generators={p.name:sha(p.read_bytes()) for p in (Path(__file__),Path(__file__).with_name('icon_archive.cpp'),Path(__file__).with_name('map_archive.cpp'))},
        notice='World of Warcraft client artwork: Blizzard Entertainment. Extracted and converted; not relicensed by RXPGuides.'))
    print('Extracted',len(icons),'stock UI icons')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('client','helper','converter','output'):parser.add_argument('--'+name,type=Path,required=True)
    a=parser.parse_args();extract(a.client,a.helper,a.converter,a.output)
