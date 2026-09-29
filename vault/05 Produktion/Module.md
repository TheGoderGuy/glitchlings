---
tags: [produktion, gameplay, godot]
---
# Module (29.09.2026)

Passive Gegenstände, die **nur für den laufenden Run** gelten – wie Relikte in Slay the Spire. Sie machen jeden Run anders und ermöglichen Builds (z. B. Brand-Build mit Überhitzer, Schnell-Evolution mit Prisma).

**Quellen**
- **Elite-Gegner**: jeder Sieg gibt ein zufälliges Modul (Gewicht Gewöhnlich 3 / Selten 4 / Episch 2), Anzeige in der Chipwahl unter den Karten.
- **Datenhändler**: ein Modul im Angebot (45 / 70 / 100 Fragmente).
- **Ereignis „Modulkapsel“** (alle Zonen): einbauen oder für 25 Fragmente ausschlachten.
- Keine Doppelten; sind alle Module da, gibt es Fragmente.

**Anzeige**: Symbole (14×14, Rahmen = Seltenheit, Piktogramm = Modulfarbe) im Kampf neben den Buffs, auf der Karte, in Räumen; Namen und Beschreibungen in der Pause (Karte und Kampf).

| Modul | Seltenheit | Wirkung |
|---|---|---|
| Verstärker | Gewöhnlich | Chip-Treffer machen +3 Schaden. |
| Schnelllader | Gewöhnlich | Chips laden 15 % schneller. |
| Startsignal | Gewöhnlich | Die Signatur-Leiste startet jeden Kampf zu einem Viertel gefüllt. |
| Panzerplatte | Gewöhnlich | Jeder Treffer gegen dich macht 2 Schaden weniger. |
| Sammler | Gewöhnlich | +30 % Fragmente aus Kämpfen. |
| Lebensbit | Gewöhnlich | Nach jedem Sieg heilst du 8 HP zusätzlich. |
| Schleimschuhe | Gewöhnlich | Schleim bremst dich nicht, Lava schadet dir nur halb so viel. |
| Rabattchip | Gewöhnlich | Beim Datenhändler ist alles 25 % billiger. |
| Überhitzer | Selten | Brand verursacht doppelten Schaden. |
| Giftkapsel | Selten | Gift verursacht 50 % mehr Schaden. |
| Kältekern | Selten | Einfrieren und Betäuben halten 50 % länger. |
| Elementlinse | Selten | Element-Vorteil macht doppelten statt 1,5-fachen Schaden. |
| Dornenpanzer | Selten | Wirst du getroffen, erleidet der Gegner 6 Schaden. |
| Reflexbooster | Selten | Du bewegst dich 25 % schneller. |
| Prisma | Selten | Element-Chips prägen doppelt: Evolution kommt schneller. |
| Kondensator | Selten | Die Signatur-Leiste lädt 30 % schneller. |
| Notschild | Selten | Jeder Kampf beginnt mit einer Blase, die 20 Schaden abfängt. |
| Suchalgorithmus | Selten | Bei jeder Chipwahl ist mindestens ein seltener oder epischer Chip. |
| Backup-Kern | Episch | Einmal pro Run: Statt zu verlieren kämpfst du mit 30 % HP weiter. |
| Kritbit | Episch | 20 % Chance auf doppelten Schaden. |
| Saugbit | Episch | Heilt 1 HP pro 10 Schaden, den du austeilst. |
| Echochip | Episch | Jeder 4. Chip wird doppelt ausgelöst. |

Code: `GameData.MODULES`, `RunState.has_mod()`, Hooks in `battle_state.gd`. Tests prüfen jede Wirkung.

**Offen / Ideen**: Balancing nach dem Anspielen (Backup-Kern und Echochip könnten zu stark sein), Modul-Synergien mit den neuen Chips, evtl. Start-Modul je Monsterlinie.
