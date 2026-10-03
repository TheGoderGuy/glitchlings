// Digi-Ei als 32-px-Symbol, Pixel für Pixel gesetzt (03.10.2026). Farben aus der 128-px-Fassung.
// Aufruf: node tools/logo/digiei_icon32.js <aus.png>   (Ergebnis liegt in game/assets/logo/digiei_32.png)
const {PNG}=require(require("path").join(__dirname,"..","sprites","node","node_modules","pngjs")),fs=require("fs");
const P={o:'#09070f',W:'#faf6e3',c:'#f3e4c6',s:'#e9caae',d:'#d7a292',r:'#b67984',g:'#1e2742',G:'#1f1231',e:'#0e8ebd',E:'#26e0f3',h:'#d2faf7',k:'#0dbdd8',K:'#75faf7',y:'#fde07b',Y:'#f9a52f',b:'#076798'};
const N=32,g=[...Array(N)].map(()=>Array(N).fill(null));
const cx=15.5,cy=17,ry=13.6,rx=10.6;
const inEgg=(x,y)=>{const t=(y+0.5-cy)/ry;if(Math.abs(t)>=1)return false;let hw=rx*Math.sqrt(1-t*t);if(t<0)hw*=1+0.16*t;return Math.abs(x+0.5-cx)<hw};
// Zickzack: Unterkante der Kappe / Oberkante der unteren Schale
const zig=x=>[0,1,2,1][((x%4)+4)%4];
const capBot=x=>10+zig(x);        // letzte Kappenzeile
const lowTop=x=>17+zig(x+2);      // erste Zeile der unteren Schale
for(let y=0;y<N;y++)for(let x=0;x<N;x++){if(!inEgg(x,y))continue;
  const t=(y+0.5-cy)/ry,nx=(x+0.5-cx)/rx;let v=nx*0.6+t*0.45;
  g[y][x]=v<-0.32?"W":v<0.12?"c":v<0.42?"s":"d";
  if(y>capBot(x)&&y<lowTop(x))g[y][x]="g";}
// leuchtende Risskanten
for(let x=0;x<N;x++){if(inEgg(x,capBot(x)))g[capBot(x)][x]='k';const lt=lowTop(x);if(inEgg(x,lt))g[lt][x]='k'}
// Glanzlicht auf der Kappe
for(const [x,y] of [[10,5],[11,5],[9,6],[10,6],[9,7]])g[y][x]='h';
// Augen (4×4, rund, Glanzpunkt oben links)
for(const ex of [10,18]){const E4=["geeg","ehEe","eEEe","geeg"];for(let dy=0;dy<4;dy++)for(let dx=0;dx<4;dx++)g[13+dy][ex+dx]=E4[dy][dx]}
// Schaltkreis auf der unteren Schale
const line=(pts,node)=>{for(const [x,y] of pts)if(g[y][x])g[y][x]='k';const [nx,ny]=node;g[ny][nx]='K'};
line([[9,21],[9,22],[9,23],[10,24]],[10,25]);
line([[15,21],[15,22],[15,23],[15,24],[15,25]],[15,26]);
line([[21,21],[21,22],[22,23]],[22,24]);
for(let y=0;y<N;y++)for(let x=0;x<N;x++){const c=g[y][x];if(c!=="d")continue;const edge=[[1,0],[0,1],[1,1]].some(([dx,dy])=>!(g[y+dy]&&g[y+dy][x+dx]));if(edge)g[y][x]="r"}
// Kontur (8er-Nachbarschaft)
const out=g.map(r=>r.slice());for(let y=0;y<N;y++)for(let x=0;x<N;x++){if(g[y][x])continue;for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){const r=g[y+dy];if(r&&r[x+dx]){out[y][x]='o';break}}}
// Funkeln
for(const [x,y,c] of [[3,7,'y'],[2,7,'Y'],[4,7,'Y'],[3,6,'Y'],[3,8,'Y'],[28,5,'K'],[27,5,'k'],[29,5,'k'],[28,4,'k'],[28,6,'k'],[28,23,'y']])if(!out[y][x])out[y][x]=c;
const o=new PNG({width:N,height:N});out.forEach((r,y)=>r.forEach((c,x)=>{if(!c)return;const n=parseInt(P[c].slice(1),16),j=(y*N+x)*4;o.data[j]=n>>16;o.data[j+1]=(n>>8)&255;o.data[j+2]=n&255;o.data[j+3]=255}));
fs.writeFileSync(process.argv[2],PNG.sync.write(o));console.log(out.map(r=>r.map(c=>c||'.').join('')).join('\n'));
