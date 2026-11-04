import * as P from '../guide-editor/map-model.js';
import * as M from '../guide-editor/model.js';
import {drawNode,drawOverlayMarker,NODE_FILLS,NODE_OUTLINE,PROFESSION_LABELS,markerRole,markerAppearance,locationDescription,markerHit} from '../guide-editor/map-markers.js';
export const fixture={schema:1,tileSize:256,maxZoom:6,continents:[{id:1,name:'Kalimdor'},{id:0,name:'Eastern Kingdoms'},{id:530,name:'Outland'},{id:571,name:'Northrend'}],
  zones:[{id:4,physical:1,display:1,token:'Durotar',aliases:['Durotar'],bounds:[-1962.4998779296875,1808.333251953125,-7249.99951171875,-1716.6666259765625]}],
  regions:[{physical:1,display:1,clip:[0,0,16384,16384],offset:[0,0]}],
  tiles:{1:Object.fromEntries(Array.from({length:7},(_,i)=>[i,{}]))}};
export async function mapTests(test,assert,equal,rejects,sleep){
  await test('Terrain cleanup changes only the relocated Ghostlands images, including zoom fallbacks',()=>{
    const region={physical:530,display:0,clip:[10,20,30,40],offset:[-10,15]},outland={physical:530,display:530,clip:[0,0,64,64],offset:[0,0]};
    const original=Object.fromEntries(Array.from({length:7},(_,level)=>[level,{'0,0':'tiles/'+level+'.webp','1,1':'tiles/untouched.webp'}]));
    const manifest={regions:[region,outland],tiles:{530:original}};
    const cleanup={schema:1,region:structuredClone(region),tiles:{},originalTiles:{}};
    for(let level=0;level<=6;level++){cleanup.tiles[level]={'0,0':level+'/0_0.webp'};cleanup.originalTiles[level]={'0,0':original[level]['0,0']};}
    const before=JSON.stringify(manifest),layers=P.terrainLayers(manifest,cleanup);
    for(let level=0;level<=6;level++){
      equal(layers.get(region)[level]['0,0'],'terrain-cleanup/'+level+'/0_0.webp');
      equal(layers.get(region)[level]['1,1'],'tiles/untouched.webp');
    }
    assert(layers.get(outland)===original);equal(JSON.stringify(manifest),before);
    assert(P.terrainLayers(manifest).get(region)===original);
    for(const change of [c=>c.region.offset[0]++,c=>c.region.display=1,c=>c.originalTiles[5]['0,0']='stale',c=>delete c.tiles[3],c=>c.tiles[6]['0,0']='../private.webp']){
      const bad=structuredClone(cleanup);change(bad);let rejected=false;
      try{P.terrainLayers(manifest,bad);}catch{rejected=true;}assert(rejected);
    }
  });
  await test('Trainer badges distinguish profession/class teachers from gathering nodes without inventing unknown classes',()=>{
    const ordinary=['start','vendor','trainer','object'];
    equal(markerAppearance(['trainer','profession-mining'],new Set(['profession-mining']),ordinary),{role:'trainer',badge:'profession-mining'});
    equal(markerAppearance(['object','profession-mining'],new Set(['profession-mining']),ordinary),{role:'profession-mining'});
    equal(markerAppearance(['trainer','class-mage'],new Set(['trainer']),ordinary),{role:'trainer',badge:'class-mage'});
    equal(markerAppearance(['trainer'],new Set(['trainer']),ordinary),{role:'trainer'});
    equal(markerAppearance(['vendor','trainer','class-mage'],new Set(['vendor']),ordinary),{role:'vendor'});
    equal(locationDescription(['trainer','profession-mining']),'Mining trainer');
    equal(locationDescription(['object','profession-mining']),'Ore deposit');
    equal(locationDescription(['trainer','class-mage']),'Mage trainer');
    const canvas=document.createElement('canvas');canvas.width=40;canvas.height=40;
    const icon=document.createElement('canvas');icon.width=20;icon.height=20;
    icon.getContext('2d').fillStyle='#ff0000';icon.getContext('2d').fillRect(0,0,20,20);
    const badge=document.createElement('canvas');badge.width=20;badge.height=20;
    badge.getContext('2d').fillStyle='#0000ff';badge.getContext('2d').fillRect(0,0,20,20);
    const context=canvas.getContext('2d');
    drawOverlayMarker(context,'trainer',20,20,1,icon,null,'T',badge);
    equal([...context.getImageData(16,16,1,1).data],[255,0,0,255]);
    equal([...context.getImageData(26,26,1,1).data],[0,0,255,255]);
    equal(context.getImageData(5,5,1,1).data[3],0);
    context.clearRect(0,0,40,40);drawOverlayMarker(context,'profession-mining',20,20,1,badge,null,'M',icon);
    equal([...context.getImageData(16,16,1,1).data],[0,0,255,255]);
    equal(context.getImageData(33,33,1,1).data[3],0);
    assert(markerHit({x:20,y:20,badged:true},33,33));
    assert(!markerHit({x:20,y:20,badged:true},36,36));
    assert(!markerHit({x:20,y:20},33,33));
  });
  await test('Profession trainer/gathering switches agree at all zooms and retain other independently selected roles',()=>{
    const records=[{roles:['trainer','creature','profession-mining'],starts:[]},
      {roles:['object','profession-mining'],events:[2],starts:[]}];
    const overview={combinations:records.map(r=>[r.roles,1,r.events||[],[]])};
    for(const trainers of [false,true])for(const gathering of [false,true])for(const events of [new Set(),new Set([2])]){
      const layers=new Set(['profession-mining']),types={trainers,gathering};
      const actual=records.map(r=>P.filterOverlay(r,layers,events,types)).filter(Boolean);
      equal(actual.length,(trainers?1:0)+(gathering&&events.has(2)?1:0));
      equal(P.filterOverlay(overview,layers,events,types)?.count||0,actual.length);
    }
    assert(P.filterOverlay(records[0],new Set(['trainer']),new Set(),{trainers:false,gathering:false}));
    equal(records[0].roles,['trainer','creature','profession-mining']);
  });
  await test('Client map icons preserve transparency without a background circle; clusters and fallbacks remain',()=>{
    const icon=document.createElement('canvas');icon.width=20;icon.height=20;
    const ink=icon.getContext('2d');ink.fillStyle='#ffd700';ink.fillRect(9,4,2,12);
    const canvas=document.createElement('canvas');canvas.width=40;canvas.height=40;
    const context=canvas.getContext('2d');
    for(const role of ['start','end','repair','vendor','trainer',...Object.keys(PROFESSION_LABELS)]){
      context.clearRect(0,0,40,40);drawOverlayMarker(context,role,20,20,1,icon,'#ff0000','!');
      equal([...context.getImageData(10,10,20,20).data],[...ink.getImageData(0,0,20,20).data]);
    }
    context.clearRect(0,0,40,40);drawOverlayMarker(context,'start',20,20,2,icon,'#ff0000','!');
    equal([...context.getImageData(14,20,1,1).data],[255,0,0,255]);
    context.clearRect(0,0,40,40);drawOverlayMarker(context,'start',20,20,1,null,'#ff0000','!');
    equal([...context.getImageData(14,20,1,1).data],[255,0,0,255]);
    for(const role of ['creature','object']){
      context.clearRect(0,0,40,40);drawOverlayMarker(context,role,20,20,1,null,null,null);
      equal(context.strokeStyle,NODE_OUTLINE);equal(context.getImageData(20,20,1,1).data[3],255);
    }
  });
  await test('Profession layers are independent, retain event gates and prefer selected profession icons',()=>{
    equal(Object.keys(PROFESSION_LABELS).length,14);
    const r={roles:['object','profession-mining'],events:[2]};
    equal(P.filterOverlay(r,new Set(['profession-herbalism']),new Set([2])),null);
    equal(P.filterOverlay(r,new Set(['profession-mining']),new Set()),null);
    assert(P.filterOverlay(r,new Set(['profession-mining']),new Set([2]))===r);
    equal(markerRole(['vendor','trainer','profession-alchemy'],new Set(['vendor','trainer','profession-alchemy']),['vendor','trainer']),'profession-alchemy');
    equal(markerRole(['vendor','trainer','profession-alchemy'],new Set(['trainer']),['vendor','trainer']),'trainer');
  });
  await test('Event gates preserve ordinary spawns, OR positive events and exclude active negative events',()=>{
    const enabled=new Set([2]);
    assert(P.eventVisible([],enabled));assert(P.eventVisible([2,12],enabled));
    assert(!P.eventVisible([12],enabled));assert(P.eventVisible([-12],enabled));
    assert(!P.eventVisible([-2],enabled));assert(!P.eventVisible([2,-2],enabled));
    assert(P.calendarEvent({holiday:141,name:'Winter Veil'}));
    assert(P.calendarEvent({holiday:0,name:"New Year's Eve"}));
    assert(!P.calendarEvent({holiday:0,name:'Pyrewood Village'}));
  });
  await test('Event filters agree for detailed and overview markers, including multi-role and permanent quest givers',()=>{
    const records=[{roles:['creature','vendor'],events:[2],starts:[]},
      {roles:['creature'],eventRoles:[[12,['start']]],eventStarts:[[12,8356]],starts:[]},
      {roles:['creature'],events:[-72],starts:[]}];
    const overview={combinations:records.map(r=>[r.roles,1,r.events||[],r.eventRoles||[]])};
    for(const enabled of [new Set(),new Set([2]),new Set([12]),new Set([72]),new Set([2,12,72])])
      for(const layers of [new Set(['start']),new Set(['vendor']),new Set(['creature','vendor','start'])]){
        const detailed=records.map(r=>P.filterOverlay(r,layers,enabled)).filter(Boolean);
        equal(P.filterOverlay(overview,layers,enabled)?.count||0,detailed.length);
      }
    equal(P.filterOverlay(records[1],new Set(['start']),new Set([12])).starts,[8356]);
    equal(records[1].starts,[]);equal(records[1].roles,['creature']);
    equal(P.filterOverlay(records[1],new Set(['start']),new Set()),null);
  });
  await test('Creature and object nodes are coloured circles with gold outlines',()=>{
    for(const [role,colour] of [['creature',[67,185,92]],['object',[154,96,208]]]){
      const canvas=document.createElement('canvas');canvas.width=20;canvas.height=20;
      const context=canvas.getContext('2d');assert(drawNode(context,role,10,10));
      equal([...context.getImageData(10,10,1,1).data],[...colour,255]);
      equal(context.fillStyle,NODE_FILLS[role]);equal(context.strokeStyle,NODE_OUTLINE);
      equal(context.getImageData(0,0,1,1).data[3],0);
      const pixels=context.getImageData(0,0,20,20).data;let gold=0;
      for(let i=0;i<pixels.length;i+=4)if(pixels[i]===216&&pixels[i+1]===178&&pixels[i+2]===74&&pixels[i+3]===255)gold++;
      assert(gold>8,'Missing gold border');assert(!drawNode(context,'start',10,10));
    }
  });
  await test('Wheel deltas are proportional and finite zoom preserves the pointer anchor',()=>{
    assert(P.wheelFactor(-1)<P.wheelFactor(-100));
    equal(P.wheelFactor(3,1),P.wheelFactor(48));
    equal(P.wheelFactor(1,2,600),P.wheelFactor(120));
    const start={u:850,v:500,scale:.25},x=110,y=290,w=600,h=600;
    let previous=start.scale;
    for(const elapsed of [0,20,60,100,140,300]){
      const frame=P.zoomFrame(start.scale,.5,elapsed),view=P.zoomAt(start,frame.scale,x,y,w,h);
      assert(frame.scale>=previous&&frame.scale<=.5+1e-12);previous=frame.scale;
      assert(Math.abs(view.u+(x-w/2)/view.scale-(start.u+(x-w/2)/start.scale))<1e-9);
      assert(Math.abs(view.v+(y-h/2)/view.scale-(start.v+(y-h/2)/start.scale))<1e-9);
      equal(frame.done,elapsed>=140);
    }
  });
  await test('Pan keeps cluster membership stable in world-anchored bins',()=>{
    const records=[{u:23,v:5},{u:25,v:7},{u:30,v:9}];
    const a=P.cluster(records,(u,v)=>[u,v],24,[0,0]);
    const b=P.cluster(records,(u,v)=>[u-13,v+8],24,[13,-8]);
    equal(JSON.stringify(a.map(c=>c.members)),JSON.stringify(b.map(c=>c.members)));
    equal(b[0].x,a[0].x-13);equal(b[0].y,a[0].y+8);
  });
  await test('Close zoom reaches eightfold magnification and clamps without moving the anchor',()=>{
    const start={u:850,v:500,scale:2},x=110,y=290,w=600,h=600;
    for(const requested of [4,8,64]){
      const view=P.zoomAt(start,requested,x,y,w,h);
      equal(view.scale,Math.min(requested,8));
      assert(Math.abs(view.u+(x-w/2)/view.scale-(start.u+(x-w/2)/start.scale))<1e-9);
      assert(Math.abs(view.v+(y-h/2)/view.scale-(start.v+(y-h/2)/start.scale))<1e-9);
    }
    equal(P.zoomAt(start,0,x,y,w,h).scale,P.MIN_SCALE);
  });
  await test('Terrain percentage / physical coordinate round trips',()=>{
    const z=fixture.zones[0];
    for(const x of [0,43.33,100])for(const y of [0,68.61,100]){
      const p=P.fromPercent(fixture,z,x,y),back=P.toPercent(fixture,z,p.u,p.v);
      assert(back&&Math.abs(back.x-x)<1e-9&&Math.abs(back.y-y)<1e-9,'Round trip');
    }
    const kaltunk=P.project(fixture,1,-610.073,-4253.52),p=P.toPercent(fixture,z,kaltunk.u,kaltunk.v);
    assert(Math.abs(p.x-43.33)<.1&&Math.abs(p.y-68.61)<.1);
  });
  await test('Map edits preserve wrappers, comments, conditions, radii and other guides',()=>{
    const line='  .goto Durotar, 43.33 , 68.61,60,0 >>Hello << Orc';
    const text='-- attribution\r\nRXPGuides.RegisterGuide([[#group Custom\r\n#name One\r\nstep\r\n'+line+'\r\n]])\r\nRXPGuides.RegisterGuide([[#name Two\nstep\n>>Other]])';
    const g=M.parseDocument(text,'x.lua').guides[0],m=P.waypoints(g,fixture)[0];
    assert(m);const next=P.moveWaypoint(text,g,m,45,67);
    equal(next,text.replace('43.33','45.00').replace('68.61','67.00'));
    const history=new M.History(text);history.set(next);history.undo();equal(history.text,text);history.redo();equal(history.text,next);
    rejects(()=>P.moveWaypoint(next,M.parseDocument(next,'x.lua').guides[0],m,2,3),/changed/);
    rejects(()=>P.moveWaypoint(text,g,m,101,0),/0–100/);
  });
  await test('Unsupported and ambiguous waypoint forms remain source-only',()=>{
    for(const text of ['.goto 1,-423,234','.goto Durotar/2,40,50','.goto Unknown,2,3','.goto Durotar,101,20','.goto Durotar,20,no'])assert(!P.parseWaypoint(text,fixture.zones));
    assert(!P.parseWaypoint('.goto Durotar,2,3',[...fixture.zones,...fixture.zones]));
  });
  await test('Dense marker clustering is screen-space, retaining every member',()=>{
    const records=Array.from({length:20000},(_,id)=>({id,u:id%100,v:Math.floor(id/100)}));
    const cells=P.cluster(records,(u,v)=>[u*.1,v*.1],24);equal(cells.length,1);equal(cells[0].members.length,records.length);
    assert(P.cluster(records,(u,v)=>[u*10,v*10],24).length>1000);
  });
  await test('Resource queue is bounded, stale requests discarded and collapse stops fetches',async()=>{
    let calls=0,active=0,peak=0,ready=0;const callbacks=[];
    const r=new P.Resources((key,signal)=>{calls++;active++;peak=Math.max(peak,active);return new Promise(resolve=>callbacks.push(()=>{active--;resolve({key});}));},()=>ready++,{limit:3,concurrency:2});
    for(let i=0;i<10;i++)r.get(String(i));await sleep(0);equal(calls,2);r.cancel();callbacks.splice(0).forEach(fn=>fn());await sleep(0);equal(ready,0);equal(r.cache.size,0);equal(r.queue.length,0);
    r.get('hidden');await sleep(0);equal(calls,2);
    r.active=true;for(let i=0;i<5;i++)r.get('new'+i);
    for(let i=0;i<6;i++){await sleep(0);callbacks.splice(0).forEach(fn=>fn());}
    await sleep(0);assert(r.cache.size<=3);assert(peak<=2);equal(ready,5);r.cancel();
  });
  await test('Failed tiles are cached without an infinite retry/redraw loop',async()=>{
    let calls=0;const r=new P.Resources(async()=>{calls++;throw new Error('Missing');},()=>{}, {limit:2});
    r.get('missing');await sleep(0);equal(r.get('missing'),null);equal(calls,1);r.cancel();
  });
  await test('Pan retains visible requests and rejects replaced same-generation responses',async()=>{
    const loads=[];let ready=0,closed=0;
    const r=new P.Resources((key,signal)=>new Promise(resolve=>loads.push({key,signal,resolve})),()=>ready++,{concurrency:2});
    r.begin();r.get('visible');r.get('leaving');r.end();await sleep(0);
    equal(loads.length,2);
    r.begin();r.get('visible');r.get('entering');r.end();
    assert(!loads[0].signal.aborted);assert(loads[1].signal.aborted);
    // Return to the old tile before its aborted loader settles.
    r.begin();r.get('visible');r.get('leaving');r.end();
    loads[1].resolve({close(){closed++;}});await sleep(0);
    equal(closed,1);equal(ready,0);equal(loads.length,3);equal(loads[2].key,'leaving');
    loads[0].resolve({key:'visible'});loads[2].resolve({key:'fresh'});await sleep(0);
    equal(ready,2);equal(r.get('leaving').key,'fresh');
    r.begin();r.get('visible');r.get('leaving');r.end();await sleep(0);
    equal(loads.length,3);equal(r.pending.size,0);r.cancel();
  });
}

