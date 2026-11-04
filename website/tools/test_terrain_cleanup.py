"""Exact pixel preservation and optional installed cleanup receipt tests."""
import argparse
import copy
import json
from pathlib import Path
import tempfile
import unittest

import map_terrain_cleanup as c


class Cleanup(unittest.TestCase):
    def test_edge_connected_only_and_other_pixels_unchanged(self):
        raw=bytearray(bytes((100,90,80,255))*65536)
        for y in range(256):
            for x in range(120,256):
                raw[(y*256+x)*4:(y*256+x+1)*4]=bytes((33,36,58,255) if x%2 else (29,34,53,255))
        # An isolated same-colour terrain pixel is not background.
        raw[1000:1004]=bytes((33,36,58,255))
        out,count=c.mask_pixels(bytes(raw),'edge-navy')
        self.assertEqual(count,136*256)
        for i in range(65536):
            self.assertEqual(out[i*4:i*4+4],bytes(4) if i%256>=120 else raw[i*4:i*4+4])
        self.assertEqual(c.mask_pixels(bytes(raw),'empty-border'),(bytes(len(raw)),65536))
        with self.assertRaises(ValueError):c.mask_pixels(b'bad','edge-navy')
        with self.assertRaises(ValueError):c.mask_pixels(bytes(raw),'guess')

    def test_review_scope_is_only_ghostlands_border(self):
        plan=json.loads(c.RECIPE.read_text())
        self.assertEqual((plan['region']['physical'],plan['region']['display']),(530,0))
        self.assertEqual(len(plan['tiles']),28)
        for e in plan['tiles']:
            x,y=map(int,e['key'].split(','))
            self.assertTrue(40<=x<=48 and 15<=y<=22)
            self.assertIn(e['mode'],('edge-navy','empty-border'))
            if e['mode']=='empty-border':self.assertTrue(x==48 or y==22)
            self.assertGreater(e['removedPixels'],0)

    def test_changed_manifest_fails_before_writing(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder);assets=root/'assets';assets.mkdir()
            (assets/'manifest.json').write_text('{}')
            with self.assertRaisesRegex(ValueError,'manifest changed'):
                c.generate(assets,Path('not-called'),root/'out')
            self.assertFalse((root/'out').exists())

    def test_installed_receipt_and_rejections(self):
        if not ARGS.assets:self.skipTest('Pass assets for actual cleaned tile checks')
        data=json.loads((ARGS.assets/'terrain-cleanup/manifest.json').read_text())
        c.validate(ARGS.assets,data)
        for mutate in [lambda d:d.update(sourceManifest='0'*64),lambda d:d.update(recipe='0'*64),
                       lambda d:d['generators'].clear(),lambda d:d['tiles']['0'].clear(),
                       lambda d:d['region'].update(display=1),lambda d:d['files'].update({'../private.webp':'0'*64}),
                       lambda d:d['files'].update({next(iter(d['files'])):'0'*64}),lambda d:d['inputs'].clear()]:
            bad=copy.deepcopy(data);mutate(bad)
            with self.assertRaises(ValueError):c.validate(ARGS.assets,bad)

    def test_actual_masks_preserve_retained_pixels(self):
        if not ARGS.assets or not ARGS.converter:self.skipTest('Pass assets and converter for pixel-level checks')
        plan=json.loads(c.RECIPE.read_text())
        for entry in plan['tiles']:
            original=c.decode(ARGS.converter,ARGS.assets/entry['source'])
            masked,count=c.mask_pixels(original,entry['mode'])
            self.assertEqual(count,entry['removedPixels'])
            output=c.decode(ARGS.converter,ARGS.assets/'terrain-cleanup/6'/ (entry['key'].replace(',','_')+'.webp'))
            for i in range(0,len(output),4):
                # WebP can discard RGB under transparent pixels, never alpha
                # or a retained visible terrain pixel.
                self.assertEqual(output[i+3],masked[i+3])
                if masked[i+3]:self.assertEqual(output[i:i+4],original[i:i+4])


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('assets','converter'):parser.add_argument('--'+name,type=Path)
    ARGS,rest=parser.parse_known_args()
    unittest.main(argv=[__file__,*rest])
