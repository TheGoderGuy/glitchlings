---
tags: [produktion, zone, boss, story, godot]
---
# Finale und Ende (29.09.2026)

Entscheidung Produzent: **kurze Finalzone + Ur-Glitch als Endboss + Ende mit Abspann, danach weiterspielen, dazu die neue Schwierigkeit „Korrumpiert“.**

## Zone 4: NEST-Kern
- Wird frei, sobald die Schwarmkönigin (Viren-Sümpfe) besiegt ist. **4 Etagen + Boss** (die anderen Zonen haben 7), letzte Etage immer Rast.
- Gegner 60 % zäher (`hp_mult` 1,6), Pools mischen die harten Gegner aller Zonen:

| Gegner | Element | HP | Muster | Aussehen |
|---|---|---|---|---|
| **Kerndrohne** (neu) | Code | 120 | Zwei Spalten, Kreuz | schwebende Wach-Drohne mit großem Linsenauge |
| **Glitchspinne** (neu) | Virus | 95 | Wand, Feld, Reihe; teleportiert | Spinne aus zerbrochenen Daten, Augen-Cluster |
| dazu | | | | Brandmauerassel, Panzerschnecke, Glitchblüte, Saugmücke, Datenwespe |

- Musik: `map_kern` (c-Moll, 100 BPM, Flöte + Pluck-Arpeggio). Im Kampf läuft die ursprüngliche, „epische“ Kampfmusik – als Rückruf an den Anfang.
- Hintergrund: dunkles Blau mit Cyan-Kante, Boss-Variante violett-rot; in Räumen steigen Datenbits auf.

## Endboss: Ur-Glitch – *Der Fehler, der den NEST zerbrach*
- Drache aus zersplitterten Daten (96 px, PixelLab, zwei Varianten verglichen, die mit hellem Chaoskern genommen). 680 HP, 19 Schaden.
- **Wechselt alle 7 s das Element** (Virus, Feuer, Wasser, Elektro, Code; in Phase 3 schneller). Anzeige oben rechts, schwebender Text „Jetzt Feuer!“ und Hinweis in der Statuszeile, welches Element jetzt stark ist (Wasser gegen Feuer usw.). Eigener Sound „shift“.
- Ab halber HP Diener **passend zum Element**: Feuer → Lava, Virus → Schleim, Code → Bitmilben, sonst Glitch-Sporen.
- Eigenes Boss-Intro mit Glitch-Streifen und eigene Musik **„finale“** (e-Moll, 184 BPM).

## Ende (`ending_view.gd`, Kino-Ende seit 30.09.2026, ca. 69 s, überspringbar)
Spiegelt das Kino-Intro (`vault/05 Produktion/Opening-Szene.md`): Kinobalken, Kamerafahrt, taktgenaue Musik. Gemeinsame Werkzeuge (Welt, Turm, Korruption, Zimmer, Kinobalken) liegen in `scripts/ui/cinema_canvas.gd`.

| # | Bild | Dauer | Text | Musik / Ton |
|---|---|---|---|---|
| 1 | **Zerspringen**: Der Ur-Glitch zittert, Risse wachsen, er zerbricht in Pixelsplitter, die zu Licht verglühen (Schockwelle, Weißblitz) | 3 s | – | Stille nach der Bossmusik, Treffer, Überlastung |
| 2 | **Neustart**: Terminal wie im Opening („Ur-Glitch ... defragmentiert · Korruption: 0 %“ …) | 6 s | (Terminal) | Ticks |
| 3 | **Heilung**: Kamerafahrt rückwärts vom Kern-Turm zu den Wiesen, eine helle Welle frisst die rote Korruption, dahinter sprießen Datenblumen | 10 s | „Der Fehler war gelöscht …“ | Weltthema aus dem Opening (C-Dur) |
| 4 | **Heimkehr**: 8 Lichtspuren kommen aus den Fluchtrichtungen des Openings zurück und werden wieder Babys, am Ende hüpfen alle | 7,5 s | „Aus allen Geräten kehrten …“ | Blech, Schlagzeug |
| 5 | **Dein Team**: Kamera fährt hoch, Morgenlicht, Konfetti-Ausbruch | 7,5 s | „Und mittendrin: dein Team …“ | Hauptthema mit Gegenstimme |
| 6 | **Zimmer am Morgen**: Regenbogen statt Gewitter, dein Glitchling sitzt neben der Eierschale auf dem Desktop, der Mauszeiger streichelt es, ein Herz steigt auf | 7,5 s | „Der Sturm ist vorbei …“ | ruhig |
| 7 | **Title Drop**: GLITCHLINGS, diesmal mit goldenem Glanz statt rotem Riss, „Der NEST ist wieder online.“ | 5 s | – | Schlag + Akkord |
| 8 | **Abspann** (kurz, 2 Karten): „Ein Spiel von TheGoderGuy“ mit allen Rollen in zwei Zeilen; dann PixelLab, Schriften (OFL), Godot, Dank. Unten läuft die Ultra-Parade | 15 s | – | Thema aus `intro` |
| 9 | **ENDE**: Hinweis auf „Korrumpiert“, dein Glitchling, daneben wackelt ein neues Ei | 7,5 s | – | Schlussakkord |

- Musik **„ending“** (96 BPM, One-Shot, 24 Takte = 60 s ab Bild 3). Beim Weiterblättern springt sie mit (`Music.seek`). Test prüft, dass Takte und Bilder zusammenpassen.
- Name im Abspann: `CREATOR` in `ending_view.gd`, Rollen in `ROLES`, zweite Karte in `THANKS`.
- Screenshot: `--mode=ending --t=<Sekunde> [--form=…]`; Video: `godot --path game --write-movie build/Glitchlings_Ende.avi --fixed-fps 30 -- --play=ending`
- Danach die normale Auswertung („Der NEST ist gerettet!“), dann die Station. Titel zeigt „* NEST gerettet *“.

## Nach dem Ende
- Alles bleibt spielbar (Dex vervollständigen, Ultras, Fusionen, Ur-Glitch erneut).
- **Schwierigkeit „Korrumpiert“** (Optionen, erst nach dem Ende wählbar): Gegner-HP ×1,5, Schaden ×1,4, Warnungen 0,15 s kürzer, **Fragmente ×1,5**.

## Offen
- [x] Abspann (30.09.2026 gekürzt): eine Karte „Ein Spiel von TheGoderGuy“ mit allen Rollen, eine Karte mit Werkzeugen und Dank.
- Eigene Ereignisse im NEST-Kern (z. B. Erinnerungsfragmente des NEST mit Lore).
- Autopilot gewinnt fast immer – echtes Anspielen nötig, ob der Ur-Glitch fordernd genug ist.
