---
tags: [produktion, prototyp, phase-1]
status: bereit zur Umsetzung
---
# Prototyp-Spezifikation (Phase 1)

> **Die einzige Frage dieser Phase:** Macht ein einzelner Run Spaß – auch ohne Meta-Systeme, ohne Grafikpolitur, ohne Belohnungen?

Ein spielbarer Browser-Prototyp dieser Spezifikation liegt als Artifact vor (Link siehe [[🏠 Start hier]]). Er dient als Referenz für das Spielgefühl, nicht als Code-Basis.

## Umfang
| Inhalt | Menge |
|---|---|
| Spielbare Monster | 3: [[Pixmiez]], [[Funkling]], [[Tröpfel]] |
| Chips | 15 → [[Chip-Übersicht]] |
| Gegner | 3 → [[Bugsy]], [[Glitchmotte]], [[Spamlet (wild)]] |
| Boss | 1 → [[Kernelmantis]] |
| Run | 3 Kämpfe + Boss, nach jedem Kampf 1 aus 3 Chips |

## Bewusst NICHT im Prototyp
Station, Brüten, Fusion, Shop, Accounts, Speichern, Story, finale Grafik. Die Prägung wird am Ende des Runs nur **angezeigt**, damit wir testen können, ob die Evolutionsvorschau neugierig macht.

## Spielfeld
- Zwei 3×3-Felder nebeneinander, links Spieler, rechts Gegner.
- Jede Figur belegt genau ein Feld.
- Spieler bewegt sich nur im eigenen Feld, Gegner nur in seinem.

## Steuerung
| Aktion | Touch | Tastatur (Test) |
|---|---|---|
| Bewegen | Swipe in Richtung oder eigenes Feld antippen (Direktsprung) | WASD / Pfeiltasten |
| Chip einsetzen | Chip antippen | J, K, L oder 1, 2, 3 |
| Chip vormerken | Ladenden Chip antippen | Taste während des Ladens |
| Pop-up schließen | Pop-up antippen | Klick |

Bewegungs-Cooldown: 0,12 s (Tröpfel: 0,18 s). Beim Direktsprung +50 % pro zusätzlichem Feld Entfernung.

**Vormerken:** Wird ein ladender Chip angetippt, feuert er automatisch, sobald er bereit ist. Das nimmt Timing-Druck heraus, ohne das Ausweichen zu vereinfachen.

## Chip-Hand
- 3 Slots. Ein benutzter Slot zieht sofort den nächsten Chip aus dem gemischten Deck, ist aber für die **Ladezeit dieses neuen Chips** gesperrt.
- Ist das Deck leer, wird der Ablagestapel neu gemischt.
- Pro Kampf wird das Deck neu gemischt.

## Deck-Transparenz
- Über der Hand steht immer der **nächste Chip** aus dem Stapel und wie viele Chips noch im Stapel liegen.
- **Deck ansehen** pausiert den Kampf und zeigt Hand, Stapel und Ablage mit Beschreibungen sowie die Elementverteilung.
- **Chip-Wahl** zeigt pro Angebot: wie oft der Chip schon im Deck ist, ob er gegen den nächsten Gegner stark oder schwach ist, und welche Prägung er gibt. Darüber steht das aktuelle Deck als Übersicht.
- Am Rechner zeigt Überfahren eines Chips seine Wirkung.

## Spielbare Monster
| Monster | HP | Besonderheit | Startdeck (8 Chips) |
|---|---|---|---|
| [[Pixmiez]] | 100 | Allrounder | 3× Pixelstrahl, 2× Byteschlag, Firewall, Heilpatch, Blitzcursor |
| [[Funkling]] | 80 | Chips laden 10 % schneller | 2× Pixelstrahl, 2× Glutball, Flammenwelle, Übertakten, Firewall, Byteschlag |
| [[Tröpfel]] | 120 | Bewegt sich langsamer | 3× Wasserstrahl, 2× Blubberschild, Eisfeld, Pixelstrahl, Heilpatch |

## Gegner-Verhalten
- Gegner bewegen sich im festen Takt auf ein zufälliges freies Nachbarfeld.
- **Jeder Angriff wird 0,7 s vorher angezeigt** (rot blinkende Felder). Kein Treffer ohne Vorwarnung – Fairness ist Pflicht.
- Details je Gegner in den Notizen unter `06 Datenbank/Gegner`.

