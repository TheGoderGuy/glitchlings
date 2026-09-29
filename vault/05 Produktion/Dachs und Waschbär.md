---
tags: [produktion, monster, godot]
---
# Dachs und Waschbär (29.09.2026)

Wunsch des Produzenten. Zwei neue Linien mit je 2 Richtungen bis zum Ultra (14 Sprites, PixelLab, 32 Farben, Blinzel-Frames, Namen geprüft). Elemente so gewählt, dass die seltener vertretenen (Feuer, Wasser, Elektro) gestärkt werden.

## Dachs – Buddli (Episch/Legendär-Ei)
Zäh und furchtlos. 115 HP, etwas langsamer. **Passiv „Furchtlos“**: unter 30 % HP machen Chip-Treffer 50 % mehr Schaden. Signatur *Buddelstoß* (35, betäubt 0,5 s).

| Richtung | Rookie | Champion | Ultra |
|---|---|---|---|
| Feuer | Glimmdachs (*Glutgrabung*) | Magmadachs (*Magmaausbruch*) | Pyromeles (*Erdkernbrecher*: 60 + 40 + sehr langer Brand) |
| Elektro (Gesichtsstreif = Blitz) | Zackdachs (*Zackenstreif*) | Donnerdachs (*Donnergrube*) | Voltameles (*Hochspannungsgraben*: 3 × 30, betäubt 1,5 s) |

## Waschbär – Maskli (Selten-Ei)
Flinker maskierter Dieb. 90 HP. **Passiv „Langfinger“**: jeder 4. Chip-Treffer klaut Ladung, ein Chip auf der Hand ist sofort bereit („Geklaut!“). Signatur *Taschendieb* (lädt alle Chips, 25).

| Richtung | Rookie | Champion | Ultra |
|---|---|---|---|
| Wasser (wäscht alles) | Plätschbär (*Waschgang*) | Flutmaske (*Flutraubzug*) | Hydrocyon (*Sintflut-Coup*: 2 × 30, friert 2 s, lädt alle Chips) |
| Virus (Schatten-Datendieb) | Klaubär (*Giftgriff*) | Nachtmaske (*Schattenraub*) | Virocyon (*Datenraubzug*: Feld 40, sehr langes Gift, lädt alle Chips) |

Monsterdex: 88 Formen, 11 Linien.

**Werkzeug-Fixes dabei**: `reduce32.js` stürzt nicht mehr ab, wenn ein Bild schon weniger als 32 Farben hat. `holes.js --fill` füllt kleine Löcher jetzt mit der häufigsten Nachbarfarbe statt einem Mittelwert (der Mittelwert erzeugte neue Farben, einige Sprites lagen dadurch bei bis zu 127 Farben – alle heutigen Sprites neu aufbereitet, jetzt ≤ 32). Virocyons Glitch-Lücken werden bewusst nicht gefüllt.
