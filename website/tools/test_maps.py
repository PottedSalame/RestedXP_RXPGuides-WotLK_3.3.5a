"""Map pipeline regressions; optional local archive/terrain checks, no network."""
import argparse
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile
import unittest
import map_extract as m

def synthetic_archive(path,member,payload,flags,crypt):
    # Tiny uncompressed MPQ for the real read-only helper. Hash/encryption
    # algorithm follows authorized libmpq common.c (GPL-2.0-or-later).
    mask=0xffffffff
    def hash_string(text,offset):
        a,b=0x7fed7fed,0xeeeeeeee
        for ch in text.upper().encode('ascii'):
            a=(crypt[offset+ch]^(a+b))&mask;b=(ch+a+b+(b<<5)+3)&mask
        return a
    def encrypt(raw,key):
        seed=hash_string(key,0x300);other=0xeeeeeeee;out=[]
        for word in struct.unpack('<'+'I'*(len(raw)//4),raw):
            other=(other+crypt[0x400+(seed&255)])&mask;out.append(word^((seed+other)&mask))
            seed=(((~seed<<21)+0x11111111)|(seed>>11))&mask;other=(word+other+(other<<5)+3)&mask
        return struct.pack('<'+'I'*len(out),*out)
    hashes=[b'\xff'*16 for _ in range(8)]
    hashes[hash_string(member,0)&7]=struct.pack('<IIHHI',hash_string(member,0x100),hash_string(member,0x200),0,0,0)
    hpos=32+len(payload);bpos=hpos+128
    header=struct.pack('<4sIIHH4I',b'MPQ\x1a',32,bpos+16,0,3,hpos,bpos,8,1)
    blocks=struct.pack('<4I',32,len(payload),len(payload),flags)
    path.write_bytes(header+payload+encrypt(b''.join(hashes),'(hash table)')+encrypt(blocks,'(block table)'))

class Maps(unittest.TestCase):
    def test_stock_inventory(self):
        with tempfile.TemporaryDirectory() as root:
            for name in [*m.STOCK,'patch-Z.mpq','enUS/patch-enUS-c.MPQ']:
                p=Path(root)/'Data'/name;p.parent.mkdir(parents=True,exist_ok=True);p.touch()
            archives,excluded=m.stock_archives(root)
            self.assertEqual([p.relative_to(Path(root)/'Data').as_posix() for p in archives],m.STOCK)
            self.assertIn('patch-z.mpq',excluded);self.assertIn('enus/patch-enus-c.mpq',excluded)
            archives[0].unlink()
            with self.assertRaisesRegex(ValueError,'missing'):m.stock_archives(root)

    def test_blp_bounds_and_formats(self):
        for alpha,length in [(0,32768),(1,65536),(7,65536)]:
            data=b'BLP2'+struct.pack('<I4BII',1,2,0 if alpha==0 else 8,alpha,1,256,256)
            data+=struct.pack('<16I',148,*([0]*15))+struct.pack('<16I',length,*([0]*15))+bytes(length)
            fmt,payload=m.texture(data);self.assertEqual(fmt,'dds_pipe');self.assertEqual(len(payload),128+length)
            with self.assertRaises(ValueError):m.texture(data[:-1])
        for depth in [0,1,4,8]:
            length=65536+(65536*depth+7)//8
            data=b'BLP2'+struct.pack('<I4BII',1,1,depth,0,1,256,256)
            data+=struct.pack('<16I',1172,*([0]*15))+struct.pack('<16I',length,*([0]*15))
            data+=bytes([5,10,20,0])*256+bytes(length)
            fmt,rgba=m.texture(data);self.assertEqual(fmt,'rawvideo');self.assertEqual(rgba[:3],bytes([20,10,5]));self.assertEqual(rgba[3],255 if depth==0 else 0)
        for data in [b'',b'BLP1'+bytes(200),b'BLP2'+bytes(200)]:
            with self.assertRaises(ValueError):m.texture(data)

    def test_mapping_missing_continent_and_duplicates(self):
        with self.assertRaisesRegex(ValueError,'Missing'):m.mappings(b'dir: Kalimdor\nmap01_02.blp aa.blp\n')
        with self.assertRaisesRegex(ValueError,'Conflicting'):m.mappings(b'dir: Kalimdor\nmap01_02.blp aa.blp\nmap01_02.blp bb.blp')

    def test_expansion_regions(self):
        # Same server X/Y placement branches as the current runtime adapter.
        for physical,x,y,expected in [(1,-610,-4253,1),(0,-9000,200,0),(530,10000,-7000,0),(530,-4000,-12000,1),(530,-200,4000,530),(571,4000,4000,571)]:
            display,u,v=m.project(physical,x,y);self.assertEqual(display,expected)
            regions=[r for r in m.regions() if r['physical']==physical and r['display']==display]
            self.assertTrue(any(r['clip'][0]<=u-r['offset'][0]<=r['clip'][2] and r['clip'][1]<=v-r['offset'][1]<=r['clip'][3] for r in regions))

    def test_actual_archive_precedence_deletion_missing_and_read_only(self):
        if not ARGS.helper or not ARGS.acore_source:self.skipTest('Pass local helper and AzerothCore source to exercise MPQ library')
        crypt=[int(n,16) for n in re.findall(r'0x([0-9a-f]{8})',(ARGS.acore_source/'deps/libmpq/libmpq/crypt_buf.h').read_text())]
        self.assertEqual(len(crypt),1280)
        with tempfile.TemporaryDirectory() as folder:
            base,patch,deleted=[Path(folder)/n for n in ('base.mpq','patch.mpq','deleted.mpq')]
            member='Textures\\Minimap\\test.blp'
            synthetic_archive(base,member,b'base',0x81000000,crypt)
            synthetic_archive(patch,member,b'patch',0x81000000,crypt)
            synthetic_archive(deleted,member,b'X',0x82000000,crypt)
            before={p.name:m.sha(p.read_bytes()) for p in (base,patch,deleted)}
            r=m.Reader(ARGS.helper,[patch,base])
            try:
                self.assertEqual(r.get(member),b'patch')
                with self.assertRaisesRegex(ValueError,'-10'):r.get('Textures\\Minimap\\missing.blp')
                with self.assertRaisesRegex(ValueError,'-23'):r.get('WTF\\Config.wtf')
            finally:r.close()
            r=m.Reader(ARGS.helper,[deleted,base])
            try:
                with self.assertRaisesRegex(ValueError,'-20'):r.get(member)
            finally:r.close()
            self.assertEqual(before,{p.name:m.sha(p.read_bytes()) for p in (base,patch,deleted)})

    def test_generated_receipts_and_four_continents(self):
        if not ARGS.assets:self.skipTest('Pass local assets to validate generation')
        receipt=json.loads((ARGS.assets/'receipt.json').read_text());manifest=json.loads((ARGS.assets/'manifest.json').read_text())
        self.assertEqual(set(manifest['tiles']),{'0','1','530','571'})
        for name,expected in receipt['files'].items():self.assertEqual(m.sha((ARGS.assets/name).read_bytes()),expected,name)
        from project_paths import source_matches
        for name,expected in receipt['generators'].items():self.assertTrue(source_matches('website/tools/'+name,expected),name)
        for region in manifest['regions']:self.assertEqual(len(region['clip']),4)
        zones={z['token']:z for z in manifest['zones']}
        for name in ['Durotar','Elwynn Forest','Hellfire Peninsula','BoreanTundra','Eversong Woods','Azuremyst Isle']:
            self.assertIn(name,zones)
        # Durotar stock bounds / published authored Kaltunk location.
        left,top,right,bottom=zones['Durotar']['bounds']
        self.assertAlmostEqual((-4253.52-left)/(right-left)*100,43.33,delta=.1)
        self.assertAlmostEqual((-610.073-top)/(bottom-top)*100,68.61,delta=.1)
        overlay=json.loads((ARGS.assets/'overlays/manifest.json').read_text())
        self.assertEqual(set(overlay['overviews']),{'0','1','530','571'})
        for name,expected in overlay['files'].items():self.assertEqual(m.sha((ARGS.assets/'overlays'/name).read_bytes()),expected,name)
        records=[]
        for name in overlay['chunks'].values():records.extend(json.loads((ARGS.assets/'overlays'/name).read_text(encoding='utf-8')))
        self.assertTrue(any(len(r['roles'])>=3 for r in records))
        self.assertTrue(any('alternate entry' in r['notes'] for r in records))
        self.assertTrue(any('pooled' in r['notes'] for r in records))
        for r in records:
            _,u,v=m.project(r['physical'],r['x'],r['y']);self.assertAlmostEqual(r['u'],u,places=3);self.assertAlmostEqual(r['v'],v,places=3)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('helper','acore-source','assets'):parser.add_argument('--'+name,type=Path)
    ARGS,rest=parser.parse_known_args()
    unittest.main(argv=[__file__,*rest])
