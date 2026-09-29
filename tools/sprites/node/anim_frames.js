// Idle-Animation aus PixelLab-Frames ins Spiel übernehmen.
// Aufruf: node anim_frames.js <sprite-name> <rohframe-präfix> [--frames 0,1,2,3,4,5] [--replace 1=0,…]
//   <sprite-name>     z. B. pixi_32 (Grundbild: game/assets/sprites/<name>.png)
//   <rohframe-präfix> z. B. /tmp/pixi_32_raw_  (Dateien <präfix>0.png … <präfix>6.png, Frame 0 = Eingabe)
//   --frames          welche Rohframes in welcher Reihenfolge (Standard 0–5; Frame 6 läuft zurück auf 0)
//   --replace a=b     Rohframe a durch Rohframe b ersetzen (z. B. verzogenen Frame durch das Original)
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
const order = opt("--frames", "0,1,2,3,4,5").split(",").map(Number);
const repl = {};
for (const r of (opt("--replace", "") || "").split(",").filter(Boolean)) { const [a, b] = r.split("=").map(Number); repl[a] = b; }
fs.mkdirSync(path.join(root, "anim"), {recursive: true});
order.forEach((raw, i) => {
  const src = repl[raw] !== undefined ? repl[raw] : raw;
  const f = PNG.sync.read(fs.readFileSync(prefix + src + ".png"));
  if (f.width !== base.width || f.height !== base.height) throw new Error("Größe passt nicht: " + prefix + src);
  const out = new PNG({width: f.width, height: f.height});
  for (let j = 0; j < f.data.length; j += 4) {
    if (f.data[j + 3] < 128) continue;
    const c = nearest(f.data[j], f.data[j + 1], f.data[j + 2]);
    out.data[j] = c[0]; out.data[j + 1] = c[1]; out.data[j + 2] = c[2]; out.data[j + 3] = 255;
  }
  fs.writeFileSync(path.join(root, "anim", `${name}_idle_${i}.png`), PNG.sync.write(out));
});
console.log(`${name}: ${order.length} Frames, Palette ${pal.length} Farben`);
