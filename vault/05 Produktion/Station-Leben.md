---
tags: [design, station, prototyp]
---
# Station-Leben: Bindung, Pflege, Expeditionen

Antwort auf Playtest-Feedback „bisher nur ein Kampfsystem“ (27.09.2026). Vorbild: Digimon UP (Tamagotchi-Gefühl), aber **fair für Kinder**.

## Grundregel
**Pflege belohnt, Vernachlässigung bestraft nie.** Kein Hunger, kein Verfall, keine traurigen Monster, keine Druck-Countdowns. Passt zu [[Monetarisierung]]-Leitlinien (kein Druck, keine Angebote nach Niederlagen).

## Bindung (0–5 Herzen)
- Steigt durch: Streicheln (+2, Abklingzeit – Prototyp 60 s, fertig ca. 1 h), Datenkeks füttern (+5), Run (+4, Sieg +6), Expedition (+3/+5/+8). Sinkt nie.
- Boni: ♥2 Signatur-Leiste startet mit 15 % · ♥3 +5 HP · ♥4 Leiste startet mit 30 % · ♥5 *Beste Freunde*: übersteht 1× pro Run einen K.-o.-Treffer mit 1 HP.
- **Datenkekse:** Run-Sieg +2, Niederlage +1, Expeditionen +1/+2/+4. Start: 3.

## Pflege-Ansicht
„♥ Pflegen“ auf jeder Team-Karte: Monster groß, **antippen = streicheln** (hüpft, Herzen steigen auf), füttern, Übersicht der Herz-Boni, direkt in einen Run starten.

## Expeditionen
- 2 Plätze, 5 Zonen (je ein Element): Glutkern (Feuer), Datenmeer (Wasser), Codewald (Code), Lichtturm (Licht), Spamsumpf (Virus).
- Dauer: Kurz / Mittel / Lang (Prototyp 30/90/240 s – fertig 30 min / 2 h / 8 h).
- Belohnung: Fragmente, Datenkekse, Bindung, **Prägung im Zonen-Element** (= Evolutionsfortschritt), bei Mittel/Lang Chance auf ein Ei. **Heimvorteil** +50 %, wenn das Element des Monsters zur Zone passt.
- Kurze Geschichte bei der Rückkehr („… hat im Codewald einem verirrten Mini-Bot den Weg gezeigt“).
- Monster auf Expedition können keine Runs spielen.

## Offene Ideen
- Pflege-Animationen (Idle, Freude) und mehr Reaktionen
- Zonen später als eigene Kampfgebiete (gleiche Welt)
- Balancing: Sind Expeditionen zu stark als Evolutionsquelle im Vergleich zu Runs?

Code: `renderCare`, `renderExp`, `collectExp`, `BOND_PERKS`, `ZONES` in `prototype/index.html`. Test: `tests/life.test.js`.
