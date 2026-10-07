---
tags: [produktion, endgame, godot]
---
# Glitch-Protokolle (07.10.2026)

Endgame nach dem Abspann, Wahl des Produzenten aus mehreren Endgame-Ideen. Freiwillige Zusatzregeln für Profis, ähnlich wie Ascension in Slay the Spire.

## Regeln
- **Freischalten:**
  - Stufe 1 wird mit dem Sieg über den Ur-Glitch frei.
  - Wer einen Zonen-Boss auf der höchsten freien Stufe besiegt, schaltet die nächste frei, bis Stufe 10.
- **Wählen:** In der Zonenwahl mit Hoch/Runter (0 = aus). Die Wahl bleibt gespeichert. Auf der Karte steht „Protokoll N“.
- **Belohnung:**
  - Jede Stufe bringt +5 % Fragmente.
  - Der Glitchling bekommt ein **Protokoll-Abzeichen** mit seiner besten Stufe. Es steht im Team-Reiter unter Runs und Siegen.
- Die Stufen **bauen aufeinander auf** und lassen sich mit jeder Schwierigkeit kombinieren.

| Stufe | Name | Regel |
|---|---|---|
| 1 | Zähe Daten | Gegner +15 % HP |
| 2 | Kurze Rast | Rastplätze heilen nur halb so viel |
| 3 | Unruhe | Gegner greifen 10 % schneller an |
| 4 | Knappe Kasse | Händlerpreise +25 % |
| 5 | Starke Wächter | Wächter und Bosse +20 % HP |
| 6 | Hektik | Warnungen 0,1 s kürzer |
| 7 | Angeschlagen | Start mit 15 % weniger max. HP |
| 8 | Harte Treffer | Gegner verursachen +15 % Schaden |
| 9 | Zähe Flächen | Lava, Schleim, Strömung und Spannungsfelder halten 50 % länger |
| 10 | Glitch-Sturm | Großangriffe kommen 30 % öfter |

## Technik
- Daten: `GameData.PROTOCOLS`.
- Run:
  - `RunState.protocol` (wird mit dem Run gespeichert)
  - Wirkung in `_apply_difficulty`, `rest_heal()`, `apply_protocol()` (max. HP), `Rooms.price()` und der Flächendauer im `BattleState`
- Spielstand:
  - `SaveGame.protocol_unlocked()`, `protocol_choice()`
  - `protocol_max`, `protocol_sel`, je Monster `protocol_best`
- Screenshot: `--mode=station --zones --protocol=N`.
- Tests: alle Regeln, das Freischalten und das Abzeichen. **333 Prüfungen.**

## Offen
- Balancing ab Stufe 7 nach echten Spieltests. Der Autopilot spielt bisher ohne Protokoll.
