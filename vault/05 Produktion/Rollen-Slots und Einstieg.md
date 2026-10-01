---
tags: [produktion, kampf, ux, spieltest, godot]
---
# Rollen-Slots und besserer Einstieg (01.10.2026)

## Anlass: Feedback vom ersten Tester
- Die Karten werden nicht erklärt. Als Neuling hat man Hektik und weiß nicht, was zu tun ist.
- Es war nicht klar, dass es ein Deck gibt. Der Tester dachte, er hätte nur die drei Karten.
- Sein Wunsch: Support-Karten immer auf derselben Taste, nur innerhalb des Slots wechselnd.

## Entscheidung des Produzenten: drei Rollen-Slots
| Slot | Tastatur | Controller | Rolle | Chips |
|---|---|---|---|---|
| 1 | J | □ / X | **Angriff** | alle Angriffe, Fallen, Beschwörungen, Seuche, Magnetfeld |
| 2 | K | ✕ / A | **Schutz** | Schilde (Firewall, Blubberschild, Hitzeschild, Kopierschutz, Konter), Nebel, Sprungantrieb, Blendgranate, Blackout, Eisfeld, Strudel |
| 3 | L | ○ / B | **Hilfe** (Heilung und Unterstützung) | Heilpatch, Neustart, Defrag, Ladungsfeld, Portscan, Übertakten |

- Jeder Slot zieht aus **seinem eigenen Teil des Decks** (`BattleState.piles` / `discs`).
- Ist ein Slot-Stapel leer, wird seine Ablage neu gemischt. Das kostet **+3 s Ladezeit** (`RESHUFFLE`), sonst käme ein einzelner Heilpatch zu oft.
- Hat das Deck keinen Chip einer Rolle, bleibt der Slot leer und zeigt „Kein Schutz-Chip im Deck“.
- **Startdecks:** jede Linie hat jetzt mindestens 1 Schutz- und 1 Hilfe-Chip. Wo Schutz fehlte, kam der neutrale Sprungantrieb dazu, damit die Element-Verteilung fair bleibt. Spukatz bekommt einen Heilpatch statt Byteschlag.
- Zuordnung: `GameData.ROLE_DEF`, `ROLE_SUP`, `role(id)`.
- Ein vierter Slot ist offen (Idee des Produzenten), erst nach weiteren Tests.

## Lesbare Karten
- Rahmen in Rollenfarbe: Angriff rot, Schutz blau, Hilfe mint. Der Streifen links zeigt weiterhin das Element.
- **Trefferbild** oben rechts (3×3 Gegnerfeld): Reihe, Nahkampf, Spalte, ganzes Feld, Einschlag, trifft immer, Mine, zieht heran. Schutz- und Hilfe-Chips zeigen stattdessen ein Symbol (Schild, Herz, Blitz …).
- **Kurzwirkung** statt nur „Angriff 20“, z. B. „20 · Gift“, „Schild 4 s“, „Heilt 25“, „×2 bei Brand“ (`GameData.CHIP_CARD`, `chip_short`).
- Über jeder Karte stehen die Rolle und der **nächste Chip** dieses Slots. Hinter der Karte ist der **Stapel** sichtbar. Beim Ziehen gleitet die neue Karte vom Stapel herein, der gespielte Name schwebt davon. Beim Neumischen steht „mischt …“ auf der Karte.

## Deck verständlich machen
- **Deck-Vorstellung** beim ersten Run (und einmal für bestehende Spielstände): drei Spalten Angriff/Schutz/Hilfe mit allen Chips und Kurzwirkung (`map_view._draw_deck_tip`, Flag `deck_intro_done`).
- **Tutorial:** neuer Schritt „Schutz und Hilfe“ nach dem ersten Treffer. Der Spieler soll K oder L ausprobieren.
- Deckliste (Pause, Karte) nach Rollen sortiert, mit Rollennamen in Farbe.
- Chipwahl: Oben auf jeder Karte steht der Slot („Schutz-Slot (K)“). Beim Händler steht die Rolle in der Beschreibung.
- Handbuch-Seite „Chips“ neu geschrieben.

## Entschleunigen
- **Bereit-Pause** vor jedem Kampf (auch nach Boss-Intros): Das Spiel steht, über jeder Karte und über der Signatur steht ihre Beschreibung. Mit Bestätigen oder einer Chip-Taste geht es los.
- **Neue Chips** werden einmal pro Spielstand erklärt: Kommt ein unbekannter Chip auf die Hand, läuft das Spiel 2,6 s in Zeitlupe (30 %), darüber erscheint „Neu: …“ mit der Beschreibung (`seen_chips` im Spielstand).

## Tests (287)
Neue Prüfungen:
- Slot-Zuordnung, Neumischen mit Strafzeit, jede Linie mit allen drei Rollen;
- Kurzwirkungen, Kartenbild für jeden Chip;
- Tutorial-Schritt „Schutz und Hilfe“;
- Bereit-Pause (Kampf steht, Bestätigen startet).

Screenshots: `--mode=ready`, `--mode=chiptip`.

## Offen
- Balancing beobachten: Heilung ist jetzt zuverlässiger verfügbar.
- Vierter Slot?
- Feedback der Tester zur neuen Steuerung.
