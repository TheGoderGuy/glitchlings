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
| `game/assets/logo/digiei_16.png` | 16 px | Von Hand gesetzt mit `tools/logo/digiei_icon16.js`, ohne Leiterbahnen (die wirkten bei 16 px wie Tränen). |
| `game/assets/logo/digiei.ico` | 16/32/64/128/256 | `node tools/logo/make_ico.js`. 256 ist die 128er-Fassung ganzzahlig verdoppelt. Ohne 16 px meldete Windows „No small icon found“. |

## Im Spiel
- **Programmsymbol:**
  - Fenster und Taskleiste nutzen `config/windows_native_icon` (die .ico).
  - Die Windows-.exe bekommt die .ico über `application/icon` im Export.
  - Das Web-Favicon kommt aus `config/icon` (128 px).
- **Titelbildschirm:** Das 64-px-Ei steht links neben dem Schriftzug, beide zusammen sind mittig ausgerichtet (`title.gd`, `LOGO_EGG`).

## Steam-Bilder (03.10.2026)
Alle Bilder liegen in `assets/steam/`, die Übersicht in `assets/steam/_uebersicht.png`. Erzeugt werden sie mit `Godot --path game res://tools/steam_art.tscn` (mit Fenster, `-- --only=header` für ein einzelnes Bild).
- Jedes Bild entsteht in einer kleinen Pixel-Leinwand aus unseren echten Sprites, dem Digi-Ei und dem Silkscreen-Schriftzug. Danach wird es ganzzahlig auf die Steam-Größe vergrößert. Der Code steht in `game/tools/steam_art.gd` und `steam_art_canvas.gd` und wird nicht mit exportiert.
- Motiv: Das Digi-Ei leuchtet in der Mitte auf einem Datenboden. Dahinter stehen Ultras als „wer daraus werden kann“, davor die Babys.
- Schriftzug: Silkscreen Bold mit dunkler Kontur, Cyan links und Magenta rechts (der Glitch-Versatz ist hier dauerhaft sichtbar).

| Datei | Größe | Basis × Faktor | Inhalt |
|---|---|---|---|
| header_capsule / library_header | 920 × 430 | 460 × 215 × 2 | Schriftzug oben, Pyromeles, Hydrolutra, Fulgurlutra, Heliopsitta, Ei, Pixmiez, Bachli |
| small_capsule | 462 × 174 | 231 × 87 × 2 | Schriftzug fast über die volle Breite, kleines Ei darüber |
| main_capsule | 1232 × 706 | 616 × 353 × 2 | Pyromeles und Hydrolutra doppelt groß, Ei, 4 Babys |
| vertical_capsule | 748 × 896 | 374 × 448 × 2 | wie die Haupt-Kapsel, im Hochformat |
| library_capsule | 600 × 900 | 300 × 450 × 2 | Fulgurlutra und Heliopsitta doppelt groß, Ei, Bachli, Pixmiez |
| library_hero | 3840 × 1240 | 960 × 310 × 4 | **ohne Text**: 10 Ultras, Ei im sicheren Bereich in der Mitte, 4 Babys |
| library_logo | 1280 × 192, durchsichtig | 640 × 96 × 2 | Ei und Schriftzug |
| community_icon | 184 × 184 | 92 × 92 × 2 | Ei mit Leuchten |
| client_icon.ico | 16–256 | – | Kopie von `digiei.ico` |

## Offen
- Mindestens 5 Spielszenen-Screenshots in 1920 × 1080 (= 640 × 360 × 3, passt genau zu unserer Basisauflösung).
- Optional: Seitenhintergrund 1438 × 810. Ohne ihn erzeugt Steam ihn aus dem letzten Screenshot.
- Die .exe-Datei mit dem neuen Symbol ist noch nicht gebaut. Das passiert beim nächsten Tester-Zip, und nur dann, wenn der Produzent es sagt.
- ~~Nutzungsrechte von PixelLab prüfen~~ geklärt am 03.10.2026: PixelLab erlaubt jede kommerzielle und nicht-kommerzielle Nutzung, also auch für Logo und Kapseln.
- Bei Steam im Content-Fragebogen angeben, dass Grafiken mit KI-Unterstützung (PixelLab) erzeugt wurden.
