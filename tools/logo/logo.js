// Glitchlings-Logo: eigene Pixel-Schrift (12 px hoch) in mehreren Stilen.
// Aufruf: node tools/logo/logo.js  →  tools/logo/out/logo_<stil>.png (1×) und Vergleichsbild entwuerfe_x4.png
const fs = require("fs");
const path = require("path");
const { PNG } = require(path.join(__dirname, "..", "sprites", "node", "node_modules", "pngjs"));
const ROOT = path.join(__dirname, "..", "..");
const OUT = path.join(__dirname, "out");
fs.mkdirSync(OUT, { recursive: true });

// ---------- Buchstaben (12 Zeilen, Strichstärke 3) ----------
const GLYPHS = {
  G: ["..######..", ".########.", "####..####", "###....###", "###.......", "###.......", "###..#####", "###..#####", "###....###", "####..####", ".#########", "..#######."],
  L: ["###.....", "###.....", "###.....", "###.....", "###.....", "###.....", "###.....", "###.....", "###.....", "###.....", "########", "########"],
  // i mit abgesetztem „Punkt“ (Zeilen 0–2), der eigens eingefärbt wird
  I: ["ddd", "ddd", "ddd", "...", "###", "###", "###", "###", "###", "###", "###", "###"],
  T: ["#########", "#########", "#########", "...###...", "...###...", "...###...", "...###...", "...###...", "...###...", "...###...", "...###...", "...###..."],
  C: ["..#######.", ".#########", "####...###", "###.......", "###.......", "###.......", "###.......", "###.......", "###.......", "####...###", ".#########", "..#######."],
  H: ["###....###", "###....###", "###....###", "###....###", "###....###", "##########", "##########", "###....###", "###....###", "###....###", "###....###", "###....###"],
  N: ["####...###", "#####..###", "######.###", "###.##.###", "###.######", "###..#####", "###...####", "###....###", "###....###", "###....###", "###....###", "###....###"],
  S: ["..#######.", ".#########", "###....###", "###.......", "####......", ".#######..", "..#######.", "......####", ".......###", "###....###", "#########.", ".#######.."],
};
const WORD = "GLITCHLINGS";
const GAP = 2;

function hex(h, a = 255) { h = h.replace("#", ""); return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16), a]; }
function lerp(a, b, k) { return a.map((v, i) => Math.round(v + (b[i] - v) * k)); }

class Img {
  constructor(w, h) { this.w = w; this.h = h; this.d = new Array(w * h).fill(null); }
  set(x, y, c) { if (x >= 0 && y >= 0 && x < this.w && y < this.h && c) this.d[y * this.w + x] = c; }
  get(x, y) { return x >= 0 && y >= 0 && x < this.w && y < this.h ? this.d[y * this.w + x] : null; }
  save(file, scale = 1, bg = null) {
    const png = new PNG({ width: this.w * scale, height: this.h * scale });
    for (let y = 0; y < this.h * scale; y++) for (let x = 0; x < this.w * scale; x++) {
      const c = this.get(Math.floor(x / scale), Math.floor(y / scale)) || bg || [0, 0, 0, 0];
      const i = (y * this.w * scale + x) * 4;
      png.data[i] = c[0]; png.data[i + 1] = c[1]; png.data[i + 2] = c[2]; png.data[i + 3] = c[3];
    }
    fs.writeFileSync(file, PNG.sync.write(png));
  }
}

function loadPng(file) { return PNG.sync.read(fs.readFileSync(file)); }

// Wort-Maske: m[y][x] = {ch, kind ('#' Strich, 'd' i-Punkt), li (Buchstabenindex), gy (Zeile im Buchstaben)}
function wordMask() {
  let w = 0;
  for (const ch of WORD) w += GLYPHS[ch][0].length + GAP;
  w -= GAP;
  const m = Array.from({ length: 12 }, () => new Array(w).fill(null));
  let x0 = 0;
  [...WORD].forEach((ch, li) => {
    const g = GLYPHS[ch];
    g.forEach((row, y) => [...row].forEach((c, x) => { if (c !== ".") m[y][x0 + x] = { kind: c, li, gy: y, gx: x, gw: row.length }; }));
    x0 += g[0].length + GAP;
  });
  return { m, w, h: 12 };
}

