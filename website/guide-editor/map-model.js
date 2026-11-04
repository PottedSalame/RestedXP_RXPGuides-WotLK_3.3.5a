// Projection and source edits, independent of the canvas and browser fetches.
import {editGuide} from './model.js';
export const ORIGIN = 17066.666666666668, UNIT = 256 / (533.3333333333334);
// Resolve presentation-only tile replacements once, not during every paint.
// Projection helpers continue to use the untouched source manifest.
export function terrainLayers(manifest, cleanup=null) {
  const layers=new Map(manifest.regions.map(r=>[r,manifest.tiles[r.physical]]));
  if(!cleanup)return layers;
  const same=(a,b)=>Array.isArray(a)&&Array.isArray(b)&&a.length===b.length&&a.every((v,i)=>v===b[i]);
  const target=cleanup.region;
  const region=manifest.regions.find(r=>r.physical===530&&r.display===0&&target?.physical===530&&target.display===0&&same(r.clip,target.clip)&&same(r.offset,target.offset));
  if(cleanup.schema!==1||!region||!cleanup.tiles||!cleanup.originalTiles)throw new Error('Terrain cleanup does not match the map.');
  const original=manifest.tiles[region.physical],levels={};
  for(let level=0;level<=6;level++){
    const changes=cleanup.tiles[level],sources=cleanup.originalTiles[level];
    if(!changes||!sources||Object.keys(changes).length!==Object.keys(sources).length)throw new Error('Incomplete terrain cleanup.');
    levels[level]={...original[level]};
    for(const [key,path] of Object.entries(changes)){
      if(!/^\d+,\d+$/.test(key)||path!==level+'/'+key.replace(',','_')+'.webp'||!original[level][key]||sources[key]!==original[level][key])throw new Error('Stale terrain cleanup.');
      levels[level][key]='terrain-cleanup/'+path;
    }
  }
  layers.set(region,levels);
  return layers;
}
export function regionAt(manifest, physical, x, y) {
  const u = (ORIGIN-y)*UNIT, v=(ORIGIN-x)*UNIT;
  return manifest.regions.find(r => r.physical===physical && inside([u,v],r.clip) && !(r.holes||[]).some(h=>inside([u,v],h)));
}
export function inside([x,y], [a,b,c,d]) { return x>=a && x<=c && y>=b && y<=d; }
export function project(manifest, physical, x, y) {
  const r=regionAt(manifest,physical,x,y);
  return r ? {display:r.display,u:(ORIGIN-y)*UNIT+r.offset[0],v:(ORIGIN-x)*UNIT+r.offset[1]} : null;
}
export function fromPercent(manifest,zone,x,y) {
  const [left,top,right,bottom]=zone.bounds;
  return project(manifest,zone.physical,top+(bottom-top)*y/100,left+(right-left)*x/100);
}
export function toPercent(manifest,zone,u,v) {
  const [left,top,right,bottom]=zone.bounds;
  const r=regionAt(manifest,zone.physical,(top+bottom)/2,(left+right)/2);
  if (!r) return null;
  const x=(ORIGIN-(u-r.offset[0])/UNIT-left)/(right-left)*100;
  const y=(ORIGIN-(v-r.offset[1])/UNIT-top)/(bottom-top)*100;
  return Number.isFinite(x+y) && x>=0 && y>=0 && x<=100 && y<=100 ? {x,y} : null;
}
export function parseWaypoint(text,zones) {
  // Only outdoor, ordinary percentage form. Conditions and extra arguments
  // are retained verbatim; world coordinates and floor forms stay source-only.
  const m=/^(\s*\.goto\s+)([^,<>]+)(,\s*)(\d+(?:\.\d+)?)(\s*,\s*)(\d+(?:\.\d+)?)(?=\s*(?:,|<<|>>|$))/.exec(text);
  if (!m || +m[4]>100 || +m[6]>100) return null;
  const matches=zones.filter(z=>z.aliases.includes(m[2].trim()));
  if(matches.length!==1) return null;
  const xStart=m[1].length+m[2].length+m[3].length, yStart=xStart+m[4].length+m[5].length;
  return {zone:matches[0],x:+m[4],y:+m[6],xStart,xEnd:xStart+m[4].length,yStart,yEnd:yStart+m[6].length};
}
export function waypoints(guide,manifest) {
  const result=[];
  guide?.steps.forEach((step,si)=>step.lines.forEach((line,li)=>{
    const waypoint=parseWaypoint(line.text,manifest.zones);
    if (!waypoint) return;
    const position=fromPercent(manifest,waypoint.zone,waypoint.x,waypoint.y);
    if(position) result.push({...waypoint,...position,step:si,line:li,source:line,number:result.length+1});
  }));
  return result;
}
export function moveWaypoint(text,guide,marker,x,y) {
  if(!Number.isFinite(x+y)||x<0||x>100||y<0||y>100) throw new Error('Coordinates must be within 0–100.');
  const line=guide?.steps[marker.step]?.lines[marker.line];
  if (!line || line.text!==marker.source.text || line.start!==marker.source.start) throw new Error('Waypoint changed; select it again.');
  const old=line.text;
  const replacement=old.slice(0,marker.xStart)+x.toFixed(2)+old.slice(marker.xEnd,marker.yStart)+y.toFixed(2)+old.slice(marker.yEnd);
  return editGuide(text,guide,line.start,line.end,replacement);
}
export function cluster(records, screen, size=28, origin=[0,0]) {
  const cells=new Map();
  for(const record of records) {
    const [x,y]=screen(record.u,record.v),key=Math.floor((x+origin[0])/size)+','+Math.floor((y+origin[1])/size);
    let cell=cells.get(key);
    if(!cell) cells.set(key,cell={x:0,y:0,members:[]});
    cell.x+=x;cell.y+=y;cell.members.push(record);
  }
  return [...cells.values()].map(c=>({...c,x:c.x/c.members.length,y:c.y/c.members.length}));
}

