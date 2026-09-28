// Exportiert SPR-Einträge (großes Object.assign) als PNG: <key>_<n>.png, <key>_<n>_x4.png, <key>_<n>_blink.png nach assets/sprites/
// Aufruf: node spr2png.js <key> [<key> ...]
const fs=require('fs'),path=require('path'),{readBig,toPNG}=require('./sprlib');
const OUT=path.join(__dirname,'../../../assets/sprites');const b=readBig();
for(const key of process.argv.slice(2)){const s=b.obj[key];if(!s){console.error('unbekannt:',key);continue}
  fs.writeFileSync(path.join(OUT,`${key}_${s.n}.png`),toPNG(s,s.px,1));fs.writeFileSync(path.join(OUT,`${key}_${s.n}_x4.png`),toPNG(s,s.px,4));if(s.pb)fs.writeFileSync(path.join(OUT,`${key}_${s.n}_blink.png`),toPNG(s,s.pb,1));
  console.log('exportiert',key)}
