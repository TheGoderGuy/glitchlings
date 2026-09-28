# GLITCHLINGS – Game Design Konzept (Gesamtfassung)

Spielbarer Prototyp: https://claude.ai/artifact/2R9X4FbbNXKrvYjsZsyMHX

## Vision & Pitch

### Der Satz
Ein Monster-Sammelspiel, in dem du kleine digitale Kreaturen ausbrütest, fusionierst und in kurzen Roguelite-Kämpfen trainierst – und **die Art, wie du kämpfst, bestimmt, wozu sie sich entwickeln.**

### Inspirationen
| Quelle | Was wir übernehmen |
|---|---|
| Megaman Battle Network | 3×3-Kampfraster, Chips als Angriffe |
| Digimon | Digitale Monster, verzweigte Evolution |
| Yu-Gi-Oh | Deckbau, Fallen, Fusion |
| Pokémon | Sammeln, Monsterdex, Seltenheit |
| Slay the Spire | Roguelite-Runs, 1-aus-3-Kartenwahl |
| Tamagotchi / Merge-Games | Brüten in Echtzeit, Pflege, Kurzbesuche |

### Die drei Säulen
1. **Kämpfen** → Kampfsystem – kurze, intensive Runs (3–4 Min.)
2. **Entwickeln** → Evolution & Prägung – Neugier als Motor
3. **Fusionieren & Brüten** → Station, Brüten & Fusion – Sammeln & Bauen

### Alleinstellungsmerkmale
- **Spielweise = Evolution:** Evolution ist direkt an den Kampfstil gekoppelt.
- **Versteckte Fusionstabelle:** Erzeugt Community, Wikis, Clips – kostenloses Marketing.
- **"Lebt in deinem Handy":** Meta-Gags (Uhrzeit, Akku, Wochentag) geben Persönlichkeit.
- **Glitch-/Pixel-Ästhetik:** Klar abgegrenzt von Pokémon/Digimon, günstig in Produktion.

### Design-Grundsätze
- Jede Session endet mit einer offenen Schleife.
- Verlieren fühlt sich an wie "fast geschafft", nie wie verschwendete Zeit.
- Alles Spielrelevante ist kostenlos erspielbar. Geld kauft Stil & Komfort.
- Lieber wenige Grunddesigns mit vielen Formen als viele flache Monster.

---

## Welt & Lore

### Prämisse
Ein alter, vergessener Server namens **NEST** ist abgestürzt. Seine Bewohner, die **Glitchlings**, sind in die Geräte der Menschen geflohen. Eines Tages erscheint ein Ei auf deinem Homescreen.

Du wirst zum **Operator**: Du ziehst Glitchlings auf, trainierst sie und reparierst Stück für Stück den NEST, dessen Zonen von verwilderten, korrumpierten Glitchlings bevölkert sind.

### Zonen (Startumfang)
| Zone | Thema | Stimmung |
|---|---|---|
| Cache-Wiesen | Grüne Datenfelder, Startgebiet | freundlich |
| Firewall-Vulkan | Glühende Sicherheitsmauern | hitzig |
| Spam-Sümpfe | Pop-ups und Werbebanner als Pflanzen | schräg-komisch |
| Deep Web | Dunkle Tiefen, Endgame | geheimnisvoll |

### Tonalität
- Süß, verspielt, leicht nerdig. Humor über Technik-Anspielungen (Bugs, Updates, WLAN).
- Kein Grusel, keine Gewalt – Monster werden "defragmentiert", nicht getötet.
- Für Kinder verständlich, für Erwachsene voller Easter Eggs.

### "Lebt in deinem Handy" – Meta-Momente
- Nachts (0–5 Uhr): Monster gähnt, schlägt vor, schlafen zu gehen.
- Akku unter 15 %: Monster wirkt müde.
- Geburtstag des Spielers: Party-Animation.
- Lange nicht gespielt: Monster hat die Station "aufgeräumt" und freut sich.

> [!warning] Grundregel
> Nie Schuldgefühle erzeugen ("Dein Monster ist traurig, weil du weg warst"). Rückkehr wird **belohnt**, Abwesenheit nicht bestraft.

Siehe auch: Vision & Pitch

---

## Core Loop

Visuell: öffne `Core Loop.canvas` im selben Ordner.

### Drei verschachtelte Schleifen

#### 🔁 Mikro-Loop (Sekunden) – im Kampf
Ausweichen → Chip spielen → Treffer & Feedback → Chip lädt nach
→ Details: Kampfsystem

#### 🔁 Run-Loop (3–4 Minuten)
Monster wählen → 5 Räume → nach jedem Raum 1 aus 3 Chips → Boss → Beute
→ Beute: Daten-Fragmente, Chips, Prägung, gelegentlich Eier

#### 🔁 Meta-Loop (Tage/Wochen)
Beute → Evolution (Evolution & Prägung) → Fusion & Brüten (Station, Brüten & Fusion) → Monsterdex füllen → neue Zonen → stärkere Runs

### Was jede Schleife liefert
| Schleife | Gefühl | Psychologie |
|---|---|---|
| Mikro | Können, Reaktion | Flow, direktes Feedback |
| Run | Spannung, Entscheidung | variable Belohnung, Near Miss |
| Meta | Wachstum, Sammeln | Komplettierung, Neugier, offene Schleifen |

Siehe auch: Engagement-Hebel, Session Design

---

## Kampfsystem

### Grundprinzip
Echtzeit-Kampf auf zwei 3×3-Feldern (Megaman-Battle-Network-Stil), für Touch vereinfacht.

```
  SPIELER          GEGNER
 [ ][ ][ ]   |   [ ][ ][ ]
 [ ][X][ ]   |   [ ][O][ ]
 [ ][ ][ ]   |   [ ][ ][ ]
```

### Steuerung
- **Swipe** → Feld wechseln (ausweichen, positionieren)
- **Tap auf Chip** → Chip einsetzen
- Keine virtuellen Sticks, alles einhändig spielbar (Bahn-tauglich!)

### Chips
- Hand: **3 Chips** gleichzeitig sichtbar, benutzte Chips laden nach (2–4 Sek.).
- Deck startet mit 8 Chips, wächst im Run durch 1-aus-3-Auswahl.
- Kategorien:

| Kategorie | Beispiel | Funktion |
|---|---|---|
| Angriff | Pixelstrahl | Schaden in einer Reihe |
| Schild | Firewall | Blockt Treffer |
| Falle | Bug-Mine | Explodiert, wenn Gegner das Feld betritt |
| Buff | Übertakten | +50 % Tempo für 5 Sek. |
| Beschwörung | Mini-Bot | Kleiner Helfer für 10 Sek. |
| Feldeffekt | Datenflut | Verändert Felder (Eis, Lava, Gift) |

→ Alle Chips: Chip-Übersicht

### Elemente (Stein-Schere-Papier)
**Feuer > Code > Wasser > Feuer**, dazu **Licht ↔ Virus** (gegenseitig stark).
Einfach genug für Kinder, tief genug für Deckbau.