// Umriss: alle Pixel im Abstand r um die Maske
function ring(img, isSet, r, col) {
  const add = [];
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) {
    if (isSet(x, y)) continue;
    let near = false;
    for (let dy = -r; dy <= r && !near; dy++) for (let dx = -r; dx <= r && !near; dx++) {
      if (Math.abs(dx) + Math.abs(dy) <= r + (r > 1 ? 1 : 0) && isSet(x + dx, y + dy)) near = true;
    }
    if (near) add.push([x, y]);
  }
  for (const [x, y] of add) img.set(x, y, col);
}

// ---------- Stil A: Glitch-Klassik (Mint/Cyan, Farbversatz, verschobene Zeilen) ----------
function styleA() {
  const { m, w, h } = wordMask();
  const P = 6, img = new Img(w + P * 2, h + P * 2);
  const slice = (y) => (y === 4 || y === 5 ? 2 : y === 9 ? -1 : 0);   // Glitch: Zeilen verschoben
  const at = (x, y) => { const gy = y - P; if (gy < 0 || gy >= h) return null; const gx = x - P - slice(gy); return gx >= 0 && gx < w ? m[gy][gx] : null; };
  // Schatten (Magenta) und Cyan-Versatz
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) {
    if (at(x - 2, y - 2)) img.set(x, y, hex("#FF4FA0"));
  }
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) if (at(x + 1, y) && !at(x, y)) img.set(x, y, hex("#4CC3F0"));
  ring(img, (x, y) => !!at(x, y), 1, hex("#140C2A"));
  const top = hex("#E8FFF8"), mid = hex("#6EE7C5"), bot = hex("#2E9FB4");
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) {
    const c = at(x, y);
    if (!c) continue;
    if (c.kind === "d") { img.set(x, y, c.gy === 0 ? hex("#FFB3C1") : hex("#FF5470")); continue; }
    const k = c.gy / 11;
    let col = k < 0.5 ? lerp(top, mid, k * 2) : lerp(mid, bot, (k - 0.5) * 2);
    if (c.gy === 0 || !at(x, y - 1)) col = hex("#F4FFFB");          // Glanzkante oben
    img.set(x, y, col);
  }
  return img;
}

// ---------- Stil B: Ei & Katze (warm, Eier als i-Punkte, Pixmiez lugt hervor) ----------
function styleB() {
  const { m, w, h } = wordMask();
  const P = 6, TOPX = 22, img = new Img(w + P * 2, h + P * 2 + TOPX);
  const oy = P + TOPX;
  // Pixmiez hinter dem „H“ (Buchstabe 5) – nur der Kopf schaut über die Buchstaben
  const cat = loadPng(path.join(ROOT, "game", "assets", "sprites", "pixi_32.png"));
  let hx = 0; for (let i = 0; i < 5; i++) hx += GLYPHS[WORD[i]][0].length + GAP;
  const cx = P + hx + 5 - 16, cy = oy - 22;
  for (let y = 0; y < 32; y++) for (let x = 0; x < 32; x++) {
    const i = (y * 32 + x) * 4;
    if (cat.data[i + 3] > 128 && cy + y < oy + 3) img.set(cx + x, cy + y, [cat.data[i], cat.data[i + 1], cat.data[i + 2], 255]);
  }
  const at = (x, y) => { const gy = y - oy, gx = x - P; return gy >= 0 && gy < h && gx >= 0 && gx < w ? m[gy][gx] : null; };
  const solid = (x, y) => { const c = at(x, y); return c && c.kind === "#"; };
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) if (solid(x - 1, y - 2) || solid(x, y - 2)) img.set(x, y, hex("#120A24"));
  ring(img, solid, 2, hex("#2A1640"));
  ring(img, solid, 1, hex("#5B2E7A"));
  const top = hex("#FFF6C8"), mid = hex("#FFD84D"), bot = hex("#FF9A3D");
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) {
    const c = at(x, y);
    if (!c || c.kind !== "#") continue;
    const k = c.gy / 11;
    let col = k < 0.45 ? lerp(top, mid, k / 0.45) : lerp(mid, bot, (k - 0.45) / 0.55);
    if (!solid(x, y - 1)) col = hex("#FFFBEA");
    img.set(x, y, col);
  }
  // i-Punkte als kleine Eier (5×6)
  const EGG = [".###.", "#####", "##o##", "#####", "#o###", ".###."];
  for (let li = 0; li < WORD.length; li++) {
    if (WORD[li] !== "I") continue;
    let x0 = 0; for (let i = 0; i < li; i++) x0 += GLYPHS[WORD[i]][0].length + GAP;
    const ex = P + x0 - 1, ey = oy - 4;
    // dunkler Rand ums Ei
    for (let y = -1; y <= EGG.length; y++) for (let x = -1; x <= 5; x++) {
      const inside = (yy, xx) => yy >= 0 && yy < EGG.length && xx >= 0 && xx < 5 && EGG[yy][xx] !== ".";
      if (!inside(y, x) && (inside(y - 1, x) || inside(y + 1, x) || inside(y, x - 1) || inside(y, x + 1))) img.set(ex + x, ey + y, hex("#2A1640"));
    }
    EGG.forEach((row, y) => [...row].forEach((ch, x) => {
      if (ch === "#") img.set(ex + x, ey + y, y < 2 ? hex("#FFFDF4") : hex("#FFF0CC"));
      if (ch === "o") img.set(ex + x, ey + y, hex("#7BD35A"));
    }));
  }
  return img;
}

