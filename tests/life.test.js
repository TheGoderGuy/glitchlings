// Station-Leben: Pflege/Bindung und Expeditionen
const {JSDOM}=require('jsdom');const fs=require('fs'),path=require('path');
const html=fs.readFileSync(path.join(__dirname,'../prototype/index.html'),'utf8');
const dom=new JSDOM(html,{url:'https://example.org/',runScripts:'dangerously',pretendToBeVisual:true,beforeParse(w){w.matchMedia=()=>({matches:false,addEventListener(){}});Object.defineProperty(w.HTMLElement.prototype,'clientWidth',{get(){return 400}});}});
const w=dom.window,d=w.document,errs=[];w.addEventListener('error',e=>errs.push(e.message));
const wait=ms=>new Promise(r=>setTimeout(r,ms));
setTimeout(async()=>{const T=w.__G,G=T.G;let fail=0;const ok=(c,m)=>{console.log((c?'OK  ':'FEHLER ')+m);if(!c)fail++};
  T.freshState();T.showStation('team');
  // Pflege öffnen
  const cb=d.querySelector('.card .carebtn');ok(!!cb,'Team-Karte hat „♥ Pflegen“');cb.click();ok(!!d.querySelector('#careStage'),'Pflege-Ansicht geöffnet');
  const id=G.careId;d.querySelector('#pet').click();await wait(700);ok((G.prog[id].bond||0)===2,'Streicheln: Bindung +2');
  d.querySelector('#pet').click();await wait(700);ok(G.prog[id].bond===2,'Streicheln hat Abklingzeit (döst)');
  const k0=G.snacks;d.querySelector('#feed').click();await wait(700);ok(G.prog[id].bond===7&&G.snacks===k0-1,'Füttern: Bindung +5, 1 Keks weniger');
  // Bindungs-Boni im Kampf
  G.prog[id].bond=100;G.careId=null;T.startRun(id);ok(G.F.sp===30,'♥4+: Leiste startet bei 30 %');ok(G.run.maxHp===G.run.M.hp+5,'♥3+: +5 HP');
  const F=G.F;F.warns.push({cells:[[F.p.c,F.p.r]],t:0,max:.7,dmg:999});F.reflex=0;T.update(.01);ok(G.run.hp===1&&!F.over,'♥5 Beste Freunde: K.-o.-Treffer mit 1 HP überstanden');
  F.warns.push({cells:[[F.p.c,F.p.r]],t:0,max:.7,dmg:999});T.update(.01);ok(F.over,'…aber nur einmal pro Run');
  await wait(800);
  // Expedition
  T.freshState();T.showStation('exp');d.querySelector('[data-plan="0"]').click();d.querySelector('[data-zone="glut"]').click();d.querySelector('[data-len="k"]').click();
  d.querySelector('[data-mon="m2"]').click();d.querySelector('#expGo').click();ok(G.exps[0]&&G.exps[0].mon==='m2','Funkling auf Expedition in den Glutkern');
  T.showStation('team');const cards=[...d.querySelectorAll('.card')];ok(cards[1].classList.contains('away'),'Team-Karte zeigt „Auf Expedition“');
  T.startRun('m2');ok(G.screen!=='fight','Monster auf Expedition kann keinen Run starten');
  G.exps[0].start-=G.exps[0].dur*1000+10;T.showStation('exp');const f0=G.frag,s0=G.snacks;d.querySelector('[data-collect="0"]').click();
  ok(G.frag===f0+30&&G.snacks===s0+2,'Abholen mit Heimvorteil (Feuer im Glutkern): +30 Fragmente, +2 Kekse');
  ok(G.prog.m2.bond===3&&G.prog.m2.pts>=22,'Expedition gibt Bindung und Prägung (pts '+G.prog.m2.pts+')');ok(!!d.querySelector('.reveal'),'Rückkehr-Geschichte wird angezeigt: '+d.querySelector('.reveal .t').textContent);
  ok(G.exps[0]===null,'Platz wieder frei');
  // Spielstand
  T.save();const sv=JSON.parse(w.localStorage.getItem('glitchlings-proto-v1'));ok('snacks' in sv&&Array.isArray(sv.exps),'Kekse und Expeditionen werden gespeichert');
  ok(errs.length===0,'keine Script-Fehler '+JSON.stringify(errs));process.exit(fail?1:0)},300);
