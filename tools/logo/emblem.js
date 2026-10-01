// Glitchlings-Bildmarke (Logo ohne Text): Entwürfe als Pixel-Art.
// Aufruf: node tools/logo/emblem.js  →  tools/logo/out/emblem_<name>.png und emblem_entwuerfe_x4.png
const fs = require("fs");
const path = require("path");
const { PNG } = require(path.join(__dirname, "..", "sprites", "node", "node_modules", "pngjs"));
const ROOT = path.join(__dirname, "..", "..");
const OUT = path.join(__dirname, "out");
fs.mkdirSync(OUT, { recursive: true });

function hex(h, a = 255) { h = h.replace("#", ""); return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16), a]; }
function lerp(a, b, k) { k = Math.max(0, Math.min(1, k)); return a.map((v, i) => Math.round(v + (b[i] - v) * k)); }
class Img {
  constructor(w, h) { this.w = w; this.h = h; this.d = new Array(w * h).fill(null); }
  set(x, y, c) { x = Math.round(x); y = Math.round(y); if (x >= 0 && y >= 0 && x < this.w && y < this.h && c) this.d[y * this.w + x] = c; }
  get(x, y) { return x >= 0 && y >= 0 && x < this.w && y < this.h ? this.d[y * this.w + x] : null; }
  outline(col) {
    const add = [];
    for (let y = 0; y < this.h; y++) for (let x = 0; x < this.w; x++) {
      if (this.get(x, y)) continue;
      if (this.get(x + 1, y) || this.get(x - 1, y) || this.get(x, y + 1) || this.get(x, y - 1)) add.push([x, y]);
    }
    for (const [x, y] of add) this.set(x, y, col);
  }
  paste(o, ox, oy) { for (let y = 0; y < o.h; y++) for (let x = 0; x < o.w; x++) { const c = o.get(x, y); if (c) this.set(ox + x, oy + y, c); } }
  save(file, scale = 1) {
    const png = new PNG({ width: this.w * scale, height: this.h * scale });
    for (let y = 0; y < this.h * scale; y++) for (let x = 0; x < this.w * scale; x++) {
      const c = this.get(Math.floor(x / scale), Math.floor(y / scale)) || [0, 0, 0, 0];
      const i = (y * this.w * scale + x) * 4;
      png.data.set(c, i);
    }
    fs.writeFileSync(file, PNG.sync.write(png));
  }
}
const sprite = (f) => { const p = PNG.sync.read(fs.readFileSync(path.join(ROOT, "game", "assets", "sprites", f))); const im = new Img(p.width, p.height);
  for (let y = 0; y < p.height; y++) for (let x = 0; x < p.width; x++) { const i = (y * p.width + x) * 4; if (p.data[i + 3] > 128) im.set(x, y, [p.data[i], p.data[i + 1], p.data[i + 2], 255]); } return im; };

// Ei-Form: oben schmaler als unten
function inEgg(x, y, cx, cy, rx, ry) {
  const v = (y - cy) / ry;
  if (v < -1 || v > 1) return false;
  const r = rx * Math.sqrt(1 - v * v) * (1 + 0.16 * v);
  return Math.abs(x - cx) <= r;
}
const ELEM = ["#FF8A4C", "#4CC3F0", "#6EE7C5", "#FFD84D", "#C77DFF"];
const DARK = hex("#140C2A");

// ---------- 1. Schlüpf-Ei: Riss mit Glitch-Versatz, zwei leuchtende Augen schauen heraus ----------
function eggHatch() {
  const W = 48, H = 52, cx = 23.5, cy = 29, rx = 15, ry = 21;
  const img = new Img(W, H);
  const crack = (x) => cy - 5 + [0, -2, 1, -1, 2, 0, -2, 1][Math.floor((x - (cx - rx)) / 4) & 7];   // Zickzack
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
    if (!inEgg(x, y + 0.5, cx, cy, rx, ry)) continue;
    const top = y < crack(x);
    // Schale: oben rechts, Licht von oben links
    const lx = (x - cx) / rx, ly = (y - cy) / ry;
    const light = -0.6 * lx - 0.8 * ly;
    let col = lerp(hex("#C9B48E"), hex("#FFF8E6"), 0.5 + light * 0.6);
    if (top) img.set(x + 2, y - 7, col);            // Deckel schwebt versetzt nach oben (Glitch)
    else img.set(x, y, col);
  }
  // Inneres im Spalt: dunkel mit zwei leuchtenden Augen
  for (let x = Math.ceil(cx - rx + 2); x < cx + rx - 1; x++) for (let y = crack(x) - 8; y < crack(x); y++) {
    if (inEgg(x, y + 0.5, cx, cy, rx, ry) && !img.get(x, y)) img.set(x, y, hex("#120A24"));
  }
  for (const ex of [cx - 7, cx + 3]) {
    for (let dy = 0; dy < 4; dy++) for (let dx = 0; dx < 3; dx++) img.set(ex + dx, cy - 11 + dy, hex(dy < 2 ? "#B8FFE9" : "#6EE7C5"));
    img.set(ex, cy - 11, hex("#FFFFFF"));
  }
  // Element-Flecken auf der Schale
  [[cx - 8, cy + 4], [cx + 6, cy + 2], [cx - 2, cy + 11], [cx + 9, cy + 12], [cx - 10, cy + 13]].forEach(([x, y], i) => {
    img.set(x, y, hex(ELEM[i])); img.set(x + 1, y, hex(ELEM[i])); img.set(x, y + 1, hex(ELEM[i])); img.set(x + 1, y + 1, lerp(hex(ELEM[i]), DARK, 0.3));
  });
  img.outline(DARK);
  // Glitch-Farbsäume am Deckel: links Cyan, rechts Magenta (je 1 Pixel)
  for (let y = 0; y < cy - 11; y++) {
    let l = -1, r = -1;
    for (let x = 0; x < W; x++) if (img.get(x, y)) { if (l < 0) l = x; r = x; }
    if (l >= 0 && y % 3 !== 1) { img.set(l - 1, y, hex("#4CC3F0")); img.set(r + 1, y, hex("#FF4FA0")); }
  }
  // Datenfunken
  [[cx - 14, cy - 18], [cx + 14, cy - 20], [cx + 17, cy - 10]].forEach(([x, y]) => { img.set(x, y, hex("#FFFFFF")); img.set(x + 1, y, hex("#6EE7C5")); });
  return img;
}