### Run-Struktur
1. Raum 1–4: normale Gegner, jeweils 20–40 Sek.
2. Raum 3 oder 4: Event-Raum (Shop, Heilquelle, Risiko-Truhe)
3. Raum 5: Elite oder Mini-Boss
4. Boss: 60–90 Sek., eigene Mechanik
5. Belohnungsbildschirm → Core Loop

### Verlieren
- Beute bis zum Tod wird zu 50 % behalten.
- Prägung wird voll behalten → Fortschritt bei Evolution & Prägung geht nie verloren.
- Near-Miss-Anzeige: "Boss hatte noch 6 % HP!"
- Optionaler Revive per Werbung (1× pro Run) → Monetarisierungsmodell

### Balancing-Leitplanken
- Ein Run darf **nie** über 5 Minuten dauern.
- Frühe Zonen: 80 % Siegquote. Späte Zonen: ~40–50 %.
- Kein Chip darf über Geld stärker werden als über Spielen.

---

## Evolution & Prägung

> Das Herzstück. Neugier ist der stärkste Motor des Spiels.

### Prinzip
Jedes gespielte Chip-Element gibt dem Monster **Prägungspunkte** dieses Typs.
Erreicht das Monster die Evolutionsschwelle, entscheidet die **stärkste Prägung** über die Form.

### Beispiel: Pixi
```
                ┌─ Feuer dominiert ──→ Blazebit
                ├─ Code dominiert ───→ Firewallo
Pixi (Stufe 1) ─┼─ Gift dominiert ───→ Virulina
                └─ alle ausgeglichen → Prisma-Pixi (geheim)
```

### Stufen
| Stufe | Name | Schwelle | Gefühl |
|---|---|---|---|
| 0 | Ei | – | Vorfreude |
| 1 | Baby | Schlupf | Bindung |
| 2 | Rookie | 100 (~3 Runs) | erstes Wow (im Onboarding!) |
| 3 | Champion | 600 (~15 Runs) | Identität, "mein Build" |
| 4 | Ultra | 2.000 (~50 Runs) + Ultra-Kern | Langzeitziel, Prestige |

### Regeln
- **Neutral-Chips zählen nicht für die Richtung**, nur für den Fortschritt.
- Bis kurz vor der Evolution kann der Spieler die Richtung noch umlenken.
- Der Monsterdex zeigt Silhouetten aller möglichen Formen, aber **nicht**, wie man sie erreicht.
- Geheime Formen: ausgeglichene Prägung, bestimmte Uhrzeit, Event-Bedingungen.
- Rück-Evolution über ein seltenes, **erspielbares** Item ("Rollback-Patch"), damit niemand Angst vor Fehlentscheidungen hat.

### Warum das funktioniert
- **Neugier & Informationslücke:** "Was wird aus ihm, wenn …?"
- **Eigenverantwortung:** Das Monster fühlt sich wie *meins* an.
- **Wiederspielwert:** Dasselbe Grundmonster mehrmals aufziehen.
- **Produktion:** 1 Grunddesign → 4–6 Formen. Spart Art-Budget, siehe Risiken.

Siehe auch: Station, Brüten & Fusion, Monster-Übersicht

Zahlen & Kurven: Progression & Wirtschaft

---

## Station, Brüten & Fusion

### Die Station
Deine kleine schwebende Insel im NEST. Heimatbasis zwischen den Runs.

**Gebäude (ausbaubar):**
| Gebäude | Funktion |
|---|---|
| Brutnest | Eier ausbrüten (Start: 2 Slots, ausbaubar auf 4) |
| Fusionslabor | Zwei Monster zu einer neuen Art verschmelzen |
| Chip-Werkstatt | Chips verbessern, Duplikate zerlegen |
| Monsterdex-Archiv | Sammlung, Belohnungen für Meilensteine |
| Deko-Fläche | Rein kosmetisch, frei gestaltbar |

### Brüten
| Ei-Seltenheit | Brutzeit |
|---|---|
| Gewöhnlich | 15 Min. |
| Selten | 1 Std. |
| Episch | 4 Std. |
| Legendär | 8 Std. |

- Timer erzeugen natürliche Wiederbesuche über den Tag verteilt.
- Beschleunigung: per Werbung (–50 %, 1× pro Ei) oder Premium-Währung.
- Push-Nachricht beim Schlupf (vom Spieler abschaltbar, maximal 2 pro Tag).

### Fusion (Yu-Gi-Oh-Polymerisation)
- Zwei Monster rein → eine neue Art raus, die Eigenschaften beider erbt.
- **Fusionstabelle ist teilweise versteckt.** Bekannte Rezepte werden im Labor gespeichert.
- Fehlgeschlagene Kombinationen geben einen Hinweis ("Es fehlt etwas Kaltes …").
- Monster gehen bei Fusion verloren → macht Entscheidungen bedeutsam und erzeugt Bedarf an neuen Eiern.

### Community-Effekt
Die versteckte Tabelle ist bewusst dafür gebaut, dass Spieler Rezepte teilen: Reddit, Discord, TikTok, Wikis. Ein Monster, das nur 1 % der Spieler entdeckt haben, ist ein Screenshot wert.

Siehe auch: Evolution & Prägung, Soziale Features

---

## Session Design

### Zielwerte
- **3–4 Sessions pro Tag**, je **5–8 Minuten**
- Eine vollständige Belohnungsrunde muss in unter 5 Minuten möglich sein

### Ablauf einer typischen Session
1. App öffnen → **sofortige Belohnung** (geschlüpftes Ei, Tagesbonus)
2. Tagesquests ansehen (3 Stück, je 1–2 Runs)
3. 1–2 Runs spielen
4. Neues Ei ins Brutnest legen
5. App schließen mit **offener Schleife**: "Evolution bei 87 %", "Ei schlüpft in 2 Std."

### Tagesrhythmus
| Tageszeit | Anlass |
|---|---|
| Morgens | Ei über Nacht geschlüpft, Tagesquests neu |
| Mittags | Kurzes Ei fertig |
| Abends | Gilden-Boss, längere Session |

### Streaks
- Login-Kalender mit 7-Tage-Zyklus.
- **1 Tag Schonfrist**: Streak bricht nicht sofort. Harte Resets erzeugen langfristig Frust und Abbruch statt Bindung.

Siehe auch: Engagement-Hebel, KPIs & Metriken

---

## Onboarding – Die ersten 10 Minuten

> Hier verlieren Mobile Games 40–60 % ihrer Spieler. Hier gehört die meiste Politur hin.

### Ablauf
| Minute | Ereignis | Ziel |
|---|---|---|
| 0–1 | Kein Menü, kein Login. Bildschirm glitcht, Ei erscheint, Tap → Schlupf | Emotionale Bindung vor jeder Erklärung |
| 1–4 | Erster Run, geführt, garantiert gewonnen, lustiger Boss | Kompetenzgefühl |
| 4–6 | Evolutionsbalken springt fast voll, Evolution im 2. Run | Das erste große "Wow" |
| 6–8 | Station wird freigeschaltet, zweites Ei, Timer startet | Erste offene Schleife |
| 8–10 | Monsterdex öffnet sich mit vielen Silhouetten | Langzeitziel sichtbar |

