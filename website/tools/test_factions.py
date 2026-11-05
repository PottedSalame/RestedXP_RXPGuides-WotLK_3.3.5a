"""Affiliation gates and compact cluster evidence, using the real generator."""
import json
import struct
import unittest
from map_factions import FACTS, annotate, evidence, race_side, template_sides, validate_facts
from map_overlays import overview_records


class Factions(unittest.TestCase):
    def test_membership_not_hostility_or_names(self):
        rows=[]
        for id,group,friends,enemies in [(1,2,0,4),(2,4,0,2),(3,0,2,4),(4,6,0,0)]:
            rows.append(struct.pack('<14I',id,0,0,group,friends,enemies,*([0]*8)))
        data=b'WDBC'+struct.pack('<4I',4,14,56,1)+b''.join(rows)+b'\0'
        self.assertEqual(template_sides(data),{'1':1,'2':2,'3':0,'4':0})
        with self.assertRaises(ValueError):template_sides(data[:-1])

    def test_quest_races_conservatively_preserve_unknowns(self):
        for mask,expected in [(0,0),(1101,1),(690,2),(1791,0),(1,1),(2,2),(1024,1),(512,2),(256,0),(0xffffffff,0)]:
            self.assertEqual(race_side(mask),expected)

    def test_roles_and_event_quests_keep_independent_audiences(self):
        facts=dict(npcFactions={'1':1},objectFactions={'2':2},questFactions={'10':1,'20':2})
        r=dict(id=3,kind='npcs',roles=['start','end','vendor'],starts=[10],ends=[20],
               eventStarts=[[2,20],[3,10],[3,20]],eventRoles=[[2,['start']],[3,['start']]],u=1,v=2)
        a=annotate(r,facts)
        self.assertNotIn('faction',a)
        self.assertEqual(a['roleFactions'],{'start':1,'end':2})
        self.assertEqual(a['eventRoleFactions'],{'2':{'start':2},'3':{'start':3}})
        self.assertEqual(annotate(dict(r,starts=[10,99]),facts).get('roleFactions'),{'end':2})
        self.assertEqual(annotate(dict(r,starts=[10,20]),facts)['roleFactions']['start'],3)
        self.assertEqual(annotate(dict(r,id=1),facts)['faction'],1)
        self.assertEqual(annotate(dict(r,id=2,kind='objects'),facts)['faction'],2)
        self.assertEqual(annotate(a,facts),a)
        self.assertNotIn('roleFactions',r)
        records=[a,dict(a,faction=1),dict(a,faction=2),a]
        forward=overview_records(records);reverse=overview_records(list(reversed(records)))
        self.assertEqual(forward,reverse)
        self.assertEqual(sum(c[1] for c in forward[0]['combinations']),4)
        self.assertEqual(len(forward[0]['combinations']),3)
        self.assertIn(evidence(a),[c[4] for c in forward[0]['combinations']])

    def test_committed_facts_represent_known_starters_and_shared_entities(self):
        f=json.loads(FACTS.read_text());validate_facts(f)
        for npc in ('3143','3144','3145','3296'):self.assertEqual(f['npcFactions'][npc],2)
        for npc in ('328','240','68'):self.assertEqual(f['npcFactions'][npc],1)
        self.assertNotIn('14322',f['npcFactions'])  # Stomper Kreeg, not a player faction.
        for quest in ('4641','788'):self.assertEqual(f['questFactions'][quest],2)
        self.assertEqual(f['questFactions']['783'],1)
        self.assertEqual(f['unknownTemplates'],[])
        bad=dict(f,questFactions={'1':3})
        with self.assertRaises(ValueError):validate_facts(bad)


if __name__=='__main__':unittest.main()
