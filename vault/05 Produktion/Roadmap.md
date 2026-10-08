---
tags: [produktion, roadmap]
---
# Roadmap (Steam, Godot)

> Seit 28.09.2026, siehe [[Steam-Neuausrichtung]]. Kein fester Zeitplan, jede Phase endet mit einer Ja/Nein-Frage.
> **Stand: 08.10.2026** (Kern überarbeitet, siehe Phase 3½). **Stand davor: 07.10.2026.** Phasen 1–3 und der größte Teil der Inhalte aus Phase 5 sind fertig. Der nächste große Block ist Spieltest, dann Steam-Technik und die Steam-Seite.

## Phase 1: Kampf-Kern in Godot ✔
**Frage: Fühlt sich der Kampf mit Controller besser an als im Browser-Prototyp?** Ja, seitdem wird nur noch in Godot entwickelt.
- [x] Godot-Projekt, 640×360, pixelgenaue Skalierung (28.09.2026)
- [x] 3×3-Raster, Bewegung, Chips mit Ladezeit, Controller und Tastatur, Spielgefühl (Treffer, Wackeln, Hitstop)
- [x] Titel, Optionen, Pause, Pixelschriften Silkscreen + Pixeloid Sans (SIL OFL)
- [x] Idle-Animationen (30.09.) und Angriffsanimationen (05.10.) für alle Figuren – [[Idle-Animationen]], [[Angriffsanimationen]]
- [x] Kampf-Animationen: Materialisieren/Zerfall, Signatur-Einblendung, Siegerpose, Treffer-Reaktion (07.10.) – [[Kampf-Animationen]]
- [x] Rollen-Slots (2× Angriff, 1× Support), Karten mit Trefferbild – [[Rollen-Slots und Einstieg]]
- [x] Effekte je Chip, Flächeneffekte (Lava, Schleim, Strömung, Spannungsfelder) – [[Tester-Feedback Training, Effekte, Gegner]]

## Phase 2: Ein kompletter Run ✔
**Frage: Will man direkt noch einen Run starten?** Laut Testern ja; offen ist noch die Lesbarkeit im Bosskampf.
- [x] Zonenkarte mit Verzweigungen, Ebenen und Wächtern – [[Zonenkarte]], [[Ebenen und Wächter]]
- [x] Chipwahl, Deckbau (verbesserte Chips, Synergien), Module – [[Deckbau und Station-Ausbau]], [[Module]]
- [x] Evolution im Run bis Ultra – [[Evolution im Run]]
- [x] Trainingskampf nach der Starterwahl, Kampf-Handbuch

## Phase 3: Hub & Meta ✔
**Frage: Zieht die Station den Spieler zurück in den nächsten Run?**
- [x] Station: Zuhause, Team, Brutnest (eine Ei-Sorte, nach Runs), Labor (Fusionen), Monsterdex, Ausbau – [[Station]], [[Zuhause in der Station]]
- [x] Spielstand mit Übertragung alter Stände, Run speichern und fortsetzen, Spiel zurücksetzen
- [x] Optionen: Sprache DE/EN, Schwierigkeit (Entspannt bis Korrumpiert), Tastenbelegung, VSync – [[Englisch]], [[Tastenbelegung]], [[Performance]]
- [x] Spieltest-Pakete: Windows-Zip und Web-Fassung (itch.io) – [[Externer Spieltest]], [[Web-Spieltest]]
- [ ] **Spieltest mit dem aktuellen Stand** (6 Zonen, neue Effekte, Zuhause); die Web-Testfassung zeigt bisher nur Wiesen und Vulkan
- [ ] Kampf-Lesbarkeit nach dem Test entscheiden (Zielvorschau, Boss-Atempausen, Boss-Element am Boss, ggf. feste Hauptkarte)

## Phase 3½: Kern überarbeiten (08.10.2026) ✔
**Frage: Trägt die Mechanik den Inhalt?** Die [[Game-Design-Analyse 2026-10-08]] sagte nein: Alles drücken gewann immer, selbst ein Baby schaffte das Finale.
- [x] A Kampf-Kern: Schützen aus der eigenen Reihe, Konter, längere Kämpfe, Mensch-Bot und Balancing-Simulation
- [x] B Evolution mit Folgen: Resonanz, Gaben je Element, gelenkte Chipwahl, Neu prägen, neue Schwellen, große Evolutions-Szene
- [x] Struktur: Ein Run ist eine Reise durch 4 Akte mit Weggabelung – [[Kampf-Kern, Evolution und Reise]]
- [ ] **Spieltest mit dem neuen Kern** (Konter verstanden? Run-Länge? echte Siegquoten)
- [x] Kampffeld je Zone – [[Kampffeld]]
- [ ] Linien-Chips, zwei Währungen, Gegnergrößen (Analyse Phase B/D)

## Phase 4: Steam-Seite & Demo
- [x] Logo und alle Steam-Kapseln – [[Logo]]
- [x] Kino-Intro und -Ende (Material für den Trailer) – [[Opening-Szene]], [[Finale und Ende]]
- [ ] Gewerbe und Steamworks-Konto (Produzent)
- [ ] Store-Texte DE/EN, 5+ Screenshots, Trailer
- [ ] Fragebogen zu KI-Inhalten (PixelLab-Grafiken; Nutzungsrechte geklärt am 03.10.)
- [ ] Steam-Seite live, Wunschlisten sammeln
- [ ] Demo (z. B. Wiesen + Vulkan) für ein Steam Next Fest

## Phase 5: Produktion
- [x] 6 Zonen (Wiesen, Vulkan, Kühlwasser-See, Sümpfe, Hochspannungs-Steppe, NEST-Kern) – [[Zonen See und Steppe]]
- [x] 102 Glitchling-Formen in 13 Linien plus Fusionen, 44 Gegner, Wächter und Bosse
- [x] 45 Chips, 22 Module, 34 Ereignisse, Story-Bosse mit Intros, Ende mit Abspann
- [x] Lokalisierung DE/EN
- [x] Endgame nach dem Abspann: [[Glitch-Protokolle]] (10 Stufen, 07.10.2026)
- [x] [[Legendäre]]: 6 Fabelwesen mit geheimen Bedingungen, Champion + Ultra (07.10.2026)
- [ ] Errungenschaften, Steam Cloud, Steam-Overlay (Steamworks-Anbindung)
- [ ] Steam Deck prüfen (Textgröße, Controller, Leistung), Controller-Tasten frei belegbar
- [ ] Echte Musik und Soundeffekte (bisher selbst synthetisierte Platzhalter)
- [ ] Balancing über alle 6 Zonen nach dem Spieltest

## Phase 6: Release
- [ ] Optional Early Access, danach 1.0
- [x] Lizenzdatei `LIZENZEN.txt` (Schriften, Godot MIT, Engine-Bibliotheken) liegt jedem Build bei (07.10.2026)