### Regeln
- Account-Erstellung erst später, optional (Gast-Login zuerst).
- Kein Shop, keine Angebote am ersten Tag. Das Starter-Paket erscheint ab Tag 2.
- Maximal 1 Satz Text pro Tutorial-Schritt. Zeigen statt erklären.
- Spieler benennt sein erstes Monster selbst (Bindung!), mit Namensfilter.

### Messen
Funnel-Tracking jedes Schritts → siehe KPIs & Metriken

---

## Soziale Features

> Live-Multiplayer ist für ein kleines Team zu teuer. Alles hier ist **asynchron**.

### Asynchrone Duelle (ab Global Launch)
- Dein Monster + Deck wird als KI-"Geist" gespeichert.
- Andere Spieler kämpfen gegen deinen Geist, du bekommst eine Benachrichtigung, wie er sich geschlagen hat.
- Wöchentliche Liga mit Rängen, Belohnungen rein kosmetisch oder Fragmente.
- **Kein Pay-to-Win**: Werte im Duell werden normalisiert.

### Freundes-Helfer
- Monster eines Freundes für einen Run ausleihen, beide erhalten einen Bonus.
- Starker Anreiz, Freunde einzuladen, ohne aggressive "Lade 5 Freunde ein"-Mechanik.

### Gilden (ab Version 1.2)
- Bis 30 Mitglieder.
- **Gilden-Boss**: riesiger Boss mit globaler HP, alle schlagen über die Woche darauf.
- Gilden-Chat mit Filter und vorgefertigten Nachrichten (Kinderschutz!).

### Teilen
- Screenshot- und Clip-Funktion für seltene Evolutionen und Fusionen.
- "Monster-Karte" als teilbares Bild mit Name, Form, Prägung.

Siehe auch: Ethik & Recht (Chat & Minderjährige)

---

## Progression & Wirtschaft

> Ziel: Fortschritt ist **jeden Tag spürbar**, nie zäh, und ein Spieler, der nie zahlt, erlebt trotzdem alles.

### Annahmen zum Spielverhalten
| Größe | Wert |
|---|---|
| Sessions pro Tag | 3–4 |
| Runs pro Tag (aktiver Spieler) | ca. 5 |
| Chip-Einsätze pro Run | ca. 40 (Sieg), ca. 25 (Niederlage) |

### Prägung & Evolution
Jeder Chip-Einsatz = 1 Prägungspunkt seines Elements → Evolution & Prägung

| Stufe | Schwelle (Prägung) | ≈ Runs | Zusatz | Erreicht (typisch) |
|---|---|---|---|---|
| Rookie | 100 | 3 | Tutorial: erste 2 Runs zählen doppelt | Tag 1, im 2. Run |
| Champion | 600 | 15 | – | Tag 5–7 |
| Ultra | 2.000 | 50 | + 1 Ultra-Kern | Tag 25–35 |

**Ultra-Kern:** aus dem wöchentlichen Gilden-Boss oder als Monsterdex-Meilenstein. Nie käuflich.

### Daten-Fragmente (weiche Währung)

#### Einnahmen
| Quelle | Menge |
|---|---|
| Run-Sieg Zone 1 / 2 / 3 / 4 | 60 / 90 / 130 / 180 |
| Niederlage | 50 % der bis dahin gesammelten Beute |
| Tagesquests (3 Stück) | je 40 |
| Duplikat-Chip zerlegen | 20 |

**Ein aktiver Spieler verdient in Woche 1 ca. 400–500 Fragmente pro Tag**, später 700–900.

#### Ausgaben
| Zweck | Kosten |
|---|---|
| Chip Level 2 / 3 / 4 / 5 | 80 / 200 / 500 / 1.200 |
| Fusion (Zone-1-Monster / später) | 300 / 800 |
| Brutnest Slot 3 | 1.500 |
| Brutnest Slot 4 | 5.000 |
| Chip-Werkstatt Ausbau | 1.000 → 3.000 → 8.000 |

Faustregel: **Nach jeder Session ist genau eine sinnvolle Sache kaufbar.** Nie so knapp, dass nichts geht, nie so reich, dass Entscheidungen egal werden.

### Eier
| Quelle | Chance |
|---|---|
| Run-Sieg | 15 % |
| Boss beim ersten Sieg pro Zone | 100 % (seltenes Ei) |
| Tagesquest-Bonus | 1 gewöhnliches Ei pro Tag |
| **Pech-Schutz** | nach 8 Runs ohne Ei garantiert eines |

Brutzeiten: 15 Min. / 1 Std. / 4 Std. / 8 Std. → Station, Brüten & Fusion

### Kristalle (Premium-Währung)

#### Kostenlose Quellen (pro 6-Wochen-Saison)
| Quelle | Menge |
|---|---|
| Tagesquests komplett (20/Tag) | ca. 840 |
| Wochenquests (100/Woche) | 600 |
| Kostenlose Pass-Spur | 300 |
| Monsterdex-Meilensteine (50 je 5 neue Monster) | ca. 200 |
| **Summe** | **ca. 1.900 pro Saison ≈ 45 pro Tag** |

#### Kaufpreise
| Paket | Preis | Kristalle pro € |
|---|---|---|
| 80 | 0,99 € | 81 |
| 500 | 4,99 € | 100 |
| 1.100 | 9,99 € | 110 |
| 2.400 | 19,99 € | 120 |
| 6.500 | 49,99 € | 130 |

Mengenrabatte bewusst **flach** halten. Stark steigende Boni erzeugen Druck zu Großkäufen – das wollen wir bei einer jungen Zielgruppe nicht.

### Eier-Ziehungen
| | |
|---|---|
| 1 Ziehung | 150 Kristalle (≈ 1,40 €, wird immer angezeigt) |
| 10 Ziehungen | 1.350 Kristalle (1 Ziehung gratis) |
| Gewöhnlich / Selten / Episch / Legendär | 58 % / 30 % / 10 % / 2 % |
| Pity | spätestens die 40. Ziehung ist legendär |

Ein Gratis-Spieler schafft ca. **12–13 Ziehungen pro Saison**. Legendäre Monster sind für ihn zusätzlich über Ultra-Evolution und geheime Fusionen erreichbar.

### Glitch-Pass
| | |
|---|---|
| Dauer | 6 Wochen |
| Stufen | 50 à 1.000 Pass-XP |
| XP-Quellen | Run-Sieg 100, Niederlage 50, Tagesquests zusammen 150 |
| Benötigt | 50.000 XP ≈ 1.200 XP pro Tag |

Ein regelmäßiger Spieler schließt den Pass um **Tag 36–38** ab. Die letzten Tage sind Puffer. Gelegenheitsspieler bekommen über Doppel-XP-Wochenenden eine faire Chance. Pass-Stufen sind **nicht** kaufbar.

### Spielerreise (aktiver Gratis-Spieler)
| Zeitpunkt | Meilenstein |
|---|---|
| Tag 1 | Erste Evolution, 2–3 Monster, Station freigeschaltet |
| Tag 2 | Starter-Paket erscheint, erster Bosssieg Zone 1 |
| Tag 3 | Erste Fusion, Zone 2 |
| Tag 7 | Erster Champion, 8–10 Monster im Dex |
| Tag 14 | Zone 3, Brutnest Slot 3, erste Gilde |
| Tag 30 | Erste Ultra-Form, 18–20 Monster |
| Tag 60 | Zone 4 (Deep Web), Jagd nach geheimen Formen |

