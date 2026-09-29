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

## Neue Champions (29.09.2026, PixelLab mit Rookie als Referenz)
Jeder Rookie hat jetzt einen Champion (Ausnahme: keine). Namen geprüft (Blitzhas/Toxidrak verworfen: zu nah an Blitza/Toxiquak).

| Rookie | Champion | Element | Signatur |
|---|---|---|---|
| Virulina | Toxipanth | Virus | Giftsprung: 50 + starkes Gift |
| Prismiez | Prismalynx | Licht | Prismastrahl: Feld 45, heilt 30 |
| Frostbyte | Glaziolotl | Wasser | Gletscherwelle: Feld 45, friert 3 s ein |
| Tracko | Schattnager | Virus | Schattenfalle: Backentasche, 3 Minen, 20 |
| Cachy | Glanzbacke | Licht | Sonnenkeks: Backentasche, heilt 45, 20 |
| Blinki | Strahlhase | Licht | Lichtgewitter: 4 × 20 |
| Virulurch | Toxikröt | Virus | Seuchenwolke: Feld 30 + sehr langes Gift |
| Toxmolch | Sumpfdrak | Virus | Sumpfatem: Reihe 45 + Gift |
| Magmolch | Lavadrak | Feuer | Lavaflut: Feld 40 + langer Brand |
| Sonnbrumm | Sonnenpranke | Licht | Sonnenschlag: 55, heilt 40 |
| Raketauz | Phönixkauz | Feuer | Phönixsturz: 60 + Brand |

Offen: Blinzel-Frames der neuen Champions, Ultras (96 px).

## Überarbeitung 29.09.2026 (Feedback: „Pixmiez wird immer Firewallo, obwohl ich viel Elektro nutze“)
**Befund:** (1) Pixmiez hatte keine Licht-/Elektro-Richtung, Licht-Chips wurden ignoriert – ein einziger Firewall (Code) im Startdeck entschied. (2) Die Schwelle zählte auch neutrale Chips → Evolution mitten im ersten Run nach 1–3 Element-Chips. (3) Startdecks legten die Richtung fest. (4) Gleichstand entschied die Listenreihenfolge. (5) Nirgends sichtbar, welche Richtungen es gibt.

**Neue Regeln:**
- Element **„Licht“ heißt jetzt „Elektro“** (Chips Blitzcursor, Blitzlanze, Blendgranate, neu **Kurzschluss**). **Heilpatch ist neutral.**
- **Pixmiez: Elektro → Prismiez** (vorher nur geheimer Weg).
- **Nur Element-Chips prägen und zählen:** Rookie ab **12**, Champion ab **35** Element-Chips (über alle Runs).
- **Klare Führung:** Die führende Richtung braucht **2 Chips Vorsprung** vor der zweitbesten, sonst wartet die Evolution („Führung zu knapp“ / „Gleichstand“). Elemente ohne Richtung zählen zur Schwelle, lenken aber nicht.
- **Startdecks:** überwiegend neutral + **genau ein Chip je Richtung** → die Spielweise entscheidet.
- **Anzeige** auf Karte, in der Station und in der Chipwahl: Balken je Richtung (Form, sobald im Dex), „Ohne Wirkung: …“, Status. Chipwahl-Karten zeigen „Prägt > Feuer-Form“ bzw. „Ohne Wirkung auf …“.

**Simulation (gezielter Spieler, 6 Durchläufe je Wunsch):** Pixmiez→Elektro 4/6, Pixmiez→Feuer 5/6, Funkling→Code 5/6, Kekso→Virus 5/6, Brummbit→Code 5/6; kein Monster bleibt Baby. Der Autopilot spielt dabei *alle* Chips – echte Spieler steuern zusätzlich, welche sie einsetzen.
