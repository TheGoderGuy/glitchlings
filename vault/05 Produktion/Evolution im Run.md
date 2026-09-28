---
tags: [produktion, gameplay, steam, evolution]
---
# Evolution im Run (Godot, seit 28.09.2026)

Kernversprechen: **Die Spielweise bestimmt die Evolution.** Umsetzung: `RunState.try_evolve()` in `game/scripts/run/run_state.gd`, Daten in `GameData.MONS / FORMS / SPECIALS`.

## Ablauf
- Vor dem Run wählt man einen **Starter**: Pixmiez (Katze), Funkling (Welpe) oder Tröpfel (Axolotl).
- Jeder gespielte Chip zählt als **Prägung** in seinem Element.
- Nach einem gewonnenen Kampf wird geprüft: **ab 15 Prägung → Rookie**, **ab 35 → Champion** (wenn die Linie eine hat).
- Richtung = Element mit den meisten gespielten Chips unter den möglichen Richtungen der Linie. Nur neutrale Chips → noch keine Richtung.
- Sonderwege: **Prismiez** (Pixmiez, bunt gemischt: ≥ 4 Elemente, keines über 30 %), **Frostbyte** (Tröpfel, 4× Eisfeld).
- Jede Stufe: +10 max. HP, neue Signatur-Attacke, neues Sprite. Katzenreflex/Regeneration werden ab Champion stärker.
- Evolutions-Szene: Silhouetten-Wechsel, Lichtsäule, Enthüllung mit neuer Signatur.
- Karte und Chipwahl zeigen **Prägung x/Schwelle** und die **Richtung** – so wird die Chipwahl zur Evolutions-Entscheidung.

## Formen im Spiel (18)
| Linie | Rookie | Champion |
|---|---|---|
| Pixmiez | Blazebit (Feuer), Firewallo (Code), Virulina (Virus), Prismiez (geheim) | Glutluchs, Bollwerkatz |
| Funkling | Glutbyte (Feuer), Overclocko (Code) | Magmawulf, Turbowulf |
| Tröpfel | Kaskadi (Wasser), Pufferling (Code), Frostbyte (Eisfeld) | Tsunamander, Panzerpuff |

## Balancing (Autopilot, 45 Runs)
Ø 45 Chips pro Run, davon ~15 im Bosskampf. Mit 15/35: 28× Rookie, 6× Champion, 11× Baby am Ende. Menschen spielen langsamer und damit mehr Chips → eher früher.

## Größe im Kampf
Babys werden im Kampf in **Originalgröße (32 px)** gezeichnet, Rookie 64, Champion 80 – das Wachstum ist sichtbar.

## Offen
- Evolution ist pro Run (setzt sich zurück). Mit der Station (Phase 3) soll sie dauerhaft werden.
- Virulina, Prismiez, Frostbyte haben noch keinen Champion; Ultras fehlen.
