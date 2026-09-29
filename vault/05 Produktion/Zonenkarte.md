---
tags: [produktion, gameplay, steam]
---
# Zonenkarte (Godot, seit 28.09.2026)

Ein Run führt über eine verzweigte Karte durch eine Zone (zuerst **Cache-Wiesen**). Umsetzung: `game/scripts/run/`.

## Aufbau
- **7 Etagen + Boss**, pro Etage 2–4 Knoten (Etage 1: 3). Wege kreuzen sich nie, jeder Knoten ist erreichbar.
- Etage 1: nur Kämpfe. Letzte Etage vor dem Boss: nur Rastplätze.
- Übrige Etagen zufällig gewichtet: Kampf 45, Ereignis 22, Elite 12 (ab Etage 3), Datenhändler 11 (ab Etage 3), Rast 10 (ab Etage 4).
- Ein Weg hat im Schnitt **~5 Kämpfe** inkl. Boss (Autopilot-Simulation).

## Knoten
| Knoten | Wirkung |
|---|---|
| Kampf | Gegner aus Pool (ab Etage 3 auch Bytewurm), +7 % HP pro Etage. Sieg: +10 HP, Chipwahl (überspringbar), Fragmente |
| Elite | +60 % HP, +4 Schaden, schneller, doppelte Fragmente. Chipwahl mit Selten/Episch bevorzugt |
| Ereignis | 8 Ereignisse (Verlorenes Datenpaket, Bit-Brunnen, Flackernder Chip, Wilder Glitchling, Wartungsdrohne, Bit-Beeren, Backup-Station, Verirrter Mini-Bot), keine Wiederholung pro Run |
| Rastplatz | Ausruhen (+35 % max. HP) **oder** Deck ausdünnen (1 Chip entfernen, Deck bleibt ≥ 5) |
| Datenhändler | 3 Chips (Gewöhnlich 25 / Selten 40 / Episch 60 Fragmente), Reparatur +25 HP (20), Chip entfernen (35) |
| Boss | Kernelmantis (320 HP) |

Das Deck-Ausdünnen beantwortet die offene Frage aus Playtest 3 („Chip entfernen statt nur hinzufügen testen“).

## Offen
- Schwierigkeit: Der Autopilot gewinnt weiter 40/40 Runs – nach Playtest nachschärfen (mehr Gegnertypen, Elite-Muster).
- Nur 3 Gegner-Sprites; Elite ist vorerst nur rötlich getönt.
- Weitere Zonen (Firewall-Vulkan, Viren-Sümpfe …) mit eigenen Ereignissen und Gegnern.
