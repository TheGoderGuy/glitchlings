// Aufruf: node dim_blink.js <png> "x0,y0,x1,y1;..." [--hi] [--f 0.65]  (Boxen: tools/sprites/blink_boxes.json, Einträge mit "dim"/"hi"/"f")
// Mech-Blinzeln: leuchtende Pixel in den Boxen abdunkeln -> <png>_blink.png
const {PNG} = require("pngjs");
const fs = require("fs"); const argv = process.argv.slice(2); const [file, boxes] = argv; const hi = argv.includes("--hi");
const fi = argv.indexOf("--f"); const factor = fi >= 0 ? parseFloat(argv[fi + 1]) : 0.3;   // --f: Helligkeit im Blinzel-Frame (0.3 = stark abgedunkelt)  // --hi: auch weiße Glanzpunkte abdunkeln
const img = PNG.sync.read(fs.readFileSync(file)); const N = img.width;
for (const b of boxes.split(";")) { const [x0, y0, x1, y1] = b.split(",").map(Number);
  for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) { const i = (y*N + x)*4; if (img.data[i+3] < 128) continue;
    const l = (img.data[i]*.3 + img.data[i+1]*.59 + img.data[i+2]*.11)/255; if (l < .3) continue; const d = img.data; if (Math.max(d[i], d[i+1], d[i+2]) - Math.min(d[i], d[i+1], d[i+2]) < 70 && !(hi && l > .75)) continue;
    for (let c = 0; c < 3; c++) img.data[i+c] = Math.round(img.data[i+c]*factor); } }
fs.writeFileSync(file.replace(/\.png$/i, "_blink.png"), PNG.sync.write(img));
