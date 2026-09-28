// Setzt die Außenkontur der angegebenen Sprites auf fast Schwarz (Stilregel seit 27.09.2026).
// 1) Pixel aus der dunklen Palette (ol), die an Transparenz grenzen, werden schwarz – innere Linien bleiben.
// 2) Wo die Silhouette keine Kontur hat (helles Pixel grenzt an Transparenz), wird außen ein schwarzes Pixel ergänzt.
// Aufruf: node dark_outline.js <key> [<key> ...]      (danach: node spr2png.js <key> ...)
const {readBig,writeBig}=require('./sprlib');
const BLACK='#0C0A17';
const b=readBig();
for(const key of process.argv.slice(2)){const s=b.obj[key];if(!s){console.error('unbekannt:',key);continue}
  let ch=Object.keys(s.pal).find(k=>s.pal[k]===BLACK);
  if(!ch){const CH='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$%&*+-/:;<=>?@^_~';ch=[...CH].find(c=>!(c in s.pal));s.pal[ch]=BLACK;s.ol+=ch}
  // kleine freistehende Teile (Funkeln, Partikel < 20 px) bleiben unverändert
  const small=new Set(),seen=new Set();for(let y=0;y<s.n;y++)for(let x=0;x<s.n;x++){if(s.px[y][x]==='.'||seen.has(y*s.n+x))continue;
    const st=[[x,y]],comp=[];seen.add(y*s.n+x);while(st.length){const [a,q]=st.pop();comp.push(q*s.n+a);for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++){const u=a+dx,v=q+dy;
      if(u<0||v<0||u>=s.n||v>=s.n||s.px[v][u]==='.'||seen.has(v*s.n+u))continue;seen.add(v*s.n+u);st.push([u,v])}}
    if(comp.length<20)comp.forEach(i=>small.add(i))}
  let n=0;const fix=rows=>rows.map((r,y)=>[...r].map((c,x)=>{if(c==='.'||!s.ol.includes(c)||small.has(y*s.n+x))return c;
    const t=[[1,0],[-1,0],[0,1],[0,-1]].some(([dx,dy])=>{const yy=y+dy,xx=x+dx;return yy<0||xx<0||yy>=s.n||xx>=s.n||rows[yy][xx]==='.'});if(t){n++;return ch}return c}).join(''));
  let m=0;const close=rows=>{const g=rows.map(r=>[...r]);rows.forEach((r,y)=>[...r].forEach((c,x)=>{if(c!=='.')return;
    const need=[[1,0],[-1,0],[0,1],[0,-1]].some(([dx,dy])=>{const yy=y+dy,xx=x+dx;if(yy<0||xx<0||yy>=s.n||xx>=s.n)return false;const q=rows[yy][xx];if(q==='.'||s.ol.includes(q)||small.has(yy*s.n+xx))return false;
      // einzelne Funkel-Pixel (ohne Nachbarn) bleiben ohne Kontur
      return [[1,0],[-1,0],[0,1],[0,-1]].some(([ex,ey])=>{const y2=yy+ey,x2=xx+ex;return y2>=0&&x2>=0&&y2<s.n&&x2<s.n&&rows[y2][x2]!=='.'&&!(y2===y&&x2===x)})});
    if(need){g[y][x]=ch;m++}}));return g.map(r=>r.join(''))};
  s.px=close(fix(s.px));if(s.pb)s.pb=close(fix(s.pb));
  // nicht mehr benutzte Palettenfarben entfernen
  const used=new Set((s.px.join('')+(s.pb||[]).join('')));for(const k of Object.keys(s.pal))if(!used.has(k)){delete s.pal[k]}s.ol=[...s.ol].filter(c=>c in s.pal).join('');
  console.log(key,'umgefärbt:',n,'ergänzt:',m)}
writeBig(b);
