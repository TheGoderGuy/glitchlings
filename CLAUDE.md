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

## Aktueller Stand (Godot, 07.10.2026)
- **Kampf:** 3×3-Raster je Seite, Echtzeit, **45 Chips** in **2× Angriff (geteilter Stapel) + 1× Support**, Signatur-Attacke, Passiv je Linie, 22 Module. Effekte je Chip, Flächen: Lava, Giftschleim, Strömung, Spannungsfelder. Wächter und Bosse mit Phasen und goldenen Großangriffen.
  Steuerung: WASD/Pfeile + J/K/L, Leertaste = Signatur, frei belegbar; Controller Chips X/A/B (PS □/✕/○), Signatur Y/RT, eigene PS-Symbole (`InputSetup.btn()`). **Kein Vormerken** ladender Chips (Karte blinkt nur rot).
- **Run:** Zonenkarte mit 3 Ebenen × 5 Etagen (Kern 2), Kampf/Elite/Glitch-Elite/Ereignis/Rast/Händler, Wächter am Ebenenende, Boss mit Intro. Nach jedem Kampf 1-aus-3-Chipwahl, verbesserte Chips (`Name+`).
- **Zonen (linear):** Cache-Wiesen > Firewall-Vulkan > Kühlwasser-See > Viren-Sümpfe > Hochspannungs-Steppe > NEST-Kern (Endboss Ur-Glitch), danach Abspann und Weiterspielen.
- **Glitchlinge:** 13 Linien bis Ultra plus Fusionen und 6 Legendäre (Champion + Ultra), **114 Formen** im Dex. Babys: Pixmiez (Katze), Funkling (Welpe), Tröpfel (Axolotl), Kekso (Hamster), Lumi (Hase), Quakli (Frosch), Molchi (Salamander), Brummbit (Bär), Kauzbit (Robo-Eule), Buddli (Dachs), Maskli (Waschbär), Bachli (Otter), Plapperli (Ara).
  **Evolution:** Prägung = Element der gespielten Element-Chips (Rookie 12, Champion 35, Ultra 80, 2 Chips Vorsprung), dauerhaft pro Monster gespeichert.
- **Elemente:** Feuer, Wasser, Code, Elektro, Virus, Neutral (Feuer > Code > Wasser > Feuer, Elektro <> Virus).
- **Station:** Zuhause (Bewohner laufen herum, streicheln), Team (Zonenwahl), Brutnest (Eier nach Runs oder für 200 Fragmente), Labor (geheime Fusionen), Monsterdex, Ausbau. Führung beim ersten Besuch.
- **Rahmen:** Kino-Intro und -Ende, Training nach der Starterwahl, Kampf-Handbuch, DE/EN, Schwierigkeiten Entspannt bis Korrumpiert, Musik und Sounds selbst synthetisiert (Platzhalter), 325 Tests.
- **Browser-Prototyp** (`prototype/`): alter Stand mit Pop-Up-Tyrann, Echtzeit-Eiern und Expeditionen, nur noch Referenz.

## Getroffene Entscheidungen (nicht ohne Rückfrage ändern)
1. **Art Direction „Tier + digitales Merkmal“** – echte Tier-Monster im Digimon-/Yu-Gi-Oh-Stil. Das Digitale zeigt sich NUR als Körpermerkmal (Leuchtlinien, Muster, Energie, Element-Effekte), **keine Gegenstands-/Kostüm-Konzepte** (keine Pop-up-Fenster, Trojaner-Holzpferde, Detektivmützen, Embleme o. Ä.; Entscheidung 27.09.2026). Rüstung ab Champion/Ultra ist ok, wenn sie organisch/kreaturhaft wirkt. **Maschinen-Tiere sind erlaubt** (Robo-Eule-Linie, Mecha-Bär, später Mecha-Champions der Code-Richtungen) – Tierform bleibt immer erkennbar; Gegenstände als Körper (Fenster, Holzpferd) bleiben verboten. Spieler-Monster basieren auf Tieren (Fuchs, Welpe/Wolf, Axolotl, Hamster, Hase, Frosch). **Gegner sind digitale Monster und Maschinen** (Insekten, Würmer, Mecha-Tiere, Pflanzen-Monster) als korrumpierte Daten – **keine Internet-/Werbe-Anspielungen** (keine Pop-ups, Spam, Werbebanner, Cookies, Captchas, Ladebalken, „Gratis“; Entscheidung 29.09.2026). Technische Begriffe (Bug, Virus, Code, Cache, Firewall, Kernel) sind ok.
2. **Stil wächst mit der Stufe:** Baby & Rookie niedlich, Champion Übergang, Ultra cool (Rüstung, Leuchtlinien, mehrere Schweife).
3. **Größenstaffel nach Digimon-UP-Niveau:** Baby 32×32, Rookie 64×64, Champion 80×80, Ultra 96×96.
   Referenz: Digimon UP (Bandai Namco, 2026) – Rookie-Sprites aus Screenshot gemessen ca. 60–80 px hoch (≈ 64er-Leinwand).
