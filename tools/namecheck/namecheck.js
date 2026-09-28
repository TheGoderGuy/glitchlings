// Prüft Monsternamen gegen Pokémon (deutsch + englisch, PokéWiki) und Digimon (Wikimon).
// Aufruf: node namecheck.js <pokewiki.html> <wikimon.html> Name1 Name2 ...
// Meldet exakte Treffer und sehr ähnliche Namen (Levenshtein-Abstand <= 2 oder gleicher Anfang/Ende ab 6 Zeichen).
const fs=require('fs');const [pw,dm,...names]=process.argv.slice(2);
const words=new Set();
const grab=(f,re)=>{const s=fs.readFileSync(f,'utf8');for(const m of s.matchAll(re))words.add(m[1].trim())};
grab(pw,/title="([A-ZÄÖÜ][A-Za-zÄÖÜäöüß\-.' ]{2,20})"/g);
grab(dm,/title="([A-Z][A-Za-z\-.' ]{2,24}mon[A-Za-z]*)"/g);
grab(dm,/title="([A-Z][A-Za-z\-]{3,24})"/g);
const lev=(a,b)=>{a=a.toLowerCase();b=b.toLowerCase();const d=[...Array(b.length+1).keys()];for(let i=1;i<=a.length;i++){let p=d[0];d[0]=i;for(let j=1;j<=b.length;j++){const t=d[j];d[j]=Math.min(d[j]+1,d[j-1]+1,p+(a[i-1]===b[j-1]?0:1));p=t}}return d[b.length]};
console.log('Vergleichsliste:',words.size,'Namen');
for(const n of names){const hits=[];for(const w of words){const l=lev(n,w);if(l===0)hits.push(w+' (EXAKT)');else if(l<=2&&Math.min(n.length,w.length)>=5)hits.push(w+' (Abstand '+l+')')}
  console.log((hits.length?'⚠ ':'✓ ')+n+(hits.length?': '+hits.slice(0,6).join(', '):''))}
