---
tags: [produktion, steam, marketing, godot]
---
# Trailer (09.10.2026)

Epischer Trailer für die Steam-Seite (Roadmap Phase 4). **73 s, 1920×1080, 60 Bilder/s, Deutsch und Englisch.**
Fast alles ist echtes Spielmaterial aus der Engine. Kämpfe spielt der Autopilot live, dazu kommen Kino-Bilder im Stil des Intros.

## Dateien
- Aufnahme: `Trailer_aufnehmen.bat` im Projektordner > `build/trailer/Glitchlings_Trailer_DE.avi` und `_EN.avi` (MJPEG, Qualität 0,95, je ca. 700 MB)
- Szene: `game/scripts/ui/trailer_view.gd` (Schnittliste, Texttafeln), `trailer_canvas.gd` (Kino-Bilder und Einblendungen)
- Musik: Stück `trailer` in `music_synth.gd` (120 BPM, 36 Takte à 2 s, One-Shot), gerendert nach `assets/music/trailer.wav`
- Start ohne Aufnahme: `godot --path game -- --play=trailer --lang=de`

## Ablauf (taktgenau, 1 Takt = 2 s)
| Zeit | Bild | Musik |
|---|---|---|
| 0–4 s | Kamerafahrt über den NEST: „Tief im Netz liegt der NEST.“ | Streicher und Chor, leise |
| 4–8 s | Korruption, der Ur-Glitch steigt auf: „Doch ein Fehler zerreißt ihn …“ | Pauken bauen auf |
| 8–12 s | Das Ei pocht im Herzschlag, Risse, Trommelwirbel | Herzschlag-Pauke |
| 12–14 s | Weißblitz, Pixmiez schlüpft: **BRÜTE** | Drop |
| 14–28 s | Kämpfe in allen 6 Zonen, Pixmiez > Rookies > Champions > Ultras: **KÄMPFE**, Chips, Konter mit Fadenkreuz, Signatur „Polarlicht“, goldener Großangriff mit „Ausgewichen! / Überlastet!“ | volles Kampfthema |
| 28–32 s | Echte Evolutions-Szene Glutbyte > Magmawulf: **DEINE SPIELWEISE BESTIMMT DIE EVOLUTION**, Enthüllung auf dem Takt | Atempause, dann Einsatz |
| 32–36 s | Zwei Entwicklungsreihen, je Schlag eine Stufe (Elektro: Pixmiez > Aurorlynx, Wasser: Tröpfel > Leviamander) | Pauken im halben Takt |
| 36–40 s | Stammbaum: ein Baby, drei Wege: **EIN EI. VIELE WEGE.** / **114 FORMEN ZU ENTDECKEN** | |
| 40–48 s | Zuhause (12 Glitchlinge, Abendlicht, Streicheln), Fusion im Labor, goldenes Ei: ein Legendärer schlüpft nur als Umriss (Sternwal, goldener Rand, glühendes Auge, „???“) | hell, hüpfend |
| 48–52 s | Karte der Steppe, Weggabelung: „Jede Reise ist anders“ / „Wähle deinen Weg“ | Aufbau |
| 52–62 s | Boss-Intros auf den Takt: Kernelmantis, Tiefenschlange, Schwarmkönigin, Donnerkondor, zuletzt der Ur-Glitch nur als Schatten mit rotem Rand und glühenden Augen, Name „???“ | Höhepunkt |
| 62–64 s | Glutfenrir gegen den (weiter verhüllten) Ur-Glitch, Signatur „Fenrirbrand“ | |
| 64–73 s | Logo, „Brüten. Kämpfen. Entwickeln.“, **Bald auf Steam**, PC · Steam Deck, fünf Ultras (Glutfenrir, Leviamander, Aurorlynx, Infernokauz, Voltameles) | letzter Schlag, D-Dur, Ausklang |

## Technik
- Spielszenen sind die echten Bildschirme (`BattleScene`, `StationScreen`, `MapScreen`, `RouteScreen`). Kämpfe werden vorgespult (`BattleView.simulate`), danach spielt `BattleView.autopilot` live. Niemand kann gewinnen oder verlieren (`min_e_hp`/`min_p_hp`).
- Besondere Momente sind geplant: Konter (Gegner holt gleich aus, Bot wartet aufs Fadenkreuz), Signatur auf Kommando (`BattleBot.allow_special`), goldener Großangriff läuft schon 0,8 s.
- `Music.locked`: Die Spielszenen wechseln die Musik nicht, das Trailer-Stück läuft durch. `PixelCanvas.cinematic` blendet „Enter weiter“ und andere Bedienhinweise aus.
- Während der Aufnahme sind alle Eingaben abgeschaltet: Ein leicht gedrückter Controller-Trigger hatte sonst Signaturen ausgelöst.
- **Auflösung:** Godot nimmt in der Projektauflösung auf (640×360). Das Skript legt deshalb kurz eine `game/override.cfg` mit 1920×1080 an (steht in `.gitignore`) und löscht sie danach. Das Spiel läuft im Trailer in einem 640×360-Unterfenster, pixelgenau dreifach vergrößert. Das Unterfenster muss ausdrücklich auf scharfe Pixel stehen (`canvas_item_default_texture_filter = NEAREST`, Pixel-Einrasten), denn es übernimmt die Projekteinstellungen nicht: In der ersten Fassung waren deshalb alle vergrößerten Sprites (Babys, Ei, Entwicklungsreihen) verwaschen (Produzent, 09.10.2026).
- Musik mit Lautstärke je Abschnitt (`"gain"` in `music_synth.gd`): leise Welt (−26 dB), Drop (−13 dB), Bosse (−11,5 dB).
- **Geheimnis** (Produzent, 09.10.2026): Ur-Glitch und Sternwal bleiben Umrisse. `_draw_sprite(…, {"mystery": true, "rim": Farbe})` zeichnet dunkle Silhouette + Randlicht, durch glühen nur die Augen (`PixelCanvas.glow_pixels`: Pixel, die sich zwischen Grundbild und Blinzel-Bild unterscheiden). Im Kampf/Intro per `BattleView.mystery_foe`, Name „???“, Element/HP im Intro verborgen.
- Kein „ß“ in Silkscreen-Tafeln, die Pixelschrift zeichnet es wie ein B.

## Nebenbei gefundener Fehler im Spiel
Die Chips **Feuersbrunst, Tsunami und Blackout** nutzen den Ton „special“. Seit den Kampf-Animationen (07.10.) startete genau dieses Ereignis die Signatur-Einblendung. Diese Chips zeigten also eine falsche Signatur, und der Kampf stand 0,85 s still. Jetzt meldet nur die Signatur zusätzlich „signature“ für die Einblendung. Test `test_signature_cutin`, 394 Prüfungen.

## Offen
- MP4 (H.264) für Steam/YouTube: braucht ffmpeg, die AVI-Dateien sind sehr groß
- „Bald auf Steam“ später durch „Jetzt auf die Wunschliste“ ersetzen, sobald die Seite live ist
- Kürzere Fassung (30 s) für soziale Medien möglich: Schnittliste in `trailer_view.gd`
- Musik ist wie alle Stücke selbst synthetisiert (Platzhalter-Qualität)
