---
tags: [produktion, playtest, steam]
---
# Externer Spieltest (Version 0.2, 29.09.2026)

## Paket bauen
Doppelklick auf `Spieltest_bauen.bat` im Projektordner → `build/Glitchlings_Spieltest.zip` (~40 MB): `Glitchlings.exe` + `LIESMICH.txt`.
Ohne Installation lauffähig. Nicht signiert → Windows-SmartScreen („Trotzdem ausführen“), steht im LIESMICH.
Export-Vorlagen: Godot 4.7.2 (nur Windows-Teil installiert in `%APPDATA%/Godot/export_templates/4.7.2.stable`).

## Was die Tester bekommen
- **Tutorial** im allerersten Kampf: Bewegen → Chip → Ausweichen (2×) → Signatur → frei kämpfen. Gegner greift erst beim Ausweichen-Schritt an; weder Gegner noch Spieler können vor dem Ende fallen.
- **Spieltest-Log** `spieltest_log.csv` (nur lokal, nichts geht ins Netz): Zeit, Version, Monster, Form, Zone, Ergebnis, Etage, gewonnene Kämpfe, Chips, Dauer, Schwierigkeit, letzter Gegner. Optionen → „Spieltest-Log öffnen“.
- 5 Fragen im LIESMICH (Steuerung klar? zweiter Run? Spaß? Frust? Lieblingsmonster?).

## Auswertung
Ergebnisse hier eintragen (je Tester eine Zeile), Ziele aus der [[Prototyp-Spezifikation]]: Steuerung ≥ 80 % klar, ≥ 70 % starten freiwillig einen zweiten Run.

| Tester | Runs | Zweiter Run? | Spaß | Frust | Lieblingsmonster |
|---|---|---|---|---|---|