### Schwierigkeitskurve
| Zone | Ziel-Siegquote |
|---|---|
| Cache-Wiesen | 80 % |
| Firewall-Vulkan | 65 % |
| Spam-Sümpfe | 55 % |
| Deep Web | 40–50 % |

### Schutzmechanismen
- Optionales **Ausgabenlimit** pro Monat in den Einstellungen
- Kristallpreis wird in jedem Kaufdialog auch in Euro angezeigt
- Pech-Schutz bei Eiern und Pity bei Ziehungen
- Alle Werte über Remote Config änderbar → Tech Stack

Siehe auch: Monetarisierungsmodell, KPIs & Metriken, Ethik & Recht

---

## Engagement-Hebel

Die Werkzeuge für "nur noch ein Run" – und wo sie im Spiel sitzen.

| Hebel | Prinzip | Umsetzung in Glitchlings |
|---|---|---|
| Variable Belohnung | Unvorhersehbare Belohnungen motivieren stärker als feste | Beute nach Runs, seltene "schillernde" Varianten (1–2 %) |
| Near Miss | "Fast geschafft" motiviert mehr als ein Sieg | HP-Anzeige des Bosses nach Niederlage |
| Zeigarnik-Effekt | Unerledigtes bleibt im Kopf | Brut-Timer, Evolution bei 90 %, Quest 2/3 |
| Komplettierung | Lücken wollen gefüllt werden | Monsterdex mit Silhouetten |
| Neugier / Informationslücke | Unbekanntes zieht an | Versteckte Evolutionen & Fusionsrezepte |
| Kompetenz & Flow | Können fühlt sich gut an | Skill-basierter Kampf, faire Schwierigkeit |
| Eigentum (Endowment) | Selbst Geformtes wird wertvoller | Monster benennen, Prägung selbst steuern |
| Soziale Bindung | Freunde halten im Spiel | Helfer, Gilden, Gilden-Boss |
| Fortschrittsbalken | Sichtbarer Fortschritt motiviert | Überall: Evolution, Pass, Dex, Station |
| Cliffhanger | Session-Ende mit Ausblick | "Nächster Run schaltet frei: …" |

### Feedback & Juice
- Treffer: Screenshake, Pixel-Splitter, kurzer Freeze-Frame.
- Seltene Beute: eigener Sound, Leuchten, Zeitlupe.
- Evolution: 3–5 Sekunden Inszenierung, **überspringbar** ab dem 2. Mal.

### Rote Linien
> [!danger] Das machen wir nicht
> - Schuldgefühle erzeugen (trauriges Monster bei Abwesenheit)
> - Angebote direkt nach Niederlagen
> - Künstliche Countdown-Druckangebote
> - Near-Miss-Effekte beim Gacha (gefälschtes "fast legendär")
> - Push-Spam (max. 2 pro Tag, abschaltbar)

Begründung: Ethik & Recht

Siehe auch: Session Design, Core Loop

---

## Monetarisierungsmodell

### Grundsatz
**Geld kauft Stil, Komfort und Tempo – nie Stärke im Wettbewerb.**
Alles Spielrelevante ist kostenlos erspielbar.

### Übersicht
| Produkt | Preis | Inhalt | Rolle |
|---|---|---|---|
| Glitch-Pass (Saison) | 4,99 € / 6 Wochen | Premium-Spur: Skins, saisonale Monsterform, Chip-Effekte | Umsatzträger Nr. 1 |
| Starter-Paket | 1,99 € einmalig | Seltenes Ei, Extra-Brutslot, Skin | Erste Conversion |
| Cosmetics | 0,99–9,99 € | Monster-Skins, Chip-Animationen, Stations-Deko | Sammler, Erwachsene |
| Komfort-Abo | 3,99 € / Monat | +1 Brutslot, tägliche Premium-Währung, kürzere Brutzeiten | Planbarer Umsatz |
| Belohnte Werbung | kostenlos | Revive, Brutzeit –50 %, doppelte Fragmente (max. 5/Tag) | Monetarisiert Nicht-Zahler |
| Eier-Ziehungen | Premium-Währung | Zufällige Eier mit Pity | Sammelreiz |

### Starter-Paket
- Erscheint ab Tag 2, verfügbar bis Tag 7.
- Deutlich bessere Preis-Leistung als reguläre Angebote.
- Wichtigster Hebel: Wer einmal zahlt, zahlt mit viel höherer Wahrscheinlichkeit wieder.

### Eier-Ziehungen – Regeln
- Wahrscheinlichkeiten **sichtbar** vor jedem Kauf.
- **Pity-Garantie**: spätestens nach 40 Zügen ein legendäres Ei.
- Jedes Monster ist auch ohne Ziehung erspielbar.
- Premium-Währung wird **immer zusätzlich in Euro** angezeigt.

### Währungen
| Währung | Quelle | Verwendung |
|---|---|---|
| Daten-Fragmente | Runs | Chips verbessern, Station ausbauen |
| Kristalle (Premium) | Kauf, Pass, Dex-Meilensteine | Ziehungen, Beschleunigen, Cosmetics |

Nur **zwei** Währungen. Mehr verwirrt – und Verwirrung wird zurecht als unfair wahrgenommen.

### Erwartungswerte
- Zahlende Spieler: realistisch **2–4 %**
- Umsatz hängt vor allem an Retention → KPIs & Metriken

Siehe auch: Ethik & Recht, Engagement-Hebel

---

## Ethik & Recht

> [!note] Hinweis
> Keine Rechtsberatung. Vor Launch mit einer auf Games spezialisierten Kanzlei prüfen.

### Warum das für uns zählt
Süße Monster ziehen Kinder und Teenager an. Die Zielgruppe "möglichst breit" schließt Minderjährige ein. Ausbeuterische Monetarisierung ist hier nicht nur moralisch fragwürdig, sondern ein Geschäftsrisiko.

### Rechtlicher Rahmen (Stand der Recherche prüfen!)
- **Deutschland / USK:** Seit der Jugendschutzgesetz-Reform können In-Game-Käufe und Lootboxen die Alterseinstufung beeinflussen.
- **Belgien / Niederlande:** Deutlich strengere Haltung zu bezahlten Lootboxen.
- **EU:** Verbraucherschutz-Initiativen gegen manipulative Designs ("Dark Patterns") und intransparente Währungen.
- **App Store & Google Play:** Pflicht zur Offenlegung von Wahrscheinlichkeiten bei zufälligen Käufen.
- **DSGVO / Kinderdaten:** Einwilligung, Datenminimierung, besondere Regeln für Minderjährige.

### Unsere Regeln
- Wahrscheinlichkeiten sichtbar, Pity-System, Euro-Preise sichtbar
- Kein Pay-to-Win im Wettbewerb
- Keine Druck-Countdowns, keine Angebote nach Niederlagen
- Ausgabenlimit-Hinweise und Unterstützung der Store-Jugendschutzfunktionen
- Chat mit Filter oder vorgefertigten Nachrichten
- Push-Nachrichten sparsam und abschaltbar

