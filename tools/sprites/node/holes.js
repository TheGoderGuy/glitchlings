// Findet eingeschlossene transparente Löcher (z. B. ausgestanzte Augen). Aufruf: node holes.js <png> [--fill]
// meldet eingeschlossene transparente Löcher; mit --fill werden kleine Löcher (<=16 px) mit der dunkelsten Nachbarfarbe gefüllt
const {PNG}=require('pngjs'),fs=require('fs');const f=process.argv[2];const a=PNG.sync.read(fs.readFileSync(f));const N=a.width;
const T=(x,y)=>a.data[(y*N+x)*4+3]<128;const seen=new Uint8Array(N*N);let filled=0;
for(let y=0;y<N;y++)for(let x=0;x<N;x++){if(!T(x,y)||seen[y*N+x])continue;const st=[[x,y]],comp=[];let border=false;seen[y*N+x]=1;
 while(st.length){const [u,v]=st.pop();comp.push([u,v]);if(u==0||v==0||u==N-1||v==N-1)border=true;for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){const p=u+dx,q=v+dy;if(p<0||q<0||p>=N||q>=N||seen[q*N+p]||!T(p,q))continue;seen[q*N+p]=1;st.push([p,q])}}
 if(border)continue;console.log(f,'Loch',comp.length,'px bei',JSON.stringify(comp.slice(0,4)));
 if(process.argv.includes('--fill')&&comp.length<=16){let best=null,bl=9;for(const [u,v] of comp)for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){const p=u+dx,q=v+dy;const i=(q*N+p)*4;if(a.data[i+3]<128)continue;const l=a.data[i]*.3+a.data[i+1]*.59+a.data[i+2]*.11;if(best==null||l<bl){bl=l;best=i}}
  if(comp.length<=3){for(const [u,v] of comp){const nb=[[1,0],[-1,0],[0,1],[0,-1]].map(([dx,dy])=>((v+dy)*N+u+dx)*4).filter(i=>a.data[i+3]>=128);const j=(v*N+u)*4;for(let c=0;c<3;c++)a.data[j+c]=Math.round(nb.reduce((t,i)=>t+a.data[i+c],0)/nb.length);a.data[j+3]=255;filled++}}else for(const [u,v] of comp){const j=(v*N+u)*4;for(let c=0;c<3;c++)a.data[j+c]=a.data[best+c];a.data[j+3]=255;filled++}}}
if(filled){fs.writeFileSync(f,PNG.sync.write(a));console.log(f,'gefüllt',filled)}
