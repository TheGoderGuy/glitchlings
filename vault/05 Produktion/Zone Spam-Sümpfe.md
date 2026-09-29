---
tags: [produktion, zone, gegner, steam]
---
# Zone 3: Spam-Sümpfe (29.09.2026)

Wird frei, sobald der Glutkernskarabäus (Firewall-Vulkan) besiegt ist. Gegner 50 % zäher als in Zone 1, viel Virus → **Elektro hat einen Vorteil**.
Daten: `GameData.ZONES.sumpf`, Gegner-Indizes 11–14. Sprites per PixelLab (Stilreferenz Captchakäfer), 32 Farben, Namen geprüft.

| Gegner | Element | HP | Mechanik |
|---|---|---|---|
| Spammücke | Virus | 65 | schnell, **Lebensraub**: heilt sich um 60 % des Schadens, den sie dir zufügt |
| Bannerschnecke | Code | 140 | langsam, **Schleim**: dein Feld + Nachbar werden 4 s klebrig (Bewegung 3× so langsam) |
| Popupblüte | Virus | 110 | **bewegt sich nie**, Kreuz-Biss und schickt Pop-ups (draufsteigen zum Schließen) |
| **Spamkönigin** (Boss) | Virus | 520 | Reihe, Schleim, Spalte, Pop-up; Lebensraub; ab halber HP abwechselnd Schleim und Pop-ups |

Pools: früh Mücke, Schnecke, Blüte · später + Brandmauerassel, Spamlet, Ladebalkenraupe · Elite: Schnecke, Blüte, Brandmauerassel.

## Offen
- Blinzel-Frames der Gegner, eigene Ereignisse für Zone 2 und 3.
- [x] Eigene Musik (siehe unten).

**Musik (29.09.2026):** eigene Stücke je Zone, selbst synthetisiert (`MusicSynth.TRACKS`, Rendern: `godot --headless --path game --script res://tools/render_music.gd -- <stück>`). Firewall-Vulkan: Karte `map_vulkan` (e-Moll, 108 BPM, Blech + Pauken), Kampf `battle_vulkan` (c-Moll, 172 BPM). Spam-Sümpfe: Karte `map_sumpf` (d-Moll, 96 BPM, Flöte, gezupfte Offbeats, Shuffle), Kampf `battle_sumpf` (g-Moll, 160 BPM, Offbeat-Bläser). Cache-Wiesen behalten die alte „epische“ Kampfmusik, der Boss hat überall die „mega“-Bossmusik. `Music.zone_key("map", zone)` wählt das Stück, Karten setzen je Zone an ihrer Stelle fort.
