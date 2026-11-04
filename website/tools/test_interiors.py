"""Interior extraction, evidence and view-only scope regressions."""
import json
from pathlib import Path
import struct
import tempfile
import unittest
from map_extract import sha, write
from map_interiors import chunks, texture_index, optional, entities
from validate_interiors import validate


def fixture(root):
    image = 'tiles/' + 'a' * 32 + '.webp'
    (root/'tiles').mkdir(parents=True)
    (root/image).write_bytes(b'fixture')
    sheet = dict(id='one', title='Section', width=64, height=128,
                 tiles={'0,0':dict(path=image,width=64,height=128)}, incomplete=False)
    write(root/'views/one.json', sheet)
    records = [dict(kind='npcs',id=7,name='NPC',roles=['creature'],notes=[],events=[],starts=[12],ends=[],eventStarts=[],eventRoles=[],count=1)]
    write(root/'entities/33.json', records)
    write(root/'manifest.json', dict(schema=1,events=[],regions=[
        dict(id=str(i),category=kind,physical=33 if i==0 else None,coordinateSupport=False,
             views=[dict(id='one',path='views/one.json',title='Section')],
             **({'entities':'entities/33.json'} if i==0 else {}))
        for i,kind in enumerate(('dungeons','raids','underground'))]))
    (root/'LICENSE-AzerothCore.txt').write_text('Fixture license')
    receipt = dict(schema=1,generators={},files={p.relative_to(root).as_posix():sha(p.read_bytes()) for p in root.rglob('*') if p.is_file()})
    write(root/'receipt.json',receipt)
    return receipt


class Interiors(unittest.TestCase):
    def test_instance_entities_preserve_roles_events_and_exclude_helpers(self):
        tables={
            'game_event':[dict(eventEntry=2,description='Festival',holiday=141)],
            'creature_template':[dict(entry=7,name='Trainer',npcflag=16|4096,flags_extra=0),dict(entry=8,name='World Trigger',npcflag=0,flags_extra=0x80)],
            'creature_queststarter':[dict(id=7,quest=12)],'creature_questender':[dict(id=7,quest=13)],
            'game_event_creature_quest':[dict(id=7,eventEntry=2,quest=14)],
            'game_event_pool':[dict(pool_entry=20,eventEntry=2)],
            'pool_pool':[dict(pool_id=21,mother_pool=20)],
            'pool_creature':[dict(guid=100,pool_entry=21)],
            'creature':[dict(guid=100,map=33,id1=7,id2=0,id3=0,npcflag=0,phaseMask=2,spawnMask=3,MovementType=1),
                        dict(guid=101,map=33,id1=8,id2=0,id3=0,npcflag=0,phaseMask=1,spawnMask=1),
                        dict(guid=102,map=34,id1=7,id2=0,id3=0,npcflag=0,phaseMask=1,spawnMask=1)],
            'gameobject_template':[dict(entry=9,name='Chest')],
            'gameobject':[dict(guid=200,map=33,id=9,phaseMask=1,spawnMask=1)],
        }
        data,events,excluded=entities(lambda name:iter(tables.get(name,[])),{33})
        self.assertEqual(set(data),{33});self.assertEqual(len(data[33]),2)
        npc=next(r for r in data[33] if r['kind']=='npcs')
        self.assertEqual(npc['roles'],['start','end','trainer','repair','creature'])
        self.assertEqual(npc['events'],[2]);self.assertEqual(npc['eventStarts'],[[2,14]])
        self.assertIn('pooled',npc['notes']);self.assertIn('moving / home spawn',npc['notes'])
        self.assertNotIn('guid',npc);self.assertNotIn('x',npc)
        self.assertEqual(excluded[0]['id'],8);self.assertEqual(events[0]['id'],2)

    def test_chunk_boundaries(self):
        raw=b'OMWM'+struct.pack('<I',4)+b'abc\0'
        self.assertEqual(list(chunks(raw)), [('MWMO', b'abc\0')])
        for data in (raw[:-1],raw+b'x',b'OMWM'+struct.pack('<I',0xffffffff)):
            with self.assertRaises(ValueError):list(chunks(data))

    def test_room_groups_and_small_grid_identity(self):
        source='a'*32+'.blp'
        raw=f'WMO\\Dungeon\\Room_001_02_03.blp {source}\nMap\\map04_05.blp {source}\n'.encode()
        terrain,rooms=texture_index(raw)
        self.assertEqual(terrain['map'][(4,5)],source)
        self.assertEqual(rooms['world\\wmo\\dungeon\\room.wmo'][1][(2,3)],source)
        with self.assertRaises(ValueError):texture_index(raw+raw.replace(b'a'*32,b'b'*32))

    def test_only_absent_and_deleted_assets_are_optional(self):
        class Reader:
            message='Missing (status -10)'
            def get(self,_):raise ValueError(self.message)
        reader=Reader()
        for n in (-10,-20):
            reader.message=f'Absent (status {n})';self.assertIsNone(optional(reader,'member'))
        reader.message='Corrupt (status -3)'
        with self.assertRaises(ValueError):optional(reader,'member')

    def test_receipt_scope_and_rejection(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);receipt=fixture(root)
            self.assertEqual(set(validate(root)),set(receipt['files']))
            manifest=json.loads((root/'manifest.json').read_text())
            for field,value in [('coordinateSupport',True),('entities','entities/34.json')]:
                changed=json.loads(json.dumps(manifest));changed['regions'][0][field]=value
                write(root/'manifest.json',changed)
                receipt['files']['manifest.json']=sha((root/'manifest.json').read_bytes());write(root/'receipt.json',receipt)
                with self.assertRaises(ValueError):validate(root)
            write(root/'manifest.json',manifest)
            receipt['files']['manifest.json']=sha((root/'manifest.json').read_bytes());write(root/'receipt.json',receipt)
            (root/'views/one.json').write_text('{}')
            with self.assertRaisesRegex(ValueError,'Changed interior'):validate(root)

    def test_unsafe_receipts_and_missing_assets(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);receipt=fixture(root)
            receipt['files']['../private.txt']='0'*64;write(root/'receipt.json',receipt)
            with self.assertRaisesRegex(ValueError,'Unexpected interior path'):validate(root)
            del receipt['files']['../private.txt'];write(root/'receipt.json',receipt)
            (root/'entities/33.json').unlink()
            with self.assertRaises(FileNotFoundError):validate(root)

    def test_changed_generator_invalidates_evidence(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);receipt=fixture(root)
            receipt['generators']={'map_interiors.py':'0'*64};write(root/'receipt.json',receipt)
            with self.assertRaisesRegex(ValueError,'Stale interior generator'):validate(root)


if __name__=='__main__':unittest.main()
