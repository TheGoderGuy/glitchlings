---
tags: [produktion, monster, godot]
---
# Glitchlinge-Überarbeitung (29.09.2026)

Nach ausgiebigem Anspielen hat der Produzent die Linien durchgesehen. Umsetzung:

| Thema | Änderung |
|---|---|
| **Brummbit** | Licht/Elektro-Linie (Sonnbrumm → Sonnenpranke → Supernovabär) gestrichen. Neue **Gift-Linie**: **Pilzbrumm** (Pilz-Bärenjunges, Signatur *Sporenwolke*) → **Sporenpranke** (Grizzly mit Giftpilz-Mähne, *Giftpranke*) → **Myzelgrizz** (Ultra, von leuchtendem Pilzgeflecht überwuchert, *Myzelnetz*). Code-Linie bis Kolossbrumm bleibt („ein BANGER“). Startdeck: Virusspritzer statt Blitzcursor. |
| **Pixmiez** | Feuer-Linie (Blazebit → Glutluchs → Pyrolynx) gestrichen. Richtungen jetzt Code, Virus, Elektro. Startdeck: Doppelklick statt Glutball. |
| **Lumi** | Maschinen-Linie (Screenshina → Holohas → Quantenhas) gestrichen. Neue **Wasser-Linie** (Wasser war nur bei Tröpfel vertreten): **Perlhopp** (Blubber-Häschen, *Perlenschuss*) → **Gischthase** (springender Wasserhase, *Gischtsprung*) → **Lunaflut** (Ultra, Mond-Hase mit Muschelpanzer, *Springflut*). Startdeck: Wasserstrahl statt Firewall. |
| **Leviamander** | Neu gezeichnet, deutlich mehr Axolotl (bulliger Vierbeiner, große Kiemenbüschel, breites Maul; Richtung Sumpex). |
| **Kekso** | Keks aus den Pfoten entfernt (PixelLab-Edit). |
| **Tracko** | Neu als kleine Vorstufe von Schattnager (dunkles Fell, Hexagon-Leuchtmuster, Leuchtschwanz). |
| **Gigaquak** | Redesign: schlanker Mecha-Frosch mit Visier-Augen, Hydraulik-Beinen und Düsen statt aufgeblähter Kugel. |
| **Molchi** | Beide Linien („Wahnsinn“) unverändert. |
| **Fusionen** | Dampfbyte und Glyphel gestrichen. Neu: **Wolperling** = Lumi + Kauzbit (Wolpertinger: Hase mit Eulenflügeln und Geweih; Elektro; Passiv *Mischwesen* = doppelt so schnell + sieht Angriffe früher; *Geweihblitz*). **Bärtierling** = Tröpfel + Brummbit (digitales Bärtierchen; Wasser; 150 HP; Passiv *Unzerstörbar* = einmal pro Kampf mit 1 HP stehen bleiben; *Urzeitpanzer*). Spukatz und Wolkerich bleiben. |

**Monsterdex**: 73 Formen. **Alte Spielstände** werden beim Laden übertragen (`SaveGame.FORM_MIGRATION`): gestrichene Formen → Ersatz auf gleicher Stufe (Pixmiez-Feuer → Elektro-Formen, Sonnbrumm-Linie → Pilzbrumm-Linie, Screenshina-Linie → Perlhopp-Linie, Dampfbyte → Bärtierling, Glyphel → Wolperling), Dex-Einträge und Rezepte ebenso.

Alle neuen Sprites: PixelLab Pro Flash, 32 Farben, Blinzel-Frames (Boxen in `tools/sprites/blink_boxes.json`), Namen per `tools/namecheck` geprüft.

**Offen**: Das Baby **Brummbit** ist noch goldgelb (Überbleibsel der Licht-Linie) – ggf. neutraler/bärenbrauner zeichnen.
