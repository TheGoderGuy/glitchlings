---
tags: [produktion, kampf, evolution, struktur, balancing, godot]
---
# Kampf-Kern, Evolution mit Folgen und die Reise (08.10.2026)

Umsetzung der Phasen A und B aus der [[Game-Design-Analyse 2026-10-08]]. Der Produzent wollte außerdem die neue Struktur ausprobieren: Ein Run führt durch mehrere Zonen.

## A: Kampf-Kern

**Gegnerangriffe haben eine Herkunft.**
- Die Muster `row` und `wall` sind jetzt Schüsse. Sie gehen von der Reihe des Gegners aus (`BattleState.SHOT_KINDS`), nicht mehr von deinem Feld.
- `wall` trifft die eigene Reihe des Gegners und eine Nachbarreihe.
- Steht ein Schuss an, sucht der Gegner deine Reihe: 75 % statt 40 %. Teleporter landen zu 60 % in deiner Reihe.
- Damit gilt wie in Megaman Battle Network: **Wer trifft, steht auch in der Schusslinie.**
- Alle anderen Muster (`cell`, `col`, `col2`, `cross`, Flächen, Großangriffe) zielen weiter auf dein Feld.
- Beim Ausholen bleibt der Gegner stehen.

**Konter-Treffer** (`_counter`, `counter_open`)
- Wer den Gegner in der zweiten Hälfte seines Ausholens trifft (`COUNTER_OPEN` 0,45 der Warnzeit), bricht dessen Angriff ab.
- Der Gegner ist 0,8 s betäubt, der Treffer macht 50 % mehr Schaden, und die Signatur lädt um 12 extra.
- Anzeige: Der Gegner glüht rot-weiß, darüber erscheint ein Fadenkreuz.
- Eigener Sound `counter`, schwebender Text „Konter!“.
- Großangriffe (gold) lassen sich nicht kontern.
- Training: Schritt „Konter“ nach dem Ausweichen. Jetzt gibt es 9 Lernschritte; der Gegner holt dabei langsamer aus, und ein Laserschuss liegt bereit.

**Längere Kämpfe, mehr Druck** (`GameData`, als `static var`, damit die Simulation sie verstellen kann)

| Wert | Wirkung |
|---|---|
| `FOE_HP` 2,5 | alle Gegner |
| `BOSS_HP` 1,3 | Wächter und Bosse zusätzlich |
| `FOE_DMG` 1,25 | Gegnerschaden |
| `FOE_TEMPO` 0,85 | Angriffstakt |
| `FIRST_ATTACK` 0,5 | erster Angriff nach dem halben Takt (vorher 0,8) |

## B: Evolution mit Folgen

**Resonanz:** Chips im Element der eigenen Form machen mehr Schaden: Rookie +20 %, Champion +30 %, Ultra +40 % (`GameData.RESONANCE`).
- Gilt nur für Chips mit Schaden, nicht für Signatur, Brand oder Gift.
- Anzeige: schimmernder Element-Streifen auf der Karte und „Resonanz: +X % Schaden“ in der Chipwahl.

**Gaben:** Jede Form ab Rookie bekommt eine Regel ihres Elements (`GameData.GIFTS`). Sie wird mit jeder Stufe stärker.

| Element | Gabe | Wirkung (Rookie / Champion / Ultra) |
|---|---|---|
| Feuer | Zündeln | Feuer-Treffer setzen 2 / 3 / 4 s Brand |
| Wasser | Sog | Wasser-Treffer verlangsamen 1 / 1,5 / 2 s |
| Code | Schutzroutine | geblockter oder vermiedener Treffer: Signatur +10 / 15 / 20 % |
| Elektro | Funkenflug | Elektro-Treffer betäuben 0,2 / 0,3 / 0,4 s |
| Virus | Ansteckung | Virus-Treffer vergiften 2 / 3 / 4 s |

- Die Gabe steht im Kampf-HUD (Abzeichen), im Team-Reiter und in der Evolutions-Szene.
- Neutrale Formen (Babys, Glimmhirsch-Linie) haben keine Gabe und keine Resonanz.
- Die Gaben greifen in die vorhandenen Kombos: Feuersbrunst gegen Brand, Datenfresser gegen Gift, Frostsplitter gegen Eis oder Verlangsamung.

