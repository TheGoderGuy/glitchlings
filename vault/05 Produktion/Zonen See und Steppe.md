---
tags: [produktion, zone, gegner, steam]
---
# Zonen: Kühlwasser-See und Hochspannungs-Steppe (06.10.2026)

Wunsch des Produzenten: neue Spielinhalte, zwei Zonen für die fehlenden Elemente Wasser und Elektro.

**Entscheidungen des Produzenten:**
- Die Zonen kommen linear hinzu: **Wiesen > Vulkan > Kühlwasser-See > Viren-Sümpfe > Hochspannungs-Steppe > NEST-Kern**.
- Die Namen hat der Produzent gewählt.
- Gegner, Mechaniken und Plan hat der Produzent freigegeben.

**Bestehende Spielstände:** Was vorher frei war, bleibt frei (`legacy_zones`, einmalig beim Laden über `zones_v2`). Wer den Vulkan schon geschafft hatte, behält die Sümpfe. Wer die Sümpfe schon geschafft hatte, behält den Kern. See und Steppe kommen ganz normal dazu.

**Zähigkeit:**

| Zone | Wiesen | Vulkan | See | Sümpfe | Steppe | Kern |
|---|---|---|---|---|---|---|
| Gegner-HP | 1,0 | 1,25 | **1,4** | 1,5 | **1,65** | **1,75** (vorher 1,6) |

## Zone 3: Kühlwasser-See (Wasser, Code im Vorteil)
**Mechanik: Strömung.** Eine Reihe wird 4 s zur Strömung (Wellen und Pfeile zeigen die Richtung). Wer darin steht, wird alle 0,7 s ein Feld mitgerissen, bis an den Rand. Das kostet keinen Schaden, bringt einen aber in Angriffe hinein.

| Rolle | Name (EN) | Element | Kampf |
|---|---|---|---|
| Gegner | Kabelaal (Cableel) | Wasser | taucht ab (teleportiert), Reihe + Strömung |
| Gegner | Frostkrill (Frostkrill) | Wasser | schnell, Einzelfelder |
| Gegner | Tauchkäfer (Divebeetle) | Code | zäh, Doppelspalte + Strömung |
| Gegner | Frostanemone (Frostanemone) | Wasser | festsitzend, Kreuz, streut **Glitch-Blasen** (draufsteigen zum Zerplatzen) |
| Wächter 1 | Schraubenrochen (Screwray) | Wasser | Großangriff **Sogwirbel** (zieht nach vorn) |
| Wächter 2 | Frostnarwal (Frostwhal) | Code | Großangriff **Eisbohrer** (Hatz) |
| **Boss** | **Tiefenschlange** (Deepserpent) | Wasser | schickt Strömungen; Großangriffe **Sturzflut** (neue Form „Welle“: Spalte für Spalte von vorn nach hinten) und **Flutring** |

**Ereignisse:**
- **Kühlrohr-Leck:** Frostsplitter für −10 HP oder +3 Wasser-Prägung.
- **Treibende Eisscholle:** meist ein seltener Chip, sonst −12 HP, oder +15 HP.
- **Taucherglocke:** Chip verbessern oder +25 Fragmente.
- **Stiller Spiegelsee:** +3 Code-Prägung oder für 20 Fragmente +10 max. HP.

**Kulisse und Musik:**
- Kulisse: dunkelblauer Himmel, ein Kühlsee mit Lichtreflexen vor den Hügeln; auf dem Rastplatz und bei Ereignissen steigen Luftblasen auf.
- Musik: `map_see` (e-Moll, 92 BPM, fließende Arpeggios) und `battle_see` (a-Moll, 166 BPM).

## Zone 5: Hochspannungs-Steppe (Elektro, Virus im Vorteil)
**Mechanik: Spannungsfelder (Risiko gegen Belohnung).** Ein geladenes Feld kostet alle 0,6 s etwas HP (20 % des Gegnerschadens), solange man darauf steht. Dafür **laden die Chips dort doppelt so schnell** (auf dem Feld steht „x2“). Der Spieler entscheidet selbst, ob er stehen bleibt.

| Rolle | Name (EN) | Element | Kampf |
|---|---|---|---|
| Gegner | Ampereameise (Ampant) | Elektro | schnell, Einzelfeld + Reihe |
| Gegner | Spulenwurm (Coilworm) | Elektro | Spalte + Spannungsfeld |
| Gegner | Mastgeier (Pylonvulture) | Elektro | fliegt (teleportiert), Kreuz |
| Gegner | Blitzfarn (Boltfern) | Elektro | festsitzend, Kreuz + Spannungsfelder |
| Wächter 1 | Donnerbock (Thunderbuck) | Elektro | Großangriff **Hornsturm** (Reihe für Reihe) |
| Wächter 2 | Trafokäfer (Gridbeetle) | Code | Großangriff **Kurzschlusskreis** (Ring) |
| **Boss** | **Donnerkondor** (Thundercondor) | Elektro | lädt Felder auf; Großangriffe **Gewitterfront** (Schachbrett) und **Himmelsriss** (Hatz) |

