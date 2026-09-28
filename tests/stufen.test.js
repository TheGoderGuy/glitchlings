const {JSDOM}=require('jsdom');const fs=require('fs');
const html=fs.readFileSync(require('path').join(__dirname,'../prototype/index.html'),'utf8');
const dom=new JSDOM(html,{url:'https://example.org/',runScripts:'dangerously',pretendToBeVisual:true,beforeParse(w){w.matchMedia=()=>({matches:false,addEventListener(){}});w.devicePixelRatio=2;Object.defineProperty(w.HTMLElement.prototype,'clientWidth',{get(){return 400}});}});
const w=dom.window,d=w.document;const errs=[];w.addEventListener('error',e=>errs.push(e.message));
setTimeout(async()=>{const T=w.__G,G=T.G;
 const out=[];
 for(let i=0;i<6;i++){const b=d.querySelector('#testEvo .minib');b.click();out.push(G.prog.m1&&G.prog.m1.evolved+'/'+G.prog.m1.stage)}
 console.log('Stufenfolge Pixmiez:',out.join(' -> '));console.log('Dex:',Object.keys(G.dex).join(','));
 // Kampf-Screenshot mit Ultra
 T.startRun('m1');const F=G.F;G.screen='x';F.warns=[];F.p.c=1;F.p.r=1;F.e.c=1;F.e.r=1;F.p.flash=0;F.e.flash=0;
 G.screen='fight';await new Promise(r=>setTimeout(r,80));G.screen='x';
 fs.writeFileSync(require('path').join(__dirname,'ultra_fight.png'),Buffer.from(d.querySelector('#cv').toDataURL().split(',')[1],'base64'));
 console.log('Fehler:',errs);process.exit(0)},300);
