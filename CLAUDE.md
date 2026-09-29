# Glitchlings – Projektgedächtnis für Claude Code

Du bist Game Designer, Director und Pixel-Art-Director für **Glitchlings**, ein Mobile-Monster-Sammelspiel.
Der Nutzer ist der Produzent. Er spricht Deutsch – antworte immer auf Deutsch.

## Das Spiel in einem Satz
**Premium-PC-Spiel für Steam** (Neuausrichtung 28.09.2026, vorher Mobile-F2P): Monster-Sammelspiel, in dem man kleine digitale Kreaturen ausbrütet, fusioniert und in kurzen Roguelite-Kämpfen
(Megaman-Battle-Network-Raster, Yu-Gi-Oh-artige Chips) trainiert. **Die Spielweise bestimmt die Evolution.**

## Projektstruktur
| Pfad | Inhalt |
|---|---|
| `game/` | **Godot-4-Projekt (Steam-Version)**, siehe `game/README.md`. Tests: `godot --headless --path game res://tests/test_battle.tscn` (als Szene, damit Autoloads da sind) |
| `prototype/index.html` | Spielbarer Browser-Prototyp (eine Datei: HTML, CSS, JS, Sprite-Daten). Im Browser öffnen oder `node tools/devserver.js` → http://localhost:8123 |
| `vault/` | Obsidian-Vault mit dem kompletten Game Design (Start: `vault/00 Übersicht/🏠 Start hier.md`) |
| `docs/Glitchlings_Konzept_Komplett.md` | Gesamtkonzept als ein Dokument |
| `tools/sprites/` | Python-Werkzeug, mit dem alle Sprites prozedural gezeichnet wurden |
| `assets/sprites/` | Alle Sprites als PNG (Originalgröße, x4/x8 vergrößert, Blinzel-Frames) |
| `tests/` | Automatische Tests mit jsdom (`cd tests && npm install && npm test`) |

## Aktueller Stand
- **Kampf:** 3×3-Raster pro Seite, Echtzeit, 15 Chips (Godot: 27), 3 Gegner + Boss (Pop-Up-Tyrann), Run = 3 Kämpfe + Boss, nach jedem Kampf 1-aus-3-Chipwahl.
  Steuerung: Wischen / Feld antippen (Direktsprung), WASD + J/K/L, ladende Chips vormerken, Leertaste = Signatur-Attacke. Deck-Ansicht pausiert, „Als Nächstes“ zeigt den nächsten Chip.
- **Station (Meta):** Team (mit ♥-Bindung und Pflege-Ansicht), Brutnest (Echtzeit-Eier, simulierte Werbung halbiert Restzeit 1×/Ei), Expeditionen (5 Element-Zonen, Echtzeit), Labor (versteckte Fusionsrezepte, Fehlversuche kostenlos + Gerücht), Monsterdex. Speicherstand in localStorage (`glitchlings-proto-v1`).
- **Monster:** 45 im Monsterdex. Spielbare Babys: Pixmiez (Katze), Funkling (Welpe), Tröpfel (Axolotl), Kekso (Hamster), Lumi (Hase), Quakli (Frosch), Molchi (Salamander), Brummbit (Bär, Tank), Kauzbit (Robo-Eule) + 4 Fusionen.
- **Evolution:** Prägung = Element der gespielten Chips. Stufen im Prototyp: Rookie 100, Champion 250, Ultra 500 Prägung, +10 HP je Stufe.
  Nur die **Feuer-Linie (Katze)** hat alle 4 Stufen: Pixmiez → Blazebit → Glutluchs → Pyrolynx (Tabelle `UP` im Code).
  **Funkling- & Tröpfel-Linie** (27.09.2026, PixelLab): Babys Funkling (Welpe) + Tröpfel (Axolotl) 32 px, Rookies Glutbyte, Overclocko, Kaskadi, Pufferling 64 px, Champions Magmawulf (← Glutbyte) und Tsunamander (← Kaskadi) 80 px. Übrige Champions + alle Ultras fehlen noch.
  **Hamster/Hase/Frosch-Redesign** (27.09.2026): Kekso → Tracko/Cachy, Lumi → Blinki/Screenshina, Quakli (früher Spamlet) → Virulurch/Hüpfbyte als Tiere (Baby 32, Rookie 64). Gegner „Spamlet“ bleibt Pop-up-Fenster (`spam`).
  Testknopf „Evolution beschleunigen“ hat je Entwicklungsrichtung einen eigenen Knopf.
  Testfunktionen im Team-Tab („Prototyp-Test“): „Evolution beschleunigen“ (je Richtung ein Knopf) und „Alle Monster freischalten“ (alle 29 Formen einmal ins Team, Dex komplett).

