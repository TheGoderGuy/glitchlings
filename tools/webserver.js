// Mini-Webserver für den Godot-Web-Build: node tools/webserver.js  →  http://localhost:8124
// Liefert build/web aus (vorher bauen: Web_bauen.bat). Richtige MIME-Typen, damit .wasm im Browser lädt.
const http = require("http"), fs = require("fs"), path = require("path");
const ROOT = path.join(__dirname, "..", "build", "web");
const PORT = +process.env.PORT || 8124;
const TYPES = { ".html": "text/html; charset=utf-8", ".js": "text/javascript", ".wasm": "application/wasm", ".pck": "application/octet-stream", ".png": "image/png" };
http.createServer((q, r) => {
  let p = decodeURIComponent(q.url.split("?")[0]);
  if (p === "/") p = "/index.html";
  // Test wie auf itch.io: Spiel in einem festen 1280×720-Rahmen (verkleinert dargestellt)
  if (p === "/_itch") {
    r.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    r.end("<body style=\"margin:0;background:#222\"><iframe src=\"/index.html\" width=\"1280\" height=\"720\" style=\"border:0;transform:scale(" + (q.url.split("s=")[1] || "0.4") + ");transform-origin:0 0\"></iframe></body>");
    return;
  }
  const f = path.join(ROOT, p);
  if (!f.startsWith(ROOT) || !fs.existsSync(f)) { r.writeHead(404); r.end("404"); return; }
  r.writeHead(200, { "Content-Type": TYPES[path.extname(f)] || "application/octet-stream", "Cache-Control": "no-store" });
  fs.createReadStream(f).pipe(r);
}).listen(PORT, () => console.log("Glitchlings Web-Build: http://localhost:" + PORT));
