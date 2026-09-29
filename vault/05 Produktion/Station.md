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

## Linien & Ei-Inhalt (Phase 3b, 29.09.2026)
9 Linien, 40 Formen, 40 Signaturen. Starter bleiben Pixmiez, Funkling, Tröpfel – die übrigen gibt es nur aus Eiern:

| Ei | Inhalt |
|---|---|
| Gewöhnlich | Pixmiez, Funkling, Tröpfel, Kekso (Hamster) |
| Selten | Lumi (Hase), Quakli (Frosch), Molchi (Salamander) |
| Episch | Brummbit (Bär), Kauzbit (Robo-Eule) |
| Legendär | vorerst wie Episch (später Fusionen/Sonderformen) |

Neue Passive: Hamstern, Hasenhaken, Giftbaut, Giftdrüsen, Dickes Fell, Eulenblick. Neue Signatur-Mechaniken: Backentasche (letzten Chip wiederholen), Minen, Abbild (fängt Treffer ab), Zungenschlag (zieht Gegner heran), Scan.
Sprites mit Umlaut im Namen liegen im Spiel als `Huepfbyte_64.png` / `Baertron_64.png` (Umlaute in Dateinamen machen Probleme). Blinzel-Frames fehlen noch für Toxmolch, Bärtron, Titanbrumm.

## Offen
- Labor/Fusion, Bindung/Pflege, dauerhafte Währung.