// ---------- Stil C: Element-Regenbogen (jeder Buchstabe ein Element, hüpfend, Funken) ----------
function styleC() {
  const { m, w, h } = wordMask();
  const P = 7, img = new Img(w + P * 2, h + P * 2 + 2);
  const EL = [["#FF8A4C", "#FFC9A6", "#C4501E"], ["#4CC3F0", "#B8ECFF", "#1E7DB0"], ["#6EE7C5", "#D2FFF0", "#2E9F86"],
    ["#FFD84D", "#FFF3B0", "#C79A12"], ["#C77DFF", "#EBCBFF", "#7B3FB8"]];
  const bounce = (li) => (li % 2 === 0 ? 0 : 2);
  const at = (x, y) => {
    const gx = x - P;
    if (gx < 0 || gx >= w) return null;
    for (const dy of [0, 2]) { const c = m[y - P - dy] && m[y - P - dy][gx]; if (c && bounce(c.li) === dy) return c; }
    return null;
  };
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) if (at(x - 1, y - 2)) img.set(x, y, hex("#0B0718"));
  ring(img, (x, y) => !!at(x, y), 1, hex("#1A1030"));
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) {
    const c = at(x, y);
    if (!c) continue;
    const e = EL[c.li % EL.length];
    let col = c.gy < 5 ? hex(e[0]) : lerp(hex(e[0]), hex(e[2]), (c.gy - 5) / 8);
    if (!at(x, y - 1)) col = hex(e[1]);
    if (c.kind === "d") col = c.gy === 0 ? hex("#FFFFFF") : hex(e[0]);
    img.set(x, y, col);
  }
  // Funken
  const sp = [[3, 4], [img.w - 5, 6], [20, 1], [img.w - 30, img.h - 3], [60, img.h - 2], [img.w / 2, 0]];
  for (const [x, y] of sp) { img.set(Math.round(x), y, hex("#FFFFFF")); img.set(Math.round(x) + 1, y, hex("#FFD84D", 180)); }
  return img;
}

const styles = { a_glitch: styleA(), b_ei_katze: styleB(), c_elemente: styleC() };
for (const [k, img] of Object.entries(styles)) img.save(path.join(OUT, "logo_" + k + ".png"), 1);

// Vergleichsbild: alle drei auf dunklem Grund, ×4
const S = 4, BG = hex("#120E26");
const maxW = Math.max(...Object.values(styles).map((i) => i.w));
const sheet = new Img(maxW + 20, Object.values(styles).reduce((a, i) => a + i.h + 12, 8));
for (let y = 0; y < sheet.h; y++) for (let x = 0; x < sheet.w; x++) sheet.set(x, y, (x % 16 === 0 || y % 16 === 0) ? hex("#1C1838") : BG);
let yy = 8;
for (const img of Object.values(styles)) {
  const xo = Math.floor((sheet.w - img.w) / 2);
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) { const c = img.get(x, y); if (c) sheet.set(xo + x, yy + y, c); }
  yy += img.h + 12;
}
sheet.save(path.join(OUT, "entwuerfe_x4.png"), S);
console.log("ok", Object.entries(styles).map(([k, i]) => k + " " + i.w + "x" + i.h).join(", "));
