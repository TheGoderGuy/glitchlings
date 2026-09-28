---
tags: [produktion, technik]
---
# Tech Stack

> Stand 28.09.2026: Steam-Premium, siehe [[Steam-Neuausrichtung]]. Die alte Mobile-Planung (Unity, Ads, Backend) ist verworfen.

## Engine: Godot 4 (GDScript)
- Kostenlos, Open Source, stark in 2D und Pixel-Art
- Export Windows (+ Linux/Steam Deck nativ möglich)
- Steam-Anbindung über **GodotSteam** (Achievements, Cloud-Saves, Overlay)

## Darstellung
- Basisauflösung **640×360**, Stretch-Modus `viewport`, **nur ganzzahlige Skalierung** (Rand schwarz, falls nötig)
- Texturfilter `Nearest`, keine Subpixel-Bewegung bei Sprites
- Sprites aus `assets/sprites/` (Originalgröße) direkt importieren, Animationen als Spritesheets

## Eingabe
- Controller-first (Xbox/PlayStation/Steam Deck), Tastatur gleichwertig, Maus für Menüs
- Alle Aktionen über die Godot-InputMap, frei belegbar

## Kein Backend
- Speicherstände lokal (`user://`), Steam Cloud für Synchronisation
- Kein Server, keine Accounts, keine Analytics-Pflicht

## Werkzeuge
- Git für Versionsverwaltung
- Sprite-Pipeline weiterhin `tools/sprites/node/` (32 Farben, schwarze Kontur), später Export nach Godot
- Tests: GUT (Godot Unit Test) für Kampflogik
