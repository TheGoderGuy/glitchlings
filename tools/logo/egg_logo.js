// Glitchlings-Bildmarke „Schlüpf-Ei“ (Ausarbeitung, 01.10.2026): 64×80 Pixel-Art, mehrere Varianten.
// Aufruf: node tools/logo/egg_logo.js  →  tools/logo/out/ei_<variante>.png (1×) und ei_varianten.png (Vergleich)
const fs = require("fs");
const path = require("path");
const { PNG } = require(path.join(__dirname, "..", "sprites", "node", "node_modules", "pngjs"));
const OUT = path.join(__dirname, "out");
fs.mkdirSync(OUT, { recursive: true });

const hex = (h, a = 255) => { h = h.replace("#", ""); return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16), a]; };
const mix = (a, b, k) => a.map((v, i) => Math.round(v + (b[i] - v) * Math.max(0, Math.min(1, k))));
class Img {
  constructor(w, h) { this.w = w; this.h = h; this.d = new Array(w * h).fill(null); }
  set(x, y, c) { x = Math.round(x); y = Math.round(y); if (x >= 0 && y >= 0 && x < this.w && y < this.h && c) this.d[y * this.w + x] = c; }
  blend(x, y, c, a) { const o = this.get(x, y); this.set(x, y, o ? mix(o, c, a).map((v, i) => (i === 3 ? 255 : v)) : [c[0], c[1], c[2], Math.round(255 * a)]); }
  get(x, y) { x = Math.round(x); y = Math.round(y); return x >= 0 && y >= 0 && x < this.w && y < this.h ? this.d[y * this.w + x] : null; }
  paste(o, ox, oy) { for (let y = 0; y < o.h; y++) for (let x = 0; x < o.w; x++) { const c = o.get(x, y); if (c) this.set(ox + x, oy + y, c); } }
  outline(col) {
    const add = [];
    for (let y = 0; y < this.h; y++) for (let x = 0; x < this.w; x++) {
      if (this.get(x, y) && this.get(x, y)[3] > 128) continue;
      const n = (dx, dy) => { const c = this.get(x + dx, y + dy); return c && c[3] > 128 && c !== col; };
      if (n(1, 0) || n(-1, 0) || n(0, 1) || n(0, -1)) add.push([x, y]);
    }
    for (const [x, y] of add) this.set(x, y, col);
  }
  save(file, scale = 1, bg = null) {
    const png = new PNG({ width: this.w * scale, height: this.h * scale });
    for (let y = 0; y < this.h * scale; y++) for (let x = 0; x < this.w * scale; x++) {
      let c = this.get(Math.floor(x / scale), Math.floor(y / scale));
      if (bg) c = c ? (c[3] < 255 ? mix(bg, c, c[3] / 255).map((v, i) => (i === 3 ? 255 : v)) : c) : bg;
      png.data.set(c || [0, 0, 0, 0], (y * this.w * scale + x) * 4);
    }
    fs.writeFileSync(file, PNG.sync.write(png));
  }
}

const DARK = hex("#140C2A");
const SHELL = [hex("#FFFBF0"), hex("#F6E7C8"), hex("#DCC49B"), hex("#B39A72")];   // hell → dunkel
const BAYER = [[0, 2], [3, 1]];
const ELEM = ["#FF8A4C", "#4CC3F0", "#6EE7C5", "#FFD84D", "#C77DFF"];

const W = 64, H = 82, CX = 31.5, CY = 52, RX = 21, RY = 28;
const inEgg = (x, y) => { const v = (y + 0.5 - CY) / RY; if (v < -1 || v > 1) return false; return Math.abs(x + 0.5 - CX) <= RX * Math.sqrt(1 - v * v) * (1 + 0.15 * v); };
// Zickzack-Riss: Zähne alle 6 px
const TEETH = [];
for (let i = 0, x = CX - RX - 2; x <= CX + RX + 6; i++, x += 6) TEETH.push([x, 40 + (i % 2 ? -3 : 2) + (i === 3 ? -1 : 0)]);
const crackY = (x) => { for (let i = 0; i < TEETH.length - 1; i++) { const [x0, y0] = TEETH[i], [x1, y1] = TEETH[i + 1]; if (x >= x0 && x <= x1) return y0 + (y1 - y0) * (x - x0) / (x1 - x0); } return 40; };

