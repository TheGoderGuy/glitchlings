---
tags: [produktion, entscheidung, steam]
---
# Steam-Neuausrichtung (28.09.2026)

**Entscheidung:** Glitchlings wird kein Mobile-F2P-Spiel mehr, sondern ein **Premium-Spiel für Steam**.
Switch ist vorerst gestrichen. Team: Produzent + Claude. Engine: **Godot 4**. Kein Zeitdruck.

## Was bleibt
- Kampfsystem: 3×3-Raster pro Seite, Echtzeit, Chips, Signatur-Attacken ([[Kampfsystem]])
- Evolution nach Spielweise / Prägung ([[Evolution & Prägung]]), unser Alleinstellungsmerkmal
- Labor mit versteckten Fusionen, Monsterdex, Bindung & Pflege ([[Station-Leben]])
- Art Direction „Tier + digitales Merkmal“, Größenstaffel 32/64/80/96 ([[Art Direction]])

## Was wegfällt oder umgebaut wird
| Mobile (alt) | Steam (neu) |
|---|---|
| Echtzeit-Eier, Werbung halbiert Brutzeit | Eier schlüpfen nach abgeschlossenen Runs: **Gewöhnlich 1 Run … Legendär 4–5 Runs** (bestätigt 28.09.2026; Vorschlag dazwischen: Selten 2, Episch 3) |
| Echtzeit-Expeditionen | Expeditionen laufen, während man einen Run spielt |
| Battle Pass, Shop, Abo, Ei-Ziehungen | Einmalkauf ~15–20 €, später evtl. DLC mit neuen Zonen/Monstern |
| Tägliche Rückkehr-Hebel ([[Engagement-Hebel]]) | „Nur-noch-ein-Run“: Neugier auf Evolutionen, Fusionen, neue Chips |
| Touch-/Wischsteuerung | Controller-first (Steam Deck), Tastatur als Alternative |

Überholt, nur noch Archiv: [[Monetarisierungsmodell]], [[Engagement-Hebel]], [[KPIs & Metriken]], [[Soziale Features]].

## Spielstruktur: Hub + Runs
- **Station = Hub.** Team verwalten, brüten, fusionieren, Dex, Chips/Deck vorbereiten.
- **Run = Weg durch eine Element-Zone** auf einer verzweigten Karte (Kämpfe, Elite, Events, Rast, Shop, Boss).
  Nach jedem Kampf 1-aus-3-Chipwahl, am Ende der Zone ein Boss.
- **Meta-Fortschritt zwischen Runs:** Monster behalten Prägung und entwickeln sich dauerhaft weiter, neue Eier,
  neue Chips im Pool, neue Zonen.
- **Story leicht:** Die Daten-Welt wird von einer Korruption befallen, jeder Zonen-Boss enthüllt ein Stück Lore
  ([[Welt & Lore]]). 5 Zonen + Finale, danach Endgame (höhere Schwierigkeitsstufen, Dex komplett).
- Zielumfang zum Release: **5 Zonen, ~100 Monster-Formen, ~80 Chips, 15–25 Stunden**.

## Kampf-Änderungen gegenüber dem Browser-Prototyp
- **Glitch-Sporen/Bitmilben des Bosses** werden geschlossen, indem man auf ihr Feld tritt (statt antippen) – funktioniert mit Controller und ist eine Ausweich-Entscheidung.
- Bewegungseingaben während des Bewegungs-Cooldowns werden gepuffert statt verworfen.
- Chip-Tasten: Controller X/Y/B, Signatur A; Tastatur J/K/L, Leertaste.

## Schwierigkeit (Optionen)
| Stufe | Gegner-HP | Gegnerschaden | Vorwarnung |
|---|---|---|---|
| Entspannt | 80 % | 70 % | +0,25 s |
| Normal | 100 % | 100 % | ±0 |
| Knackig | 125 % | 125 % | −0,1 s |

## Technische Eckpunkte
Siehe [[Tech Stack]]. Basisauflösung **640×360**, ganzzahlige Skalierung (1080p ×3, 1440p ×4, 4K ×6, Steam Deck ×2).

## Offene Punkte
- [x] Nutzungsrechte PixelLab geklärt (03.10.2026, Produzent): jede kommerzielle und nicht-kommerzielle Nutzung erlaubt
- [ ] Steam-KI-Offenlegung vorbereiten (Content-Fragebogen: Grafiken mit PixelLab erzeugt)
- [ ] Markenrecherche „Glitchlings“ (DPMA/EUIPO, Steam-Suche)
- [ ] Musik & Sound: Wer macht das? (Auftrag, Asset-Pakete, lizenzfreie Musik) – bis dahin 4 selbst synthetisierte Chiptune-Platzhalter (`game/scripts/audio/music_synth.gd`), jederzeit durch WAV/OGG gleichen Namens in `game/assets/music/` ersetzbar
- [ ] Gewerbe anmelden, bevor die Steam-Seite live geht (Steamworks braucht Steuer-/Bankdaten)

## Musik (Stand 29.09.2026)
Feedback Produzent: Die erste Chiptune-Fassung klang zu sehr nach NES; gewünscht ist der Stil von **Pokémon Gen 3–6**. Die **Kampfmusik der ersten Fassung ist „episch“** und bleibt unverändert (`battle.wav`).
Neuer Synthesizer (`game/scripts/audio/music_synth.gd`): Streicher-Flächen, Blech mit Filter-Anschlag, Glockenspiel, gezupfter Bass mit treibenden Achtel-Oktaven, Pauke, Schlagzeug mit Wirbeln und Becken, Gegenstimme im B-Teil, Stereo-Ping-Pong-Echo, 32 kHz Stereo. Aufbau Intro → A → B, Schleife nur über A+B.
- Neu: Titel (Fanfare, C-Dur), Karte (beschwingt, G-Dur), Boss (d-Moll, Aufhellung nach D-Dur im B-Teil)
- Zum Vergleich: `battle_neu.wav` (neue Kampf-Fassung, wird im Spiel nicht benutzt)
- Eigene Melodien, nur der Stil ist angelehnt – keine Pokémon-Melodien übernehmen (Urheberrecht).
- Feedback 29.09.: **Bossmusik „mega“** (bleibt). Die Wechsel durch die kurzen Kämpfe wirkten „nicht rund“ → Lösung wie in Pokémon:
  **Siegesfanfare** nach jedem gewonnenen Kampf (läuft während der Chipwahl in einer ruhigen Schleife weiter),
  **Kartenmusik läuft an derselben Stelle weiter** statt neu zu starten, Kämpfe starten knackig ohne Einblenden, die Karte blendet weich ein (1,2 s).
