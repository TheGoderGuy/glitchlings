// PNG -> SPR-Eintrag für prototype/index.html
// Aufruf: node png2spr.js <sprite.png> <SPR-Schlüssel> [--blink "x0,y0,x1,y1[,fx,fy];..."] [--fur x,y] [--insert]
//   --blink  Augen-Rechteck(e), im Blinzel-Frame zugemalt und durch einen Lidstrich ersetzt; mehrere mit ';'.
//            Optional fx,fy je Auge: Pixel, dessen Farbe als Fellfarbe dient.
//   --fur    Standard-Fellfarbe für alle Augen (sonst häufigste Farbe)
//   --insert schreibt den Eintrag direkt in prototype/index.html (ersetzt vorhandenen Eintrag im großen Object.assign)
// Schreibt zusätzlich <Name>_blink.png neben das Original.
const {PNG}=require('pngjs'),fs=require('fs'),path=require('path');
const CH='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$%&*+-/:;<=>?@^_~';
const args=process.argv.slice(2),opt=k=>{const i=args.indexOf(k);return i<0?null:args[i+1]};
const file=args[0],key=args[1];if(!file||!key){console.error('Aufruf: node png2spr.js <png> <key> [--blink x0,y0,x1,y1] [--fur x,y] [--insert]');process.exit(1)}
const img=PNG.sync.read(fs.readFileSync(file)),N=img.width;if(img.height!==N)throw new Error('Sprite muss quadratisch sein');
const hex=i=>'#'+[0,1,2].map(c=>img.data[i+c].toString(16).padStart(2,'0')).join('').toUpperCase();
const grid=[];for(let y=0;y<N;y++){grid.push([]);for(let x=0;x<N;x++){const i=(y*N+x)*4;grid[y].push(img.data[i+3]>=128?hex(i):null)}}
const count=new Map();grid.flat().forEach(c=>c&&count.set(c,(count.get(c)||0)+1));
const lum=h=>{const n=parseInt(h.slice(1),16);return((n>>16)*.3+((n>>8)&255)*.59+(n&255)*.11)/255};
// Blinzel-Frame
const blink=grid.map(r=>r.slice());const bb=opt('--blink');
if(bb){const f=opt('--fur');
  const fur0=f?grid[+f.split(',')[1]][+f.split(',')[0]]:[...count.entries()].sort((a,b)=>b[1]-a[1])[0][0];
  const lid=[...count.keys()].sort((a,b)=>lum(a)-lum(b))[0];
  for(const box of bb.split(';')){const [x0,y0,x1,y1,fx,fy]=box.split(',').map(Number);// Fellfarbe: häufigste helle Farbe im Ring um das Auge (oder fx,fy); je Spalte bevorzugt das Pixel direkt über dem Auge
    const ring=new Map();for(let y=y0-1;y<=y1+1;y++)for(let x=x0-1;x<=x1+1;x++){if(y>=y0&&y<=y1&&x>=x0&&x<=x1)continue;const c=grid[y]&&grid[y][x];if(c&&lum(c)>=.2)ring.set(c,(ring.get(c)||0)+1)}
    const fur=fx!=null&&!isNaN(fx)?grid[fy][fx]:(ring.size?[...ring.entries()].sort((a,b)=>b[1]-a[1])[0][0]:fur0);
    const touchesAir=(x,y)=>[[1,0],[-1,0],[0,1],[0,-1]].some(([dx,dy])=>{const r=grid[y+dy];return !r||!r[x+dx]});
    for(let y=y0;y<=y1;y++)for(let x=x0;x<=x1;x++)if(blink[y][x]&&!touchesAir(x,y)){const up=grid[y0-1]&&grid[y0-1][x];blink[y][x]=up&&lum(up)>=.2&&Math.abs(lum(up)-lum(fur))<.12?up:fur}
    const my=Math.min(y1,Math.round((y0+y1)/2)+1);
    if(x1-x0<4){for(let x=x0;x<=x1;x++)blink[my][x]=lid}else{for(let x=x0+1;x<x1;x++)blink[my][x]=lid;blink[my-1][x0]=lid;blink[my-1][x1]=lid}}
  const out=new PNG({width:N,height:N});blink.forEach((r,y)=>r.forEach((c,x)=>{if(!c)return;const n=parseInt(c.slice(1),16),j=(y*N+x)*4;out.data[j]=n>>16;out.data[j+1]=(n>>8)&255;out.data[j+2]=n&255;out.data[j+3]=255}));
  fs.writeFileSync(file.replace(/\.png$/i,'_blink.png'),PNG.sync.write(out))}
const cols=[];[grid,blink].forEach(g=>g.flat().forEach(c=>{if(c&&!cols.includes(c))cols.push(c)}));
if(cols.length>CH.length)throw new Error(cols.length+' Farben – bitte vorher auf max. '+CH.length+' reduzieren');
const pal={},inv={};cols.forEach((c,i)=>{pal[CH[i]]=c;inv[c]=CH[i]});
const rows=g=>g.map(r=>r.map(c=>c?inv[c]:'.').join(''));
const entry={n:N,pal,px:rows(grid),pb:rows(blink),ol:cols.filter(c=>lum(c)<.2).map(c=>inv[c]).join('')};
const js=JSON.stringify(entry);
console.log(`${key}: ${N}×${N}, ${cols.length} Farben, Kontur/dunkel: ${entry.ol}`);
if(args.includes('--insert')){
  const html=path.join(__dirname,'../../../prototype/index.html');let s=fs.readFileSync(html,'utf8');
  const lines=s.split('\n');const li=lines.findIndex(l=>l.startsWith('Object.assign(SPR,{'));if(li<0)throw new Error('Object.assign(SPR,…) nicht gefunden');
  const L=lines[li],obj=JSON.parse(L.slice('Object.assign(SPR,'.length,L.lastIndexOf(')')));obj[key]=entry;
  lines[li]='Object.assign(SPR,'+JSON.stringify(obj)+');';fs.writeFileSync(html,lines.join('\n'));console.log('eingefügt in',html)}
else console.log(js);
