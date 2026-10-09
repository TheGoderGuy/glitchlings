---
tags: [produktion, endgame, station, godot]
---
# Herausforderungen (09.10.2026)

Endgame, Punkt 1 aus der Endgame-Einschätzung vom 08.10.2026. Bis dahin war nach dem Abspann wenig zu tun: Station-Ausbau nach ca. 5 Runs fertig, [[Glitch-Protokolle]] nur stärkere Werte, Monsterdex sehr lang. Die Herausforderungen geben **Ziele, die zu einer anderen Spielweise zwingen**. Sie passen damit zu „Die Spielweise bestimmt die Evolution“.

## Prinzip
- **Brett in der Station**, neuer Reiter **„Aufgaben“** ganz rechts. 30 Aufgaben in 5 Bereichen à 6: Reise, Kampf, Spielweise, Glitchlinge, Meister.
- **Jede Aufgabe gibt es einmal.** Geschafft = Stern blinkt, die Belohnung holt man im Reiter mit Bestätigen ab (Haken danach). Ein blinkender Punkt am Reiter und am Bereich zeigt wartende Belohnungen.
- **Belohnungen:** Fragmente (50–500), Ei oder „Ei mit neuer Art“ (eine Baby-Art, die noch fehlt). Eier brauchen einen freien Nestplatz, sonst bleibt die Belohnung liegen.
- **Kein Zeitdruck:** keine täglichen Aufgaben, nichts verfällt (Premium-Entscheidung 5).
- **Fortschritt** mit Balken bei Aufgaben mit Zielwert (z. B. 143/200 Feuer-Chips, 1/2 Glitch-Elites). Werte aus einer Reise zählen als **Bestwert**.
- **Run-Ende** meldet neu geschaffte Aufgaben („Herausforderung geschafft: … (Station > Aufgaben)“). Was außerhalb von Runs passiert (Schlüpfen, Fusion, alte Spielstände), wird beim Betreten der Station, beim Schlüpfen und bei Fusionen geprüft.
- **Testfassung** (nur Wiesen + Vulkan) blendet Aufgaben aus, die andere Zonen brauchen (`need`), dort sind es 20.
- Die geheimen Bedingungen der [[Legendäre]]n sind bewusst **nicht** als Aufgaben verraten.

## Die Aufgaben
| Bereich | Aufgabe | Bedingung | Belohnung |
|---|---|---|---|
| Reise | Erste Säuberung | Boss der Cache-Wiesen | 50 Fragmente |
| Reise | Feuer und Wasser | Bosse von Vulkan und See (über mehrere Reisen) | Ei |
| Reise | Sumpf und Steppe | Bosse von Sümpfen und Steppe | Ei |
| Reise | Retter des NEST | Ur-Glitch besiegt | 200 Fragmente |
| Reise | Viele Helden | Ur-Glitch mit 3 verschiedenen Arten | Ei mit neuer Art |
| Reise | Protokoll 3 | ganze Reise auf Glitch-Protokoll 3+ | 300 Fragmente |
| Kampf | Konterkunst | 10 Konter in einem Kampf | 100 Fragmente |
| Kampf | Felsenfest | Elite (oder stärker) ohne einen Schritt besiegen | 100 Fragmente |
| Kampf | Blitzsieg | Wächter in unter 20 s | 150 Fragmente |
| Kampf | Goldener Tänzer | in einem Bosskampf allen goldenen Großangriffen ausweichen (mind. 3) | Ei |
| Kampf | Risikofreude | 2 Glitch-Elites in einer Reise | Ei |
| Kampf | Unberührt | Wächter ohne Schaden | 150 Fragmente |
| Spielweise | Feuer-/Wasser-/Code-/Elektro-/Virusseele | 200 Chips eines Elements in einer Reise | je Ei |
| Spielweise | Leichtes Gepäck | Zonen-Boss mit höchstens 10 Chips im Deck (Überspringen lohnt sich) | 150 Fragmente |
| Glitchlinge | Erste Entwicklung / Champion / Ultra | eine Form der Stufe durch Entwicklung (Fusionen und Legendäre zählen nicht) | 50 / Ei / 300 |
| Glitchlinge | Verschmolzen | eine Fusion im Labor | Ei |
| Glitchlinge | Forscher | 40 Formen im Monsterdex | Ei mit neuer Art |
| Glitchlinge | Großfamilie | alle 13 Baby-Arten im Monsterdex | 300 Fragmente |
| Meister | Korrumpiert | Ur-Glitch auf Korrumpiert | 500 Fragmente |
| Meister | Glitch-Sturm | ganze Reise auf Protokoll 10 | 500 Fragmente |
| Meister | Kleiner Held | Boss in Akt 2 mit einem Baby (Entwicklung vermeiden!) | Ei mit neuer Art |
| Meister | Eiserne Reserve | Ur-Glitch ohne einen Heil-Chip in der ganzen Reise (Heilpatch, Neustart, Kiemenatmung) | 300 Fragmente |
| Meister | Makellos | Ur-Glitch ohne Schaden | 500 Fragmente |
| Meister | Unaufhaltsam | 3 ganze Reisen hintereinander ohne Niederlage | 500 Fragmente |

