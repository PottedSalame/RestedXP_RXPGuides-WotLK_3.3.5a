// Project-drawn node symbols: no texture download or external artwork.
export const NODE_FILLS=Object.freeze({creature:'#43b95c',object:'#9a60d0'});
export const NODE_OUTLINE='#d8b24a';
export const PROFESSION_LABELS=Object.freeze({
  'profession-alchemy':'Alchemy','profession-blacksmithing':'Blacksmithing',
  'profession-enchanting':'Enchanting','profession-engineering':'Engineering',
  'profession-herbalism':'Herbalism','profession-inscription':'Inscription',
  'profession-jewelcrafting':'Jewelcrafting','profession-leatherworking':'Leatherworking',
  'profession-mining':'Mining','profession-skinning':'Skinning','profession-tailoring':'Tailoring',
  'profession-cooking':'Cooking','profession-first-aid':'First Aid','profession-fishing':'Fishing'
});
const professionKeys=Object.keys(PROFESSION_LABELS);
export const CLASS_LABELS=Object.freeze({'class-warrior':'Warrior','class-paladin':'Paladin','class-hunter':'Hunter',
  'class-rogue':'Rogue','class-priest':'Priest','class-deathknight':'Death Knight','class-shaman':'Shaman',
  'class-mage':'Mage','class-warlock':'Warlock','class-druid':'Druid'});
export function markerRole(roles,layers,ordinary){
  return professionKeys.find(role=>layers.has(role)&&roles.includes(role))||ordinary.find(role=>layers.has(role)&&roles.includes(role));
}
export function markerAppearance(roles,layers,ordinary){
  const role=markerRole(roles,layers,ordinary);
  if(roles.includes('trainer')&&(layers.has('trainer')||Object.hasOwn(PROFESSION_LABELS,role))){
    const badge=professionKeys.find(key=>layers.has(key)&&roles.includes(key))||roles.find(key=>Object.hasOwn(PROFESSION_LABELS,key)||Object.hasOwn(CLASS_LABELS,key));
    return {role:'trainer',badge};
  }
  return {role};
}
export function locationDescription(roles){
  if(roles.includes('trainer')){
    const subjects=roles.map(r=>PROFESSION_LABELS[r]||CLASS_LABELS[r]).filter(Boolean);
    return subjects.length?subjects.join(' / ')+' trainer':'Trainer';
  }
  if(roles.includes('profession-mining'))return 'Ore deposit';
  if(roles.includes('profession-herbalism'))return 'Herb';
  if(roles.includes('profession-fishing'))return 'Fishing pool';
  return '';
}
export function markerHit(marker,x,y){
  return marker.badged?Math.abs(x-marker.x)<=15&&Math.abs(y-marker.y)<=15:Math.hypot(x-marker.x,y-marker.y)<14;
}
export function drawNode(context,role,x,y,radius=8){
  if(!Object.hasOwn(NODE_FILLS,role))return false;
  context.fillStyle=NODE_FILLS[role];context.strokeStyle=NODE_OUTLINE;context.lineWidth=2;
  context.beginPath();context.arc(x,y,radius,0,2*Math.PI);context.fill();context.stroke();
  return true;
}

export function drawOverlayMarker(context,role,x,y,count,icon,color,symbol,badge){
  if(count===1&&icon){
    context.drawImage(icon,x-10,y-10,20,20);
    if(role==='trainer'&&badge){
      // A small square badge, not a circle behind the client artwork.
      context.drawImage(badge,x+1,y+1,13,13);
      context.strokeStyle='#e4edf2';context.lineWidth=1;context.strokeRect(x+.5,y+.5,14,14);
    }
    return;
  }
  const radius=count>1?11:8,node=drawNode(context,role,x,y,radius);
  if(!node){
    context.fillStyle=color||'#fff';context.strokeStyle='#172530';context.lineWidth=2;
    context.beginPath();context.arc(x,y,radius,0,2*Math.PI);context.fill();context.stroke();
  }
  context.fillStyle=node?'#fff4d6':'#172530';
  if(count>1||!node)context.fillText(count>1?String(count):symbol,x,y);
}