// Schalenfarbe mit Licht von oben links, geordnet gedithert
function shellCol(x, y) {
  const lx = (x + 0.5 - CX) / RX, ly = (y + 0.5 - CY) / RY;
  const l = 0.55 - 0.45 * lx - 0.55 * ly + 0.25 * (1 - lx * lx - ly * ly);   // 0 dunkel … 1 hell
  const k = (1 - Math.max(0, Math.min(1, l))) * 3;
  const band = Math.floor(k), f = k - band;
  // flache Bänder, Dithering nur im schmalen Übergang
  const dith = f > 0.78 && (BAYER[y & 1][x & 1] % 2 === 0);
  return SHELL[Math.min(3, band + (f > 0.92 || dith ? 1 : 0))];
}

function egg(v) {
  const img = new Img(W, H);
  const LID = { dx: 3, dy: -11 };
  // --- Lichtstrahlen aus dem Spalt (hinter allem) ---
  const drawRays = () => {
  if (v.rays) {
    for (let y = 8; y < 40; y++) for (let x = 0; x < W; x++) {
      const dx = x + 0.5 - CX, dy = 40 - y, dist = Math.hypot(dx, dy);
      const ang = Math.atan2(dx, dy);
      const beam = [-0.95, -0.45, 0.5, 1.0].some((a) => Math.abs(ang - a) < 0.07 + 0.002 * dist);
      // hell und deckend, nach außen per Raster auslaufend (keine Halbtransparenz: wirkt auf dunklem Grund sonst grau)
      if (beam && dist > 12 && dist < 30 && !img.get(x, y) && (dist < 21 || (x + y) % 2 === 0)) img.set(x, y, hex(dist < 17 ? "#FFF6C8" : (v.rayCol || "#FFD84D")));
    }
  }
  };
  // --- Unterschale ---
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) if (inEgg(x, y) && y >= crackY(x)) img.set(x, y, shellCol(x, y));
  // --- Öffnung: dunkles Inneres als Halbellipse über der Bruchkante, darin das Wesen ---
  const OPEN = { cx: CX, cy: 43, rx: RX - 4, ry: 11 };
  const inOpen = (x, y) => (((x + 0.5 - OPEN.cx) / OPEN.rx) ** 2 + ((y + 0.5 - OPEN.cy) / OPEN.ry) ** 2) <= 1 && y < 43 + (v.ears ? 0 : 0);
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) if (inOpen(x, y) && y < crackY(x) + 1) img.set(x, y, hex(v.body || "#1E1440"));
  const drawEars = () => {
  if (v.ears) {
    for (const [ex, dir] of [[CX - 13, 1], [CX + 7, -1]]) {
      for (let k = 0; k < 11; k++) for (let j = 0; j <= k * 0.7; j++) {
        const yy = 23 + k, xx = ex + (dir > 0 ? j : -j) + (dir > 0 ? 0 : 3);
        img.set(xx, yy, hex(v.body || "#1E1440"));
        if (k > 3 && j > 0 && j < k * 0.7 - 1) img.set(xx, yy, hex("#FF8FD8"));
      }
    }
  }
  };
  // Augen
  if (v.eyes) {
    for (const ex of [CX - 8, CX + 4]) {
      const ey = 36;
      for (let dy = -1; dy <= 5; dy++) for (let dx = -1; dx <= 4; dx++) img.blend(ex + dx, ey + dy, hex(v.eyeCol || "#6EE7C5"), 0.25);
      for (let dy = 0; dy < 5; dy++) for (let dx = 0; dx < 4; dx++) {
        if ((dy === 0 || dy === 4) && (dx === 0 || dx === 3)) continue;
        img.set(ex + dx, ey + dy, hex(dy < 2 ? (v.eyeHi || "#D2FFF0") : (v.eyeCol || "#6EE7C5")));
      }
      img.set(ex + 1, ey + 1, hex("#FFFFFF")); img.set(ex + 1, ey + 2, hex("#FFFFFF"));
    }
  }
  // helle Bruchkante der Unterschale
  for (let x = 0; x < W; x++) { const y = Math.ceil(crackY(x)); if (inEgg(x, y) && img.get(x, y) && !inOpen(x, y - 1)) img.set(x, y, SHELL[0]); }
  // Element-Flecken (rautenförmig) auf der Unterschale
  [[CX - 11, 55], [CX + 7, 51], [CX - 2, 63], [CX + 12, 64], [CX - 14, 67]].forEach(([x, y], i) => {
    const c = hex(ELEM[i]), d = mix(c, DARK, 0.35), l = mix(c, hex("#FFFFFF"), 0.45);
    img.set(x, y - 1, l); img.set(x - 1, y, c); img.set(x, y, c); img.set(x + 1, y, d); img.set(x, y + 1, d);
  });
  // --- Deckel: schwebt versetzt, in drei Glitch-Bändern ---
  const lid = new Img(W, H);
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) if (inEgg(x, y) && y < crackY(x)) lid.set(x, y, shellCol(x, y));
  for (let x = 0; x < W; x++) { const y = Math.floor(crackY(x)) - 1; if (lid.get(x, y)) lid.set(x, y, SHELL[3]); }   // Unterkante dunkler
  const band = (y) => (y < 27 ? 0 : y < 32 ? (v.glitch ? 3 : 0) : 1);
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) { const c = lid.get(x, y); if (c) img.set(x + LID.dx + band(y), y + LID.dy, c); }
  drawEars();
  img.outline(DARK);
  // Glitch-Farbsäume am Deckel und abgesprungene Pixel
  if (v.glitch) {
    for (let y = 0; y < 34; y++) {
      let l = -1, r = -1;
      for (let x = 0; x < W; x++) { const c = img.get(x, y); if (c && c !== DARK && y + 11 < 44) { if (l < 0) l = x; r = x; } }
      if (l < 0 || y % 4 === 3) continue;
      img.set(l - 1, y, hex("#4CC3F0")); img.set(r + 2, y, hex("#FF4FA0"));
    }
    [[CX + 20, 16, "#FF4FA0"], [CX + 23, 12, "#6EE7C5"], [CX - 22, 20, "#4CC3F0"], [CX + 18, 22, "#FFF6DE"]].forEach(([x, y, c]) => { img.set(x, y, hex(c)); img.set(x + 1, y, hex(c)); });
  }
  drawRays();
  // Funkeln (Plus-Sterne)
  for (const [x, y, c] of v.stars || []) { img.set(x, y, hex("#FFFFFF")); for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) img.set(x + dx, y + dy, hex(c)); }
  return img;
}

