---
tags: [datenbank, chips]
---
# Chip-Übersicht

Alle 15 Chips des Prototyps. Neue Chips über [[Template – Chip]] anlegen.

| Chip | Kategorie | Element | Schaden | Ladezeit | Seltenheit |
|---|---|---|---|---|---|
| [[Pixelstrahl]] | Angriff | Neutral | 20 | 2,0 s | Gewöhnlich |
| [[Byteschlag]] | Angriff | Neutral | 30 | 1,5 s | Gewöhnlich |
| [[Firewall]] | Schild | Code | 0 | 4,0 s | Gewöhnlich |
| [[Bug-Mine]] | Falle | Virus | 35 | 3,0 s | Selten |
| [[Übertakten]] | Buff | Feuer | 0 | 6,0 s | Selten |
| [[Glutball]] | Angriff | Feuer | 45 | 3,0 s | Gewöhnlich |
| [[Flammenwelle]] | Angriff | Feuer | 25 | 3,5 s | Selten |
| [[Wasserstrahl]] | Angriff | Wasser | 15 | 2,0 s | Gewöhnlich |
| [[Blubberschild]] | Schild | Wasser | 0 | 4,0 s | Gewöhnlich |
| [[Eisfeld]] | Feldeffekt | Wasser | 0 | 4,0 s | Selten |
| [[Heilpatch]] | Buff | Licht | 0 | 5,0 s | Gewöhnlich |
| [[Blitzcursor]] | Angriff | Licht | 20 | 3,0 s | Gewöhnlich |
| [[Mini-Bot]] | Beschwörung | Code | 0 | 6,0 s | Selten |
| [[Virusspritzer]] | Angriff | Virus | 10 | 2,5 s | Gewöhnlich |
| [[Defrag]] | Buff | Neutral | 0 | 8,0 s | Episch |

```dataview
TABLE kategorie AS "Kategorie", element AS "Element", schaden AS "Schaden", ladezeit AS "Ladezeit"
FROM "06 Datenbank/Chips"
SORT kategorie ASC
```

Siehe auch: [[Kampfsystem]], [[Prototyp-Spezifikation]]

## Erweiterung Steam-Version (28.09.2026) – 12 neue Chips
Jetzt 27 Chips, jedes Element hat 4–5 Chips (eigene Evolutionsrichtung spielbar). Umsetzung: `game/scripts/data/game_data.gd`.

| Chip | Element | Kategorie | Seltenheit | Wirkung |
|---|---|---|---|---|
| Doppelklick | Neutral | Angriff | Gewöhnlich | 2 Projektile über deine Reihe, je 12 |
| Neustart | Neutral | Buff | Episch | +15 HP, komplett neue, sofort bereite Hand |
| Funkenregen | Feuer | Angriff | Selten | Trifft immer: 25 + Brand |
| Hitzeschild | Feuer | Schild | Gewöhnlich | Blockt nächsten Treffer (4 s), Angreifer brennt |
| Laserschuss | Code | Angriff | Gewöhnlich | Sofortiger Treffer in deiner Reihe: 25 |
| Portscan | Code | Buff | Selten | Nächste 2 Treffer +50 % |
| Strudel | Wasser | Feldeffekt | Gewöhnlich | Gegner 3 s halb so schnell |
| Nebel | Wasser | Schild | Selten | 3 s: Angriffe verfehlen mit 50 % |
| Lichtlanze | Licht | Angriff | Gewöhnlich | Trifft die Gegnerspalte = deine Spalte: 30 |
| Blendgranate | Licht | Feldeffekt | Selten | Bricht den laufenden Gegnerangriff ab |
| Wurmloch | Virus | Falle | Selten | Zieht Gegner in deine Reihe, 10 |
| Datenfresser | Virus | Angriff | Gewöhnlich | Projektil 15, doppelt gegen Gift |

**Designidee:** Mehr Positionsspiel – Wurmloch + Laserschuss/Pixelstrahl, Lichtlanze belohnt die richtige Spalte, Blendgranate als Konter statt Ausweichen.