## Run-Ablauf
1. Monster wählen
2. Kampf 1: Bugsy → Chipwahl (1 aus 3) → +15 HP
3. Kampf 2: Glitchmotte → Chipwahl → +15 HP
4. Kampf 3: Spamlet → Chipwahl → +15 HP
5. Boss: Kernelmantis
6. Ergebnis: Fragmente, Prägung nach Element, Evolutionsvorschau

Bei Niederlage: **Near-Miss-Anzeige** ("Der Tyrann hatte nur noch 8 % HP") und 50 % der Fragmente bleiben.

## Juice-Minimum (auch im Prototyp!)
- Trefferblitz + kleiner Screenshake beim Treffen und Getroffenwerden
- Schadenszahlen, die aufsteigen und verblassen
- Kurzer Freeze-Frame (60 ms) bei starken Treffern
- Chip-Slot pulsiert kurz, wenn er wieder bereit ist

## Erfolgskriterien für den Playtest
Mit 10–20 Testern, ohne Erklärung außer "Swipe zum Bewegen, Tippen für Chips":

| Frage | Ziel |
|---|---|
| Versteht der Tester die Steuerung ohne Hilfe? | ≥ 80 % nach Kampf 1 |
| Spielt er freiwillig einen zweiten Run? | ≥ 70 % |
| Wie viele Runs am Stück? | Ø ≥ 3 |
| Dauer eines Runs | 3–5 Minuten |
| Siegquote im ersten Run | 30–50 % |
| Wird die Chipwahl als Entscheidung empfunden? | Tester können begründen, warum sie gewählt haben |
| Fühlt sich die Niederlage fair an? | Tester nennen eigenen Fehler, nicht "Glück" |

## Beobachten statt fragen
Tester sagen oft "macht Spaß" aus Höflichkeit. Stärker ist: Greift er ohne Aufforderung wieder zum Handy? Flucht er beim Verlieren (gut: emotional investiert) oder legt er es weg (schlecht)?

## Entscheidung nach Phase 1
- **Kriterien erfüllt:** weiter zu Phase 2 → [[Roadmap]]
- **Knapp verfehlt:** 2–4 Wochen iterieren (Tempo, Chip-Werte, Gegner-Telegraphing)
- **Klar verfehlt:** Kampfsystem grundlegend überdenken, bevor Geld in Meta-Systeme fließt

## Playtest-Log
### Playtest 1
**Beobachtung:** Mit der Maus sind Bewegen und Chips gleichzeitig kaum machbar. Glutball fühlt sich schwächer an als die anderen Chips.
**Änderungen:**
- Direktsprung per Tipp auf ein eigenes Feld
- Vormerken von ladenden Chips
- Zwei-Hand-Tastaturbelegung WASD + J/K/L
- [[Glutball]]: 40 → 45 Schaden, zusätzlich 20 Flächenschaden auf Nachbarfelder
**Offen:** Prüfen, ob der Direktsprung das Ausweichen zu leicht macht. Wenn ja, Sprung auf 2 Felder begrenzen.

### Playtest 2
**Beobachtung:** Kämpfe machen Spaß, Grafik soll besser werden.
**Änderungen:** 16×16-Sprites mit Kontur und Schattierung, Idle-Animation, Zonen-Hintergründe, Plattformen mit Tiefe, Projektil-Schweife, Trefferringe, Schadensrand, HUD-Porträts, Element-Icons. Details: [[Art Direction]]

### Grafik-Update 32×32
Alle 7 Figuren neu in 32×32 gezeichnet, dazu 9 Evolutions-Sprites (Pixi, Funkling, Tröpfel). Nach der ersten Evolution kämpft das Monster in seiner neuen Form. Der Ergebnisbildschirm zeigt vorher die **Silhouette der kommenden Evolution**, um Neugier zu testen. Details: [[Art Direction]]

### Playtest 3
**Beobachtung:** Deckbuilding ist simpel und cool, aber undurchsichtig. Man sieht nicht, was im Deck passiert.
**Prinzip der Lösung:** Mehr Sichtbarkeit, nicht mehr Regeln.
**Änderungen:** Nächster-Chip-Anzeige, pausierende Deck-Ansicht, Kontext-Tags bei der Chip-Wahl (Anzahl, Stärke gegen nächsten Gegner, Prägung), Tooltips.
**Offen / nächster Test:** Wird die Chip-Wahl jetzt bewusster getroffen? Tester sollen ihre Wahl begründen können. Falls Decks zu groß und beliebig werden: Option "Chip entfernen" statt nur hinzufügen testen (klassisches Deck-Ausdünnen).

