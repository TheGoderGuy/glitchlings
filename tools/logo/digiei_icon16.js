// Digi-Ei als 16-px-Symbol (kleinstes Windows-Symbol), jeder Pixel von Hand gesetzt (03.10.2026).
// Farben wie digiei_32.png, ohne Leiterbahnen (wirkten bei 16 px wie Tränen). Aufruf: node tools/logo/digiei_icon16.js  →  game/assets/logo/digiei_16.png
const path = require("path"), fs = require("fs");
const { PNG } = require(path.join(__dirname, "..", "sprites", "node", "node_modules", "pngjs"));
const P = { o: "#09070f", W: "#faf6e3", h: "#d2faf7", c: "#f3e4c6", s: "#e9caae", d: "#d7a292", g: "#1e2742",
  e: "#0e8ebd", E: "#26e0f3", k: "#0dbdd8", K: "#75faf7" };
const ROWS = [
  "................",
  "......oooo......",
  ".....oWWcco.....",
  "....oWhcccco....",
  "...oWWWccccso...",
  "...ocgcgcgcgco..",
  "..oggEeggEeggo..",
  "..oggeeggeeggo..",
  "..ogcgcgcgcgco..",
  "..oWWccccssddo..",
  "..oWcccccssddo..",
  "...occccssddo...",
  "...occcsssddo...",
  "....ocsssddo....",
  ".....ossddo.....",
  "......oooo......",
];
const png = new PNG({ width: 16, height: 16 });
ROWS.forEach((r, y) => {
  if (r.length !== 16) throw new Error(`Zeile ${y} hat ${r.length} Zeichen`);
  [...r].forEach((ch, x) => {
    if (ch === ".") return;
    const n = parseInt(P[ch].slice(1), 16), j = (y * 16 + x) * 4;
    png.data[j] = n >> 16; png.data[j + 1] = (n >> 8) & 255; png.data[j + 2] = n & 255; png.data[j + 3] = 255;
  });
});
fs.writeFileSync(path.join(__dirname, "..", "..", "game", "assets", "logo", "digiei_16.png"), PNG.sync.write(png));
console.log("digiei_16.png");