## Getroffene Entscheidungen (nicht ohne Rückfrage ändern)
1. **Art Direction „Tier + digitales Merkmal“** – echte Tier-Monster im Digimon-/Yu-Gi-Oh-Stil. Das Digitale zeigt sich NUR als Körpermerkmal (Leuchtlinien, Muster, Energie, Element-Effekte), **keine Gegenstands-/Kostüm-Konzepte** (keine Pop-up-Fenster, Trojaner-Holzpferde, Detektivmützen, Embleme o. Ä.; Entscheidung 27.09.2026). Rüstung ab Champion/Ultra ist ok, wenn sie organisch/kreaturhaft wirkt. **Maschinen-Tiere sind erlaubt** (Robo-Eule-Linie, Mecha-Bär, später Mecha-Champions der Code-Richtungen) – Tierform bleibt immer erkennbar; Gegenstände als Körper (Fenster, Holzpferd) bleiben verboten. Spieler-Monster basieren auf Tieren (Fuchs, Welpe/Wolf, Axolotl, Hamster, Hase, Frosch). Gegner bleiben bewusst Gegenstände/Insekten (korrumpierte Daten).
2. **Stil wächst mit der Stufe:** Baby & Rookie niedlich, Champion Übergang, Ultra cool (Rüstung, Leuchtlinien, mehrere Schweife).
3. **Größenstaffel nach Digimon-UP-Niveau:** Baby 32×32, Rookie 64×64, Champion 80×80, Ultra 96×96.
   Referenz: Digimon UP (Bandai Namco, 2026) – Rookie-Sprites aus Screenshot gemessen ca. 60–80 px hoch (≈ 64er-Leinwand).
4. **Sprite-Regeln:** Licht von oben links, Kontur fast schwarz (seit 27.09.2026), max. 32 Farben pro Sprite, Dithering nur an Übergängen,
   nur ganzzahlig skalieren, im Kampf ab Rookie ca. 1 CSS-Pixel pro Kunstpixel, Füße stehen auf der Plattform.
5. **Premium statt F2P (28.09.2026):** Einmalkauf auf Steam (Richtpreis 15–20 €), **keine Werbung, kein Battle Pass,
   keine Ei-Ziehungen, keine Echtzeit-Timer** (Brüten/Expeditionen an Spielfortschritt koppeln). Motivation durch
   „Nur-noch-ein-Run“-Neugier (Evolution, geheime Fusionen), nicht durch Zwangsschleifen. Die Mobile-Notizen in
   `vault/04 Monetarisierung/` und `vault/03 Psychologie/` sind überholt (Archiv). Details: `vault/05 Produktion/Steam-Neuausrichtung.md`.
6. **Plattform & Technik:** zuerst nur **Steam (Windows, Steam-Deck-tauglich)**, Switch vorerst gestrichen.
   Engine **Godot 4** (GDScript). Controller-first, Basisauflösung 640×360, nur ganzzahlig skalieren.
   Der Browser-Prototyp bleibt Spezifikation und Balancing-Referenz.
7. **Zielgruppe** möglichst breit (inkl. Kinder), **Team:** der Produzent + Claude, ohne Zeitdruck.

