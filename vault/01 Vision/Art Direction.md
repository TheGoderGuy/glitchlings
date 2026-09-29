---
tags: [vision, art]
status: Alle 25 Monster, 4 Gegner und 3 Ei-Sorten in 32×32 fertig
---
# Art Direction

### Alle 25 Monster
![[sheet_alle25.png]]

### Basisfiguren und Gegner
![[sheet_basis.png]]

### Evolutionen
![[sheet_evolutionen.png]]

### Im Kampf
![[kampf-32px.png]]

## Neue Richtung: Stil wächst mit der Stufe (Entscheidung nach Playtest)
**Feedback:** Die bisherigen Monster sind cool, aber nicht massentauglich. Zu viele Gegenstände, alle haben dasselbe Gesicht, kein Körper.

**Entscheidung:** Jede Linie basiert auf einem **Tier mit einem digitalen Merkmal**. Der Stil entwickelt sich mit der Stufe: niedlich am Anfang, cool am Ende. Das Sprite wird mit jeder Stufe größer, die Pixelgröße bleibt gleich.

![[feuerfuchs-linie-final.png]]

![[kampf-ultra.png]]

| Stufe | Leinwand | Stil |
|---|---|---|
| Baby | 32×32 | Niedlich/Chibi: Kopf ca. 60 % der Höhe, große runde Augen, winzige Nase |
| Rookie | 64×64 | Niedlich, aber detailliert: Dreiviertelansicht, große runde Augen mit Iris-Verlauf, kurze Schnauze |
| Champion | 80×80 | Übergang: stehend auf vier Beinen, mandelförmige Augen, Mähne, erste Leuchtlinien |
| Ultra | 96×96 | Cool: imposant, Rüstungsteile, mehrere Schweife, leuchtende Schaltkreis-Linien |

**Warum:** Jüngere lieben die niedlichen Startformen, Ältere erarbeiten sich die coolen Ultra-Formen. Die Evolution wird dadurch auch optisch zur echten Belohnung.

**Referenz Digimon UP (Bandai Namco, 2026):** Aus einem Screenshot gemessen sind die Rookie-Sprites dort etwa 60 bis 80 Pixel hoch, geschätzt auf einer Leinwand von ca. 64×64 (Konturen 1 bis 2 Pixel, Screenshot verkleinert, also ± 10 %). Unsere Staffel orientiert sich daran. Klassische V-Pets nutzen 16×16, die Farbgeräte bis 48×48.

**Darstellung im Kampf:** Ab Rookie gilt eine feste Pixelgröße (ca. 1 Bildpunkt pro Kunstpixel bei 400 px Breite). Die Füße stehen immer auf der Plattform, größere Formen ragen nach oben über das Feld hinaus. So wirkt jede Stufe sichtbar größer.

**Gegner** sind digitale Monster und Maschinen (Käfer, Motten, Würmer, Mecha-Insekten, Pflanzen-Monster): Sie sind die korrumpierten Daten, die Tiere sind die Helden. **Keine Internet-/Werbe-Anspielungen** – keine Pop-up-Fenster, Spam, Werbebanner, Cookies, Captchas, Ladebalken (Entscheidung Produzent, 29.09.2026).

**Regel (Entscheidung Produzent, 27.09.2026):** Monster sind echte Tier-Kreaturen im Digimon-/Yu-Gi-Oh-Stil. Das Digitale steckt nur in Körpermerkmalen – Leuchtlinien, Muster, Energie, Element-Effekte. **Keine Gegenstands- oder Kostüm-Konzepte** (Pop-up-Fenster als Körperteil, Trojaner-Holzpferd, Detektivmütze, Keks-Emblem usw. wurden verworfen).

### Geplante Linien
| Linie | Tier | Digitales Merkmal |
|---|---|---|
| Pixmiez | Katze (Feuer-Linie: Blazebit → Glutluchs → Pyrolynx) | Schweif zerfällt in Pixel |
| Funkling | Welpe / Wolf | Flammenohren und -mähne |
| Tröpfel | Axolotl | Kiemen wie ein Ladekreis |
| Kekso | Hamster | Speichert Daten als Kekse in den Backen |
| Lumi | Hase | Leuchtende Cursor-Ohren |
| Quakli (früher Spamlet) | Frosch | Pfeilgiftfrosch mit Leuchtflecken; Rookies Virulurch (Virus) / Hüpfbyte (Code) |

**Hinweis:** Die Feuerfuchs-Linie erreicht etwa 70 % Digimon-UP-Niveau. Für das fertige Spiel sollten Rookie bis Ultra von einem Pixel-Artist finalisiert werden (mehr Schattierungsstufen, lebendigere Posen, Animationen). Die Prototyp-Sprites sind Richtungsvorgaben.