4. **Sprite-Regeln:** Licht von oben links, Kontur fast schwarz (seit 27.09.2026), max. 32 Farben pro Sprite (inkl. Blinzel-Bild und Idle-Frames, per Test geprüft; Aufräumen mit `tools/sprites/node/fix_colors.js`), Dithering nur an Übergängen,
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
- [ ] Phase 1c: ~~Angriffs-/Idle-Animationen~~ (fertig), Musik, Balancing nach erstem Anspielen – besser als der Browser-Prototyp?
- [x] Phase 2a (28.09.2026): Zonenkarte Cache-Wiesen (7 Etagen + Boss; Kampf, Elite, Ereignis, Rast, Händler), Ergebnisbildschirm, 42 Tests – `vault/05 Produktion/Zonenkarte.md`
- [x] Phase 2b (28.09.2026): Starterwahl (Pixmiez/Funkling/Tröpfel), Evolution im Run (15/35 Prägung, 18 Formen, 18 Signaturen), Evolutions-Szene, 55 Tests – `vault/05 Produktion/Evolution im Run.md`
- [x] Phase 2c-1 (28.09.2026): 12 neue Chips (jetzt 27, je Element 4–5), 4 neue Ereignisse (jetzt 8), 76 Tests
- [x] Phase 2c-2 (28.09.2026): 3 neue Gegner (heute Chiffrekäfer, Datenwespe, Glutraupe) mit Kreuz-/Wand-Mustern, Gegner-Pools je Etage, 80 Tests
- [x] Phase 2d (28.09.2026): 4 Chiptune-Platzhalterstücke (Titel/Karte/Kampf/Boss, selbst synthetisiert), Zonen-Hintergrund Cache-Wiesen, Schwierigkeit Entspannt/Normal/Knackig, Musik-Lautstärke, Blinzel-Frames, 84 Tests
- [x] Musik 29.09.: Titel/Karte/Boss im GBA/DS-Stil neu (Bossmusik „mega“), alte Kampfmusik bleibt („episch“), Siegesfanfare, Karte läuft nach Kämpfen weiter
- [x] Phase 3a (29.09.2026): Spielstand, Station (Team/Brutnest/Monsterdex), dauerhafte Evolution (Rookie 15, Champion 60), Eier nach Runs, Schlüpf-Szene, 99 Tests – `vault/05 Produktion/Station.md`
- [x] Phase 3b (29.09.2026): 6 weitere Linien (Kekso, Lumi, Quakli, Molchi, Brummbit, Kauzbit) als Ei-Inhalt – 9 Linien, 40 Formen, 6 neue Passive, Monsterdex blättert, 109 Tests
- [x] Labor/Fusion (29.09.2026): 4 Fusionen mit neuen Passiven/Signaturen, Rezeptbuch mit Gerüchten, Fragmente werden gerettet, 120 Tests
- [x] Zone 2 Firewall-Vulkan (29.09.2026): 3 Gegner + Boss (PixelLab), Lava-Mechanik, Zwei-Spalten-Angriff, Zonen-Freischaltung + Auswahl, 133 Tests – `vault/05 Produktion/Zone Firewall-Vulkan.md`
- [x] Spieltest-Paket (29.09.2026): Windows-.exe (`Spieltest_bauen.bat` → `build/Glitchlings_Spieltest.zip`), Tutorial im ersten Kampf, lokales Spieltest-Log, LIESMICH – `vault/05 Produktion/Externer Spieltest.md`
- [x] B Kampf-Juice (29.09.2026): Vorschnellen, Mündungsblitz, Rückstoß, Ausholen/Zuschlagen, Staub, Niederlage-Animation
- [x] C Champions (29.09.2026): 11 neue Champions per PixelLab (Rookie als Referenz), jeder Rookie hat jetzt eine Endstufe – 55 Formen
- [x] Evolution überarbeitet (29.09.2026): Licht → **Elektro**, Heilpatch neutral, Pixmiez Elektro→Prismiez, nur Element-Chips zählen (Rookie 12, Champion 35), 2 Chips Vorsprung nötig, faire Startdecks, Richtungsanzeige überall – Details `vault/05 Produktion/Evolution im Run.md`
- [x] Zone 3 Viren-Sümpfe (29.09.2026): Saugmücke (Lebensraub), Panzerschnecke (Schleim verlangsamt), Glitchblüte (stationär, Glitch-Sporen), Boss Schwarmkönigin, 154 Tests – `vault/05 Produktion/Zone Viren-Sümpfe.md`
- [x] Ultras (29.09.2026): 21 Ultras (96 px, PixelLab) mit Signatur-Attacken, ab 80 Element-Chips, Dex nach Linien sortiert, 156 Tests – `vault/05 Produktion/Evolution im Run.md`
- [x] Blinzel-Frames für alle Champions + Ultras (29.09.2026, außer Toxmolch), Boxen in `tools/sprites/blink_boxes.json`
- [x] Zonenmusik (29.09.2026): `map_vulkan`/`battle_vulkan`, `map_sumpf`/`battle_sumpf`, 158 Tests
- [x] Zonen-Ereignisse + Gegner-Blinzeln (29.09.2026): je 4 eigene Ereignisse für Vulkan und Sümpfe (16 insgesamt, 3 nur Wiesen), Element-Prägung aus Ereignissen, „Gegner geschwächt“, 167 Tests
- [x] Toxmolch blinzelt, Ereignis-Bildschirm mit Zonenlandschaft + animierter Szene je Ereignis, Lagerfeuer am Rastplatz (29.09.2026)
- [x] Opening-Szene (29.09.2026): 5 Bilder (Boot → Absturz → Flucht → Ei auf dem Desktop → Operator), eigene Intro-Musik, überspringbar, „Intro ansehen“ in den Optionen, 171 Tests – `vault/05 Produktion/Opening-Szene.md`
- [x] Keine Internet-/Werbe-Anspielungen (29.09.2026): Zone 3 → Viren-Sümpfe, 6 neue Gegner-Sprites (Bytewurm, Kernelmantis als Boss Zone 1, Datenwespe, Panzerschnecke, Glitchblüte, Schwarmkönigin), Pop-ups → Bitmilben/Glitch-Sporen, Ereignisse Bit-Beeren/Wartungsdrohne/Datenleitung
- [x] Boss-Intros (29.09.2026): Warnstreifen, Silhouette, Enthüllung mit Blitz + Bossmusik, Name/Titel mit Glitch-Effekt, überspringbar, 177 Tests – `vault/05 Produktion/Boss-Intros.md`
- [x] Finale + Ende (29.09.2026): Zone 4 NEST-Kern (4 Etagen, Kerndrohne, Glitchspinne), Endboss Ur-Glitch (wechselt das Element), Ende-Szene + Abspann, danach weiterspielen, Schwierigkeit „Korrumpiert“, Musik map_kern/finale/ending, 188 Tests – `vault/05 Produktion/Finale und Ende.md`
- [x] Module (29.09.2026): 22 passive Run-Gegenstände (Elite, Händler, Modulkapsel), Anzeige in Kampf/Karte/Räumen/Pause, 204 Tests – `vault/05 Produktion/Module.md`
- [x] Chips 28 → 45 (29.09.2026): 17 neue Kombo-Chips (je Element 7–8), Konter/Ausweichen/Geschützturm, 216 Tests – Tabelle in `vault/06 Datenbank/Chip-Übersicht.md`
- [x] Glitchlinge überarbeitet (29.09.2026): Brummbit Gift-Linie (Pilzbrumm/Sporenpranke/Myzelgrizz), Lumi Wasser-Linie (Perlhopp/Gischthase/Lunaflut), Pixmiez ohne Feuer-Linie, Leviamander/Tracko/Gigaquak/Kekso neu, Fusionen Wolperling, Schlummerbit, Pustebacke statt Dampfbyte/Glyphel, Brummbit braun, Gigaquak Titan, 74 Formen, Spielstand-Übertragung – `vault/05 Produktion/Glitchlinge-Überarbeitung.md`
- [x] Dachs (Buddli: Feuer/Elektro) und Waschbär (Maskli: Wasser/Virus) als neue Linien bis Ultra, Passive Furchtlos/Langfinger, 88 Formen, 223 Tests – `vault/05 Produktion/Dachs und Waschbär.md`
- [x] **Legendäre** (07.10.2026): je Zone ein Fabelwesen mit geheimer Bedingung beim Boss-Sieg (Glimmhirsch/Baby, Glutkirin/6 Feuer-Chips, Sternwal/nie mitgerissen, Toxilisk/ohne Heilpatch, Funkengreif/10 s Spannungsfeld, Chiffrasphinx/Signatur-Siegtreffer) > leuchtendes Ei (auch über Nestplätze hinaus), schlüpfen als Champion, Ultra ab 80 Element-Chips (Lumicervus, Pyrokirin, Astralwal, Miasmalisk, Donnergryph, Algosphinx), eigene Passive + Signaturen, Dex-Reihen mit Gerüchten, 114 Formen, 339 Tests – `vault/05 Produktion/Legendäre.md`
- [x] **Glitch-Protokolle** (07.10.2026): Endgame nach dem Abspann, 10 aufbauende Stufen (Zähe Daten … Glitch-Sturm), Wahl in der Zonenwahl mit Hoch/Runter, je Stufe +5 % Fragmente, nächste Stufe durch Boss-Sieg auf der höchsten, Protokoll-Abzeichen je Glitchling (`GameData.PROTOCOLS`, `RunState.protocol`, `SaveGame.protocol_unlocked/choice`), Screenshot `--zones --protocol=N`, 333 Tests – `vault/05 Produktion/Glitch-Protokolle.md`
- [x] **Zuhause in der Station** (06.10.2026): neuer Reiter ganz links (Station öffnet dort), bis zu 12 Team-Glitchlinge laufen, schlafen, spielen zu zweit, besuchen Lieblingsplätze je Element (Lagerfeuer, Teich, Blitzableiter, Datenbaum, Pilzkreis, Bit-Ball), Eulen/Aras schweben, Streicheln mit Herzchen + Reaktion je Tierart, seit 07.10. Tageszeiten je Run (Morgen/Tag/Abend/Nacht, nachts mehr Schlaf) und Einzugsszene für Neue (`home_seen`) (`HomeSim`, `station_view._draw_home`), Screenshot `--mode=home --t= [--pops] [--daytime=] [--welcome]`, 328 Tests – `vault/05 Produktion/Zuhause in der Station.md`
- [x] **Zonen Kühlwasser-See + Hochspannungs-Steppe** (06.10.2026): Reihenfolge jetzt **Wiesen > Vulkan > See > Sümpfe > Steppe > Kern** (Produzent: linear), Strömung (reißt mit, kein Schaden) bzw. Spannungsfelder (kosten HP, Chips laden x2), je 4 Gegner + 2 Wächter + Boss (Tiefenschlange, Donnerkondor), 8 Ereignisse, Kulissen (Kühlsee, Strommasten + Wetterleuchten), Musik map_/battle_see|steppe, Großangriff „Welle“, alte Spielstände behalten freie Zonen (`legacy_zones`), Zonenwahl als Karussell, Kern-HP 1,75, 321 Tests – `vault/05 Produktion/Zonen See und Steppe.md`
- [x] **Tester-Feedback 04.10.: Training, Effekte, Gegner** – Trainingskampf direkt nach der Starterwahl + Titel > Training (8 Lernschritte, verlieren unmöglich), alle 45 Chips mit eigenem Effekt (`BattleState.vfx`, `_draw_vfx/_draw_proj/_draw_shield`, Heilpatch = Pflaster), Flächeneffekte neu (Lava-Risse > Ausbruch > Lavapfütze mit Schollen, Giftschleim-Pfützen, Brand/Gift/Langsam/Eis sichtbar am Gegner, 05.10.), 5 neue Gegner (Funkenkäfer, Datenegel, Moorlibelle, Sentinelkrabbe, Fehlerqualle) und nur noch zonentypische Gegner-Pools, Screenshot `--chip=` / `--area`, 311 Tests – `vault/05 Produktion/Tester-Feedback Training, Effekte, Gegner.md`
- [x] **Spiel zurücksetzen** (04.10.2026): Optionen > Spiel zurücksetzen (2× bestätigen) löscht Spielstand, Run, Einstellungen und Tastenbelegung wie eine Neuinstallation, Spieltest-Log bleibt; Tests leiten `Settings.path` um, 305 Tests – `vault/05 Produktion/Externer Spieltest.md`
- [x] **Tastenbelegung** (03.10.2026): Optionen > Tastenbelegung, 11 Aktionen frei belegbar (Tausch bei Doppelbelegung, Pfeile/Enter/Esc/Rücktaste/Tab fest), gespeichert in settings.cfg, alle Tastenhinweise folgen der Belegung (`InputSetup.key_label/key_text/move_keys`), Optionen jetzt über Kennungen (`OPTIONS`), 303 Tests – `vault/05 Produktion/Tastenbelegung.md`
- [x] **Logo „Digi-Ei“** (03.10.2026): Ei mit Augen im Riss + Leiterbahnen (PixelLab, Variante C), 128/64/32 px + `digiei.ico` als Fenster-/exe-/Web-Symbol, auf dem Titel links neben dem Schriftzug; **Steam-Bilder** (alle Kapseln, Bibliothek inkl. Hero/Logo, Community-Symbol) in `assets/steam/` per `res://tools/steam_art.tscn` – `vault/05 Produktion/Logo.md`
- [x] **Otter (Bachli: Wasser/Elektro) und Ara (Plapperli: Elektro/Feuer)** (03.10.2026) bis Ultra, Passive Teamgeist (Support-Slot +25 % Laden) / Nachplappern (jeder 4. Angriffs-Chip nach 0,5 s mit halbem Schaden), 102 Formen, 13 Linien, 295 Tests – `vault/05 Produktion/Otter und Ara.md`
- [x] Ebenen + Wächter (30.09.2026): Zonen 3 Ebenen × 5 Etagen (Kern 2), 7 Wächter (Sprungschreck, Dornwurz, Schlackwurm, Magmaskorp, Schnappkelch, Schlickkrake, Skolopendrox), Boss-Phasen mit neuen Mustern, goldene Großangriffe (ausweichen = Überlastet), Wächtermusik, Run speichern/fortsetzen, 239 Tests – `vault/05 Produktion/Ebenen und Wächter.md`
- [x] Deckbau + Station-Ausbau (30.09.2026): verbesserte Chips (`Name+`, Rast/Händler/Ereignisse), Synergie-Hinweise in der Chipwahl, Glitch-Elite (riskante Route), 9 neue Ereignisse (26, NEST-Kern mit Lore), Station-Reiter „Ausbau“ (6 Ausbauten), 261 Tests – `vault/05 Produktion/Deckbau und Station-Ausbau.md`
- [x] Schrift (30.09.2026): Fließtext jetzt **Pixeloid Sans** (9 px, Kleinbuchstaben, OFL), Überschriften/Logo bleiben Silkscreen; alle Bildschirme geprüft (Händler, Station, Labor angepasst)
- [x] Kino-Intro (30.09.2026, seit 06.10. mit allen 6 Zonen, Weltfahrt 15 s): 8 Bilder, ca. 62 s – Kaltstart, Kamerafahrt über den NEST, Ur-Glitch als Silhouette, Absturz (Röhre geht aus), Flucht als Lichtspuren, Title Drop, Gewitternacht, Ei mit Herzschlag; Kinobalken, taktgenaue Musik `opening` (One-Shot), Video per `--write-movie … -- --play=opening` – `vault/05 Produktion/Opening-Szene.md`
- [x] Kino-Ende (30.09.2026): 9 Bilder, ca. 69 s – Ur-Glitch zerspringt, Neustart, Heilungswelle über den NEST, Heimkehr als Lichtspuren, Team, Zimmer am Morgen, Title Drop, kurzer Abspann (2 Karten), ENDE mit neuem Ei; Musik `ending` taktgenau (One-Shot), gemeinsame Kino-Werkzeuge in `cinema_canvas.gd`, 275 Tests – `vault/05 Produktion/Finale und Ende.md`
- [x] Tester-Orientierung v0.3 (30.09.2026): Zonenwahl-Bildschirm (4 Zonen als Karten, gesperrt/geschafft), Station-Führung (7 Schritte, Hilfe-Taste Leertaste/Y), Karten-Tipp beim ersten Run, LIESMICH aktualisiert, 270 Tests – `vault/05 Produktion/Externer Spieltest.md`
- [x] Kampf-Handbuch (30.09.2026): 8 Seiten mit gezeichneten Beispielen (Spielfeld, Chips, Ausweichen, Elemente, Zustände, Signatur/Passiv, Entwicklung, Nach dem Kampf), erreichbar über Titelmenü, Pause (Kampf + Karte), Station und Taste H / Select (`handbook_view.gd`, `PixelCanvas.open_handbook()`), 274 Tests
- [x] **Eier vereinfacht** (03.10.2026): nur eine Ei-Sorte (schlüpft nach 2 Runs, Brutwärmer 1), alle 11 Babys möglich, fehlende Arten 3-fach gewichtet, Seltenheiten/Legendär gestrichen bis es einen Plan gibt, alte Eier werden umgewandelt, Ei kaufen im Brutnest für 200 Fragmente, 292 Tests – `vault/05 Produktion/Station.md`
- [x] **Rollen-Slots + Einstieg** (01.10.2026, Tester-Feedback): seit 03.10. **2× Angriff (J/□, K/✕, geteilter Stapel) + 1× Support (L/○: Schutz + Heilung)**, Support-Neumischen +3 s, Startdecks 6 Angriff + 2 Support, Karten mit Trefferbild + Kurzwirkung + sichtbarem Stapel, Deck-Vorstellung, Tutorial-Schritt, Bereit-Pause nur bei unbekannten Chips auf der Starthand (03.10.), neue Chips mit kleinem „Neu!“ (keine Zeitlupe mehr, 03.10.), 289 Tests – `vault/05 Produktion/Rollen-Slots und Einstieg.md`
- [x] **Web-Spieltest** (01.10.2026): Godot-Web-Export (ohne Threads), `Web_bauen.bat` → `build/Glitchlings_Web.zip` für itch.io (Restricted), Testfassung `testbuild` nur Wiesen + Vulkan, Titel mit „TESTVERSION“ + © 2026 TheGoderGuy, Log-Download im Browser, lokaler Test `node tools/webserver.js` (Launch „web“, `/_itch` = 1280×720-Rahmen), 279 Tests – `vault/05 Produktion/Web-Spieltest.md`
- [x] **Englisch** (01.10.2026): Sprache in den Optionen (erster Start: Systemsprache), `T.t()` mit deutschen Texten als Schlüssel, englische Tabellen `scripts/data/lang_en_*.gd`, eigene englische Monsternamen (namecheck-geprüft), interne IDs bleiben deutsch, Test prüft Vollständigkeit, `node game/tools/lang_keys.js --missing`, Screenshots mit `--lang=en`, 278 Tests – `vault/05 Produktion/Englisch.md`
- [x] Idle-Animationen: **alle 132 Figuren** (30.09.2026, Otter + Ara 03.10., neue Zonengegner 04.10.), 6 Bilder, 10 Bilder/s (`tools/sprites/node/anim_frames.js`, entfernt jetzt auch mitgemalte Hintergründe) – `vault/05 Produktion/Idle-Animationen.md`
- [x] **Angriffsanimationen** (05.10.2026): alle 132 Figuren, 6 Bilder (PixelLab `animate_image`, Prompt „big exaggerated attack …“), eigener Glitchling bei Angriffs-Chips + Signatur (0,36 s), Gegner holen synchron zur Warnung aus und schlagen beim Einschlag zu, Vorschnellen bleibt; `anim_frames.js --kind atk`, Screenshot `--atkpose=0–1`, Test prüft 32 Farben inkl. Angriff + jede Figur hat eine, 312 Tests – `vault/05 Produktion/Angriffsanimationen.md`
- [ ] Phase 4: Steam-Seite + Demo – offene Punkte stehen in `vault/05 Produktion/Roadmap.md` (Stand 07.10.2026)
- [x] **Aufräumen** (07.10.2026): Roadmap auf den echten Stand, `LIZENZEN.txt` (Schriften OFL, Godot MIT, Engine-Bibliotheken; `godot --headless --path game --script res://tools/write_licenses.gd`) liegt jedem Build bei, Abspann nennt sie

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
- [x] Signatur-Fähigkeiten der 4 Fusionen (Godot, 29.09.2026)
- [x] 7 Mecha-Champions der Code-Richtungen (Bollwerkatz, Turbowulf, Panzerpuff, Mechaquak, Holohas, Titanbrumm, Radarkauz)
- [x] Champions für die übrigen Nicht-Code-Rookies (Godot, 29.09.2026) · [x] Ultras (Godot, 29.09.2026)
- [x] Station-Leben: Bindung/Pflege + Expeditionen (`vault/05 Produktion/Station-Leben.md`)
- [x] Champions der übrigen Linien · [x] Ultras (Godot)
- [x] Angriffsanimationen (05.10.2026): alle 132 Figuren – `vault/05 Produktion/Angriffsanimationen.md`
- [ ] Prototyp mit 5–10 externen Testern spielen lassen, Ergebnisse ins Playtest-Log (`vault/05 Produktion/Prototyp-Spezifikation.md`)

