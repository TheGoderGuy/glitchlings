// Findet Augen-Kandidaten für den Blinzel-Frame: dunkle Pixelgruppen im Inneren (berühren keine Transparenz),
// mit einem hellen Glanzpunkt in der Nähe. Gibt das --blink-Argument für png2spr.js aus.
// Aufruf: node eyes.js <png> [maxAugen=2]
const {PNG}=require('pngjs'),fs=require('fs');const a=PNG.sync.read(fs.readFileSync(process.argv[2]));const N=a.width,MAX=+process.argv[3]||2;
const px=(x,y)=>{if(x<0||y<0||x>=N||y>=N)return null;const i=(y*N+x)*4;return a.data[i+3]<128?null:[a.data[i],a.data[i+1],a.data[i+2]]};
const lum=c=>(c[0]*.3+c[1]*.59+c[2]*.11)/255;
const dark=(x,y)=>{const c=px(x,y);return c&&lum(c)<.25};
const seen=new Set(),cands=[];
for(let y=0;y<N;y++)for(let x=0;x<N;x++){if(!dark(x,y)||seen.has(y*N+x))continue;const st=[[x,y]],comp=[];let edge=false;seen.add(y*N+x);
  while(st.length){const [u,v]=st.pop();comp.push([u,v]);for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){const p=u+dx,q=v+dy;if(!px(p,q)){edge=true;continue}if(dark(p,q)&&!seen.has(q*N+p)){seen.add(q*N+p);st.push([p,q])}}}
  if(edge||comp.length<2||comp.length>N*N/60)continue;
  const xs=comp.map(c=>c[0]),ys=comp.map(c=>c[1]);let [x0,x1,y0,y1]=[Math.min(...xs),Math.max(...xs),Math.min(...ys),Math.max(...ys)];
  if(x1-x0>N/5||y1-y0>N/5)continue;
  let hi=0;for(let v=y0-1;v<=y1+1;v++)for(let u=x0-1;u<=x1+1;u++){const c=px(u,v);if(c&&lum(c)>.8)hi++}
  // Iris (farbige Pixel direkt am Pupillenrand) mit einschließen
  cands.push({x0,y0,x1,y1,n:comp.length,hi,score:hi*3+comp.length-(y0/N)*5})}
cands.sort((p,q)=>q.score-p.score);
const pick=cands.filter(c=>c.hi>0).slice(0,MAX);
console.error(cands.slice(0,6).map(c=>`${c.x0},${c.y0}-${c.x1},${c.y1} n=${c.n} glanz=${c.hi}`).join('\n'));
console.log(pick.map(c=>[Math.max(0,c.x0),Math.max(0,c.y0-1),Math.min(N-1,c.x1),Math.min(N-1,c.y1+1)].join(',')).join(';'));
