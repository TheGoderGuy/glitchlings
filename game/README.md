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

## Aufbau
| Datei | Inhalt |
|---|---|
| `scripts/data/game_data.gd` | Chips, Gegner, Monster (aus dem Browser-Prototyp übernommen) |
| `scripts/battle/battle_state.gd` | Reine Kampflogik ohne Grafik |
| `scripts/battle/run_state.gd` | Run: HP, Deck, Prägung, Chipwahl |
| `scripts/battle/battle_bot.gd` | Autopilot für Tests, Screenshots, Balancing |
| `scripts/battle/battle_view.gd` | Ablauf, Eingabe, Zeichnen |
| `scripts/input_setup.gd` | Tastenbelegung (Autoload) |

## Tests & Screenshots
```
godot --headless --path game --import
godot --headless --path game --script res://tests/test_battle.gd
godot --path game -- --shot=C:/tmp/kampf.png --mode=fight --room=3 --sim=6
```
`--mode` = fight | pick | pause | result, `--pad` zeigt Controller-Tasten.