## Zielwerte geprüft
Mit der Balancing-Simulation (`balance_sim.tscn -- --challenges`, Mensch-Bot, 26 Reisen je Stufe). Erste Entwürfe waren zu leicht und wurden geändert:
- 3 Signatur-Attacken in einem Kampf schafft der Bot **immer** (Ø 16 je Kampf) > Aufgabe gestrichen.
- Kampf unter 8 s: der Bot hat fast jede Reise einen Kampf unter 5 s > jetzt **Wächter unter 20 s** (Baby 0/26, Ultra 14/26).
- 5 Konter in einem Kampf: 24/26 > jetzt **10** (3–9 von 26).
- 5 goldene Großangriffe je Reise: Ø 14–20 > jetzt **ein ganzer Bosskampf ohne Großangriff-Treffer** (8–18 von 26).
- Kampf ohne Schritt: kurze Kämpfe gewinnt man zufällig im Stand > jetzt **nur gegen Elites und stärker**.
- Element-Chips: Ø 60–110 je Element und Reise, mit Zufallswahl erreichen 1–9 von 26 die 200 > man muss sich auf ein Element festlegen.
- Der Bot weicht besser aus als Menschen (Ur-Glitch ohne Schaden in 3–5 von 26 Reisen). Im Spieltest prüfen, ob „Makellos“ und „Unberührt“ zu schwer sind.
- Nebenbefund: Manche normalen Kämpfe dauern nur 3–5 s (schnellster Sieg je Reise Ø 3–5 s). Das sollte man beim Balancing ansehen.

## Technik
- Daten: `GameData.CHALLENGES` (id, cat, name, desc, goal, need, reward), `CHALLENGE_CATS`, `HEAL_CHIPS`, `BLITZ_TIME`, `MINI_DECK`, `GOLD_DODGES`.
- Erfassung im Kampf: `BattleState._challenge_feats()` beim Sieg (Konter, Schritte `moves`, erlittener Schaden `dmg_taken`, Treffer durch Großangriffe `gold_hits`), Heil-Chips in `use_slot`, ausgewichene Großangriffe in `_special_dodged`. Werte der Reise in `RunState.ch` (wird mit dem Run gespeichert).
- Spielstand: `SaveGame._challenge_run` übernimmt die Bestwerte (`data.ch_best`), dazu `final_species` und `stats.streak`. `check_challenges()`, `challenge_progress()`, `claim_challenge()`, `evolved_stage()`. Zustand je Aufgabe in `data.challenges` (1 geschafft, 2 abgeholt).
- Station: `station_view._draw_challenges`, `_process_challenges`, Führung hat jetzt 9 Schritte. Screenshot: `--mode=aufgaben --t=<Bereich>`.
- Tests: `test_challenges` (393 Prüfungen insgesamt).
