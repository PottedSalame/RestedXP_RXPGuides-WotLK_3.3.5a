// Presentation only. Move existing controls; never copy document state or
// replace form handlers. Tabs and panel state are intentionally session-only.
const $=id=>document.getElementById(id);
const make=(tag,id,text)=>{const n=document.createElement(tag);if(id)n.id=id;if(text)n.textContent=text;return n;};

export function createWorkspace({beforeView=()=>{}}={}){
  const grid=document.querySelector('.editor-grid'),center=make('section','workspace-main'),inspector=make('aside','workspace-inspector');
  const pages=make('div','workspace-pages'),details=make('section','details-page'),locations=make('section','locations-page');
  const context=make('p','selection-context');context.className='selection-context';
  const detailTitle=make('h2',null,'Instruction');details.append(detailTitle,$('instruction-form'),$('line-hint'),$('instruction-errors'));
  locations.append(make('h2',null,'Locations'));
  const locationHint=make('p','locations-hint','Open Map to browse locations.');locationHint.className='hint';locations.append(locationHint);
  const outdoor=document.querySelector('#map-content .map-sidebar'),interior=document.querySelector('#interior-content .map-sidebar');
  locations.append(outdoor,interior);
  let view='write',side='details';
  const positions=new Map();
  const inspectorViews=new Map([['write','details'],['map','locations'],['source','details']]);
  function tabs(id,label,entries,onSelect){
    const bar=make('div',id);bar.className='workspace-tabs';bar.setAttribute('role','tablist');bar.setAttribute('aria-label',label);
    for(const [key,title,panel] of entries){
      const button=make('button',id+'-'+key,title);button.type='button';button.setAttribute('role','tab');button.setAttribute('aria-controls',panel.id);
      panel.setAttribute('role','tabpanel');panel.setAttribute('aria-labelledby',button.id);
      button.onclick=()=>onSelect(key);
      button.onkeydown=e=>{
        const keys=['ArrowLeft','ArrowRight','Home','End'];if(!keys.includes(e.key))return;e.preventDefault();
        const buttons=[...bar.children],at=buttons.indexOf(button),next=e.key==='Home'?0:e.key==='End'?buttons.length-1:(at+(e.key==='ArrowLeft'?-1:1)+buttons.length)%buttons.length;
        buttons[next].focus();buttons[next].click();
      };bar.append(button);
    }
    return {bar,update(){for(const [key,,panel] of entries){const active=(id==='workspace-tabs'?view:side)===key,button=bar.querySelector('#'+id+'-'+key);button.setAttribute('aria-selected',String(active));button.tabIndex=active?0:-1;panel.hidden=!active;}}};
  }
  const panels=[['write','Write',$('write-page')],['map','Map',$('terrain-panel')],['source','Source',$('source-page')]];
  const mainTabs=tabs('workspace-tabs','Editor view',panels,key=>show(key));
  const sideTabs=tabs('inspector-tabs','Inspector',[['details','Instruction',details],['locations','Locations',locations],['lookup','Lookup',$('lookup-page')]],key=>inspect(key));
  pages.append(...panels.map(([, ,p])=>p));center.append(mainTabs.bar,pages);
  inspector.append(context,sideTabs.bar,details,locations,$('lookup-page'));
  function mapVisibility(){
    locationHint.hidden=view==='map';outdoor.hidden=view!=='map'||$('map-kind').value!=='outdoor';interior.hidden=view!=='map'||$('map-kind').value==='outdoor';
  }
  function show(key){
    if(!panels.some(([k])=>k===key))return;
    if(view!==key){
      beforeView();
      inspectorViews.set(view,side);
      const previous=panels.find(([k])=>k===view)[2];positions.set(view,previous.scrollTop);
      const hidingFocus=previous.contains(document.activeElement)||inspector.contains(document.activeElement);view=key;mainTabs.update();
      side=inspectorViews.get(key)||'details';sideTabs.update();
      panels.find(([k])=>k===view)[2].scrollTop=positions.get(view)||0;
      if(hidingFocus)$('workspace-tabs-'+key).focus();
    }
    $('terrain-panel').open=key==='map';mapVisibility();
  }
  function inspect(key){
    if(!['details','locations','lookup'].includes(key))return;
    if(side===key)return;
    const active=inspector.querySelector('[role="tabpanel"]:not([hidden])'),hidingFocus=active?.contains(document.activeElement);
    side=key;sideTabs.update();if(hidingFocus)$('inspector-tabs-'+key).focus();
  }
  grid.insertBefore(center,$('problems-panel'));grid.insertBefore(inspector,$('problems-panel'));
  $('export-menu-content').append($('export-page'));
  // Keep the existing legend/event controls and handlers, only group them.
  const filters=make('details','map-filters');filters.append(make('summary',null,'Layers, professions and events'));
  const hint=$('map-events').nextElementSibling;
  $('map-legend').before(filters);filters.append($('map-legend'),$('map-professions'),$('map-events'));
  if(hint?.classList.contains('hint'))filters.append(hint);
  $('map-kind').addEventListener('change',mapVisibility);
  $('terrain-panel').addEventListener('toggle',()=>{
    // Retain compatibility with the existing map-opening entry point.
    if($('terrain-panel').open&&view!=='map')show('map');
    else if(!$('terrain-panel').open&&view==='map')show('write');
  });
  $('outline-toggle').onclick=()=>{
    const expanded=$('outline-toggle').getAttribute('aria-expanded')!=='true';
    $('outline-toggle').setAttribute('aria-expanded',String(expanded));grid.classList.toggle('outline-open',expanded);
  };
  const menus=[$('file-menu'),$('export-menu')];
  for(const menu of menus)menu.addEventListener('toggle',()=>{if(menu.open)for(const other of menus)if(other!==menu)other.open=false;});
  document.addEventListener('pointerdown',event=>{for(const menu of menus)if(menu.open&&!menu.contains(event.target))menu.open=false;});
  document.addEventListener('keydown',event=>{if(event.key==='Escape')for(const menu of menus)if(menu.open){menu.open=false;menu.querySelector('summary').focus();event.preventDefault();}});
  document.body.classList.add('workspace-ready');mainTabs.update();sideTabs.update();mapVisibility();
  return {show,inspect,context(text){context.textContent=text;},get view(){return view;}};
}
