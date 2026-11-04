import {Resources,waypoints,fromPercent,toPercent,cluster,inside,wheelFactor,zoomAt,zoomFrame,MIN_SCALE,MAX_SCALE,calendarEvent,filterOverlay,terrainLayers} from './map-model.js';
import {drawNode,drawOverlayMarker,NODE_FILLS,PROFESSION_LABELS,CLASS_LABELS,markerAppearance,locationDescription,markerHit} from './map-markers.js';
const labels={guide:'Guide waypoints',start:'Quest starters',end:'Quest turn-ins',repair:'Repairs',vendor:'Vendors',trainer:'Trainers',creature:'Creatures',object:'Objects',...PROFESSION_LABELS};
const colors={start:'#f6d24f',end:'#e2e2db',repair:'#e5bb85',vendor:'#91dab0',trainer:'#8fcfff',...NODE_FILLS,...Object.fromEntries(Object.keys(PROFESSION_LABELS).map(key=>[key,'#d4c597']))};
const ordinaryRoles=Object.keys(colors);
const symbols={start:'!',end:'?',repair:'R',vendor:'$',trainer:'T',creature:'•',object:'□',...Object.fromEntries(Object.entries(PROFESSION_LABELS).map(([key,name])=>[key,name[0]]))};
const el=(tag,text)=>{const n=document.createElement(tag);if(text!==undefined)n.textContent=text;return n;};
const option=(name,value)=>{const n=el('option',name);n.value=value;return n;};
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));

