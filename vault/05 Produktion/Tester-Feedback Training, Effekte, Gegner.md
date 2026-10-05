---
tags: [produktion, spieltest, godot]
---
# Tester-Feedback 04.10.2026: Training, Effekte, Gegner

Das Feedback der Tester:
- „Wir brauchen einen Tutorial-Kampf. Das Handbuch wird kaum gelesen, die Leute wollen in einen Kampf geworfen werden.“
- „Die Effekte sollen zu den Karten bzw. Patches passen.“
- „Je nach Zone sollen passende Gegner kommen. Die Bosse passen, die Gegner nicht.“

## 1. Trainingskampf (Entscheidung Produzent: direkt nach der Starterwahl)
**Ablauf:** Intro > Starter wählen > **sofort ein geführter Kampf** mit dem neuen Glitchling gegen Bugsy (Cache-Wiesen) > Station. Das Training lässt sich jederzeit über **Titel > Training** wiederholen (nur mit Spielstand).

**Acht Lernschritte**, alle zum Selbermachen, mit kurzen Texten und ohne Verweis aufs Handbuch:
1. Bewegen (3 Schritte)
2. Angriff 1: Der Gegner stellt sich in deine Reihe.
3. Angriff 2 (beide Angriffs-Slots ziehen aus demselben Stapel)
4. Ausweichen (2×)
5. Schützen: Die Firewall liegt im Support-Slot bereit, der Gegner greift genau deine Reihe an, und „Geblockt“ zählt.
6. Element-Vorteil: Der Blitzcursor liegt bereit, Elektro gegen Virus gibt „Effektiv!“.
7. Großangriff: Ein goldenes Glitchkreuz in X-Form. Wer allen Feldern ausweicht, überlastet den Gegner. Bei einem Treffer kommt das Kreuz noch einmal.
8. Signatur: Die Leiste wird gefüllt.

Danach wird frei gekämpft, bis der Gegner besiegt ist. Den Takt bestimmt der Spieler: Der Gegner greift nur in den Schritten an, in denen es ums Ausweichen geht.

**Regeln im Training:**
- Verlieren ist unmöglich (HP bleiben mindestens 1).
- Es gibt keine Bereit-Pause, keine Entwicklung, keine Chipwahl, keine Belohnung, und nichts wird gespeichert.
- Danach gilt `tutorial_done`, der erste echte Run startet also ohne Tutorial.

**Technik:**
- `Tutorial` (8 Schritte, `LEARN_STEPS`)
- `RunState.training`
- `main.start_training(then)`
- `BattleState.last_slot` und `last_mult` erkennen, welcher Slot gespielt wurde und ob ein Treffer effektiv war.
- Test „Training: …“ mit 8 Prüfungen.

## 2. Effekte passend zur Karte
Vorher sahen alle geraden Geschosse gleich aus: ein Balken in der Element-Farbe. Geworfenes war ein Quadrat, Treffer waren ein farbiges Aufblitzen. **Der Heilpatch versprühte sogar gelbe Elektro-Funken.**

Neu: rein optische Effekte (`BattleState.vfx`, gezeichnet in `battle_view._draw_vfx`), dazu Geschosse je Chip (`_draw_proj`) und Schilde je Karte (`_draw_shield`):

