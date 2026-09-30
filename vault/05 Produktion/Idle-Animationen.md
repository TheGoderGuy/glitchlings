---
tags: [produktion, grafik, godot]
---
# Idle-Animationen (30.09.2026)

Alle **113 Figuren** haben eine Idle-Animation: 88 Glitchling-Formen und 25 Gegner, Wächter und Bosse.

- 6 Bilder, **10 Bilder/s**. Der Produzent hat beim Pilot mit 6 Figuren entschieden: „10 Bilder/s sieht sehr gut aus“.
- Dateien: `game/assets/sprites/anim/<sprite>_idle_0.png … _5.png`. `PixelCanvas` spielt sie automatisch statt Wippen und Blinzeln ab. Figuren starten versetzt, damit nicht alle im Gleichtakt atmen.
- Erzeugt mit PixelLab `animate_image` (Anfangs- = Endbild für einen sauberen Loop, 1 Generierung je Figur, insgesamt etwa 118 inklusive Neuversuchen).
- Übernahme mit `tools/sprites/node/anim_frames.js <sprite> <rohframe-präfix> [--frames …] [--replace a=b]`. Jeder Frame wird auf die Palette des Grundbilds gezogen, damit es kein Flimmern gibt und keine neuen Farben entstehen.
- **Neu im Werkzeug:** Liefert PixelLab einen Frame mit gefülltem Hintergrund (passiert bei Bollwerkatz), wird der Hintergrund automatisch vom Rand her entfernt. Das passiert nur, wenn der Frame deutlich mehr deckende Pixel hat als das Grundbild.

## Qualitätskontrolle
Jede Animation wurde auf einem Kontaktbogen (7 Rohbilder) geprüft. Typische Probleme und Lösungen:

| Problem | Figuren | Lösung |
|---|---|---|
| Merkmal verschwindet in der Mitte (Linien, Flecken, Lichter, Augen) | Toxmolch, Gigaquak, Optikauz, Radarkauz, Glitchspinne, Klaubär | Nur die gute Hälfte vor und zurück abspielen (`--frames 0,1,2,2,1,0`) |
| Gesicht verzieht sich (Babys mit 32 px) | Kekso, Lumi, Molchi, Quakli, Brummbit, Buddli (bekam Hasenohren!) | Nur saubere Frames verwenden (`--replace` / `--frames`) |
| Grelles Aufblitzen | Skarabäus, Phantomnager | Blitz-Frames weggelassen |
| Hintergrund und Bodenschatten mitgemalt | Bollwerkatz | Neu generiert |
| Schaltkreis-Linien verschwinden | Overclocko (2 Versuche) | Linien aus dem Grundbild in jeden Frame übertragen |
| Maul wird zum schwarzen Loch, Giftbeulen verschwinden | Quakli, Toxikröt | Neu generiert mit „mouth stays closed“ |

Bewusst behalten, weil es zur Figur passt: Hüpfbyte quakt mit offenem Maul, Virulurch lässt die Zunge schnellen, die Kerndrohne „blinzelt“ mit der Linse, der Ur-Glitch hat weiße Glitch-Störungen, die Glutraupe „atmet“ ihre Glut.

## Offen
- Einige ältere Sprites haben mehr als 32 Farben (z. B. Virulurch 74, Spukatz 51, Virulina 51, Prismiez 46, Bollwerkatz 44, Toxmolch 41). Das stammt aus der Zeit vor dem `holes.js`-Fix. Aufräumen: Grundbild mit `reduce32.js` reduzieren, dann `anim_frames.js` und das Blinzel-Bild neu erzeugen. Die Rohframes liegen noch im Scratchpad.
- Angriffsanimationen (Ausholen der Gegner) sind noch nicht umgesetzt.
