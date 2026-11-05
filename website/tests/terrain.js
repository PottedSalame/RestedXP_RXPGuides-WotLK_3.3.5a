// Optional actual-artwork check, never required in a source-only checkout.
const frame=document.getElementById('terrain-editor');
await new Promise(resolve=>frame.addEventListener('load',resolve,{once:true}));
const w=frame.contentWindow,d=frame.contentDocument,sleep=ms=>new Promise(r=>setTimeout(r,ms));
const result=document.getElementById('terrain-result'),issues=[];
let requests=0,active=0,peak=0,tiles=0,failed=0,decoding=0;
const bitmap=w.createImageBitmap.bind(w);
w.createImageBitmap=async(...args)=>{decoding++;try{return await bitmap(...args);}finally{decoding--;}};
const fetch=w.fetch;
w.fetch=async(...args)=>{
  const local=String(args[0]).includes('/map-assets-local/');if(local){requests++;active++;peak=Math.max(peak,active);}
  try{const response=await fetch(...args);if(local&&String(args[0]).endsWith('.webp')){tiles++;if(!response.ok)failed++;}return response;}
  finally{if(local)active--;}
};
try{
  await sleep(100);d.getElementById('terrain-panel').open=true;
  for(let i=0;i<100&&d.getElementById('map-content').hidden;i++)await sleep(100);
  if(d.getElementById('map-content').hidden)throw new Error(d.getElementById('map-status').textContent);
  const select=(id,value)=>{const n=d.getElementById(id);n.value=value;n.dispatchEvent(new w.Event('change'));};
  const requested=new URLSearchParams(location.search).get('zone');
  const targets=requested?[requested]:['Durotar','Elwynn Forest','Hellfire Peninsula','BoreanTundra','Eversong Woods','Azuremyst Isle'];
  const manifest=await fetch(new URL('../map-assets-local/manifest.json',location.href)).then(r=>r.json());
  for(const name of targets){
    const zone=manifest.zones.find(z=>z.token===name);if(!zone)throw new Error('Missing zone '+name);
    select('map-continent',zone.display);select('map-zone',zone.id);
    d.getElementById('terrain-panel').scrollIntoView();
    await sleep(800);for(let i=0;i<60&&(active||decoding);i++)await sleep(100);await sleep(100);
    const canvas=d.getElementById('terrain'),pixels=canvas.getContext('2d').getImageData(0,0,canvas.width,canvas.height).data;
    let textured=0;
    for(let i=0;i<pixels.length;i+=400)if(pixels[i]!==36||pixels[i+1]!==51||pixels[i+2]!==61)textured++;
    if(textured<100)issues.push(name+': terrain did not paint');
    // Trigger resize and keyboard paths without changing guide content.
    canvas.dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowRight',cancelable:true}));
    canvas.dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowLeft',cancelable:true}));
  }
  const canvas=d.getElementById('terrain'),context=canvas.getContext('2d'),clear=context.clearRect.bind(context);
  let paints=0;context.clearRect=(...args)=>{paints++;return clear(...args);};
  const rect=canvas.getBoundingClientRect(),before=d.getElementById('source').value;
  if(Math.abs(rect.width-rect.height)>1)issues.push('Wide map is not square');
  canvas.dispatchEvent(new w.WheelEvent('wheel',{deltaY:-60,deltaMode:0,clientX:rect.left+100,clientY:rect.top+150,cancelable:true}));
  await sleep(250);
  if(paints<2)issues.push('Wheel zoom did not render intermediate frames');
  for(let i=0;i<60&&(active||decoding);i++)await sleep(100);
  await sleep(300);const settled=paints;await sleep(300);
  if(paints!==settled)issues.push('Map keeps repainting after zoom settles');
  if(d.getElementById('source').value!==before)issues.push('Zoom changed guide source');
  const badges=[...d.querySelectorAll('.map-legend-icon')];
  // Client images have multiple colours; fallback glyphs have one plus alpha.
  const colours=badge=>{const pixels=badge.getContext('2d').getImageData(0,0,20,20).data,set=new Set();for(let i=0;i<pixels.length;i+=4)if(pixels[i+3]>200)set.add([pixels[i],pixels[i+1],pixels[i+2]].join(','));return set.size;};
  if(badges.filter(b=>colours(b)>5).length<5)issues.push('Five client legend icons did not render');
  if(!d.querySelector('[data-layer="repair"]'))issues.push('Repair layer missing');
  for(const [role,expected] of [['creature',[67,185,92,255]],['object',[154,96,208,255]]]){
    const badge=d.querySelector('[data-layer="'+role+'"]').parentNode.querySelector('canvas');
    if(JSON.stringify([...badge.getContext('2d').getImageData(10,10,1,1).data])!==JSON.stringify(expected))issues.push('Incorrect '+role+' legend node');
  }
  const fill=context.fill.bind(context),nodePaints=new Set();
  context.fill=(...args)=>{if(context.strokeStyle==='#d8b24a')nodePaints.add(context.fillStyle);return fill(...args);};
  for(const role of ['creature','object'])d.querySelector('[data-layer="'+role+'"]').click();
  await sleep(300);for(let i=0;i<60&&(active||decoding);i++)await sleep(100);await sleep(100);
  context.fill=fill;
  if(!nodePaints.has('#43b95c')||!nodePaints.has('#9a60d0'))issues.push('Generic map markers did not use both gold-bordered node styles');
  // Real snapshot controls: seasonal markers affect the current renderer and
  // location list, not just a synthetic predicate. Terrain remains cached.
  const winter=d.querySelector('[data-event="2"]'),events=winter?.closest('details');
  if(!winter||winter.checked)issues.push('Winter Veil should be individually selectable and initially hidden');
  if(events){
    const snapshot=d.getElementById('source').value;
    const beforeLocations=d.getElementById('map-locations').textContent;
    const fetches=requests;
    d.getElementById('map-popup').textContent='Stale event action';
    events.querySelector('[aria-label="Show all calendar events"]').click();await sleep(250);
    if(d.getElementById('map-popup').textContent)issues.push('Event change retained stale popup actions');
    if(d.getElementById('map-locations').textContent===beforeLocations)issues.push('Calendar events did not change visible snapshot locations');
    events.querySelector('[aria-label="Hide all calendar events"]').click();await sleep(250);
    if(d.getElementById('map-locations').textContent!==beforeLocations)issues.push('Calendar hide did not restore location list');
    if(d.getElementById('source').value!==snapshot)issues.push('Calendar filters changed guide source');
    if(requests!==fetches)issues.push('Calendar filters refetched unchanged terrain/chunks');
  }
  const professionControls=[...d.querySelectorAll('#map-profession-options input')];
  if(professionControls.length!==14||professionControls.some(c=>c.checked))issues.push('Fourteen profession layers must start disabled');
  d.getElementById('map-professions').open=true;await sleep(250);
  for(let i=0;i<60&&(active||decoding);i++)await sleep(100);await sleep(100);
  for(const control of professionControls){
    if(colours(control.parentNode.querySelector('canvas'))<5)issues.push('Client profession icon missing: '+control.dataset.layer);
  }
  let professionPaints=0;const professionDraw=context.drawImage.bind(context);
  context.drawImage=(...args)=>{if(args[0].width===64&&args[0].height===64)professionPaints++;return professionDraw(...args);};
  for(const control of professionControls)control.click();await sleep(300);
  context.drawImage=professionDraw;
  if(!professionPaints)issues.push('Selected professions did not paint client icons on actual terrain');
  for(const control of professionControls)control.click();d.getElementById('map-professions').open=false;
  // Actual snapshot markers, including filtered popup actions. No data reload
  // should be needed when only faction selection changes.
  for(const [continent,zoneId,hiddenSide] of [[1,4,'horde'],[0,30,'alliance']]){
  select('map-continent',continent);select('map-zone',zoneId);
  for(const input of d.querySelectorAll('[data-layer]')){
    const on=['guide','start','end','repair','vendor','trainer'].includes(input.dataset.layer);
    if(input.checked!==on)input.click();
  }
  await sleep(600);for(let i=0;i<100&&(active||decoding);i++)await sleep(100);await sleep(100);
  const alliance=d.getElementById('map-alliance'),horde=d.getElementById('map-horde');
  if(alliance.disabled||horde.disabled)issues.push('Faction evidence not available');
  for(const input of [alliance,horde]){
    if(input.type!=='checkbox'||!input.checked||!input.closest('label'))issues.push('Faction checkbox is not labelled and initially checked');
    if(colours(d.getElementById(input.id+'-icon'))<5)issues.push('Client faction icon missing: '+input.id);
  }
  const allLocations=d.getElementById('map-locations').textContent,factionFetches=requests,factionSource=d.getElementById('source').value;
  const toggle=hiddenSide==='horde'?horde:alliance;
  toggle.click();await sleep(250);
  if(d.getElementById('map-locations').textContent===allLocations)issues.push(hiddenSide+' toggle did not filter actual starter-zone locations');
  const locationList=d.getElementById('map-locations');
  for(let i=0;i<Math.min(locationList.options.length,10);i++){
    select('map-locations',i);d.getElementById('map-details').click();
    const popup=d.getElementById('map-popup').textContent;
    if(popup.includes((hiddenSide==='horde'?'Horde':'Alliance')+' affiliation'))issues.push('Hidden faction marker remained actionable');
  }
  toggle.click();await sleep(250);
  if(d.getElementById('map-locations').textContent!==allLocations)issues.push('Both factions did not restore the original markers');
  if(d.getElementById('map-popup').textContent)issues.push('Faction change retained stale popup');
  if(requests!==factionFetches)issues.push('Faction toggles refetched terrain or overlay data');
  if(d.getElementById('source').value!==factionSource)issues.push('Faction controls changed guide source');
  }
  // Exercise the production controls beyond the former 2x ceiling. Native
  // 256px tiles should paint at 2048px, not request invented higher levels.
  const drawImage=context.drawImage.bind(context);let largestTile=0;
  context.drawImage=(...args)=>{if(args.length===5)largestTile=Math.max(largestTile,args[3]);return drawImage(...args);};
  for(let i=0;i<12;i++)d.getElementById('map-in').click();
  await sleep(300);for(let i=0;i<60&&(active||decoding);i++)await sleep(100);await sleep(100);
  if(largestTile<2048||largestTile>2049)issues.push('Production zoom did not reach the bounded 8x native scale');
  context.drawImage=drawImage;d.getElementById('map-reset').click();
  await sleep(100);d.getElementById('terrain-panel').open=false;await sleep(100);const count=requests;await sleep(300);
  if(requests!==count)issues.push('Requests continued while collapsed');
  if(peak>4)issues.push('More than four simultaneous map requests');if(!tiles||failed)issues.push('Tile response failures');
  d.getElementById('terrain-panel').open=true;await sleep(100);d.getElementById('terrain-panel').scrollIntoView();
  result.textContent=JSON.stringify({passed:issues.length===0,issues,requests,peak,tiles});result.dataset.status=issues.length?'failed':'passed';
}catch(error){result.textContent=error.message;result.dataset.status='failed';}
