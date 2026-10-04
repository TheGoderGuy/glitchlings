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

## Version 0.3 (30.09.2026): Orientierung für Tester
Der Produzent wollte vor der Weitergabe ein kleines Tutorial, „was wo zu finden ist“, und eine sichtbare Zonenwahl.
- **Zonenwahl-Bildschirm**: Nach Enter im Team-Reiter öffnet sich „Wohin geht die Reise?“ mit allen 4 Zonen als Karten. Jede zeigt Landschaft, Gefahrenstufe, Aufbau (Ebenen/Wächter) und Beschreibung mit Element-Tipp. Der Boss erscheint erst, wenn die Zone geschafft ist. Gesperrte Zonen haben ein Schloss und den Hinweis, wie man sie freischaltet. Vorher war die Zone nur eine kleine Zeile „< Cache-Wiesen >“ im Team-Reiter.
- **Station-Führung** (7 Schritte): beim ersten Besuch automatisch, danach mit Leertaste bzw. Y/△. Sie hebt jeweils Reiter oder Teamliste hervor: Team, Brutnest, Labor, Monsterdex, Ausbau, „Los geht's“.
- **Karten-Tipp** beim allerersten Run: Wege wählen, Legende, Wächter und Ebenen, Pause mit Deck.
- LIESMICH überarbeitet: Intro überspringen, Run starten, Ebenen und Wächter, speichern und beenden, Controller-Symbole.
- Version 0.3 in `project.godot` und in den Export-Einstellungen.
- **Kampf-Handbuch** (8 Seiten mit gezeichneten Beispielen): Spielfeld, Chips, Ausweichen (rote und goldene Felder, Lava), Elemente (Kreislauf, ×1,5 / ×0,75), Zustände und Kombos, Signatur und Passiv, Entwicklung (12/35/80, 2 Vorsprung), Nach dem Kampf (Chipwahl, Fragmente, Elite, Glitch-Elite, Wächter, Boss-Phasen).
  - Erreichbar über das Titelmenü, das Pause-Menü in Kampf und Karte, die Station und jederzeit mit H bzw. Back/Share. Das Kampf-Tutorial verweist am Ende darauf.
  - Der Select-Knopf pausiert nicht mehr, er öffnet das Handbuch (Pause bleibt auf Start).

## Spiel zurücksetzen (04.10.2026)
Wunsch des Produzenten. **Optionen > Spiel zurücksetzen** (zweimal bestätigen) setzt alles zurück wie bei einer Neuinstallation:
- gelöscht werden Spielstand samt laufendem Run, alle Einstellungen und die Tastenbelegung,
- die Sprache kommt danach wieder aus dem System,
- das **Spieltest-Log bleibt erhalten**, weil darin die Testerdaten stehen.

Danach landet man im Hauptmenü mit der Meldung „Spiel zurückgesetzt …“. „Neues Spiel“ beginnt wieder mit Intro, Starterwahl und Tutorial.

Vorher hieß der Eintrag „Spielstand löschen“. Er löschte nur den Spielstand und war ohne Spielstand ausgegraut.

Technik:
- `TitleScreen.reset_game()`, `Settings.reset_defaults()`. Die Einstellungsdatei wird gelöscht, damit der nächste Start wie der allererste ist.
- Tests leiten `Settings.path` auf `user://test_settings.cfg` um, so wie Spielstand und Log.
- Screenshot: `--mode=options --t=8 --bonus` zeigt die Rückfrage, `--mode=title --bonus` die Meldung. Dabei wird nur angezeigt, nichts wirklich zurückgesetzt.
