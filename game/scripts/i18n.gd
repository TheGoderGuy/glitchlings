class_name T
extends RefCounted
## Übersetzung (01.10.2026): Die deutschen Texte im Code sind die Schlüssel, die englischen stehen in LangEN.all().
## T.t("Weiter") gibt je nach Settings.lang den deutschen Text oder die Übersetzung zurück.
## Zusammengesetzte Texte: erst die Vorlage übersetzen, dann einsetzen – T.t("Noch %d Element-Chips") % n.
## Namen (Chips, Glitchlinge, Gegner, Module, Zonen …) bleiben intern deutsch (IDs im Spielstand),
## übersetzt wird nur die Anzeige. PixelCanvas._text() übersetzt automatisch, wenn der ganze Text ein Schlüssel ist.

## Unterstützte Sprachen: Kürzel und Anzeigename
const LANGS := {"de": "Deutsch", "en": "English"}


static func en() -> bool:
	return Settings.lang == "en"


## Text übersetzen (unbekannte Texte bleiben unverändert)
static func t(s: String) -> String:
	if Settings.lang == "de" or s == "":
		return s
	if LangEN.all().has(s):
		return LangEN.all()[s]
	# verbesserte Chips: „Glutball+“
	if s.ends_with("+") and LangEN.all().has(s.trim_suffix("+")):
		return LangEN.all()[s.trim_suffix("+")] + "+"
	# Elite-Gegner: „Elite-Bugsy“, „Glitch-Bytewurm“
	for pre in ["Elite-", "Glitch-"]:
		if s.begins_with(pre) and LangEN.all().has(s.substr(pre.length())):
			return LangEN.all().get(pre, pre) + LangEN.all()[s.substr(pre.length())]
	return s


## Chip-Name mit Verbesserung: „Glutball+“ > „Ember Ball+“
static func chip(id: String) -> String:
	if id.ends_with("+"):
		return t(id.trim_suffix("+")) + "+"
	return t(id)


## Liste von Namen übersetzen und mit Komma verbinden
static func names(list: Array, sep := ", ") -> String:
	var out: PackedStringArray = []
	for n in list:
		out.append(chip(str(n)))
	return sep.join(out)


## Kommazahl im Format der Sprache: 2,5 (Deutsch) bzw. 2.5 (Englisch)
static func dec(x: float, digits := 1) -> String:
	var s := ("%." + str(digits) + "f") % x
	return s if en() else s.replace(".", ",")


## Sprache aus dem System ableiten (erster Start): Deutsch bei deutschem System, sonst Englisch
static func system_lang() -> String:
	return "de" if OS.get_locale_language() == "de" else "en"
