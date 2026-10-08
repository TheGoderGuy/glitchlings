---
tags: [produktion, analyse, gameplay, balancing]
---
# Game-Design-Analyse (08.10.2026)

> **Umsetzung:** Der Produzent hat Phase A, B und die Struktur (Option B, Reise) freigegeben. Umgesetzt am selben Tag, Details und neue Messwerte in [[Kampf-Kern, Evolution und Reise]]. Noch offen aus B: Linien-Chips. Phase D (zwei Währungen, Kampffeld, Gegnergrößen) steht noch aus.

> Auftrag des Produzenten: Spielprinzip und Assets bewerten (nicht Vertrieb). Ziel: „ein sauberes, gutes Spiel mit einer perfekten Gameloop, die Spaß macht“.
> Grundlage: Code in `game/` (Kampf, Run, Station, Daten), Vault, gerenderte Screenshots, eigenes Spieltest-Log, Autopilot-Simulation mit rund 950 Runs.

## Das Urteil in drei Sätzen
1. Präsentation, Kreaturen und Umfang sind auf dem Niveau eines fertigen Spiels. Die **Spielmechanik trägt diesen Inhalt aber noch nicht**.
2. Der Kampf ist so schnell vorbei, dass er kaum Entscheidungen verlangt. Wer alles drückt, was bereit ist, gewinnt. Deckbau und Evolution haben dadurch kaum spürbare Folgen.
3. Das Fundament (Raster-Kampf, Tier-Monster, Prägung) ist richtig. Die Probleme sitzen in wenigen Stellschrauben. **Erst den Kern reparieren, dann wieder Inhalte bauen.**

## Bewertung
| Bereich | Note (1–10) | Kurz |
|---|---|---|
| Konzept & Fantasie | 9 | Tier-Monster + MMBN-Raster + Prägung ist ein starkes, eigenständiges Versprechen |
| Monster-Grafik & Animation | 8 | einheitlich, gute Silhouetten, Wachstum je Stufe sichtbar, 132 Figuren animiert |
| Kampfgefühl (Feedback) | 8 | Treffer, Bildstopp, Effekte je Chip, Boss-Intros: fühlt sich gut an |
| Kampftiefe (Entscheidungen) | 3 | dominante Strategie: alles abfeuern, rote Felder verlassen |
| Schwierigkeit & Spannung | 2 | selbst Babys gewinnen das Finale; Niederlagen sind fast unmöglich |
| Deckbau | 3 | Chipwahl ändert am Ergebnis messbar nichts |
| Evolution (Alleinstellung) | 4 | Idee und Präsentation stark, Folgen fürs Spiel fast null |
| Run-Struktur | 4 | eine Zone = ein Run, Deck startet jedes Mal neu, geschaffte Zonen haben wenig Wert |
| Meta / Station | 5 | viele Reiter, wenig Zugkraft zurück in den Run |
| Kampffeld, Menü-Grafik | 5 | flaches, gleichförmiges Raster, Händler/Ereignisse als Textlisten |

## Was stark ist und bleiben soll
- **Das Raster mit Telegrafen.** Rote Felder, goldene Großangriffe mit „Überlastet“-Belohnung, Flächen je Zone. Das ist lesbar und fair.
- **Spannungsfelder in der Steppe.** Sie kosten HP, laden aber Chips doppelt so schnell. Das ist das beste Risiko/Nutzen-Design im Spiel; davon braucht es mehr.
- **Die Prägungs-Vorschau in der Chipwahl** („Prägt > Prismiez“). Sie verknüpft Entscheidung und Evolution direkt.
- **Die Bedingungen der Legendären** (ohne Heilpatch, Signatur als letzter Schlag, nie mitgerissen). Sie verändern, *wie* man einen Kampf spielt. Genau so sollten sich auch normale Ziele anfühlen.
- **Kartenlesbarkeit:** Trefferbild, Kurzwirkung, Rollenfarben, nächster Chip sichtbar.
- **Premium ohne Zwangsschleifen**, Eier an Runs gekoppelt.
- **Die Monster.** Sie sind das größte Kapital des Projekts.

## Messung: Wie schwer ist das Spiel?
Autopilot (`BattleBot`) spielt komplette Zonen-Runs; je Zone die realistische Stufe (Wiesen Baby, Vulkan Rookie, See/Sümpfe Champion, Steppe/Kern Ultra). „Mensch“ = Bot mit 0,5 s Reaktion, 0,35 s zum Zielen, 0,3 s Zögern vor jedem Chip, 8 % Fehltritte.