| Art | Chips |
|---|---|
| Geschosse | **Pixelstrahl** Datenstrahl mit abplatzenden Pixeln · **Wasserstrahl** Strahl mit Tropfen · **Virusspritzer** Giftklecks · **Datenfresser** Fressmaul · **Kurzschluss** Funkenkugel · **Frostsplitter** Eissplitter · **Parasit** Zecke · **Doppelklick** zwei Pfeile · **Glutball** Feuerball mit Explosion |
| Nahkampf und Strahlen | **Byteschlag/Glutklinge** Klingen-Bogen · **Laserschuss** Laser · **Debugger** grüner Laser mit Code-Zeichen · **Blitzlanze** Blitzsäule · **Blitzcursor/Kettenblitz** Blitzeinschläge und Kettenblitz |
| Feuer | **Flammenwelle** Flammenzungen in der Spalte · **Feuersbrunst** Flammen überall · **Funkenregen** fallende Funken · **Hitzeschild** Flammenring |
| Wasser | **Flutwelle** Welle über die Reihe · **Tsunami** Wasserwand übers Feld · **Eisfeld** Eiskristalle · **Strudel** Wirbel · **Nebel/Blubberschild** Nebel bzw. Blase |
| Elektro | **Blendgranate** Blendblitz mit Strahlen · **Blackout** Feld wird dunkel, Funken · **Magnetfeld** Feldlinien · **Ladungsfeld** Ladungsring |
| Virus | **Seuche** Giftblasen · **Wurmloch** Portal am Boden · **Bug-Mine/Sporenfalle** fallende Mine |
| Patches und Hilfen | **Heilpatch** ein Pflaster fliegt heran und klebt, grüne Plus-Zeichen · **Neustart** Kreispfeil · **Übertakten** Tempolinien und Zahnrad · **Defrag** bunte Blöcke ordnen sich · **Portscan** Radarwelle und Fadenkreuz · **Sprungantrieb** Sprungpfeile · **Mini-Bot/Geschützturm** Pixel-Wolke |
| Schilde | **Firewall** glühende Mauer mit Flammenspitzen · **Kopierschutz** Sechseck mit Schloss · **Konter** gekreuzte Klingen · Aufbau jeweils als Sechseck-Welle |

**Prüfung:**
- Der Test „Alle 45 Chips haben einen passenden Effekt“ und der Heilpatch-Test laufen.
- Kontaktbögen per `--mode=fight --chip=<Name> --t=<s>` (neue Screenshot-Option).
- Leistung: Ur-Glitch-Kampf weiter bei 1,3 ms pro Bild.

## 3. Zonentypische Gegner (Entscheidung Produzent: alle 5 neuen zeichnen)
Vorher hatte jede Zone nur 2–3 eigene Gegner und wurde mit Gegnern aus anderen Zonen aufgefüllt:
- Vulkan: Datenwespe und Chiffrekäfer
- Sümpfe: Glutraupe und Brandmauerassel
- Kern: Panzerschnecke und Glitchblüte

Jetzt hat jede Zone nur noch ihre eigenen Gegner:

| Zone | Gegner |
|---|---|
| Cache-Wiesen | Bugsy, Glitchmotte, Datenwespe, Bytewurm, Chiffrekäfer |
| Firewall-Vulkan | Glutmilbe, Aschefalter, Brandmauerassel, Glutraupe (aus den Wiesen umgezogen), **Funkenkäfer** (neu) |
| Viren-Sümpfe | Saugmücke, Panzerschnecke, Glitchblüte, **Datenegel** (neu), **Moorlibelle** (neu) |
| NEST-Kern | Kerndrohne, Glitchspinne, **Sentinelkrabbe** (neu), **Fehlerqualle** (neu) |

Die neuen Gegner, alle 64 px, gezeichnet mit PixelLab Pro Flash im Stil der bestehenden Gegner, mit Idle-Animation:

| Gegner | Englisch | Aussehen | Kampfverhalten |
|---|---|---|---|
| **Funkenkäfer** | Sparkbeetle | Bombardierkäfer mit Lavarissen | Feuer: Einzelfeld, Lava, Einzelfeld. Blinzelt. |
| **Datenegel** | Dataleech | Blutegel mit Saugmaul | Wasser: Reihe und Schleim, Lebensraub. Blinzelt nicht, hat keine Augen. |
| **Moorlibelle** | Mirefly | Libelle | Wasser: schnell, teleportiert, Einzelfelder und Spalte. Blinzelt nicht, Facettenaugen. |
| **Sentinelkrabbe** | Sentinelcrab | Mecha-Krabbe | Code: zäh, Reihe und Doppelspalte. Blinzelt. Erste Fassung war am Rand angeschnitten und wurde neu gezeichnet. |
| **Fehlerqualle** | Errorjelly | Glitch-Qualle | Elektro: teleportiert, Kreuz und Einzelfeld. Blinzelt. |

Alle Namen sind mit `tools/namecheck` geprüft. Ein Test prüft, dass jede Zone nur ihre eigenen Gegner hat, und die Autopilot-Runs gewinnen weiter in allen Zonen.
