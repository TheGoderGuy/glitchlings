// Baut game/assets/logo/digiei.ico aus den Pixel-Fassungen des Digi-Eis (03.10.2026).
// Enthält 16, 32, 64, 128 und 256 px (256 = 128 ganzzahlig verdoppelt), jeweils als PNG-Eintrag.
// Aufruf: node tools/logo/make_ico.js
const fs = require("fs");
const path = require("path");
const { PNG } = require(path.join(__dirname, "..", "sprites", "node", "node_modules", "pngjs"));
const DIR = path.join(__dirname, "..", "..", "game", "assets", "logo");

function scale(png, k) {
  const o = new PNG({ width: png.width * k, height: png.height * k });
  for (let y = 0; y < o.height; y++)
    for (let x = 0; x < o.width; x++) {
      const i = (Math.floor(y / k) * png.width + Math.floor(x / k)) * 4, j = (y * o.width + x) * 4;
      png.data.copy(o.data, j, i, i + 4);
    }
  return o;
}

const read = (f) => PNG.sync.read(fs.readFileSync(path.join(DIR, f)));
const images = [read("digiei_16.png"), read("digiei_32.png"), read("digiei_64.png"), read("digiei_128.png"), scale(read("digiei_128.png"), 2)]
  .map((p) => ({ size: p.width, data: PNG.sync.write(p) }));

const head = Buffer.alloc(6 + 16 * images.length);
head.writeUInt16LE(0, 0);
head.writeUInt16LE(1, 2);            // Typ: Icon
head.writeUInt16LE(images.length, 4);
let offset = head.length;
images.forEach((im, n) => {
  const e = 6 + 16 * n;
  head.writeUInt8(im.size >= 256 ? 0 : im.size, e);      // 0 = 256
  head.writeUInt8(im.size >= 256 ? 0 : im.size, e + 1);
  head.writeUInt8(0, e + 2);
  head.writeUInt8(0, e + 3);
  head.writeUInt16LE(1, e + 4);       // Farbebenen
  head.writeUInt16LE(32, e + 6);      // Bit pro Pixel
  head.writeUInt32LE(im.data.length, e + 8);
  head.writeUInt32LE(offset, e + 12);
  offset += im.data.length;
});
fs.writeFileSync(path.join(DIR, "digiei.ico"), Buffer.concat([head, ...images.map((i) => i.data)]));
console.log("digiei.ico:", images.map((i) => i.size).join(", "), "px");
