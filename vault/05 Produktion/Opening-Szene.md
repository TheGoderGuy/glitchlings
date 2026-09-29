---
tags: [produktion, story, godot]
---
# Opening-Szene

Läuft beim **neuen Spiel** (kein Spielstand) vor der Starterwahl, ca. 35 s, jederzeit überspringbar (Esc/Start), Enter/A zeigt den Text sofort bzw. blättert weiter. In den Optionen: **„Intro ansehen“**. Code: `game/scripts/ui/opening_view.gd`, Screenshot: `--mode=opening --t=<Sekunde>`.

Die Geschichte folgt [[Welt & Lore]], angepasst an den PC: Das Ei landet auf dem **Desktop** statt auf dem Homescreen.

| # | Bild | Text | Ton |
|---|---|---|---|
| 1 | Terminal: NEST fährt hoch (Zonen, 4.096 Bewohner, „alles friedlich“) | (Terminal tippt) | Ticks |
| 2 | Warnung „Datenkorruption“, dann SYSTEMABSTURZ mit Störstreifen, Bildschirmwackeln | Eines Tages stürzte der NEST ab. | Warnton, Einschlag |
| 3 | Cache-Wiesen: sechs Baby-Glitchlings stehen im Gras, lösen sich nacheinander in Pixelspuren auf; danach flackern Bug, Glitchmotte, Spamlet auf | … flohen in alle Geräte … Zurück blieben wilde, korrupte Daten. | Intro-Musik beginnt |
| 4 | Nachts im Zimmer: Fenster mit Mond, Monitor mit Desktop; ein Ei fällt aus einem Datenspalt auf den Desktop, der Mauszeiger wandert hin | Eines Nachts landet etwas auf deinem Desktop … | Plopp |
| 5 | Nahaufnahme: Ei wackelt, bekommt drei Risse, Lichtstrahlen, weißer Blitz → Starterwahl blendet aus dem Weiß ein | Du bist jetzt Operator. … bring den NEST zurück ins Netz. | Ticks, Aufladen |

**Musik:** `intro` (MusicSynth, 80 BPM, Flöte + Glockenspiel + Streicher, ohne Schlagzeug): 8 Takte wehmütig in d-Moll, 8 Takte hoffnungsvoll in F-Dur. Läuft in der Starterwahl weiter.

**Offen / Ideen:**
- Bilder sind mit einfachen Formen gezeichnet; Zimmer und Ei-Nahaufnahme könnten später als PixelLab-Illustrationen kommen.
- Auswahl in der Starterwahl als „drei Signale aus dem Ei“ inszenieren?
- Eigener Sound für das Schlüpfen / die Risse.