| Zone | Bot perfekt (r = 0,25) | „Mensch“ | Ø normaler Kampf | Gegnerangriffe bis zum Sieg | HP-Verlust je Kampf | Wächter/Boss |
|---|---|---|---|---|---|---|
| Cache-Wiesen | 26/26 | 13/13 | 3,3 s | 0,8 | 0 % | 11 s |
| Firewall-Vulkan | 26/26 | 13/13 | 5,0 s | 1,4 | 0 % | 14 s |
| Kühlwasser-See | 26/26 | 13/13 | 6,7 s | 2,0 | 1 % | 16 s |
| Viren-Sümpfe | 26/26 | 13/13 | 7,7 s | 2,4 | 0 % | 17 s |
| Hochspannungs-Steppe | 26/26 | 13/13 | 6,7 s | 2,4 | 1 % | 15 s |
| NEST-Kern | 26/26 | 13/13 | 7,9 s | 2,5 | 1 % | 20 s |

Zusatztests:
- **Baby im NEST-Kern** („Mensch“): 13/13 Siege, 91 % HP am Ende.
- **Nie ausweichen**, nur zielen und feuern: alle Zonen 26/26, 1–4 % HP-Verlust je Kampf.
- **Nie zielen**, nur ausweichen: alle Zonen 26/26, Kämpfe nur 20–40 % länger.
- **Nie einen Chip nehmen** (nur Startdeck, Sümpfe, Champion): 26/26, genauso viele Siege wie mit Chipwahl.
- **Korrumpiert:** weiterhin 13/13. Erst **Korrumpiert + Protokoll 10** kostet etwa jeden zweiten Run.
- Das eigene Spieltest-Log bestätigt die Größenordnung: Eine Zone dauert real 3–11 Minuten, fast alle Runs enden mit Sieg. **Die Geschichte ist in etwa einer Stunde durchgespielt** (Ziel laut Steam-Neuausrichtung: 15–25 Stunden Gesamtumfang).

Einordnung: Ein Bot ist kein Mensch. Menschen verlieren gelegentlich, weil sie unaufmerksam sind (siehe Log). Aber wenn ein Bot ohne Ausweichen, ohne Zielen oder ohne Chipwahl genauso sicher gewinnt, **haben diese Ebenen kein Gewicht**. Herausforderung entsteht dann nur noch aus Unaufmerksamkeit, nicht aus Entscheidungen.

## Die Kernprobleme, nach Wirkung sortiert

### 1. Der Kampf ist vorbei, bevor er anfängt
- Der Kampf startet mit drei sofort bereiten Chips. Ein normaler Gegner verliert in der ersten Sekunde 40–60 % seiner HP.
- Der erste Gegnerangriff kommt frühestens nach `atk × 0,8 + 0,7 s Warnung` (Bugsy: 2,6 s). **Viele Gegner sterben, bevor sie einmal zuschlagen.**
- Es gibt keine Ressource außer der Ladezeit, und die läuft automatisch. Beide Angriffs-Slots ziehen aus demselben Stapel. **Es gibt keinen Grund, einen Chip zu halten.** Die beste Strategie ist immer: abfeuern, sobald bereit.
- Folge: Bosse mit drei Phasen, Großangriffen und Dienern werden in 11–20 s besiegt. Spieler sehen die Hälfte der Boss-Mechaniken nie.

### 2. Gegner greifen deinen Standort an, nicht aus ihrer Position
- Alle Gegnerangriffe (`_enemy_attack`) werden relativ zum **Feld des Spielers** gebaut: Reihe, Spalte, Kreuz um den Spieler. Wo der Gegner steht, ist für die Verteidigung egal.
- Damit fehlt der Kern von Megaman Battle Network: **„Um ihn zu treffen, muss ich in seine Reihe. In seiner Reihe trifft er mich.“** Angriff und Verteidigung stehen nicht in Spannung.
- Jeder Gegner spielt sich deshalb gleich: rote Felder unter mir, einen Schritt weg, weiterfeuern. Die Gegner unterscheiden sich in Form und Takt, nicht im Verhalten.

### 3. Keine Spannung über den Run
- Spieler-HP wachsen nur um 10 je Stufe, Gegner-HP um ×1,75 über alle Zonen. Die Spielerstärke wächst durch Deck, Verbesserungen, Module und Signatur aber deutlich schneller.
- Heilung nach jedem Kampf (+10), Rastplätze (35 %), Regeneration und Heilpatch decken die winzigen Verluste mehrfach ab.
- Ohne Niederlagen gibt es kein „knapp geschafft“, keine Angst um den Run und keinen Grund, an Modulen oder Routen zu tüfteln.