**Weitere Änderungen**
- **Chipwahl lenkt mit** (`RunState.growth_elements`, `roll_pick`): In jeder Wahl liegt mindestens ein Chip für eine Entwicklungsrichtung (Baby) bzw. für die Resonanz (ab Rookie).
- **Überspringen** gibt 10 Fragmente. Schlanke Decks sind damit eine echte Strategie.
- **Evolutions-Schwellen: 25 / 900 / 2700 Element-Chips** über alle Runs (vorher 12 / 35 / 80).
  - Ein Run spielt jetzt 300–800 Element-Chips.
  - Rookie: meist noch im ersten Akt des ersten Runs.
  - Champion: nach etwa 2–3 Runs.
  - Ultra: nach etwa 6–7 Runs.
  - Das Handbuch liest die Zahlen aus `EVO_AT`.
- **Neu prägen** im Labor (60 Fragmente, zweimal bestätigen):
  - Ein entwickeltes Monster wird wieder zum Baby, die Lebenszeit-Prägung startet bei 0.
  - Alle Formen bleiben im Monsterdex.
  - Nicht möglich für Fusionen und Legendäre.
- **Evolutions-Szene** größer inszeniert:
  - Sprite doppelt so groß, Strahlenkranz.
  - Darunter steht, was sich ändert: Signatur, Gabe, Resonanz.

## Die Reise (Struktur)
**Ein Run führt durch vier Akte** (`GameData.ACTS`):
1. Cache-Wiesen
2. Firewall-Vulkan oder Kühlwasser-See
3. Viren-Sümpfe oder Hochspannungs-Steppe
4. NEST-Kern

**Aufbau**
- Jede Zone hat 2 Ebenen à 4 Etagen.
- Am Ende von Ebene 1 kommt ein Wächter, zufällig einer der beiden Wächter der Zone.
- Am Ende von Ebene 2 kommt der Zonen-Boss.
- Deck, Module, HP und Form bleiben über den ganzen Run.

**Zähigkeit je Akt** statt je Zone, für normale Gegner:

| | Akt 1 | Akt 2 | Akt 3 | Akt 4 |
|---|---|---|---|---|
| HP (`ACT_HP`) | 1,0 | 1,4 | 1,85 | 2,3 |
| Schaden (`ACT_DMG`) | 1,0 | 1,2 | 1,4 | 1,6 |

**Nach einem Zonen-Boss** (nicht nach dem letzten)
- Belohnung wie nach einem Wächter: Evolution, Chipwahl mit epischen Chancen, ein Modul.
- Danach kommt die **Weggabelung** (`route_view.gd`): Man wählt die nächste Zone. Die Karte zeigt, ob das eigene Element gegen den Boss dort im Vorteil ist.
- Es gibt eine Verschnaufpause: +40 % HP (`ACT_HEAL`).
- Wer an der Weggabelung beendet, landet beim Fortsetzen wieder dort (`route_pending`).

**Station**
- Der Reiseplan ersetzt das Zonenkarussell: vier Spalten, „Boss besiegt“-Markierung, Protokollwahl wie bisher.
- Alle Zonen sind über die Route erreichbar.
- Die Zonen-Gerüchte der Legendären werden lesbar, sobald man eine Zone einmal betreten hat (`visited`, `SaveGame.zone_seen`).

**Belohnungen am Run-Ende**
- Eier:
  - eins ab 2 Siegen, dazu eins je besiegtem Zonen-Boss,
  - der Brutwärmer gibt jetzt ein weiteres Ei (vorher: einen Run früher schlüpfen),
  - Eier schlüpfen nach dem nächsten Run (`EGG_RUNS` 1).
- Die Legenden-Bedingung wird direkt nach jedem Boss-Sieg geprüft (`SaveGame.legend_check`).

**Abschluss und Ausnahmen**
- Spiel durchgespielt: wenn der Ur-Glitch besiegt ist.
- Nächste Protokoll-Stufe: durch eine ganze geschaffte Reise.
- Testfassung (nur Wiesen + Vulkan): Die Reise endet nach dem Vulkan-Boss.
- Alte Spielstände: Ein laufender Zonen-Run läuft als Akt seiner Zone weiter (`act` aus der Zone).

