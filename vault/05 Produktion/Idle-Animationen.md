---
tags: [produktion, grafik, godot]
---
# Idle-Animationen (30.09.2026)

Alle **127 Figuren** haben eine Idle-Animation: 102 Glitchling-Formen (Otter und Ara seit 03.10.2026) und 25 Gegner, Wächter und Bosse.

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

## Farben aufgeräumt (30.09.2026)
- 68 Sprites korrigiert: 35 Grundbilder hatten mehr als 32 Farben (Virulurch 74, Bugsy 66, Spukatz und Virulina 51 …), bei 33 weiteren brachte das Blinzel-Bild (abgedunkelte Augen) Zusatzfarben mit.
- Werkzeug `tools/sprites/node/fix_colors.js [--dry]`: reduziert das Grundbild (reduce32), färbt Blinzel-Bild und Idle-Frames mit derselben Zuordnung um, Zusatzfarben gehen auf die nächste Palettenfarbe. Optisch kaum ein Unterschied, alle Blinzler bleiben sichtbar.
- Test `test_sprite_colors` prüft jetzt bei jedem Lauf: höchstens 32 Farben je Sprite inklusive Blinzeln und Idle.

## Angriffsanimationen
Fertig seit 05.10.2026 für alle 132 Figuren, Details in [[Angriffsanimationen]]. Die 5 neuen Zonengegner (04.10.2026) haben ebenfalls Idle-Animationen.