### 4. Deckbau ohne Gewicht
- Die Chipwahl zieht aus **allen 45 Chips**, nur nach Seltenheit gewichtet. Sie reagiert weder auf Monster noch auf Zone noch auf die Entwicklungsrichtung.
- Es gibt nur sechs echte Payoff-Chips (Brand, Gift, Kälte, Reihe, Spalte). Die meisten Chips sind „Schaden in deiner Reihe plus kleiner Effekt“.
- Messung: Mit und ohne Chipwahl gewinnt der Bot gleich oft.
- Jeder Zonen-Run beginnt wieder mit dem 8er-Startdeck. Der Bogen „mein Deck wird zur Maschine“ dauert nur etwa 10 Picks und wird sechsmal zurückgesetzt.

### 5. Evolution: ein einmaliges Ereignis ohne Folgen
- **Nur eine Weiche:** Baby > Rookie hat 2–3 Richtungen, danach geht es linear bis Ultra.
- **Zu schnell:** 12 / 35 / 80 Element-Chips über alle Runs bedeuten: Rookie im ersten Run, Ultra nach etwa 2–3 Runs (Log: Prismiez > Aurorlynx in zwei Runs). Im Ursprungskonzept waren es ~3 / 15 / 50 Runs.
- **Keine Rückkopplung:** Das Element der Form hat im Kampf keine Wirkung, außer auf die eigene Signatur. Es gibt keinen Bonus für passende Chips, keine Schwäche und kein neues Deck. Das Passiv hängt an der Linie, nicht an der Form. Eine Evolution bringt +10 HP und eine neue Signatur.
- Damit wird das Versprechen „Die Spielweise bestimmt die Evolution“ nur halb eingelöst. Es fehlt die zweite Hälfte: **„… und die Evolution verändert, wie ich spiele.“**

### 6. Struktur: eine Zone = ein Run
- Die Zonen sind linear und werden dauerhaft freigeschaltet. Eine geschaffte Zone muss man nie wieder spielen. Danach motivieren nur noch Eier, Fragmente oder Legendäre.
- Ein Roguelite lebt davon, dass ein langer Run auf dem Spiel steht. Hier steht nach 5–10 Minuten fast nichts auf dem Spiel.

### 7. Meta und Monster-Identität
- **Eine Währung für alles:** Fragmente bezahlen den Händler im Run und werden danach auf die Station gerettet. Jeder Einkauf beim Händler kostet also Meta-Fortschritt. Das bremst genau die Entscheidungen, die im Run Spaß machen sollen.
- **Monster spielen sich ähnlich:** Die Startdecks teilen sich 5 von 8 Chips (Pixelstrahl ×2, Byteschlag, Heilpatch …). Alle ziehen aus demselben Chip-Pool. Spürbar verschieden sind vor allem die Tempo-Passive (Lumi) und der Tank (Brummbit). Hamstern 25 % oder Eulenblick +0,3 s merkt man kaum.
- **Wenig Grund, das Team zu wechseln:** Der Element-Tipp einer Zone („Wasser hat hier einen Vorteil“) betrifft nur Chips, nicht das Monster.
- Zuhause und Streicheln sind rein kosmetisch. Das ist in Ordnung, ein Wohlfühlort darf das sein.

### 8. Takt
- Bei 3–8 s Kampf kommen 0,7 s Materialisieren, 1,5 s Siegerpose und die Chipwahl dazu. Die Inszenierung ist fast so lang wie der Kampf. Das löst sich von selbst, sobald Kämpfe 15–25 s dauern.

## Assets
**Stark**
- Monster: einheitlicher Stil, klare Silhouetten, sichtbares Wachstum von Baby bis Ultra, Idle- und Angriffsanimationen für alle 132 Figuren.
- Boss-Intros, Kino-Intro und -Ende, Zonenkulissen, Effekte je Chip.
- HUD und Karten sind gut lesbar, die Schriftwahl passt.

