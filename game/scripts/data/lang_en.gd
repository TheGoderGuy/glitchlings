class_name LangEN
extends RefCounted
## Englische Texte (01.10.2026). Schlüssel = deutscher Text aus dem Code, Wert = Englisch. Siehe scripts/i18n.gd.
## Aufgeteilt in LangENNames (Namen), LangENData (Beschreibungen) und LangENText (Oberfläche, Ereignisse, Story).
## Fehlende Texte findet: node game/tools/lang_keys.js --missing

static var _all := {}


static func all() -> Dictionary:
	if _all.is_empty():
		_all = LangENNames.D.merged(LangENData.D).merged(LangENText.D)
	return _all