### Das Geschäftsargument
- Weniger Rückbuchungen durch Eltern
- Bessere Reviews und Store-Featuring
- Längere Retention, höherer Lifetime Value
- Kein Risiko, aus Stores oder Märkten zu fliegen

Siehe auch: Monetarisierungsmodell, Risiken

---

## Prototyp-Spezifikation (Phase 1)

> **Die einzige Frage dieser Phase:** Macht ein einzelner Run Spaß – auch ohne Meta-Systeme, ohne Grafikpolitur, ohne Belohnungen?

Ein spielbarer Browser-Prototyp dieser Spezifikation liegt als Artifact vor (Link siehe 🏠 Start hier). Er dient als Referenz für das Spielgefühl, nicht als Code-Basis.

### Umfang
| Inhalt | Menge |
|---|---|
| Spielbare Monster | 3: Pixi, Funkling, Tröpfel |
| Chips | 15 → Chip-Übersicht |
| Gegner | 3 → Bugsy, Glitchmotte, Spamlet (wild) |
| Boss | 1 → Pop-Up-Tyrann |
| Run | 3 Kämpfe + Boss, nach jedem Kampf 1 aus 3 Chips |

### Bewusst NICHT im Prototyp
Station, Brüten, Fusion, Shop, Accounts, Speichern, Story, finale Grafik. Die Prägung wird am Ende des Runs nur **angezeigt**, damit wir testen können, ob die Evolutionsvorschau neugierig macht.

### Spielfeld
- Zwei 3×3-Felder nebeneinander, links Spieler, rechts Gegner.
- Jede Figur belegt genau ein Feld.
- Spieler bewegt sich nur im eigenen Feld, Gegner nur in seinem.

### Steuerung
| Aktion | Touch | Tastatur (Test) |
|---|---|---|
| Bewegen | Swipe in Richtung | Pfeiltasten / WASD |
| Chip einsetzen | Chip antippen | 1, 2, 3 |
| Pop-up schließen | Pop-up antippen | Klick |

Bewegungs-Cooldown: 0,12 s (Tröpfel: 0,18 s).

### Chip-Hand
- 3 Slots. Ein benutzter Slot zieht sofort den nächsten Chip aus dem gemischten Deck, ist aber für die **Ladezeit dieses neuen Chips** gesperrt.
- Ist das Deck leer, wird der Ablagestapel neu gemischt.
- Pro Kampf wird das Deck neu gemischt.

### Spielbare Monster
| Monster | HP | Besonderheit | Startdeck (8 Chips) |
|---|---|---|---|
| Pixi | 100 | Allrounder | 3× Pixelstrahl, 2× Byteschlag, Firewall, Heilpatch, Blitzcursor |
| Funkling | 80 | Chips laden 10 % schneller | 2× Pixelstrahl, 2× Glutball, Flammenwelle, Übertakten, Firewall, Byteschlag |
| Tröpfel | 120 | Bewegt sich langsamer | 3× Wasserstrahl, 2× Blubberschild, Eisfeld, Pixelstrahl, Heilpatch |

### Gegner-Verhalten
- Gegner bewegen sich im festen Takt auf ein zufälliges freies Nachbarfeld.
- **Jeder Angriff wird 0,7 s vorher angezeigt** (rot blinkende Felder). Kein Treffer ohne Vorwarnung – Fairness ist Pflicht.
- Details je Gegner in den Notizen unter `06 Datenbank/Gegner`.

### Run-Ablauf
1. Monster wählen
2. Kampf 1: Bugsy → Chipwahl (1 aus 3) → +15 HP
3. Kampf 2: Glitchmotte → Chipwahl → +15 HP
4. Kampf 3: Spamlet → Chipwahl → +15 HP
5. Boss: Pop-Up-Tyrann
6. Ergebnis: Fragmente, Prägung nach Element, Evolutionsvorschau

Bei Niederlage: **Near-Miss-Anzeige** ("Der Tyrann hatte nur noch 8 % HP") und 50 % der Fragmente bleiben.

### Juice-Minimum (auch im Prototyp!)
- Trefferblitz + kleiner Screenshake beim Treffen und Getroffenwerden
- Schadenszahlen, die aufsteigen und verblassen
- Kurzer Freeze-Frame (60 ms) bei starken Treffern
- Chip-Slot pulsiert kurz, wenn er wieder bereit ist

### Erfolgskriterien für den Playtest
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

### Beobachten statt fragen
Tester sagen oft "macht Spaß" aus Höflichkeit. Stärker ist: Greift er ohne Aufforderung wieder zum Handy? Flucht er beim Verlieren (gut: emotional investiert) oder legt er es weg (schlecht)?

### Entscheidung nach Phase 1
- **Kriterien erfüllt:** weiter zu Phase 2 → Roadmap
- **Knapp verfehlt:** 2–4 Wochen iterieren (Tempo, Chip-Werte, Gegner-Telegraphing)
- **Klar verfehlt:** Kampfsystem grundlegend überdenken, bevor Geld in Meta-Systeme fließt

---

## Roadmap

### Phase 1 – Prototyp (Monat 1–3)
Spezifikation: Prototyp-Spezifikation
**Kernfrage: Macht ein einzelner Run Spaß?**
- [ ] 3×3-Kampfsystem mit Swipe & Tap
- [ ] 3 Monster, 15 Chips, 1 Boss
- [ ] Graybox-Grafik, Fokus auf Spielgefühl
- [ ] Playtests mit 10–20 Personen
> Wenn der Run nicht trägt, hilft kein Meta-System. Erst weiter, wenn die Antwort "Ja" ist.

### Phase 2 – Vertical Slice (Monat 4–8)
- [ ] Evolution & Prägung implementiert
- [ ] Station, Brüten & Fusion (Basis)
- [ ] 25 Monster, 60 Chips
- [ ] Zone 1 (Cache-Wiesen) komplett
- [ ] Finaler Artstyle
- [ ] Onboarding – Die ersten 10 Minuten
- [ ] Test mit 50–100 externen Spielern

### Phase 3 – Soft Launch (Monat 9–12)
- [ ] Shop, Glitch-Pass, belohnte Werbung
- [ ] Analytics & Funnel-Tracking
- [ ] Launch in 1–2 kleinen Märkten (z. B. Kanada, Skandinavien, Philippinen)
- [ ] KPIs & Metriken erreichen, iterieren

### Phase 4 – Global Launch (Monat 13–15)
- [ ] 40–50 Monster, 3 Zonen
- [ ] Asynchrone Duelle (Soziale Features)
- [ ] Marketing-Push, Creator-Kooperationen

### Phase 5 – Live-Ops (ab Launch)
- Alle 6 Wochen eine Saison: 5–8 neue Monster, neue Zone oder Event
- Gilden & Gilden-Boss ab Version 1.2
- Community-Events rund um geheime Fusionen

---

## Tech Stack

### Engine
| Option | Pro | Contra |
|---|---|---|
| **Unity** | Riesiges Ökosystem, Werbe- & Analytics-SDKs, viel Mobile-Erfahrung am Markt | Lizenzmodell beobachten |
| **Godot** | Kostenlos, Open Source, leichtgewichtig, stark in 2D | Weniger fertige Mobile-Monetarisierungs-Plugins |

