---
tags: [produktion, zone, gegner, steam]
---
# Zone 2: Firewall-Vulkan (29.09.2026)

Wird frei, sobald der Pop-Up-Tyrann (Cache-Wiesen) besiegt ist. **Zum Testen:** Titel → Optionen → „Test: Alle Zonen freischalten“ (vor dem Launch ausblenden). In der Station per links/rechts wählbar.
Gegner 25 % zäher als in den Cache-Wiesen, viel Feuer → **Wasser-Monster haben einen Vorteil**.
Daten: `GameData.ZONES`, Gegner-Indizes 7–10. Sprites per PixelLab (Stilreferenz Captchakäfer), 32 Farben, Namen geprüft.

| Gegner | Element | HP | Mechanik |
|---|---|---|---|
| Glutmilbe | Feuer | 60 | klein und schnell: Feld, Feld, Reihe |
| Brandmauerassel | Code | 130 | gepanzert, greift **zwei Spalten** an (eine davon deine) |
| Aschefalter | Feuer | 75 | teleportiert, **Lava**: dein Feld + ein weiteres brennen 3 s |
| **Glutkernskarabäus** (Boss) | Feuer | 420 | Reihe, Lava, Spalte; ab halber HP alle 4 s zwei Lavafelder statt Pop-ups |

**Lava (neue Mechanik):** Nach einer orangen Warnung brennt das Feld 3 s. Wer darauf steht, nimmt alle 0,6 s Schaden (40 % des Gegnerschadens). Der Autopilot meidet Lava.

Pools: früh Glutmilbe, Aschefalter, Spamwespe · später + Brandmauerassel, Captchakäfer, Ladebalkenraupe · Elite: Brandmauerassel, Ladebalkenraupe, Captchakäfer.

## Offen
- Blinzel-Frames für die vier neuen Gegner.
- Eigene Musik für Zone 2 (derzeit Karte/Kampf/Boss wie Zone 1).
- Zonen-Ereignisse mit Vulkan-Flair.
