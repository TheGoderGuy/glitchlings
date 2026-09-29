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
- [x] Blinzel-Frames: Glutmilbe, Brandmauerassel, Aschefalter, Glutkernskarabäus (glühende Augen dunkeln kurz ab).
- [x] Eigene Ereignisse (29.09.2026): **Glut-Schmiede** (−10 HP: gewöhnlicher Chip → episch | +15 Fragmente), **Heiße Quelle** (+25 HP | +3 Feuer-Prägung), **Riss in der Firewall** (nächster Gegner −25 % HP | 15 Fragmente: Firewall-Chip + 5 max. HP), **Ascheregen** (50 %: epischer Chip, sonst −15 HP | +10 Fragmente). Dazu die 5 allgemeinen Ereignisse; Datenpaket, Bit-Brunnen und Cookie-Spur gibt es nur in den Wiesen.
- [x] Eigene Musik für Zone 2 (siehe unten).

**Musik (29.09.2026):** eigene Stücke je Zone, selbst synthetisiert (`MusicSynth.TRACKS`, Rendern: `godot --headless --path game --script res://tools/render_music.gd -- <stück>`). Firewall-Vulkan: Karte `map_vulkan` (e-Moll, 108 BPM, Blech + Pauken), Kampf `battle_vulkan` (c-Moll, 172 BPM). Spam-Sümpfe: Karte `map_sumpf` (d-Moll, 96 BPM, Flöte, gezupfte Offbeats, Shuffle), Kampf `battle_sumpf` (g-Moll, 160 BPM, Offbeat-Bläser). Cache-Wiesen behalten die alte „epische“ Kampfmusik, der Boss hat überall die „mega“-Bossmusik. `Music.zone_key("map", zone)` wählt das Stück, Karten setzen je Zone an ihrer Stelle fort.
- Zonen-Ereignisse mit Vulkan-Flair.
