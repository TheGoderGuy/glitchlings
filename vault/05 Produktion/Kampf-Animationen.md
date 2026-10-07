---
tags: [produktion, kampf, animation]
---
# Kampf-Animationen (07.10.2026)

Ergänzt [[Idle-Animationen]] und [[Angriffsanimationen]]. Alles in `game/scripts/battle/battle_view.gd`, ohne neue Grafiken (die Pixel kommen aus den vorhandenen Sprites).

## 1. Materialisieren und Defragmentieren
- **Kampfbeginn** (normale Kämpfe, Elite, Glitch-Elite): der Gegner setzt sich in 0,7 s aus Datenpixeln zusammen. Die Pixel fliegen von außen herbei, leuchten erst mint und nehmen dann ihre Farbe an. Bosse und Wächter behalten ihr eigenes Intro.
- **Sieg**: kurzer weißer Blitz, dann lösen sich die Pixel von oben nach unten, treiben auseinander und rieseln mint nach oben weg. Ersetzt das alte Absinken/Verblassen.
- Technik: `_build_enemy_pixels()` liest das Sprite einmal beim Kampfstart im 2er-Raster aus (gespiegelt wie im Kampf), `_draw_materialize` / `_draw_dissolve`.

## 2. Signatur-Einblendung
- Bei der Signatur-Attacke steht der Kampf 0,85 s still. Ein Streifen fährt von links herein: der eigene Glitchling groß (ganzzahlig: Baby x4, Rookie x2, Champion/Ultra x1) mit Umriss in Element-Farbe, Tempolinien, Name der Attacke in groß, „Signatur-Attacke“.
- Erst danach startet die Angriffsanimation. Eingaben (auch vorgemerkte Schritte) werden in der Zeit verworfen.
- `CUTIN`, `cutin_t`, `_draw_cutin()`. Die Simulation (Screenshots, Autopilot-Tests) überspringt die Einblendung.

## 3. Siegerpose
- Nach dem Sieg macht der Glitchling zwei Freudensprünge (12 px), Sterne und Funken steigen auf. Das Kampfende dauert dafür 1,5 s statt 0,65 s (`END_WIN`), bei Niederlage bleibt es bei 0,65 s (`END_LOSE`).

## 4. Treffer-Reaktion
- Kurzes Zittern (±2 px), nach dem weißen Blitz ein roter Nachglimm-Ton (0,3 s, `p_hurt`).
- Schwere Treffer (ab 18 Schaden) lösen einen kurzen Bildstopp aus (`BattleState.freeze`, 0,07 s).
- **Bewusst kein Stauchen/Strecken (Squash & Stretch):** das würde die Pixel ungleichmäßig skalieren und gegen die Regel „nur ganzzahlig skalieren“ verstoßen.

## Prüfen
`Godot --path game -- --shot=bild.png --mode=fight --anim=mat|dissolve|win|cutin|hurt --t=<Sekunden seit Beginn>`

## Offen / Ideen
- Signatur-Einblendung ggf. nur beim ersten Einsatz pro Kampf zeigen, falls sie Testern zu oft kommt.
- Eigener Ton für den Zerfall.
