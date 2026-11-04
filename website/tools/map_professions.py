"""Profession identity and overlay classification from authorized client/server facts."""
import struct
from collections import defaultdict
from map_extract import dbc,sha

# WotLK skill IDs: AzerothCore SharedDefines.h. Artwork is stock client UI.
PROFESSIONS=[
    (171,'alchemy','Alchemy','Trade_Alchemy'),
    (164,'blacksmithing','Blacksmithing','Trade_BlackSmithing'),
    (333,'enchanting','Enchanting','Trade_Engraving'),
    (202,'engineering','Engineering','Trade_Engineering'),
    (182,'herbalism','Herbalism','Trade_Herbalism'),
    (773,'inscription','Inscription','INV_Inscription_Tradeskill01'),
    (755,'jewelcrafting','Jewelcrafting','INV_Misc_Gem_01'),
    (165,'leatherworking','Leatherworking','Trade_LeatherWorking'),
    (186,'mining','Mining','INV_Pick_02'),
    (393,'skinning','Skinning','INV_Misc_Pelt_Wolf_01'),
    (197,'tailoring','Tailoring','Trade_Tailoring'),
    (185,'cooking','Cooking','INV_Misc_Food_15'),
    (129,'first-aid','First Aid','Spell_Holy_SealOfSacrifice'),
    (356,'fishing','Fishing','Trade_Fishing')]

CLASSES=[(1,'warrior','Warrior'),(2,'paladin','Paladin'),(3,'hunter','Hunter'),
    (4,'rogue','Rogue'),(5,'priest','Priest'),(6,'deathknight','Death Knight'),
    (7,'shaman','Shaman'),(8,'mage','Mage'),(9,'warlock','Warlock'),(11,'druid','Druid')]

def trainer_classes(trainers,assignments):
    classes={id:'class-'+key for id,key,_ in CLASSES}
    verified={r['Id']:classes[r['Requirement']] for r in trainers if r['Type']==0 and r['Requirement'] in classes}
    return {r['CreatureId']:verified[r['TrainerId']] for r in assignments if r['TrainerId'] in verified}

def client_facts(reader):
    inputs={}
    def table(name):
        data=reader.get('DBFilesClient\\'+name+'.dbc');inputs[name+'.dbc']=sha(data)
        return dbc(data)
    rows,text=table('SkillLine');skills={struct.unpack_from('<I',r)[0]:r for r in rows}
    for id,_,name,_ in PROFESSIONS:
        if id not in skills or text(struct.unpack_from('<I',skills[id],12)[0])!=name:
            raise ValueError('Unexpected client profession: '+name)
    rows,_=table('Lock');locks={}
    # DBCStructure.h LockEntry: eight Type/Index/Skill cases; Type=2 is skill.
    # SharedDefines.h: LOCKTYPE_HERBALISM=2, LOCKTYPE_MINING=3.
    for row in rows:
        fields=struct.unpack('<'+'I'*(len(row)//4),row)
        if len(fields)!=33:raise ValueError('Unexpected Lock layout')
        found=sorted({{2:182,3:186}[fields[9+i]] for i in range(8) if fields[1+i]==2 and fields[9+i] in (2,3)})
        if found:locks[str(fields[0])]=found
    return dict(schema=1,professions=[dict(skill=id,key='profession-'+key,name=name) for id,key,name,_ in PROFESSIONS],
        gatheringLocks=locks,inputs=inputs,
        notice='World of Warcraft 3.3.5 client skill/lock metadata: Blizzard Entertainment. Classification uses AzerothCore SharedDefines.h and DBCStructure.h; not live skill eligibility.')

def trainer_professions(trainers,spells,assignments):
    allowed={id:'profession-'+key for id,key,_,_ in PROFESSIONS}
    types={r['Id']:r['Type'] for r in trainers};skills=defaultdict(set)
    for r in spells:
        if types.get(r['TrainerId'])==2 and r['ReqSkillLine'] in allowed:
            skills[r['TrainerId']].add(allowed[r['ReqSkillLine']])
    return {r['CreatureId']:sorted(skills[r['TrainerId']]) for r in assignments if skills[r['TrainerId']]}

def gathering_professions(template,facts):
    if template['type']==25:return ['profession-fishing']
    if template['type']!=3:return []
    keys={p['skill']:p['key'] for p in facts['professions']}
    return [keys[s] for s in facts['gatheringLocks'].get(str(template['Data0']),[])]
