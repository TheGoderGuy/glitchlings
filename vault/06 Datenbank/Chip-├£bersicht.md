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

## Godot-Stand (29.09.2026): 45 Chips

Die Tabelle wird aus `game/scripts/data/game_data.gd` erzeugt. Neu am 29.09.2026 (17 Chips): Kombos mit Zonen-Mechaniken und Modulen, z. B. Magnetfeld → Blitzlanze, Frostsplitter gegen eingefrorene Gegner, Debugger räumt Lava/Schleim/Diener weg, Feuersbrunst doppelt gegen brennende Gegner.

| Chip | Element | Art | Schaden | Ladezeit | Seltenheit | Wirkung |
|---|---|---|---|---|---|---|
| Pixelstrahl | Neutral | Angriff | 20 | 2.0 s | Gewöhnlich | Projektil über deine Reihe. |
| Byteschlag | Neutral | Angriff | 30 | 1.5 s | Gewöhnlich | Nahkampf: vordere zwei Felder deiner Reihe. |
| Heilpatch | Neutral | Buff | – | 5.0 s | Gewöhnlich | Heilt sofort 25 HP. |
| Defrag | Neutral | Buff | – | 8.0 s | Episch | Lädt alle anderen Chips in der Hand sofort. |
| Doppelklick | Neutral | Angriff | 12 | 1.8 s | Gewöhnlich | Zwei schnelle Projektile über deine Reihe, je 12. |
| Neustart | Neutral | Buff | – | 7.0 s | Episch | Heilt 15 HP und zieht eine komplett neue, sofort bereite Hand. |
| Sprungantrieb | Neutral | Buff | – | 3.0 s | Gewöhnlich | Du weichst dem nächsten Treffer in den nächsten 2 s aus. |
| Konter | Neutral | Schild | 35 | 4.0 s | Selten | Blockt einen Treffer in den nächsten 1,5 s und schlägt mit 35 zurück. |
| Übertakten | Feuer | Buff | – | 6.0 s | Selten | Alle Chips laden 5 s doppelt so schnell. |
| Glutball | Feuer | Angriff | 45 | 3.0 s | Gewöhnlich | Schlägt 3 Felder vor dir ein: 45 im Zentrum, 20 daneben. Setzt Brand. |
| Flammenwelle | Feuer | Angriff | 25 | 3.5 s | Selten | Trifft die ganze Spalte, in der der Gegner steht. |
| Funkenregen | Feuer | Angriff | 25 | 3.0 s | Selten | Funken regnen aufs Gegnerfeld, einer trifft immer: 25 + Brand. |
| Hitzeschild | Feuer | Schild | – | 5.0 s | Gewöhnlich | Blockt den nächsten Treffer (4 s) und setzt den Angreifer in Brand. |
| Glutklinge | Feuer | Angriff | 22 | 1.6 s | Gewöhnlich | Nahkampf: vordere zwei Felder deiner Reihe, 22 + kurzer Brand. |
| Feuersbrunst | Feuer | Angriff | 30 | 6.0 s | Episch | Ganzes Gegnerfeld: 30 + langer Brand. Doppelt, wenn er schon brennt. |
| Wasserstrahl | Wasser | Angriff | 15 | 2.0 s | Gewöhnlich | Projektil. Stößt den Gegner ein Feld zurück. |
| Blubberschild | Wasser | Schild | – | 4.0 s | Gewöhnlich | Blase absorbiert 30 Schaden (5 s). |
| Eisfeld | Wasser | Feldeffekt | – | 4.0 s | Selten | Friert den Gegner 2 s ein. |
| Strudel | Wasser | Feldeffekt | – | 4.0 s | Gewöhnlich | Der Gegner wird 3 s lang halb so schnell. |
| Nebel | Wasser | Schild | – | 5.0 s | Selten | 3 s lang verfehlen dich Angriffe mit 50 % Chance. |
| Flutwelle | Wasser | Angriff | 28 | 3.5 s | Selten | Welle über deine Reihe: 28, stößt den Gegner zurück. |
| Frostsplitter | Wasser | Angriff | 14 | 2.2 s | Gewöhnlich | Projektil: 14, dreifach gegen eingefrorene oder langsame Gegner. |
| Tsunami | Wasser | Angriff | 35 | 7.0 s | Episch | Trifft das ganze Gegnerfeld: 35 und friert 1,5 s ein. |
| Firewall | Code | Schild | – | 4.0 s | Gewöhnlich | Blockt den nächsten Treffer (4 s). |
| Mini-Bot | Code | Beschwörung | – | 6.0 s | Selten | Helfer: 6 s lang 5 Schaden pro Sekunde. |
| Laserschuss | Code | Angriff | 25 | 2.5 s | Gewöhnlich | Sofortiger Laser über deine Reihe: 25. |
| Portscan | Code | Buff | – | 4.0 s | Selten | Deine nächsten 2 Treffer machen +50 % Schaden. |
| Kopierschutz | Code | Schild | 15 | 6.0 s | Selten | Blockt den nächsten Treffer (6 s) und wirft 15 Schaden zurück. |
| Geschützturm | Code | Beschwörung | 12 | 7.0 s | Selten | Turm für 8 s: feuert alle 1,5 s einen Laser über deine Reihe (12). |
| Debugger | Code | Angriff | 20 | 2.5 s | Gewöhnlich | Laser über deine Reihe: 20. Entfernt Lava, Schleim und Diener auf deiner Seite. |
| Blitzcursor | Elektro | Angriff | 20 | 3.0 s | Gewöhnlich | Markiert den Gegner. Trifft nach 0,5 s garantiert. |
| Blitzlanze | Elektro | Angriff | 30 | 2.5 s | Gewöhnlich | Trifft die Gegnerspalte, die deiner Spalte entspricht: 30. |
| Blendgranate | Elektro | Feldeffekt | – | 5.0 s | Selten | Blendet den Gegner: sein laufender Angriff wird abgebrochen. |
| Kurzschluss | Elektro | Angriff | 18 | 2.5 s | Gewöhnlich | Projektil: 18 Schaden, betäubt 0,5 s. |
| Kettenblitz | Elektro | Angriff | 15 | 3.0 s | Selten | Trifft garantiert: 15, dann springt der Blitz zweimal nach (je 10). |
| Ladungsfeld | Elektro | Buff | – | 4.0 s | Gewöhnlich | Lädt deine Signatur-Leiste um 25 %. |
| Magnetfeld | Elektro | Feldeffekt | – | 3.5 s | Gewöhnlich | Zieht den Gegner in deine Spalte, betäubt 0,5 s. Kombo mit Blitzlanze! |
| Blackout | Elektro | Feldeffekt | – | 7.0 s | Episch | Stromausfall: Gegner 3 s betäubt, sein laufender Angriff fällt aus. |
| Bug-Mine | Virus | Falle | 35 | 3.0 s | Selten | Mine unter dem Gegner. Explodiert, wenn er darauf steht. |
| Virusspritzer | Virus | Angriff | 10 | 2.5 s | Gewöhnlich | Projektil. Vergiftet 4 s lang. |
| Wurmloch | Virus | Falle | 10 | 3.0 s | Selten | Zieht den Gegner in deine Reihe: 10 Schaden. |
| Datenfresser | Virus | Angriff | 15 | 2.0 s | Gewöhnlich | Projektil: 15, doppelt gegen vergiftete Gegner. |
| Seuche | Virus | Feldeffekt | – | 4.0 s | Selten | Verdoppelt das Gift auf dem Gegner (min. 4 s). |
| Sporenfalle | Virus | Falle | 15 | 3.0 s | Gewöhnlich | Mine unter dem Gegner: 15 Schaden und 6 s Gift. |
| Parasit | Virus | Angriff | 12 | 3.0 s | Selten | Projektil: 12 Schaden, du heilst dich um genauso viel. |