## Messung (Mensch-Bot, `game/tools/balance_sim.tscn`, 13 Reisen je Zeile)

| Start | Siege | Akt 3 / 4 erreicht | normaler Kampf | Wächter/Boss | HP-Verlust je Kampf |
|---|---|---|---|---|---|
| Baby, Entspannt | 13/13 | 13 / 13 | 14 s | 48 s | 1 % |
| Baby, Normal | 7/13 | 12 / 11 | 16 s | 51 s | 7 % |
| Rookie | 8/13 | 11 / 10 | 15 s | 53 s | 5 % |
| Champion | 13/13 | 13 / 13 | 15 s | 50 s | 5 % |
| Ultra | 11/13 | 13 / 12 | 15 s | 43 s | 4 % |

Vorher gewann derselbe Bot jede einzelne Zone zu 100 %, mit 3–8 s je Kampf und 0–1 % HP-Verlust.
- Ein Run dauert jetzt etwa 12 Minuten reine Kampfzeit (mit Karte und Menüs geschätzt 20–25 Minuten).
- Babys scheitern vor allem an Bossen und Elites.
- Der Bot spielt besser als ein durchschnittlicher Mensch. Echte Siegquoten liegen vermutlich deutlich darunter. **Das muss ein Spieltest bestätigen.**

**Simulation selbst starten:**
```
godot --headless --path game res://tools/balance_sim.tscn -- --runs=13 --stage=1
```
Optionen: `--bot=human|perfect|counter`, `--diff=0..3`, `--protocol=N`, `--zones` (einzelne Zonen wie früher), `--set=FOE_DMG:1.4` bzw. `--set=ACT_HP:1,1.4,1.85,2.3` zum Ausprobieren.

## Training nachgebessert (08.10.2026, abends)
Der Produzent meldete nach einem neuen Spiel: „Der Tutorial-Kampf fehlt“, genauer „kurz ein Kampf, dann Station“.

**Nachgestellt:** Das Training startet (Neues Spiel > Intro > Starter, auch mit echten Tastendrücken). Es konnte aber rasend schnell vorbei sein:
- Bei schnellem Drücken erledigten sich die ersten Schritte in unter einer Sekunde, die Texte blitzten nur auf.
- Wer früh viel angriff, hatte Bugsy auf seine Mindest-HP gedrückt. Der freie Kampf endete dann mit einem einzigen Treffer.

**Lösung**
- Jeder Lernschritt bleibt mindestens 1,5 s stehen (`Tutorial.MIN_STEP`). Was in der Zeit passiert, zählt trotzdem.
- Zum freien Kampf rappelt sich Bugsy auf 60 % HP auf, mit Banner „Frei kämpfen!“.
- Nach dem Sieg erscheint „Training geschafft!“ (1 s länger), dann geht es zur Station.

## Tests
359 Prüfungen, darunter `test_design_review`:
- Schuss aus der Gegnerreihe, Stillstand beim Ausholen
- Konter zu früh und im Fenster
- Resonanz und alle Gaben
- gelenkte Chipwahl
- Neu prägen
- Eier je Boss
- eine ganze Reise mit Autopilot

## Bewusst noch nicht umgesetzt
- **Linien-Chips** (ein eigener Chip je Linie). Das ist neuer Inhalt. Erst soll der neue Kern im Spieltest überzeugen.
- Zwei Währungen, neues Kampffeld, Gegnergrößen im Spätspiel (Phase D der Analyse).
- Geheime zweite Ultra-Form je Linie.

## Offene Fragen an den Spieltest
- Fühlt sich jeder normale Kampf wie ein kleines Duell an? Wird der Konter verstanden und genutzt?
- Ist ein Run mit 20–25 Minuten zu lang für eine Sitzung? Speichern und Fortsetzen gibt es.
- Siegquoten echter Spieler je Startstufe. Danach `BattleBot.human()` (Unaufmerksamkeit `lapse`) nachjustieren.
