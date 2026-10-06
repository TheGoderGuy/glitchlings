---
tags: [produktion, tcg-app, konzept]
projekt: Glitchlings × ViMOn TCG-App
status: Planung
stand: 2026-10-06
---
# TCG-App (Glitchlings × ViMOn) – Konzept und Plan

> Eigenständige Mobile-App neben dem Steam-Spiel: ein hochglänzendes Sammelkartenspiel nach dem Vorbild von *Pokémon TCG Pocket*, mit Glitchlings und den Kreaturen aus ViMOn (`Documents/Claude/Projects/Vimon`).

## Entscheidungen (06.10.2026, Produzent)
| Frage | Entscheidung |
|---|---|
| Geschäftsmodell | **Kein Echtgeld-Zufall.** Packs nur durchs Spielen, optional Kosmetik oder Einmalkauf. Kein Gacha, keine Lootbox-Problematik (Belgien/NL, USK-Hinweis „zufällige Objekte“), kindgerecht, kein Live-Betrieb nötig |
| Kunststil | **Zwei Editionen.** Glitchlings als Pixel-Edition, ViMOn als gemalte Edition, je eigener Kartenrahmen und Holo-Stil. Bestehende Bilder bleiben nutzbar |
| Plattform | **Mobile (iOS/Android) mit Godot 4**, Hochformat, Gyro-Neigung |
| Kampf | **Pocket-schlank + Evo-Twist:** 20-Karten-Decks, automatische Energie, 3 Punkte. Neu: verzweigte Evolution je nach angelegter Element-Energie |

## Recherche: Pokémon TCG Pocket
Creatures Inc. + DeNA, weltweit seit 30.10.2024. 100 Mio. Downloads bis Feb. 2025, über 200 Mio. $ im ersten Monat, über 500 Mio. $ bis Feb. 2025. Metacritic 75. Lob für Pack-Öffnen und Zugänglichkeit, Kritik an „öden“ Kämpfen, Gacha-Druck und eingeschränktem Tausch (Tausch-Ausdauer, Shinedust, nur gleiche Seltenheit).

### Bildschirme (App-Store-Screenshots)
| Bildschirm | Beobachtung |
|---|---|
| Pack-Auswahl | 3D-Packs im Karussell, darüber Vorschau der Top-Karten, Pack-Punkte, Knopf „Erscheinungsraten“, untere Leiste mit 5 Reitern |
| Pack öffnen | Wisch zum Aufreißen, Karten einzeln aufdecken, seltene Karten mit eigener Inszenierung |
| Karten | Holo-Glanz folgt der Neigung (Gyro), Full-Art-Varianten, „Immersive Cards“ (animierte Fahrt ins Kartenbild) |
| Sammlung | Raster mit 5 Spalten, Alben, Galerien, Decks, Sammelzähler |
| Präsentation | Lieblingskarte vor illustriertem Hintergrund, für andere sichtbar |
| Kampf | Hochformat, runde Arena, aktives Monster groß in der Mitte, 3 Bankplätze, Schalter „Autom.“, „Zug beenden“ |

**Bildsprache:** Pastellverläufe (Mint bis Lavendel), weiße Milchglas-Flächen, viel Leerraum, Regenbogen nur als Akzent. Die Oberfläche bleibt ruhig, damit die Karten leuchten.

### Regeln
- 20 Karten pro Deck, höchstens 2 gleichnamige
- Energiezone erzeugt 1 Energie pro Zug, keine Energiekarten
- Sieg bei 3 Punkten (normales K.O. 1, ex 2), Bank mit 3 Plätzen, Partie etwa 5 Minuten

### Kreislauf und Wirtschaft
- 2 kostenlose Packs pro Tag (12-h-Timer, „Sanduhren“ verkürzen), 5 Karten pro Pack
- Seltenheiten: ◆1–4, ☆1–3, Krone. Sehr seltene „Rare Packs“ mit 0,05 %
- Pack-Punkte: 5 pro Pack, gegen Wunschkarten tauschbar (Garantie gegen Pech)
- Wonder Pick: eine verdeckte Karte aus Packs anderer Spieler ziehen
- Premium-Abo (+1 Pack/Tag), Echtgeld-Währung, Events und Missionen, etwa monatlich neue Sets

