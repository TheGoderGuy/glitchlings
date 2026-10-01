---
tags: [produktion, lokalisierung, godot]
---
# Englisch (01.10.2026)

Das Spiel gibt es jetzt auf **Deutsch und Englisch**. Beim ersten Start wird die Systemsprache erkannt: ein deutsches System startet auf Deutsch, alles andere auf Englisch. Umschalten geht in den Optionen über den ersten Punkt **„Sprache (Language)“**, der in beiden Sprachen zweisprachig beschriftet ist.

## Technik
- `scripts/i18n.gd` (Klasse `T`): `T.t("Deutscher Text")` liefert den Text in der gewählten Sprache. Die deutschen Texte im Code sind die Schlüssel.
- Zusammengesetzte Texte übersetzen zuerst die Vorlage, dann wird eingesetzt: `T.t("Noch %d Element-Chips") % n`.
- `T.chip("Glutball+")` ergibt „Ember Ball+“. Elite-Namen („Elite-Bugsy“) und verbesserte Chips übersetzt `T.t` automatisch.
- `T.dec(2.5)` liefert „2,5“ bzw. „2.5“.
- `PixelCanvas._text()` und `text_width()` übersetzen automatisch, wenn der ganze Text ein Schlüssel ist. Namen, die direkt gezeichnet werden, brauchen also kein `T.t`.
- **Intern bleibt alles deutsch:** Chip-, Monster- und Gegnernamen sind IDs im Spielstand, übersetzt wird nur die Anzeige. Spielstände funktionieren in beiden Sprachen.
- Englische Tabellen in `scripts/data/`:

| Datei | Inhalt |
|---|---|
| `lang_en_names.gd` | Namen |
| `lang_en_data.gd` | Beschreibungen |
| `lang_en_text.gd` | Oberfläche, Ereignisse, Handbuch, Intro, Ende |

  `LangEN.all()` fügt die drei Tabellen zusammen.
- Einstellung `lang` steht in `settings.cfg`, Abschnitt `[game]`.

## Neue Texte einbauen
1. Text im Code wie gewohnt auf Deutsch schreiben. Wenn er zusammengesetzt wird, in `T.t(...)` packen.
2. `node game/tools/lang_keys.js --missing` zeigt alle Texte ohne Übersetzung.
3. Übersetzung in die passende `lang_en_*.gd` eintragen.
4. Der Test **„Englisch: alle Namen, Beschreibungen und Texte übersetzt“** prüft alle Daten (Chips, Formen, Signaturen, Module, Ereignisse, Handbuch, Intro/Ende) und jeden `T.t("…")`-Text. Ein zweiter Test prüft, dass die Platzhalter gleich sind und keine Umlaute im Englischen stehen.
- Screenshots auf Englisch: `--lang=en`, z. B. `--mode=shop --lang=en`.

## Englische Monsternamen
Eigene englische Wortspiele nach demselben Prinzip wie im Deutschen. Neutrale Namen bleiben (Firewallo, Overclocko, Tsunamander, Aurorlynx …). Alle neuen Namen sind mit `tools/namecheck` gegen Pokémon (deutsch + englisch) und Digimon geprüft. Ersetzt wurden: Growlbit (≈ Golbit), Beartron (≈ Bearmon) und Splashcoon (≈ Splashmon).

| Linie | Deutsch | Englisch |
|---|---|---|
| Katze | Pixmiez, Prismiez, Bollwerkatz, Bastionkatz | Pixmeow, Prismeow, Bulwarkat, Bastionkat |
| Welpe | Funkling, Glutbyte, Magmawulf, Turbowulf, Glutfenrir, Hyperwulf | Sparkpup, Emberbyte, Magmawolf, Turbowolf, Blazefenrir, Hyperwolf |
| Axolotl | Tröpfel, Panzerpuff, Kolosspuff | Droplotl, Armorpuff, Colossopuff |
| Hamster | Kekso, Schattnager, Glanzbacke, Phantomnager, Stellarbacke | Crumbster, Shadowgnaw, Shinecheek, Phantomgnaw, Stellarcheek |
| Hase | Perlhopp, Strahlhase, Gischthase, Plasmahase, Lunaflut | Pearlhop, Beamhare, Sprayhare, Plasmahare, Lunatide |
| Frosch | Quakli, Virulurch, Hüpfbyte, Toxikröt, Mechaquak, Miasmakröt, Gigaquak | Croakle, Virulurk, Hopbyte, Toxitoad, Mechacroak, Miasmatoad, Gigacroak |
| Salamander | Molchi, Toxmolch, Magmolch, Sumpfdrak, Lavadrak, Hydradrak, Vulkandrak | Newtie, Toxnewt, Magmanewt, Swampdrake, Lavadrake, Hydradrake, Volcanodrake |
| Bär | Brummbit, Bärtron, Pilzbrumm, Titanbrumm, Sporenpranke, Kolossbrumm, Myzelgrizz | Rumblebit, Ursotron, Fungrumble, Titanrumble, Sporepaw, Colossorumble, Mycelgrizz |
| Robo-Eule | Kauzbit, Optikauz, Raketauz, Radarkauz, Phönixkauz, Orbitkauz, Infernokauz | Hootbit, Optihoot, Rockethoot, Radarhoot, Phoenixhoot, Orbithoot, Infernohoot |
| Dachs | Buddli, Glimmdachs, Zackdachs, Magmadachs, Donnerdachs | Burrli, Glowbadger, Zapbadger, Magmabadger, Thunderbadger |
| Waschbär | Plätschbär, Klaubär, Flutmaske, Nachtmaske | Puddlecoon, Pilfercoon, Floodmask, Nightmask |
| Fusionen | Wolkerich, Spukatz, Wolperling, Schlummerbit, Pustebacke | Cloudster, Spookat, Jackalowl, Slumberbit, Puffcheek |

Gegner zum Beispiel: Glitchmotte → Glitchmoth, Bytewurm → Byteworm, Schwarmkönigin → Swarm Queen, Schnappkelch → Snapmaw. Zonen: Cache Meadows, Firewall Volcano, Virus Swamps, NEST Core.

## Offen
- Muttersprachliche Durchsicht der Texte (Ton, Wortspiele), am besten durch englischsprachige Tester.
- Steam: Sprache später über die Steam-API statt über die Systemsprache.
- `LIESMICH_Spieltest.txt` gibt es nur auf Deutsch, eine englische `README` fehlt noch.
- Vor dem Launch: echte Markenprüfung der Namen.
