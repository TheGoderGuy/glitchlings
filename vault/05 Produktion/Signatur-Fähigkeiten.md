---
tags: [design, kampf, prototyp]
---
# Signatur-Fähigkeiten

**Ziel:** Jeder Glitchling soll sich im Kampf einzigartig anfühlen, nicht nur durch Werte. Drei Schichten:
1. **Passive Fähigkeit** pro Linie (echte Mechanik, gilt für alle Formen der Linie)
2. **Signatur-Attacke** – eigene Taste (Leertaste / großer Knopf über den Chips), nur diese Form hat sie
3. **Evolution verändert die Signatur** – jede Richtung eine andere Variante, Champion/Ultra stärker

**Leiste:** lädt durch ausgeteilten Schaden (×1,2) und eingesteckten Schaden (×1,5), startet jeden Kampf bei 0. Treffer der Signatur-Attacke selbst laden nicht. Ergebnis: ca. 1× pro Normalkampf, 2–3× gegen den Boss.

## Passive Fähigkeiten
| Linie | Passiv | Wirkung |
|---|---|---|
| [[Pixmiez]] | Katzenreflex | Weicht dem ersten Treffer jedes Kampfes aus (ab Champion: den ersten zwei). |
| [[Tröpfel]] | Regeneration | Heilt 1 HP pro Sekunde, wenn es 3 s lang nicht getroffen wurde (ab Champion: 2 HP). |
| [[Quakli]] | Giftbaut | Wer Quakli trifft, wird selbst vergiftet. |
| [[Funkling]] | Übermut | Jeder 3. gespielte Chip halbiert die Ladezeit der anderen Chips auf der Hand. |
| [[Kekso]] | Hamstern | 25 % Chance: Ein gespielter Chip wird gehamstert und landet sofort wieder auf der Hand. |
| [[Lumi]] | Hasenhaken | Bewegt sich doppelt so schnell. |

## Signatur-Attacken
| Form | Attacke | Element | Wirkung |
|---|---|---|---|
| [[Pixmiez]] | Pixelsprung | Neutral | Springt zum Gegner und kratzt: 40 Schaden, trifft immer. |
| [[Blazebit]] | Flammensprung | Feuer | Brennender Sprung: 45 Schaden + Brand. |
| [[Glutluchs]] | Glutkrallen | Feuer | Zwei Flammenhiebe à 30 + langer Brand. |
| [[Pyrolynx]] | Dreischweif-Inferno | Feuer | Drei Feuerschweife à 28 + Brand, setzt die Gegnerreihe in Flammen. |
| [[Firewallo]] | Schildsprung | Code | 35 Schaden und landet mit Firewall-Schild (4 s). |
| [[Virulina]] | Giftkralle | Virus | 35 Schaden + starkes Gift (6 s). |
| [[Prismiez]] | Prismasprung | Licht | 40 Schaden und heilt 20 HP. |
| [[Tröpfel]] | Blubberwelle | Wasser | Welle über deine Reihe: 30 Schaden, stößt zurück. |
| [[Kaskadi]] | Kaskadenflut | Wasser | Flutet das ganze Gegnerfeld: 35 Schaden, trifft immer. |
| [[Tsunamander]] | Tsunami | Wasser | Riesenwelle: 55 Schaden, trifft immer, friert 1,5 s ein. |
| [[Pufferling]] | Aufblähen | Wasser | Bläht sich zur Blase auf: absorbiert 60 Schaden (6 s), 15 Schaden in deiner Reihe. |
| [[Frostbyte]] | Frostwelle | Wasser | Eiswelle über deine Reihe: 30 Schaden, friert 2,5 s ein. |
| [[Quakli]] | Zungenschlag | Virus | Zieht den Gegner direkt vor dich: 25 Schaden + Gift. |
| [[Virulurch]] | Giftwolke | Virus | Giftwolke über das ganze Gegnerfeld: 20 Schaden + sehr langes Gift. |
| [[Hüpfbyte]] | Datensprung | Code | Springt auf den Gegner: 40 Schaden, betäubt 1,5 s. |
| [[Funkling]] | Funkenbiss | Feuer | Drei schnelle Funkenbisse à 14, treffen immer. |
| [[Glutbyte]] | Glutbiss | Feuer | Drei glühende Bisse à 18 + Brand. |
| [[Magmawulf]] | Magmasturm | Feuer | Vier Magma-Hiebe à 20 + Brand, setzt die Gegnerspalte in Flammen. |
| [[Overclocko]] | Überladung | Code | Lädt alle Chips sofort, übertaktet 6 s und trifft mit 25 Schaden. |
| [[Kekso]] | Backentasche | Neutral | Spuckt den zuletzt gespielten Chip gratis noch einmal aus (sonst 30 Schaden). |
| [[Tracko]] | Keksfalle | Virus | Backentasche + zwei Virus-Minen um den Gegner. |
| [[Cachy]] | Leuchtkeks | Licht | Backentasche + heilt 30 HP. |
| [[Lumi]] | Cursorblitz | Licht | Blitz, der immer trifft: 35 Schaden. |
| [[Blinki]] | Dreifachblitz | Licht | Drei Blitze à 22, treffen immer. |
| [[Screenshina]] | Abbild | Code | Erschafft ein Abbild, das die nächsten 2 Treffer abfängt (8 s), und trifft mit 20 Schaden. |

## Noch offen
Die 4 Fusionen haben noch keine Passive/Signatur (Knopf ausgeblendet) – erst nach der Überarbeitung von Namen/Designs der Fusionen.

Code: `PASSIVE`, `SPECIAL`, `useSpecial()` in `prototype/index.html`. Test: `tests/abil.test.js`.
