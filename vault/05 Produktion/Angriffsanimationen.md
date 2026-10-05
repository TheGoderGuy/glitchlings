---
tags: [produktion, grafik, godot]
---
# Angriffsanimationen (05.10.2026)

Alle **132 Figuren** haben jetzt eine Angriffsanimation: 102 Glitchling-Formen und 30 Gegner, Wächter und Bosse (inklusive der 5 neuen Zonengegner). Auftrag des Produzenten: „Kümmere dich um die Angriffsanimationen.“

## Im Kampf
- **Eigener Glitchling:** Bei jedem **Angriffs-Chip** läuft die Animation in 0,36 s (`ATK_TIME`), ebenso bei der Signatur. Schild-, Heil- und Hilfs-Chips lösen keine aus. Das Vorschnellen nach vorn bleibt zusätzlich erhalten, weil die Bilder allein eher dezent wirken.
- **Gegner:** Die Ausholbilder laufen synchron zur roten Warnung bis 55 % der Animation (`ATK_HIT`). Beim Einschlag folgen Schlag und Rückkehr in 0,24 s (`E_ATK_POST`). Ausholen und Vorschnellen bleiben ebenfalls.
- Die Angriffsbilder überdecken Idle und Blinzeln, aber nicht den weißen Treffer-Blitz. Besiegte Gegner zeigen keine Angriffspose.
- **Technik:**
  - Dateien: `game/assets/sprites/anim/<sprite>_atk_0 … _5.png`
  - Laden in `PixelCanvas.sprite()` (Feld `atk`), Option `"atk"` (Fortschritt 0–1) in `_draw_sprite`, Abfrage `PixelCanvas.has_attack()`
  - Steuerung in `battle_view.gd` (`p_atk`, `e_atk_post`)
  - Prüfung per Screenshot mit `--mode=fight --form=<Form> --foe=<Nr> --atkpose=<0–1>`

## Erzeugung
- PixelLab `animate_image` mit 6 Bildern, Anfangs- gleich Endbild (Grundsprite), 1 Generierung je Figur, insgesamt etwa 140 inklusive Pilot und Neuversuchen.
- **Prompt:** Der erste Pilot mit „attack“ allein war zu zahm (Wogotter, Kernelmantis). Gut funktioniert: *„big exaggerated attack: … leans back to wind up, then lunges far forward to the right and strikes hard … then returns to its starting pose, strong clear motion, stays facing right, same size“*. Eigene Varianten gibt es für Vögel (Flügel hoch, Sturzflug mit Schnabel und Krallen), Robo-Eulen, Gegner („rears back“) und Pflanzen („snaps its head forward and bites“).
- Übernahme mit `tools/sprites/node/anim_frames.js <sprite> <rohframe-präfix> --kind atk --frames 1,2,3,4,5,6`. Jeder Frame wird auf die Palette des Grundbilds gezogen.

## Qualitätskontrolle
Jede Animation wurde auf einem Kontaktbogen geprüft.

| Problem | Figuren | Lösung |
|---|---|---|
| Kaum Bewegung | Kolosspuff, Maskli, Orbitkauz | Neu generiert mit genauerer Bewegung („charges and rams“, „jumps and swipes“, „dives down and slashes“). Orbitkauz wurde deutlich besser, Kolosspuff und Maskli bleiben dezent. Das Vorschnellen im Kampf gleicht das aus. |
| Weißer Gegenstand (Schloss-Symbol) mitten im Angriff | Quakli | Neu generiert mit „no objects“, jetzt ein Bauchklatscher |
| Figur zerfällt zu braunem Fleck | Glitchmotte | Neu generiert mit „keeps its bright yellow colors“. Das letzte bräunliche Bild wird übersprungen (`--frames 1,2,3,4,4,6`). |
| Gemalter Hintergrund | Fehlerqualle (2 Bilder) | Automatisch entfernt, die Energiesichel bleibt bis auf wenige Pixel erhalten |

Bewusst behalten:
- Kleine Merkmale verschwinden kurz: Bastionkatz und Bollwerkatz verlieren die Kugeln, bei Glimmdachs werden die Leuchtlinien dunkel, Toxikröt verliert die Giftbeulen.
- Glutraupe und Datenwespe verfärben sich beim Schlag (Glut kühlt ab bzw. die Streifen werden hell).
- Die Glitchblüte bewegt sich als festsitzende Pflanze kaum.

## Test
`test_sprite_colors` prüft jetzt höchstens 32 Farben inklusive Angriffsbildern und dass **jede Figur eine Angriffsanimation hat** (312 Prüfungen).
