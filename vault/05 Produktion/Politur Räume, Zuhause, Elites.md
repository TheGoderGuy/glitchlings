---
tags: [produktion, ux, grafik, godot]
---
# Politur: Räume als Karten, Zuhause entzerrt, Elite-Aura (08.10.2026)

Drei Punkte aus der [[Game-Design-Analyse 2026-10-08]], die nicht vom Balancing abhängen. Sie entstanden, während der Produzent den neuen Kern ([[Kampf-Kern, Evolution und Reise]]) anspielt.

## Händler, Rastplatz und Ereignisse als Karten (`room_view.gd`)
Vorher waren alle Optionen Textzeilen untereinander.

**Händler**
- Oben die Angebote als Karten: Rolle, Name, Element und Seltenheit, Trefferbild, Schaden und Ladezeit, „Kombo mit …“ oder „Resonanz +X %“, Preis (rot, wenn zu teuer), „verkauft“.
- Module als Karte mit Symbol und Seltenheit.
- Darunter die Dienste als Knöpfe mit Symbol und Preis: Reparatur, Verbessern, Entfernen, Weitergehen.
- Die volle Beschreibung der gewählten Karte steht unten.

**Rastplatz:** drei Karten mit großem Symbol (Ausruhen, Chip verbessern, Deck ausdünnen), darunter „Weitergehen“.

**Ereignisse**
- Die Wahlmöglichkeiten als Karten nebeneinander.
- Das Symbol zeigt die Art der Belohnung (Prägung in Elementfarbe, Modul, Chip, Signatur, Gegner geschwächt, Fragmente, HP).
- Es wird aus dem übersetzten Text abgeleitet, auf Deutsch und Englisch.

**Steuerung:** Alle vier Richtungen springen zur nächstgelegenen Karte (`RoomView.nav_dir`).

## Zuhause entzerrt (`home_sim.gd`)
Vorher ballten sich große Champions und Ultras in der Bildmitte.
- **Abstandhalten:** Wer zu nah steht, wird sanft weggeschoben (`_separate`, Abstand nach Sprite-Breite). Die Tiefe zählt nur wenig (`DEPTH`), denn große Sprites verdecken sich auch versetzt.
- **Spielpartner** stellen sich nach Sprite-Breite auseinander, nicht mehr fest 36 px.
- **Lieblingsplatz:** Mehrere Bewohner desselben Elements verteilen sich im Halbkreis.
- **Bildrand:** Große und schwebende Sprites bleiben im Bild.

## Elite-Aura (`battle_view.gd`, `PixelCanvas.silhouette`)
- Elite-Gegner haben eine pulsierende rote Kontur (Silhouette des aktuellen Animationsbilds, 1 Kunstpixel nach außen) und einen größeren Schatten.
- Glitch-Elites flackern magenta.

**Größere Gegner im Spätspiel** gehen mit der Regel „nur ganzzahlig skalieren“ nicht per Code: 64 px würden zu 128 px und damit größer als eine Feldreihe. Dafür bräuchte es neue 80-px-Sprites für die späten Zonen samt Idle- und Angriffsanimationen. Das ist eine Entscheidung für den Produzenten (PixelLab-Kontingent, Größenstaffel).

## Tests
363 Prüfungen, neu: `test_room_cards_and_home`.
- Karten im Fenster und ohne Überlappung
- Pfeil-Navigation
- Abstand im Zuhause

Screenshots: `--mode=shop|rest|event`, `--mode=home --t=…`, Kampf mit `--elite` bzw. `--glitch`.
