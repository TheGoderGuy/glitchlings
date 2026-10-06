---
tags: [produktion, story, godot]
---
# Opening-Szene (Kino-Intro)

Läuft beim **neuen Spiel** (kein Spielstand) vor der Starterwahl, **ca. 62 s** (vorher 56 s), jederzeit überspringbar (Esc/Start). Enter/A zeigt den Text sofort bzw. blättert weiter, die Musik springt dabei mit. In den Optionen: **„Intro ansehen“**.

- Code: `game/scripts/ui/opening_view.gd`
- Screenshot: `--mode=opening --t=<Sekunde>`
- Video-Aufnahme: `godot --path game --write-movie build/Glitchlings_Intro.avi --fixed-fps 30 -- --play=opening`

**30.09.2026 zum Kino-Intro ausgebaut** (vorher 5 Bilder, ca. 35 s; die erste Fassung kam als „mega“ an).

## Kino-Mittel
- Kinobalken (40 px), die im Kaltstart hereinfahren. Bildunterschriften stehen im unteren Balken.
- Dunkle Ränder (Vignette), Kamerafahrt mit Vordergrund-Parallax, Bildwackeln bei Treffern.
- Farbversatz (Cyan/Magenta), Glitch-Blöcke, Bildrisse, Röhrenmonitor-Abschaltung.
- Musik **`opening`** (96 BPM, 1 Takt = 2,5 s) läuft **taktgenau** zu den Bildern und spielt einmal durch (One-Shot). Ab dem Zimmer übernimmt `intro`, das in der Starterwahl weiterläuft.

## Ablauf
| # | Bild | Dauer | Text | Musik / Ton |
|---|---|---|---|---|
| 1 | Kaltstart: schwarz, blinkender Cursor, dann tippt das Terminal den NEST hoch (alle 6 Zonen, auf zwei Zeilen) | 7 s | (Terminal) | Ticks, keine Musik |
| 2 | **Kamerafahrt** über den NEST: Cache-Wiesen, Vulkan, Kühlwasser-See, Sümpfe, Hochspannungs-Steppe, am Ende der Kern-Turm (seit 06.10.2026 alle 6 Zonen, ein Takt je Zone). 20 Glitchlinge mit Idle-Animation, Datenfunken im Vordergrund | 15 s | „Tief im Netz lag der NEST …“ | ruhig, Flöte + Glockenspiel (C-Dur) |
| 3 | **Der Fehler**: Das Turm-Leuchtfeuer flackert rot, hinter dem Turm steigt der **Ur-Glitch als Silhouette** auf (nur Umriss und glühende Augen). Rote Korruption frisst sich ins Bild, die Glitchlinge zittern | 7,5 s | „Doch im Kern erwachte ein Fehler …“ | Blech in a-Moll, Pauken bauen auf, Warntöne |
| 4 | **Absturz**: Weißblitz, SYSTEMABSTURZ mit Farbversatz, dann schrumpft das Bild wie ein alter Röhrenmonitor zu einer Linie und einem Punkt | 2,5 s | – | ein Schlag, dann Stille |
| 5 | **Flucht**: 8 Glitchlinge sammeln sich und schießen als Lichtspuren in alle Richtungen davon; danach tauchen Bugsy, Bytewurm, Glitchmotte und Glitchspinne auf | 7,5 s | „Die Glitchlings flohen …“ | treibend mit Schlagzeug, Wusch je Flucht |
| 6 | **Title Drop**: GLITCHLINGS schlägt mit Weißblitz, Schockwelle und Funken ein. „Brüten. Fusionieren. Prägen.“ Später läuft ein roter Riss über das Logo | 5 s | – | Hauptthema (Blech + Streicher) |
| 7 | **Gewitternacht**: Zimmer, Regen am Fenster, Doppelblitz, langsamer Kameraschwenk. Ein Ei fällt aus einem Datenspalt auf den Desktop, der Mauszeiger wandert hin | 8,5 s | „In einer stürmischen Nacht …“ | `intro` beginnt, Donner, Plopp |
| 8 | **Das Ei**: Herzschlag-Pulsen (doppelt, immer schneller), drei Risse, Lichtstrahlen, Weißblende zur Starterwahl | 9 s | „Du bist jetzt Operator …“ | Herzschlag-Ticks, Risse, Aufladen |

## Technik
- `MusicSynth`: Abschnitte können jetzt Lead, Bass, Begleitung, Stabs und Schlagzeug überschreiben (`"drums": "timp_build"` usw.). Akkord `"-"` bedeutet stiller Takt, `"oneshot": true` heißt keine Schleife und der Ausklang bleibt erhalten.
- `Music.seek()`: Beim Weiterblättern springt die Musik an die passende Stelle.
- Die Augen des Ur-Glitch werden aus seinem Sprite gelesen (helle Pixel im Augenbereich) und in der Silhouette rot nachgezeichnet.

## Ideen
- Gemalte Schlüsselbilder (PixelLab) für Panorama oder Zimmer wären möglich; aktuell ist alles prozedural gezeichnet.
- Die Starterwahl könnte als „drei Signale aus dem Ei“ inszeniert werden.

## Umbau auf 6 Zonen (06.10.2026)
Wunsch des Produzenten: Im Intro sollen alle 6 Zonen vorkommen.

- **Weltstreifen** (`cinema_canvas.gd`, `WORLD`): 6 Zonen à 640 px, die Kamera fährt bis 3200 px, der Kern-Turm steht bei 3520 px.
- **Neue Bewohner:**
  - See: Tröpfel (vorher in den Sümpfen), Bachli, Kaskadi, Perlhopp
  - Steppe: Plapperli (fliegt), Blinki, Zackdachs, Overclocko
  - Die Bewohner von Sümpfen und Kern sind entsprechend nach rechts gerückt.
- **Musik:** Der Abschnitt „world“ im Stück `opening` hat jetzt 6 statt 4 Takte (C, Am, F, C, Dm, G), also 15 s, und bleibt taktgenau zu den Bildern.
- **Startzeilen:** Das Terminal nennt alle 6 Zonen auf zwei Zeilen. Das erste Bild dauert dafür 7 statt 6 s.
- **Ende:** Die Heilungswelle fährt über denselben Streifen zurück. Die Datenblumen reichen jetzt über alle 6 Zonen. Die Dauer bleibt 10 s, damit die Musik passt, die Kamera fährt deshalb etwas schneller.