**Schwach**
1. **Kampffeld:** Das Raster ist flach, riesig (88 × 50 je Feld) und in allen Zonen gleich. Es verdeckt die Zonenkulisse fast komplett und wirkt wie eine Tabelle, nicht wie ein Ort. Vorschlag: Feld-Material je Zone (Gras, Obsidian, Eis, Moos, Metall), leichte Perspektive wie bei MMBN, flachere Felder, mehr Kulisse sichtbar.
2. **Babys im Kampf:** 32 px auf einem 88-px-Feld. Gerade die ersten Minuten (Baby-Phase) sehen am leersten aus. `BABY_SCALE = 2` im Kampf wäre ganzzahlig. Das widerspricht aber dem bewusst sichtbaren Wachstum, also Entscheidung Produzent.
3. **Größenverhältnis im Spätspiel:** Ein Ultra (96 px) überragt normale Gegner. Die Gegner wirken harmlos. Spätere Zonen und Elites sollten größere Gegner haben.
4. **Evolutions-Szene:** Für das wichtigste Ereignis des Spiels ist sie zu bescheiden (kleines Sprite, ein Lichtstrahl, „+10 max. HP“). Sie sollte der spektakulärste Bildschirm sein und zeigen, was sich spielerisch ändert.
5. **Händler, Rast, Ereignisse** sind Textlisten. Chips sollten dort als dieselben Karten erscheinen wie in der Chipwahl.
6. **Zuhause:** Die Bewohner ballen sich in der Bildmitte und überdecken sich (Screenshot `--mode=home --t=6`).
7. Musik und Sounds sind Platzhalter (bekannt).

## Zielbild: die Gameloop in einem Satz
> **Jeder Kampf ist ein kleines Positionsduell. Jede Chipwahl formt mein Monster. Jede Evolution verändert, wie ich spiele. Jeder Boss prüft, ob mein Build hält.**

```
Kampf (Positionsduell, 15–25 s)
  > Chipwahl (Build + Prägungsrichtung)
    > Evolution im Run (neue Regel, die den Build verstärkt)
      > Wächter/Boss (Prüfung, echte Niederlagen möglich)
        > Station (Ei, Fusion, neue Linie = neuer Spielstil)
          > nächster Run mit anderem Monster / anderer Route
```

**Zielwerte** (Normal, durchschnittlicher Spieler):
- Normaler Kampf 15–25 s, 4–8 Gegnerangriffe, 8–15 % HP-Verlust
- Elite 30–40 s, Wächter 45–60 s, Boss 60–90 s mit allen Phasen und 2–3 Großangriffen
- Erster Versuch: Zone 1 etwa 85 % Siegchance, letzte Zone etwa 50 %
- Bis zum Abspann 8–12 Stunden, mit Dex und Protokollen 20+

## Empfehlungen und Reihenfolge

### Phase A: Kampf-Kern (vor allem anderen)
1. **Gegnerangriffe bekommen eine Herkunft.** Gegner-Archetypen statt nur Muster:
   - *Schützen* feuern entlang **ihrer** Reihe und suchen deine Reihe. Wer zurückschießen will, steht in der Schusslinie.
   - *Werfer* (Artillerie) zielen wie heute auf dein Feld, halten aber Abstand.
   - *Nahkämpfer* springen nach vorn und treffen nur die vorderste Spalte.
   - *Flächenleger* (Lava, Schleim, Strömung, Spannung) wie heute.
   - Großangriffe (gold) bleiben flächig und standortbezogen.
2. **Konter-Treffer.** Wer einen Gegner trifft, während er ausholt (die Warnung läuft und die Angriffsanimation ist schon synchron), bricht den Angriff ab: Betäubung 0,8 s, +50 % Schaden, „Konter!“, Extra-Signaturladung. **Damit lohnt es sich, einen starken Chip zu halten.** Das ist die einfachste Art, Timing-Entscheidungen zu erzeugen, und sie passt zu den vorhandenen Ausholanimationen.
3. **Time-to-kill anheben:** Gegner-HP etwa ×2–2,5, erster Gegnerangriff früher (z. B. `atk × 0,4`), Bosse so, dass alle Phasen gesehen werden. Heilung nach dem Kampf neu einstellen.
4. **Simulation als Werkzeug fest einbauen:** den „Mensch“-Bot als Test mit Zielkorridoren je Zone (Siegquote, Kampfdauer, HP-Verlust). Jede Balancing-Änderung wird dagegen gemessen. Das Skript der Analyse liegt nur temporär im Scratchpad, es müsste neu angelegt werden.

**Ja/Nein-Frage am Ende:** Fühlt sich jeder normale Kampf wie ein kleines Duell an, bei dem man den Gegner lesen muss?