## Arbeitsweise mit PixelLab (sobald verbunden)
- Beschreibungen auf Englisch an PixelLab, immer „entire creature fits inside the canvas, nothing cut off“ dazuschreiben, Größe passend zur Stufe, transparenter Hintergrund, Blick nach rechts (Spieler steht links).
- Unsere bestehenden Sprites (`assets/sprites/`, z. B. `Blazebit_64_x4.png`, `Pyrolynx_96_x4.png`) als **Stilreferenz** nutzen – bei PixelLab am besten per `style_image.source_image_id` (PixelLab-image_id), große base64-Bilder kommen abgeschnitten an, damit alles einheitlich bleibt.
- Jedes Ergebnis selbst ansehen und kritisch prüfen (Silhouette, Lesbarkeit bei Originalgröße, Stilregeln oben), dann ggf. per Inpainting nachbessern.
- Fertige Sprites ins Spiel einbauen: Sprite-Daten stehen in `prototype/index.html` im Objekt `SPR` (Palette `pal`, Pixelzeilen `px`,
  Blinzel-Frame `pb`, dunkle Farben `ol`, Größe `n`). Werkzeuge in `tools/sprites/node/` (einmalig `npm install`):
  1. `node reduce32.js <roh.png> <aus.png>` – auf **32 Farben** reduzieren (Original als `*_pixellab_original.png` behalten). Danach mit `holes.js --fill` bleibt die Palette erhalten (seit 29.09.2026).
  2. `node holes.js <png> --fill` – eingeschlossene Löcher füllen (PixelLab stanzt manchmal Augen aus!)
  3. Augen suchen: `node eyes.js <png>` (Vorschlag, Ergebnis immer visuell prüfen; bei Glubschaugen Fellfarbe per fx,fy vorgeben)
  4. `node png2spr.js <png> <Schlüssel> --blink "x0,y0,x1,y1;…" --insert` → Eintrag + Blinzel-PNG (ein Rechteck je Auge)
  5. `node dark_outline.js <Schlüssel>` (Kontur schwarz schließen) und `node spr2png.js <Schlüssel>` (PNGs nach `assets/sprites/`)
