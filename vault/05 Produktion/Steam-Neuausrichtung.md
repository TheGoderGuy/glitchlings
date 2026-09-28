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

## Technische Eckpunkte
Siehe [[Tech Stack]]. Basisauflösung **640×360**, ganzzahlige Skalierung (1080p ×3, 1440p ×4, 4K ×6, Steam Deck ×2).

## Offene Punkte
- [ ] Nutzungsrechte PixelLab für kommerzielle Nutzung klären + Steam-KI-Offenlegung vorbereiten
- [ ] Markenrecherche „Glitchlings“ (DPMA/EUIPO, Steam-Suche)
- [ ] Musik & Sound: Wer macht das? (Auftrag, Asset-Pakete, lizenzfreie Musik)
- [ ] Gewerbe anmelden, bevor die Steam-Seite live geht (Steamworks braucht Steuer-/Bankdaten)