### Warum es funktioniert
1. Pack-Öffnen als Ritual (Haptik, Spannung, Seltenheits-Inszenierung)
2. Die Karte ist der Inhalt (Full-Art, Holo, immersive Karten)
3. Kurze Sitzungen (2 Packs, 5-Minuten-Kampf)
4. Sammeln vor Kämpfen, viele kämpfen fast nie

## Unsere Abgrenzung
- **Ohne Echtgeld-Zufall** ist das Vorbild eher das Game-Boy-*Pokémon Trading Card Game* (1998): Packs als Belohnung für Siege, Herausforderungen und Sammelfortschritt. Pack-Punkte als Pech-Schutz bleiben sinnvoll.
- **Keine Echtzeit-Timer als Bremse** (wie bei Glitchlings): Packs kommen über Spielfortschritt, nicht über Wartezeit. Eine tägliche Gratis-Belohnung ist als Bonus okay, darf aber nicht die Hauptquelle sein.
- **Nicht kopieren:** Kartenlayout, Symbole, Begriffe („ex“, „Wonder Pick“, „Shinedust“) und Oberflächengestaltung sind Pokémon-Eigentum. Mechaniken dürfen übernommen werden, alles Sichtbare wird eigen.
- **Alleinstellung:** verzweigte Evolution. Ein Baby wird je nach angelegter Element-Energie zu einem anderen Rookie. Das überträgt „Die Spielweise bestimmt die Evolution“ in eine Kartenregel.

## Inhalte
| Quelle | Bestand | Kartenformat |
|---|---|---|
| Glitchlings | 13 Linien, 102 Formen (Pixel, 32–96 px), Idle- und Angriffsanimationen | Pixel-Edition: Sprite ganzzahlig skaliert, Pixel-Hintergrund, Holo als Pixel-Raster |
| ViMOn | 11 Linien, 33 Formen (gemalt, ca. 1250 px, freigegeben in `Vimon/assets/monsters/`) | Gemalte Edition: Illustration mit Hintergrund, klassischer Holo-Glanz |

Ungefähr 135 Monster plus Seltenheits-Varianten (Full-Art, Immersive) und Unterstützungskarten ergeben für Set 1 etwa 200 Karten (Pocket startete mit rund 290).

**Offene Lore-Frage:** Wie begegnen sich der NEST (Glitchlings) und das Terra-Protokoll (ViMOn)? Beides ist „erschaffenes digitales Leben“, z. B. als Archiv, das beide Welten speichert.

## Phasenplan
| Phase | Inhalt | Prüffrage |
|---|---|---|
| 0 | Entscheidungen + dieses Konzept | ✅ |
| 1 | **Hochglanz-Test** in Godot: je eine Karte pro Edition mit Holo-Shader, Neigung (Gyro/Maus) und Pack-Öffnung mit Aufdecken | Fühlt es sich hochwertig an? |
| 2 | Kampfregeln: 2 Starterdecks, KI, verzweigte Evolution | Ist der Kampf interessanter als bei Pocket? |
| 3 | Sammlung, Album, Deckbau, Pack-Kreislauf (offline, ohne Server) | Will man weiter sammeln? |
| 4 | Set 1: Kartenwerte, Kartenbilder, Varianten | |
| 5 | Optional online: Tauschen, PvP, Präsentation (braucht Backend) | |

## Offene Fragen
- [ ] Eigenes Projekt-Repo oder Ordner neben `game/`?
- [ ] Name der App
- [ ] Lore-Verbindung der beiden Welten
- [ ] Kosmetik-Verkauf oder Einmalkauf (Entscheidung spätestens vor Phase 4)

## Quellen
- [Wikipedia: Pokémon TCG Pocket](https://en.wikipedia.org/wiki/Pok%C3%A9mon_Trading_Card_Game_Pocket)
- [App Store: Pokémon TCG Pocket](https://apps.apple.com/de/app/pok%C3%A9mon-tcg-pocket/id6479970832)
- [Offizielle Seite](https://tcgpocket.pokemon.com/en-us/)
- [Bulbapedia: Seltenheiten](https://bulbapedia.bulbagarden.net/wiki/Rarity_(TCG_Pocket))
- [Pokémon GO Hub: Ziehungsraten](https://pokemongohub.net/post/tcg-pocket/pokemon-tcg-pocket-pull-rates-explained/)
- [EVZ: Lootboxen](https://www.evz.de/themen/einkaufen-digitales/gaming/lootboxen/)
- [Godot Shaders: Holo-Karte](https://godotshaders.com/shader/2d-holographic-card-shader/)
