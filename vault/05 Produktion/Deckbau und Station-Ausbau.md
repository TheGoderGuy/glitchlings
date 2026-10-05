---
tags: [produktion, gameplay, godot]
---
# Deckbau und Station-Ausbau (30.09.2026)

Der Produzent hat 5 Punkte aus der Ideenliste freigegeben („versuche 1–5“). Ziel: Das Deck soll sich besser ausbauen lassen, und die Fragmente aus den längeren Runs (siehe [[Ebenen und Wächter]]) sollen ein dauerhaftes Ziel haben.

## 1. Chips verbessern („Name+“)
- Jeder Chip hat eine verbesserte Fassung, z. B. **Glutball+**: +30 % Schaden (auf 5 gerundet), 20 % kürzere Ladezeit. Chips ohne Schaden (Heilpatch, Blubberschild …) wirken 30 % stärker. Beispiel: Heilpatch+ heilt 33 statt 25.
- Verbessern lässt sich jeder Chip **einmal**. Verbesserte Chips stehen in Gold in der Deckliste.
- **Chipkarte beim Verbessern (05.10.2026, Wunsch des Produzenten):** Am Rastplatz und beim Händler steht oben links immer die Karte des gerade gewählten Chips. Sie zeigt den Namen > Name+, Element und Seltenheit, das Trefferbild, Schaden alt > neu (bzw. „Wirkung +30 %“), Ladezeit alt > neu und die Beschreibung (`room_view._draw_upgrade_card`). Das Trefferbild `_draw_chip_icon` liegt dafür jetzt in `PixelCanvas`.
- **Wo:**
  - Rastplatz: neue dritte Wahl „Chip verbessern“ neben Ausruhen und Deck ausdünnen.
  - Datenhändler: „Chip verbessern (45)“, einmal pro Besuch.
  - Ereignisse: Alte Werkbank, Pusteblumenfeld, Versunkenes Wrack, Kernspeicher.
  - Station: Werkbank.
- Umsetzung: `GameData.chip(id)` liefert die Werte (auch für „+“), `RunState.upgrade_chip()`.

## 2. Synergie-Anzeige
In der Chipwahl steht ein pulsierender goldener Hinweis, z. B. „**Kombo mit Feuersbrunst!**“. Beim Händler steht er in der Beschreibung.

| Auslöser (Tag) | Chips | Profitiert davon |
|---|---|---|
| Brand | Glutball, Funkenregen, Hitzeschild, Glutklinge, Feuersbrunst | Feuersbrunst, Modul Überhitzer, Passiv Giftdrüsen |
| Gift | Virusspritzer, Sporenfalle | Datenfresser, Seuche, Modul Giftkapsel, Passive Giftdrüsen/Giftbaut/Schwebegas |
| Kälte/Betäubung | Eisfeld, Strudel, Tsunami, Kurzschluss, Blackout, Magnetfeld | Frostsplitter, Modul Kältekern |
| Reihe | Byteschlag, Glutklinge, Laserschuss, Flutwelle, Debugger | Wurmloch (zieht den Gegner in deine Reihe) |
| Spalte | Blitzlanze | Magnetfeld (zieht den Gegner in deine Spalte) |

## 3. Riskante Route: Glitch-Elite
- Ab Etage 5 der Zone wird ein Teil der Elite-Knoten (40 %) zur **Glitch-Elite**: magenta, flackerndes Symbol auf der Karte.
- Werte: Elite-Werte, dazu +35 % HP, +3 Schaden, 1,5× Fragmente.
- Belohnung: Chipwahl fast nur Episch (Gewöhnlich 0 / Selten 1 / Episch 3) und ein Modul.
- Sie liegt nie auf dem einzigen Weg, man kann ihr also ausweichen.

## 4. Neue Ereignisse (jetzt 26)
| Zone | Ereignis | Wahl |
|---|---|---|
| Wiesen | Alte Werkbank | Chip verbessern / +20 Fragmente |
| Wiesen | Pusteblumenfeld | zufälliger Chip verbessert / +15 HP |
| Vulkan | Obsidianspiegel | +8 max. HP / +35 Fragmente für −10 HP |
| Vulkan | Glutkäfer-Nest | meist +40 Fragmente (sonst −15 HP) / Funkenregen ins Deck |
| Sümpfe | Versunkenes Wrack | 2 Chips verbessert für −10 HP / +20 Fragmente |
| Sümpfe | Glühwürmchen-Schwarm | 30 % HP heilen / Ladungsfeld + 3 Elektro-Prägung |
| NEST-Kern | Server-Logbuch (Lore: Fehler 0x0 nannte sich selbst „Ur-Glitch“) | +3 Code-Prägung / +30 Fragmente |
| NEST-Kern | Versteckte Glitchlings (drei, die nie geflohen sind) | +20 HP und Signatur halb voll / nächster Gegner geschwächt |
| NEST-Kern | Kernspeicher | Chip verbessern / epischer Chip für −12 HP |

Alle haben eine eigene gezeichnete Szene (wie die bisherigen Ereignisse).

## 5. Station-Ausbau (neuer Reiter „Ausbau“)
| Ausbau | Stufen (Fragmente) | Wirkung |
|---|---|---|
| Werkbank | 120 / 260 | Run startet mit 1 / 2 verbesserten Chips (bevorzugt Angriffe) |
| Vorratslager | 100 / 200 / 350 | +10 / +20 / +30 max. HP zu Beginn |
| Modulschacht | 220 / 420 | Run startet mit einem Modul (Stufe 1 gewöhnlich, Stufe 2 auch selten/episch) |
| Fragmentfilter | 150 / 300 | +15 / +30 % Fragmente aus Kämpfen |
| Brutwärmer | 180 | Eier schlüpfen einen Run früher (mindestens 1) |
| Nest-Erweiterung | 150 | 4. Platz im Brutnest |

Alles zusammen kostet 2.450 Fragmente, bei den längeren Runs etwa 10–15 Runs. Gespeichert wird in `SaveGame.data.upgrades`.

## Kleinkram
- Die Pixelschrift kennt kein „→“. Überall durch „>“ ersetzt, auch im Ergebnisbildschirm („Entwicklung gespeichert“), wo der Fehler schon länger bestand.
- Kartenlegende mit kurzen Namen (Rast, Händler, Glitch) statt abgeschnittener.
- Screenshot-Schalter: `--choose=upgrade`, `--choices=a,b,c`, `--deck=a,b`, `--glitchnode`, `--mode=upgrade`.
- Tests: 261 Prüfungen.

## Offen
- Preise nach Spieltest prüfen (Fragmente pro Run vs. Ausbau-Kosten).
- Weitere Synergien, falls neue Chips dazukommen: `GameData.CHIP_TAGS` / `PAYOFFS` erweitern.