### Update: Station & alle Monster
Alle 25 Monster als Sprites, 3 neue spielbare Basismonster, 4 Fusionsmonster mit eigenen Decks. Meta-Ebene mit Brutnest, Labor und Monsterdex → [[Station-Prototyp]]

### Update: Vier Stufen & Digimon-UP-Größen
Feuerfuchs-Linie komplett spielbar: Pixi (Baby, 32) → Blazebit (Rookie, 64) → Glutfuchs (Champion, 80) → Infernitsune (Ultra, 96). Stufen im Prototyp bei 100 / 250 / 500 Prägung, je Stufe +10 HP. Größere Formen stehen auf der Plattform und ragen über das Feld. Testfunktion im Team-Tab: „Evolution beschleunigen“. Der Ergebnisbildschirm zeigt die Silhouette der nächsten Stufe. → [[Art Direction]]

### Update: PixelLab-Test & schwarze Konturen (27.09.2026)
Erster Sprite aus PixelLab: **Overclocko** (Funklings Code-Rookie) neu als elektrischer Welpe, 64×64, im Spiel eingebaut inkl. Blinzel-Frame. KI-Sprites werden lokal auf 32 Farben reduziert (optisch kein Unterschied). **Stilentscheidung:** Konturen ab jetzt fast schwarz statt farbig – die Feuerfuchs-Linie (Pixi, Blazebit, Glutfuchs, Infernitsune) wurde angeglichen und hat jetzt eine geschlossene Kontur. Werkzeuge: `tools/sprites/node/` (`png2spr.js`, `dark_outline.js`, `spr2png.js`). → [[Art Direction]]
**Offen:** Die Testfunktion „Evolution beschleunigen“ entwickelt Funkling immer in die Feuer-Richtung (Glutbyte) – Overclocko erscheint nur über Code-Prägung im echten Spiel.

### Update: Funkling- & Tröpfel-Linie in neuer Staffel (27.09.2026)
Mit PixelLab neu erzeugt und eingebaut: **Funkling** (Feuer-Welpe, Baby 32), **Tröpfel** (Axolotl, Baby 32), **Glutbyte** (Feuer-Wolf, Rookie 64), **Kaskadi** (Wasserfall-Axolotl, Rookie 64), **Pufferling** (Kugelfisch-Axolotl, Rookie 64) – dazu Overclocko von vorher. Alle mit schwarzer Kontur (schwebende Partikel wie Funken/Tropfen bleiben ohne Kontur) und Blinzel-Frame.
Testfunktion „Evolution beschleunigen“ hat jetzt je Entwicklungsrichtung einen Knopf (z. B. „Funkling → Overclocko +100 Code“).
**Offen:** Champion/Ultra für diese Linien fehlen noch (PixelLab-Testguthaben: noch 10 Generierungen = 2 Bilder). Decks der Rookies entsprechen noch dem Basis-Monster (Overclocko spielt Funklings Feuer-Deck).

### Update: Erste Champions der neuen Linien (27.09.2026)
**Magmawulf** (Glutbyte → Champion, Feuer) und **Tsunamander** (Kaskadi → Champion, Wasser), je 80×80 mit Blinzel-Frame, in `UP`-Tabelle und Monsterdex (jetzt 29 Einträge). Der erste Wasser-Champion hatte einen abgeschnittenen Schweif und wurde neu erzeugt (Prompt jetzt mit „ganzer Körper im Bild“). PixelLab-Abo aktiv (Tier 1, 2.000 Generierungen/Monat).

