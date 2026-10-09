---
tags: [produktion, spieltest, kampf, musik, godot]
---
# Spieltest 2026-10-09 (Produzent, Neustart von Grund auf)

Der Produzent hat das Spiel komplett zurückgesetzt und von vorn gespielt. Seine fünf Punkte und was daraus wurde:

## 1. Firewall: grünes Hexagon statt brennender Mauer
- Der Schild des Chips **Firewall** ist jetzt ein **grünes Hexagon um den Glitchling**. Es hat eine halbtransparente Füllung, einen inneren Ring, helle Ecken und einen Lichtpunkt, der am Rand entlangläuft.
- Die Größe passt sich der Figur an (Baby klein, Ultra groß). Vorher gab es eine Mauer mit Flammen, die nach Feuer aussah, obwohl Firewall ein Code-Chip ist.
- Code: `battle_view._draw_shield`, Zweig `firewall`.

## 2. Cache-Wiesen: Dornenranken als Zonen-Effekt
- Jede Zone hat jetzt ihre Fläche: Lava (Vulkan), Strömung (See), Schleim (Sümpfe), Spannungsfelder (Steppe) und neu **Dornenranken (Cache-Wiesen)**.
- **Regel:** Wer in ein Dornenfeld läuft oder von einer Strömung hineingespült wird, verliert die Hälfte des Gegnerschadens. **Stehenbleiben und Herauslaufen kosten nichts.** Lava bestraft also Stehenbleiben, Dornen bestrafen Hineinlaufen: eine neue Art, die Bewegung zu planen. Dauer 5 s.
- Wer macht Dornen: Bytewurm und Chiffrekäfer (Muster `thorn`), der Wächter Dornwurz, die Kernelmantis ab Phase 2 (Muster und Diener). Bugsy (Training) nicht, das Training bleibt unverändert.
- Aussehen: Triebe brechen als Warnung aus dem Boden, danach grüne Ranken mit Dornen, roten Beeren und erdigem Untergrund, die sich wiegen.
- Die Sternwal-Linie (Passiv Sternenmeer) schwebt wie über alle Flächen auch über die Dornen.
- Code: `BattleState.HAZARD_DUR/HAZARD_COL["thorn"]`, `THORN_DMG`, `_enter_cell()`, `battle_view._draw_thorn_patch`.

## 3. Betäubte Bosse nehmen doppelten Schaden
- Ist ein **Boss oder Wächter** betäubt, eingefroren oder überlastet (`e.frozen > 0`), nimmt er **doppelten Schaden** (`GameData.STUN_MULT`). Das gilt auch für Brand und Gift.
- Der Konter-Treffer selbst zählt nicht doppelt (seine Betäubung beginnt erst mit ihm), aber jeder weitere Treffer in der Betäubung.
- Anzeige: ein pulsierendes **„x2“** über dem Boss, Schadenszahlen in Gold mit „x2“.

## 4. Entwicklung schneller
- **Dritter Durchgang („Champion zu Ultra dauert noch ein wenig lange“): Ultra bei 550.** Simulation, Reise ab frischem Champion (200): Ultra noch in derselben Reise bei 800 in 1 von 26, bei 600 in 8, bei 500 in 13 Reisen. Bei 550 wird ein Glitchling, der in der ersten Reise Champion wird, in der zweiten Reise Ultra.
- **Labor:** Sind zwei Monster für die Fusion gewählt, springt die Auswahl automatisch auf „Fusionieren“.
- **Nachtrag (zweiter Durchgang, „dauert immer noch zu lange“):** jetzt **15 / 200 / 800**. Simulation, 26 erste Reisen eines frischen Babys (ca. 355 Element-Chips je Reise):

| Schwellen | Champion in der 1. Reise | Ultra nach |
|---|---|---|
| 18 / 650 / 1950 | 1 von 26 | 5–6 Reisen |
| 15 / 300 / 1000 | 13 von 26 (Akt 3–4) | ca. 3 Reisen |
| **15 / 200 / 800** | **24 von 26 (ab Akt 3)** | **2–3 Reisen** |

  Siegquote kaum verändert (21 statt 20 von 26). Ausprobieren: `balance_sim.tscn -- --stage=1 --set=EVO_AT:15,200,800`.
- Erster Schritt (verworfen):
- Die Schwellen für Element-Chips sinken von 25 / 900 / 2700 auf **18 / 650 / 1950** (`GameData.EVO_AT`).
- Die Deutung von „Element-Chips dauern sehr lange“ als Entwicklungsschwellen ist mit dem Produzenten noch zu bestätigen.
- Mit ca. 300–400 Element-Chips je Reise (Simulation) heißt das: Champion nach etwa 2 Reisen, Ultra nach etwa 5–6 (vorher etwa 7–8).

## 5. Kette: gleiches Element hintereinander bis 4-fach
- Angriffs-Chips **desselben Elements hintereinander** machen mehr Schaden: 1. Chip ×1, dann ×1,5, ×2, ×3 und ab dem 5. Chip **×4** (`GameData.CHAIN_MULT`).
- **Neutrale** Chips und Support zählen nicht und unterbrechen nicht.
- Die Kette endet durch ein anderes Element, einen Treffer gegen dich (Schilde und Ausweichen schützen die Kette) oder 4 s ohne Element-Angriff (`CHAIN_GAP`).
- Anzeige: „Kette x3“ in Elementfarbe links über dem Spielfeld mit ablaufender Zeitleiste, dazu „Kette x2“ als Einblendung am Glitchling.
- Passt zum Kern „Spielweise bestimmt die Evolution“: Wer sich auf ein Element festlegt, wird belohnt.