**Ereignisse:**
- **Verlassenes Umspannwerk:** −10 HP für +3 Elektro-Prägung und eine halb volle Signatur-Leiste, oder +30 Fragmente.
- **Aufziehendes Gewitter:** +15 HP oder Kettenblitz für −12 HP.
- **Wilde Datenherde:** +8 max. HP oder +25 Fragmente.
- **Relaisturm:** −8 HP, dafür ist der nächste Gegner geschwächt, oder +3 Virus-Prägung.

**Kulisse und Musik:**
- Kulisse: grauer Gewitterhimmel mit Wetterleuchten und Blitzen, Strommasten mit durchhängenden Leitungen auf den Hügeln, Funken im Wind.
- Musik: `map_steppe` (D-Dur, 112 BPM, Blech, heldenhaft) und `battle_steppe` (h-Moll, 176 BPM).

## Grafik
- 14 neue Figuren, gezeichnet mit PixelLab Pro Flash. Stilreferenz waren jeweils bestehende Gegner (Datenegel, Glitchblüte, Schlickkrake, Schwarmkönigin, Funkenkäfer, Sprungschreck, Magmaskorp, Skarabäus).
- Alle sind auf 32 Farben reduziert und haben Idle- und Angriffsanimationen.
- Bei Spulenwurm und Trafokäfer läuft im Idle nur die saubere Hälfte vor und zurück, weil in der Mitte ein greller Blitz aufleuchtet.
- Die Tiefenschlange wurde für den Angriff ein zweites Mal generiert, mit deutlicherem Biss.
- **Blinzeln:** Kabelaal, Tauchkäfer, Mastgeier, Ampereameise, Donnerbock, Trafokäfer, Tiefenschlange und Donnerkondor blinzeln. Keine Blinzel-Bilder haben:
  - Frostkrill (winzige Facettenaugen)
  - Frostanemone, Spulenwurm und Blitzfarn (keine Augen)
  - Schraubenrochen und Frostnarwal (Linsen)
- Alle Namen sind mit `tools/namecheck` geprüft (deutsch und englisch).
- Etwa 100 PixelLab-Generierungen.

## Technik
- **Gefahrenflächen sind verallgemeinert.**
  - `BattleState.HAZARD_DUR` und `HAZARD_COL` legen Dauer und Farbe je Art fest: `lava | slime | current | spark`.
  - `on_hazard()` prüft, ob ein Feld eine bestimmte Fläche hat.
  - Je Feld gibt es höchstens eine Fläche.
  - Die Strömung hat einen eigenen Schub-Takt (`push_t`).
- **Angriffsmuster:**
  - `current` macht die Reihe des Spielers zur Strömung, `spark` lädt das Feld des Spielers und ein weiteres auf.
  - Boss-Diener `current` und `spark`. Auch der Ur-Glitch nutzt sie, wenn er Wasser bzw. Elektro ist.
- **Zeichnen** (`battle_view`): `_draw_current_pool` und `_draw_spark_pool` für die Flächen, Warnungen in `_draw_ground_warn`, die Glitch-Blase in `_draw_minion`.
- **Zonenwahl:** Bei 6 Zonen ist sie ein Karussell, 4 Karten sind sichtbar, Pfeile zeigen weitere Zonen.
- **Screenshots:**
  - `--mode=fight --zone=see|steppe --area`
  - `--pops`
  - `--mode=event --zone=see --event=taucherglocke`
- **Tests:**
  - Zonenreihenfolge, Bosse und Wächter.
  - Strömung (bis an den Rand, ohne Schaden) und Spannungsfeld (HP-Verlust, doppelte Ladegeschwindigkeit).
  - Großangriff Welle, Spielstand-Übergang, Freischaltkette.
  - Autopilot je 6 Runs in See und Steppe: alle gewonnen, kein Kampf hängt.
  - **321 Prüfungen.**

## Offen
- Spieltest: Fühlt sich die Strömung fair an, oder reißt sie zu oft in Angriffe? Wird das Risiko der Spannungsfelder verstanden?
- Das Kino-Intro zeigt weiterhin nur die vier alten Zonen.