### Update: Redesign Hamster-, Hasen- und Frosch-Linie (27.09.2026)
Die bisherigen Gegenstands-Monster sind jetzt Tiere mit digitalem Merkmal (Art Direction): **Kekso** (Hamster, Keks-Backen) → Tracko (Detektiv-Hamster, Virus) / Cachy (Licht-Hamster); **Lumi** (Hase, Cursor-Ohren) → Blinki (Blitz-Hase) / Screenshina (Bilderrahmen-Hase, Code); **Spamlet** (Frosch, Pop-up-Kehlblase) → Pop-Upsi (Pop-up-Akkordeon) / Trojo (Trojaner-Holzpferd-Frosch, Code). Babys 32 px, Rookies 64 px, alle mit schwarzer Kontur und (außer Tracko) Blinzel-Frame.
Spielbarer Spamlet hat eigenen Sprite-Schlüssel `Spamlet`, der Gegner Spamlet bleibt `spam` (Pop-up-Fenster).
Neues Werkzeug `tools/sprites/node/eyes.js` schlägt Augen-Positionen für den Blinzel-Frame vor (muss visuell geprüft werden). Verbrauch: 65 PixelLab-Generierungen (inkl. Neuversuche für Hase, Frosch, Tracko).

### Update: Designregel „keine Objekt-Monster“ (27.09.2026)
Feedback Produzent: Lumi-Linie super, Kekso-Baby super. Pop-up-Frosch, Trojaner-Holzpferd, Detektivmütze usw. verworfen → Regel: Monster sind echte Tier-Kreaturen (Digimon/Yu-Gi-Oh-Stil), Digitales nur als Körpermerkmal. Neu gemacht: Tracko (Schleich-Hamster mit Virus-Adern), Cachy (Licht-Hamster mit Strahlen-Fell), Spamlet (Pfeilgiftfrosch), Pop-Upsi (Giftfrosch mit Kehlblase), Trojo (Hornkröte mit Leiterbahnen). PixelLab stanzte bei Pop-Upsi viele Einzelpixel aus – `holes.js --fill` füllt jetzt Löcher bis 3 px mit Nachbarfarbe.
**Offen:** Namen Spamlet / Pop-Upsi / Trojo stammen noch aus den alten Objekt-Konzepten.

### Update: Frosch-Linie umbenannt & überarbeitet (27.09.2026)
Namen: **Quappel** (Baby, vorher Spamlet) → **Virulurch** (Virus, vorher Pop-Upsi) / **Hüpfbyte** (Code, vorher Trojo). Namen per Websuche gegen Pokémon/Digimon geprüft (Toxiquak & Co. wären Pokémon-Namen gewesen). Vor Launch professionelle Markenprüfung nötig. Alte Spielstände werden beim Laden automatisch umbenannt (`migrateNames`). Der Gegner „Spamlet“ behält seinen Namen, der Boss Kernelmantis ist jetzt die Riesenform der wilden Spamlets.
Virulurch/Hüpfbyte neu: stilisierter, näher an Quappels Lila-Rosa-Palette. Tracko neu: Keks-Braun wie Kekso statt dunkel/violett.

### Update: Pixi-Linie als Katzen (27.09.2026)
Pixi bleibt eine Katze (Entscheidung Produzent), jetzt im neuen Stil: Pixi (Baby 32, Pixel-Schwanz), Firewallo (Code, Wächter-Katze mit Sechseck-Schild-Muster), Virulina (Virus, Schleichkatze mit Pixelflecken), Prisma-Pixi (Licht, geheim, Regenbogen-Schweif). Erste Pixi-Version hatte ein mintgrünes „Halstuch“ → als Accessoire verworfen, ersetzt durch Brustfell.
**Offen:** Feuer-Linie Blazebit → Glutfuchs → Infernitsune ist noch Fuchs im alten Stil; Entscheidung Katze vs. Fuchs steht aus.

### Update: Feuer-Linie wird Katze (27.09.2026)
Pixi → **Blazebit** (Rookie 64, Feuerkatze) → **Glutluchs** (Champion 80, vorher Glutfuchs) → **Pyrolynx** (Ultra 96, vorher Infernitsune; drei Flammenschweife, Obsidian-Panzer). Namen per Websuche geprüft. Alte Spielstände werden per `migrateNames` umbenannt. Alte Fuchs-Sprites als `*_alt_fuchs.png` aufbewahrt. Die komplette Pixi-Familie ist jetzt im neuen Stil.

