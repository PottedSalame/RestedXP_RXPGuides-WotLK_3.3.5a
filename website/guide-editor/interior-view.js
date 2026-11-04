import {Resources,wheelFactor,zoomFrame,filterOverlay,calendarEvent} from './map-model.js';

const kinds=new Set(['dungeons','raids','underground']);
const roles=new Set(['creature','object','start','end','vendor','trainer','repair']);
const empty=[];
const el=(tag,text)=>{const node=document.createElement(tag);if(text!==undefined)node.textContent=text;return node;};
const option=(label,value)=>{const node=el('option',label);node.value=value;return node;};
export function interiorPath(path){
  if(!/^(?:manifest\.json|entities\/\d+\.json|views\/[a-z0-9-]+\.json|tiles\/[a-f0-9]{32}\.webp)$/.test(path))throw new Error('Invalid interior asset path');
  return path;
}
export function interiorEntities(records,query,type,events){
  query=query.trim().toLowerCase();
  return records.map(r=>filterOverlay(r,roles,events)).filter(r=>r&&(!query||r.name.toLowerCase().includes(query)||String(r.id).includes(query))&&
    (type==='all'||type===r.kind||type==='quests'&&(r.starts.length||r.ends.length)||type==='services'&&r.roles.some(x=>['vendor','trainer','repair'].includes(x))));
}
export function interiorInstruction(record,action,id){
  if(!Number.isSafeInteger(record.id)||record.id<=0)throw new Error('Invalid entity ID');
  if(action==='target'&&record.kind==='npcs')return '    .target '+record.id;
  if(action==='note')return '    >>Interact with '+record.name.replace(/[\r\n\x00-\x1f]/g,' ')+' ('+(record.kind==='objects'?'object':'NPC')+' '+record.id+').';
  if((action==='accept'||action==='turnin')&&Number.isSafeInteger(id)&&id>0&&(action==='accept'?record.starts:record.ends).includes(id))return '    .'+action+' '+id;
  throw new Error('Unsupported entity action');
}

