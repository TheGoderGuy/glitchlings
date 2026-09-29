---
tags: [gameplay, wirtschaft, progression, balancing]
status: erster Entwurf – im Soft Launch per Remote Config justieren
---
# Progression & Wirtschaft

> Ziel: Fortschritt ist **jeden Tag spürbar**, nie zäh, und ein Spieler, der nie zahlt, erlebt trotzdem alles.

## Annahmen zum Spielverhalten
| Größe | Wert |
|---|---|
| Sessions pro Tag | 3–4 |
| Runs pro Tag (aktiver Spieler) | ca. 5 |
| Chip-Einsätze pro Run | ca. 40 (Sieg), ca. 25 (Niederlage) |

## Prägung & Evolution
Jeder Chip-Einsatz = 1 Prägungspunkt seines Elements → [[Evolution & Prägung]]

| Stufe | Schwelle (Prägung) | ≈ Runs | Zusatz | Erreicht (typisch) |
|---|---|---|---|---|
| Rookie | 100 | 3 | Tutorial: erste 2 Runs zählen doppelt | Tag 1, im 2. Run |
| Champion | 600 | 15 | – | Tag 5–7 |
| Ultra | 2.000 | 50 | + 1 Ultra-Kern | Tag 25–35 |

**Ultra-Kern:** aus dem wöchentlichen Gilden-Boss oder als Monsterdex-Meilenstein. Nie käuflich.

## Daten-Fragmente (weiche Währung)

### Einnahmen
| Quelle | Menge |
|---|---|
| Run-Sieg Zone 1 / 2 / 3 / 4 | 60 / 90 / 130 / 180 |
| Niederlage | 50 % der bis dahin gesammelten Beute |
| Tagesquests (3 Stück) | je 40 |
| Duplikat-Chip zerlegen | 20 |

**Ein aktiver Spieler verdient in Woche 1 ca. 400–500 Fragmente pro Tag**, später 700–900.

### Ausgaben
| Zweck | Kosten |
|---|---|
| Chip Level 2 / 3 / 4 / 5 | 80 / 200 / 500 / 1.200 |
| Fusion (Zone-1-Monster / später) | 300 / 800 |
| Brutnest Slot 3 | 1.500 |
| Brutnest Slot 4 | 5.000 |
| Chip-Werkstatt Ausbau | 1.000 → 3.000 → 8.000 |

Faustregel: **Nach jeder Session ist genau eine sinnvolle Sache kaufbar.** Nie so knapp, dass nichts geht, nie so reich, dass Entscheidungen egal werden.

## Eier
| Quelle | Chance |
|---|---|
| Run-Sieg | 15 % |
| Boss beim ersten Sieg pro Zone | 100 % (seltenes Ei) |
| Tagesquest-Bonus | 1 gewöhnliches Ei pro Tag |
| **Pech-Schutz** | nach 8 Runs ohne Ei garantiert eines |

Brutzeiten: 15 Min. / 1 Std. / 4 Std. / 8 Std. → [[Station, Brüten & Fusion]]

## Kristalle (Premium-Währung)

### Kostenlose Quellen (pro 6-Wochen-Saison)
| Quelle | Menge |
|---|---|
| Tagesquests komplett (20/Tag) | ca. 840 |
| Wochenquests (100/Woche) | 600 |
| Kostenlose Pass-Spur | 300 |
| Monsterdex-Meilensteine (50 je 5 neue Monster) | ca. 200 |
| **Summe** | **ca. 1.900 pro Saison ≈ 45 pro Tag** |

### Kaufpreise
| Paket | Preis | Kristalle pro € |
|---|---|---|
| 80 | 0,99 € | 81 |
| 500 | 4,99 € | 100 |
| 1.100 | 9,99 € | 110 |
| 2.400 | 19,99 € | 120 |
| 6.500 | 49,99 € | 130 |

Mengenrabatte bewusst **flach** halten. Stark steigende Boni erzeugen Druck zu Großkäufen – das wollen wir bei einer jungen Zielgruppe nicht.

## Eier-Ziehungen
| | |
|---|---|
| 1 Ziehung | 150 Kristalle (≈ 1,40 €, wird immer angezeigt) |
| 10 Ziehungen | 1.350 Kristalle (1 Ziehung gratis) |
| Gewöhnlich / Selten / Episch / Legendär | 58 % / 30 % / 10 % / 2 % |
| Pity | spätestens die 40. Ziehung ist legendär |

Ein Gratis-Spieler schafft ca. **12–13 Ziehungen pro Saison**. Legendäre Monster sind für ihn zusätzlich über Ultra-Evolution und geheime Fusionen erreichbar.

## Glitch-Pass
| | |
|---|---|
| Dauer | 6 Wochen |
| Stufen | 50 à 1.000 Pass-XP |
| XP-Quellen | Run-Sieg 100, Niederlage 50, Tagesquests zusammen 150 |
| Benötigt | 50.000 XP ≈ 1.200 XP pro Tag |

Ein regelmäßiger Spieler schließt den Pass um **Tag 36–38** ab. Die letzten Tage sind Puffer. Gelegenheitsspieler bekommen über Doppel-XP-Wochenenden eine faire Chance. Pass-Stufen sind **nicht** kaufbar.

## Spielerreise (aktiver Gratis-Spieler)
| Zeitpunkt | Meilenstein |
|---|---|
| Tag 1 | Erste Evolution, 2–3 Monster, Station freigeschaltet |
| Tag 2 | Starter-Paket erscheint, erster Bosssieg Zone 1 |
| Tag 3 | Erste Fusion, Zone 2 |
| Tag 7 | Erster Champion, 8–10 Monster im Dex |
| Tag 14 | Zone 3, Brutnest Slot 3, erste Gilde |
| Tag 30 | Erste Ultra-Form, 18–20 Monster |
| Tag 60 | Zone 4 (Deep Web), Jagd nach geheimen Formen |

## Schwierigkeitskurve
| Zone | Ziel-Siegquote |
|---|---|
| Cache-Wiesen | 80 % |
| Firewall-Vulkan | 65 % |
| Viren-Sümpfe | 55 % |
| Deep Web | 40–50 % |

## Schutzmechanismen
- Optionales **Ausgabenlimit** pro Monat in den Einstellungen
- Kristallpreis wird in jedem Kaufdialog auch in Euro angezeigt
- Pech-Schutz bei Eiern und Pity bei Ziehungen
- Alle Werte über Remote Config änderbar → [[Tech Stack]]

Siehe auch: [[Monetarisierungsmodell]], [[KPIs & Metriken]], [[Ethik & Recht]]
