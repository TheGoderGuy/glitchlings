// Idle-Animation aus PixelLab-Frames ins Spiel übernehmen.
// Aufruf: node anim_frames.js <sprite-name> <rohframe-präfix> [--frames 0,1,2,3,4,5] [--replace 1=0,…]
//   <sprite-name>     z. B. pixi_32 (Grundbild: game/assets/sprites/<name>.png)
//   <rohframe-präfix> z. B. /tmp/pixi_32_raw_  (Dateien <präfix>0.png … <präfix>6.png, Frame 0 = Eingabe)
//   --frames          welche Rohframes in welcher Reihenfolge (Standard 0–5; Frame 6 läuft zurück auf 0)
//   --replace a=b     Rohframe a durch Rohframe b ersetzen (z. B. verzogenen Frame durch das Original)
//   --kind atk        Angriffsanimation statt Idle (Ausgabe <name>_atk_<i>.png, 05.10.2026)
// Jeder Frame wird auf die Palette des Grundbilds gezogen (nächste Farbe), damit nichts flimmert und die
// 32-Farben-Regel hält. Ausgabe: game/assets/sprites/anim/<name>_idle_<i>.png
const {PNG} = require("pngjs"), fs = require("fs"), path = require("path");
const args = process.argv.slice(2);
const opt = (k, d) => { const i = args.indexOf(k); return i < 0 ? d : args[i + 1]; };
const [name, prefix] = args;
if (!name || !prefix) { console.error("Aufruf: node anim_frames.js <sprite-name> <rohframe-präfix> [--frames …] [--replace a=b]"); process.exit(1); }
const root = path.resolve(__dirname, "../../../game/assets/sprites");
const base = PNG.sync.read(fs.readFileSync(path.join(root, name + ".png")));
const pal = [];
for (let i = 0; i < base.data.length; i += 4) {
  if (base.data[i + 3] < 128) continue;
  const c = [base.data[i], base.data[i + 1], base.data[i + 2]];
  if (!pal.some(p => p[0] === c[0] && p[1] === c[1] && p[2] === c[2])) pal.push(c);
}
const nearest = (r, g, b) => { let best = pal[0], bd = 1e9; for (const p of pal) { const d = (p[0]-r)**2*0.3 + (p[1]-g)**2*0.59 + (p[2]-b)**2*0.11; if (d < bd) { bd = d; best = p; } } return best; };
const kind = opt("--kind", "idle");
const order = opt("--frames", "0,1,2,3,4,5").split(",").map(Number);
const repl = {};
for (const r of (opt("--replace", "") || "").split(",").filter(Boolean)) { const [a, b] = r.split("=").map(Number); repl[a] = b; }
fs.mkdirSync(path.join(root, "anim"), {recursive: true});
let bgFixed = 0;
order.forEach((raw, i) => {
  const src = repl[raw] !== undefined ? repl[raw] : raw;
  const f = PNG.sync.read(fs.readFileSync(prefix + src + ".png"));
  if (f.width !== base.width || f.height !== base.height) throw new Error("Größe passt nicht: " + prefix + src);
  removeBackground(f);
  const out = new PNG({width: f.width, height: f.height});
  for (let j = 0; j < f.data.length; j += 4) {
    if (f.data[j + 3] < 128) continue;
    const c = nearest(f.data[j], f.data[j + 1], f.data[j + 2]);
    out.data[j] = c[0]; out.data[j + 1] = c[1]; out.data[j + 2] = c[2]; out.data[j + 3] = 255;
  }
  fs.writeFileSync(path.join(root, "anim", `${name}_${kind}_${i}.png`), PNG.sync.write(out));
});
console.log(`${name}: ${order.length} Frames, Palette ${pal.length} Farben${bgFixed ? `, Hintergrund entfernt (${bgFixed} Frames)` : ""}`);

// PixelLab liefert manchmal Frames mit gefülltem Hintergrund (z. B. Bollwerkatz_80): Ist der Bildrand
// überwiegend deckend, wird vom Rand aus alles transparent, was der häufigsten Randfarbe ähnelt.
function removeBackground(img) {
  const W = img.width, H = img.height, d = img.data;
  // Hintergrund vorhanden, wenn der Frame deutlich mehr deckende Pixel hat als das Grundbild
  let opq = 0, baseOpq = 0;
  for (let i = 3; i < d.length; i += 4) { if (d[i] >= 128) opq++; if (base.data[i] >= 128) baseOpq++; }
  if (opq < baseOpq * 1.4) return;
  const border = [];
  for (let x = 0; x < W; x++) border.push([x, 0], [x, H - 1]);
  for (let y = 1; y < H - 1; y++) border.push([0, y], [W - 1, y]);
  // Hintergrundfarbe: häufigste deckende Farbe dort, wo das Grundbild durchsichtig ist
  const counts = {};
  for (let i = 0; i < d.length; i += 4) { if (d[i + 3] < 128 || base.data[i + 3] >= 128) continue; const k = (d[i] >> 3) + "," + (d[i + 1] >> 3) + "," + (d[i + 2] >> 3); counts[k] = (counts[k] || 0) + 1; }
  const top = Object.entries(counts).sort((a, b) => b[1] - a[1])[0][0].split(",").map(v => v * 8 + 4);
  const near = i => Math.abs(d[i] - top[0]) + Math.abs(d[i + 1] - top[1]) + Math.abs(d[i + 2] - top[2]) < 60;
  const seen = new Uint8Array(W * H), st = [];
  for (const [x, y] of border) st.push([x, y]);
  while (st.length) {
    const [x, y] = st.pop();
    if (x < 0 || y < 0 || x >= W || y >= H || seen[y * W + x]) continue;
    seen[y * W + x] = 1;
    const i = (y * W + x) * 4;
    if (d[i + 3] >= 128 && !near(i)) continue;
    d[i + 3] = 0;
    st.push([x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]);
  }
  bgFixed++;
}
