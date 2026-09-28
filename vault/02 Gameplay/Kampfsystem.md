---
tags: [gameplay, kampf]
---
# Kampfsystem

## Grundprinzip
Echtzeit-Kampf auf zwei 3×3-Feldern (Megaman-Battle-Network-Stil), für Touch vereinfacht.

```
  SPIELER          GEGNER
 [ ][ ][ ]   |   [ ][ ][ ]
 [ ][X][ ]   |   [ ][O][ ]
 [ ][ ][ ]   |   [ ][ ][ ]
```

## Steuerung
- **Swipe** → Feld wechseln (ausweichen, positionieren)
- **Tipp auf eigenes Feld** → Direktsprung dorthin
- **Tipp auf ladenden Chip** → vormerken, feuert automatisch
- **Tap auf Chip** → Chip einsetzen
- Keine virtuellen Sticks, alles einhändig spielbar (Bahn-tauglich!)

## Chips
- Hand: **3 Chips** gleichzeitig sichtbar, benutzte Chips laden nach (2–4 Sek.).
- Deck startet mit 8 Chips, wächst im Run durch 1-aus-3-Auswahl.
- Kategorien:

| Kategorie | Beispiel | Funktion |
|---|---|---|
| Angriff | Pixelstrahl | Schaden in einer Reihe |
| Schild | Firewall | Blockt Treffer |
| Falle | Bug-Mine | Explodiert, wenn Gegner das Feld betritt |
| Buff | Übertakten | +50 % Tempo für 5 Sek. |
| Beschwörung | Mini-Bot | Kleiner Helfer für 10 Sek. |
| Feldeffekt | Datenflut | Verändert Felder (Eis, Lava, Gift) |

→ Alle Chips: [[Chip-Übersicht]]

**Transparenz:** Der nächste Chip aus dem Stapel ist immer sichtbar, das Deck jederzeit einsehbar (pausiert). Details: [[Prototyp-Spezifikation#Deck-Transparenz]]

## Elemente (Stein-Schere-Papier)
**Feuer > Code > Wasser > Feuer**, dazu **Licht ↔ Virus** (gegenseitig stark).
Einfach genug für Kinder, tief genug für Deckbau.

## Run-Struktur
1. Raum 1–4: normale Gegner, jeweils 20–40 Sek.
2. Raum 3 oder 4: Event-Raum (Shop, Heilquelle, Risiko-Truhe)
3. Raum 5: Elite oder Mini-Boss
4. Boss: 60–90 Sek., eigene Mechanik
5. Belohnungsbildschirm → [[Core Loop]]

## Verlieren
- Beute bis zum Tod wird zu 50 % behalten.
- Prägung wird voll behalten → Fortschritt bei [[Evolution & Prägung]] geht nie verloren.
- Near-Miss-Anzeige: "Boss hatte noch 6 % HP!"
- Optionaler Revive per Werbung (1× pro Run) → [[Monetarisierungsmodell]]

## Balancing-Leitplanken
- Ein Run darf **nie** über 5 Minuten dauern.
- Frühe Zonen: 80 % Siegquote. Späte Zonen: ~40–50 %.
- Kein Chip darf über Geld stärker werden als über Spielen.