### Phase B: Build & Evolution (das Alleinstellungsmerkmal einlösen)
1. **Resonanz:** Chips im Element der aktuellen Form machen +25 % Schaden. Evolution verstärkt so den Stil, der sie ausgelöst hat.
2. **Eigenschaft je Form** (nur Text, keine Grafik): z. B. Firewallo „Schilde laden 20 % schneller“, Virulina „Gift tickt schneller“, Prismiez „Elektro-Treffer betäuben kurz“. Jede Stufe ändert eine Regel, nicht nur Zahlen.
3. **Chipwahl lenkt mit:** In jeder Wahl liegt mindestens ein Chip einer möglichen Entwicklungsrichtung des Monsters. Zonen gewichten ihr eigenes Element etwas höher.
4. **Archetypen ausbauen:** je Archetyp (Brand, Gift, Kälte, Position, Fallen, Signatur) 2–3 Auslöser, 2–3 Payoffs und ein Modul. Weniger „Schaden + Effekt“-Chips, mehr Chips mit Bedingungen.
5. **Überspringen belohnen** (Fragmente oder kleine Heilung), damit schlanke Decks eine echte Strategie sind.
6. **Evolutionskurve verlangsamen:** Startwert zum Prüfen 12 / 100 / 280 Element-Chips (Rookie im ersten Run, Champion nach ~2–3, Ultra nach ~6–7 Runs). Dazu **„Neu prägen“ im Labor** (zurück zum Baby, Dex bleibt), damit man andere Richtungen ohne doppeltes Ei ausprobieren kann.
7. **Eigener Linien-Chip** für jede der 13 Linien im Startdeck, z. B. Kekso „Backentasche“ oder Quakli „Zungenzug“. Kartenbilder sind prozedural, das kostet keine Grafik.
8. **Evolutions-Szene** groß inszenieren und die neue Regel zeigen.
9. Später, falls nötig: eine **geheime zweite Ultra-Form je Linie** über eine Spielweise-Bedingung (wie bei den Legendären). Kostet 13–26 Sprites.

### Phase C: Struktur (Entscheidung Produzent, berührt die Entscheidung „linear“ vom 06.10.)
- **Option A (behalten, aufwerten):** Eine Zone bleibt ein Run. Geschaffte Zonen bekommen eigenen Wiederspielwert, z. B. zonentypische Eier und Formen, eigene Protokoll-Stufen je Zone und eine Bestzeit. Wenig Aufwand, das Grundproblem (kurzer Bogen, wenig auf dem Spiel) bleibt aber.
- **Option B (empfohlen):** **Ein Run ist eine Reise durch mehrere Zonen.** Akt 1 Cache-Wiesen, Akt 2 nach Wahl Vulkan oder See, Akt 3 nach Wahl Sümpfe oder Steppe, Finale NEST-Kern. Jeder Akt ist kürzer (z. B. 2 Ebenen × 4 Etagen + Wächter/Boss). Deck, Module und HP bleiben über den ganzen Run. Ein Run dauert etwa 35–45 Minuten und lässt sich speichern (gibt es schon).
  - Die Zonenwahl wird zur Build-Entscheidung (Element-Vorteil, Prägungs-Ereignisse).
  - Die Evolution passiert *im* Run und wirkt sofort.
  - Alle vorhandenen Inhalte werden weiterverwendet. Die Protokolle werden zur Aufstiegsleiter wie bei Slay the Spire.

### Phase D: Meta & Politur
1. **Zwei Währungen:** *Bits* für den Händler im Run, *Fragmente* für die Station (aus Wächtern, Bossen, Elites und Meilensteinen). Händler-Entscheidungen fühlen sich dann nicht mehr wie Verzicht an.
2. Kampffeld neu (Material je Zone, Perspektive), Gegnergrößen im Spätspiel, Karten in Händler und Ereignissen, Zuhause entzerren.
3. Musik und Sound.

### Inhaltsstopp
In zehn Tagen sind 13 Linien, 114 Formen, 6 Zonen, 45 Chips und 22 Module entstanden. Das ist beeindruckend, aber **jede weitere Form und jede weitere Zone vergrößert ein Spiel, dessen Kern noch nicht trägt**. Empfehlung: keine neuen Monster, Zonen oder Gegner, bis Phase A und B gespielt und gemessen sind. Neue Chips nur noch, wenn sie einen Archetyp schließen.

## Entscheidungen für den Produzenten
1. Phase A starten (Herkunft der Gegnerangriffe, Konter-Treffer, Time-to-kill)?
2. Struktur: Option A oder B?
3. Babys im Kampf ×2 (`BABY_SCALE`) oder bewusst klein lassen?
4. Zwei Währungen?
5. Inhaltsstopp bis nach Phase B?

Siehe auch: [[Roadmap]], [[Kampfsystem]], [[Evolution im Run]], [[Zonenkarte]], [[Externer Spieltest]]
