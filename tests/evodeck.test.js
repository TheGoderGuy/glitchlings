// Prüft: entwickelte Formen starten einen Run mit ihrem eigenen Deck (EVO_DECK), Babys mit dem Basis-Deck
const {JSDOM}=require('jsdom');const fs=require('fs'),path=require('path');
const html=fs.readFileSync(path.join(__dirname,'../prototype/index.html'),'utf8');
const dom=new JSDOM(html,{url:'https://example.org/',runScripts:'dangerously',pretendToBeVisual:true,beforeParse(w){w.confirm=()=>true;w.matchMedia=()=>({matches:false,addEventListener(){}});Object.defineProperty(w.HTMLElement.prototype,'clientWidth',{get(){return 400}});}});
const w=dom.window,errs=[];w.addEventListener('error',e=>errs.push(e.message));
setTimeout(()=>{const T=w.__G,G=T.G;let fail=0;const ok=(c,m)=>{console.log((c?'OK  ':'FEHLER ')+m);if(!c)fail++};
  T.freshState();T.startRun('m2');const base=G.run.deck.join(',');ok(G.run.deck.length===8&&base.includes('Glutball'),'Funkling (Baby) startet mit Basis-Deck: '+base);
  T.freshState();G.prog.m2={praeg:{Code:50},eis:0,pts:100,runs:0,evolved:'Overclocko',evolvedEl:'Code',stage:2};T.startRun('m2');
  const oc=G.run.deck;ok(oc.filter(c=>c==='Mini-Bot'||c==='Firewall').length>=4,'Overclocko startet Code-lastig: '+oc.join(','));
  T.freshState();G.prog.m3={praeg:{Wasser:50},eis:0,pts:300,runs:0,evolved:'Tsunamander',evolvedEl:'Wasser',stage:3};T.startRun('m3');
  ok(G.run.deck.filter(c=>['Wasserstrahl','Eisfeld','Blubberschild'].includes(c)).length>=7,'Tsunamander startet Wasser-lastig: '+G.run.deck.join(','));
  T.freshState();T.showStation('team');const ub=w.document.querySelector('#unlockAll');ub.click();ok(G.col.length===3,'1. Tippen ändert nur den Text: '+ub.textContent);ub.click();
  ok(G.col.length===45&&Object.keys(G.dex).length===45,'Testknopf „Alle Monster freischalten“: '+G.col.length+' im Team, Dex '+Object.keys(G.dex).length);
  ok(errs.length===0,'keine Script-Fehler '+JSON.stringify(errs));process.exit(fail?1:0)},300);
