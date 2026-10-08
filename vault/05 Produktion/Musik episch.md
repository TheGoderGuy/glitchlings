---
tags: [produktion, musik, audio, godot]
---
# Epische Musik: Titel, Station, Kampf, Boss (08.10.2026)

Wunsch des Produzenten: „epische Musik, eine Titelmelodie, Idle-Musik und Kampf- sowie Bossmusik“. Alles sind eigene Kompositionen, selbst synthetisiert wie die bisherigen Platzhalter (`game/scripts/audio/music_synth.gd`).

## Die Stücke
| Stück | Datei | Läuft in | Tonart, Tempo | Charakter |
|---|---|---|---|---|
| Titelmelodie | `title_epic.wav` (70 s, Intro 10 s) | Titel, nach Bossen | D-Dur, 96 BPM | Hornruf mit Pauken (Intro), heroisches Thema mit Chor, Streicher-Ostinato und Melodie in Oktaven; Mittelteil als Aufschwung (Blechbögen über Taikos, B-Dur als geliehener Akkord). Der erste Mittelteil mit Flöte gefiel dem Produzenten nicht und wurde ersetzt. |
| Station (Idle) | `station.wav` (46 s) | Station mit allen Reitern, Zuhause | F-Dur, 84 BPM | „Heimat“-Thema: zitiert das Titelmotiv ruhig mit Flöte, Glockenspiel und leisem Chor |
| Kampf | `battle_epic.wav` (39 s, Intro 3 s) | normale Kämpfe der Wiesen (andere Zonen behalten ihre Zonenmusik) | E-Moll, 160 BPM | Blech + Rechteck-Lead, Taikos, Ostinato; Mittelteil nur mit Taikos und Chor (phrygische Wendung F-Dur) |
| Boss | `boss_epic.wav` (40 s, Intro 6 s) | Zonen-Bosse (Wächter und Ur-Glitch behalten ihre Stücke) | C-Moll, 170 BPM | dunkler Chor, neapolitanischer Akkord (Des-Dur), schwere Pauken; Mittelteil als Chor-Choral |

**Leitmotiv:** Quinte – Grundton – Terz – Quinte (Titel A4 D5 F#5 A5, Station C5 F5 A5 C6). So klingt die Station wie ein Zuhause im selben Spiel.

## Neue Klangfarben im Synthesizer
Bestehende Stücke klingen unverändert, die Optionen greifen nur, wenn ein Stück sie setzt.
- **Chor** (`choir`): vier verstimmte Sägezähne durch zwei Formantfilter („Aah“), eine Fläche je Folge gleicher Akkorde.
- **Streicher-Ostinato** (`arp: "ostinato"`): Sechzehntel in tiefer Lage (Grundton, Quinte, Oktave), kurz gestrichen (`_spiccato`).
- **Melodie in Oktaven** (`double: "strings"`), **zweite Lead-Stimme** (`lead2`), Glockenspiel abschaltbar (`glock: false`).
- **Taikos:** Schlagzeugstile `epic_title`, `epic_battle`, `epic_boss`, `taiko`, `home`; Tomhöhe je Stil (`tf`).
- Abschnitte können Lead, zweite Stimme, Chor, Schlagzeug und Begleitung einzeln überschreiben (Mittelteile).

## Einbindung und zurückwechseln
`Music.USE` in `game/scripts/audio/music.gd` ordnet zu: title > title_epic, battle > battle_epic, boss > boss_epic. Die Station spielt `station`.
- **Die alten Dateien bleiben unverändert erhalten:** `battle.wav` („episch“, 29.09.), `boss.wav` („mega“), `title.wav`.
- Gefällt eine alte Fassung besser, wird nur die Zeile in `USE` gelöscht.

**Neu rendern** (nur die genannten Stücke, die alten werden nicht angefasst):
```
godot --headless --path game --script res://tools/render_music.gd -- title_epic station battle_epic boss_epic
```

## Prüfung
- Pegel wie die alten Stücke (RMS −14 bis −17 dBFS, Spitzen ≤ −1 dBFS, keine Übersteuerung), saubere Schleifen.
- Test „Alle 17 Musikstücke …“ und „Epische Musik: …“, 364 Prüfungen.
- **Gehört hat sie bisher nur der Produzent.** Claude kann Musik nicht anhören, nur technisch prüfen. Ob sie episch genug klingt, entscheidet das Ohr.
