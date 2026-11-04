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
export function markerRole(roles,layers,ordinary){
  return professionKeys.find(role=>layers.has(role)&&roles.includes(role))||ordinary.find(role=>layers.has(role)&&roles.includes(role));
}
export function drawNode(context,role,x,y,radius=8){
  if(!Object.hasOwn(NODE_FILLS,role))return false;
  context.fillStyle=NODE_FILLS[role];context.strokeStyle=NODE_OUTLINE;context.lineWidth=2;
  context.beginPath();context.arc(x,y,radius,0,2*Math.PI);context.fill();context.stroke();
  return true;
}

export function drawOverlayMarker(context,role,x,y,count,icon,color,symbol){
  if(count===1&&icon){
    context.drawImage(icon,x-10,y-10,20,20);
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