### Update: Gegner, Fusionen, Evolutions-Decks (27.09.2026)
**Gegner neu:** Bugsy, Glitchmotte, Spamlet (wild) je 64 px, Kernelmantis 96 px – im Stil der Monster, aber weiterhin Gegenstände/Insekten. Große Gegner werden jetzt wie Spieler-Monster in fester Pixelgröße gezeichnet (Füße auf der Plattform).
**Neu im Tier-Stil:** Frostbyte (Eis-Axolotl, 64), Fusionen Dampfbyte, Wolkerich, Quellcoda, 404-Geist (je 80, echte Tier-Chimären der Eltern).
**Evolutions-Decks:** Jede entwickelte Form startet mit eigenem 8-Chip-Deck (`EVO_DECK` im Code): 4–6 Element-Chips + Signatur-Chip + neutrale Basis. Babys behalten ihr Basis-Deck. Ziel: Die Spielweise bestimmt die Evolution – und die Evolution verstärkt dann diesen Spielstil. Test: `tests/evodeck.test.js`.
**Beobachten im Playtest:** Fühlen sich Evolutionen spürbar anders an? Werden Champion/Ultra-Decks zu stark (Pyrolynx: 5 Feuer-Angriffe)?

### Update: Testknopf „Alle Monster freischalten“ (27.09.2026)
Im Team-Tab unter „Prototyp-Test“: ersetzt das Team durch alle 29 Formen (jede in passender Stufe) und füllt den Monsterdex. Nur für interne Tests – vor externem Playtest ggf. ausblenden.

### Playtest 4 (intern, Produzent, 27.09.2026)
**Beobachtung:** Macht weiterhin Spaß, neue Grafik funktioniert. Aber: **zu wenig Inhalt** – Runs wiederholen sich schnell.
**Stand:** 15 Chips, 3 Gegner + 1 Boss, 1 Zone, Run = 3 Kämpfe + Boss. Gegner nur Virus/Licht → Element-Vorteile (Feuer/Wasser/Code) spielen kaum eine Rolle.

### Update: Signatur-Fähigkeiten (27.09.2026)
Antwort auf Playtest 4 („Chips sind für jeden Glitchy gleich“): Pixi-, Tröpfel- und Quappel-Linie haben jetzt eine **passive Fähigkeit** (Katzenreflex, Regeneration, Giftbaut) und **15 Signatur-Attacken** (eine pro Form) mit eigener Leiste und Taste. Team-Karten zeigen Signatur und Passiv. Details: [[Signatur-Fähigkeiten]].
**Beobachten:** Fühlen sich die Linien jetzt unterschiedlich an? Wird die Leiste zu schnell/zu langsam voll? Ist Tröpfels Regeneration spürbar (bisher eher schwach: 1 HP/s nach 3 s)?
**Offen:** Funkling, Kekso, Lumi, Fusionen.

### Update: Signatur-Fähigkeiten für alle 6 Linien (27.09.2026)
Produzent: Pixi/Tröpfel/Quappel „fühlen sich sehr gut an“. Nachgezogen: Funkling (Übermut, Funkenbiss → Glutbiss/Magmasturm/Überladung), Kekso (Hamstern, Backentasche → Keksfalle/Leuchtkeks), Lumi (Hasenhaken, Cursorblitz → Dreifachblitz/Abbild). Jetzt 6 Passive + 25 Signatur-Attacken. Fusionen folgen nach deren Überarbeitung.

### Update: Umbenennungen nach Namens-Check (27.09.2026)
Neues Werkzeug `tools/namecheck/namecheck.js` gleicht Namen mit der kompletten deutschen/englischen Pokémon-Liste (PokéWiki) und der Digimon-Liste (Wikimon) ab – exakt und ähnlich (Levenshtein ≤ 2). Funde: **„Pixi“ = deutscher Name von Pokémon Clefable**, **„Quappel“ ≈ „Quapsel“ (Poliwag)**. Umbenannt: Pixi → **Pixmiez**, Prisma-Pixi → **Prismiez**, Quappel → **Quakli**, Quellcoda → **Glyphel**, 404-Geist → **Spukatz**. Alte Spielstände werden per `migrateNames` umgestellt. Alle übrigen Namen: keine Treffer.

