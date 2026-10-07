---
tags: [produktion, monster, endgame, godot]
---
# Legendäre Glitchlinge (07.10.2026)

**Entscheidungen des Produzenten:**
- Je Zone gibt es ein Fabelwesen mit einer geheimen Bedingung.
- Sie schlüpfen als Champion und können sich zur Ultra-Form entwickeln.
- Die sechs Fabelwesen und ihre Bedingungen hat er freigegeben.

## Ablauf
- Erfüllt man die Bedingung beim **Sieg über den Zonen-Boss**, erscheint ein **leuchtendes Ei** im Brutnest.
  - Es darf zusätzlich zu den Nestplätzen liegen und schlüpft nach 1 Run.
  - Jeden Legendären gibt es nur einmal (`legends` im Spielstand).
- Legendäre schlüpfen auf **Champion-Stufe** (80 px) und entwickeln sich ab 80 Element-Chips zur **Ultra-Form** (96 px), wie die normalen Linien.
- **Monsterdex:** Die Legendären stehen in eigenen Reihen mit goldenem Rahmen. Zu einem unbekannten Legendären steht ein **Gerücht**, sobald seine Zone erreichbar ist. Vorher steht dort nur „Ein Gerücht darüber hörst du in …“.
- Sie kommen nicht aus normalen Eiern.

| Zone | Champion > Ultra (EN) | Element | Passiv | Geheime Bedingung |
|---|---|---|---|---|
| Wiesen | Glimmhirsch > Lumicervus (Glimmerstag) | Neutral | Lichtschein: heilt alle 6 s 4 HP | Boss mit einem **Baby** besiegen (keine Entwicklung im Run) |
| Vulkan | Glutkirin > Pyrokirin (Emberkirin) | Feuer | Glutmähne: Angreifer fangen Feuer | Boss mit **mindestens 6 Feuer-Chips** im Deck |
| See | Sternwal > Astralwal (Starwhale, Astralwhale) | Wasser | Sternenmeer: Flächen wirken nicht | Boss, **ohne je von einer Strömung mitgerissen** zu werden |
| Sümpfe | Toxilisk > Miasmalisk | Virus | Bannblick: Gegner 15 % langsamer | Schwarmkönigin **ohne Heilpatch** im Bosskampf |
| Steppe | Funkengreif > Donnergryph (Sparkgriffin, Thundergryph) | Elektro | Sturmschwingen: doppelt so schnell | Im Bosskampf **10 s auf Spannungsfeldern**, dann gewinnen |
| Kern | Chiffrasphinx > Algosphinx (Ciphersphinx) | Code | Rätselwächter: jeder 3. Treffer prallt ab | Ur-Glitch mit der **Signatur-Attacke** besiegen |

Jede Form hat eine eigene Signatur-Attacke. Beispiele: Sternenflut/Nebelgesang mit Schutzblase, Bannstrahl/Steinerner Blick mit Starre, Ur-Algorithmus lädt alle Chips. Dazu kommen ein Startdeck mit 6 Angriffen und 2 Support-Chips sowie eine Reaktion beim Streicheln im Zuhause. Sternwal und Astralwal schweben dort.

## Grafik
- 12 Sprites mit PixelLab Pro Flash. Die Champions haben bestehende Champions als Stilreferenz, die Ultras ihren eigenen Champion (`source_image_id`), damit die Entwicklung erkennbar bleibt.
- Alle sind auf 32 Farben reduziert. Lücken bis 3 Pixel wurden mit der häufigsten Nachbarfarbe gefüllt; größere, gewollte Lücken bleiben.
- Alle haben Blinzel-Bilder sowie Idle- und Angriffsanimationen. Als Vorlage für die Animationen diente direkt die PixelLab-Download-URL, ohne vorher zu pushen.
- Dezent geratene Angriffe: Glimmhirsch, Glutkirin, Chiffrasphinx. Das Vorschnellen im Kampf gleicht das aus.
- Etwa 85 Generierungen.

## Technik
- Daten:
  - `GameData.LEGENDS` (Zone, Bedingung, Gerücht) und `GameData.legend_of(form)`
  - `MONS[*].legend`, FORMS (Stufe 3 > 4), SPECIALS
- Bedingungen:
  - `RunState`: `pushed`, `boss_heal`, `boss_spark_t`, `final_sig` (werden mit dem Run gespeichert)
  - Erfasst in `BattleState`: Strömung, Heilpatch im Bosskampf, Spannungsfeld im Bosskampf, Siegtreffer der Signatur gegen den Ur-Glitch
  - Ausgewertet in `SaveGame._legend_check()` bei `record_run(won)`
- Passive in `BattleState`: Lichtschein (`light_t`), Glutmähne, Sternenmeer (`_hazard_at` und Lava/Spannung), Bannblick (Gegner-Angriffstakt), Sturmschwingen, Rätselwächter (`riddle`).
- Screenshots: `--mode=dex --t=<Index>`, `--mode=nest --legendegg`.
- Tests: Daten, alle 6 Bedingungen, Ei über den Nestplätzen hinaus, nur einmal, Schlüpfen und Ultra-Schwelle, drei Passive. **339 Prüfungen.**
