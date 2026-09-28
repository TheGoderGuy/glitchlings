// Reduziert ein PixelLab-PNG per k-means auf 32 Farben. Aufruf: node reduce32.js <ein.png> <aus.png>
const {PNG}=require('pngjs'),fs=require('fs');
const K=32,IN=process.argv[2],OUTF=process.argv[3];
const a=PNG.sync.read(fs.readFileSync(IN));
const px=[];for(let i=0;i<a.data.length;i+=4)if(a.data[i+3]>0)px.push([a.data[i],a.data[i+1],a.data[i+2],i]);
const d2=(p,c)=>(p[0]-c[0])**2*0.3+(p[1]-c[1])**2*0.59+(p[2]-c[2])**2*0.11;
// deterministische k-means++ (am weitesten entfernte Punkte)
let C=[px[0].slice(0,3)];
while(C.length<K){let best=0,bi=0;for(const p of px){const m=Math.min(...C.map(c=>d2(p,c)));if(m>best){best=m;bi=p;}}C.push(bi.slice(0,3));}
let asg=new Array(px.length);
for(let it=0;it<40;it++){for(let j=0;j<px.length;j++){let b=1e9,bi=0;C.forEach((c,k)=>{const v=d2(px[j],c);if(v<b){b=v;bi=k;}});asg[j]=bi;}
 const S=C.map(()=>[0,0,0,0]);px.forEach((p,j)=>{const s=S[asg[j]];s[0]+=p[0];s[1]+=p[1];s[2]+=p[2];s[3]++;});
 C=C.map((c,k)=>S[k][3]?[S[k][0]/S[k][3],S[k][1]/S[k][3],S[k][2]/S[k][3]]:c);}
C=C.map(c=>c.map(Math.round));
const o=PNG.sync.read(fs.readFileSync(IN));let maxe=0,sum=0;
px.forEach((p,j)=>{const c=C[asg[j]];o.data[p[3]]=c[0];o.data[p[3]+1]=c[1];o.data[p[3]+2]=c[2];o.data[p[3]+3]=255;const e=Math.sqrt((p[0]-c[0])**2+(p[1]-c[1])**2+(p[2]-c[2])**2);maxe=Math.max(maxe,e);sum+=e;});
fs.writeFileSync(OUTF,PNG.sync.write(o));
console.log('K',K,'Farben',new Set(C.map(String)).size,'mittl. Abweichung',(sum/px.length).toFixed(1),'max',maxe.toFixed(1),'(von 441)');
