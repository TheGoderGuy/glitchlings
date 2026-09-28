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