- **Nutzungsrechte PixelLab geklärt (03.10.2026, Produzent):** PixelLab erlaubt jede kommerzielle und nicht-kommerzielle Nutzung der erzeugten Bilder. Für Steam bleibt nur die Offenlegung KI-erzeugter Inhalte im Content-Fragebogen.

## Qualitätsregeln für Änderungen am Prototyp
- Godot-Texte zweisprachig: neue zusammengesetzte Texte in `T.t("…") % …`, danach `node game/tools/lang_keys.js --missing` und Übersetzung in `scripts/data/lang_en_*.gd` eintragen (Test „Englisch …“ prüft das).
- Godot-Text: im Code nur die Größen 8 / 16 / 24 verwenden. `_text()` bildet 8 automatisch auf die Pixeloid-Rastergröße ab; bei direkten `draw_multiline_string`/`draw_string`-Aufrufen `tsz(8)` und `font(bold, größe)` benutzen. Kein „→“ o. Ä. (fehlt in den Pixelschriften), stattdessen „>“. Controller-Tasten in Hinweisen immer über `InputSetup.btn("A")` usw.
- Godot: Texturen **nie erst in `_draw()` laden** (bleiben im ersten Bild weiß) – `preload` oder `PixelCanvas.sprite()` (alles wird in `main._ready` vorgeladen).
- Godot (`game/`): nach jeder Änderung **zuerst `--headless --import` auf SCRIPT ERROR prüfen** (ein Parse-Fehler in main.gd lässt das Spiel leer hängen!), dann Godot-Tests, bei Grafikänderungen per `--shot` einen Screenshot rendern – immer mit `timeout 60 … --quit-after 900`, damit nichts hängen bleibt. Godot-Exe: `~/AppData/Local/Microsoft/WinGet/Packages/GodotEngine*/Godot_*_console.exe`.
- Godot-Performance messen: `Godot --path game -- --bench=10 --mode=fight` (1080p, ohne VSync, Autopilot). Stand 03.10.2026: 99 % aller Bilder unter 3 ms, Budget 16,7 ms; `--mode=wechsel` misst Szenenwechsel. Kampf rechnet in festen Schritten (`BattleState.advance`, max. 1/120 s, Hänger zählen max. 50 ms), Musik und Zonen-Kulissen werden vorgeladen, Option VSync – `vault/05 Produktion/Performance.md`
- Godot-Tests dürfen **nie** den echten Spielstand oder das echte Spieltest-Log schreiben: `test_battle.gd` leitet in `_ready` `SaveGame.path`, `SaveGame.log_path` und `Settings.path` auf `user://test_*`-Dateien um (29.09.2026 hatte ein Test den echten Stand verändert). Diese Umleitung nie entfernen; neue Testfunktionen, die speichern, brauchen sonst nichts Zusätzliches.
- Browser-Prototyp: nach jeder Änderung `cd tests && npm test` ausführen.
- Bei Grafikänderungen ein Bild rendern (die Tests zeigen, wie: jsdom + canvas) und es selbst ansehen, bevor du fertig meldest.
- Änderungen im Vault dokumentieren (Playtest-Log bzw. passende Notiz).
- Ehrlich bleiben: Wenn etwas nicht gut aussieht oder nicht getestet ist, sag es.
- Keine nativen Browser-Dialoge (`confirm`/`alert`/`prompt`) – sie werden im App-Browser und in manchen WebViews blockiert. Stattdessen `confirmTap(btn, frage, aktion)` (zweimal tippen).
