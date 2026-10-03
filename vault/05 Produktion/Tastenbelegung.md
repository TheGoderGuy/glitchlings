---
tags: [produktion, steuerung, godot]
---
# Tastenbelegung (03.10.2026)

Wunsch des Produzenten: Die Tastaturbelegung soll änderbar sein.

## Bedienung
**Titel > Optionen > Tastenbelegung**
- Aktion wählen, Enter drücken, dann die neue Taste drücken. Esc bricht ab.
- Frei belegbar sind 11 Aktionen:

  | Aktion | Standard |
  |---|---|
  | Hoch / Runter / Links / Rechts | W / S / A / D |
  | Angriff 1 / Angriff 2 / Support | J / K / L |
  | Signatur | Leertaste |
  | Handbuch | H |
  | Reiter zurück / vor | Q / E |
- **Doppelte Belegung:** Die Tasten werden getauscht, und die Seite meldet „Getauscht mit …“.
- **Fest belegt**, damit man sich nicht aussperren kann: Pfeiltasten, Enter, Esc, Rücktaste und Tab. Die Pfeiltasten bewegen weiterhin immer, auch wenn WASD umbelegt ist.
- „Standard wiederherstellen“ setzt alles zurück.
- **Bestätigen** reagiert neben Enter weiter auch auf die Signatur- und die Angriff-1-Taste, so wie vorher Leertaste und J, und folgt deren neuer Belegung.

## Technik
- `InputSetup.REBIND` und `FIXED_KEYS`; `overrides` ordnet jeder Aktion eine physische Taste zu. Weil die Belegung über die Position auf der Tastatur läuft, funktioniert WASD auch auf QWERTZ und AZERTY.
- Gespeichert wird in `user://settings.cfg` unter `[keys] map`. `Settings.load_settings` übernimmt nur gültige Einträge und richtet danach die InputMap neu ein.
- Angezeigt wird der Tastenname nach dem Tastaturlayout des Systems (`key_label`). Sondertasten heißen auf Deutsch: Leertaste, Umschalt, Strg, Entf …
- **Alle Tastenhinweise folgen der Belegung:** Kampfkarten, Signatur-Karte, Tutorial, Handbuch, Karte (Deck-Vorstellung, Hinweise) und Station (Reiter, Hilfe, Führung).
  - Die Leertaste steht im Satz mit Artikel („Drück die Leertaste“), andere Tasten ohne („Drück U“): `key_text`.
  - Die Bewegungstasten erscheinen als „WASD“ bzw. „IASD“: `move_keys`.
- Kampfkarten: Das Tasten-Kästchen wächst mit langen Namen wie „Umschalt“ mit, der Chipname wird dann mit Punkt gekürzt.
- Die Optionen laufen jetzt über Kennungen statt Positionsnummern (`OPTIONS` in `title.gd`). Neue Einträge verschieben so keine Nummern mehr.
- Screenshot: `--mode=keys [--t=Zeile]`, Belegung zum Testen mit `--key=chip_1:Shift`.
- Tests (6): Standard, Umbelegen samt Bestätigen und Anzeige, Tausch, feste Tasten, Pfeiltasten bleiben erhalten, Zurücksetzen. Insgesamt 303 Prüfungen.

## Offen
- Controller-Belegung ist noch nicht änderbar. Steam Input kann das systemweit, eine eigene Lösung wäre optional.
