// Farben aufräumen: jedes Sprite höchstens 32 Farben – Grundbild, Blinzel-Bild und Idle-Frames teilen eine Palette.
// Aufruf: node fix_colors.js [--dry]
//   1. Grundbilder mit mehr als 32 Farben per reduce32.js (k-means) reduzieren.
//   2. Blinzel-Bild und Idle-Frames mit derselben Zuordnung alte → neue Farbe umfärben;
//      Farben, die nur dort vorkommen (abgedunkelte Augen, Lidstrich), auf die nächste Palettenfarbe ziehen.
//   3. Geänderte Dateien auch nach assets/sprites/ (Ablage neben dem Spiel) kopieren, falls dort vorhanden.
const {PNG} = require("pngjs"), fs = require("fs"), path = require("path"), {execFileSync} = require("child_process");
const G = path.resolve(__dirname, "../../../game/assets/sprites"), A = path.resolve(__dirname, "../../../assets/sprites");
const dry = process.argv.includes("--dry");
const read = f => PNG.sync.read(fs.readFileSync(f));
const key = (d, i) => (d[i] << 16) | (d[i + 1] << 8) | d[i + 2];
const colors = img => { const s = new Set(); for (let i = 0; i < img.data.length; i += 4) if (img.data[i + 3] > 0) s.add(key(img.data, i)); return s; };
const lum = (r, g, b) => [r, g, b];
let changed = 0, report = [];
for (const f of fs.readdirSync(G)) {
  if (!f.endsWith(".png") || f.includes("_blink")) continue;
  const name = f.slice(0, -4);
  const basePath = path.join(G, f), blinkPath = path.join(G, name + "_blink.png");
  const anims = fs.existsSync(path.join(G, "anim")) ? fs.readdirSync(path.join(G, "anim")).filter(a => a.startsWith(name + "_idle_") && a.endsWith(".png")).map(a => path.join(G, "anim", a)) : [];
  const old = read(basePath);
  const nOld = colors(old).size;
  const related = [fs.existsSync(blinkPath) ? blinkPath : null, ...anims].filter(Boolean);
  const tooMany = nOld > 32 || related.some(r => { const all = colors(read(r)); for (const c of colors(old)) all.add(c); return all.size > 32; });
  if (!tooMany) continue;
  // 1. Grundbild reduzieren (nur wenn nötig)
  const map = new Map();
  let base = old;
  if (nOld > 32) {
    const tmp = path.join(require("os").tmpdir(), "fixc_" + f);
    execFileSync("node", [path.join(__dirname, "reduce32.js"), basePath, tmp]);
    base = read(tmp);
    fs.unlinkSync(tmp);
  }
  for (let i = 0; i < old.data.length; i += 4) if (old.data[i + 3] > 0) map.set(key(old.data, i), key(base.data, i));
  const pal = [...colors(base)].map(c => [c >> 16 & 255, c >> 8 & 255, c & 255]);
  const nearest = (r, g, b) => { let best = pal[0], bd = 1e9; for (const p of pal) { const d = (p[0] - r) ** 2 * 0.3 + (p[1] - g) ** 2 * 0.59 + (p[2] - b) ** 2 * 0.11; if (d < bd) { bd = d; best = p; } } return best; };
  const recolor = file => {
    const img = read(file); const d = img.data;
    for (let i = 0; i < d.length; i += 4) {
      if (d[i + 3] === 0) continue;
      const k = key(d, i);
      let c;
      if (map.has(k)) { const m = map.get(k); c = [m >> 16 & 255, m >> 8 & 255, m & 255]; } else c = nearest(d[i], d[i + 1], d[i + 2]);
      d[i] = c[0]; d[i + 1] = c[1]; d[i + 2] = c[2]; d[i + 3] = 255;
    }
    return img;
  };
  const out = [[basePath, base], ...related.map(r => [r, recolor(r)])];
  const worst = Math.max(...out.map(([, img]) => colors(img).size));
  report.push(`${name}: ${nOld} → ${colors(base).size} Farben` + (related.length ? `, ${related.length} Begleitbilder, max. ${worst}` : ""));
  if (dry) continue;
  for (const [file, img] of out) {
    const buf = PNG.sync.write(img);
    fs.writeFileSync(file, buf);
    const rootCopy = path.join(A, path.relative(G, file));
    if (fs.existsSync(rootCopy)) fs.writeFileSync(rootCopy, buf);
  }
  changed++;
}
console.log(report.join("\n"));
console.log(dry ? `(Probelauf) ${report.length} Sprites betroffen` : `${changed} Sprites aufgeräumt`);
