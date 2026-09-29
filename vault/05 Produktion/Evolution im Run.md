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

Offen: Blinzel-Frames der neuen Champions. Ultras: siehe unten.

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

## Ultras (Stufe 4, 96 px) – 29.09.2026
Jeder der 21 Champions hat jetzt ein Ultra (PixelLab Pro Flash, Stilreferenz Pyrolynx, auf 32 Farben reduziert). **Ab 80 Element-Chips** (über alle Runs) entwickelt sich ein Champion zu seinem Ultra, +10 HP, neue Signatur-Attacke. Die Richtung ist ab dem Rookie festgelegt – für Champion und Ultra zählt nur noch die Gesamtzahl der Element-Chips.

| Champion | Ultra | Element | Signatur |
|---|---|---|---|
| Glutluchs | Pyrolynx | Feuer | Dreischweif-Inferno: Reihe 3 × 28 + Brand |
| Bollwerkatz | Bastionkatz | Code | Bastionssprung: 70, betäubt 1,5 s, Schild 8 s |
| Toxipanth | Venomynx | Virus | Dreigiftschweif: Feld 3 × 25 + sehr langes Gift |
| Prismalynx | Aurorlynx | Elektro | Polarlicht: Feld 60, heilt 50 |
| Magmawulf | Glutfenrir | Feuer | Fenrirbrand: 2 × 45 + langer Brand |
| Turbowulf | Hyperwulf | Code | Hyperschub: lädt alle Chips, übertaktet 10 s, 4 × 20 |
| Tsunamander | Leviamander | Wasser | Leviathanflut: Feld 75, friert 2 s ein |
| Panzerpuff | Kolosspuff | Code | Kolossblase: Blase 120 (10 s) + Feld 35 |
| Glaziolotl | Kryolotl | Wasser | Absoluter Nullpunkt: Feld 55, 4 s eingefroren |
| Schattnager | Phantomnager | Virus | Phantomfalle: Backentasche, 4 Minen, 2 Schatten, 35 |
| Glanzbacke | Stellarbacke | Elektro | Sternenkeks: Backentasche, heilt 60, 30 |
| Holohas | Quantenhas | Code | Quantenarmee: 4 Abbilder (12 s) + 40 |
| Strahlhase | Plasmahase | Elektro | Plasmasturm: 4 × 25 |
| Toxikröt | Miasmakröt | Virus | Miasma: Feld 40 + extrem langes Gift |
| Mechaquak | Gigaquak | Code | Gigasprung: 85, betäubt 2,5 s |
| Sumpfdrak | Hydradrak | Virus | Dreikopfatem: Reihe 3 × 30 + Gift |
| Lavadrak | Vulkandrak | Feuer | Eruption: Feld 55 + langer Brand |
| Sonnenpranke | Supernovabär | Elektro | Supernova: 75, heilt 55 |
| Titanbrumm | Kolossbrumm | Code | Kolossfäuste: 2 × 55, betäubt 2 s |
| Phönixkauz | Infernokauz | Feuer | Infernosturz: 85 + langer Brand |
| Radarkauz | Orbitkauz | Code | Orbitalschlag: 40, nächste 8 Treffer +50 % |

Zwei Entwürfe wurden neu generiert: **Bastionkatz** hatte einen Burgturm auf dem Rücken (verstößt gegen „keine Gegenstände als Körper“), **Phantomnager** sah wie eine Katze aus (jetzt klar Ratte). Der Monsterdex ist jetzt nach Linien sortiert (Baby → Rookies → Champions → Ultras, Fusionen am Ende) und hat 76 Einträge; 96er-Sprites werden oben an der Kachel abgeschnitten.

**Blinzel-Frames (29.09.2026):** alle Champions und Ultras (+ Bärtron) blinzeln. Augenboxen in `tools/sprites/blink_boxes.json`, von Hand am vergrößerten Kopf gesucht; Tier-Augen per `png2spr.js --blink` (Lid), leuchtende Mech-/Drachenaugen per `dim_blink.js` (kurz abgedunkelt). Toxmolch hat noch keinen, sein Auge ist nicht eindeutig.

Offen: Balancing der Ultra-Signaturen nach dem Anspielen (80 Element-Chips ≈ 3–4 Runs mit einem Monster).