export function createMap(adapter,{base=new URL('../map-assets-local/',import.meta.url),fetcher=fetch}={}) {
  const $=id=>document.getElementById(id),canvas=$('terrain'),ctx=canvas.getContext('2d');
  let open=false,manifest=null,overlay=null,iconManifest=null,controller=null,frame=0,markers=[],selected=null,gesture=null,motion=null;
  let terrain=null;
  const legendIcons=new Map(),legendPainted=new Map();
  const reducedMotion=matchMedia('(prefers-reduced-motion: reduce)');
  let documentText=null,documentGuide=null,display=1,view={u:0,v:0,scale:1},width=1,height=1,hit=[],proposal=null,locations=[],locationsKey='';
  const layers=new Set(['guide','start','end','repair','vendor','trainer']);
  const enabledEvents=new Set();
  const professionTypes={trainers:true,gathering:true};
  const status=text=>{$('map-status').textContent=text;};
  const url=path=>{
    if(!/^[a-zA-Z0-9_.,/\-]+$/.test(path)||path.includes('..')||path.startsWith('/'))throw new Error('Invalid map asset path');
    return new URL(path,base);
  };
  const json=async(path,signal)=>{const r=await fetcher(url(path),{signal,credentials:'omit'});if(!r.ok)throw new Error('Map data unavailable.');return r.json();};
  const resources=new Resources(async(key,signal)=>{
    if(key.endsWith('.json'))return json(key,signal);
    const r=await fetcher(url(key),{signal,credentials:'omit'});if(!r.ok){if(key.startsWith('icons/'))return null;throw new Error('Some map tiles are unavailable.');}
    const blob=await r.blob();if(blob.size>2*1024*1024)throw new Error('Oversized map tile.');
    const image=await createImageBitmap(blob);
    const icon=key.startsWith('icons/');
    if(image.width!==image.height||!(icon?[16,32,64].includes(image.width):image.width===256)){image.close();throw new Error('Invalid map image dimensions.');}
    return image;
  },error=>{if(error)status(error.message+' Manual editing remains available.');request();},{limit:192,concurrency:4});
  resources.cancel();
  function request(){if(open&&!frame)frame=requestAnimationFrame(now=>{
    frame=0;
    if(motion){const next=zoomFrame(motion.view.scale,motion.target,now-motion.started);view=zoomAt(motion.view,next.scale,motion.x,motion.y,width,height);if(next.done)motion=null;}
    draw();if(motion)request();
  });}
  function invalidate(){resources.cancel(open);request();}
  const screen=(u,v)=>[(u-view.u)*view.scale+width/2,(v-view.v)*view.scale+height/2];
  const world=(x,y)=>[view.u+(x-width/2)/view.scale,view.v+(y-height/2)/view.scale];
  const zone=()=>manifest?.zones.find(z=>String(z.id)===$('map-zone').value);
  function choices(preferred){
    $('map-zone').replaceChildren(option('Choose zone…',''));
    for(const z of manifest.zones.filter(z=>z.display===display).sort((a,b)=>a.token.localeCompare(b.token)))$('map-zone').append(option(z.token,z.id));
    if(preferred)$('map-zone').value=String(preferred.id);
    proposal=null;$('map-x').value='';$('map-y').value='';$('map-popup').replaceChildren();
  }
  function fit(){
    motion=null;
    const z=zone(),bounds=[];
    if(z){bounds.push(fromPercent(manifest,z,0,0),fromPercent(manifest,z,100,100));}
    else for(const r of manifest.regions.filter(r=>r.display===display)){
      // Use occupied terrain, not a continent-sized empty 64×64 square.
      for(const key of Object.keys(manifest.tiles[r.physical]['6'])){
        const [x,y]=key.split(',').map(Number),u=x*256,v=y*256;
        if(u+256<r.clip[0]||v+256<r.clip[1]||u>r.clip[2]||v>r.clip[3])continue;
        if((r.holes||[]).some(h=>inside([u+128,v+128],h)))continue;
        bounds.push({u:u+r.offset[0],v:v+r.offset[1]},{u:u+256+r.offset[0],v:v+256+r.offset[1]});
      }
    }
    const points=bounds.filter(Boolean);if(!points.length)return;
    const xs=points.map(p=>p.u),ys=points.map(p=>p.v),a=Math.min(...xs),b=Math.min(...ys),c=Math.max(...xs),d=Math.max(...ys);
    view={u:(a+c)/2,v:(b+d)/2,scale:clamp(Math.min((width-30)/(c-a),(height-30)/(d-b)),MIN_SCALE,MAX_SCALE)};
    gesture=null;invalidate();
  }
  function zoom(factor,x=width/2,y=height/2){
    const target=clamp((motion?.target??view.scale)*factor,MIN_SCALE,MAX_SCALE);gesture=null;
    if(reducedMotion.matches){view=zoomAt(view,target,x,y,width,height);motion=null;}
    else motion={view:{...view},target,x,y,started:performance.now()};
    request();
  }
  function size(){const rect=canvas.getBoundingClientRect(),w=Math.max(1,rect.width),h=Math.max(1,rect.height),dpr=Math.min(devicePixelRatio||1,3);
    if(width!==w||height!==h||canvas.width!==Math.round(w*dpr)||canvas.height!==Math.round(h*dpr)){
      motion=null;width=w;height=h;canvas.width=Math.round(width*dpr);canvas.height=Math.round(height*dpr);ctx.setTransform(dpr,0,0,dpr,0,0);
    }request();}
  const observer=new ResizeObserver(()=>{if(open)size();});
  function filtersChanged(){
    $('map-popup').replaceChildren();locations=[];locationsKey='';
    $('map-locations').replaceChildren();$('map-details').disabled=true;hit=[];request();
  }
  function eventControls(){
    const container=$('map-events');container.replaceChildren();
    for(const [title,calendar] of [['Calendar events',true],['Other world events',false]]){
      const events=(overlay?.events||[]).filter(e=>calendarEvent(e)===calendar).sort((a,b)=>a.name.localeCompare(b.name)||a.id-b.id);
      if(!events.length)continue;
      const section=el('details'),summary=el('summary',title),list=el('div');list.className='map-event-options';
      section.append(summary);const actions=el('div');actions.className='toolbar';section.append(actions,list);
      for(const e of events){
        const input=el('input');input.type='checkbox';input.dataset.event=String(e.id);input.checked=false;
        if(input.checked)enabledEvents.add(e.id);
        const label=el('label');label.append(input,document.createTextNode(e.name));list.append(label);
        input.onchange=()=>{if(input.checked)enabledEvents.add(e.id);else enabledEvents.delete(e.id);filtersChanged();};
      }
      for(const [label,on] of [['Show all',true],['Hide all',false]]){
        const button=el('button',label);button.type='button';button.setAttribute('aria-label',label+' '+title.toLowerCase());
        button.onclick=()=>{for(const input of list.querySelectorAll('input')){input.checked=on;if(on)enabledEvents.add(+input.dataset.event);else enabledEvents.delete(+input.dataset.event);}filtersChanged();};actions.append(button);
      }
      container.append(section);
    }
    container.hidden=!container.children.length;
  }
  for(const [key,label] of Object.entries(labels)){
    const input=el('input');input.type='checkbox';input.checked=layers.has(key);input.dataset.layer=key;
    const wrap=el('label');wrap.append(input);
    if(symbols[key]){const badge=el('canvas');badge.width=20;badge.height=20;badge.className='map-legend-icon';badge.setAttribute('aria-hidden','true');wrap.append(badge);legendIcons.set(key,badge);}
    wrap.append(document.createTextNode(label));$(Object.hasOwn(PROFESSION_LABELS,key)?'map-profession-options':'map-legend').append(wrap);
    input.onchange=()=>{if(input.checked)layers.add(key);else layers.delete(key);filtersChanged();};
  }
  $('map-professions').ontoggle=()=>request();
  for(const type of ['trainers','gathering'])$('map-profession-'+type).onchange=()=>{
    professionTypes[type]=$('map-profession-'+type).checked;filtersChanged();
  };
  $('map-continent').onchange=()=>{display=+$('map-continent').value;choices();fit();};
  $('map-zone').onchange=()=>{proposal=null;gesture=null;$('map-x').value='';$('map-y').value='';$('map-popup').replaceChildren();fit();};
  $('map-in').onclick=()=>zoom(2);$('map-out').onclick=()=>zoom(.5);$('map-reset').onclick=fit;
  function choose(marker){
    if(!marker)return;motion=null;adapter.select(marker);selected=marker;
    if(display!==marker.display){display=marker.display;$('map-continent').value=display;choices(marker.zone);fit();}
    else $('map-zone').value=marker.zone.id;
    $('map-waypoints').value=String(marker.number);setProposal(marker.x,marker.y);
    $('map-selection').textContent='Step '+(marker.step+1)+': '+marker.zone.token;
    request();
  }
  $('map-waypoints').onchange=()=>{const m=markers.find(m=>String(m.number)===$('map-waypoints').value);choose(m);if(m){view.u=m.u;view.v=m.v;invalidate();}};
  function setProposal(x,y){proposal={x,y};$('map-x').value=x.toFixed(2);$('map-y').value=y.toFixed(2);}
  function numbers(){const x=Number($('map-x').value),y=Number($('map-y').value);if(!zone()||!$('map-x').value||!$('map-y').value||!Number.isFinite(x+y)||x<0||y<0||x>100||y>100)throw new Error('Select a zone and enter X/Y within 0–100.');return {x,y};}
  function action(callback){try{callback();}catch(error){status(error.message);}}
  $('map-add').onclick=()=>action(()=>{const {x,y}=numbers();adapter.add('    .goto '+zone().token+','+x.toFixed(2)+','+y.toFixed(2));});
  $('map-replace').onclick=()=>action(()=>{const {x,y}=numbers();if(!selected||selected.zone.id!==zone().id)throw new Error('Select a waypoint in this zone first.');adapter.move(selected,x,y);});
  function popup(members){
    const box=$('map-popup');box.replaceChildren();
    if(members.length>1){box.append(el('p',members.length+' overlapping markers (first 50 listed).'));const b=el('button','Zoom here');b.onclick=()=>{motion=null;view.u=members[0].u;view.v=members[0].v;zoom(2);};box.append(b);}
    for(const m of members.slice(0,50)){
      if(m.kind==='cluster'){const b=el('button',m.count+' snapshot locations — zoom in');b.onclick=()=>{motion=null;view.u=m.u;view.v=m.v;zoom(2);};box.append(b);continue;}
      const row=el('div');row.append(el('strong',m.name+' ['+m.id+']'),el('p',locationDescription(m.roles)),el('p',m.roles.map(r=>labels[r]||CLASS_LABELS[r]||r).join(', ')),
        el('p','Physical map '+m.physical+'; X '+m.x+', Y '+m.y),el('p',m.notes.join('; ')||'Snapshot home position'));
      const eventNames=(m.events||[]).map(id=>(id<0?'Absent during: ':'')+(overlay?.events?.find(e=>e.id===Math.abs(id))?.name||('Event '+Math.abs(id))));
      if(eventNames.length)row.append(el('p',eventNames.join('; ')));
      const coords=zone()?.physical===m.physical?toPercent(manifest,zone(),m.u,m.v):null;
      if(coords){row.append(el('p',zone().token+': '+coords.x.toFixed(2)+', '+coords.y.toFixed(2)));const b=el('button','Use coordinates');b.onclick=()=>setProposal(coords.x,coords.y);row.append(b);}
      if(m.kind==='npcs'){const b=el('button','Add target');b.onclick=()=>action(()=>adapter.add('    .target '+m.id));row.append(b);}
      for(const [field,tag] of [['starts','accept'],['ends','turnin']])for(const quest of m[field]){
        const b=el('button','Add .'+tag+' '+quest);b.onclick=()=>action(()=>adapter.add('    .'+tag+' '+quest));row.append(b);
      }
      const b=el('button','Wowhead details');b.onclick=()=>adapter.lookup(m.kind,m.id);row.append(b);box.append(row);
    }
  }
  $('map-details').onclick=()=>{const c=locations[+$('map-locations').value];if(c)popup(c.members);};
  function tileImage(levels,level,x,y,sx,sy,pixels){
    const path=levels[level][x+','+y];if(!path)return;
    const image=resources.get(path);
    if(image){ctx.drawImage(image,sx,sy,pixels+.3,pixels+.3);return;}
    // Reuse a coarser cached tile while the requested resolution decodes.
    for(let parent=level-1;parent>=0;parent--){
      const factor=2**(level-parent),fallback=resources.peek(levels[parent][Math.floor(x/factor)+','+Math.floor(y/factor)]);
      if(fallback){ctx.drawImage(fallback,(x%factor)*256/factor,(y%factor)*256/factor,256/factor,256/factor,sx,sy,pixels+.3,pixels+.3);return;}
    }
    // When zooming out, cached finer tiles also keep terrain on screen.
    if(level<6)for(let dy=0;dy<2;dy++)for(let dx=0;dx<2;dx++){
      const child=resources.peek(levels[level+1][(2*x+dx)+','+(2*y+dy)]);
      if(child)ctx.drawImage(child,sx+dx*pixels/2,sy+dy*pixels/2,pixels/2+.3,pixels/2+.3);
    }
  }
  function draw(){
    if(!open||!manifest)return;
    resources.begin();
    const icons={};
    const iconFor=role=>{
      if(role&&iconManifest?.icons?.[role]?.path===role+'.webp')return icons[role]||(icons[role]=resources.get('icons/'+role+'.webp'));
      return null;
    };
    for(const [role,badge] of legendIcons){
      if(!Object.hasOwn(PROFESSION_LABELS,role)||layers.has(role)||$('map-professions').open)iconFor(role);
      if(legendPainted.has(role)&&legendPainted.get(role)===icons[role])continue;
      legendPainted.set(role,icons[role]);
      const context=badge.getContext('2d');context.clearRect(0,0,20,20);
      if(icons[role])context.drawImage(icons[role],0,0,20,20);
      else if(!drawNode(context,role,10,10)){context.fillStyle=colors[role];context.font='bold 16px system-ui';context.textAlign='center';context.fillText(symbols[role],10,16);}
    }
    ctx.clearRect(0,0,width,height);ctx.fillStyle='#24333d';ctx.fillRect(0,0,width,height);hit=[];
    const min=world(0,0),max=world(width,height);
    let zoomLevel=clamp(Math.ceil(6+Math.log2(view.scale*(devicePixelRatio||1))),0,6),span=256*2**(6-zoomLevel);
    // Very wide/high-density displays must not create a working set larger
    // than the bounded cache, causing perpetual evict/refetch cycles.
    while(zoomLevel>0&&(Math.ceil(width/view.scale/span)+2)*(Math.ceil(height/view.scale/span)+2)>64){zoomLevel--;span*=2;}
    for(const r of manifest.regions.filter(r=>r.display===display)){
      const levels=terrain.get(r),tiles=levels[zoomLevel];ctx.save();ctx.beginPath();
      for(const b of [r.clip,...(r.holes||[])]){const [x,y]=screen(b[0]+r.offset[0],b[1]+r.offset[1]);ctx.rect(x,y,(b[2]-b[0])*view.scale,(b[3]-b[1])*view.scale);}ctx.clip('evenodd');
      const startX=Math.max(0,Math.floor((Math.max(min[0]-r.offset[0],r.clip[0]))/span)),endX=Math.min(2**zoomLevel-1,Math.floor(Math.min(max[0]-r.offset[0],r.clip[2])/span));
      const startY=Math.max(0,Math.floor((Math.max(min[1]-r.offset[1],r.clip[1]))/span)),endY=Math.min(2**zoomLevel-1,Math.floor(Math.min(max[1]-r.offset[1],r.clip[3])/span));
      for(let x=startX;x<=endX;x++)for(let y=startY;y<=endY;y++){
        if((r.holes||[]).some(h=>inside([x*span,y*span],h)&&inside([(x+1)*span,(y+1)*span],h)))continue;
        const path=tiles[x+','+y];if(!path)continue;
        const [sx,sy]=screen(x*span+r.offset[0],y*span+r.offset[1]);tileImage(levels,zoomLevel,x,y,sx,sy,span*view.scale);
      }ctx.restore();
    }
    const records=[];
    if(overlay&&[...layers].some(l=>l!=='guide')){
      const chunkCount=(Math.floor(max[0]/512)-Math.floor(min[0]/512)+1)*(Math.floor(max[1]/512)-Math.floor(min[1]/512)+1);
      if(view.scale<.3||chunkCount>64){const path=overlay.overviews?.[display];if(path)records.push(...(resources.get('overlays/'+path)||[]));}
      else for(let x=Math.floor(min[0]/512);x<=Math.floor(max[0]/512);x++)for(let y=Math.floor(min[1]/512);y<=Math.floor(max[1]/512);y++){
        const path=overlay.chunks[display+'/'+x+'_'+y];if(path)records.push(...(resources.get('overlays/'+path)||[]));
      }
    }
    const visible=[];
    for(const m of records){
      if(!inside([m.u,m.v],[min[0],min[1],max[0],max[1]]))continue;
      const filtered=filterOverlay(m,layers,enabledEvents,professionTypes);if(filtered)visible.push(filtered);
    }
    ctx.font='bold 13px system-ui';ctx.textAlign='center';ctx.textBaseline='middle';
    const clusters=cluster(visible,screen,24,[view.u*view.scale-width/2,view.v*view.scale-height/2]);
    for(const c of clusters){
      c.count=c.members.reduce((n,m)=>n+(m.count||1),0);
      c.appearance=markerAppearance(c.members.flatMap(m=>m.roles),layers,ordinaryRoles);
      // Mixed clusters retain numbered badges; never borrow one NPC's class.
      if(c.count===1){iconFor(c.appearance.role);iconFor(c.appearance.badge);}
    }
    resources.end();
    if(!motion&&!gesture?.moved){
    locations=clusters.slice(0,200);
    const nextKey=locations.map(c=>c.members.map(m=>m.key||[m.u,m.v,m.count].join(':')).join(',')).join(';');
    if(nextKey!==locationsKey){
      locationsKey=nextKey;const previous=$('map-locations').value;
      $('map-locations').replaceChildren(...locations.map((c,i)=>option(c.members.length===1&&c.members[0].name?c.members[0].name+' ['+c.members[0].id+']'+(locationDescription(c.members[0].roles)?' — '+locationDescription(c.members[0].roles):''):c.count+' snapshot locations',i)));
      $('map-locations').value=locations[+previous]?previous:locations.length?'0':'';$('map-details').disabled=!locations.length;
    }
    }
    for(const c of clusters){
      const {role,badge}=c.appearance;
      drawOverlayMarker(ctx,role,c.x,c.y,c.count,icons[role],colors[role],symbols[role],icons[badge]);
      hit.push({...c,kind:'overlay',badged:c.count===1&&!!badge});
    }
    if(layers.has('guide')){
      let previous=null;ctx.strokeStyle='#84d8ff';ctx.lineWidth=2;
      for(const m of markers){
        if(m.display!==display){previous=null;continue;}
        const p=gesture?.marker?.number===m.number&&gesture.preview?gesture.preview:m,[x,y]=screen(p.u,p.v);
        // No lines between different physical projections, even on a composite continent.
        if(previous&&previous.zone.physical===m.zone.physical){const [a,b]=screen(previous.u,previous.v);ctx.beginPath();ctx.moveTo(a,b);ctx.lineTo(x,y);ctx.stroke();}
        previous=m;
        if(x< -20||y< -20||x>width+20||y>height+20)continue;
        ctx.fillStyle=selected?.number===m.number?'#ffdb76':'#e4f5ff';ctx.beginPath();ctx.arc(x,y,11,0,2*Math.PI);ctx.fill();ctx.stroke();ctx.fillStyle='#152c3d';ctx.fillText(String(m.number),x,y);hit.push({x,y,kind:'guide',marker:m});
      }
    }
  }
  const point=event=>{const r=canvas.getBoundingClientRect();return [event.clientX-r.left,event.clientY-r.top];};
  canvas.onwheel=event=>{if(!open)return;event.preventDefault();if(event.deltaY)zoom(wheelFactor(event.deltaY,event.deltaMode,height),...point(event));};
  canvas.onpointerdown=event=>{
    if(event.button!==0||!manifest)return;motion=null;canvas.focus();const [x,y]=point(event),found=[...hit].reverse().find(h=>markerHit(h,x,y));
    if(found?.kind==='guide')choose(found.marker);
    gesture={id:event.pointerId,x,y,view:{...view},hit:found,marker:found?.marker,text:adapter.read().text,moved:false};canvas.setPointerCapture(event.pointerId);
  };
  canvas.onpointermove=event=>{
    const [x,y]=point(event),[u,v]=world(x,y),coords=zone()?toPercent(manifest,zone(),u,v):null;
    $('map-coordinates').textContent=coords?zone().token+': '+coords.x.toFixed(2)+', '+coords.y.toFixed(2):'Choose the matching zone for percentage coordinates.';
    if(!gesture||gesture.id!==event.pointerId)return;
    if(Math.hypot(x-gesture.x,y-gesture.y)>4)gesture.moved=true;
    if(!gesture.moved)return;
    if(gesture.marker){const c=toPercent(manifest,gesture.marker.zone,u,v);gesture.preview=c?{u,v,...c}:null;request();}
    else{view.u=gesture.view.u-(x-gesture.x)/view.scale;view.v=gesture.view.v-(y-gesture.y)/view.scale;request();}
  };
  canvas.onpointerup=event=>{
    const g=gesture;if(!g)return;gesture=null;canvas.releasePointerCapture(event.pointerId);
    if(g.marker&&g.moved&&g.preview&&g.text===adapter.read().text)action(()=>adapter.move(g.marker,g.preview.x,g.preview.y));
    else if(!g.moved&&g.hit?.kind==='overlay')popup(g.hit.members);
    else if(!g.moved&&!g.hit&&zone()){const c=toPercent(manifest,zone(),...world(...point(event)));if(c)setProposal(c.x,c.y);}
    request();
  };
  function cancel(){motion=null;if(gesture&&!gesture.marker)view=gesture.view;gesture=null;request();}
  canvas.onpointercancel=cancel;canvas.onlostpointercapture=cancel;
  canvas.onkeydown=event=>{
    if(event.key==='Escape'){event.preventDefault();cancel();return;}
    if(['+','=','-','ArrowLeft','ArrowRight','ArrowUp','ArrowDown'].includes(event.key))event.preventDefault();else return;
    if(event.key==='+'||event.key==='=')zoom(1.5);else if(event.key==='-')zoom(1/1.5);
    else{motion=null;view.u+=({'ArrowLeft':-80,'ArrowRight':80}[event.key]||0)/view.scale;view.v+=({'ArrowUp':-80,'ArrowDown':80}[event.key]||0)/view.scale;request();}
  };
  function sync(){
    if(!manifest||!open)return;
    const current=adapter.read();
    if(current.text!==documentText||current.guide!==documentGuide){motion=null;gesture=null;documentText=current.text;documentGuide=current.guide;invalidate();markers=waypoints(current.guide,manifest);$('map-waypoints').replaceChildren(...markers.map(m=>option(m.number+'. Step '+(m.step+1)+' — '+m.zone.token,m.number)));
      $('map-popup').replaceChildren();
      const total=current.guide?.steps.reduce((n,s)=>n+s.lines.filter(l=>/^\s*\.goto\s/.test(l.text)).length,0)||0;
      $('map-source-warning').textContent=total>markers.length?(total-markers.length)+' unsupported/ambiguous waypoint(s) remain source-only.':'';
    }
    selected=markers.find(m=>m.step===current.step&&m.line===current.line)||null;
    $('map-waypoints').value=selected?String(selected.number):'';
    $('map-replace').disabled=!selected;
    $('map-selection').textContent=selected?'Selected waypoint '+selected.number:'Select a guide waypoint, or click terrain.';
    request();
  }
  async function show(value){
    open=value;
    if(!open){controller?.abort();resources.cancel();observer.disconnect();if(frame)cancelAnimationFrame(frame);frame=0;gesture=null;motion=null;return;}
    resources.active=true;
    if(!manifest){
      controller=new AbortController();const local=controller;
      status('Loading local terrain…');
      try{
        const data=await json('manifest.json',local.signal);if(!open||controller!==local)return;
        if(data.schema!==1||!data.regions||!data.zones||!data.tiles)throw new Error('Unsupported map manifest.');
        let nextTerrain=terrainLayers(data),cleanupUnavailable=false;
        try{nextTerrain=terrainLayers(data,await json('terrain-cleanup/manifest.json',local.signal));}
        catch(error){if(error.name==='AbortError')throw error;cleanupUnavailable=true;}
        if(!open||controller!==local)return;
        let nextOverlay=null;
        try{nextOverlay=await json('overlays/manifest.json',local.signal);}catch(error){if(error.name==='AbortError')throw error;}
        if(!open||controller!==local)return;
        let nextIcons=null;
        try{nextIcons=await json('icons/manifest.json',local.signal);}catch(error){if(error.name==='AbortError')throw error;}
        if(!open||controller!==local)return;
        iconManifest=nextIcons?.schema===1?nextIcons:null;
        manifest=data;terrain=nextTerrain;overlay=nextOverlay?.schema===2?nextOverlay:null;eventControls();
        $('map-continent').replaceChildren(...manifest.continents.map(c=>option(c.name,c.id)));$('map-continent').value=display;
        const preferred=manifest.zones.find(z=>z.token==='Durotar');choices(preferred);
        $('map-content').hidden=false;size();fit();
        status((overlay?'Local terrain · snapshot overlays':'Local terrain · overlays unavailable')+(cleanupUnavailable?' · original terrain borders':''));
      }catch(error){if(error.name!=='AbortError')status('Map unavailable. Generate local map assets; manual editing still works.');return;}
    }
    $('map-content').hidden=false;size();observer.observe(canvas);sync();
  }
  return {show,sync,stats:()=>({cached:resources.cache.size,pending:resources.pending.size,running:resources.running,open}),destroy(){show(false);}};
}
