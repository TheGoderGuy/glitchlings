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

## Ende (`ending_view.gd`, ca. 55 s, überspringbar)
1. Terminal wie im Opening: „Ur-Glitch … defragmentiert · Korruption: 0 % · NEST-Server … Neustart · Bewohner … zurück · Status: alles friedlich“
2. Rückkehr: Pixelspuren fliegen herein und werden wieder zu den sechs Babys (umgekehrte Flucht aus dem Opening)
3. Dein Team (aktuelles Monster + Team, bis 5) mit Pixel-Konfetti – „Danke, Operator.“
4. Abspann mit Parade von Ultras am unteren Rand
5. „ENDE“ – Hinweis auf die neue Schwierigkeit
- Musik **„ending“**: das Thema aus dem Opening, jetzt hell mit Blech und Schlagzeug.
- Danach die normale Auswertung („Der NEST ist gerettet!“), dann die Station. Titel zeigt „* NEST gerettet *“.

## Nach dem Ende
- Alles bleibt spielbar (Dex vervollständigen, Ultras, Fusionen, Ur-Glitch erneut).
- **Schwierigkeit „Korrumpiert“** (Optionen, erst nach dem Ende wählbar): Gegner-HP ×1,5, Schaden ×1,4, Warnungen 0,15 s kürzer, **Fragmente ×1,5**.

## Offen
- Abspann-Namen prüfen/anpassen (Produktion: TheGoderGuy).
- Eigene Ereignisse im NEST-Kern (z. B. Erinnerungsfragmente des NEST mit Lore).
- Autopilot gewinnt fast immer – echtes Anspielen nötig, ob der Ur-Glitch fordernd genug ist.
