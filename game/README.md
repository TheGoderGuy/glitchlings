# Glitchlings – Godot-Projekt (Steam)

Godot 4.7, GDScript, Renderer „Compatibility“, Basisauflösung 640×360 (ganzzahlig skaliert).

## Starten
- Godot öffnen → „Importieren“ → `game/project.godot` → F5
- oder Kommandozeile: `godot --path game`

## Steuerung
| | Tastatur | Controller (Xbox) |
|---|---|---|
| Bewegen | WASD / Pfeile | Steuerkreuz / linker Stick |
| Chip 1 / 2 / 3 | J / K / L | X / Y / B |
| Signatur-Attacke | Leertaste | A / RT |
| Pause + Deck | Esc / Tab | Start |
| Menü: bestätigen / zurück | Enter / Esc | A / B |

## Aufbau
| Datei | Inhalt |
|---|---|
| `scripts/data/game_data.gd` | Chips, Gegner, Monster (aus dem Browser-Prototyp übernommen) |
| `scripts/battle/battle_state.gd` | Reine Kampflogik ohne Grafik |
| `scripts/run/run_state.gd` | Run: HP, Deck, Fragmente, Prägung, Position auf der Karte |
| `scripts/run/zone_map.gd` | Zonenkarte erzeugen (Etagen, Knoten, Wege) |
| `scripts/run/rooms.gd` | Rastplatz, Ereignisse, Datenhändler (reine Logik) |
| `scripts/ui/map_view.gd` / `room_view.gd` / `result_view.gd` | Karte, Räume, Ergebnis |
| `scripts/battle/battle_bot.gd` | Autopilot für Tests, Screenshots, Balancing |
| `scripts/battle/battle_view.gd` | Ablauf, Eingabe, Zeichnen |
| `scripts/input_setup.gd` | Tastenbelegung + zuletzt benutztes Gerät (Autoload) |
| `scripts/settings.gd` | Optionen, gespeichert in `user://settings.cfg` (Autoload) |
| `scripts/audio/sfx.gd` | Platzhalter-Sounds, zur Laufzeit synthetisiert: `Sfx.play("hit")` (Autoload) |
| `scripts/ui/pixel_canvas.gd` | Basis aller Bildschirme: Schrift, Kästen, Balken, Sprites |
| `scripts/ui/title.gd` | Titelbildschirm + Optionen |
| `scripts/main.gd` | Ablauf: Titel → Karte → Knoten → … → Boss → Ergebnis |

## Tests & Screenshots
```
godot --headless --path game --import
godot --headless --path game --script res://tests/test_battle.gd
godot --path game -- --shot=C:/tmp/karte.png --mode=map --floor=3
```
`--mode` = title | options | map | event | rest | shop | fight | pick | pause | result, `--floor=N` Etage, `--pad` zeigt Controller-Tasten.

## Lizenzen
- Schrift **Silkscreen** – SIL Open Font License 1.1 (`assets/fonts/OFL.txt`), kommerziell frei, muss in den Credits genannt werden.
