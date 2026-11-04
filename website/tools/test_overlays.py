"""Conservative exclusions and event-aware overlay generation. No network/SQL writes."""
import unittest
import struct
from map_overlays import exclusion,pool_event_map,overview_records
from map_professions import PROFESSIONS,client_facts,trainer_professions,trainer_classes,gathering_professions

class Overlays(unittest.TestCase):
    def test_class_badges_require_class_trainer_and_known_class_id(self):
        rows=[dict(Id=1,Type=0,Requirement=8),dict(Id=2,Type=2,Requirement=8),
              dict(Id=3,Type=3,Requirement=3),dict(Id=4,Type=0,Requirement=10),dict(Id=5,Type=0,Requirement=6)]
        assignments=[dict(CreatureId=n+100,TrainerId=n) for n in range(1,7)]
        self.assertEqual(trainer_classes(rows,assignments),{101:'class-mage',105:'class-deathknight'})
    def test_professions_require_curriculum_and_tradeskill_trainer(self):
        trainers=[dict(Id=1,Type=2),dict(Id=2,Type=0)]
        spells=[dict(TrainerId=1,ReqSkillLine=171),dict(TrainerId=1,ReqSkillLine=333),
                dict(TrainerId=1,ReqSkillLine=0),dict(TrainerId=2,ReqSkillLine=171)]
        assignments=[dict(CreatureId=100,TrainerId=1),dict(CreatureId=101,TrainerId=2),dict(CreatureId=102,TrainerId=999)]
        self.assertEqual(trainer_professions(trainers,spells,assignments),{100:['profession-alchemy','profession-enchanting']})

    def test_client_skill_and_lock_facts_do_not_classify_by_name(self):
        def dbc(rows,strings=b'\0'):
            return b'WDBC'+struct.pack('<4I',len(rows),len(rows[0]),4*len(rows[0]),len(strings))+b''.join(struct.pack('<'+'I'*len(row),*row) for row in rows)+strings
        names=b'\0';skills=[]
        for id,_,name,_ in PROFESSIONS:
            row=[0]*56;row[0]=id;row[3]=len(names);names+=name.encode()+b'\0';skills.append(row)
        herb=[0]*33;herb[0]=1;herb[1]=2;herb[9]=2
        mine=[0]*33;mine[0]=2;mine[1]=2;mine[9]=3
        item=[0]*33;item[0]=3;item[1]=1;item[9]=2
        class Reader:
            def get(self,name):return dbc(skills,names) if name.endswith('SkillLine.dbc') else dbc([herb,mine,item])
        facts=client_facts(Reader());self.assertEqual(facts['gatheringLocks'],{'1':[182],'2':[186]})
        self.assertEqual(len(facts['professions']),14)
        for type,lock,expected in [(3,1,['profession-herbalism']),(3,2,['profession-mining']),
                (3,3,[]),(25,0,['profession-fishing']),(10,1,[]),(3,999,[])]:
            self.assertEqual(gathering_professions(dict(type=type,Data0=lock),facts),expected)

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