import {interiorResponse,interiorUITests} from './interior-tests.js';

export async function mapUITests(test,assert,equal,sleep,w,d,input,basic){
  const get=id=>d.getElementById(id),fetch=w.fetch;let requests=0,missing=true,delayed=false,resolveOverlay;
  w.fetch=async(url,opts)=>{
    if(String(url).includes('/map-assets-local/')){
      if(String(url).includes('/interiors/'))return interiorResponse(w,String(url));
      requests++;
      if(missing)return new w.Response('Missing',{status:404});
      if(delayed&&String(url).endsWith('/overlays/manifest.json'))return new Promise(resolve=>{resolveOverlay=resolve;});
      if(String(url).endsWith('/overlays/manifest.json'))return new w.Response(JSON.stringify({schema:2,chunks:{},overviews:{},events:[
        {id:2,holiday:141,name:'Winter Veil'},{id:25,holiday:0,name:'Pyrewood Village'}]}));
      return new w.Response(JSON.stringify(fixture));
    }return fetch(url,opts);
  };
  try{
    await test('Absent local artwork leaves editor usable and retries only on explicit reopening',async()=>{
      equal(requests,0);get('terrain-panel').open=true;await sleep(700);
      assert(get('map-status').textContent.includes('unavailable'));assert(get('map-content').hidden);
      const count=requests;await sleep(100);equal(requests,count);get('terrain-panel').open=false;await sleep(50);missing=false;
    });
    await test('Collapse during manifest loading discards stale overlay responses',async()=>{
      delayed=true;get('terrain-panel').open=true;await sleep(150);assert(resolveOverlay);
      get('terrain-panel').open=false;await sleep(50);resolveOverlay(new w.Response(JSON.stringify({schema:1,chunks:{},overviews:{}})));await sleep(50);
      assert(get('map-content').hidden);delayed=false;requests=0;
    });
    await test('Map remains unloaded while collapsed; opens from a repository-relative URL',async()=>{
      equal(requests,0);get('terrain-panel').open=true;await sleep(700);assert(!get('map-content').hidden,get('map-status').textContent);equal(requests,4);
      equal(get('map-zone').value,'4');
    });
    await test('All event controls start off, retain explicit choices and clear stale popups',async()=>{
      const winter=d.querySelector('[data-event="2"]'),world=d.querySelector('[data-event="25"]');
      assert(winter&&!winter.checked);assert(world&&!world.checked);
      const before=get('source').value,count=requests;
      get('map-popup').textContent='Old event quest action';winter.click();
      assert(winter.checked);equal(get('map-popup').textContent,'');assert(get('map-details').disabled);
      get('terrain-panel').open=false;await sleep(50);world.click();await sleep(50);equal(requests,count);
      get('terrain-panel').open=true;await sleep(100);assert(winter.checked&&world.checked);
      equal(get('source').value,before);equal(requests,count);
      const section=winter.closest('details');
      section.querySelector('[aria-label="Hide all calendar events"]').click();assert(!winter.checked);
      section.querySelector('[aria-label="Show all calendar events"]').click();assert(winter.checked);
    });
    await test('Fourteen profession switches start off and changing them does not edit the guide',async()=>{
      const controls=[...d.querySelectorAll('#map-profession-options input')];equal(controls.length,14);
      assert(controls.every(c=>!c.checked));
      const before=get('source').value,count=requests;
      get('map-professions').open=true;
      for(const control of controls)control.click();await sleep(50);
      assert(controls.every(c=>c.checked));equal(get('source').value,before);equal(requests,count);
      get('terrain-panel').open=false;await sleep(50);get('terrain-panel').open=true;await sleep(100);
      assert(controls.every(c=>c.checked));
      for(const control of controls)control.click();get('map-professions').open=false;
      for(const id of ['map-profession-trainers','map-profession-gathering']){
        assert(get(id).checked);get('map-popup').textContent='Stale action';get(id).click();
        assert(!get(id).checked);equal(get('map-popup').textContent,'');equal(get('source').value,before);
        get(id).click();assert(get(id).checked);
      }
    });
    await test('Map add / replace / selection use the real source and Undo controls',async()=>{
      input('source',basic);await sleep(400);
      get('map-x').value='44';get('map-y').value='65';const before=get('source').value;
      get('map-add').click();assert(get('source').value.includes('.goto Durotar,44.00,65.00'));
      get('undo').click();equal(get('source').value,before);get('redo').click();
      const list=get('map-waypoints');list.value='1';list.dispatchEvent(new w.Event('change'));
      equal(get('steps').value,'0');get('map-x').value='40';get('map-y').value='60';get('map-replace').click();
      assert(get('source').value.includes('.goto Durotar,40.00,60.00'));get('undo').click();assert(get('source').value.includes('.goto Durotar,43.33,68.61'));
    });
    await test('Selecting steps retains the unchanged map waypoint list; source edits rebuild it',async()=>{
      input('source',basic+'\nstep\n    .goto Durotar,44,66\n');await sleep(400);
      const list=get('map-waypoints'),original=list.firstElementChild,source=get('source').value;
      assert(original);get('steps').value='1';get('steps').dispatchEvent(new w.Event('change'));
      equal(get('source').value,source);assert(list.firstElementChild===original,'Step selection rebuilt waypoints');
      get('steps').value='0';get('steps').dispatchEvent(new w.Event('change'));
      assert(list.firstElementChild===original,'Returning to a step rebuilt waypoints');
      input('source',source.replace('44,66','45,67'));await sleep(400);
      assert(list.firstElementChild!==original,'Source edits must invalidate waypoint spans');
    });
    await test('Keyboard pan/zoom and pointer cancellation do not edit source',async()=>{
      const before=get('source').value,c=get('terrain');
      for(const key of ['ArrowRight','ArrowDown','+','-','Escape'])c.dispatchEvent(new w.KeyboardEvent('keydown',{key,bubbles:true,cancelable:true}));
      c.dispatchEvent(new w.PointerEvent('pointercancel',{pointerId:1}));await sleep(30);equal(get('source').value,before);
      get('terrain-panel').open=false;await sleep(50);const count=requests;await sleep(100);equal(requests,count);
      get('terrain-panel').open=true;await sleep(100);equal(requests,count);
    });
    await interiorUITests(test,assert,equal,sleep,w,d,input,basic);
  }finally{get('terrain-panel').open=false;w.fetch=fetch;}
}
