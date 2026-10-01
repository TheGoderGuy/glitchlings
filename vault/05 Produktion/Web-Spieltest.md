---
tags: [produktion, spieltest, web, godot]
---
# Web-Spieltest auf itch.io (01.10.2026)

Glitchlings läuft im Browser. Gedacht ist das für Tester, die nichts installieren wollen oder einen Mac haben. Als Plattform haben wir **itch.io** gewählt: privat (Restricted) mit Passwort oder persönlichen Download-Schlüsseln.

## Bauen
- `Web_bauen.bat` (im Projektordner) erzeugt `build/web/` und `build/Glitchlings_Web.zip`, etwa 25 MB.
- Exportvorlage **„Web“** in `game/export_presets.cfg`: ohne Threads (läuft überall, kein SharedArrayBuffer nötig) und mit dem Feature `testbuild`.
- Lokal testen: `node tools/webserver.js` und dann http://localhost:8124 öffnen. Unter `/_itch` läuft das Spiel in einem 1280×720-Rahmen wie auf itch.
- Godot-Exportbausteine für Web (4.7.2) liegen in `%APPDATA%/Godot/export_templates/4.7.2.stable/`.

## Testfassung (`testbuild`)
- Nur **Cache-Wiesen und Firewall-Vulkan** sind spielbar. Viren-Sümpfe und NEST-Kern zeigen „Nicht in dieser Testversion enthalten“, auch über die Test-Option „Alle Zonen freischalten“.
- Der Titel zeigt „TESTVERSION · bitte nicht weitergeben“. Der Hinweis „© 2026 TheGoderGuy“ steht immer da, auch in der Vollversion.
- Die Windows-Spieltest-Version bleibt die Vollversion.
- Test: „Testfassung: nur zwei Zonen …“ in `test_battle.gd`, für Screenshots `--testbuild`.

## Browser-Anpassungen
- „Beenden“ fehlt im Titelmenü, im Browser schließt man den Tab.
- Optionen: „Spieltest-Log **herunterladen**“ statt „öffnen“. Das Log wird als `glitchlings_spieltest_log.csv` gespeichert.
- Der Spielstand liegt im Browser (IndexedDB) und bleibt beim Neuladen erhalten. Wer die Browserdaten löscht, verliert ihn.
- Ist das Fenster kleiner als 640×360, verkleinert das Spiel stufenlos, statt abzuschneiden. Ab 640×360 gilt weiter die ganzzahlige Skalierung (`main.gd _fit_scale`).

## Auf itch.io hochladen (einmalig einrichten)
1. Dashboard → **Create new project**.
2. Titel z. B. „Glitchlings (Testversion)“, **Kind of project: HTML**.
3. **Uploads:** `build/Glitchlings_Web.zip` hochladen und **„This file will be played in the browser“** anhaken.
4. **Embed options:**
   - Viewport **1280 × 720**.
   - „Fullscreen button“ an.
   - „SharedArrayBuffer support“ **aus**, wird nicht gebraucht.
   - „Mobile friendly“ aus.
5. **Pricing:** No payments.
6. **Visibility & access:** **Restricted**. Zugang per Passwort oder, besser, mit persönlichen **Download-Schlüsseln** (Distribute → Download keys): jeder Tester bekommt seinen eigenen, der sich sperren lässt.
7. Für neue Versionen: `Web_bauen.bat` ausführen, im Upload-Bereich die alte Datei ersetzen. Der Link bleibt gleich.

## Getestet (01.10.2026, Chromium)
- Titel, Intro, Starterwahl, Station mit Führung, Zonenwahl mit Sperre, Karte, Kampf mit Tutorial.
- Keine Fehler in der Konsole, Spielstand bleibt beim Neuladen erhalten.
- **Nicht getestet:** Ton im Browser (nicht hörbar geprüft), Firefox und Safari, Controller im Browser.

## Offen
- Englische Tester-Anleitung (README) für die itch-Seite.
- Optional: eigene HTML-Hülle mit Ladebalken im Glitchlings-Stil.
