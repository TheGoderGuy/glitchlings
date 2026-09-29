---
tags: [produktion, meta, station, steam]
---
# Station (Godot, Phase 3a, 29.09.2026)

Der Hub zwischen den Runs. Umsetzung: `game/scripts/meta/save_game.gd` (Autoload `SaveGame`), `game/scripts/ui/station_view.gd`.

## Ablauf
Titel → **erster Start:** Starter wählen → Station · **danach:** direkt Station → Monster wählen → Run → Ergebnis („Was bleibt“) → Station (bereite Eier schlüpfen).

## Dauerhaft (Spielstand `user://savegame.json`)
- **Team:** jedes Monster ist ein Individuum mit Form, Stufe, Lebenszeit-Prägung, Runs/Siegen. Zwei Funklinge können sich verschieden entwickeln.
- **Evolution bleibt erhalten**, auch bei Niederlage (keine Schuldgefühle). Schwellen: Rookie 15, Champion 60 gespielte Chips über alle Runs.
- **Brutnest:** 3 Plätze. Ei nach Runs mit ≥ 2 gewonnenen Kämpfen; Boss-Sieg: 40 % Gewöhnlich, 40 % Selten, 20 % Episch, sonst 75/22/3. Schlüpfen nach abgeschlossenen Runs: Gewöhnlich 1, Selten 2, Episch 3, Legendär 5. Nest voll → kein Ei.
- **Monsterdex:** 18 Formen, Unbekanntes als Silhouette.
- Titel → Optionen → „Spielstand löschen“ (zweimal bestätigen).

## Pro Run (Roguelite, wird zurückgesetzt)
Deck, Fragmente, HP, Ereignis-Boni.

## Offen
- Ei-Seltenheit ist noch ohne Wirkung: alle Pools enthalten die 3 Starter. Mit den Linien Kekso, Lumi, Quakli, Molchi, Brummbit, Kauzbit (Sprites vorhanden) bekommen die Seltenheiten Inhalt.
- Labor/Fusion, Bindung/Pflege, dauerhafte Währung.