## 6. Musik: Intro und Idle einheitlich
- Station (Idle), Starterwahl nach dem Intro, Kino-Intro und Abspann spielten die Melodie mit der weichen Flöte. Die epischen Stücke (Titel, Kampf, Boss, Trailer) nutzen Streicher, Blech und Chor.
- Neu: Melodiestimme **Streicher** mit Glockenspiel-Glanz eine Oktave höher (`_lead("strings")`), Chor und Blech-Gegenstimme. Melodien und Taktlängen bleiben, die Kino-Szenen bleiben also taktgenau.
- Die Kartenstücke (Wiesen, Sümpfe, See, Kern) spielen weiterhin mit Flöte. Umstellen ginge genauso, falls gewünscht.
- Nicht selbst angehört (Claude kann keine Musik hören), nur die Lautstärke geprüft.

## Balancing (Simulation, 26 Reisen je Stufe, Mensch-Bot)
| Stufe | Boss/Wächter vorher > jetzt | normaler Kampf | Siege vorher > jetzt |
|---|---|---|---|
| Baby | 56,6 > 41,3 s | 17,2 > 17,6 s | 15 > 19 |
| Rookie | 55,6 > 37,6 s | 16,5 > 15,1 s | 22 > 20 |
| Champion | 49,9 > 34,3 s | 14,9 > 13,7 s | 24 > 25 |
| Ultra | 40,4 > 24,6 s | 13,3 > 12,5 s | 23 > 25 |

Bosskämpfe werden etwa ein Drittel kürzer (der Bot kontert und weicht viel aus). Normale Kämpfe ändern sich kaum, weil der Bot gemischte Decks spielt. Menschen mit reinen Element-Decks werden durch die Kette deutlich schneller sein. **Beim nächsten Spieltest beobachten.** Falls Bosse zu leicht werden: `GameData.BOSS_HP` anheben (1,3 > ca. 1,6).

## Tests
`test_feedback_battle` (Kette, x2, Dornen, Schwellen). Bestehende Schadenstests messen jetzt ohne Kette bzw. ohne Boss-Betäubung. 400 Prüfungen.

## Teil 2: Module, Training, Zertreten
### Module besser erkennbar
- **Im Kampf:** Modul-Symbole doppelt so groß (28 px) in einer eigenen Zeile unter den Zuständen, höchstens 6 (dann „+N“). **Wirkt ein Modul, leuchtet sein Symbol weiß auf und springt kurz hoch, darunter steht sein Name** (z. B. Kritbit beim Krit, Verstärker bei jedem Treffer, Backup-Kern beim Retten). Grundlage: `BattleState.mod_ping(id)` an allen Stellen, an denen ein Modul wirkt, `mod_fx`/`mod_last`.
- **Neues Modul:** Nach Elite, Glitch-Elite, Wächter und Boss erscheint vor der Chipwahl ein eigenes Fenster **„Neues Modul!“** mit großem Symbol (3-fach), Name, Seltenheit, „wirkt für den ganzen Run“ und Wirkung. Weiter mit Bestätigen. Vorher stand es nur als Zeile unter den Chipkarten.
- `_draw_module_icon(id, pos, s)` ist jetzt skalierbar. Screenshot: `--mode=pick --elite --newmod=kritbit --reveal`.

### Zertreten
- **Bisher gab es keine Belohnung**, nur keinen Schaden (wer nicht zertritt, bekommt 15).
- **Neu:** Zertreten lädt die Signatur-Leiste um 15 (wie „Überlastet“), Einblendung „+Signatur“ (`BattleState.STOMP_SP`, Zähler `stomps`). So lohnt es sich, hinzulaufen statt nur auszuweichen. Steht auch im Handbuch.

### Training: 12 statt 9 Lernschritte
Bewegen > Angriff 1 > Angriff 2 > Ausweichen > Konter > Schützen > Element-Vorteil > **Kette** > Großangriff > **Zertreten** > **Dornenranken** > Signatur > frei kämpfen.
- **Kette:** Beide Angriffs-Slots bekommen Blitzcursor, drei Elektro-Angriffe hintereinander (Anzeige „Kette (n/3)“).
- **Großangriff:** Der Text nennt jetzt auch den doppelten Schaden an betäubten Bossen.
- **Zertreten:** Eine Bitmilbe erscheint (6 s Zeit). Platzt sie, kommt eine neue. Zertreten lädt die Signatur.
- **Dornenranken:** Ziel-Feld in der gegenüberliegenden Ecke („Ziel“, leuchtet). Zwei Dornenfelder liegen im naheliegenden Weg, ein freier Weg bleibt immer offen (Breitensuche wählt die Dornen). Hineinlaufen tut weh, verlieren kann man nicht.
- Screenshot: `--mode=tutorial --tutstep=chain|stomp|thorn`.

Tests: Training spielt alle 12 Schritte durch, Module leuchten/verblassen, Zertreten gibt Signatur. 405 Prüfungen.
