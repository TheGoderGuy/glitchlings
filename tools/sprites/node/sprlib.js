// Gemeinsame Helfer: SPR-Daten aus prototype/index.html lesen/schreiben und als PNG exportieren
const fs=require('fs'),path=require('path'),{PNG}=require('pngjs');
const HTML=path.join(__dirname,'../../../prototype/index.html');
const PRE='Object.assign(SPR,';
function readBig(){const lines=fs.readFileSync(HTML,'utf8').split('\n');const li=lines.findIndex(l=>l.startsWith(PRE+'{'));const L=lines[li];return{lines,li,obj:JSON.parse(L.slice(PRE.length,L.lastIndexOf(')')))}}
function writeBig(b){b.lines[b.li]=PRE+JSON.stringify(b.obj)+');';fs.writeFileSync(HTML,b.lines.join('\n'))}
function toPNG(s,rows,scale=1){const N=s.n,o=new PNG({width:N*scale,height:N*scale});
  for(let y=0;y<N*scale;y++)for(let x=0;x<N*scale;x++){const ch=rows[(y/scale)|0][(x/scale)|0];if(ch==='.')continue;const n=parseInt(s.pal[ch].slice(1),16),j=(y*N*scale+x)*4;o.data[j]=n>>16;o.data[j+1]=(n>>8)&255;o.data[j+2]=n&255;o.data[j+3]=255}
  return PNG.sync.write(o)}
module.exports={HTML,readBig,writeBig,toPNG};
