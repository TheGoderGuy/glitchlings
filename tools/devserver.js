// Mini-Webserver für den Prototyp: node tools/devserver.js  →  http://localhost:8123
const http=require('http'),fs=require('fs'),path=require('path');const ROOT=path.join(__dirname,'..','prototype');const PORT=+process.env.PORT||8123;
http.createServer((q,r)=>{let p=decodeURIComponent(q.url.split('?')[0]);if(p==='/')p='/index.html';const f=path.join(ROOT,p);
  if(!f.startsWith(ROOT)||!fs.existsSync(f)){r.writeHead(404);r.end('404');return}
  r.writeHead(200,{'Content-Type':f.endsWith('.html')?'text/html; charset=utf-8':'application/octet-stream','Cache-Control':'no-store'});fs.createReadStream(f).pipe(r)}).listen(PORT,()=>console.log('Glitchlings-Prototyp: http://localhost:'+PORT));
