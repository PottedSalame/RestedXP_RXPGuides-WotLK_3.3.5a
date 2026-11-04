import {interiorPath,interiorEntities,interiorInstruction} from '../guide-editor/interior-view.js';

const npc={kind:'npcs',id:42,name:'Friendly NPC',roles:['creature','start','end'],notes:['moving / home spawn'],events:[],starts:[101],ends:[102],eventStarts:[],eventRoles:[],count:1};
const object={...npc,kind:'objects',id:43,name:'Chest',roles:['object'],starts:[],ends:[]};
const seasonal={...npc,id:44,name:'Festival NPC',events:[2]};
const manifest={schema:1,events:[{id:2,holiday:141,name:'Winter Veil'}],regions:[
  {id:'a',category:'dungeons',name:'Dungeon A',physical:33,coordinateSupport:false,entityScope:'Entire instance; floor unknown',entities:'entities/33.json',views:[{id:'one',title:'Room section',path:'views/one.json'}]},
  {id:'b',category:'dungeons',name:'Dungeon B',physical:34,coordinateSupport:false,entityScope:'Entire instance; floor unknown',entities:'entities/34.json',views:[{id:'one',title:'Room section',path:'views/one.json'}]},
  {id:'raid',category:'raids',name:'Raid',physical:33,coordinateSupport:false,entityScope:'Entire instance; floor unknown',entities:'entities/33.json',views:[]},
  {id:'cave',category:'underground',name:'Shared cave',physical:null,coordinateSupport:false,entityScope:'Shared artwork; no verified spawn association',views:[{id:'one',title:'Room section',path:'views/one.json'}]}
]};
export const interiorMock={calls:0,missing:false,delay:false,resolve:null};
export function interiorResponse(w,url){
  interiorMock.calls++;
  if(interiorMock.missing)return new w.Response('Missing',{status:404});
  if(interiorMock.delay&&url.endsWith('/entities/34.json'))return new Promise(resolve=>{interiorMock.resolve=resolve;});
  const data=url.endsWith('/manifest.json')?manifest:url.includes('/views/')?{id:'one',width:256,height:128,tiles:{},incomplete:false}:[npc,object,seasonal];
  return new w.Response(JSON.stringify(data));
}
export async function interiorTests(test,assert,equal,rejects){
  await test('Interior references preserve event gates and do not invent coordinates',()=>{
    equal(interiorEntities([npc,object,seasonal],'','all',new Set()).map(r=>r.id),[42,43]);
    equal(interiorEntities([npc,object,seasonal],'festival','quests',new Set([2])).map(r=>r.id),[44]);
    equal(interiorInstruction(npc,'target'),'    .target 42');
    equal(interiorInstruction(npc,'accept',101),'    .accept 101');
    assert(!interiorInstruction(object,'note').includes('.goto'));
    rejects(()=>interiorInstruction(object,'target'),/Unsupported/);
    rejects(()=>interiorInstruction(npc,'turnin',999),/Unsupported/);
    for(const path of ['../secret','/manifest.json','tiles/a.webp','entities/../33.json'])rejects(()=>interiorPath(path),/Invalid/);
  });
}
export async function interiorUITests(test,assert,equal,sleep,w,d,input,basic){
  const get=id=>d.getElementById(id),change=(id,value)=>{get(id).value=value;get(id).dispatchEvent(new w.Event('change'));};
  // The dump-DOM runner advances virtual timers, not offscreen iframe RAF.
  // Native rendering/RAF is exercised separately by browser_interiors.py.
  const raf=w.requestAnimationFrame,cancel=w.cancelAnimationFrame;
  w.requestAnimationFrame=fn=>w.setTimeout(()=>fn(w.performance.now()),16);w.cancelAnimationFrame=w.clearTimeout.bind(w);
  try{
  await test('Interiors are lazy and absent imagery never blocks source editing',async()=>{
    equal(interiorMock.calls,0);get('terrain-panel').open=false;await sleep(50);
    interiorMock.missing=true;change('map-kind','dungeons');await sleep(50);equal(interiorMock.calls,0);
    get('terrain-panel').open=true;await sleep(500);assert(get('interior-status').textContent.includes('unavailable'),'Missing state: '+get('interior-status').textContent+'; requests='+interiorMock.calls+'; kind='+get('map-kind').value);
    get('terrain-panel').open=false;await sleep(50);interiorMock.missing=false;
    get('terrain-panel').open=true;await sleep(450);assert(!get('interior-content').hidden,'Interior container hidden');assert(get('map-content').hidden,'Outdoor container still shown');
    assert(get('interior-status').textContent.includes('view-only'),get('interior-status').textContent);equal(get('interior-entities').options.length,2);
    equal(get('interior-region').options.length,2);
  });
  await test('Interior entity actions use real span edits, Undo and stale-action rejection',async()=>{
    input('source',basic);await sleep(400);const before=get('source').value;
    get('interior-entities').value='0';get('interior-entity-details').click();
    const buttons=[...get('interior-details').querySelectorAll('button')],target=buttons.find(b=>b.textContent==='Add target');
    target.click();assert(get('source').value.includes('.target 42'));
    const changed=get('source').value;target.click();equal(get('source').value,changed);
    get('undo').click();equal(get('source').value,before);
    get('interior-entity-details').click();[...get('interior-details').querySelectorAll('button')].find(b=>b.textContent==='Add .accept 101').click();
    assert(get('source').value.includes('.accept 101'));get('undo').click();equal(get('source').value,before);
    get('interior-entities').value='1';get('interior-entity-details').click();
    const note=[...get('interior-details').querySelectorAll('button')].find(b=>b.textContent==='Add interaction note');
    input('source',basic+'\n>>new source\n');await sleep(400);const edited=get('source').value;note.click();equal(get('source').value,edited);
  });
  await test('Interior navigation, events and shared caves never fabricate positions',async()=>{
    const before=get('source').value,canvas=get('interior-canvas');
    for(const key of ['ArrowRight','ArrowDown','+','-','Escape'])canvas.dispatchEvent(new w.KeyboardEvent('keydown',{key,bubbles:true,cancelable:true}));
    canvas.click();equal(get('source').value,before);
    get('interior-events').querySelector('input').click();await sleep(100);equal(get('interior-entities').options.length,3);
    change('map-kind','underground');await sleep(150);equal(get('interior-entities').options.length,0);
    assert(get('interior-scope').textContent.includes('no verified spawn association'));equal(get('source').value,before);
    const box=canvas.getBoundingClientRect();assert(Math.abs(box.width-box.height)<=1);
    assert(d.documentElement.scrollWidth<=d.documentElement.clientWidth+2,'Interior controls overflow narrow screen');
    change('map-kind','raids');await sleep(100);assert(get('interior-status').textContent.includes('No usable stock imagery'));
  });
  await test('Collapsed and replaced interior requests cannot populate another region',async()=>{
    change('map-kind','dungeons');await sleep(150);interiorMock.delay=true;change('interior-region','b');await sleep(100);assert(interiorMock.resolve);
    change('map-kind','underground');await sleep(100);interiorMock.resolve(new w.Response(JSON.stringify([npc])));await sleep(100);
    equal(get('interior-entities').options.length,0);interiorMock.delay=false;
    get('terrain-panel').open=false;await sleep(50);const calls=interiorMock.calls;await sleep(100);equal(interiorMock.calls,calls);
    change('map-kind','outdoor');await sleep(50);equal(interiorMock.calls,calls);
    get('terrain-panel').open=true;await sleep(100);assert(!get('map-content').hidden);assert(get('interior-content').hidden);
  });
  }finally{get('terrain-panel').open=false;await sleep(40);w.requestAnimationFrame=raf;w.cancelAnimationFrame=cancel;}
}
