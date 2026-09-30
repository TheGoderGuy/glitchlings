---
tags: [produktion, gameplay, godot]
---
# Ebenen, Wächter und Großangriffe (30.09.2026)

**Anlass (Produzent):** „Wenn man tatsächlich mal ein nettes Deck hat, kann man es nicht ausspielen, weil die Zone zu Ende ist.“
Entscheidung: längere Zonen mit Ebenen-Bossen dazwischen, echte Boss-Phasen, angekündigte Großangriffe, Run speichern.

## Aufbau einer Zone
| | vorher | jetzt |
|---|---|---|
| Wiesen, Vulkan, Sümpfe | 7 Etagen + Boss | **3 Ebenen × 5 Etagen**: Ebene 1 → Wächter → Ebene 2 → Wächter → Ebene 3 → Boss |
| NEST-Kern | 4 Etagen + Ur-Glitch | **2 Ebenen × 5 Etagen**: Ebene 1 → Wächter → Ebene 2 → Ur-Glitch |
| Kämpfe pro Run (Autopilot) | Ø 4,9 | **Ø 10,9** (inkl. Wächter und Boss) |

- Jede Ebene hat ihre eigene Karte (sonst passen 17 Etagen nicht lesbar auf 640×360). Beim Betreten einer neuen Ebene blendet die Karte „EBENE 2“ ein, oben steht „Ebene X von Y“.
- Etage 1 der ersten Ebene: nur Kämpfe. Letzte Etage jeder Ebene: Rastplatz vor Wächter/Boss.
- Gegner-HP: **+5 % pro Etage**, über die ganze Zone gezählt (vorher +7 % bei 7 Etagen), × Zonenfaktor.
- Wächter-Sieg: +10 HP + **30 % der max. HP**, **ein Modul**, Chipwahl mit Elite-Gewichtung (mehr Selten/Episch).

## Die 7 Wächter (PixelLab, 80 px, 32 Farben)
| Zone | Ebene | Wächter | Element | HP | Großangriff |
|---|---|---|---|---|---|
| Cache-Wiesen | 1 | **Sprungschreck** (Mecha-Heuschrecke, springt übers Feld) | Elektro | 230 | *Hüpfjagd*: 3 Einschläge, die dir folgen |
| Cache-Wiesen | 2 | **Dornwurz** (Distel-Wurzelwesen, stationär, Sporen) | Virus | 280 | *Dornenteppich*: Schachbrett |
| Firewall-Vulkan | 1 | **Schlackwurm** (Lavawurm, gräbt sich um) | Feuer | 310 | *Magmageysir*: alles außer einem Feld |
| Firewall-Vulkan | 2 | **Magmaskorp** (Obsidian-Skorpion) | Code | 360 | *Scherenzange*: äußere Reihen, dann die Mitte |
| Viren-Sümpfe | 1 | **Schnappkelch** (fleischfressende Pflanze, stationär) | Virus | 380 | *Fangschlund*: zieht dich nach vorn und schnappt zu |
| Viren-Sümpfe | 2 | **Schlickkrake** (Schlamm-Krake) | Wasser | 430 | *Tentakelwirbel*: äußere Spalten, dann die Mitte |
| NEST-Kern | 1 | **Skolopendrox** (Mecha-Hundertfüßer) | Code | 480 | *Segmentfeuer*: Reihe für Reihe |

Namen per `tools/namecheck` gegen Pokémon/Digimon geprüft. Blinzeln: Sprungschreck, Dornwurz, Schlickkrake, Skolopendrox (Boxen in `tools/sprites/blink_boxes.json`); Schlackwurm, Magmaskorp, Schnappkelch haben keine sichtbaren Augen.
Dornwurz wurde einmal neu generiert (erste Fassung war ein Fliegenfallen-Maul wie Schnappkelch).

## Großangriffe (alle Wächter und Bosse)
- **Goldene Warnfelder** mit „!!“, 1,4 s Vorwarnung (statt 0,7 s), 160 % Schaden (Hatz: 120 %), Sirene + Banner mit dem Namen.
- **Komplett ausgewichen → „Überlastet!“**: Gegner 2 s betäubt, Signatur-Leiste +15. Belohnt gutes Ausweichen statt nur Schaden zu bestrafen.
- Wächter: ab Kampfbeginn (erster nach 5 s, dann alle 11 s, in Phase 3 alle 7,7 s).
- Bosse: ab Phase 2, in Phase 3 alle Großangriffe im Wechsel.
- Formen: Kreuz (X), Ring, Schachbrett, ein sicheres Feld, Sog nach vorn, Zange (Reihen/Spalten in 2 Wellen), Reihen-Welle, Hatz.
- Test: Alle Großangriffe sind für einen perfekten Spieler ausweichbar.

## Boss-Phasen (D)
| Boss | HP (neu) | Phase 2 (< 50 %) | Phase 3 (< 20 %) | Großangriffe |
|---|---|---|---|---|
| Kernelmantis | 320 → **380** | Reihe/Kreuz/Spalte + Bitmilben | Kreuz/Doppelspalte/Reihe | Sensenkreuz, Klingenhatz |
| Glutkernskarabäus | 420 → **500** | Doppelspalte/Lava/Reihe | Wand/Lava/Kreuz | Sonnenrad (Ring), Kernschmelze |
| Schwarmkönigin | 520 → **600** | Kreuz/Schleim/Wand/Sporen | Doppelspalte/Sporen/Kreuz/Schleim | Schwarmwelle, Stachelregen |
| Ur-Glitch | 680 → **800** | Kreuz/Doppelspalte/Wand/Reihe | Wand/Kreuz/Doppelspalte | Systemabsturz, Kernfehler, Totalausfall, Datenlöschung |

Phasenwechsel: Banner „Phase 2!“ / „Letzte Phase!“, Brüll-Sound, Bildschirmwackeln. Wächter haben dieselben Phasen (neue Muster ab 50 %).

## Weiteres
- **Wächter-Intro:** wie das Boss-Intro, Warnstreifen „WÄCHTER“, Untertitel „Wächter der Ebene X · …“, normaler Zonenhintergrund.
- **Musik:** neues Stück `guard` (E-Moll, 172 BPM, treibend), damit die Bossmusik („mega“) ihren Moment behält.
- **Run speichern:** Beim Betreten der Karte wird der Run gespeichert (`SaveGame.data.run`). Titel zeigt „Run fortsetzen“; Pause auf der Karte: „Speichern und beenden“. Wer mitten im Kampf beendet, beginnt wieder auf der Karte vor diesem Knoten.
- **Autopilot** (0,25 s Reaktion): gewinnt weiterhin alle Runs, Ø 98 s Kampfzeit pro Run. 2 von 45 Runs erreichen jetzt schon im ersten Run Ultra. Echte Spieltests entscheiden, ob Wächter/Bosse härter werden müssen.

## Offen / beobachten
- Ist eine Zone mit ~25–35 Minuten zu lang? Dann auf 3 × 4 Etagen gehen (`ZoneMap.FLOORS`).
- Fragmente und Evolution kommen durch mehr Kämpfe schneller – ggf. Labor-/Händlerpreise anpassen.
- Idle-Animationen für die Wächter fehlen noch (wie bei allen Figuren außer den 6 Piloten).