export function createInteriorView(adapter,{base,fetcher=fetch}={}){
  const $=id=>document.getElementById(id),canvas=$('interior-canvas'),ctx=canvas.getContext('2d');
  let open=false,category=null,manifest=null,region=null,sheet=null,rows=[],visible=[],frame=0,serial=0,queryKey='',gesture=null,motion=null;
  let width=1,height=1,view={x:0,y:0,scale:1},lastSheet=null,documentState=null;
  const reduced=matchMedia('(prefers-reduced-motion: reduce)');
  const status=text=>{$('interior-status').textContent=text;};
  const resources=new Resources(async(key,signal)=>{
    const response=await fetcher(new URL('interiors/'+interiorPath(key),base),{signal,credentials:'omit'});
    if(!response.ok)throw new Error('Interior data unavailable');
    if(key.endsWith('.json')){const text=await response.text();if(text.length>8*1024*1024)throw new Error('Oversized interior data');return JSON.parse(text);}
    const blob=await response.blob();if(blob.size>2*1024*1024)throw new Error('Oversized interior image');
    const image=await createImageBitmap(blob);
    if(image.width>256||image.height>256||image.width<4||image.height<4){image.close();throw new Error('Unsupported interior image');}
    return image;
  },error=>{if(error)status(error.message+'; manual editing remains available.');request();},{limit:128,concurrency:4});
  resources.cancel();
  const invalidate=()=>{serial++;$('interior-details').replaceChildren();gesture=null;motion=null;};
  function request(){if(open&&!frame)frame=requestAnimationFrame(now=>{
    frame=0;if(motion){const next=zoomFrame(motion.start.scale,motion.target,now-motion.time);applyZoom(motion.start,next.scale,motion.px,motion.py);if(next.done)motion=null;}
    draw();if(motion)request();
  });}
  function selectRegion(){
    invalidate();resources.cancel(open);region=manifest?.regions.find(r=>r.id===$('interior-region').value)||null;
    sheet=null;lastSheet=null;rows=[];visible=[];queryKey='';
    $('interior-entities').replaceChildren();$('interior-count').textContent='';
    $('interior-view').replaceChildren(...(region?.views||[]).map(v=>option(v.title,v.id)));
    $('interior-scope').textContent=region?.entityScope||'';request();
  }
  function choices(){
    const current=region?.id,query=$('interior-search').value.toLowerCase().trim();
    const choices=manifest.regions.filter(r=>r.category===category&&(!query||(r.name+' '+(r.source||'')).toLowerCase().includes(query)));
    $('interior-region').replaceChildren(...choices.map(r=>option(r.name,r.id)));
    if(choices.some(r=>r.id===current))$('interior-region').value=current;
    selectRegion();
  }
  function setup(data){
    if(data.schema!==1||!Array.isArray(data.regions)||!Array.isArray(data.events))throw new Error('Unsupported interior catalogue');
    const ids=new Set();
    for(const r of data.regions){
      if(!kinds.has(r.category)||ids.has(r.id)||!Array.isArray(r.views)||r.coordinateSupport!==false)throw new Error('Invalid interior region');ids.add(r.id);
      for(const v of r.views)interiorPath(v.path);if(r.entities)interiorPath(r.entities);
    }
    manifest=data;
    const container=$('interior-events');container.replaceChildren();
    for(const [title,calendar] of [['Calendar events',true],['Other world events',false]]){
      const entries=data.events.filter(e=>calendarEvent(e)===calendar);if(!entries.length)continue;
      container.append(el('strong',title));
      for(const e of entries){const input=el('input');input.type='checkbox';input.value=e.id;input.onchange=()=>{invalidate();queryKey='';request();};const label=el('label');label.append(input,document.createTextNode(e.name));container.append(label);}
    }
    choices();
  }
  const events=()=>new Set([...$('interior-events').querySelectorAll('input:checked')].map(n=>+n.value));
  function list(){
    const key=[$('interior-query').value,$('interior-type').value,[...events()].join(','),region?.id,rows].map(v=>typeof v==='object'?rows.length:String(v)).join('|');
    if(key===queryKey)return;queryKey=key;
    visible=interiorEntities(rows,$('interior-query').value,$('interior-type').value,events());
    $('interior-entities').replaceChildren(...visible.slice(0,200).map((r,i)=>option(r.name+' ['+r.id+'] — '+(r.kind==='objects'?'object':'NPC'),i)));
    $('interior-count').textContent=visible.length+' matches'+(visible.length>200?' (first 200; narrow the search)':'');
  }
  function details(){
    const item=visible[+$('interior-entities').value],box=$('interior-details');box.replaceChildren();if(!item)return;
    const token=serial,original=adapter.read();
    box.append(el('strong',item.name+' ['+item.id+']'),el('p',region.entityScope),el('p',item.roles.join(', ')),el('p',item.notes.join('; ')||'Snapshot spawn record'));
    const action=(label,fn)=>{const button=el('button',label);button.type='button';button.onclick=()=>{
      const now=adapter.read();if(!open||token!==serial||now.text!==original.text||now.guide!==original.guide||now.step!==original.step){status('Selection changed; select the entity again.');box.replaceChildren();return;}
      try{fn();}catch(error){status(error.message);}
    };box.append(button);};
    if(item.kind==='npcs')action('Add target',()=>adapter.add(interiorInstruction(item,'target')));
    action('Add interaction note',()=>adapter.add(interiorInstruction(item,'note')));
    for(const [field,verb] of [['starts','accept'],['ends','turnin']])for(const quest of item[field])action('Add .'+verb+' '+quest,()=>adapter.add(interiorInstruction(item,verb,quest)));
    action('Wowhead details',()=>adapter.lookup(item.kind,item.id));
  }
  function fit(){
    if(!sheet)return;
    view={x:sheet.width/2,y:sheet.height/2,scale:Math.min(8,Math.max(.015625,Math.min((width-24)/sheet.width,(height-24)/sheet.height)))};
    motion=null;request();
  }
  function draw(){
    if(!open)return;resources.begin();
    ctx.fillStyle='#24333d';ctx.fillRect(0,0,width,height);
    if(!manifest){const data=resources.get('manifest.json');if(data){try{setup(data);}catch(error){status(error.message);resources.end();return;}}resources.end();return;}
    if(!region){status('No matching regions.');resources.end();return;}
    const selected=region.views.find(v=>v.id===$('interior-view').value);
    const data=selected?resources.get(selected.path):null;
    const records=region.entities?resources.get(region.entities):empty;
    if(records&&records!==rows){rows=records;queryKey='';}list();
    if(data){
      if(!Number.isFinite(data.width+data.height)||data.width<=0||data.height<=0||data.width>16384||data.height>16384||!data.tiles){status('Unsupported interior sheet');resources.end();return;}
      sheet=data;if(lastSheet!==sheet){lastSheet=sheet;fit();}
      status(region.name+' · view-only'+(sheet.incomplete?' · some source imagery unavailable':''));
      // A few large outdoor instance overviews have >128 tiles. Limit the
      // visible working set by drawing reduced sheets generated offline.
      const nativeCount=(Math.ceil(width/view.scale/256)+1)*(Math.ceil(height/view.scale/256)+1);
      const level=sheet.overview&&(view.scale<.5||nativeCount>96)?'overview':null;
      const entries=level?sheet.overview.tiles:sheet.tiles,unit=level?sheet.overview.unit:256;
      for(const [key,tile] of Object.entries(entries)){
        const [tx,ty]=key.split(',').map(Number),x=(tx*unit-view.x)*view.scale+width/2,y=(ty*unit-view.y)*view.scale+height/2;
        const factor=unit/256,w=tile.width*factor*view.scale,h=tile.height*factor*view.scale;
        if(x+w<0||y+h<0||x>width||y>height)continue;
        const image=resources.get(tile.path);if(image)ctx.drawImage(image,x,y,w,h);
      }
    }else status(selected?'Loading interior image…':'No usable stock imagery; entity references remain available.');
    resources.end();
  }
  function size(){const r=canvas.getBoundingClientRect(),dpr=Math.min(devicePixelRatio||1,3);width=Math.max(1,r.width);height=Math.max(1,r.height);canvas.width=Math.round(width*dpr);canvas.height=Math.round(height*dpr);ctx.setTransform(dpr,0,0,dpr,0,0);request();}
  const observer=new ResizeObserver(()=>{if(open)size();});
  function applyZoom(start,scale,px,py){view={scale,x:start.x+(px-width/2)/start.scale-(px-width/2)/scale,y:start.y+(py-height/2)/start.scale-(py-height/2)/scale};}
  function zoom(factor,px=width/2,py=height/2){if(!sheet)return;const target=Math.max(.015625,Math.min(8,(motion?.target??view.scale)*factor));gesture=null;if(reduced.matches){applyZoom(view,target,px,py);motion=null;}else motion={start:{...view},target,px,py,time:performance.now()};request();}
  const point=e=>{const r=canvas.getBoundingClientRect();return [e.clientX-r.left,e.clientY-r.top];};
  canvas.onwheel=e=>{if(open){e.preventDefault();zoom(wheelFactor(e.deltaY,e.deltaMode,height),...point(e));}};
  canvas.onpointerdown=e=>{if(e.button||!open)return;motion=null;canvas.focus();gesture={id:e.pointerId,p:point(e),view:{...view}};canvas.setPointerCapture(e.pointerId);};
  canvas.onpointermove=e=>{if(!gesture||gesture.id!==e.pointerId)return;const p=point(e);view.x=gesture.view.x-(p[0]-gesture.p[0])/view.scale;view.y=gesture.view.y-(p[1]-gesture.p[1])/view.scale;request();};
  canvas.onpointerup=e=>{if(gesture){gesture=null;canvas.releasePointerCapture(e.pointerId);}};
  const cancel=()=>{if(gesture)view=gesture.view;gesture=null;motion=null;request();};canvas.onpointercancel=cancel;canvas.onlostpointercapture=cancel;
  canvas.onkeydown=e=>{if(e.key==='Escape'){cancel();return;}if(!['+','=','-','ArrowLeft','ArrowRight','ArrowUp','ArrowDown'].includes(e.key))return;e.preventDefault();if(e.key==='+'||e.key==='=')zoom(2);else if(e.key==='-')zoom(.5);else{motion=null;view.x+=({'ArrowLeft':-80,'ArrowRight':80}[e.key]||0)/view.scale;view.y+=({'ArrowUp':-80,'ArrowDown':80}[e.key]||0)/view.scale;request();}};
  $('interior-in').onclick=()=>zoom(2);$('interior-out').onclick=()=>zoom(.5);$('interior-reset').onclick=fit;
  $('interior-search').oninput=()=>{if(manifest)choices();};$('interior-region').onchange=selectRegion;
  $('interior-view').onchange=()=>{invalidate();sheet=null;lastSheet=null;resources.cancel(open);request();};
  $('interior-query').oninput=$('interior-type').onchange=()=>{invalidate();queryKey='';request();};$('interior-entities').onchange=details;
  $('interior-entity-details').onclick=details;
  function sync(){const next=adapter.read();if(documentState&&(next.text!==documentState.text||next.guide!==documentState.guide||next.step!==documentState.step)){invalidate();}documentState=next;}
  function show(value,nextCategory=category){
    open=value;invalidate();resources.cancel(open);$('interior-content').hidden=!open;
    if(!open){observer.disconnect();if(frame)cancelAnimationFrame(frame);frame=0;return;}
    // Retry failed assets only on explicit reopening, never on every redraw.
    for(const [key,value] of resources.cache)if(value===null)resources.cache.delete(key);
    if(!kinds.has(nextCategory))throw new Error('Unknown interior category');
    if(nextCategory!==category){category=nextCategory;$('interior-search').value='';if(manifest)choices();}
    sync();size();observer.observe(canvas);request();
  }
  return {show,sync,stats:()=>({open,cached:resources.cache.size,pending:resources.pending.size})};
}
