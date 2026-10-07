---
tags: [produktion, station, godot]
---
# Zuhause in der Station (06.10.2026)

Wunsch des Produzenten: „Station-Bewohner, die herumlaufen“. Entscheidungen:
- Es gibt einen **eigenen Reiter „Zuhause“** ganz links. Die Station öffnet dort.
- Die Bewohner haben ein **eigenes Leben, und man kann sie streicheln**. Es gibt keine Spielwerte und keine Bindung.

## So sieht es aus
- Nachts auf den Cache-Wiesen leben bis zu **12 Team-Glitchlinge** (die ersten im Team) mit ihren Idle-Animationen. Babys sind doppelt so groß gezeichnet. Ist das Team größer, steht oben „N weitere Glitchlinge ruhen sich gerade aus.“
- **Verhalten:**
  - Sie **laufen** mit kleinen Hüpfern umher und suchen sich bevorzugt freie Stellen, damit sich nicht alles in der Mitte ballt.
  - Sie **stehen** herum.
  - Sie **schlafen**: Augen zu, Animation steht still, „z“ steigt auf.
  - Sie **spielen** zu zweit: Treffpunkt, abwechselnd hüpfen, Noten.
  - Sie besuchen ihren **Lieblingsplatz**:
    - Feuer: Lagerfeuer (Glut)
    - Wasser: Teich (Spritzer)
    - Elektro: Blitzableiter (Funken)
    - Code: Datenbaum (Bits)
    - Virus: Pilzkreis (Bläschen)
    - Neutral: Bit-Ball (hüpft mit)
- Kauzbit- und Plapperli-Linie **schweben** statt zu laufen.
- **Streicheln:** Mit < > wählst du einen Glitchling (Pfeil über dem Kopf), mit Enter/A streichelst du ihn. Er hüpft zweimal, Herzchen steigen auf, und oben steht eine Reaktion je Tierart, z. B. „Pixmiez schnurrt zufrieden.“ oder „Plapperli plappert: Nochmal! Nochmal!“.
- **Station-Führung:** Der neue Schritt 2/8 erklärt das Zuhause.

## Requisiten (06.10.2026, Produzent: „sehen aus wie Artefakte“)
Die zuerst aus Rechtecken gezeichneten Lieblingsplätze wirkten neben den Sprites wie Bildfehler. Jetzt sind alle sechs mit PixelLab Pro Flash gezeichnet. Stilreferenz war Bachli_32, auf 32 Farben reduziert und auf den Inhalt zugeschnitten: `game/assets/sprites/home/` (Teich, Pilzkreis, Datenbaum, Blitzableiter, Ball).

- Das **Lagerfeuer** hat 6 flackernde Bilder (`anim/home_feuer_48_idle_*`).
- Der Ball wurde ein zweites Mal gezeichnet, mit Sternen statt Querstreifen, damit er nicht an einen Pokéball erinnert.
- Etwa 36 Generierungen.

## Technik
- `scripts/meta/home_sim.gd` (`HomeSim`): Simulation ohne Grafik, damit sie testbar ist.
  - Funktionen: `setup(team, seed)`, `update(dt)`, `pet(i)`, `order()`.
  - Konstanten: `AREA` (Laufbereich), `SPOTS` (Lieblingsplätze je Element), `PET_TEXT` (Reaktionen).
- `station_view.gd`:
  - `Tab.HOME`, `TAB_ORDER` (Zuhause zuerst)
  - Zeichnen: `_draw_home`, `_draw_home_props`, `_draw_home_fx`
  - `_sync_home` stellt die Bewohner neu auf, wenn sich das Team ändert (Schlüpfen, Fusion).
- Screenshot: `--mode=home --t=<s>` (simuliert t Sekunden, Beispiel-Team mit 11 Glitchlingen), mit `--pops` gleich streicheln.
- Tests:
  - Bewohner bleiben im Laufbereich, alle Verhaltensweisen kommen vor.
  - Streicheln gibt Herzchen und Text.
  - Die Station öffnet im Reiter Zuhause.
  - **325 Prüfungen.**

## Tageszeiten und Einzug (07.10.2026, Wunsch des Produzenten)
- **Tageszeit** wechselt mit jedem Run: Morgen, Tag, Abend, Nacht (`HomeSim.daytime_for(runs)`).
  - Licht als weicher Farbverlauf über die Kulisse, dazu tiefe Morgensonne, hohe Mittagssonne, Abendsonne bzw. Mondsichel.
  - Die Tageszeit steht oben links.
  - Verhalten (`DAY_MOOD`): Nachts wird viel geschlafen, tagsüber mehr gelaufen und gespielt (im Test über 20× so viel Schlaf nachts).
- **Einzug:** Wer neu im Team ist (Schlüpfen, Fusion), kommt beim nächsten Besuch im Zuhause von links hereingelaufen.
  - Alle anderen drehen sich zu ihm, hüpfen und machen Noten.
  - Bei der Ankunft gibt es Freudensprünge mit Herzchen, oben steht „X ist eingezogen! Alle freuen sich.“
  - Wer schon begrüßt wurde, merkt sich der Spielstand (`home_seen`). Alte Spielstände starten ohne Begrüßungswelle.
- Screenshot: `--mode=home --daytime=morgen|tag|abend|nacht`, `--welcome`.

## Ideen für später
- Bewohner reagieren auf Fusionen und Entwicklungen (Glitzern, „Wow!“).