Empfehlung: **Unity**, wenn Monetarisierung & Ads schnell stehen sollen; **Godot**, wenn das Team es bereits kennt.

### Backend (kein eigener Server!)
- Fertige Dienste wie Firebase, PlayFab oder Nakama
- Benötigt: Accounts/Gast-Login, Cloud-Save, Remote Config, Leaderboards, Geister-Daten für Duelle

### Weitere Bausteine
- Analytics (Funnels, Retention, Monetarisierung)
- Werbe-Mediation für belohnte Werbung
- In-App-Purchase-Abwicklung über Store-APIs
- Remote Config für Balancing ohne App-Update
- Crash-Reporting

### Art
- 2D: Pixel-Art oder weiche Vektor-Illustrationen
- Skelett-Animation (z. B. Spine) spart Frames bei vielen Monsterformen

---

## KPIs & Metriken

### Zielwerte Soft Launch
| Metrik | Ziel | Wenn verfehlt … |
|---|---|---|
| Tag-1-Retention | > 40 % | Onboarding überarbeiten → Onboarding – Die ersten 10 Minuten |
| Tag-7-Retention | > 15 % | Mid-Game-Tiefe fehlt → Evolution & Prägung |
| Tag-30-Retention | > 6 % | Langzeitziele, Live-Ops, Soziales |
| Sessions/Tag | 3–4 | Session Design |
| Sessionlänge | 5–8 Min. | Run-Länge prüfen |
| Zahlende Spieler | 2–4 % | Monetarisierungsmodell |

### Wichtige Funnels
- Tutorial-Schritte (Abbruch pro Schritt)
- Erster Run → erste Evolution → erste Fusion
- Shop-Besuch → Kauf

### Faustregel
Erst Geld in Nutzerakquise stecken, wenn die Retention steht.

---

## Risiken

| Risiko | Wahrscheinlichkeit | Gegenmaßnahme |
|---|---|---|
| Content-Hunger (Spieler sind schneller als das Team) | hoch | Evolutionsformen & Fusionen vervielfachen Arten, Farbvarianten, prozedurale Räume |
| Zu nah an Pokémon/Digimon | mittel | Eigene Glitch-Ästhetik, rechtliche Prüfung von Namen & Designs |
| Sichtbarkeit im Store | hoch | Teilbare Momente (Fusion, schillernde Monster), Creator, Community |
| Balancing-Probleme | mittel | Remote Config, Soft Launch |
| Kampf macht keinen Spaß | mittel | Prototyp-Phase mit klarer Abbruchentscheidung |
| Regulierung (Lootboxen, Jugendschutz) | mittel | Ethik & Recht |
| Burnout im kleinen Team | mittel | Realistischer Umfang, Live-Ops-Rhythmus nicht zu eng |

---

## Anhang A: Monster
#### 404-Geist

**Element:** Virus | **Stufe:** 3 (Champion) | **Seltenheit:** Episch
**Herkunft:** Fusion: Spamlet-Linie + Pixi-Linie

### Beschreibung
Ein Geist, der manchmal einfach nicht gefunden werden kann – er verschwindet mitten im Kampf.

### Persönlichkeit
schüchtern, schelmisch

### Bedingung
Fusion aus Spamlet-Linie und Pixi-Linie. Nur zwischen 0 und 4 Uhr möglich.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Virusspritzer

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Blazebit

**Element:** Feuer | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Pixi

### Beschreibung
Pixis Körper glüht wie ein überhitzter Prozessor, aus dem Rücken steigen Pixel-Funken.

### Persönlichkeit
hitzköpfig, mutig, loyal

### Bedingung
Feuer-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Glutball

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Blinki

**Element:** Licht | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Lumi

### Beschreibung
Ein blinkender Cursor mit Blitzflügeln, zu schnell für jedes Foto.

### Persönlichkeit
flink, frech, ungeduldig

### Bedingung
Licht-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Blitzcursor

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Cachy

**Element:** Licht | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Kekso

### Beschreibung
Ein warm leuchtender Keks, der Verbündete mit gespeicherten Erinnerungen heilt.

### Persönlichkeit
fürsorglich, gastfreundlich

### Bedingung
Licht-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Heilpatch

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Dampfbyte

**Element:** Feuer | **Stufe:** 3 (Champion) | **Seltenheit:** Selten
**Herkunft:** Fusion: Funkling-Linie + Tröpfel-Linie

### Beschreibung
Eine kleine Dampflok aus Kühlwasser und Glut, die pfeift, wenn sie sich freut.

### Persönlichkeit
fleißig, pünktlich, laut

### Bedingung
Fusion aus einem Feuer-Monster der Funkling-Linie und einem Monster der Tröpfel-Linie.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Glutball

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Firewallo

**Element:** Code | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Pixi

### Beschreibung
Trägt einen Panzer aus leuchtenden Code-Backsteinen und hält sich für einen Türsteher.

### Persönlichkeit
ruhig, beschützend, etwas stur

### Bedingung
Code-Prägung dominiert (z. B. Firewall, Mini-Bot).

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Firewall

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Frostbyte

**Element:** Wasser | **Stufe:** 2 (Rookie) | **Seltenheit:** Selten
**Herkunft:** Tröpfel

### Beschreibung
Ein Eiskristall-Tröpfel mit Schneeflocken-Pixeln als Krone.

### Persönlichkeit
kühl, elegant, heimlich kuschelig

### Bedingung
Sonderbedingung: mindestens 8 Eisfeld-Chips gespielt, bevor die Evolution erreicht ist.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Eisfeld

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Funkling

**Element:** Feuer | **Stufe:** 1 (Baby) | **Seltenheit:** Gewöhnlich
**Herkunft:** Ei (Cache-Wiesen)

### Beschreibung
Ein winziger Kurzschluss-Funke mit Knopfaugen, der ständig hin und her flackert.

### Persönlichkeit
hibbelig, übermütig, lacht knisternd

### Bedingung
Schlüpft aus Feuer-Eiern.

### Entwickelt sich zu
- Glutbyte
- Overclocko

### Signatur-Chip
Glutball

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Glutbyte

**Element:** Feuer | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Funkling

### Beschreibung
Ein glühender Klumpen aus geschmolzenem Silizium mit kleinen Lava-Ärmchen.

### Persönlichkeit
impulsiv, großherzig

### Bedingung
Feuer-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Flammenwelle

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Kaskadi

**Element:** Wasser | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Tröpfel

### Beschreibung
Ein kleiner Wasserfall-Drache, dessen Körper aus fließenden Datenströmen besteht.

### Persönlichkeit
verspielt, stolz

### Bedingung
Wasser-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Wasserstrahl

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Kekso

**Element:** Code | **Stufe:** 1 (Baby) | **Seltenheit:** Gewöhnlich
**Herkunft:** Ei (Cache-Wiesen)

### Beschreibung
Ein Browser-Cookie mit Schokostückchen aus Bits, das sich an alles erinnert.

### Persönlichkeit
gesellig, verfressen, neugierig

### Bedingung
Schlüpft aus Code-Eiern.

### Entwickelt sich zu
- Tracko
- Cachy

### Signatur-Chip
Mini-Bot

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Lumi