### Update: Drei neue Linien (27.09.2026)
Wunsch Produzent: Salamander, Bär und Maschinen-Monster. Neu: **Molchi** (Salamander, Virus → Toxmolch / Magmolch), **Brummbit** (Bär, Licht, Tank mit 140 HP → Sonnbrumm / Bärtron = Mecha-Bär), **Kauzbit** (Robo-Eule, Code → Optikauz / Raketauz). Je eigene Passive (Giftdrüsen, Dickes Fell, Eulenblick) und Signatur-Attacken, Startdecks, in Selten- und Episch-Eiern. Monsterdex jetzt 38. Maschinen-Tiere sind ab jetzt erlaubt (Tierform bleibt erkennbar).
**Offen:** Mecha-Champions für die Code-Richtungen (Firewallo, Overclocko, Pufferling, Hüpfbyte, Screenshina, Bärtron, Optikauz).

### Update: Mecha-Champions (27.09.2026)
Die Code-Richtungen bekommen Mecha-Champions (80 px, ab 250 Prägung): Firewallo → **Bollwerkatz**, Overclocko → **Turbowulf**, Pufferling → **Panzerpuff**, Hüpfbyte → **Mechaquak**, Screenshina → **Holohas**, Bärtron → **Titanbrumm**, Optikauz → **Radarkauz**. Je eigenes Startdeck und stärkere Signatur-Attacke. Monsterdex: 45.

### Update: Station-Leben (27.09.2026)
Bindung (0–5 Herzen, faire Boni, sinkt nie), Pflege-Ansicht (streicheln, Datenkekse füttern) und Expeditionen (5 Element-Zonen, Echtzeit, Heimvorteil, Prägung als Belohnung). Details: [[Station-Leben]].
**Beobachten:** Wird die Station jetzt öfter besucht? Fühlt sich Streicheln belohnend an? Sind Expeditionen zu stark?
**Neu fürs Testen:** `node tools/devserver.js` startet den Prototyp unter http://localhost:8123.

### Playtest 5 (intern, Produzent, 28.09.2026) – Godot-Version
**Stand:** Kampf-Kern in Godot (Pixmiez, 15 Chips, 3 Gegner + Boss), Pixel-Schrift, synthetisierte Platzhalter-Sounds, Titel, Optionen, Pause.
**Beobachtung:** Kampfgefühl und Sounds fühlen sich gut an. Damit ist die Frage von Phase 1 beantwortet: **Ja**, die Godot-Version trägt.
**Offen:** Schwierigkeit (Autopilot gewinnt 40/40), Animationen, Musik. Weiter mit Phase 2 (kompletter Run mit Zonenkarte), siehe [[Roadmap]].

### Playtest 6 (intern, Produzent, 29.09.2026) – Station, Labor, Firewall-Vulkan
**Stand:** Station mit Spielstand, 9 Linien + 4 Fusionen (44 Formen), Labor, Zone 2 mit Lava-Mechanik, Musik im GBA/DS-Stil.
**Beobachtung:** „Spielt sich sehr gut.“ Vulkan per Testfunktion angespielt.
**Offen:** Schwierigkeit bleibt zu beobachten (Autopilot gewinnt alles), externe Tester fehlen noch.

### Update Spielfeld (29.09.2026)
Feedback: „Manchmal ist das Spielfeld ein bisschen zu klein.“ → Felder 88×50 statt 80×44, Battle-Network-Paneele (Fase, Innenplatte mit Datenraster, Vorderkante, hintere Reihe dunkler), Sockel mit Schatten unter der Arena, leuchtende Mittellinie. Handleiste etwas tiefer.

### Update Kampf-Juice (29.09.2026)
Prozedurale Animationen ohne Skalierung (Pixel bleiben scharf): Vorschnellen + Mündungsblitz bei Angriffs-Chips, Rückstoß bei Treffern (Spieler und Gegner), Gegner holt während der Warnung aus und schnellt beim Zuschlagen vor (+ Wusch-Sound), Hüpfer + Staubwolke beim Bewegen, besiegte Gegner blinken, sinken ab und verblassen.

### Bugfix Musik (29.09.2026)
Feedback: Kampfmusik blieb manchmal stumm (Karte → nächster Kampf). Ursache: verspäteter Stopp-Befehl der vorigen Überblendung traf den Abspieler, der gerade die neue Musik spielte (passiert beim schnellen Durchklicken). Fix: laufende Blenden werden bei jedem Wechsel abgebrochen, gestoppt wird nur ein inaktiver Abspieler. Regressionstest stellt den schnellen Wechsel nach (schlug mit altem Code fehl).
