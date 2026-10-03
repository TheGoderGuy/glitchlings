---
tags: [produktion, grafik, marke]
---
# Logo: das Digi-Ei (03.10.2026)

**Entscheidung des Produzenten:** Die Bildmarke ist ein **Digi-Ei**. Es ist ein cremeweißes Monster-Ei, dessen obere Schale in einem leuchtenden Zickzack-Riss aufbricht. Aus dem dunklen Spalt schauen zwei große türkise Augen. Leuchtende Leiterbahnen mit Knotenpunkten laufen über die untere Schale, und ein paar Funken schweben drumherum.

Bildmarke und Schriftzug sind bewusst zwei getrennte Dinge (Wunsch des Produzenten, 01.10.2026). Der Schriftzug bleibt „GLITCHLINGS“ in Silkscreen mit Cyan-/Magenta-Versatz.

## Weg dorthin
1. **01.10.:** Selbst gezeichnete Entwürfe (Schriftzug, Abzeichen, Monogramm, Schlüpf-Ei). Das Ei gefiel, war aber „noch nicht perfekt“. Diese Dateien liegen in `tools/logo/out/ei_*`, `emblem_*` und `logo_*`.
2. **03.10., ganz neuer Anlauf mit PixelLab:**
   - Erste Runde mit vier Richtungen: Glitch-Katze, Kralle aus dem Ei, Evolutions-Kreis, Augen im Riss. Davon war „Kralle aus dem Ei“ die richtige Richtung, aber ein **Digi-Ei** sollte es sein.
   - Zweite Runde mit vier Digi-Eiern: Schaltkreis, Glitch-Zerfall, Schlüpfling mit Pfote, Element-Mosaik.
   - Gewählt wurden die **Augen aus dem Schlüpfling (ohne Pfote)** zusammen mit dem **Schaltkreis**. Davon gab es drei Varianten, Variante C ist es geworden.
   - Alle Entwürfe liegen in `tools/logo/out/neu_*` und `digiei_*`.

## Dateien
| Datei | Größe | Herkunft |
|---|---|---|
| `game/assets/logo/digiei_128.png` | 128 px | PixelLab Pro Flash, auf 32 Farben reduziert (Rohfassung `assets/logo/digiei_128_pixellab_original.png`) |
| `game/assets/logo/digiei_64.png` | 64 px | PixelLab, mit einer 2:1-Verkleinerung als Vorlage neu gezeichnet. Die reine Verkleinerung ließ Leiterbahnen und Kontur zerfallen. |
| `game/assets/logo/digiei_32.png` | 32 px | Von Hand Pixel für Pixel gesetzt, mit `tools/logo/digiei_icon32.js`. Farben aus der 128er-Fassung, spitzere Zacken, damit der Riss nicht wie eine Sonnenbrille wirkt. |
| `game/assets/logo/digiei.ico` | 32/64/128/256 | `node tools/logo/make_ico.js`. 256 ist die 128er-Fassung ganzzahlig verdoppelt. |

## Im Spiel
- **Programmsymbol:**
  - Fenster und Taskleiste nutzen `config/windows_native_icon` (die .ico).
  - Die Windows-.exe bekommt die .ico über `application/icon` im Export.
  - Das Web-Favicon kommt aus `config/icon` (128 px).
- **Titelbildschirm:** Das 64-px-Ei steht links neben dem Schriftzug, beide zusammen sind mittig ausgerichtet (`title.gd`, `LOGO_EGG`).

## Offen
- Die .exe-Datei mit dem neuen Symbol ist noch nicht gebaut. Das passiert beim nächsten Tester-Zip, und nur dann, wenn der Produzent es sagt.
- Für Steam werden später gebraucht: Kapselbilder in mehreren Größen, Community-Symbol 184 px und Bibliotheks-Logo. Die kommen in Phase 4 (Steam-Seite).
- Nutzungsrechte von PixelLab für kommerzielle Nutzung vor dem Launch prüfen. Das gilt auch für das Logo.