## Offene nächste Schritte
**Steam/Godot (Plan: `vault/05 Produktion/Roadmap.md`), Struktur: Station als Hub + Runs durch 5 Element-Zonen**
- [x] Godot 4.7 installiert (winget), Repo https://github.com/TheGoderGuy/glitchlings
- [x] Phase 1a (28.09.2026): Kampf-Kern portiert – Pixmiez, 15 Chips, 3 Gegner + Boss, Chipwahl, Pause/Deck, Ergebnis, Controller, 23 Tests
- [x] Phase 1b (28.09.2026): Pixel-Schrift Silkscreen (OFL), synthetisierte Platzhalter-Sounds (`Sfx.play`), Titelbildschirm, Optionen (Vollbild, Lautstärke, Bildschirmwackeln), Pause-Menü, 26 Tests
- [ ] Phase 1c: Angriffs-/Idle-Animationen, Musik, Balancing nach erstem Anspielen – besser als der Browser-Prototyp?
- [x] Phase 2a (28.09.2026): Zonenkarte Cache-Wiesen (7 Etagen + Boss; Kampf, Elite, Ereignis, Rast, Händler), Ergebnisbildschirm, 42 Tests – `vault/05 Produktion/Zonenkarte.md`
- [x] Phase 2b (28.09.2026): Starterwahl (Pixmiez/Funkling/Tröpfel), Evolution im Run (15/35 Prägung, 18 Formen, 18 Signaturen), Evolutions-Szene, 55 Tests – `vault/05 Produktion/Evolution im Run.md`
- [x] Phase 2c-1 (28.09.2026): 12 neue Chips (jetzt 27, je Element 4–5), 4 neue Ereignisse (jetzt 8), 76 Tests
- [x] Phase 2c-2 (28.09.2026): 3 neue Gegner (Captchakäfer, Spamwespe, Ladebalkenraupe) mit Kreuz-/Wand-Mustern, Gegner-Pools je Etage, 80 Tests
- [x] Phase 2d (28.09.2026): 4 Chiptune-Platzhalterstücke (Titel/Karte/Kampf/Boss, selbst synthetisiert), Zonen-Hintergrund Cache-Wiesen, Schwierigkeit Entspannt/Normal/Knackig, Musik-Lautstärke, Blinzel-Frames, 84 Tests
- [x] Musik 29.09.: Titel/Karte/Boss im GBA/DS-Stil neu (Bossmusik „mega“), alte Kampfmusik bleibt („episch“), Siegesfanfare, Karte läuft nach Kämpfen weiter
- [x] Phase 3a (29.09.2026): Spielstand, Station (Team/Brutnest/Monsterdex), dauerhafte Evolution (Rookie 15, Champion 60), Eier nach Runs, Schlüpf-Szene, 99 Tests – `vault/05 Produktion/Station.md`
- [x] Phase 3b (29.09.2026): 6 weitere Linien (Kekso, Lumi, Quakli, Molchi, Brummbit, Kauzbit) als Ei-Inhalt – 9 Linien, 40 Formen, 6 neue Passive, Monsterdex blättert, 109 Tests
- [ ] Als Nächstes: Labor/Fusion · Champions+Ultras für Linien ohne Endstufe · Zone 2 · Phase 4: Steam-Seite + Demo

**Aus der Mobile-Phase (weiterhin gültig für Inhalte)**
- [x] PixelLab-MCP anbinden (Abo Tier 1 seit 27.09.2026: 2.000 Generierungen/Monat, Reset am 27.; Pro-Flash-Bild kostet 5, egal welche Größe)
- [x] Welpe (Funkling) + Axolotl (Tröpfel) bis Rookie in neuer Staffel
- [ ] Champions für Overclocko + Pufferling, Ultras (96) für alle neuen Linien, jeweils `UP`-Tabelle + `DEX` erweitern
- [ ] Übrige Sprites (Babys, Gegner, Fusionen) auf schwarze Kontur umstellen (`tools/sprites/node/dark_outline.js`)
- [x] Boss (96) und Gegner (64) neu im Monster-Stil, große Gegner in fester Pixelgröße
- [x] Hamster, Hase, Frosch: Baby + Rookies neu gestaltet
- [x] Pixmiez (Katze) + Firewallo, Virulina, Prismiez neu
- [x] Feuer-Linie als Katze neu: Blazebit → Glutluchs → Pyrolynx
- [x] Frostbyte + 4 Fusionen als Tier-Chimären
- [x] Evolutions-Decks (`EVO_DECK`, Übersicht: `vault/05 Produktion/Evolutions-Decks.md`)
- [x] Signatur-Fähigkeiten für alle 6 Linien (6 Passive, 25 Signatur-Attacken, `vault/05 Produktion/Signatur-Fähigkeiten.md`)
- [x] Fusionen umbenannt: Glyphel (ex Quellcoda), Spukatz (ex 404-Geist); Pixi → Pixmiez, Quappel → Quakli (Pokémon-Kollision!)
- [x] Neue Linien Molchi, Brummbit, Kauzbit (Baby + Rookies, Passive, Signaturen)
- [ ] Signatur-Fähigkeiten der 4 Fusionen
- [x] 7 Mecha-Champions der Code-Richtungen (Bollwerkatz, Turbowulf, Panzerpuff, Mechaquak, Holohas, Titanbrumm, Radarkauz)
- [ ] Champions für die übrigen Nicht-Code-Rookies + Ultras
- [x] Station-Leben: Bindung/Pflege + Expeditionen (`vault/05 Produktion/Station-Leben.md`)
- [ ] Champions/Ultras der übrigen Linien
- [ ] Angriffsanimationen / Idle-Animationen
- [ ] Prototyp mit 5–10 externen Testern spielen lassen, Ergebnisse ins Playtest-Log (`vault/05 Produktion/Prototyp-Spezifikation.md`)