// ---------- 2. Abzeichen: Pixmiez im Kreis, Ring aus den fünf Elementfarben ----------
function badge() {
  const W = 48, H = 48, c = 23.5, R = 22;
  const img = new Img(W, H);
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
    const d = Math.hypot(x - c, y - c);
    if (d > R) continue;
    if (d > R - 4) {
      const a = (Math.atan2(y - c, x - c) + Math.PI * 1.5) % (Math.PI * 2);
      const seg = Math.floor(a / (Math.PI * 2) * 5);
      const gap = (a / (Math.PI * 2) * 5) % 1 < 0.06;
      img.set(x, y, gap ? DARK : lerp(hex(ELEM[seg]), DARK, d > R - 1.5 ? 0.35 : 0));
    } else {
      img.set(x, y, lerp(hex("#2A2152"), hex("#130E2A"), (y - c + R) / (2 * R)));
    }
  }
  // Raster-Linien im Inneren (digital)
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) if (Math.hypot(x - c, y - c) < R - 5 && (x % 6 === 0 || y % 6 === 0)) img.set(x, y, hex("#33295E"));
  const cat = sprite("pixi_32.png");
  const catImg = new Img(32, 32); catImg.paste(cat, 0, 0); catImg.outline(DARK);
  img.paste(catImg, 8, 9);
  img.outline(DARK);
  return img;
}

// ---------- 3. Monogramm: großes G als Ei, ein Pixelsplitter fliegt heraus ----------
function monogram() {
  const W = 48, H = 52, cx = 23.5, cy = 28, rx = 17, ry = 22;
  const img = new Img(W, H);
  // G-Öffnung: rechts oben ausgeschnitten, Querbalken nach innen
  const cut = (x, y) => {
    const inner = inEgg(x, y + 0.5, cx, cy, rx - 7, ry - 7);
    const mouth = x > cx + 3 && y > cy - 9 && y < cy - 1;
    const bar = x > cx - 2 && y >= cy - 1 && y < cy + 5;
    return (inner || mouth) && !bar;
  };
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
    if (!inEgg(x, y + 0.5, cx, cy, rx, ry) || cut(x, y)) continue;
    const k = (y - (cy - ry)) / (2 * ry);
    let col = k < 0.5 ? lerp(hex("#D2FFF0"), hex("#6EE7C5"), k * 2) : lerp(hex("#6EE7C5"), hex("#2E8FA8"), (k - 0.5) * 2);
    // Glitch: ein Band leicht verschoben
    if (y >= cy + 8 && y < cy + 11) { img.set(x + 2, y, col); continue; }
    img.set(x, y, col);
  }
  // Ein Splitter (Ecke der Öffnung) fliegt nach oben rechts davon
  for (let y = 0; y < 4; y++) for (let x = 0; x < 4; x++) img.set(cx + 13 + x, cy - 20 + y, y === 0 ? hex("#D2FFF0") : hex("#6EE7C5"));
  img.set(cx + 19, cy - 24, hex("#6EE7C5")); img.set(cx + 21, cy - 26, hex("#FFFFFF"));
  // kleine Augen im Inneren des G: ein Glitchling wohnt drin
  for (const ex of [cx - 6, cx - 1]) { for (let dy = 0; dy < 3; dy++) for (let dx = 0; dx < 2; dx++) img.set(ex + dx, cy - 5 + dy, hex(dy === 0 ? "#FFF3B0" : "#FFD84D")); }
  img.outline(DARK);
  return img;
}

const ems = { ei: eggHatch(), abzeichen: badge(), monogramm: monogram() };
for (const [k, im] of Object.entries(ems)) im.save(path.join(OUT, "emblem_" + k + ".png"));

// Vergleichsbild: groß (×4) und darunter klein (×1, wie ein Symbol in der Taskleiste)
const sheet = new Img(3 * 60 + 12, 76 + 40);
for (let y = 0; y < sheet.h; y++) for (let x = 0; x < sheet.w; x++) sheet.set(x, y, (x % 16 === 0 || y % 16 === 0) ? hex("#1C1838") : hex("#120E26"));
Object.values(ems).forEach((im, i) => {
  sheet.paste(im, 8 + i * 60 + Math.floor((48 - im.w) / 2), 8 + (56 - im.h));
});
const S = 4, big = sheet;
big.save(path.join(OUT, "emblem_entwuerfe_x4.png"), S);
console.log("ok");
