---
tags: [produktion, boss, godot]
---
# Boss-Intros (29.09.2026)

Vor jedem Bosskampf läuft ein kurzes Intro (ca. 4 s), mit Enter/A oder Start überspringbar (0,35 s Sperre, damit der Tastendruck von der Karte nicht durchrutscht). Der Kampf ist währenddessen angehalten. Code: `battle_view.gd` (`Mode.INTRO`), Screenshot: `--mode=bossintro --floor=7 --zone=<zone> --t=<s>`.

| Zeit | Was passiert | Ton |
|---|---|---|
| 0–0,35 s | Bild verdunkelt, rot-schwarze Warnstreifen fahren oben/unten herein, Laufschrift „WARNUNG · BOSS“ | Warnton ×3 |
| 0,5–1,6 s | Boss gleitet als schwarze Silhouette (doppelte Größe) von rechts herein | Aufladen |
| 1,7 s | Weißer Blitz, Bildschirmwackeln, Boss wird farbig, Lichtstrahlen in Elementfarbe | Einschlag, **Bossmusik setzt ein** |
| 1,85 s | Name mit Glitch-Versatz (Cyan/Magenta) fährt von links herein, darunter Titel, Element und HP | |
| 3,7–4,2 s | Überblenden in den Kampf | |

**Titel** (`GameData.FOES[…].title`):
- Kernelmantis – *Wächter des System-Kernels*
- Glutkernskarabäus – *Glühendes Herz des Vulkans*
- Schwarmkönigin – *Herrscherin der Viren-Sümpfe*

Ideen für später: eigener Boss-Schrei je Boss, kurze Zeile („Du kommst nicht an den Kernel heran!“), Intro nur beim ersten Mal lang, danach kürzer.