export function wheelFactor(delta,mode=0,page=600) {
  const pixels=delta*(mode===1?16:mode===2?page:1);
  return Math.exp(-Math.max(-120,Math.min(120,pixels))*.0018);
}
// Display magnification only: never request tiles above native resolution.
export const MIN_SCALE=.015625,MAX_SCALE=8;
export function zoomAt(view,scale,x,y,width,height) {
  scale=Math.max(MIN_SCALE,Math.min(MAX_SCALE,scale));
  return {scale,u:view.u+(x-width/2)/view.scale-(x-width/2)/scale,
    v:view.v+(y-height/2)/view.scale-(y-height/2)/scale};
}
export function zoomFrame(start,target,elapsed,duration=140) {
  const t=Math.max(0,Math.min(1,elapsed/duration)),eased=1-(1-t)**3;
  return {scale:Math.exp(Math.log(start)+(Math.log(target)-Math.log(start))*eased),done:t===1};
}

// One cancellation generation for view/document changes. LRU storage is
// bounded independently from queued and active requests. No background loop.
export class Resources {
  constructor(load,onReady,{limit=128,concurrency=4}={}) {
    this.load=load;this.onReady=onReady;this.limit=limit;this.concurrency=concurrency;
    this.cache=new Map();this.pending=new Map();this.queue=[];this.running=0;this.epoch=0;this.active=true;
    this.wanted=null;
  }
  begin(){this.wanted=new Set();}
  peek(key){return this.cache.get(key);}
  get(key) {
    this.wanted?.add(key);
    if(this.cache.has(key)) {const value=this.cache.get(key);this.cache.delete(key);this.cache.set(key,value);return value;}
    if(this.active&&!this.pending.has(key)) {this.pending.set(key,null);this.queue.push(key);if(!this.wanted)this.pump();}
    return undefined;
  }
  end(){
    if(!this.wanted)return;
    for(const [key,controller] of this.pending)if(!this.wanted.has(key)){controller?.abort();this.pending.delete(key);}
    this.queue=this.queue.filter(key=>this.wanted.has(key));this.wanted=null;this.pump();
  }
  pump() {
    while(this.active&&this.running<this.concurrency&&this.queue.length) {
      const key=this.queue.shift(),epoch=this.epoch,controller=new AbortController();
      this.pending.set(key,controller);this.running++;
      Promise.resolve().then(()=>this.load(key,controller.signal)).then(value=>{
        if(epoch!==this.epoch||!this.active||this.pending.get(key)!==controller) {value?.close?.();return;}
        this.cache.set(key,value);
        while(this.cache.size>this.limit) {const first=this.cache.keys().next().value;this.cache.get(first)?.close?.();this.cache.delete(first);}
        this.onReady();
      }).catch(error=>{
        if(epoch===this.epoch&&this.active&&this.pending.get(key)===controller&&error.name!=='AbortError') {
          this.cache.set(key,null);
          while(this.cache.size>this.limit) {const first=this.cache.keys().next().value;this.cache.get(first)?.close?.();this.cache.delete(first);}
          this.onReady(error);
        }
      }).finally(()=>{this.running--;if(epoch===this.epoch&&this.pending.get(key)===controller)this.pending.delete(key);this.pump();});
    }
  }
  cancel(active=false) {
    this.epoch++;this.active=active;for(const controller of this.pending.values())controller?.abort();
    this.pending.clear();this.queue=[];this.wanted=null;
  }
}
// Preview event selections, not the live server calendar. Negative links mean
// a location is absent during that event; any positive link can enable it.
export function eventVisible(events,enabled){
  let positive=false,active=false;
  for(const id of events||[]){
    if(id<0&&enabled.has(-id))return false;
    if(id>0){positive=true;if(enabled.has(id))active=true;}
  }
  return !positive||active;
}
export function calendarEvent(event){
  return event.holiday>0||/New Year's Eve|Brew of the Month|Fishing Extravaganza|Fishing Derby/.test(event.name);
}
function eventRoles(roles,dynamic,enabled){
  if(!dynamic?.length)return roles;
  const result=new Set(roles);
  for(const [id,add] of dynamic)if(enabled.has(id))for(const role of add)result.add(role);
  return [...result];
}
function professionRoles(roles,types){
  if(!types||types.trainers&&types.gathering)return roles;
  if((roles.includes('trainer')&&!types.trainers||roles.includes('object')&&!types.gathering)&&roles.some(role=>role.startsWith('profession-')))
    return roles.filter(role=>!role.startsWith('profession-'));
  return roles;
}
export function filterOverlay(record,layers,enabled,types){
  if(record.combinations){
    let count=0;const roles=new Set();
    for(const [base,n,events,dynamic] of record.combinations){
      if(!eventVisible(events,enabled))continue;
      const visible=professionRoles(eventRoles(base,dynamic,enabled),types);
      if(!visible.some(r=>layers.has(r)))continue;
      count+=n;for(const role of visible)roles.add(role);
    }
    return count?{...record,count,roles:[...roles]}:null;
  }
  if(!eventVisible(record.events,enabled))return null;
  const roles=professionRoles(eventRoles(record.roles,record.eventRoles,enabled),types);
  if(!roles.some(r=>layers.has(r)))return null;
  if(roles===record.roles&&!record.eventRoles&&!record.eventStarts)return record;
  const starts=new Set(record.starts);
  for(const [id,quest] of record.eventStarts||[])if(enabled.has(id))starts.add(quest);
  return {...record,roles,starts:[...starts].sort((a,b)=>a-b)};
}
