// Sammelt alle anzeigbaren deutschen Texte aus den Skripten (Schlüssel für scripts/data/lang_en.gd).
// Aufruf: node game/tools/lang_keys.js [--missing]   (--missing: nur Texte ohne englische Übersetzung)
// Dieselbe Regel nutzt der Godot-Test „Englisch vollständig“ (test_battle.gd).
const fs = require("fs");
const path = require("path");
const root = path.join(__dirname, "..");
const SKIP_FILES = ["scripts/audio/music_synth.gd", "scripts/audio/sfx.gd", "scripts/audio/music.gd", "scripts/shot.gd",
  "scripts/main.gd", "scripts/input_setup.gd", "scripts/settings.gd", "scripts/i18n.gd", "scripts/data/lang_en.gd",
  "scripts/battle/battle_bot.gd", "scripts/meta/save_game.gd"];
// Zeilen ohne Anzeigetext (Logik, Ressourcen, Vergleiche)
const SKIP_LINE = /is_action|Sfx\.play|Music\.(play|seek|current)|preload\(|load\(|res:\/\/|user:\/\/|get_value|set_value|push_error|print\(|^\s*match |^\s*"[^"]*",?\s*$(?!)|(==|!=)\s*"|"\s*(==|!=)|\.has\("|\bin \[|\.begins_with\(|\.ends_with\(|draw_sprite\(|sprite\(|zone_texture\(|_imprint\(run, "|random_chip\("|\.append\("[A-ZÄÖÜ][a-zäöü]+[^ "]*"\)|\.erase\(|Color\("|PICTOS|ICONS\[/;

// In beiden Sprachen gleich (Tasten, Formatvorlagen, Eigennamen, Pixelmuster)
const SAME = new Set(["Start", "Esc", "Enter", "Back", "LB", "RB", "BOSS", "GLITCHLINGS", "TheGoderGuy", "Silkscreen", "Glutball+",
  ", +%d HP", " · %ss", "%s · %d HP", "%s · %s · %d HP", "buy_%d", ".xx.xx.", ".xxxxx.", "..xxx..", "application/config/version",
  "Language (Sprache): ", "Sprache (Language): ", "© 2026 TheGoderGuy"]);

function walk(dir, out) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, out);
    else if (e.name.endsWith(".gd")) out.push(p);
  }
  return out;
}

function keys() {
  const found = {};
  for (const abs of walk(path.join(root, "scripts"), [])) {
    const rel = path.relative(root, abs).split(path.sep).join("/");
    if (SKIP_FILES.includes(rel) || rel.startsWith("scripts/data/lang_en")) continue;
    const src = fs.readFileSync(abs, "utf8").split("\n");
    src.forEach((line, i) => {
      const t = line.trim();
      if (t.startsWith("#")) return;
      const re = /"((?:[^"\\]|\\.)*)"/g;
      let m;
      while ((m = re.exec(line))) {
        const s = m[1];
        const before = line.slice(0, m.index);
        const after = line.slice(m.index + m[0].length).trimStart();
        const wrapped = /(T\.t|T\.chip)\($/.test(before);
        if (/\.get\($/.test(before)) continue;                         // def.get("title", …)
        if (!wrapped) {
          if (SKIP_LINE.test(line)) continue;
          if (after.startsWith(":")) continue;                       // Dictionary-Schlüssel
          if (/^\s*(const|var) \w+ := \[$/.test(before)) {}          // Listen sind ok
        }
        if (!/[A-Za-zÄÖÜäöüß]{2}/.test(s)) continue;
        if (/\.(ttf|png|wav|gd|json|csv|cfg)$/.test(s)) continue;
        if (/^[a-z0-9_]+$/.test(s) && !wrapped && !/_text\(|_menu\(/.test(line)) continue;   // IDs
        if (/^#[0-9A-Fa-f]{6}/.test(s)) continue;
        if (/_\d+$/.test(s)) continue;                             // Sprite-Dateien
        if (SAME.has(s)) continue;
        (found[s] = found[s] || []).push(rel + ":" + (i + 1));
      }
    });
  }
  return found;
}

if (require.main === module) {
  const all = keys();
  let list = Object.keys(all);
  if (process.argv.includes("--missing")) {
    const have = new Set();
    for (const f of fs.readdirSync(path.join(root, "scripts/data")).filter((n) => /^lang_en.*\.gd$/.test(n))) {
      const en = fs.readFileSync(path.join(root, "scripts/data", f), "utf8");
      const re = /"((?:[^"\\]|\\.)*)":\s/g;
      let m;
      while ((m = re.exec(en))) have.add(m[1]);
    }
    list = list.filter((k) => !have.has(k));
  }
  if (process.argv.includes("--json")) console.log(JSON.stringify(list.map((k) => [k, all[k][0]]), null, 0));
  else for (const k of list) console.log(JSON.stringify(k) + "  // " + all[k][0]);
  console.error(list.length + " Texte");
}
module.exports = keys;