**Element:** Licht | **Stufe:** 1 (Baby) | **Seltenheit:** Gewöhnlich
**Herkunft:** Ei (Firewall-Vulkan)

### Beschreibung
Ein kleiner Mauszeiger mit Glühwürmchen-Schwanz, der immer auf Dinge zeigt.

### Persönlichkeit
hilfsbereit, aufgedreht

### Bedingung
Schlüpft aus Licht-Eiern.

### Entwickelt sich zu
- Blinki
- Screenshina

### Signatur-Chip
Blitzcursor

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Overclocko

**Element:** Code | **Stufe:** 2 (Rookie) | **Seltenheit:** Selten
**Herkunft:** Funkling

### Beschreibung
Ein Funke im Kühlerventilator-Anzug, der sich immer schneller dreht, je spannender der Kampf wird.

### Persönlichkeit
ehrgeizig, ungeduldig, Rekordjäger

### Bedingung
Code-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Übertakten

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Pixi

**Element:** Neutral | **Stufe:** 1 (Baby) | **Seltenheit:** Gewöhnlich
**Herkunft:** Start-Ei

### Beschreibung
Ein kleiner Pixelwurm, der beim Freuen in bunte Quadrate zerfällt und sich wieder zusammensetzt.

### Persönlichkeit
neugierig, verspielt, anhänglich

### Bedingung
Schlüpft aus dem Start-Ei.

### Entwickelt sich zu
- Blazebit
- Firewallo
- Virulina
- Prisma-Pixi

### Signatur-Chip
Pixelstrahl

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Pop-Upsi

**Element:** Virus | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Spamlet

### Beschreibung
Ein Stapel aus Pop-ups, die sich wie ein Akkordeon auf- und zuklappen.

### Persönlichkeit
überschwänglich, chaotisch

### Bedingung
Virus-Prägung dominiert. Korrumpierte Ultra-Form: der Boss Pop-Up-Tyrann.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Bug-Mine

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Prisma-Pixi

**Element:** Licht | **Stufe:** 2 (Rookie) | **Seltenheit:** Episch (geheim)
**Herkunft:** Pixi

### Beschreibung
Schillert in allen Farben und hinterlässt einen Regenbogen-Glitch, wenn es sich bewegt.

### Persönlichkeit
gelassen, weise, geheimnisvoll

### Bedingung
Alle Prägungen fast gleich stark (kein Element über 30 %). Im Dex nur als Silhouette mit ???.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Defrag

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Pufferling

**Element:** Code | **Stufe:** 2 (Rookie) | **Seltenheit:** Gewöhnlich
**Herkunft:** Tröpfel

### Beschreibung
Ein runder Speicherpuffer, der sich bei Gefahr aufbläht wie ein Kugelfisch.

### Persönlichkeit
vorsichtig, gemütlich, beschützend

### Bedingung
Code-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Blubberschild

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Quellcoda

**Element:** Licht | **Stufe:** 3 (Champion) | **Seltenheit:** Episch
**Herkunft:** Fusion: Lumi-Linie + Kekso-Linie

### Beschreibung
Eine leuchtende Schlange aus Quellcode-Zeilen, die alte Geheimnisse des NEST kennt.

### Persönlichkeit
weise, rätselhaft

### Bedingung
Fusion aus Lumi-Linie und Kekso-Linie. Rezept im Spiel versteckt.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Defrag

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Screenshina

**Element:** Code | **Stufe:** 2 (Rookie) | **Seltenheit:** Selten
**Herkunft:** Lumi

### Beschreibung
Ein schwebender Bilderrahmen, der Momente einfriert und Kopien von Verbündeten erschafft.

### Persönlichkeit
künstlerisch, eitel, liebevoll

### Bedingung
Code-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Mini-Bot

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Spamlet

**Element:** Virus | **Stufe:** 1 (Baby) | **Seltenheit:** Gewöhnlich
**Herkunft:** Ei (Spam-Sümpfe)

### Beschreibung
Ein kleines Pop-up-Fenster mit Augen, das immer wieder unaufgefordert auftaucht.

### Persönlichkeit
aufdringlich, gutmütig, laut

### Bedingung
Schlüpft aus Virus-Eiern. Wilde Spamlets sind im Prototyp Gegner.

### Entwickelt sich zu
- Pop-Upsi
- Trojo

### Signatur-Chip
Virusspritzer

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Tracko

**Element:** Virus | **Stufe:** 2 (Rookie) | **Seltenheit:** Selten
**Herkunft:** Kekso

### Beschreibung
Ein Tracking-Cookie mit Detektivhut, der Gegnern heimlich folgt.

### Persönlichkeit
listig, aufdringlich, aber harmlos

### Bedingung
Virus-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Bug-Mine

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Trojo

**Element:** Code | **Stufe:** 2 (Rookie) | **Seltenheit:** Selten
**Herkunft:** Spamlet

### Beschreibung
Ein Holzpferdchen aus Pixeln, in dem sich kleine Helfer verstecken.

### Persönlichkeit
verschmitzt, überraschend treu

### Bedingung
Code-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Mini-Bot

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Tröpfel

**Element:** Wasser | **Stufe:** 1 (Baby) | **Seltenheit:** Gewöhnlich
**Herkunft:** Ei (Cache-Wiesen)

### Beschreibung
Ein Wassertropfen in Form eines Ladekreises, der sich dreht, wenn er nachdenkt.

### Persönlichkeit
verträumt, sanft, etwas langsam

### Bedingung
Schlüpft aus Wasser-Eiern.

### Entwickelt sich zu
- Kaskadi
- Pufferling
- Frostbyte

### Signatur-Chip
Wasserstrahl

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Virulina

**Element:** Virus | **Stufe:** 2 (Rookie) | **Seltenheit:** Selten
**Herkunft:** Pixi

### Beschreibung
Frech grinsend, mit violetten Pixelflecken, die über den Körper wandern.

### Persönlichkeit
chaotisch, frech, nie böse gemeint

### Bedingung
Virus-Prägung dominiert.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Virusspritzer

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

#### Wolkerich

**Element:** Wasser | **Stufe:** 3 (Champion) | **Seltenheit:** Selten
**Herkunft:** Fusion: Tröpfel-Linie + Kekso-Linie

### Beschreibung
Eine flauschige Cloud-Speicher-Wolke, die Dinge für später aufhebt.

### Persönlichkeit
hilfsbereit, vergesslich, verträumt

### Bedingung
Fusion aus Tröpfel-Linie und Kekso-Linie.

### Entwickelt sich zu
- _Weitere Stufe (Champion/Ultra) folgt in späteren Saisons_

### Signatur-Chip
Blubberschild

### Design-Notizen
- Silhouette muss auch als 16×16-Pixel-Icon erkennbar sein
- 

## Anhang B: Chips
#### Blitzcursor

**Kategorie:** Angriff | **Element:** Licht | **Schaden:** 20 | **Ladezeit:** 3,0 s

### Effekt
Markiert den Gegner und schlägt nach 0,5 s garantiert ein.

### Prägung
Jeder Einsatz gibt **1 Licht-Prägung** → siehe Evolution & Prägung.

#### Blubberschild

**Kategorie:** Schild | **Element:** Wasser | **Schaden:** 0 | **Ladezeit:** 4,0 s

