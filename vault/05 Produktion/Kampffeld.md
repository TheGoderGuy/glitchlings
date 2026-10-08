---
tags: [produktion, grafik, kampf, godot]
---
# Kampffeld je Zone (08.10.2026)

Aus der [[Game-Design-Analyse 2026-10-08]], Punkt „Kampffeld“. Vorher waren alle 18 Felder in jeder Zone gleich: Rechtecke mit Datenraster auf einem dunklen Sockel. Sie verdeckten die Zonenkulisse fast ganz und wirkten wie eine Tabelle, nicht wie ein Ort.

## Was neu ist
- **Material je Zone**, als Pixel-Textur vorab erzeugt (`game/scripts/battle/arena_tiles.gd`, `ArenaTiles`):

| Zone | Platte | Leuchtebene (pulsiert je Platte versetzt) |
|---|---|---|
| Cache-Wiesen | Gras mit Büscheln | Daten-Blüten |
| Firewall-Vulkan | Basaltplatten mit Fugen | glimmende Fugen, Glutnaht an der Kante |
| Kühlwasser-See | Metallgitter mit Nieten | Nässe-Glanz |
| Viren-Sümpfe | Holzplanken mit Moos | Leuchtpilze |
| Hochspannungs-Steppe | Trockenschollen, Erdkabel | Funken am Kabel |
| NEST-Kern | Metallplatten mit Leiterbahnen | Knoten der Leiterbahnen, Lichtleiste |

- **Seiten auf einen Blick:**
  - Deine Seite ist blaugrün getönt.
  - Die Gegnerseite wird im Farbton Richtung Magenta gedreht, nicht gemischt. Mischen mit der Gegenfarbe (Grün + Magenta) ergab Grau. So wird z. B. das Gras der Wiesen auf der Gegnerseite violett: Es wirkt wie korrumpiert.
  - Oberkante und Vorderkante tragen die Seitenfarbe kräftig, wie bei Battle Network.
- **Kein Sockel mehr:** Jede Platte steht einzeln mit Schatten, die Kulisse ist zwischen den Platten sichtbar.
- **Pixel-Regeln:** Licht von oben links (helle Ober-/Linkskante, dunkle Unter-/Rechtskante), dunkle Kontur, abgerundete Ecken, 3 Varianten je Seite gegen Wiederholung. Hintere Reihen sind etwas dunkler (Tiefe).
- **Spielgeometrie unverändert:** Feldgröße, Warnungen, Flächen, Effekte und Trefferlogik sind gleich geblieben (`cell_rect`).

## Leistung
- Platten werden beim Start vorab erzeugt (`PixelCanvas.preload_all`, alle Zonen zusammen 84 ms) und im Kampf nur noch als Texturen gezeichnet.
- Messung im Vulkan-Kampf (1080p, ohne VSync): 2,1 ms je Bild, 99 % unter 2,7 ms. Vorher waren es 3,8 ms, weil jedes Feld aus Dutzenden Einzelrechtecken bestand.

## Test
`test_arena_tiles`: Jede Zone hat ein eigenes Material, beide Seiten sind unterscheidbar, die Größe passt zum Raster.

## Offen
- Perspektive wie in Battle Network (schräg zulaufende Reihen) wurde bewusst nicht umgesetzt: Dafür müssten alle Effekte und Warnflächen auf Trapeze umgestellt werden.
- Gegnergrößen im Spätspiel (Analyse) sind noch offen.
