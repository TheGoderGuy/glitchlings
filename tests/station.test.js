const {JSDOM}=require('jsdom');const fs=require('fs');
const html=fs.readFileSync(require('path').join(__dirname,'../prototype/index.html'),'utf8');
const dom=new JSDOM(html,{url:'https://example.org/',runScripts:'dangerously',pretendToBeVisual:true,beforeParse(w){w.matchMedia=()=>({matches:false,addEventListener(){}});w.confirm=()=>true;}});
const w=dom.window,d=w.document;const errs=[];w.addEventListener('error',e=>errs.push(e.message));
const q=s=>d.querySelector(s),qa=s=>[...d.querySelectorAll(s)];
function playRun(T,id){T.startRun(id);let n=0;while(n++<30000){const G=T.G;
  if(G.screen==='pick'){q('#cpick button').click();continue}
  if(G.screen==='result')return q('.big').textContent;
  if(G.F.over){if(G.run.hp<=0)T.showResult(false);else if(G.run.room>=3)T.showResult(true);else T.showPick();continue}
  for(let i=0;i<3;i++)T.useSlot(i);const F=G.F;
  if(F.warns.length){const bad=F.warns.flatMap(x=>x.cells);if(bad.some(([c,r])=>c===F.p.c&&r===F.p.r)){F.p.cd=0;for(const [dc,dr] of [[1,0],[-1,0],[0,1],[0,-1]]){const c=F.p.c+dc,r=F.p.r+dr;if(c>=0&&c<3&&r>=0&&r<3&&!bad.some(([a,b])=>a===c&&b===r)){T.movePlayer(dc,dr);break}}}}
  if(F.pops.length)F.pops.shift();T.update(1/60)}return 'timeout'}
setTimeout(()=>{const T=w.__G,G=T.G;
 console.log('Start-Screen:',G.screen,'Tabs:',qa('.tab').map(t=>t.textContent).join(' | '));
 console.log('Team-Karten:',qa('#picks .card').length);
 // Brutnest: Ei einlegen
 T.showStation('nest');q('[data-egg]').click();console.log('Nest nach Einlegen:',!!G.nest[0],'Eier übrig',G.eggs.length);
 G.nest[0].start-=60000;T.showStation('nest');q('[data-hatch]').click();console.log('Geschlüpft:',G.reveal&&G.reveal.sp,'Sammlung',G.col.length,'Dex',Object.keys(G.dex).length);
 // Runs
 for(let k=0;k<3;k++)console.log('Run',k+1,playRun(T,'m1'),'| Frag',G.frag,'| Eier',G.eggs.length,'| Pixmiez-Form',G.prog.m1&&G.prog.m1.evolved);
 q('#other').click();console.log('Nach Run -> Tab',G.tab);
 // Fusion ohne Treffer
 T.showStation('lab');G.fuse=['m1','m2'];T.tryFuse();console.log('Fehlversuch:',G.fuseMsg.slice(0,40),'Hints',G.hints.length);
 G.frag=500;G.fuse=['m2','m3'];T.tryFuse();console.log('Fusion:',G.fuseReveal&&G.fuseReveal.sp,'Team',G.col.map(c=>c.sp).join(','),'Frag',G.frag,'Rezepte',G.recipes);
 // Kampf mit Fusionsmonster
 const fid=G.col.find(c=>c.sp==='Dampfbyte').id;console.log('Dampfbyte-Run:',playRun(T,fid));
 T.showStation('dex');console.log('Dex-Kacheln',qa('.dx').length,'unbekannt',qa('.dx.unk').length);
 // Speichern/Laden
 T.save();const snap=JSON.stringify(G.col);T.freshState();T.load();console.log('Laden ok:',JSON.stringify(G.col)===snap);
 // Werbung
 T.showStation('nest');const e=q('[data-egg]');if(e){e.click();const b=q('[data-ad]');if(b){b.click();console.log('Werbemodal:',!!q('.admodal'))}}
 setTimeout(()=>{console.log('Ad fertig:',G.nest.some(n=>n&&n.ad),'Fehler:',errs);process.exit(0)},3500)
},300);