const VARIANTS = {
  augen: { eyes: true, glitch: true, stars: [[8, 30, "#6EE7C5"], [56, 40, "#FFD84D"]] },
  katze: { eyes: true, ears: true, glitch: true, stars: [[8, 30, "#FF8FD8"], [57, 42, "#6EE7C5"]] },
  licht: { eyes: true, rays: true, glitch: true, eyeCol: "#FFD84D", eyeHi: "#FFF6C8", stars: [[7, 34, "#FFD84D"], [57, 44, "#FFD84D"]] },
};
const imgs = {};
for (const [k, v] of Object.entries(VARIANTS)) { imgs[k] = egg(v); imgs[k].save(path.join(OUT, "ei_" + k + ".png")); }

// Vergleich: groß (×3) und darunter in Symbolgröße (×1)
const S = 3, BG = hex("#120E26");
const sheet = new Img(3 * (W + 8) + 8, H + 8 + 8 + H);
Object.values(imgs).forEach((im, i) => { sheet.paste(im, 8 + i * (W + 8), 4); });
// klein: 1:1 nebeneinander (wie ein Programmsymbol)
const small = new Img(sheet.w, H);
Object.values(imgs).forEach((im, i) => small.paste(im, 8 + i * (W + 8), 0));
const png = new PNG({ width: sheet.w * S, height: (H + 8) * S + H + 16 });
for (let y = 0; y < png.height; y++) for (let x = 0; x < png.width; x++) {
  let c = null;
  if (y < (H + 8) * S) c = sheet.get(Math.floor(x / S), Math.floor(y / S));
  else { const sy = y - (H + 8) * S - 8, sx = x - (png.width - small.w) / 2; c = small.get(Math.floor(sx), sy); }
  const out = c ? (c[3] < 255 ? mix(BG, c, c[3] / 255).map((v, i) => (i === 3 ? 255 : v)) : c) : BG;
  png.data.set(out, (y * png.width + x) * 4);
}
fs.writeFileSync(path.join(OUT, "ei_varianten.png"), PNG.sync.write(png));
console.log("ok");
