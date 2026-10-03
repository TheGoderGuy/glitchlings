---
tags: [produktion, technik, godot]
---
# Performance (03.10.2026)

**Frage des Produzenten:** Schafft das Spiel konstant 60 fps bei 1080p?

## Messmodus
`godot --path game -- --bench=<sekunden> --mode=<…> [Shot-Optionen]` (`scripts/shot.gd`)
- Er baut dieselbe Szene auf wie die Screenshot-Modi und öffnet ein Fenster in 1920 × 1080, ohne VSync und ohne Bildratenbremse.
- Im Kampf spielt ein Autopilot: Er setzt jede 0,25 s alle Chips ein, weicht zufällig aus, nutzt die Signatur und füllt die HP auf. So laufen Effekte, Treffer und Gegnerangriffe wirklich mit.
- Ausgabe: Schnitt, 99. Perzentil, Maximum, Anzahl der Bilder über 16,7 ms, Render-CPU, GPU und Zeichenaufrufe. Jedes langsame Bild wird mit Szene und Zeitpunkt gemeldet.

## Ergebnis auf dem Entwicklungs-PC
Core Ultra 7 255HX, RTX 5070 Laptop, Godot 4.7 (GL Compatibility):

| Szene | Schnitt | 99 % | Max | Zeichenaufrufe |
|---|---|---|---|---|
| Titel | 0,71 ms | 1,25 ms | 2,2 ms | 31 |
| Karte | 1,94 ms | 2,76 ms | 4,9 ms | 118 |
| Kampf Wiesen (Bugsy) | 1,73 ms | 2,73 ms | 4,5 ms | 128 |
| Boss Glutkernskarabäus | 1,13 ms | 2,49 ms | 4,2 ms | 80 |
| Boss Schwarmkönigin | 1,35 ms | 2,59 ms | 4,7 ms | 86 |
| Endboss Ur-Glitch (20 s, 4 Läufe) | 1,2–1,5 ms | 2,5–3,0 ms | 4–6,5 ms | ca. 80 |
| Station / Monsterdex | 0,9 ms | 1,4 ms | 4,2 ms | 72–95 |
| Kino-Intro / Ende | 0,7–0,8 ms | 1,3 ms | 13 ms (Bildwechsel) | 9–12 |

- Das Budget für 60 fps sind 16,7 ms pro Bild. Selbst das 99. Perzentil liegt bei höchstens 3 ms, das ist etwa **5- bis 6-fache Reserve**.
- Die GPU ist praktisch unbelastet (unter 0,3 ms). Gerendert wird intern in 640 × 360 und nur ganzzahlig hochskaliert. Die Grenze liegt also bei der CPU, nämlich bei GDScript-Logik und dem Zeichnen.
- Ein Ausreißer (265 ms, 24 langsame Bilder) trat in einem von vier Ur-Glitch-Läufen auf und ließ sich nicht wiederholen. Wahrscheinlich kam er vom System.

## Gleichmäßigkeit für höhere Schwierigkeit (03.10.2026)
Der Produzent will ein flüssiges Spielgefühl, weil die Schwierigkeit steigen soll. Umgesetzt:

1. **Feste Rechenschritte im Kampf** (`BattleState.advance`)
   - Jedes Bild wird in Schritte von höchstens 1/120 s geteilt. Dadurch laufen Kampf und Trefferprüfung bei 60, 120 und 165 Hz gleich ab.
   - Ein Hänger zählt höchstens 50 ms. Das Spiel bremst dann kurz, statt vorzuspulen.
   - Vorher konnte ein Geschoss den Gegner bei einem 100-ms-Hänger überspringen: Es fliegt 12 Felder pro Sekunde, das Trefferfenster ist ±0,4 Felder. Außerdem wäre ein Angriff ohne sichtbare Vorwarnung eingeschlagen.
   - Tests: „Hänger von 250 ms: Geschoss überspringt den Gegner nicht“ und „60 Hz und 165 Hz: gleicher Kampfverlauf nach 6 s“.
2. **Musik wird vorgeladen** (`music.gd`)
   - Alle Stücke laden nach dem Start mit Threads im Hintergrund. Im Browser, ohne Threads, kommt ein Stück alle 20 Bilder dazu.
   - Ein Szenenwechsel wartet nicht mehr auf die WAV-Datei. Vorher kostete das bis zu 23 ms.
3. **Zonen-Kulissen werden beim Start vorberechnet** (`PixelCanvas.preload_all`)
   - Jede Kulisse kostet etwa 20 ms Pixelarbeit. Bisher fiel die genau beim ersten Kampf oder der ersten Karte einer Zone an, und die Zonenwahl rechnete beim ersten Öffnen alle vier auf einmal.
4. **Neue Option „VSync: An/Aus“** (unter Vollbild)
   - An (Standard): ruhiges Bild ohne Zerreißen.
   - Aus: weniger Eingabeverzögerung, Bildrate bis 300.

**Wechsel-Messung** `--bench=30 --mode=wechsel`: Sie wechselt alle 45 Bilder zwischen Titel, Station, Karte, Kampf und Ergebnis und meldet das langsamste Bild nach jedem Wechsel.
- Ergebnis: Titel 3 ms, Karte 6–8 ms, Kampf 5–7 ms, Ergebnis 3–4 ms.
- Ausnahme: Das **allererste** Öffnen der Station kostet einmal 15–25 ms. Das ist kein Schriftrastern (Vorwärmen half nicht) und auch nicht das Zeichnen selbst (etwa 5 ms). Vermutlich wird beim ersten Mal Text geformt. Das ist ein einmaliger Menü-Hänger ohne Bedeutung fürs Spielgefühl und wird nicht weiter verfolgt.

## Offen
- Nicht auf schwacher Hardware gemessen. Grobe Schätzung: Ein Steam Deck ist in der CPU etwa 2,5- bis 4-mal langsamer, das ergäbe 8 bis 12 ms im 99. Perzentil und damit weiter 60 fps. Für eine sichere Aussage muss man auf echtem Gerät testen, zum Beispiel einem alten Laptop oder dem Steam Deck.
- Die Web-Fassung (WebAssembly, ohne Threads) ist deutlich langsamer und hier nicht gemessen.
