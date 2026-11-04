import * as P from '../guide-editor/map-model.js';
import * as M from '../guide-editor/model.js';
export const fixture={schema:1,tileSize:256,maxZoom:6,continents:[{id:1,name:'Kalimdor'},{id:0,name:'Eastern Kingdoms'},{id:530,name:'Outland'},{id:571,name:'Northrend'}],
  zones:[{id:4,physical:1,display:1,token:'Durotar',aliases:['Durotar'],bounds:[-1962.4998779296875,1808.333251953125,-7249.99951171875,-1716.6666259765625]}],
  regions:[{physical:1,display:1,clip:[0,0,16384,16384],offset:[0,0]}],
  tiles:{1:Object.fromEntries(Array.from({length:7},(_,i)=>[i,{}]))}};
export async function mapTests(test,assert,equal,rejects,sleep){
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

export async function mapUITests(test,assert,equal,sleep,w,d,input,basic){
  const get=id=>d.getElementById(id),fetch=w.fetch;let requests=0,missing=true,delayed=false,resolveOverlay;
  w.fetch=async(url,opts)=>{
    if(String(url).includes('/map-assets-local/')){
      requests++;
      if(missing)return new w.Response('Missing',{status:404});
      if(delayed&&String(url).endsWith('/overlays/manifest.json'))return new Promise(resolve=>{resolveOverlay=resolve;});
      if(String(url).endsWith('/overlays/manifest.json'))return new w.Response(JSON.stringify({schema:1,chunks:{},overviews:{}}));
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
      equal(requests,0);get('terrain-panel').open=true;await sleep(700);assert(!get('map-content').hidden,get('map-status').textContent);equal(requests,3);
      equal(get('map-zone').value,'4');
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
    await test('Keyboard pan/zoom and pointer cancellation do not edit source',async()=>{
      const before=get('source').value,c=get('terrain');
      for(const key of ['ArrowRight','ArrowDown','+','-','Escape'])c.dispatchEvent(new w.KeyboardEvent('keydown',{key,bubbles:true,cancelable:true}));
      c.dispatchEvent(new w.PointerEvent('pointercancel',{pointerId:1}));await sleep(30);equal(get('source').value,before);
      get('terrain-panel').open=false;await sleep(50);const count=requests;await sleep(100);equal(requests,count);
      get('terrain-panel').open=true;await sleep(100);equal(requests,count);
    });
  }finally{get('terrain-panel').open=false;w.fetch=fetch;}
}
