---
tags: [produktion, chips, monster, godot]
---
# Linien-Chips (08.10.2026)

Aus der [[Game-Design-Analyse 2026-10-08]], Phase B: „Monster spielen sich ähnlich“. Alle Startdecks teilten sich 5 von 8 Chips (Pixelstrahl ×2, Byteschlag, Heilpatch …).

## Prinzip
- **Ein eigener Chip je Linie** (13 Stück), passend zum Tier und oft zum Passiv der Linie. Er ersetzt im Startdeck einen neutralen Chip derselben Rolle. Es bleiben 6 Angriffs- und 2 Support-Chips.
- **Neutral:** Er lenkt die Evolution nicht. Die Regel „je Richtung genau ein Element-Chip im Startdeck“ bleibt erfüllt.
- **Seltenheit „Linie“** (`"line": Art` in `GameData.CHIPS`, `GameData.is_line_chip`): kommt nie in Chipwahl, Händler oder Ereignissen vor. Verbessern (Rast, Werkbank, Ereignisse) und Kopieren gehen wie bei jedem Chip.
- **Bestehende Spielstände:** Ein Run startet immer mit dem Startdeck der Linie, deshalb haben alle Monster den neuen Chip sofort.

## Die Chips
| Linie | Chip | Rolle | Wirkung | Idee |
|---|---|---|---|---|
| Pixmiez (Katze) | Krallenwirbel | Angriff | 3 Nahkampfhiebe à 9 | schnell und flink; mehrere Treffer = mehrere Chancen auf einen Konter |
| Funkling (Welpe) | Stöckchen | Angriff | Projektil 14, kommt zurück (10) | Apportieren |
| Tröpfel (Axolotl) | Kiemenatmung | Support | heilt 8 + 6 s lang 3/s | passt zur Regeneration |
| Kekso (Hamster) | Backenvorrat | Support | beide Angriffs-Chips sofort geladen | Vorräte in den Backen, passt zum Hamstern |
| Lumi (Hase) | Hakenschlag | Support (Schutz) | weicht aus (2 s), nächster Treffer +50 % | Haken schlagen und zurückschlagen |
| Quakli (Frosch) | Zungenzug | Angriff | zieht den Gegner in deine Reihe ganz nach vorn, 14, betäubt | Kombo mit Byteschlag (Nahkampf) |
| Molchi (Salamander) | Hautgift | Angriff | Projektil 10, Gift und Brand +3 s | passt zu Giftdrüsen (Gift/Brand +50 %) |
| Brummbit (Bär) | Bärenhieb | Angriff | Nahkampf 34, Rückstoß, betäubt | der Tank haut zu |
| Kauzbit (Robo-Eule) | Eulenauge | Support | 4 s lang jedes Ausholen konterbar | Adleraugen: macht die Eule zur Konter-Spezialistin |
| Buddli (Dachs) | Graben | Support (Schutz) | 1,2 s unverwundbar, dann 22 von unten (trifft immer) | Dachsbau |
| Maskli (Waschbär) | Stibitzen | Angriff | Projektil 12: Gegner greift 1 s später an, Support sofort geladen | kleiner Dieb, passt zu Langfinger |
| Bachli (Otter) | Kieselwurf | Angriff | Bogenwurf 24, daneben 12 | Otter spielen mit Steinen |
| Plapperli (Ara) | Echoruf | Angriff | Schall 10, dann Echo des letzten Angriffs (halb) | passt zu Nachplappern |

Fusionen und Legendäre haben schon eigene Startdecks und bekommen keinen Linien-Chip.

## Darstellung
- Eigene Projektile: Stöckchen dreht sich, Kiesel, Hautgift-Tropfen, Diebesbeutel.
- Effekte: Klingenbogen (Krallen, Bärenhieb), Feldlinien (Zungenzug), Radar (Eulenauge), Schallwelle (Echoruf).
- Graben: Das Monster verschwindet in einem Erdhügel, über dem Gegner steht eine Zielmarke.
- Statusanzeigen im HUD: „Kiemen“, „Eulenauge“, „Eingegraben“.

## Tests
`test_line_chips` (379 Prüfungen insgesamt): jede Linie hat genau einen neutralen Linien-Chip, nie in Chipwahl, Händler oder Ereignissen, und jede Wirkung ist einzeln geprüft. Dazu laufen alle 58 Chips samt verbesserter Fassungen durch die bestehenden Tests (Wirkung, Effekt, Kartenbild, Textlänge, Übersetzung).
