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
| **Fusionen** | Dampfbyte und Glyphel gestrichen. Neu: **Wolperling** = Lumi + Kauzbit (Wolpertinger: Hase mit Eulenflügeln und Geweih; Elektro; Passiv *Mischwesen* = doppelt so schnell + sieht Angriffe früher; *Geweihblitz*). **Schlummerbit** = Kekso + Brummbit (ersetzt den kurzlebigen Bärtierling; zwei Winterschläfer träumen gemeinsam: schwebt schlafend, Sternenfell, Backen voller Sterne; Elektro; Passiv *Winterschlaf* = 25 % weniger Schaden + Hamstern; *Schlaflied* betäubt 3 s und heilt). **Pustebacke** = Kekso + Quakli (Backentaschen + Schallblase = aufgeblasener Giftgas-Ballon; Virus; Passiv *Schwebegas* = 15 % Ausweichen + Angreifer vergiftet; *Gasexplosion*). Spukatz und Wolkerich bleiben. |

**Monsterdex**: 74 Formen (Stand Nachträge). **Alte Spielstände** werden beim Laden übertragen (`SaveGame.FORM_MIGRATION`): gestrichene Formen → Ersatz auf gleicher Stufe (Pixmiez-Feuer → Elektro-Formen, Sonnbrumm-Linie → Pilzbrumm-Linie, Screenshina-Linie → Perlhopp-Linie, Dampfbyte und Bärtierling → Schlummerbit, Glyphel → Wolperling), Dex-Einträge und Rezepte ebenso.

Alle neuen Sprites: PixelLab Pro Flash, 32 Farben, Blinzel-Frames (Boxen in `tools/sprites/blink_boxes.json`), Namen per `tools/namecheck` geprüft.

**Nachträge**: Baby **Brummbit** in Bärenbraun statt Gelb. **Gigaquak** zweites Redesign: Titan-Kröte mit Schulterkanonen (aus 3 Varianten gewählt). Fusionen jetzt: Wolkerich, Spukatz, Wolperling, Schlummerbit, Pustebacke – 74 Formen im Dex.
