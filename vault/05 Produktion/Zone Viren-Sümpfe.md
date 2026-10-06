---
tags: [produktion, zone, gegner, steam]
---
# Zone 3: Viren-Sümpfe (29.09.2026)

Seit 06.10.2026 **Zone 4**: wird frei, sobald die Tiefenschlange (Kühlwasser-See) besiegt ist (vorher direkt nach dem Vulkan, siehe [[Zonen See und Steppe]]). Gegner 50 % zäher als in Zone 1, viel Virus → **Elektro hat einen Vorteil**.
Daten: `GameData.ZONES.sumpf`, Gegner-Indizes 11–14. Sprites per PixelLab (Stilreferenz Chiffrekäfer); Panzerschnecke, Glitchblüte und Schwarmkönigin am 29.09.2026 ohne Werbe-/Pop-up-Motive neu gezeichnet, 32 Farben, Namen geprüft.

| Gegner | Element | HP | Mechanik |
|---|---|---|---|
| Saugmücke | Virus | 65 | schnell, **Lebensraub**: heilt sich um 60 % des Schadens, den sie dir zufügt |
| Panzerschnecke | Code | 140 | langsam, **Schleim**: dein Feld + Nachbar werden 4 s klebrig (Bewegung 3× so langsam) |
| Glitchblüte | Virus | 110 | **bewegt sich nie**, Kreuz-Biss und streut **Glitch-Sporen** (draufsteigen zum Zertreten, sonst platzen sie nach 3 s) |
| **Schwarmkönigin** (Boss) | Virus | 520 | Reihe, Schleim, Spalte, Sporen; Lebensraub; ab halber HP abwechselnd Schleim und Glitch-Sporen |

Pools: früh Mücke, Schnecke, Blüte · später + Brandmauerassel, Bytewurm, Glutraupe · Elite: Schnecke, Blüte, Brandmauerassel.

## Offen
- [x] Blinzel-Frames: Saugmücke, Panzerschnecke (Stielaugen), Schwarmkönigin. Die Glitchblüte hat keine Augen.
- [x] Eigene Ereignisse (29.09.2026): **Verstopfte Datenleitung** (Chip entfernen | +30 Fragmente, −10 HP), **Irrlicht** (60 %: seltener Chip, sonst −12 HP | +3 Elektro-Prägung), **Giftmoor** (−8 HP: +3 Virus-Prägung | +20 HP), **Quak-Orakel** (20 Fragmente: epischer Chip | +3 Wasser-Prägung und verrät die Evolutionsrichtung).

**Ereignis-Bildschirm (29.09.2026):** Zonenlandschaft als Hintergrund (Vulkan: aufsteigende Glut, Sümpfe: Glühwürmchen), neben dem Monster eine kleine animierte Szene je Ereignis (Amboss mit Funken, Quelle/Moorloch mit Blasen und Dampf, Firewall-Mauer mit Riss, Ascheregen, Irrlicht, verstopfte Datenleitung mit Funken, Orakel-Kröte auf Seerose) und ein Lagerfeuer am Rastplatz. Rastplatz-Texte je Zone.

**Element-Prägung aus Ereignissen:** zählt wie 3 gespielte Element-Chips und lenkt so die Evolution. Vulkan lockt Richtung Feuer, die Sümpfe Richtung Elektro, Virus und Wasser.
- [x] Eigene Musik (siehe unten).

**Musik (29.09.2026):** eigene Stücke je Zone, selbst synthetisiert (`MusicSynth.TRACKS`, Rendern: `godot --headless --path game --script res://tools/render_music.gd -- <stück>`). Firewall-Vulkan: Karte `map_vulkan` (e-Moll, 108 BPM, Blech + Pauken), Kampf `battle_vulkan` (c-Moll, 172 BPM). Viren-Sümpfe: Karte `map_sumpf` (d-Moll, 96 BPM, Flöte, gezupfte Offbeats, Shuffle), Kampf `battle_sumpf` (g-Moll, 160 BPM, Offbeat-Bläser). Cache-Wiesen behalten die alte „epische“ Kampfmusik, der Boss hat überall die „mega“-Bossmusik. `Music.zone_key("map", zone)` wählt das Stück, Karten setzen je Zone an ihrer Stelle fort.
