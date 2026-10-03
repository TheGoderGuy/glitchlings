---
tags: [produktion, monster, godot]
---
# Otter und Ara (03.10.2026)

Aus der Element-Analyse: Wasser, Elektro und Feuer sollten gestärkt werden. Der Produzent hat Otter und Ara (Papagei) gewählt, den Fuchs abgelehnt. Zwei neue Linien mit je 2 Richtungen bis zum Ultra: 14 Sprites, PixelLab Pro Flash, 32 Farben, Blinzel-Frames (Boxen in `tools/sprites/blink_boxes.json`). Alle Namen sind deutsch und englisch mit `tools/namecheck` geprüft.

**Namensregel:** keine Endung „-ara“, weil sie an Nachtara, Psiana und Flamara erinnert. „Zapp“, „Blitzotter“ und „Stromotter“ hat der Produzent abgelehnt. Der Elektro-Champion heißt deshalb **Lutrion**.

## Otter – Bachli (Ei)
Verspielter Teamplayer. 100 HP. **Passiv „Teamgeist“**: Der Support-Slot (L/○) lädt 25 % schneller. Signatur *Bauchrutscher*: 30 über die Reihe, stößt zurück.

| Richtung | Rookie | Champion | Ultra |
|---|---|---|---|
| Wasser | Strudli (*Strudelwirbel*: 2 × 20, heilt 10) | Wogotter (*Wogenbrecher*: Feld 35, friert 1 s ein, heilt 15) | Hydrolutra (*Mahlstrom*: Feld 2 × 35, friert 1,5 s ein, heilt 25) |
| Elektro | Knisterli (*Schnurrhaarblitz*: Reihe 30, betäubt 0,5 s) | Lutrion (*Donnerwirbel*: 2 × 30, betäubt 1 s) | Fulgurlutra (*Gewitterfront*: Feld 2 × 45, betäubt 1 s, lädt alle Chips) |

## Ara – Plapperli (Ei)
Bunter Plapper-Ara. 85 HP. **Passiv „Nachplappern“**: Jeder 4. Angriffs-Chip wird nach 0,5 s mit halbem Schaden wiederholt („Nachgeplappert!“). Signatur *Plapperschwall*: 2 × 15 über die Reihe.

| Richtung | Rookie | Champion | Ultra |
|---|---|---|---|
| Elektro | Surrfeder (*Surrsturz*: 35, betäubt 0,5 s) | Sturmschwinge (*Federsalve*: Reihe 3 × 20, betäubt 0,5 s) | Fulgopsitta (*Donnerschrei*: Feld 4 × 25, betäubt 1 s) |
| Feuer | Glutfeder (*Glutfedern*: Reihe 30 + Brand) | Flammschwinge (*Feuerfächer*: Feld 2 × 20 + langer Brand) | Heliopsitta (*Sonnensturz*: 70 + 30 + sehr langer Brand) |

## Gestaltung
- **Flammschwinge und Heliopsitta sollen nicht wie ein Phönix aussehen.** Die Glut sitzt im Körper, es gibt keine Flammenflügel. Bei Flammschwinge waren zwei Versuche zu sehr Phönix, der Produzent hat Variante C gewählt.
- **Ultras:** Die erste Runde war „nicht Ultra genug“ im Vergleich zu Pyromeles und Hydrocyon. Danach hat das Element den ganzen Körper verwandelt: Panzer, Leuchtlinien, mehrere Schweife.
- Fulgurlutra stand zuerst auf allen Vieren. Der Produzent: Das passt nicht zum Otter. Jetzt steht er aufrecht wie Hydrolutra.
- Fulgurlutras Auge ist nur 2 Pixel groß. Sein Blinzel-Bild wurde von Hand gemacht, dabei wurden die Augenpixel mit Fellfarbe übermalt.

## Startdecks
Beide Startdecks haben 6 Angriffs- und 2 Support-Chips. Je Entwicklungsrichtung liegt 1 Element-Chip im Deck, damit kein Weg bevorzugt ist:
- Bachli: Wasserstrahl und Blitzcursor.
- Plapperli: Glutball und Blitzcursor.
- Support bei beiden: Heilpatch und Sprungantrieb.

Monsterdex: **102 Formen, 13 Linien.** Eier: 13 Babys möglich.

## Idle-Animationen
Alle 14 Formen haben eine Idle-Animation, je 6 Bilder. Nachgebessert wurden:
- **Knisterli:** Die erste Fassung hatte fast die ganze Zeit die Augen zu und sah aus, als würde er niesen. Neu generiert mit „eyes stay open“.
- **Lutrion, Flammschwinge, Heliopsitta:** Nur die ruhige Hälfte wird vor und zurück abgespielt. Bei Lutrion verschwanden die Leuchtlinien, Flammschwinge spuckte kurz Feuer, Heliopsitta leuchtete zu grell auf.
- **Bachli:** Läuft mit den Bildern 0, 1, 2, 3, 2, 1, weil Bild 5 das Gesicht verändert.
