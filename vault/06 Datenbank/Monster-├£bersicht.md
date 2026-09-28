---
tags: [datenbank, monster]
---
# Monster-Übersicht

25 Monster für den Vertical Slice. Neue Monster über [[Template – Monster]] anlegen.

## Evolutionslinien

- **[[Pixmiez]]** (Neutral) → [[Blazebit]] · [[Firewallo]] · [[Virulina]] · [[Prismiez]]
- **[[Funkling]]** (Feuer) → [[Glutbyte]] → [[Magmawulf]] · [[Overclocko]]
- **[[Tröpfel]]** (Wasser) → [[Kaskadi]] → [[Tsunamander]] · [[Pufferling]] · [[Frostbyte]]
- **[[Kekso]]** (Code) → [[Tracko]] · [[Cachy]]
- **[[Lumi]]** (Licht) → [[Blinki]] · [[Screenshina]]
- **[[Quakli]]** (Virus) → [[Virulurch]] · [[Hüpfbyte]]
- **[[Molchi]]** (Virus, Salamander) → [[Toxmolch]] · [[Magmolch]]
- **[[Brummbit]]** (Licht, Bär) → [[Sonnbrumm]] · [[Bärtron]]
- **[[Kauzbit]]** (Code, Robo-Eule) → [[Optikauz]] · [[Raketauz]]

## Fusionen

- **[[Dampfbyte]]** (Feuer, Selten) – Funkling-Linie + Tröpfel-Linie
- **[[Wolkerich]]** (Wasser, Selten) – Tröpfel-Linie + Kekso-Linie
- **[[Glyphel]]** (Licht, Episch) – Lumi-Linie + Kekso-Linie
- **[[Spukatz]]** (Virus, Episch) – Quakli-Linie + Pixmiez-Linie

## Statische Tabelle

| Monster | Element | Stufe | Seltenheit | Signatur-Chip |
|---|---|---|---|---|
| [[Pixmiez]] | Neutral | 1 | Gewöhnlich | Pixelstrahl |
| [[Blazebit]] | Feuer | 2 | Gewöhnlich | Glutball |
| [[Firewallo]] | Code | 2 | Gewöhnlich | Firewall |
| [[Virulina]] | Virus | 2 | Selten | Virusspritzer |
| [[Prismiez]] | Licht | 2 | Episch (geheim) | Defrag |
| [[Funkling]] | Feuer | 1 | Gewöhnlich | Glutball |
| [[Glutbyte]] | Feuer | 2 | Gewöhnlich | Flammenwelle |
| [[Overclocko]] | Code | 2 | Selten | Übertakten |
| [[Tröpfel]] | Wasser | 1 | Gewöhnlich | Wasserstrahl |
| [[Kaskadi]] | Wasser | 2 | Gewöhnlich | Wasserstrahl |
| [[Pufferling]] | Code | 2 | Gewöhnlich | Blubberschild |
| [[Frostbyte]] | Wasser | 2 | Selten | Eisfeld |
| [[Kekso]] | Code | 1 | Gewöhnlich | Mini-Bot |
| [[Tracko]] | Virus | 2 | Selten | Bug-Mine |
| [[Cachy]] | Licht | 2 | Gewöhnlich | Heilpatch |
| [[Lumi]] | Licht | 1 | Gewöhnlich | Blitzcursor |
| [[Blinki]] | Licht | 2 | Gewöhnlich | Blitzcursor |
| [[Screenshina]] | Code | 2 | Selten | Mini-Bot |
| [[Quakli]] | Virus | 1 | Gewöhnlich | Virusspritzer |
| [[Virulurch]] | Virus | 2 | Gewöhnlich | Bug-Mine |
| [[Hüpfbyte]] | Code | 2 | Selten | Mini-Bot |
| [[Dampfbyte]] | Feuer | 3 | Selten | Glutball |
| [[Wolkerich]] | Wasser | 3 | Selten | Blubberschild |
| [[Glyphel]] | Licht | 3 | Episch | Defrag |
| [[Spukatz]] | Virus | 3 | Episch | Virusspritzer |

## Dataview (dynamisch)

```dataview
TABLE element AS "Element", stufe AS "Stufe", seltenheit AS "Seltenheit", entwickelt_aus AS "Herkunft"
FROM "06 Datenbank/Monster"
SORT stufe ASC, element ASC
```
> Benötigt das Community-Plugin **Dataview**.

## Verteilung nach Element

| Element | Anzahl |
|---|---|
| Code | 6 |
| Feuer | 4 |
| Licht | 5 |
| Neutral | 1 |
| Virus | 5 |
| Wasser | 4 |

Elementkreislauf: **Feuer > Code > Wasser > Feuer**, **Licht ↔ Virus** gegenseitig stark. Neutral ohne Stärken und Schwächen.
