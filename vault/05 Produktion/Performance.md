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

## Bekannte kleine Hänger
- Die Musik wird beim Szenenwechsel als WAV-Datei geladen. Das dauert 2 bis 23 ms (alle Stücke zusammen 64 MB). Auf langsamen Rechnern kann deshalb beim Wechsel ein Bild ausfallen. Mögliche Lösung: die Musik nach dem Start im Hintergrund vorladen.
- Kino-Bildwechsel: bis 13 ms, also noch unter dem Budget.

## Offen
- Nicht auf schwacher Hardware gemessen. Grobe Schätzung: Ein Steam Deck ist in der CPU etwa 2,5- bis 4-mal langsamer, das ergäbe 8 bis 12 ms im 99. Perzentil und damit weiter 60 fps. Für eine sichere Aussage muss man auf echtem Gerät testen, zum Beispiel einem alten Laptop oder dem Steam Deck.
- Die Web-Fassung (WebAssembly, ohne Threads) ist deutlich langsamer und hier nicht gemessen.