## Arbeitsweise mit PixelLab (sobald verbunden)
- Beschreibungen auf Englisch an PixelLab, immer „entire creature fits inside the canvas, nothing cut off“ dazuschreiben, Größe passend zur Stufe, transparenter Hintergrund, Blick nach rechts (Spieler steht links).
- Unsere bestehenden Sprites (`assets/sprites/`, z. B. `Blazebit_64_x4.png`, `Pyrolynx_96_x4.png`) als **Stilreferenz** nutzen – bei PixelLab am besten per `style_image.source_image_id` (PixelLab-image_id), große base64-Bilder kommen abgeschnitten an, damit alles einheitlich bleibt.
- Jedes Ergebnis selbst ansehen und kritisch prüfen (Silhouette, Lesbarkeit bei Originalgröße, Stilregeln oben), dann ggf. per Inpainting nachbessern.
- Fertige Sprites ins Spiel einbauen: Sprite-Daten stehen in `prototype/index.html` im Objekt `SPR` (Palette `pal`, Pixelzeilen `px`,
  Blinzel-Frame `pb`, dunkle Farben `ol`, Größe `n`). Werkzeuge in `tools/sprites/node/` (einmalig `npm install`):
  1. `node reduce32.js <roh.png> <aus.png>` – auf **32 Farben** reduzieren (Original als `*_pixellab_original.png` behalten)
  2. `node holes.js <png> --fill` – eingeschlossene Löcher füllen (PixelLab stanzt manchmal Augen aus!)
  3. Augen suchen: `node eyes.js <png>` (Vorschlag, Ergebnis immer visuell prüfen; bei Glubschaugen Fellfarbe per fx,fy vorgeben)
  4. `node png2spr.js <png> <Schlüssel> --blink "x0,y0,x1,y1;…" --insert` → Eintrag + Blinzel-PNG (ein Rechteck je Auge)
  5. `node dark_outline.js <Schlüssel>` (Kontur schwarz schließen) und `node spr2png.js <Schlüssel>` (PNGs nach `assets/sprites/`)
- Nutzungsrechte von PixelLab für kommerzielle Nutzung vor dem Launch prüfen lassen.

## Qualitätsregeln für Änderungen am Prototyp
- Godot: Texturen **nie erst in `_draw()` laden** (bleiben im ersten Bild weiß) – `preload` oder `PixelCanvas.sprite()` (alles wird in `main._ready` vorgeladen).
- Godot (`game/`): nach jeder Änderung **zuerst `--headless --import` auf SCRIPT ERROR prüfen** (ein Parse-Fehler in main.gd lässt das Spiel leer hängen!), dann Godot-Tests, bei Grafikänderungen per `--shot` einen Screenshot rendern – immer mit `timeout 60 … --quit-after 900`, damit nichts hängen bleibt. Godot-Exe: `~/AppData/Local/Microsoft/WinGet/Packages/GodotEngine*/Godot_*_console.exe`.
- Browser-Prototyp: nach jeder Änderung `cd tests && npm test` ausführen.
- Bei Grafikänderungen ein Bild rendern (die Tests zeigen, wie: jsdom + canvas) und es selbst ansehen, bevor du fertig meldest.
- Änderungen im Vault dokumentieren (Playtest-Log bzw. passende Notiz).
- Ehrlich bleiben: Wenn etwas nicht gut aussieht oder nicht getestet ist, sag es.
- Keine nativen Browser-Dialoge (`confirm`/`alert`/`prompt`) – sie werden im App-Browser und in manchen WebViews blockiert. Stattdessen `confirmTap(btn, frage, aktion)` (zweimal tippen).
