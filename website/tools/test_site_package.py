"""Offline client-icon decoding, role semantics and static packaging regressions."""
import json
from pathlib import Path
import struct
import tempfile
import unittest
from map_extract import sha,write
from map_icons import decode,MEMBERS
from map_overlays import npc_roles
from package_site import package,ROOT,checked

class SitePackage(unittest.TestCase):
    def test_icon_palette_and_bounds(self):
        for size in (16,32):
            pixels=size*size;length=pixels*2
            data=b'BLP2'+struct.pack('<I4BII',1,1,8,0,1,size,size)
            data+=struct.pack('<16I',1172,*([0]*15))+struct.pack('<16I',length,*([0]*15))
            data+=bytes((2,3,4,0))*256+bytes(pixels)+bytes([127])*pixels
            w,h,fmt,raw=decode(data)
            self.assertEqual((w,h,fmt),(size,size,'rawvideo'));self.assertEqual(raw[:4],bytes((4,3,2,127)))
            with self.assertRaises(ValueError):decode(data[:-1])
        for data in (b'',b'BLP1'+bytes(2048),b'BLP2'+bytes(2048)):
            with self.assertRaises(ValueError):decode(data)

    def test_repair_is_not_inferred_from_vendor(self):
        self.assertEqual(npc_roles(128),['vendor'])
        self.assertEqual(npc_roles(4096),['repair'])
        self.assertEqual(npc_roles(128|4096|16),['vendor','trainer','repair'])

    def fixtures(self,root):
        assets=root/'assets';assets.mkdir()
        write(assets/'manifest.json',dict(schema=1,tiles={str(k):{} for k in (0,1,530,571)}))
        write(assets/'receipt.json',dict(schema=1,files={'manifest.json':sha((assets/'manifest.json').read_bytes())}))
        write(assets/'overlays/manifest.json',dict(schema=2,files={},chunks={},overviews={},events=[]))
        (assets/'overlays/LICENSE-AzerothCore.txt').write_text('Fixture license')
        files={};icons={}
        for role in MEMBERS:
            name=role+'.webp';path=assets/'icons'/name;path.parent.mkdir(exist_ok=True);path.write_bytes(b'fixture')
            files[name]=sha(b'fixture');icons[role]={'path':name}
        write(assets/'icons/manifest.json',dict(schema=1,files=files,icons=icons,members={},notice='Client artwork'))
        return assets

    def test_deterministic_allowlist_and_no_client_requirement(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);assets=self.fixtures(root)
            (assets/'private.txt').write_text('must not ship')
            a=package(assets,root/'a');b=package(assets,root/'b');self.assertEqual(a,b)
            self.assertNotIn('map-assets/private.txt',a['files'])
            self.assertFalse(any(n.startswith(('tools/','tests/')) for n in a['files']))
            self.assertTrue((root/'a/map-assets/icons/repair.webp').exists())
            self.assertIn('../map-assets/',(root/'a/guide-editor/map-view.js').read_text())
            self.assertNotIn('../map-assets-local/',(root/'a/guide-editor/map-view.js').read_text())
            with self.assertRaisesRegex(ValueError,'empty'):package(assets,root/'a')

    def test_changed_or_missing_assets_fail_before_output(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);assets=self.fixtures(root)
            icon=assets/'icons/repair.webp';icon.write_bytes(b'changed')
            with self.assertRaisesRegex(ValueError,'Changed asset'):package(assets,root/'out')
            self.assertFalse((root/'out').exists());icon.unlink()
            with self.assertRaises(FileNotFoundError):package(assets,root/'out')

    def test_unsafe_manifest_paths_and_unreceipted_references(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);assets=self.fixtures(root)
            for path in ('../secret','/absolute','C:/private','tiles/../../private','tiles\\escape'):
                with self.assertRaises(ValueError):checked(assets,path)
            manifest=assets/'overlays/manifest.json'
            write(manifest,dict(schema=2,files={},chunks={'1/1_1':'1/1_1.json'},overviews={},events=[]))
            with self.assertRaisesRegex(ValueError,'Unreceipted overlay'):package(assets,root/'out')

if __name__=='__main__':unittest.main()
