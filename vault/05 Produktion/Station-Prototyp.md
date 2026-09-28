---
tags: [produktion, prototyp, station, meta]
status: spielbar im Browser-Prototyp
---
# Station-Prototyp (Meta-Ebene)

> **Kernfrage:** Gibt die Station einen Grund, nach einem Run weiterzuspielen und später zurückzukommen?

Spielbar im Browser-Prototyp (Link: [[🏠 Start hier]]). Der Fortschritt wird im Browser gespeichert.

## Bereiche
| Bereich | Funktion |
|---|---|
| Team | Alle eigenen Monster, Start eines Runs. Jedes Monster ist ein Einzelstück mit eigener Evolution. |
| Brutnest | 2 Brutplätze (3. für 300 Fragmente), Eier brüten in Echtzeit, auch offline |
| Labor | Zwei Monster zu einer neuen Art fusionieren. Rezepte sind versteckt. |
| Monsterdex | 25 Einträge, unbekannte als Silhouette. Alle 5 Einträge +50 Fragmente. |

## Eier
| Ei | Brutzeit Prototyp | Brutzeit Spiel | Mögliche Monster |
|---|---|---|---|
| Gewöhnlich | 20 s | 15 Min. | Pixmiez, Funkling, Tröpfel, Kekso |
| Selten | 60 s | 1 Std. | Lumi, Quakli, Kekso |
| Episch | 3 Min. | 4 Std. | Lumi, Quakli (Evolution schon zu 50 % geladen) |

**Beute:** Sieg = immer ein Ei (60 % gewöhnlich, 30 % selten, 10 % episch). Niederlage = 35 % Chance auf ein gewöhnliches Ei. Zum Start liegt ein Ei bereit, damit das Brutnest sofort erlebbar ist.

**Werbung (simuliert):** Einmal pro Ei freiwillig, halbiert die Restzeit. Testet, wie sich belohnte Werbung im Spielfluss anfühlt → [[Monetarisierungsmodell]]

## Fusion
- Kosten: 100 Fragmente, **nur bei Erfolg**. Fehlversuche sind kostenlos und verraten ein Gerücht im Rezeptbuch.
- Die **Linie** zählt, nicht die Form: Ein entwickeltes Monster fusioniert wie seine Grundform.
- Beide Monster gehen in der Fusion auf. Das macht die Entscheidung bedeutsam und erzeugt Bedarf an neuen Eiern.

| Rezept | Ergebnis | Besonderheit |
|---|---|---|
| Funkling + Tröpfel | [[Dampfbyte]] | |
| Tröpfel + Kekso | [[Wolkerich]] | |
| Lumi + Kekso | [[Glyphel]] | Startet mit Defrag |
| Quakli + Pixmiez | [[Spukatz]] | Nur 0 bis 4 Uhr. Weicht 20 % der Treffer aus. |

## Neue spielbare Monster
| Monster | HP | Stil | Evolutionen |
|---|---|---|---|
| [[Kekso]] | 100 | Helfer-Bots, Minen | [[Tracko]] (Virus), [[Cachy]] (Licht) |
| [[Lumi]] | 85 | Schnell, Blitzcursor | [[Blinki]] (Licht), [[Screenshina]] (Code) |
| [[Quakli]] | 95 | Gift, Minen | [[Virulurch]] (Virus), [[Hüpfbyte]] (Code) |

## Was wir beobachten wollen
- Gehen Tester nach einem Run **freiwillig** in die Station?
- Wird das Brutnest zum Grund, nach ein paar Minuten zurückzukommen?
- Probieren Tester Fusionen aus, auch ohne Rezept? Lesen sie die Gerüchte?
- Tut es weh, zwei Monster für eine Fusion herzugeben? (Ein bisschen soll es das.)
- Wird die simulierte Werbung genutzt, und wie fühlt sie sich an?

Siehe auch: [[Station, Brüten & Fusion]], [[Progression & Wirtschaft]]