### Effekt
Blase absorbiert bis zu 30 Schaden (hält 5 s).

### Prägung
Jeder Einsatz gibt **1 Wasser-Prägung** → siehe Evolution & Prägung.

#### Bug-Mine

**Kategorie:** Falle | **Element:** Virus | **Schaden:** 35 | **Ladezeit:** 3,0 s

### Effekt
Legt eine Mine auf das Feld, auf dem der Gegner gerade steht. Nach 0,8 s scharf, explodiert beim Betreten (hält 6 s).

### Prägung
Jeder Einsatz gibt **1 Virus-Prägung** → siehe Evolution & Prägung.

#### Byteschlag

**Kategorie:** Angriff | **Element:** Neutral | **Schaden:** 30 | **Ladezeit:** 1,5 s

### Effekt
Nahkampf: trifft die vorderen zwei Gegnerfelder der eigenen Reihe.

### Prägung
Jeder Einsatz gibt **1 Neutral-Prägung** → siehe Evolution & Prägung.

#### Defrag

**Kategorie:** Buff | **Element:** Neutral | **Schaden:** 0 | **Ladezeit:** 8,0 s

### Effekt
Lädt alle anderen Chips in der Hand sofort nach.

### Prägung
Jeder Einsatz gibt **1 Neutral-Prägung** → siehe Evolution & Prägung.

#### Eisfeld

**Kategorie:** Feldeffekt | **Element:** Wasser | **Schaden:** 0 | **Ladezeit:** 4,0 s

### Effekt
Friert den Gegner 2 s ein: keine Bewegung, keine Angriffe.

### Prägung
Jeder Einsatz gibt **1 Wasser-Prägung** → siehe Evolution & Prägung.

#### Firewall

**Kategorie:** Schild | **Element:** Code | **Schaden:** 0 | **Ladezeit:** 4,0 s

### Effekt
Blockt den nächsten Treffer vollständig (hält 4 s).

### Prägung
Jeder Einsatz gibt **1 Code-Prägung** → siehe Evolution & Prägung.

#### Flammenwelle

**Kategorie:** Angriff | **Element:** Feuer | **Schaden:** 25 | **Ladezeit:** 3,5 s

### Effekt
Trifft nach kurzem Aufladen die gesamte Spalte, in der der Gegner steht.

### Prägung
Jeder Einsatz gibt **1 Feuer-Prägung** → siehe Evolution & Prägung.

#### Glutball

**Kategorie:** Angriff | **Element:** Feuer | **Schaden:** 40 | **Ladezeit:** 3,0 s

### Effekt
Fliegt genau 3 Felder weit und schlägt dort ein. Setzt 3 s Brand (5/s).

### Prägung
Jeder Einsatz gibt **1 Feuer-Prägung** → siehe Evolution & Prägung.

#### Heilpatch

**Kategorie:** Buff | **Element:** Licht | **Schaden:** 0 | **Ladezeit:** 5,0 s

### Effekt
Stellt sofort 25 HP wieder her.

### Prägung
Jeder Einsatz gibt **1 Licht-Prägung** → siehe Evolution & Prägung.

#### Mini-Bot

**Kategorie:** Beschwörung | **Element:** Code | **Schaden:** 0 | **Ladezeit:** 6,0 s

### Effekt
Kleiner Helfer, der 6 s lang 5 Schaden pro Sekunde verursacht.

### Prägung
Jeder Einsatz gibt **1 Code-Prägung** → siehe Evolution & Prägung.

#### Pixelstrahl

**Kategorie:** Angriff | **Element:** Neutral | **Schaden:** 20 | **Ladezeit:** 2,0 s

### Effekt
Schnelles Projektil über die eigene Reihe. Trifft, wenn der Gegner in derselben Reihe steht.

### Prägung
Jeder Einsatz gibt **1 Neutral-Prägung** → siehe Evolution & Prägung.

#### Virusspritzer

**Kategorie:** Angriff | **Element:** Virus | **Schaden:** 10 | **Ladezeit:** 2,5 s

### Effekt
Reihen-Projektil. Vergiftet 4 s lang (4/s).

### Prägung
Jeder Einsatz gibt **1 Virus-Prägung** → siehe Evolution & Prägung.

#### Wasserstrahl

**Kategorie:** Angriff | **Element:** Wasser | **Schaden:** 15 | **Ladezeit:** 2,0 s

### Effekt
Reihen-Projektil. Stößt den Gegner ein Feld zurück.

### Prägung
Jeder Einsatz gibt **1 Wasser-Prägung** → siehe Evolution & Prägung.

#### Übertakten

**Kategorie:** Buff | **Element:** Feuer | **Schaden:** 0 | **Ladezeit:** 6,0 s

### Effekt
Alle Chips laden 5 s lang doppelt so schnell.

### Prägung
Jeder Einsatz gibt **1 Feuer-Prägung** → siehe Evolution & Prägung.

## Anhang C: Gegner
#### Bugsy

| Wert | |
|---|---|
| Element | Virus |
| HP | 70 |
| Bewegung | alle 1,4 s |
| Angriff | alle 2,4 s |

### Angriffsmuster
Reihe: warnt die aktuelle Spielerreihe 0,7 s lang, dann 10 Schaden.

### Rolle im Run
Raum 1 – Lerngegner. Bringt dem Spieler das Ausweichen bei.

#### Glitchmotte

| Wert | |
|---|---|
| Element | Licht |
| HP | 60 |
| Bewegung | alle 1,0 s (teleportiert) |
| Angriff | alle 2,0 s |

### Angriffsmuster
Feld: markiert das Feld des Spielers, 14 Schaden.

### Rolle im Run
Raum 2 – Prüft Reaktion: das markierte Feld muss verlassen werden.

#### Pop-Up-Tyrann (Boss)

Die korrumpierte Ultra-Form von Pop-Upsi. Ein riesiger Turm aus Werbefenstern mit einer Krone aus Schließen-Buttons, die alle nicht funktionieren.

| Phase | HP | Verhalten |
|---|---|---|
| 1 | 100–50 % | Bewegung alle 1,8 s. Werbebanner-Laser: warnt die Spielerreihe, 16 Schaden, alle 2,2 s |
| 2 | 50–20 % | Zusätzlich: alle 4 s erscheint ein **Pop-up** auf einem Spielerfeld. Antippen schließt es. Nach 3 s explodiert es (15 Schaden). |
| 3 | unter 20 % | Wut: Angriffe alle 1,5 s |

### Designziel
- Phase 2 bricht die Routine: Der Spieler muss kurz den Blick vom Gegner nehmen. Das ist die Stelle, an der knappe Niederlagen entstehen (Near Miss!).
- Die Pop-ups sind ein Gag über nervige Werbung – passend zur Welt und selbstironisch für ein F2P-Spiel.

#### Spamlet (wild)

| Wert | |
|---|---|
| Element | Virus |
| HP | 90 |
| Bewegung | alle 1,6 s |
| Angriff | alle 2,6 s |

### Angriffsmuster
Abwechselnd Reihe und Spalte, 12 Schaden.

### Rolle im Run
Raum 3 – Mischt Muster, der Spieler muss lesen statt reagieren.

