// Prüft Signatur-Attacken (alle Formen mit SPECIAL) und die passiven Fähigkeiten
const {JSDOM}=require('jsdom');const fs=require('fs'),path=require('path');
const html=fs.readFileSync(path.join(__dirname,'../prototype/index.html'),'utf8');
const dom=new JSDOM(html,{url:'https://example.org/',runScripts:'dangerously',pretendToBeVisual:true,beforeParse(w){w.confirm=()=>true;w.matchMedia=()=>({matches:false,addEventListener(){}});Object.defineProperty(w.HTMLElement.prototype,'clientWidth',{get(){return 400}});}});
const w=dom.window,d=w.document,errs=[];w.addEventListener('error',e=>errs.push(e.message));
const key=k=>w.dispatchEvent(new w.KeyboardEvent('keydown',{key:k}));
setTimeout(()=>{const T=w.__G,G=T.G;let fail=0;const ok=(c,m)=>{console.log((c?'OK  ':'FEHLER ')+m);if(!c)fail++};
  // Formen: [Basis, entwickelte Form oder null, Stufe]
  const forms=[['Pixmiez',null,1],['Pixmiez','Blazebit',2],['Pixmiez','Glutluchs',3],['Pixmiez','Pyrolynx',4],['Pixmiez','Firewallo',2],['Pixmiez','Virulina',2],['Pixmiez','Prismiez',2],
    ['Tröpfel',null,1],['Tröpfel','Kaskadi',2],['Tröpfel','Tsunamander',3],['Tröpfel','Pufferling',2],['Tröpfel','Frostbyte',2],
    ['Quakli',null,1],['Quakli','Virulurch',2],['Quakli','Hüpfbyte',2],
    ['Funkling',null,1],['Funkling','Glutbyte',2],['Funkling','Magmawulf',3],['Funkling','Overclocko',2],
    ['Kekso',null,1],['Kekso','Tracko',2],['Kekso','Cachy',2],['Lumi',null,1],['Lumi','Blinki',2],['Lumi','Screenshina',2],
    ['Molchi',null,1],['Molchi','Toxmolch',2],['Molchi','Magmolch',2],['Brummbit',null,1],['Brummbit','Sonnbrumm',2],['Brummbit','Bärtron',2],['Kauzbit',null,1],['Kauzbit','Optikauz',2],['Kauzbit','Raketauz',2],
    ['Pixmiez','Bollwerkatz',3],['Funkling','Turbowulf',3],['Tröpfel','Panzerpuff',3],['Quakli','Mechaquak',3],['Lumi','Holohas',3],['Brummbit','Titanbrumm',3],['Kauzbit','Radarkauz',3]];
  for(const [sp,ev,st] of forms){
    T.freshState();G.col=[{id:'m1',sp}];G.prog.m1={praeg:{},eis:0,pts:0,runs:0,evolved:ev,evolvedEl:ev?'Feuer':null,stage:st};
    T.startRun('m1');const F=G.F;F.e.def=Object.assign({},F.e.def,{hp:999});F.e.hp=F.e.max=999;F.e.r=F.p.r;F.e.c=1;
    const btn=d.querySelector('#special');const shown=!btn.hidden;
    key(' ');const before=F.e.hp;ok(F.e.hp===999,(ev||sp)+': ohne volle Leiste passiert nichts');
    F.sp=100;key(' ');T.update(.5);T.update(.5);
    const effect=F.e.hp<999||F.bubble>0;ok(shown&&effect&&F.sp<100,(ev||sp)+': Signatur-Knopf sichtbar, Angriff wirkt (Gegner '+F.e.hp+'/999'+(F.bubble>0?', Blase '+F.bubble:'')+')');
  }
  // Leiste lädt durch Schaden
  T.freshState();T.startRun('m1');let F=G.F;F.e.hp=F.e.max=999;F.warns.push({cells:[[F.p.c,F.p.r]],t:0,max:.7,dmg:10});T.update(.01);ok(F.sp===0&&G.run.hp===G.run.maxHp,'Pixmiez Katzenreflex: erster Treffer ausgewichen');
  F.warns.push({cells:[[F.p.c,F.p.r]],t:0,max:.7,dmg:10});T.update(.01);ok(G.run.hp===G.run.maxHp-10&&F.sp>0,'Pixmiez: zweiter Treffer trifft und lädt die Leiste ('+Math.round(F.sp)+' %)');
  // Tröpfel Regeneration
  T.freshState();G.col=[{id:'m1',sp:'Tröpfel'}];T.startRun('m1');F=G.F;F.e.def=Object.assign({},F.e.def,{atk:99,move:99});F.e.atkT=99;F.e.moveT=99;G.run.hp-=20;const hp0=G.run.hp;for(let i=0;i<60;i++)T.update(.1);ok(G.run.hp>hp0,'Tröpfel Regeneration: '+hp0+' → '+G.run.hp+' HP in 6 s');
  // Quakli Giftbaut
  T.freshState();G.col=[{id:'m1',sp:'Quakli'}];T.startRun('m1');F=G.F;F.warns.push({cells:[[F.p.c,F.p.r]],t:0,max:.7,dmg:10});T.update(.01);ok(F.e.poison>0,'Quakli Giftbaut: Angreifer vergiftet');
  // Funkling Übermut: jeder 3. Chip halbiert Ladezeit der anderen
  T.freshState();T.startRun('m2');F=G.F;F.hand.forEach(q=>{q.rem=0});T.useSlot(0);F.hand[0].rem=0;T.useSlot(0);F.hand[0].rem=0;const before=F.hand[1].rem=4;T.useSlot(0);ok(F.hand[1].rem===2,'Funkling Übermut: 3. Chip halbiert Ladezeit (4 → '+F.hand[1].rem+')');
  // Lumi Hasenhaken
  T.freshState();G.col=[{id:'m1',sp:'Lumi'}];T.startRun('m1');F=G.F;F.p.cd=0;F.p.c=1;T.movePlayer(1,0);ok(Math.abs(F.p.cd-G.run.M.move*.5)<1e-9,'Lumi Hasenhaken: halbe Bewegungs-Abklingzeit');
  // Kekso Hamstern (statistisch)
  T.freshState();G.col=[{id:'m1',sp:'Kekso'}];T.startRun('m1');F=G.F;F.e.hp=F.e.max=9999;let ham=0;for(let n=0;n<200;n++){F.hand[0].rem=0;const id=F.hand[0].chip;T.useSlot(0);if(F.hand[0].chip===id&&F.fx.some(x=>x.text==='Gehamstert!'))ham++;F.fx=[]}ok(ham>20&&ham<90,'Kekso Hamstern: '+ham+'/200 Chips gehamstert (erwartet ~50)');
  // Screenshina Abbild
  T.freshState();G.col=[{id:'m1',sp:'Lumi'}];G.prog.m1={praeg:{},eis:0,pts:100,runs:0,evolved:'Screenshina',evolvedEl:'Code',stage:2};T.startRun('m1');F=G.F;F.e.hp=F.e.max=999;F.sp=100;key(' ');const hp1=G.run.hp;
  for(let n=0;n<3;n++){F.warns.push({cells:[[F.p.c,F.p.r]],t:0,max:.7,dmg:10});T.update(.01)}ok(G.run.hp===hp1-10,'Screenshina Abbild: 2 Treffer abgefangen, 3. trifft ('+hp1+' → '+G.run.hp+')');
  // Brummbit Dickes Fell
  T.freshState();G.col=[{id:'m1',sp:'Brummbit'}];T.startRun('m1');F=G.F;F.warns.push({cells:[[F.p.c,F.p.r]],t:0,max:.7,dmg:20});T.update(.01);ok(G.run.maxHp-G.run.hp===15,'Brummbit Dickes Fell: 20 Schaden → '+(G.run.maxHp-G.run.hp));
  // Kauzbit Eulenblick + Scanblick
  T.freshState();G.col=[{id:'m1',sp:'Kauzbit'}];T.startRun('m1');F=G.F;F.e.atkT=0;T.update(.01);ok(F.warns.length&&F.warns[0].max===1,'Kauzbit Eulenblick: Warnung 1,0 s statt 0,7 s');
  F.e.hp=F.e.max=999;F.warns=[];F.sp=100;key(' ');const s0=F.e.hp;ok(F.scan===3,'Kauzbit Scanblick: 3 verstärkte Treffer vorgemerkt');
  // Molchi Giftdrüsen
  T.freshState();G.col=[{id:'m1',sp:'Molchi'}];T.startRun('m1');F=G.F;F.e.hp=F.e.max=999;F.e.poison=1;F.e.dotT=0;T.update(.01);ok(F.e.hp===993,'Molchi Giftdrüsen: Gift-Tick 6 statt 4 ('+(999-F.e.hp)+')');
  // Fusion ohne Signatur: Knopf versteckt
  T.freshState();G.col=[{id:'m1',sp:'Dampfbyte'}];T.startRun('m1');ok(d.querySelector('#special').hidden,'Fusion (noch ohne Signatur): Knopf versteckt');
  ok(errs.length===0,'keine Script-Fehler '+JSON.stringify(errs));process.exit(fail?1:0)},300);
