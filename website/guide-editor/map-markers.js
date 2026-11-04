// Project-drawn node symbols: no texture download or external artwork.
export const NODE_FILLS=Object.freeze({creature:'#43b95c',object:'#9a60d0'});
export const NODE_OUTLINE='#d8b24a';
export function drawNode(context,role,x,y,radius=8){
  if(!Object.hasOwn(NODE_FILLS,role))return false;
  context.fillStyle=NODE_FILLS[role];context.strokeStyle=NODE_OUTLINE;context.lineWidth=2;
  context.beginPath();context.arc(x,y,radius,0,2*Math.PI);context.fill();context.stroke();
  return true;
}
