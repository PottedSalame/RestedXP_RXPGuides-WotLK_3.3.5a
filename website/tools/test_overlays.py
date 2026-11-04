"""Conservative exclusions and event-aware overlay generation. No network/SQL writes."""
import unittest
from map_overlays import exclusion,pool_event_map,overview_records

class Overlays(unittest.TestCase):
    def test_only_verified_placeholder_or_helper_evidence(self):
        for name in ('Rabbit','Bunny','Squirrel','Training Dummy','Scourge Test Subject','Lucid Test Subject','Greatfather Winter','Invisible Stalker'):
            self.assertIsNone(exclusion('npcs',dict(entry=1,name=name,flags_extra=0)),name)
        self.assertIsNotNone(exclusion('npcs',dict(entry=1,name='World Trigger',flags_extra=0x80)))
        self.assertIsNotNone(exclusion('npcs',dict(entry=20239,name='Neutralizing Emote Placeholder')))
        self.assertIsNotNone(exclusion('objects',dict(entry=2558,name='Test')))
        self.assertIsNone(exclusion('objects',dict(entry=2558,name='Changed real object')))
        self.assertIsNone(exclusion('objects',dict(entry=192874,name='The Fluffy Bunny')))

    def test_event_pools_inherit_signed_gates_and_reject_cycles(self):
        events=[dict(pool_entry=1,eventEntry=9),dict(pool_entry=4,eventEntry=-12)]
        parents=[dict(pool_id=2,mother_pool=1),dict(pool_id=3,mother_pool=2)]
        self.assertEqual(pool_event_map(events,parents),{1:[9],2:[9],3:[9],4:[-12]})
        with self.assertRaisesRegex(ValueError,'Cyclic'):
            pool_event_map([],parents+[dict(pool_id=1,mother_pool=3)])
        with self.assertRaisesRegex(ValueError,'Conflicting'):
            pool_event_map(events+[dict(pool_entry=3,eventEntry=12)],parents)

    def test_overview_preserves_role_event_combinations_without_double_counting(self):
        records=[dict(u=1,v=2,roles=['creature','vendor'],events=[2]),
                 dict(u=4,v=6,roles=['creature'],eventRoles=[[12,['start']]]),
                 dict(u=8,v=9,roles=['creature'],events=[-72]),
                 dict(u=10,v=11,roles=['creature','vendor'],events=[2])]
        a=overview_records(records);b=overview_records(list(reversed(records)))
        self.assertEqual(a,b);self.assertEqual(a[0]['count'],4)
        self.assertEqual(sum(c[1] for c in a[0]['combinations']),4)
        self.assertIn([['creature','vendor'],2,[2],[]],a[0]['combinations'])
        self.assertIn([['creature'],1,[],[[12,['start']]]],a[0]['combinations'])
        self.assertIn([['creature'],1,[-72],[]],a[0]['combinations'])

if __name__=='__main__':unittest.main()