## Grundidee
**Freundliche Pixel-Kreaturen in einer weichen, pastelligen Datenwelt.** Retro genug für Nostalgiker, rund und niedlich genug für Kinder. Der Glitch-Look ist Würze, nicht Hauptgericht.

## Sprites
- **Kampf-Sprites: 32×32 Pixel**, fertig für alle 25 Monster, 4 Gegner und 3 Ei-Sorten (`06 Datenbank/Sprites`). Für Monsterdex und Evolutionsszenen später **64×64**.
- Im Spiel nur in **ganzzahligen Vielfachen** skalieren (2×, 3×, 4×), sonst werden Pixel ungleich breit.
- Licht kommt immer von **oben links**. Vier Farbstufen pro Material plus Kontur.
- **Dithering nur an Farbübergängen**, nie flächig. Flächiges Karo-Dithering wirkt auf kleinen Bildschirmen wie Rauschen.
- Schatten wandern leicht Richtung Violett, Lichter Richtung Gelb. Das hält die Palette warm und zusammenhängend.
- **Kontur: fast schwarz / sehr dunkel** (Entscheidung Produzent, 27.09.2026 – nach Vergleich mit farbiger Kontur am PixelLab-Funkling: schwarz wirkt knackiger und hebt sich besser vom dunklen Hintergrund ab). Ältere Sprites mit farbiger Kontur (Feuerfuchs-Linie) werden bei Gelegenheit angeglichen.
- Idle-Animation: 1 Pixel auf und ab (kein Stauchen, das verwischt Pixel) plus Blinzel-Frame.
- Evolutionen behalten die **Silhouette der Basisform** und ergänzen ein Merkmal (Flammenkamm, Ziegelhelm, Virus-Fühler, Regenbogen). So bleibt die Verwandtschaft erkennbar.
- **Immer Kontur**, 1 Pixel, fast schwarz (siehe oben).
- **Palette max. 32 Farben pro Sprite.** KI-Sprites (PixelLab) werden nach dem Download lokal auf 32 Farben reduziert – optisch kein Unterschied, aber nötig fürs `SPR`-Palettenformat.
- Drei Töne pro Körper: Licht oben links, Grundfarbe, Schatten unten.
- Große Augen mit weißem Glanz, rosa Wangen bei freundlichen Monstern. Gegner bekommen schräge Augen statt Wangen.
- Silhouette muss auch als einfarbiger Schatten eindeutig sein (Monsterdex-Silhouetten!).
- Idle-Animation: Atmen (leichtes Stauchen) und Blinzeln. Evolutionen dürfen mehr Frames haben.

## Farben der Elemente
| Element | Farbe |
|---|---|
| Neutral | `#B8B0DD` |
| Feuer | `#FF8A4C` |
| Code | `#58D68D` |
| Wasser | `#4CC3F0` |
| Licht | `#FFD84D` |
| Virus | `#C77DFF` |

Eine Evolution übernimmt die Farbe ihres Elements als Grundfarbe. So erkennt man die Prägung auf einen Blick.

## Kampffeld
![[kampf-hell.png]]
- Eigene Seite mint, Gegnerseite rosa, dazwischen ein pulsierender Datenstrom.
- Plattformen mit sichtbarer Dicke und Schatten unter den Figuren geben Tiefe ohne 3D.
- **Jede Zone hat einen eigenen Hintergrund** (Cache-Wiesen: Hügel & Wolken, Viren-Sümpfe: violett-grün mit Glühwürmchen).
- Warnfelder immer Koralle mit weißem Ausrufezeichen. Diese Farbe ist für Gefahr reserviert.

## Effekte
- Projektile mit leuchtendem Schweif in Elementfarbe
- Trefferring bei jedem Treffer, gold bei "Effektiv!"
- Roter Bildschirmrand, wenn der Spieler Schaden nimmt
- Schadenszahlen in Pixelschrift mit dunkler Kontur

## Schrift
- **Silkscreen** (Pixel) für Titel, Zahlen, Schadenszahlen
- **Nunito** (rund) für alle Fließtexte und Chips, damit es auch für Kinder gut lesbar bleibt

## Werkzeuge für das Team
- Aseprite für Sprites und Animationen. Die PNGs in `06 Datenbank/Sprites` (32×32 und 8× vergrößert) lassen sich direkt öffnen und weiterbearbeiten.
- Paletten-Datei aus dieser Notiz als Startpunkt
- Referenz: der [[Prototyp-Spezifikation|Browser-Prototyp]]

## Abgrenzung
Kein Stil, der mit Pokémon oder Digimon verwechselt werden kann: keine Pokébälle, keine Digivices, keine ähnlichen Silhouetten. Die Technik-Motive (Fenster, Cursor, Cookies, Ladekreise) sind unser eigenes Vokabular.
