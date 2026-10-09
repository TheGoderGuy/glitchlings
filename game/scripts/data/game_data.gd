class_name GameData
extends RefCounted
## Spieldaten, übernommen aus prototype/index.html (CHIPS, FOES, MONS).

static var EL := {
	"Neutral": Color("#B8B0DD"), "Feuer": Color("#FF8A4C"), "Code": Color("#58D68D"),
	"Wasser": Color("#4CC3F0"), "Elektro": Color("#FFD84D"), "Virus": Color("#C77DFF"),
}

## Farben der Kampfansicht (dunkles Theme des Prototyps)
static var COL := {
	"bg": Color("#1E1738"), "bg2": Color("#171130"), "panel": Color("#2C2352"), "line": Color("#4A3E80"),
	"ink": Color("#F6F1FF"), "muted": Color("#B2A8D8"), "mint": Color("#6EE7C5"), "coral": Color("#FF7A93"),
	"sun": Color("#FFC83D"), "tileP": Color("#2A5A63"), "tileE": Color("#5A2F54"), "dark": Color("#120D24"),
}

const CHIPS := {
	"Pixelstrahl": {"cat": "Angriff", "el": "Neutral", "dmg": 20, "cd": 2.0, "rar": "Gewöhnlich", "desc": "Projektil über deine Reihe."},
	"Byteschlag": {"cat": "Angriff", "el": "Neutral", "dmg": 30, "cd": 1.5, "rar": "Gewöhnlich", "desc": "Nahkampf: vordere zwei Felder deiner Reihe."},
	"Firewall": {"cat": "Schild", "el": "Code", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Blockt den nächsten Treffer (4 s)."},
	"Bug-Mine": {"cat": "Falle", "el": "Virus", "dmg": 35, "cd": 3.0, "rar": "Selten", "desc": "Mine unter dem Gegner. Explodiert, wenn er darauf steht."},
	"Übertakten": {"cat": "Buff", "el": "Feuer", "dmg": 0, "cd": 6.0, "rar": "Selten", "desc": "Alle Chips laden 5 s doppelt so schnell."},
	"Glutball": {"cat": "Angriff", "el": "Feuer", "dmg": 45, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Schlägt 3 Felder vor dir ein: 45 im Zentrum, 20 daneben. Setzt Brand."},
	"Flammenwelle": {"cat": "Angriff", "el": "Feuer", "dmg": 25, "cd": 3.5, "rar": "Selten", "desc": "Trifft die ganze Spalte, in der der Gegner steht."},
	"Wasserstrahl": {"cat": "Angriff", "el": "Wasser", "dmg": 15, "cd": 2.0, "rar": "Gewöhnlich", "desc": "Projektil. Stößt den Gegner ein Feld zurück."},
	"Blubberschild": {"cat": "Schild", "el": "Wasser", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Blase absorbiert 30 Schaden (5 s)."},
	"Eisfeld": {"cat": "Feldeffekt", "el": "Wasser", "dmg": 0, "cd": 4.0, "rar": "Selten", "desc": "Friert den Gegner 2 s ein."},
	"Heilpatch": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 5.0, "rar": "Gewöhnlich", "desc": "Heilt sofort 25 HP."},
	"Blitzcursor": {"cat": "Angriff", "el": "Elektro", "dmg": 20, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Markiert den Gegner. Trifft nach 0,5 s garantiert."},
	"Mini-Bot": {"cat": "Beschwörung", "el": "Code", "dmg": 0, "cd": 6.0, "rar": "Selten", "desc": "Helfer: 6 s lang 5 Schaden pro Sekunde."},
	"Virusspritzer": {"cat": "Angriff", "el": "Virus", "dmg": 10, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Projektil. Vergiftet 4 s lang."},
	"Defrag": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 8.0, "rar": "Episch", "desc": "Lädt alle anderen Chips in der Hand sofort."},
	# --- Erweiterung 28.09.2026 ---
	"Doppelklick": {"cat": "Angriff", "el": "Neutral", "dmg": 12, "cd": 1.8, "rar": "Gewöhnlich", "desc": "Zwei schnelle Projektile über deine Reihe, je 12."},
	"Neustart": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 7.0, "rar": "Episch", "desc": "Heilt 15 HP und zieht eine komplett neue, sofort bereite Hand."},
	"Funkenregen": {"cat": "Angriff", "el": "Feuer", "dmg": 25, "cd": 3.0, "rar": "Selten", "desc": "Funken regnen aufs Gegnerfeld, einer trifft immer: 25 + Brand."},
	"Hitzeschild": {"cat": "Schild", "el": "Feuer", "dmg": 0, "cd": 5.0, "rar": "Gewöhnlich", "desc": "Blockt den nächsten Treffer (4 s) und setzt den Angreifer in Brand."},
	"Laserschuss": {"cat": "Angriff", "el": "Code", "dmg": 25, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Sofortiger Laser über deine Reihe: 25."},
	"Portscan": {"cat": "Buff", "el": "Code", "dmg": 0, "cd": 4.0, "rar": "Selten", "desc": "Deine nächsten 2 Treffer machen +50 % Schaden."},
	"Strudel": {"cat": "Feldeffekt", "el": "Wasser", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Der Gegner wird 3 s lang halb so schnell."},
	"Nebel": {"cat": "Schild", "el": "Wasser", "dmg": 0, "cd": 5.0, "rar": "Selten", "desc": "3 s lang verfehlen dich Angriffe mit 50 % Chance."},
	"Blitzlanze": {"cat": "Angriff", "el": "Elektro", "dmg": 30, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Trifft die Gegnerspalte, die deiner Spalte entspricht: 30."},
	"Blendgranate": {"cat": "Feldeffekt", "el": "Elektro", "dmg": 0, "cd": 5.0, "rar": "Selten", "desc": "Blendet den Gegner: sein laufender Angriff wird abgebrochen."},
	"Wurmloch": {"cat": "Falle", "el": "Virus", "dmg": 10, "cd": 3.0, "rar": "Selten", "desc": "Zieht den Gegner in deine Reihe: 10 Schaden."},
	"Kurzschluss": {"cat": "Angriff", "el": "Elektro", "dmg": 18, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Projektil: 18 Schaden, betäubt 0,5 s."},
	"Datenfresser": {"cat": "Angriff", "el": "Virus", "dmg": 15, "cd": 2.0, "rar": "Gewöhnlich", "desc": "Projektil: 15, doppelt gegen vergiftete Gegner."},
	# --- Erweiterung 29.09.2026: Kombos mit Zonen-Mechaniken und Modulen ---
	"Glutklinge": {"cat": "Angriff", "el": "Feuer", "dmg": 22, "cd": 1.6, "rar": "Gewöhnlich", "desc": "Nahkampf: vordere zwei Felder deiner Reihe, 22 + kurzer Brand."},
	"Feuersbrunst": {"cat": "Angriff", "el": "Feuer", "dmg": 30, "cd": 6.0, "rar": "Episch", "desc": "Ganzes Gegnerfeld: 30 + langer Brand. Doppelt, wenn er schon brennt."},
	"Flutwelle": {"cat": "Angriff", "el": "Wasser", "dmg": 28, "cd": 3.5, "rar": "Selten", "desc": "Welle über deine Reihe: 28, stößt den Gegner zurück."},
	"Frostsplitter": {"cat": "Angriff", "el": "Wasser", "dmg": 14, "cd": 2.2, "rar": "Gewöhnlich", "desc": "Projektil: 14, dreifach gegen eingefrorene oder langsame Gegner."},
	"Tsunami": {"cat": "Angriff", "el": "Wasser", "dmg": 35, "cd": 7.0, "rar": "Episch", "desc": "Trifft das ganze Gegnerfeld: 35 und friert 1,5 s ein."},
	"Kopierschutz": {"cat": "Schild", "el": "Code", "dmg": 15, "cd": 6.0, "rar": "Selten", "desc": "Blockt den nächsten Treffer (6 s) und wirft 15 Schaden zurück."},
	"Geschützturm": {"cat": "Beschwörung", "el": "Code", "dmg": 12, "cd": 7.0, "rar": "Selten", "desc": "Turm für 8 s: feuert alle 1,5 s einen Laser über deine Reihe (12)."},
	"Debugger": {"cat": "Angriff", "el": "Code", "dmg": 20, "cd": 2.5, "rar": "Gewöhnlich", "desc": "Laser über deine Reihe: 20. Entfernt Lava, Schleim und Diener auf deiner Seite."},
	"Kettenblitz": {"cat": "Angriff", "el": "Elektro", "dmg": 15, "cd": 3.0, "rar": "Selten", "desc": "Trifft garantiert: 15, dann springt der Blitz zweimal nach (je 10)."},
	"Ladungsfeld": {"cat": "Buff", "el": "Elektro", "dmg": 0, "cd": 4.0, "rar": "Gewöhnlich", "desc": "Lädt deine Signatur-Leiste um 25 %."},
	"Magnetfeld": {"cat": "Feldeffekt", "el": "Elektro", "dmg": 0, "cd": 3.5, "rar": "Gewöhnlich", "desc": "Zieht den Gegner in deine Spalte, betäubt 0,5 s. Kombo mit Blitzlanze!"},
	"Blackout": {"cat": "Feldeffekt", "el": "Elektro", "dmg": 0, "cd": 7.0, "rar": "Episch", "desc": "Stromausfall: Gegner 3 s betäubt, sein laufender Angriff fällt aus."},
	"Seuche": {"cat": "Feldeffekt", "el": "Virus", "dmg": 0, "cd": 4.0, "rar": "Selten", "desc": "Verdoppelt das Gift auf dem Gegner (min. 4 s)."},
	"Sporenfalle": {"cat": "Falle", "el": "Virus", "dmg": 15, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Mine unter dem Gegner: 15 Schaden und 6 s Gift."},
	"Parasit": {"cat": "Angriff", "el": "Virus", "dmg": 12, "cd": 3.0, "rar": "Selten", "desc": "Projektil: 12 Schaden, du heilst dich um genauso viel."},
	"Sprungantrieb": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 3.0, "rar": "Gewöhnlich", "desc": "Du weichst dem nächsten Treffer in den nächsten 2 s aus."},
	"Konter": {"cat": "Schild", "el": "Neutral", "dmg": 35, "cd": 4.0, "rar": "Selten", "desc": "Blockt einen Treffer in den nächsten 1,5 s und schlägt mit 35 zurück."},
	# --- Linien-Chips (08.10.2026, Game-Design-Analyse): je Linie ein eigener Chip im Startdeck, passend zum Tier.
	# Neutral (lenkt die Evolution nicht), Seltenheit „Linie“: nie in Chipwahl, Händler oder Ereignissen (Schlüssel "line").
	"Krallenwirbel": {"cat": "Angriff", "el": "Neutral", "dmg": 9, "cd": 2.2, "rar": "Linie", "line": "Pixmiez", "desc": "Nahkampf: 3 schnelle Krallenhiebe à 9 auf die vorderen zwei Felder."},
	"Stöckchen": {"cat": "Angriff", "el": "Neutral", "dmg": 14, "cd": 2.0, "rar": "Linie", "line": "Funkling", "desc": "Projektil: 14. Kommt zurück und trifft dabei noch einmal (10)."},
	"Kiemenatmung": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 6.5, "rar": "Linie", "line": "Tröpfel", "desc": "Heilt sofort 8 HP und danach 6 s lang 3 HP pro Sekunde."},
	"Backenvorrat": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 6.0, "rar": "Linie", "line": "Kekso", "desc": "Beide Angriffs-Chips auf der Hand sind sofort geladen."},
	"Hakenschlag": {"cat": "Schild", "el": "Neutral", "dmg": 0, "cd": 3.5, "rar": "Linie", "line": "Lumi", "desc": "Weicht dem nächsten Treffer in 2 s aus. Dein nächster Treffer +50 %."},
	"Zungenzug": {"cat": "Angriff", "el": "Neutral", "dmg": 14, "cd": 3.0, "rar": "Linie", "line": "Quakli", "desc": "Zieht den Gegner in deine Reihe nach vorn: 14, betäubt 0,5 s."},
	"Hautgift": {"cat": "Angriff", "el": "Neutral", "dmg": 10, "cd": 2.4, "rar": "Linie", "line": "Molchi", "desc": "Projektil: 10. Verlängert Gift und Brand auf dem Gegner um je 3 s (sonst 2 s Gift)."},
	"Bärenhieb": {"cat": "Angriff", "el": "Neutral", "dmg": 34, "cd": 3.2, "rar": "Linie", "line": "Brummbit", "desc": "Nahkampf: vordere zwei Felder deiner Reihe, 34. Stößt zurück und betäubt 0,5 s."},
	"Eulenauge": {"cat": "Buff", "el": "Neutral", "dmg": 0, "cd": 5.0, "rar": "Linie", "line": "Kauzbit", "desc": "4 s lang ist jedes Ausholen des Gegners konterbar."},
	"Graben": {"cat": "Schild", "el": "Neutral", "dmg": 22, "cd": 5.0, "rar": "Linie", "line": "Buddli", "desc": "1,2 s eingegraben (unverwundbar), dann Stoß von unten: 22, trifft immer."},
	"Stibitzen": {"cat": "Angriff", "el": "Neutral", "dmg": 12, "cd": 2.6, "rar": "Linie", "line": "Maskli", "desc": "Projektil: 12. Gegner greift 1 s später an, Support sofort geladen."},
	"Kieselwurf": {"cat": "Angriff", "el": "Neutral", "dmg": 24, "cd": 2.6, "rar": "Linie", "line": "Bachli", "desc": "Bogenwurf 3 Felder vor dir: 24 im Zentrum, 12 auf den Nachbarfeldern."},
	"Echoruf": {"cat": "Angriff", "el": "Neutral", "dmg": 10, "cd": 3.0, "rar": "Linie", "line": "Plapperli", "desc": "Schall über deine Reihe: 10, dann Echo deines letzten Angriffs (halb)."},
}


## Linien-Chip (nur im Startdeck seiner Linie, nie in Chipwahl, Händler oder Ereignissen)?
static func is_line_chip(id: String) -> bool:
	return CHIPS.get(base_chip(id), {}).has("line")

## ---------- Verbesserte Chips (30.09.2026) ----------
## „Glutball+“ ist die verbesserte Fassung von „Glutball“: +30 % Schaden (auf 5 gerundet), 20 % kürzere Ladezeit.
## Chips ohne Schaden (Schilde, Heilung …) laden schneller und wirken 30 % stärker (k).
## ---------- Rollen-Slots (01.10.2026, Spieltest-Feedback; 03.10.2026 auf 2 + 1 umgestellt) ----------
## Zwei Angriffs-Slots (J / □ und K / ✕) teilen sich den Angriffsstapel, der Support-Slot (L / ○) zieht
## Schutz und Heilung aus dem Support-Stapel. Rolle = Stapel: 0 Angriff, 1 Support.
const ROLE_NAMES := ["Angriff", "Support"]
const ROLE_COL := ["#FF7A93", "#6EE7C5"]
const SLOT_ROLE := [0, 0, 1]
const ROLE_DEF := ["Blubberschild", "Firewall", "Hitzeschild", "Konter", "Kopierschutz", "Nebel", "Sprungantrieb",
	"Blendgranate", "Blackout", "Eisfeld", "Strudel", "Hakenschlag", "Graben"]
const ROLE_SUP := ["Heilpatch", "Neustart", "Defrag", "Ladungsfeld", "Portscan", "Übertakten", "Kiemenatmung", "Backenvorrat", "Eulenauge"]


static func role(id: String) -> int:
	var b := base_chip(id)
	return 1 if ROLE_DEF.has(b) or ROLE_SUP.has(b) else 0


## Kartenbild im Kampf: [Trefferbild oder Symbol, Kurzwirkung]. Trefferbilder (3×3 Gegnerfeld):
## row = deine Reihe, front = vordere zwei Felder deiner Reihe, col = Spalte des Gegners, mycol = deine Spalte,
## field = ganzes Feld, aim = trifft immer den Gegner, mine = unter dem Gegner, blast = Einschlag mit Rand, pull = zieht heran.
## Sonst ein Symbol aus PICTOS.
const CHIP_CARD := {
	"Pixelstrahl": ["row", ""], "Byteschlag": ["front", "Nahkampf"], "Firewall": ["shield", "Schild 4 s"],
	"Bug-Mine": ["mine", "Mine"], "Übertakten": ["gear", "Laden ×2"], "Glutball": ["blast", "Brand"],
	"Flammenwelle": ["col", "Spalte"], "Wasserstrahl": ["row", "Rückstoß"], "Blubberschild": ["shield", "Blase 30"],
	"Eisfeld": ["snow", "Friert 2 s"], "Heilpatch": ["heart", "Heilt 25"], "Blitzcursor": ["aim", "trifft immer"],
	"Mini-Bot": ["gear", "Helfer 6 s"], "Virusspritzer": ["row", "Gift"], "Defrag": ["bolt", "Lädt Hand"],
	"Doppelklick": ["row", "2×"], "Neustart": ["heart", "Neue Hand"], "Funkenregen": ["field", "Brand"],
	"Hitzeschild": ["shield", "Schild + Brand"], "Laserschuss": ["row", "sofort"], "Portscan": ["eye", "+50 % ×2"],
	"Strudel": ["arrow", "Gegner langsam"], "Nebel": ["boot", "Ausweichen 3 s"], "Blitzlanze": ["mycol", "Spalte"],
	"Blendgranate": ["eye", "Stoppt Angriff"], "Wurmloch": ["pull", "Zieht heran"], "Kurzschluss": ["row", "Betäubt"],
	"Datenfresser": ["row", "×2 bei Gift"], "Glutklinge": ["front", "Brand"], "Feuersbrunst": ["field", "×2 bei Brand"],
	"Flutwelle": ["row", "Rückstoß"], "Frostsplitter": ["row", "×3 bei Eis"], "Tsunami": ["field", "Friert"],
	"Kopierschutz": ["shield", ""], "Geschützturm": ["gear", "Turm 8 s"], "Debugger": ["row", "Säubert"],
	"Kettenblitz": ["aim", "springt"], "Ladungsfeld": ["bolt", "Signatur +25 %"], "Magnetfeld": ["pull", "Betäubt"],
	"Blackout": ["bolt", "Betäubt 3 s"], "Seuche": ["skull", "Gift ×2"], "Sporenfalle": ["mine", "Gift"],
	"Parasit": ["row", "Lebensraub"], "Sprungantrieb": ["boot", "Weicht aus"], "Konter": ["shield", ""],
	# Linien-Chips
	"Krallenwirbel": ["front", "3× Kralle"], "Stöckchen": ["row", "kommt zurück"], "Kiemenatmung": ["heart", ""],
	"Backenvorrat": ["bolt", "Angriffe bereit"], "Hakenschlag": ["boot", "Ausweichen + 50 %"], "Zungenzug": ["pull", "Zieht nach vorn"],
	"Hautgift": ["row", "Gift/Brand +3 s"], "Bärenhieb": ["front", "Rückstoß"], "Eulenauge": ["eye", "Konter leicht"],
	"Graben": ["shield", ""], "Stibitzen": ["row", "klaut Zeit"], "Kieselwurf": ["blast", "Bogenwurf"], "Echoruf": ["row", "Echo"],
}


## Kurzwirkung für die Karte: „20 · Gift“, „Schild 4 s“, „Heilt 32“ (verbessert)
static func chip_short(id: String) -> String:
	var ch := chip(id)
	var info: Array = CHIP_CARD.get(base_chip(id), ["row", ""])
	var s := T.t(info[1])
	if id == "Heilpatch+":
		s = T.t("Heilt %d") % roundi(25 * float(ch.get("k", 1.0)))
	# Linien-Chips mit Zahlen, die mit der Verbesserung wachsen
	match base_chip(id):
		"Kiemenatmung":
			return T.t("Heilt %d + %d") % [roundi(8 * float(ch.get("k", 1.0))), 6 * roundi(3 * float(ch.get("k", 1.0)))]
		"Graben":
			return T.t("Eingraben + %d") % int(ch.dmg)
	if int(ch.dmg) > 0 and role(id) == 0:
		return str(ch.dmg) + ("" if s == "" else " · " + s)
	if int(ch.dmg) > 0 and base_chip(id) in ["Konter", "Kopierschutz"]:
		return T.t("Block + %d") % ch.dmg if base_chip(id) == "Kopierschutz" else T.t("Konter %d") % ch.dmg
	return s

const UP_DMG := 1.3
const UP_CD := 0.8
static var _up_cache := {}


## Werte eines Chips aus dem Deck (auch verbesserte „Name+“)
static func chip(id: String) -> Dictionary:
	if not id.ends_with("+"):
		return CHIPS[id]
	if not _up_cache.has(id):
		var b: Dictionary = CHIPS[id.trim_suffix("+")]
		var d := b.duplicate()
		if int(b.dmg) > 0:
			d.dmg = maxi(int(b.dmg) + 5, roundi(b.dmg * UP_DMG / 5.0) * 5)
			d.k = float(d.dmg) / float(b.dmg)
		else:
			d.k = UP_DMG
		d.cd = snappedf(b.cd * UP_CD, 0.1)
		d.up = true
		_up_cache[id] = d
	return _up_cache[id]


static func base_chip(id: String) -> String:
	return id.trim_suffix("+")


static func is_upgraded(id: String) -> bool:
	return id.ends_with("+")


## Kurzbeschreibung der Verbesserung, z. B. „45 → 60 Schaden, 3,0 → 2,4 s“
static func upgrade_text(id: String) -> String:
	var b: Dictionary = CHIPS[base_chip(id)]
	var u := chip(base_chip(id) + "+")
	var cd := "%s > %s s" % [T.dec(b.cd), T.dec(u.cd)]
	if int(b.dmg) > 0:
		return (T.t("%d > %d Schaden, ") % [b.dmg, u.dmg]) + cd
	return T.t("30 % stärker, ") + cd


## ---------- Synergien (Anzeige in Chipwahl und Händler) ----------
## Tags: was ein Chip auslöst. PAYOFFS: welcher Tag einen Chip besonders stark macht.
const CHIP_TAGS := {
	"Glutball": ["brand"], "Funkenregen": ["brand"], "Hitzeschild": ["brand"], "Glutklinge": ["brand", "reihe"], "Feuersbrunst": ["brand"],
	"Virusspritzer": ["gift"], "Sporenfalle": ["gift"],
	"Eisfeld": ["kaelte"], "Strudel": ["kaelte"], "Tsunami": ["kaelte"], "Kurzschluss": ["kaelte"], "Blackout": ["kaelte"], "Magnetfeld": ["kaelte"],
	"Byteschlag": ["reihe"], "Laserschuss": ["reihe"], "Flutwelle": ["reihe"], "Debugger": ["reihe"],
	"Blitzlanze": ["spalte"],
}
const PAYOFFS := {"Feuersbrunst": "brand", "Datenfresser": "gift", "Seuche": "gift", "Frostsplitter": "kaelte",
	"Wurmloch": "reihe", "Magnetfeld": "spalte"}
const MODULE_TAGS := {"ueberhitzer": "brand", "giftkapsel": "gift", "kaeltekern": "kaelte"}
const PASSIVE_TAGS := {"Giftdrüsen": ["gift", "brand"], "Giftbaut": ["gift"], "Schwebegas": ["gift"]}


## Passt der Chip zu Deck, Modulen oder Passiv? Gibt z. B. „Kombo mit Feuersbrunst“ zurück, sonst "".
static func synergy(chip_id: String, deck: Array, modules: Array, passive: String) -> String:
	var b := base_chip(chip_id)
	var tags: Array = CHIP_TAGS.get(b, [])
	var need: String = PAYOFFS.get(b, "")
	for c in deck:
		var cb := base_chip(c)
		if cb == b:
			continue
		if need != "" and CHIP_TAGS.get(cb, []).has(need):
			return T.t("Kombo mit %s") % T.chip(cb)
		var cneed: String = PAYOFFS.get(cb, "")
		if cneed != "" and tags.has(cneed):
			return T.t("Kombo mit %s") % T.chip(cb)
	for m in modules:
		if MODULE_TAGS.has(m) and (tags.has(MODULE_TAGS[m]) or need == MODULE_TAGS[m]):
			return T.t("Kombo mit %s") % T.t(MODULES[m].name)
	for t in PASSIVE_TAGS.get(passive, []):
		if tags.has(t) or need == t:
			return T.t("Kombo mit %s") % T.t(passive)
	return ""


const FOES := [
	{"name": "Bugsy", "el": "Virus", "hp": 70, "move": 1.4, "atk": 2.4, "dmg": 10, "pat": ["row"], "spr": "bug", "loot": 10, "boss": false, "tele": false},
	{"name": "Glitchmotte", "el": "Elektro", "hp": 60, "move": 1.0, "atk": 2.0, "dmg": 14, "pat": ["cell"], "spr": "moth", "loot": 10, "boss": false, "tele": true},
	{"name": "Bytewurm", "el": "Virus", "hp": 90, "move": 1.6, "atk": 2.6, "dmg": 12, "pat": ["row", "thorn", "col"], "spr": "wurm", "loot": 10, "boss": false, "tele": false},
	{"name": "Kernelmantis", "el": "Virus", "hp": 380, "move": 1.8, "atk": 2.2, "dmg": 16, "pat": ["row"], "spr": "mantis", "title": "Wächter des System-Kernels", "loot": 30, "boss": true, "tele": false, "minion": "thorn",
		"phase2": ["row", "thorn", "cross", "col"], "phase3": ["cross", "col2", "row"],
		"specials": [{"shape": "x", "name": "Sensenkreuz"}, {"shape": "chase", "name": "Klingenhatz"}]},
	# --- Cache-Wiesen-Erweiterung 28.09.2026 (Index 4–6) ---
	{"name": "Chiffrekäfer", "el": "Code", "hp": 80, "move": 1.5, "atk": 2.5, "dmg": 12, "pat": ["cross", "thorn"], "spr": "kaefer", "loot": 10, "boss": false, "tele": false},
	{"name": "Datenwespe", "el": "Virus", "hp": 50, "move": 0.8, "atk": 1.7, "dmg": 8, "pat": ["cell", "row", "cell"], "spr": "wespe", "loot": 10, "boss": false, "tele": false},
	{"name": "Glutraupe", "el": "Feuer", "hp": 115, "move": 2.2, "atk": 3.2, "dmg": 16, "pat": ["wall"], "spr": "raupe", "loot": 12, "boss": false, "tele": false},
	# --- Firewall-Vulkan (Index 7–10) ---
	{"name": "Glutmilbe", "el": "Feuer", "hp": 60, "move": 0.7, "atk": 1.6, "dmg": 9, "pat": ["cell", "cell", "row"], "spr": "milbe", "loot": 11, "boss": false, "tele": false},
	{"name": "Brandmauerassel", "el": "Code", "hp": 130, "move": 2.0, "atk": 3.0, "dmg": 15, "pat": ["col2"], "spr": "assel", "loot": 13, "boss": false, "tele": false},
	{"name": "Aschefalter", "el": "Feuer", "hp": 75, "move": 1.1, "atk": 2.4, "dmg": 10, "pat": ["lava", "cell"], "spr": "falter", "loot": 12, "boss": false, "tele": true},
	{"name": "Glutkernskarabäus", "el": "Feuer", "hp": 500, "move": 1.8, "atk": 2.1, "dmg": 17, "pat": ["row", "lava", "col"], "spr": "skarab", "title": "Glühendes Herz des Vulkans", "loot": 40, "boss": true, "tele": false, "minion": "lava",
		"phase2": ["col2", "lava", "row"], "phase3": ["wall", "lava", "cross"],
		"specials": [{"shape": "ring", "name": "Sonnenrad"}, {"shape": "safe1", "name": "Kernschmelze"}]},
	# --- Viren-Sümpfe (Index 11–14) ---
	{"name": "Saugmücke", "el": "Virus", "hp": 65, "move": 0.8, "atk": 1.8, "dmg": 10, "pat": ["cell", "row"], "spr": "muecke", "loot": 13, "boss": false, "tele": false, "drain": true},
	{"name": "Panzerschnecke", "el": "Code", "hp": 140, "move": 2.6, "atk": 2.8, "dmg": 14, "pat": ["slime", "row"], "spr": "schnecke", "loot": 14, "boss": false, "tele": false},
	{"name": "Glitchblüte", "el": "Virus", "hp": 110, "move": 99.0, "atk": 2.2, "dmg": 13, "pat": ["cross", "pop", "cross"], "spr": "bluete", "loot": 14, "boss": false, "tele": false, "stationary": true},
	{"name": "Schwarmkönigin", "el": "Virus", "hp": 600, "move": 1.9, "atk": 2.0, "dmg": 18, "pat": ["row", "slime", "col", "pop"], "spr": "koenigin", "title": "Herrscherin der Viren-Sümpfe", "loot": 50, "boss": true, "tele": false, "minion": "mix", "drain": true,
		"phase2": ["cross", "slime", "wall", "pop"], "phase3": ["col2", "pop", "cross", "slime"],
		"specials": [{"shape": "checker", "name": "Schwarmwelle"}, {"shape": "sweep", "name": "Stachelregen"}]},
	# --- NEST-Kern (Index 15–17) ---
	{"name": "Kerndrohne", "el": "Code", "hp": 120, "move": 1.4, "atk": 2.4, "dmg": 15, "pat": ["col2", "cross"], "spr": "drohne", "loot": 15, "boss": false, "tele": false},
	{"name": "Glitchspinne", "el": "Virus", "hp": 95, "move": 1.0, "atk": 2.2, "dmg": 14, "pat": ["wall", "cell", "row"], "spr": "spinne", "loot": 15, "boss": false, "tele": true},
	{"name": "Ur-Glitch", "el": "Virus", "hp": 800, "move": 1.7, "atk": 1.9, "dmg": 19, "pat": ["row", "cross", "col2", "wall"], "spr": "urglitch", "title": "Der Fehler, der den NEST zerbrach", "loot": 80, "boss": true, "tele": false, "minion": "shift", "shift": true, "final": true,
		"phase2": ["cross", "col2", "wall", "row"], "phase3": ["wall", "cross", "col2", "cross"],
		"specials": [{"shape": "ring", "name": "Systemabsturz"}, {"shape": "x", "name": "Kernfehler"}, {"shape": "safe1", "name": "Totalausfall"}, {"shape": "sweep", "name": "Datenlöschung"}]},
	# --- Ebenen-Wächter (30.09.2026, Index 18–24): Mini-Bosse am Ende von Ebene 1 und 2 jeder Zone ---
	# Großangriffe (specials) gibt es bei Wächtern von Anfang an, bei Bossen ab Phase 2.
	{"name": "Sprungschreck", "el": "Elektro", "hp": 230, "move": 1.3, "atk": 2.2, "dmg": 14, "pat": ["row", "cell", "col"], "spr": "sprungschreck",
		"title": "Der Springer der Datenwiesen", "loot": 22, "boss": true, "guard": true, "tele": true, "minion": "none",
		"phase2": ["cross", "row", "cell", "col"], "specials": [{"shape": "chase", "name": "Hüpfjagd"}]},
	{"name": "Dornwurz", "el": "Virus", "hp": 280, "move": 99.0, "atk": 2.3, "dmg": 15, "pat": ["cross", "thorn", "row"], "spr": "dornwurz",
		"title": "Die Wurzel der Wiesen", "loot": 24, "boss": true, "guard": true, "tele": false, "stationary": true, "minion": "none", "pop_kind": "spore",
		"phase2": ["cross", "pop", "row", "col"], "specials": [{"shape": "checker", "name": "Dornenteppich"}]},
	{"name": "Schlackwurm", "el": "Feuer", "hp": 310, "move": 1.7, "atk": 2.3, "dmg": 16, "pat": ["lava", "row"], "spr": "schlackwurm",
		"title": "Er gräbt durch glühendes Gestein", "loot": 28, "boss": true, "guard": true, "tele": true, "minion": "none",
		"phase2": ["lava", "col2", "row"], "specials": [{"shape": "safe1", "name": "Magmageysir"}]},
	{"name": "Magmaskorp", "el": "Code", "hp": 360, "move": 1.7, "atk": 2.2, "dmg": 17, "pat": ["col", "row", "cell"], "spr": "magmaskorp",
		"title": "Der Stachel der Brandmauer", "loot": 30, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["col2", "cross", "lava", "row"], "specials": [{"shape": "pincer", "name": "Scherenzange"}]},
	{"name": "Schnappkelch", "el": "Virus", "hp": 380, "move": 99.0, "atk": 2.2, "dmg": 16, "pat": ["cross", "slime"], "spr": "schnappkelch",
		"title": "Der Hunger aus dem Sumpf", "loot": 32, "boss": true, "guard": true, "tele": false, "stationary": true, "minion": "none", "pop_kind": "spore",
		"phase2": ["cross", "slime", "row", "pop"], "specials": [{"shape": "pull", "name": "Fangschlund"}]},
	{"name": "Schlickkrake", "el": "Wasser", "hp": 430, "move": 1.5, "atk": 2.1, "dmg": 17, "pat": ["row", "slime", "col"], "spr": "schlickkrake",
		"title": "Herr des tiefen Schlicks", "loot": 34, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["col2", "slime", "wall"], "specials": [{"shape": "tentacle", "name": "Tentakelwirbel"}]},
	{"name": "Skolopendrox", "el": "Code", "hp": 480, "move": 1.2, "atk": 2.0, "dmg": 18, "pat": ["row", "col2"], "spr": "skolopendrox",
		"title": "Torwächter des Kerns", "loot": 40, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["wall", "cross", "col2"], "specials": [{"shape": "sweep", "name": "Segmentfeuer"}]},
	# --- Zonentypische Gegner (04.10.2026, Tester: „Bosse passen, Gegner nicht“) – Index 25–29 ---
	{"name": "Funkenkäfer", "el": "Feuer", "hp": 85, "move": 1.3, "atk": 2.4, "dmg": 12, "pat": ["cell", "lava", "cell"], "spr": "funkenkaefer", "loot": 12, "boss": false, "tele": false},
	{"name": "Datenegel", "el": "Wasser", "hp": 100, "move": 1.8, "atk": 2.4, "dmg": 11, "pat": ["row", "slime"], "spr": "datenegel", "loot": 13, "boss": false, "tele": false, "drain": true},
	{"name": "Moorlibelle", "el": "Wasser", "hp": 60, "move": 0.7, "atk": 1.6, "dmg": 9, "pat": ["cell", "cell", "col"], "spr": "moorlibelle", "loot": 13, "boss": false, "tele": true},
	{"name": "Sentinelkrabbe", "el": "Code", "hp": 150, "move": 2.2, "atk": 2.7, "dmg": 16, "pat": ["row", "col2"], "spr": "sentinelkrabbe", "loot": 15, "boss": false, "tele": false},
	{"name": "Fehlerqualle", "el": "Elektro", "hp": 85, "move": 1.0, "atk": 2.0, "dmg": 13, "pat": ["cross", "cell"], "spr": "fehlerqualle", "loot": 15, "boss": false, "tele": true},
	# --- Kühlwasser-See (06.10.2026, Index 30–36): Strömung reißt den Spieler mit ---
	{"name": "Kabelaal", "el": "Wasser", "hp": 90, "move": 1.2, "atk": 2.3, "dmg": 12, "pat": ["row", "current"], "spr": "kabelaal", "loot": 13, "boss": false, "tele": true},
	{"name": "Frostkrill", "el": "Wasser", "hp": 55, "move": 0.6, "atk": 1.5, "dmg": 8, "pat": ["cell", "cell", "row"], "spr": "frostkrill", "loot": 13, "boss": false, "tele": false},
	{"name": "Tauchkäfer", "el": "Code", "hp": 145, "move": 2.2, "atk": 2.8, "dmg": 15, "pat": ["col2", "current"], "spr": "tauchkaefer", "loot": 14, "boss": false, "tele": false},
	{"name": "Frostanemone", "el": "Wasser", "hp": 115, "move": 99.0, "atk": 2.2, "dmg": 13, "pat": ["cross", "pop", "cross"], "spr": "frostanemone", "loot": 14, "boss": false, "tele": false, "stationary": true, "pop_kind": "bubble"},
	{"name": "Tiefenschlange", "el": "Wasser", "hp": 560, "move": 1.8, "atk": 2.0, "dmg": 18, "pat": ["row", "current", "col", "cross"], "spr": "tiefenschlange", "title": "Hüterin des Kühlwasser-Sees", "loot": 45, "boss": true, "tele": false, "minion": "current",
		"phase2": ["wall", "current", "col2", "row"], "phase3": ["cross", "current", "wall", "col2"],
		"specials": [{"shape": "wave", "name": "Sturzflut"}, {"shape": "ring", "name": "Flutring"}]},
	{"name": "Schraubenrochen", "el": "Wasser", "hp": 330, "move": 1.4, "atk": 2.2, "dmg": 16, "pat": ["row", "current", "cell"], "spr": "schraubenrochen",
		"title": "Der Sog unter der Oberfläche", "loot": 26, "boss": true, "guard": true, "tele": true, "minion": "none",
		"phase2": ["current", "col2", "row"], "specials": [{"shape": "pull", "name": "Sogwirbel"}]},
	{"name": "Frostnarwal", "el": "Code", "hp": 380, "move": 1.6, "atk": 2.2, "dmg": 17, "pat": ["col", "row", "current"], "spr": "frostnarwal",
		"title": "Der Eisbrecher des Sees", "loot": 30, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["col2", "cross", "current", "row"], "specials": [{"shape": "chase", "name": "Eisbohrer"}]},
	# --- Hochspannungs-Steppe (06.10.2026, Index 37–43): Spannungsfelder schaden, laden aber Chips doppelt so schnell ---
	{"name": "Ampereameise", "el": "Elektro", "hp": 70, "move": 0.6, "atk": 1.5, "dmg": 10, "pat": ["cell", "row", "cell"], "spr": "ampereameise", "loot": 15, "boss": false, "tele": false},
	{"name": "Spulenwurm", "el": "Elektro", "hp": 120, "move": 1.6, "atk": 2.4, "dmg": 14, "pat": ["col", "spark"], "spr": "spulenwurm", "loot": 15, "boss": false, "tele": false},
	{"name": "Mastgeier", "el": "Elektro", "hp": 95, "move": 1.0, "atk": 2.0, "dmg": 13, "pat": ["cross", "cell"], "spr": "mastgeier", "loot": 15, "boss": false, "tele": true},
	{"name": "Blitzfarn", "el": "Elektro", "hp": 125, "move": 99.0, "atk": 2.2, "dmg": 14, "pat": ["cross", "spark", "cross"], "spr": "blitzfarn", "loot": 16, "boss": false, "tele": false, "stationary": true},
	{"name": "Donnerkondor", "el": "Elektro", "hp": 650, "move": 1.7, "atk": 1.9, "dmg": 19, "pat": ["row", "spark", "col2", "cross"], "spr": "donnerkondor", "title": "Herr der Hochspannungs-Steppe", "loot": 55, "boss": true, "tele": true, "minion": "spark",
		"phase2": ["cross", "spark", "wall", "col"], "phase3": ["col2", "spark", "cross", "wall"],
		"specials": [{"shape": "checker", "name": "Gewitterfront"}, {"shape": "chase", "name": "Himmelsriss"}]},
	{"name": "Donnerbock", "el": "Elektro", "hp": 400, "move": 1.3, "atk": 2.1, "dmg": 17, "pat": ["row", "spark", "col"], "spr": "donnerbock",
		"title": "Der Hornsturm der Steppe", "loot": 34, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["wall", "spark", "row"], "specials": [{"shape": "sweep", "name": "Hornsturm"}]},
	{"name": "Trafokäfer", "el": "Code", "hp": 460, "move": 1.6, "atk": 2.1, "dmg": 18, "pat": ["col2", "spark", "row"], "spr": "trafokaefer",
		"title": "Das Umspannwerk auf Beinen", "loot": 38, "boss": true, "guard": true, "tele": false, "minion": "none",
		"phase2": ["cross", "spark", "col2", "wall"], "specials": [{"shape": "ring", "name": "Kurzschlusskreis"}]},
]

## Zähigkeit aller Gegner im Run (08.10.2026, Game-Design-Analyse): Vorher starben normale Gegner nach 3–8 s,
## oft vor ihrem ersten Angriff. Gemessen mit dem „Mensch“-Bot (game/tools/balance_sim.tscn).
## Als static var, damit die Balancing-Simulation sie zum Ausprobieren verstellen kann (--set=FOE_DMG:1.4)
static var FOE_HP := 2.5
static var BOSS_HP := 1.3      # Wächter und Bosse zusätzlich, damit man alle Phasen erlebt
static var FOE_DMG := 1.25     # Gegnerschaden
static var FOE_TEMPO := 0.85   # Angriffstakt (kleiner = öfter)

## Zonen: Gegner-Pools (Indizes in FOES), Boss, Wächter (einer davon je Run), Hintergrund. Jede Zone hat 2 Ebenen à 4 Etagen
## (ZoneMap) und ist ein Akt der Reise (ACTS). „unlock“ stammt aus der Zeit, als jede Zone ein eigener Run war.
const ZONES := {
	"wiesen": {"name": "Cache-Wiesen", "bg": "wiesen", "boss": 3, "guards": [18, 19],
		"early": [0, 1, 5], "late": [0, 1, 2, 4, 5], "elite": [2, 4, 5],
		"desc": "Grüne Datenwiesen. Das Startgebiet.", "unlock": ""},
	"vulkan": {"name": "Firewall-Vulkan", "bg": "vulkan", "boss": 10, "guards": [20, 21],
		"early": [7, 9, 25], "late": [7, 8, 9, 6, 25], "elite": [8, 6, 25],
		"desc": "Glühende Sicherheitsmauern. Wasser hat hier einen Vorteil.", "unlock": "wiesen"},
	"see": {"name": "Kühlwasser-See", "bg": "see", "boss": 34, "guards": [35, 36],
		"early": [30, 31, 33], "late": [30, 31, 32, 33], "elite": [32, 33, 30],
		"desc": "Der riesige Kühlsee unter dem Server. Strömungen reißen dich mit. Code hat hier einen Vorteil.", "unlock": "vulkan"},
	"sumpf": {"name": "Viren-Sümpfe", "bg": "sumpf", "boss": 14, "guards": [22, 23],
		"early": [11, 26, 27], "late": [11, 12, 13, 26, 27], "elite": [12, 13, 26],
		"desc": "Blubbernde Sümpfe voller Viren und Glitch-Sporen. Elektro hat hier einen Vorteil.", "unlock": "see"},
	"steppe": {"name": "Hochspannungs-Steppe", "bg": "steppe", "boss": 41, "guards": [42, 43],
		"early": [37, 38, 39], "late": [37, 38, 39, 40], "elite": [38, 40, 39],
		"desc": "Grasland unter Dauergewitter. Spannungsfelder kosten HP, laden deine Chips aber doppelt so schnell. Virus hat hier einen Vorteil.", "unlock": "sumpf"},
	"kern": {"name": "NEST-Kern", "bg": "kern", "boss": 17, "guards": [24], "final": true,
		"early": [15, 16, 29], "late": [15, 16, 28, 29], "elite": [15, 28, 29],
		"desc": "Das Herz des abgestürzten Servers. Kurz, hart – und am Ende wartet der Ur-Glitch.", "unlock": "steppe"},
}
## Glitch-Protokolle (07.10.2026): Endgame nach dem Abspann. Stufen bauen aufeinander auf, jede gibt +5 % Fragmente.
const PROTOCOLS := [
	{"name": "Zähe Daten", "desc": "Gegner +15 % HP"},
	{"name": "Kurze Rast", "desc": "Rastplätze heilen nur halb so viel"},
	{"name": "Unruhe", "desc": "Gegner greifen 10 % schneller an"},
	{"name": "Knappe Kasse", "desc": "Händlerpreise +25 %"},
	{"name": "Starke Wächter", "desc": "Wächter und Bosse +20 % HP"},
	{"name": "Hektik", "desc": "Warnungen 0,1 s kürzer"},
	{"name": "Angeschlagen", "desc": "Start mit 15 % weniger max. HP"},
	{"name": "Harte Treffer", "desc": "Gegner verursachen +15 % Schaden"},
	{"name": "Zähe Flächen", "desc": "Lava, Schleim, Strömung und Spannungsfelder halten 50 % länger"},
	{"name": "Glitch-Sturm", "desc": "Großangriffe kommen 30 % öfter"},
]
const ZONE_ORDER := ["wiesen", "vulkan", "see", "sumpf", "steppe", "kern"]

## ---------- Reise (08.10.2026, Game-Design-Analyse) ----------
## Ein Run führt durch mehrere Zonen: Akt 1 Cache-Wiesen, Akt 2 Vulkan oder See, Akt 3 Sümpfe oder Steppe,
## Finale NEST-Kern. Deck, Module, HP und Evolution bleiben über den ganzen Run. Nach jedem Zonen-Boss wählt man
## die nächste Zone. Die Zähigkeit der Gegner hängt vom Akt ab, nicht mehr von der Zone.
const ACTS := [["wiesen"], ["vulkan", "see"], ["sumpf", "steppe"], ["kern"]]
static var ACT_HP := [1.0, 1.4, 1.85, 2.3]      # normale Gegner je Akt
static var ACT_DMG := [1.0, 1.2, 1.4, 1.6]      # Schaden normaler Gegner je Akt
const ACT_HEAL := 0.4                       # Erholung zwischen zwei Akten (Anteil der max. HP)


## Akt einer Zone (0 = Cache-Wiesen … 3 = NEST-Kern)
static func act_of(zone: String) -> int:
	for i in ACTS.size():
		if ACTS[i].has(zone):
			return i
	return 0
## Elemente, durch die der Ur-Glitch wechselt
const SHIFT_ELEMENTS := ["Virus", "Feuer", "Wasser", "Elektro", "Code"]

## Gegner-Pools der Cache-Wiesen (Indizes in FOES); allgemein siehe ZONES
const POOL_EARLY := [0, 1, 5]
const POOL_LATE := [0, 1, 2, 4, 5, 6]
const POOL_ELITE := [2, 4, 6]

## Spielbare Linien (Baby-Werte). evo: Element der meistgespielten Chips → Rookie.
const MONS := {
	"Pixmiez": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Katze",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Heilpatch", "Krallenwirbel", "Firewall", "Virusspritzer", "Blitzcursor"],
		"passive": "Katzenreflex", "passive_desc": "Weicht dem ersten Treffer jedes Kampfes aus (ab Champion: den ersten zwei).",
		"trait": "Allrounder. Guter Einstieg.",
		"evo": {"Code": "Firewallo", "Virus": "Virulina", "Elektro": "Prismiez"},
	},
	"Funkling": {
		"hp": 80, "move": 0.12, "rech": 1.1, "el": "Feuer", "animal": "Welpe",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Sprungantrieb", "Byteschlag", "Stöckchen", "Heilpatch", "Glutball", "Laserschuss"],
		"passive": "Übermut", "passive_desc": "Jeder 3. gespielte Chip halbiert die Ladezeit der anderen Chips auf der Hand.",
		"trait": "Wenig HP, Chips laden 10 % schneller.",
		"evo": {"Feuer": "Glutbyte", "Code": "Overclocko"},
	},
	"Tröpfel": {
		"hp": 120, "move": 0.18, "rech": 1.0, "el": "Wasser", "animal": "Axolotl",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Kiemenatmung", "Wasserstrahl", "Firewall"],
		"passive": "Regeneration", "passive_desc": "Heilt 1 HP pro Sekunde, wenn es 3 s nicht getroffen wurde (ab Champion: 2 HP).",
		"trait": "Viel HP, bewegt sich langsamer.",
		"evo": {"Wasser": "Kaskadi", "Code": "Pufferling"}, "ice": "Frostbyte",
	},
	# --- Weitere Linien aus dem Prototyp (Phase 3b, 29.09.2026), kommen aus Eiern ---
	"Kekso": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Hamster",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Backenvorrat", "Byteschlag", "Byteschlag", "Heilpatch", "Bug-Mine", "Blitzcursor"],
		"passive": "Hamstern", "passive_desc": "25 % Chance: Ein gespielter Chip wird gehamstert und kommt gleich wieder.",
		"trait": "Hamstert Chips und legt Minen.",
		"evo": {"Virus": "Tracko", "Elektro": "Cachy"},
	},
	"Lumi": {
		"hp": 85, "move": 0.1, "rech": 1.05, "el": "Elektro", "animal": "Hase",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Doppelklick", "Byteschlag", "Hakenschlag", "Heilpatch", "Blitzcursor", "Wasserstrahl"],
		"passive": "Hasenhaken", "passive_desc": "Bewegt sich doppelt so schnell.",
		"trait": "Flink. Blitz-Angriffe treffen immer.",
		"evo": {"Elektro": "Blinki", "Wasser": "Perlhopp"},
	},
	"Quakli": {
		"hp": 95, "move": 0.12, "rech": 1.0, "el": "Virus", "animal": "Frosch",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Zungenzug", "Byteschlag", "Byteschlag", "Heilpatch", "Virusspritzer", "Firewall"],
		"passive": "Giftbaut", "passive_desc": "Wer Quakli trifft, wird selbst vergiftet.",
		"trait": "Vergiftet Gegner und legt Minen.",
		"evo": {"Virus": "Virulurch", "Code": "Hüpfbyte"},
	},
	"Molchi": {
		"hp": 90, "move": 0.11, "rech": 1.0, "el": "Virus", "animal": "Salamander",
		"deck": ["Pixelstrahl", "Hautgift", "Sprungantrieb", "Byteschlag", "Byteschlag", "Heilpatch", "Virusspritzer", "Glutball"],
		"passive": "Giftdrüsen", "passive_desc": "Gift und Brand auf dem Gegner wirken 50 % stärker.",
		"trait": "Flinker Gift-Salamander.",
		"evo": {"Virus": "Toxmolch", "Feuer": "Magmolch"},
	},
	"Brummbit": {
		"hp": 140, "move": 0.2, "rech": 1.05, "el": "Neutral", "animal": "Bär",
		"deck": ["Byteschlag", "Byteschlag", "Bärenhieb", "Pixelstrahl", "Pixelstrahl", "Heilpatch", "Virusspritzer", "Firewall"],
		"passive": "Dickes Fell", "passive_desc": "Nimmt 25 % weniger Schaden.",
		"trait": "Tank. Viel HP, langsam, steckt viel weg.",
		"evo": {"Virus": "Pilzbrumm", "Code": "Bärtron"},
	},
	"Kauzbit": {
		"hp": 90, "move": 0.12, "rech": 1.0, "el": "Code", "animal": "Robo-Eule",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Eulenauge", "Byteschlag", "Byteschlag", "Heilpatch", "Laserschuss", "Glutball"],
		"passive": "Eulenblick", "passive_desc": "Sieht Angriffe früher: Warnungen erscheinen 0,3 s eher.",
		"trait": "Robo-Eule mit Adleraugen.",
		"evo": {"Code": "Optikauz", "Feuer": "Raketauz"},
	},
	# --- Neue Linien 29.09.2026: Dachs und Waschbär ---
	"Buddli": {
		"hp": 115, "move": 0.15, "rech": 1.0, "el": "Neutral", "animal": "Dachs",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Byteschlag", "Graben", "Heilpatch", "Glutball", "Blitzcursor"],
		"passive": "Furchtlos", "passive_desc": "Unter 30 % HP machen Chip-Treffer 50 % mehr Schaden.",
		"trait": "Zäh und furchtlos. Je knapper es wird, desto härter schlägt es zu.",
		"evo": {"Feuer": "Glimmdachs", "Elektro": "Zackdachs"},
	},
	"Maskli": {
		"hp": 90, "move": 0.11, "rech": 1.05, "el": "Neutral", "animal": "Waschbär",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Stibitzen", "Byteschlag", "Heilpatch", "Sprungantrieb", "Wasserstrahl", "Virusspritzer"],
		"passive": "Langfinger", "passive_desc": "Jeder 4. Chip-Treffer klaut Ladung: ein Chip auf der Hand ist sofort bereit.",
		"trait": "Flinker kleiner Dieb mit Maske.",
		"evo": {"Wasser": "Plätschbär", "Virus": "Klaubär"},
	},
	# --- Neue Linien 03.10.2026: Otter und Ara ---
	"Bachli": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Neutral", "animal": "Otter",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Kieselwurf", "Wasserstrahl", "Blitzcursor", "Heilpatch", "Sprungantrieb"],
		"passive": "Teamgeist", "passive_desc": "Support-Chips laden 25 % schneller.",
		"trait": "Verspielter Otter, der immer auf sein Team aufpasst.",
		"evo": {"Wasser": "Strudli", "Elektro": "Knisterli"},
	},
	"Plapperli": {
		"hp": 85, "move": 0.11, "rech": 1.0, "el": "Neutral", "animal": "Ara",
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Echoruf", "Glutball", "Blitzcursor", "Heilpatch", "Sprungantrieb"],
		"passive": "Nachplappern", "passive_desc": "Jeder 4. Angriffs-Chip wird nach 0,5 s nachgeplappert (halber Schaden).",
		"trait": "Bunter Plapper-Ara. Was er einmal gehört hat, wiederholt er.",
		"evo": {"Elektro": "Surrfeder", "Feuer": "Glutfeder"},
	},
	# --- Fusionen (Labor): Endstufe auf Champion-Niveau (+20 HP über die Stufe), keine weitere Evolution ---
	"Wolkerich": {
		"hp": 115, "move": 0.18, "rech": 1.0, "el": "Wasser", "animal": "Axolotl × Hamster", "fusion": true,
		"deck": ["Blubberschild", "Blubberschild", "Wasserstrahl", "Wasserstrahl", "Mini-Bot", "Eisfeld", "Heilpatch", "Firewall"],
		"passive": "Wolkendecke", "passive_desc": "Startet jeden Kampf in einer Schutzblase (30 Schaden, 6 s).",
		"trait": "Fusion. Sehr zäh und gut geschützt.", "evo": {},
	},
	"Wolperling": {
		"hp": 95, "move": 0.09, "rech": 1.05, "el": "Elektro", "animal": "Hase × Eule", "fusion": true,
		"deck": ["Blitzcursor", "Blitzcursor", "Kettenblitz", "Blitzlanze", "Magnetfeld", "Laserschuss", "Heilpatch", "Sprungantrieb"],
		"passive": "Mischwesen", "passive_desc": "Hase und Eule: bewegt sich doppelt so schnell und sieht Angriffe 0,3 s früher.",
		"trait": "Fusion. Ein Wolpertinger: flink und wachsam.", "evo": {},
	},
	"Schlummerbit": {
		"hp": 130, "move": 0.18, "rech": 1.0, "el": "Elektro", "animal": "Bär × Hamster", "fusion": true,
		"deck": ["Byteschlag", "Byteschlag", "Blitzcursor", "Kettenblitz", "Blendgranate", "Heilpatch", "Firewall", "Bug-Mine"],
		"passive": "Winterschlaf", "passive_desc": "Dickes Fell und volle Backen: nimmt 25 % weniger Schaden, 25 % Chance, einen Chip zu hamstern.",
		"trait": "Fusion. Schwebt schlafend durch seine Träume.", "evo": {},
	},
	"Pustebacke": {
		"hp": 90, "move": 0.1, "rech": 1.0, "el": "Virus", "animal": "Hamster × Frosch", "fusion": true,
		"deck": ["Virusspritzer", "Virusspritzer", "Sporenfalle", "Seuche", "Bug-Mine", "Pixelstrahl", "Heilpatch", "Sprungantrieb"],
		"passive": "Schwebegas", "passive_desc": "Schwebt: weicht 15 % der Treffer aus. Wer trifft, wird vergiftet.",
		"trait": "Fusion. Kugelrund, voller Giftgas und völlig chaotisch.", "evo": {},
	},
	"Spukatz": {
		"hp": 70, "move": 0.1, "rech": 1.0, "el": "Virus", "animal": "Katze × Frosch", "fusion": true,
		"deck": ["Virusspritzer", "Virusspritzer", "Bug-Mine", "Bug-Mine", "Blitzcursor", "Pixelstrahl", "Heilpatch", "Blubberschild"],
		"passive": "Spuk", "passive_desc": "Weicht 20 % aller Treffer aus.",
		"trait": "Fusion. Halb Geist, halb Katze.", "evo": {},
	},
	# --- Legendäre (07.10.2026): je Zone ein Fabelwesen, schlüpfen als Champion, Ultra ab EVO_AT[4] Element-Chips ---
	"Glimmhirsch": {
		"hp": 110, "move": 0.11, "rech": 1.0, "el": "Neutral", "animal": "Hirsch", "legend": true,
		"deck": ["Pixelstrahl", "Pixelstrahl", "Byteschlag", "Doppelklick", "Blitzcursor", "Wasserstrahl", "Heilpatch", "Firewall"],
		"passive": "Lichtschein", "passive_desc": "Heilt alle 6 s 4 HP, auch mitten im Kampf.",
		"trait": "Legendär. Ein Hirsch aus Licht, der sich nur den Jüngsten zeigt.", "evo": {},
	},
	"Glutkirin": {
		"hp": 105, "move": 0.11, "rech": 1.0, "el": "Feuer", "animal": "Kirin", "legend": true,
		"deck": ["Glutball", "Glutball", "Flammenwelle", "Glutklinge", "Funkenregen", "Byteschlag", "Heilpatch", "Hitzeschild"],
		"passive": "Glutmähne", "passive_desc": "Wer den Kirin trifft, fängt Feuer.",
		"trait": "Legendär. Ein Drachenpferd aus dem Herzen des Vulkans.", "evo": {},
	},
	"Sternwal": {
		"hp": 125, "move": 0.17, "rech": 1.0, "el": "Wasser", "animal": "Wal", "legend": true,
		"deck": ["Wasserstrahl", "Wasserstrahl", "Flutwelle", "Frostsplitter", "Tsunami", "Pixelstrahl", "Heilpatch", "Blubberschild"],
		"passive": "Sternenmeer", "passive_desc": "Schwebt über allem: Lava, Schleim, Strömung und Spannungsfelder wirken nicht.",
		"trait": "Legendär. Ein Wal, der zwischen den Sternen schwimmt.", "evo": {},
	},
	"Toxilisk": {
		"hp": 105, "move": 0.12, "rech": 1.0, "el": "Virus", "animal": "Basilisk", "legend": true,
		"deck": ["Virusspritzer", "Virusspritzer", "Seuche", "Sporenfalle", "Bug-Mine", "Parasit", "Heilpatch", "Firewall"],
		"passive": "Bannblick", "passive_desc": "Sein Blick lähmt: Gegner greifen 15 % langsamer an.",
		"trait": "Legendär. Wer ihm in die Augen sieht, erstarrt.", "evo": {},
	},
	"Funkengreif": {
		"hp": 100, "move": 0.12, "rech": 1.0, "el": "Elektro", "animal": "Greif", "legend": true,
		"deck": ["Blitzcursor", "Blitzcursor", "Kettenblitz", "Blitzlanze", "Kurzschluss", "Magnetfeld", "Heilpatch", "Ladungsfeld"],
		"passive": "Sturmschwingen", "passive_desc": "Bewegt sich doppelt so schnell.",
		"trait": "Legendär. Halb Adler, halb Löwe, ganz Gewitter.", "evo": {},
	},
	"Chiffrasphinx": {
		"hp": 115, "move": 0.13, "rech": 1.0, "el": "Code", "animal": "Sphinx", "legend": true,
		"deck": ["Pixelstrahl", "Laserschuss", "Debugger", "Datenfresser", "Mini-Bot", "Geschützturm", "Heilpatch", "Kopierschutz"],
		"passive": "Rätselwächter", "passive_desc": "Jeder 3. Treffer prallt an ihr ab.",
		"trait": "Legendär. Die Hüterin der Rätsel im NEST-Kern.", "evo": {},
	},
}

## Fusionsrezepte (Linien, egal welche Stufe). need_form: eine bestimmte Form muss dabei sein.
const RECIPES := [
	{"a": "Kekso", "b": "Brummbit", "r": "Schlummerbit", "hint": "Zwei Winterschläfer, die gemeinsam träumen … vielleicht sogar von den Sternen."},
	{"a": "Tröpfel", "b": "Kekso", "r": "Wolkerich", "hint": "Ein Tropfen und ein Keks, der sich alles merkt, werden zu einer Wolke voller Daten."},
	{"a": "Lumi", "b": "Kauzbit", "r": "Wolperling", "hint": "Ein Hase, der fliegen will, und eine Eule, die hüpfen will. Aus alten Sagen bekannt."},
	{"a": "Kekso", "b": "Quakli", "r": "Pustebacke", "hint": "Volle Backen und eine Schallblase. Was passiert, wenn beide gleichzeitig aufpusten?"},
	{"a": "Quakli", "b": "Pixmiez", "r": "Spukatz", "need_form": "Virulina", "hint": "Ein Giftfrosch und ein Kätzchen … aber nur, wenn die Katze selbst Gift im Blut hat."},
]
const FUSION_COST := 100

## Legendäre: je Zone ein Fabelwesen mit geheimer Bedingung beim Sieg über den Zonen-Boss.
## Erfüllt: ein leuchtendes Ei im Brutnest (schlüpft nach 1 Run). Gerüchte stehen im Monsterdex.
const LEGENDS := {
	"Glimmhirsch": {"zone": "wiesen", "cond": "baby",
		"rumor": "Ein Hirsch aus Licht soll sich zeigen, wenn ein ganz junger Glitchling den Herrscher der Wiesen bezwingt."},
	"Glutkirin": {"zone": "vulkan", "cond": "fire6",
		"rumor": "Im Vulkan wartet ein Wesen aus Glut auf jemanden, dessen Deck selbst lichterloh brennt."},
	"Sternwal": {"zone": "see", "cond": "nopush",
		"rumor": "Der Sternwal kommt nur zu denen, die sich im See von keiner Strömung mitreißen lassen."},
	"Toxilisk": {"zone": "sumpf", "cond": "noheal",
		"rumor": "Der Blick des Basilisken prüft, wer die Königin des Sumpfs ganz ohne Heilpatch besiegt."},
	"Funkengreif": {"zone": "steppe", "cond": "spark10",
		"rumor": "Wer im Kampf gegen den Donnerkondor lange auf geladenem Boden ausharrt, dem erscheint der Greif."},
	"Chiffrasphinx": {"zone": "kern", "cond": "sigkill",
		"rumor": "Die Sphinx verlangt: Der letzte Schlag gegen den Ur-Glitch muss deine Signatur-Attacke sein."},
}
## Ultra-Form → zugehöriger Legendärer (für Dex und Gerüchte)
static func legend_of(form: String) -> String:
	if LEGENDS.has(form):
		return form
	for L in LEGENDS:
		if FORMS[L].up == form:
			return L
	return ""

## Alle Formen: Sprite-Datei, Stufe (1 Baby, 2 Rookie, 3 Champion), Element, nächste Stufe
const FORMS := {
	"Pixmiez": {"spr": "pixi_32", "stage": 1, "el": "Neutral", "up": ""},
	"Funkling": {"spr": "funk_32", "stage": 1, "el": "Feuer", "up": ""},
	"Tröpfel": {"spr": "drop_32", "stage": 1, "el": "Wasser", "up": ""},
	"Firewallo": {"spr": "Firewallo_64", "stage": 2, "el": "Code", "up": "Bollwerkatz"},
	"Virulina": {"spr": "Virulina_64", "stage": 2, "el": "Virus", "up": "Toxipanth"},
	"Prismiez": {"spr": "Prismiez_64", "stage": 2, "el": "Elektro", "up": "Prismalynx"},
	"Glutbyte": {"spr": "Glutbyte_64", "stage": 2, "el": "Feuer", "up": "Magmawulf"},
	"Overclocko": {"spr": "Overclocko_64", "stage": 2, "el": "Code", "up": "Turbowulf"},
	"Kaskadi": {"spr": "Kaskadi_64", "stage": 2, "el": "Wasser", "up": "Tsunamander"},
	"Pufferling": {"spr": "Pufferling_64", "stage": 2, "el": "Code", "up": "Panzerpuff"},
	"Frostbyte": {"spr": "Frostbyte_64", "stage": 2, "el": "Wasser", "up": "Glaziolotl"},
	"Bollwerkatz": {"spr": "Bollwerkatz_80", "stage": 3, "el": "Code", "up": "Bastionkatz"},
	"Magmawulf": {"spr": "Magmawulf_80", "stage": 3, "el": "Feuer", "up": "Glutfenrir"},
	"Turbowulf": {"spr": "Turbowulf_80", "stage": 3, "el": "Code", "up": "Hyperwulf"},
	"Tsunamander": {"spr": "Tsunamander_80", "stage": 3, "el": "Wasser", "up": "Leviamander"},
	"Panzerpuff": {"spr": "Panzerpuff_80", "stage": 3, "el": "Code", "up": "Kolosspuff"},
	"Kekso": {"spr": "Kekso_32", "stage": 1, "el": "Neutral", "up": ""},
	"Tracko": {"spr": "Tracko_64", "stage": 2, "el": "Virus", "up": "Schattnager"},
	"Cachy": {"spr": "Cachy_64", "stage": 2, "el": "Elektro", "up": "Glanzbacke"},
	"Lumi": {"spr": "Lumi_32", "stage": 1, "el": "Elektro", "up": ""},
	"Blinki": {"spr": "Blinki_64", "stage": 2, "el": "Elektro", "up": "Strahlhase"},
	"Quakli": {"spr": "Quakli_32", "stage": 1, "el": "Virus", "up": ""},
	"Virulurch": {"spr": "Virulurch_64", "stage": 2, "el": "Virus", "up": "Toxikröt"},
	"Hüpfbyte": {"spr": "Huepfbyte_64", "stage": 2, "el": "Code", "up": "Mechaquak"},
	"Mechaquak": {"spr": "Mechaquak_80", "stage": 3, "el": "Code", "up": "Gigaquak"},
	"Molchi": {"spr": "Molchi_32", "stage": 1, "el": "Virus", "up": ""},
	"Toxmolch": {"spr": "Toxmolch_64", "stage": 2, "el": "Virus", "up": "Sumpfdrak"},
	"Magmolch": {"spr": "Magmolch_64", "stage": 2, "el": "Feuer", "up": "Lavadrak"},
	"Brummbit": {"spr": "Brummbit_32", "stage": 1, "el": "Neutral", "up": ""},
	"Bärtron": {"spr": "Baertron_64", "stage": 2, "el": "Code", "up": "Titanbrumm"},
	"Titanbrumm": {"spr": "Titanbrumm_80", "stage": 3, "el": "Code", "up": "Kolossbrumm"},
	"Kauzbit": {"spr": "Kauzbit_32", "stage": 1, "el": "Code", "up": ""},
	"Optikauz": {"spr": "Optikauz_64", "stage": 2, "el": "Code", "up": "Radarkauz"},
	"Raketauz": {"spr": "Raketauz_64", "stage": 2, "el": "Feuer", "up": "Phönixkauz"},
	"Radarkauz": {"spr": "Radarkauz_80", "stage": 3, "el": "Code", "up": "Orbitkauz"},
	"Wolkerich": {"spr": "Wolkerich_80", "stage": 3, "el": "Wasser", "up": ""},
	"Spukatz": {"spr": "Spukatz_80", "stage": 3, "el": "Virus", "up": ""},
	"Glimmhirsch": {"spr": "Glimmhirsch_80", "stage": 3, "el": "Neutral", "up": "Lumicervus"},
	"Glutkirin": {"spr": "Glutkirin_80", "stage": 3, "el": "Feuer", "up": "Pyrokirin"},
	"Sternwal": {"spr": "Sternwal_80", "stage": 3, "el": "Wasser", "up": "Astralwal"},
	"Toxilisk": {"spr": "Toxilisk_80", "stage": 3, "el": "Virus", "up": "Miasmalisk"},
	"Funkengreif": {"spr": "Funkengreif_80", "stage": 3, "el": "Elektro", "up": "Donnergryph"},
	"Chiffrasphinx": {"spr": "Chiffrasphinx_80", "stage": 3, "el": "Code", "up": "Algosphinx"},
	"Lumicervus": {"spr": "Lumicervus_96", "stage": 4, "el": "Neutral", "up": ""},
	"Pyrokirin": {"spr": "Pyrokirin_96", "stage": 4, "el": "Feuer", "up": ""},
	"Astralwal": {"spr": "Astralwal_96", "stage": 4, "el": "Wasser", "up": ""},
	"Miasmalisk": {"spr": "Miasmalisk_96", "stage": 4, "el": "Virus", "up": ""},
	"Donnergryph": {"spr": "Donnergryph_96", "stage": 4, "el": "Elektro", "up": ""},
	"Algosphinx": {"spr": "Algosphinx_96", "stage": 4, "el": "Code", "up": ""},
	"Wolperling": {"spr": "Wolperling_80", "stage": 3, "el": "Elektro", "up": ""},
	"Schlummerbit": {"spr": "Schlummerbit_80", "stage": 3, "el": "Elektro", "up": ""},
	# --- Dachs ---
	"Buddli": {"spr": "Buddli_32", "stage": 1, "el": "Neutral", "up": ""},
	"Glimmdachs": {"spr": "Glimmdachs_64", "stage": 2, "el": "Feuer", "up": "Magmadachs"},
	"Magmadachs": {"spr": "Magmadachs_80", "stage": 3, "el": "Feuer", "up": "Pyromeles"},
	"Pyromeles": {"spr": "Pyromeles_96", "stage": 4, "el": "Feuer", "up": ""},
	"Zackdachs": {"spr": "Zackdachs_64", "stage": 2, "el": "Elektro", "up": "Donnerdachs"},
	"Donnerdachs": {"spr": "Donnerdachs_80", "stage": 3, "el": "Elektro", "up": "Voltameles"},
	"Voltameles": {"spr": "Voltameles_96", "stage": 4, "el": "Elektro", "up": ""},
	# --- Waschbär ---
	"Maskli": {"spr": "Maskli_32", "stage": 1, "el": "Neutral", "up": ""},
	"Plätschbär": {"spr": "Plaetschbaer_64", "stage": 2, "el": "Wasser", "up": "Flutmaske"},
	"Flutmaske": {"spr": "Flutmaske_80", "stage": 3, "el": "Wasser", "up": "Hydrocyon"},
	"Hydrocyon": {"spr": "Hydrocyon_96", "stage": 4, "el": "Wasser", "up": ""},
	"Klaubär": {"spr": "Klaubaer_64", "stage": 2, "el": "Virus", "up": "Nachtmaske"},
	"Nachtmaske": {"spr": "Nachtmaske_80", "stage": 3, "el": "Virus", "up": "Virocyon"},
	"Virocyon": {"spr": "Virocyon_96", "stage": 4, "el": "Virus", "up": ""},
	# --- Otter ---
	"Bachli": {"spr": "Bachli_32", "stage": 1, "el": "Neutral", "up": ""},
	"Strudli": {"spr": "Strudli_64", "stage": 2, "el": "Wasser", "up": "Wogotter"},
	"Wogotter": {"spr": "Wogotter_80", "stage": 3, "el": "Wasser", "up": "Hydrolutra"},
	"Hydrolutra": {"spr": "Hydrolutra_96", "stage": 4, "el": "Wasser", "up": ""},
	"Knisterli": {"spr": "Knisterli_64", "stage": 2, "el": "Elektro", "up": "Lutrion"},
	"Lutrion": {"spr": "Lutrion_80", "stage": 3, "el": "Elektro", "up": "Fulgurlutra"},
	"Fulgurlutra": {"spr": "Fulgurlutra_96", "stage": 4, "el": "Elektro", "up": ""},
	# --- Ara ---
	"Plapperli": {"spr": "Plapperli_32", "stage": 1, "el": "Neutral", "up": ""},
	"Surrfeder": {"spr": "Surrfeder_64", "stage": 2, "el": "Elektro", "up": "Sturmschwinge"},
	"Sturmschwinge": {"spr": "Sturmschwinge_80", "stage": 3, "el": "Elektro", "up": "Fulgopsitta"},
	"Fulgopsitta": {"spr": "Fulgopsitta_96", "stage": 4, "el": "Elektro", "up": ""},
	"Glutfeder": {"spr": "Glutfeder_64", "stage": 2, "el": "Feuer", "up": "Flammschwinge"},
	"Flammschwinge": {"spr": "Flammschwinge_80", "stage": 3, "el": "Feuer", "up": "Heliopsitta"},
	"Heliopsitta": {"spr": "Heliopsitta_96", "stage": 4, "el": "Feuer", "up": ""},
	"Pustebacke": {"spr": "Pustebacke_80", "stage": 3, "el": "Virus", "up": ""},
	# --- Neue Linien 29.09.2026: Brummbit Gift, Lumi Wasser ---
	"Pilzbrumm": {"spr": "Pilzbrumm_64", "stage": 2, "el": "Virus", "up": "Sporenpranke"},
	"Sporenpranke": {"spr": "Sporenpranke_80", "stage": 3, "el": "Virus", "up": "Myzelgrizz"},
	"Myzelgrizz": {"spr": "Myzelgrizz_96", "stage": 4, "el": "Virus", "up": ""},
	"Perlhopp": {"spr": "Perlhopp_64", "stage": 2, "el": "Wasser", "up": "Gischthase"},
	"Gischthase": {"spr": "Gischthase_80", "stage": 3, "el": "Wasser", "up": "Lunaflut"},
	"Lunaflut": {"spr": "Lunaflut_96", "stage": 4, "el": "Wasser", "up": ""},
	# --- Champions (PixelLab, 29.09.2026) ---
	"Toxipanth": {"spr": "Toxipanth_80", "stage": 3, "el": "Virus", "up": "Venomynx"},
	"Prismalynx": {"spr": "Prismalynx_80", "stage": 3, "el": "Elektro", "up": "Aurorlynx"},
	"Glaziolotl": {"spr": "Glaziolotl_80", "stage": 3, "el": "Wasser", "up": "Kryolotl"},
	"Schattnager": {"spr": "Schattnager_80", "stage": 3, "el": "Virus", "up": "Phantomnager"},
	"Glanzbacke": {"spr": "Glanzbacke_80", "stage": 3, "el": "Elektro", "up": "Stellarbacke"},
	"Strahlhase": {"spr": "Strahlhase_80", "stage": 3, "el": "Elektro", "up": "Plasmahase"},
	"Toxikröt": {"spr": "Toxikroet_80", "stage": 3, "el": "Virus", "up": "Miasmakröt"},
	"Sumpfdrak": {"spr": "Sumpfdrak_80", "stage": 3, "el": "Virus", "up": "Hydradrak"},
	"Lavadrak": {"spr": "Lavadrak_80", "stage": 3, "el": "Feuer", "up": "Vulkandrak"},
	"Phönixkauz": {"spr": "Phoenixkauz_80", "stage": 3, "el": "Feuer", "up": "Infernokauz"},
	# --- Ultras (96 px, Stufe 4, ab EVO_AT[4] Element-Chips) ---
	"Bastionkatz": {"spr": "Bastionkatz_96", "stage": 4, "el": "Code", "up": ""},
	"Venomynx": {"spr": "Venomynx_96", "stage": 4, "el": "Virus", "up": ""},
	"Aurorlynx": {"spr": "Aurorlynx_96", "stage": 4, "el": "Elektro", "up": ""},
	"Glutfenrir": {"spr": "Glutfenrir_96", "stage": 4, "el": "Feuer", "up": ""},
	"Hyperwulf": {"spr": "Hyperwulf_96", "stage": 4, "el": "Code", "up": ""},
	"Leviamander": {"spr": "Leviamander_96", "stage": 4, "el": "Wasser", "up": ""},
	"Kolosspuff": {"spr": "Kolosspuff_96", "stage": 4, "el": "Code", "up": ""},
	"Kryolotl": {"spr": "Kryolotl_96", "stage": 4, "el": "Wasser", "up": ""},
	"Phantomnager": {"spr": "Phantomnager_96", "stage": 4, "el": "Virus", "up": ""},
	"Stellarbacke": {"spr": "Stellarbacke_96", "stage": 4, "el": "Elektro", "up": ""},
	"Plasmahase": {"spr": "Plasmahase_96", "stage": 4, "el": "Elektro", "up": ""},
	"Miasmakröt": {"spr": "Miasmakroet_96", "stage": 4, "el": "Virus", "up": ""},
	"Gigaquak": {"spr": "Gigaquak_96", "stage": 4, "el": "Code", "up": ""},
	"Hydradrak": {"spr": "Hydradrak_96", "stage": 4, "el": "Virus", "up": ""},
	"Vulkandrak": {"spr": "Vulkandrak_96", "stage": 4, "el": "Feuer", "up": ""},
	"Kolossbrumm": {"spr": "Kolossbrumm_96", "stage": 4, "el": "Code", "up": ""},
	"Infernokauz": {"spr": "Infernokauz_96", "stage": 4, "el": "Feuer", "up": ""},
	"Orbitkauz": {"spr": "Orbitkauz_96", "stage": 4, "el": "Code", "up": ""},
}

const STAGE_NAMES := ["", "Baby", "Rookie", "Champion", "Ultra"]

## Lebenszeit-Prägung (gespielte Element-Chips über alle Runs), ab der die nächste Stufe erreicht wird.
## Seit der Reise (08.10.2026) spielt man pro Run 300–800 Element-Chips: Rookie meist noch im ersten Akt des ersten Runs,
## Champion nach etwa 2 Runs, Ultra nach etwa 5 Runs (vorher 12/35/80, da war Ultra nach 2–3 kurzen Zonen-Runs erreicht).
static var EVO_AT := {2: 15, 3: 200, 4: 550}   # 09.10.2026 (Spieltest, mehrfach „dauert zu lange“): vorher 25/900/2700, dann 18/650/1950, 15/200/800. Champion in der 1. Reise, Ultra in der 2.
## Kette (09.10.2026, Produzent): Angriffs-Chips desselben Elements hintereinander machen mehr Schaden, bis 4-fach.
## Neutrale Chips und Support zählen nicht und unterbrechen nicht. Ein anderes Element, ein Treffer gegen dich
## oder CHAIN_GAP Sekunden ohne Element-Angriff beenden die Kette.
const CHAIN_MULT := [1.0, 1.5, 2.0, 3.0, 4.0]
const CHAIN_GAP := 4.0
## Betäubte Bosse und Wächter (Konter, eingefroren, überlastet …) nehmen doppelten Schaden (09.10.2026, Produzent)
const STUN_MULT := 2.0


static func chain_mult(n: int) -> float:
	return CHAIN_MULT[clampi(n, 1, CHAIN_MULT.size()) - 1]


## Faktor als Text: x2, x1,5 (Deutsch) bzw. x1.5 (Englisch)
static func mult_text(k: float) -> String:
	return "x%d" % roundi(k) if is_equal_approx(k, roundf(k)) else "x" + T.dec(k)
## Die führende Richtung braucht so viele Chips Vorsprung vor der zweitbesten, sonst wartet die Evolution
const EVO_LEAD := 2

## Signatur-Attacken je Form. Treffer (hits) landen im Abstand von 0,15 s und treffen immer.
## anim: jump (Sprung zum Gegner), row (Welle über die Gegnerreihe), field (ganzes Gegnerfeld), self (auf sich selbst)
const SPECIALS := {
	"Pixmiez": {"name": "Pixelsprung", "el": "Neutral", "anim": "jump", "hits": [40], "desc": "Springt zum Gegner und kratzt: 40 Schaden."},
	"Firewallo": {"name": "Schildsprung", "el": "Code", "anim": "jump", "hits": [35], "shield": 4.0, "desc": "35 Schaden, landet mit Firewall-Schild (4 s)."},
	"Bollwerkatz": {"name": "Bollwerksprung", "el": "Code", "anim": "jump", "hits": [50], "stun": 1.0, "shield": 6.0, "desc": "Mecha-Sprung: 50 Schaden, betäubt 1 s, Firewall-Schild (6 s)."},
	"Virulina": {"name": "Giftkralle", "el": "Virus", "anim": "jump", "hits": [35], "poison": 6, "desc": "35 Schaden + starkes Gift."},
	"Prismiez": {"name": "Prismasprung", "el": "Elektro", "anim": "jump", "hits": [40], "heal": 20, "desc": "40 Schaden und heilt 20 HP."},
	"Funkling": {"name": "Funkenbiss", "el": "Feuer", "anim": "jump", "hits": [14, 14, 14], "desc": "Drei schnelle Funkenbisse à 14."},
	"Glutbyte": {"name": "Glutbiss", "el": "Feuer", "anim": "jump", "hits": [18, 18, 18], "burn": 4, "desc": "Drei glühende Bisse à 18 + Brand."},
	"Magmawulf": {"name": "Magmasturm", "el": "Feuer", "anim": "field", "hits": [20, 20, 20, 20], "burn": 6, "desc": "Vier Magma-Hiebe à 20 + langer Brand."},
	"Overclocko": {"name": "Überladung", "el": "Code", "anim": "self", "hits": [25], "recharge": true, "oc": 6.0, "desc": "Lädt alle Chips sofort, übertaktet 6 s, 25 Schaden."},
	"Turbowulf": {"name": "Turboschub", "el": "Code", "anim": "jump", "hits": [15, 15, 15], "recharge": true, "oc": 8.0, "desc": "Lädt alle Chips, übertaktet 8 s, rammt dreimal à 15."},
	"Tröpfel": {"name": "Blubberwelle", "el": "Wasser", "anim": "row", "hits": [30], "knock": true, "desc": "Welle: 30 Schaden, stößt zurück."},
	"Kaskadi": {"name": "Kaskadenflut", "el": "Wasser", "anim": "field", "hits": [35], "desc": "Flutet das ganze Gegnerfeld: 35 Schaden."},
	"Tsunamander": {"name": "Tsunami", "el": "Wasser", "anim": "field", "hits": [55], "stun": 1.5, "desc": "Riesenwelle: 55 Schaden, friert 1,5 s ein."},
	"Pufferling": {"name": "Aufblähen", "el": "Wasser", "anim": "self", "hits": [15], "bubble": 60, "bubble_t": 6.0, "desc": "Schutzblase (60 Schaden, 6 s) und 15 Schaden."},
	"Panzerpuff": {"name": "Panzerblase", "el": "Code", "anim": "field", "hits": [25], "bubble": 90, "bubble_t": 8.0, "desc": "Riesige Schutzblase (90, 8 s), 25 Schaden aufs ganze Feld."},
	"Frostbyte": {"name": "Frostwelle", "el": "Wasser", "anim": "row", "hits": [30], "stun": 2.5, "desc": "Eiswelle: 30 Schaden, friert 2,5 s ein."},
	"Kekso": {"name": "Backentasche", "el": "Neutral", "anim": "self", "hits": [], "replay": true, "desc": "Spuckt den zuletzt gespielten Chip kostenlos noch einmal aus (sonst 30 Schaden)."},
	"Tracko": {"name": "Keksfalle", "el": "Virus", "anim": "self", "hits": [], "replay": true, "mines": 2, "desc": "Backentasche und zwei Virus-Minen um den Gegner."},
	"Cachy": {"name": "Leuchtkeks", "el": "Elektro", "anim": "self", "hits": [], "replay": true, "heal": 30, "desc": "Backentasche und heilt 30 HP."},
	"Lumi": {"name": "Cursorblitz", "el": "Elektro", "anim": "field", "hits": [35], "desc": "Blitz, der immer trifft: 35 Schaden."},
	"Blinki": {"name": "Dreifachblitz", "el": "Elektro", "anim": "field", "hits": [22, 22, 22], "desc": "Drei Blitze à 22."},
	"Quakli": {"name": "Zungenschlag", "el": "Virus", "anim": "row", "hits": [25], "pull": true, "poison": 4, "desc": "Zieht den Gegner direkt vor dich: 25 Schaden + Gift."},
	"Virulurch": {"name": "Giftwolke", "el": "Virus", "anim": "field", "hits": [20], "poison": 10, "desc": "Giftwolke über das ganze Gegnerfeld: 20 + sehr langes Gift."},
	"Hüpfbyte": {"name": "Datensprung", "el": "Code", "anim": "jump", "hits": [40], "stun": 1.5, "desc": "Springt auf den Gegner: 40 Schaden, betäubt 1,5 s."},
	"Mechaquak": {"name": "Kolbensprung", "el": "Code", "anim": "jump", "hits": [60], "stun": 2.0, "desc": "Kolben-Sprung: 60 Schaden, betäubt 2 s."},
	"Molchi": {"name": "Giftspucke", "el": "Virus", "anim": "row", "hits": [25], "poison": 4, "desc": "Gift, das immer trifft: 25 Schaden + Gift."},
	"Toxmolch": {"name": "Toxinregen", "el": "Virus", "anim": "field", "hits": [30], "poison": 8, "desc": "Giftregen übers ganze Gegnerfeld: 30 + langes Gift."},
	"Magmolch": {"name": "Lavastrom", "el": "Feuer", "anim": "row", "hits": [40], "burn": 4, "desc": "Lava über die Gegnerreihe: 40 Schaden + Brand."},
	"Brummbit": {"name": "Tatzenhieb", "el": "Neutral", "anim": "jump", "hits": [40], "knock": true, "desc": "Kräftiger Prankenschlag: 40 Schaden, stößt zurück."},
	"Bärtron": {"name": "Raketenfaust", "el": "Code", "anim": "row", "hits": [60], "stun": 1.0, "desc": "Mechanische Faust: 60 Schaden, betäubt 1 s."},
	"Titanbrumm": {"name": "Doppelraketenfaust", "el": "Code", "anim": "row", "hits": [45, 45], "stun": 1.5, "desc": "Zwei Raketenfäuste à 45, betäubt 1,5 s."},
	"Kauzbit": {"name": "Scanblick", "el": "Code", "anim": "self", "hits": [15], "scan": 3, "desc": "15 Schaden, deine nächsten 3 Treffer machen +50 %."},
	"Optikauz": {"name": "Laserblick", "el": "Code", "anim": "row", "hits": [50], "desc": "Laser aus den Linsenaugen: 50 Schaden."},
	"Raketauz": {"name": "Düsenangriff", "el": "Feuer", "anim": "field", "hits": [20, 20, 20], "burn": 4, "desc": "Drei Zielraketen à 20 + Brand."},
	"Radarkauz": {"name": "Zielerfassung", "el": "Code", "anim": "self", "hits": [30], "scan": 5, "desc": "30 Schaden, deine nächsten 5 Treffer machen +50 %."},
	"Wolkerich": {"name": "Datenwolke", "el": "Wasser", "anim": "field", "hits": [15], "bubble": 60, "bubble_t": 6.0, "heal": 20, "desc": "Schutzblase (60, 6 s), heilt 20 HP und trifft das ganze Feld mit 15."},
	"Toxipanth": {"name": "Giftsprung", "el": "Virus", "anim": "jump", "hits": [50], "poison": 8, "desc": "Lautloser Sprung: 50 Schaden + starkes Gift."},
	"Prismalynx": {"name": "Prismastrahl", "el": "Elektro", "anim": "field", "hits": [45], "heal": 30, "desc": "Regenbogenlicht übers ganze Feld: 45 Schaden, heilt 30 HP."},
	"Glaziolotl": {"name": "Gletscherwelle", "el": "Wasser", "anim": "field", "hits": [45], "stun": 3.0, "desc": "Eisige Flut übers ganze Feld: 45 Schaden, friert 3 s ein."},
	"Schattnager": {"name": "Schattenfalle", "el": "Virus", "anim": "self", "hits": [20], "replay": true, "mines": 3, "desc": "Backentasche, drei Virus-Minen und 20 Schaden."},
	"Glanzbacke": {"name": "Sonnenkeks", "el": "Elektro", "anim": "self", "hits": [20], "replay": true, "heal": 45, "desc": "Backentasche, heilt 45 HP und trifft mit 20."},
	"Strahlhase": {"name": "Blitzgewitter", "el": "Elektro", "anim": "field", "hits": [20, 20, 20, 20], "desc": "Vier Lichtblitze à 20."},
	"Toxikröt": {"name": "Seuchenwolke", "el": "Virus", "anim": "field", "hits": [30], "poison": 12, "desc": "Giftwolke übers ganze Feld: 30 + sehr langes Gift."},
	"Sumpfdrak": {"name": "Sumpfatem", "el": "Virus", "anim": "row", "hits": [45], "poison": 8, "desc": "Giftiger Atem über die Gegnerreihe: 45 + Gift."},
	"Lavadrak": {"name": "Lavaflut", "el": "Feuer", "anim": "field", "hits": [40], "burn": 6, "desc": "Lava übers ganze Gegnerfeld: 40 + langer Brand."},
	"Phönixkauz": {"name": "Phönixsturz", "el": "Feuer", "anim": "jump", "hits": [60], "burn": 6, "desc": "Flammender Sturzflug: 60 Schaden + Brand."},
	"Bastionkatz": {"name": "Bastionssprung", "el": "Code", "anim": "jump", "hits": [70], "stun": 1.5, "shield": 8.0, "desc": "Festungssprung: 70 Schaden, betäubt 1,5 s, Firewall-Schild (8 s)."},
	"Venomynx": {"name": "Dreigiftschweif", "el": "Virus", "anim": "field", "hits": [25, 25, 25], "poison": 12, "desc": "Drei Giftschweife übers ganze Feld à 25 + sehr langes Gift."},
	"Aurorlynx": {"name": "Polarlicht", "el": "Elektro", "anim": "field", "hits": [60], "heal": 50, "desc": "Aurora übers ganze Feld: 60 Schaden, heilt 50 HP."},
	"Glutfenrir": {"name": "Fenrirbrand", "el": "Feuer", "anim": "jump", "hits": [45, 45], "burn": 8, "desc": "Zwei glühende Bisse à 45 + langer Brand."},
	"Hyperwulf": {"name": "Hyperschub", "el": "Code", "anim": "jump", "hits": [20, 20, 20, 20], "recharge": true, "oc": 10.0, "desc": "Lädt alle Chips, übertaktet 10 s, rammt viermal à 20."},
	"Leviamander": {"name": "Leviathanflut", "el": "Wasser", "anim": "field", "hits": [75], "stun": 2.0, "desc": "Gewaltige Flut: 75 Schaden, friert 2 s ein."},
	"Kolosspuff": {"name": "Kolossblase", "el": "Code", "anim": "field", "hits": [35], "bubble": 120, "bubble_t": 10.0, "desc": "Riesige Blase (120, 10 s) und 35 Schaden aufs ganze Feld."},
	"Kryolotl": {"name": "Absoluter Nullpunkt", "el": "Wasser", "anim": "field", "hits": [55], "stun": 4.0, "desc": "Alles gefriert: 55 Schaden, 4 s eingefroren."},
	"Phantomnager": {"name": "Phantomfalle", "el": "Virus", "anim": "self", "hits": [35], "replay": true, "mines": 4, "decoy": 2, "decoy_t": 8.0, "desc": "Backentasche, vier Minen, zwei Schatten fangen Treffer ab, 35 Schaden."},
	"Stellarbacke": {"name": "Sternenkeks", "el": "Elektro", "anim": "self", "hits": [30], "replay": true, "heal": 60, "desc": "Backentasche, heilt 60 HP und trifft mit 30."},
	"Plasmahase": {"name": "Plasmasturm", "el": "Elektro", "anim": "field", "hits": [25, 25, 25, 25], "desc": "Vier Plasmablitze à 25."},
	"Miasmakröt": {"name": "Miasma", "el": "Virus", "anim": "field", "hits": [40], "poison": 16, "desc": "Giftnebel übers ganze Feld: 40 + extrem langes Gift."},
	"Gigaquak": {"name": "Gigasprung", "el": "Code", "anim": "jump", "hits": [85], "stun": 2.5, "desc": "Kolossaler Kolbensprung: 85 Schaden, betäubt 2,5 s."},
	"Hydradrak": {"name": "Dreikopfatem", "el": "Virus", "anim": "row", "hits": [30, 30, 30], "poison": 10, "desc": "Drei Köpfe speien Gift über die Reihe à 30 + Gift."},
	"Vulkandrak": {"name": "Eruption", "el": "Feuer", "anim": "field", "hits": [55], "burn": 8, "desc": "Ausbruch übers ganze Feld: 55 + langer Brand."},
	"Kolossbrumm": {"name": "Kolossfäuste", "el": "Code", "anim": "row", "hits": [55, 55], "stun": 2.0, "desc": "Zwei Kolossfäuste à 55, betäubt 2 s."},
	"Infernokauz": {"name": "Infernosturz", "el": "Feuer", "anim": "jump", "hits": [85], "burn": 8, "desc": "Flammender Sturzflug: 85 Schaden + langer Brand."},
	"Orbitkauz": {"name": "Orbitalschlag", "el": "Code", "anim": "self", "hits": [40], "scan": 8, "desc": "40 Schaden, deine nächsten 8 Treffer machen +50 %."},
	"Wolperling": {"name": "Geweihblitz", "el": "Elektro", "anim": "jump", "hits": [30, 30], "stun": 1.0, "desc": "Flatternder Geweihstoß: 2 × 30, betäubt 1 s."},
	"Buddli": {"name": "Buddelstoß", "el": "Neutral", "anim": "jump", "hits": [35], "stun": 0.5, "desc": "Gräbt sich unter den Gegner und stößt hoch: 35, betäubt 0,5 s."},
	"Glimmdachs": {"name": "Glutgrabung", "el": "Feuer", "anim": "jump", "hits": [40], "burn": 4, "desc": "Glühende Krallen von unten: 40 + Brand."},
	"Magmadachs": {"name": "Magmaausbruch", "el": "Feuer", "anim": "field", "hits": [40], "burn": 6, "desc": "Gräbt eine Magmaader an: 40 aufs ganze Feld + langer Brand."},
	"Pyromeles": {"name": "Erdkernbrecher", "el": "Feuer", "anim": "jump", "hits": [60, 40], "burn": 8, "desc": "Bricht bis zum glühenden Kern durch: 60 + 40 + sehr langer Brand."},
	"Zackdachs": {"name": "Zackenstreif", "el": "Elektro", "anim": "row", "hits": [35], "stun": 0.5, "desc": "Blitz aus dem Gesichtsstreif über die Reihe: 35, betäubt 0,5 s."},
	"Donnerdachs": {"name": "Donnergrube", "el": "Elektro", "anim": "field", "hits": [25, 25], "stun": 1.0, "desc": "Donnerschlag aus der Tiefe: 2 × 25 aufs ganze Feld, betäubt 1 s."},
	"Voltameles": {"name": "Hochspannungsgraben", "el": "Elektro", "anim": "field", "hits": [30, 30, 30], "stun": 1.5, "desc": "Drei Blitzgräben übers ganze Feld: 3 × 30, betäubt 1,5 s."},
	"Maskli": {"name": "Taschendieb", "el": "Neutral", "anim": "self", "hits": [25], "recharge": true, "desc": "Klaut Ladung: alle Chips sofort bereit, dazu 25 Schaden."},
	"Plätschbär": {"name": "Waschgang", "el": "Wasser", "anim": "row", "hits": [30], "knock": true, "desc": "Schwall über die Reihe: 30, stößt zurück."},
	"Flutmaske": {"name": "Flutraubzug", "el": "Wasser", "anim": "field", "hits": [35], "stun": 1.5, "heal": 20, "desc": "Flutwelle übers ganze Feld: 35, friert 1,5 s ein, heilt 20 HP."},
	"Hydrocyon": {"name": "Sintflut-Coup", "el": "Wasser", "anim": "field", "hits": [30, 30], "stun": 2.0, "recharge": true, "desc": "2 × 30 aufs ganze Feld, friert 2 s ein und lädt alle Chips."},
	"Klaubär": {"name": "Giftgriff", "el": "Virus", "anim": "jump", "hits": [30], "poison": 6, "desc": "Blitzschneller Griff: 30 + Gift."},
	"Nachtmaske": {"name": "Schattenraub", "el": "Virus", "anim": "self", "hits": [40], "poison": 8, "decoy": 1, "decoy_t": 6.0, "desc": "40 + langes Gift, ein Schatten fängt den nächsten Treffer ab."},
	"Virocyon": {"name": "Datenraubzug", "el": "Virus", "anim": "field", "hits": [40], "poison": 12, "recharge": true, "desc": "Klaut alle Daten: 40 aufs ganze Feld, sehr langes Gift, lädt alle Chips."},
	"Bachli": {"name": "Bauchrutscher", "el": "Neutral", "anim": "row", "hits": [30], "knock": true, "desc": "Rutscht auf dem Bauch über die Reihe: 30, stößt zurück."},
	"Strudli": {"name": "Strudelwirbel", "el": "Wasser", "anim": "jump", "hits": [20, 20], "heal": 10, "desc": "Wirbelt durch den Gegner: 2 × 20, heilt 10 HP."},
	"Wogotter": {"name": "Wogenbrecher", "el": "Wasser", "anim": "field", "hits": [35], "stun": 1.0, "heal": 15, "desc": "Riesenwoge übers ganze Feld: 35, friert 1 s ein, heilt 15 HP."},
	"Hydrolutra": {"name": "Mahlstrom", "el": "Wasser", "anim": "field", "hits": [35, 35], "stun": 1.5, "heal": 25, "desc": "Mahlstrom übers ganze Feld: 2 × 35, friert 1,5 s ein, heilt 25 HP."},
	"Knisterli": {"name": "Schnurrhaarblitz", "el": "Elektro", "anim": "row", "hits": [30], "stun": 0.5, "desc": "Blitz aus den Schnurrhaaren über die Reihe: 30, betäubt 0,5 s."},
	"Lutrion": {"name": "Donnerwirbel", "el": "Elektro", "anim": "jump", "hits": [30, 30], "stun": 1.0, "desc": "Springt blitzend durch den Gegner: 2 × 30, betäubt 1 s."},
	"Fulgurlutra": {"name": "Gewitterfront", "el": "Elektro", "anim": "field", "hits": [45, 45], "stun": 1.0, "recharge": true, "desc": "Gewitterfront übers ganze Feld: 2 × 45, betäubt 1 s, lädt alle Chips."},
	"Plapperli": {"name": "Plapperschwall", "el": "Neutral", "anim": "row", "hits": [15, 15], "desc": "Plappert ohne Pause über die Reihe: 2 × 15."},
	"Surrfeder": {"name": "Surrsturz", "el": "Elektro", "anim": "jump", "hits": [35], "stun": 0.5, "desc": "Surrender Sturzflug: 35, betäubt 0,5 s."},
	"Sturmschwinge": {"name": "Federsalve", "el": "Elektro", "anim": "row", "hits": [20, 20, 20], "stun": 0.5, "desc": "Geladene Federn über die Reihe: 3 × 20, betäubt 0,5 s."},
	"Fulgopsitta": {"name": "Donnerschrei", "el": "Elektro", "anim": "field", "hits": [25, 25, 25, 25], "stun": 1.0, "desc": "Ohrenbetäubender Donnerschrei: 4 × 25 aufs ganze Feld, betäubt 1 s."},
	"Glutfeder": {"name": "Glutfedern", "el": "Feuer", "anim": "row", "hits": [30], "burn": 4, "desc": "Wirft glühende Federn über die Reihe: 30 + Brand."},
	"Flammschwinge": {"name": "Feuerfächer", "el": "Feuer", "anim": "field", "hits": [20, 20], "burn": 6, "desc": "Fächert Glutfedern übers ganze Feld: 2 × 20 + langer Brand."},
	"Heliopsitta": {"name": "Sonnensturz", "el": "Feuer", "anim": "jump", "hits": [70, 30], "burn": 8, "desc": "Stürzt herab wie eine kleine Sonne: 70 + 30 + sehr langer Brand."},
	"Schlummerbit": {"name": "Schlaflied", "el": "Elektro", "anim": "field", "hits": [20], "stun": 3.0, "heal": 30, "desc": "Ein Schlaflied übers ganze Feld: 20 Schaden, der Gegner schläft 3 s, du heilst 30 HP."},
	# --- Legendäre (07.10.2026) ---
	"Glimmhirsch": {"name": "Lichtsprung", "el": "Neutral", "anim": "jump", "hits": [45], "heal": 25, "desc": "Springt im Lichtbogen zum Gegner: 45 Schaden, heilt 25 HP."},
	"Lumicervus": {"name": "Sonnengeweih", "el": "Neutral", "anim": "field", "hits": [65], "heal": 45, "desc": "Das Geweih strahlt übers ganze Feld: 65 Schaden, heilt 45 HP."},
	"Glutkirin": {"name": "Feuerhuf", "el": "Feuer", "anim": "field", "hits": [25, 25], "burn": 6, "desc": "Stampft Feuer übers Feld: 2 × 25 + langer Brand."},
	"Pyrokirin": {"name": "Höllenhuf", "el": "Feuer", "anim": "field", "hits": [30, 30, 30], "burn": 8, "desc": "Ein Ritt durch Flammen: 3 × 30 + sehr langer Brand."},
	"Sternwal": {"name": "Sternenflut", "el": "Wasser", "anim": "field", "hits": [45], "bubble": 40, "bubble_t": 5.0, "desc": "Eine Flut voller Sterne: 45 Schaden aufs ganze Feld, Schutzblase (40, 5 s)."},
	"Astralwal": {"name": "Nebelgesang", "el": "Wasser", "anim": "field", "hits": [65], "stun": 1.5, "bubble": 60, "bubble_t": 6.0, "desc": "Ein Lied aus dem All: 65 Schaden, friert 1,5 s ein, Schutzblase (60, 6 s)."},
	"Toxilisk": {"name": "Bannstrahl", "el": "Virus", "anim": "row", "hits": [40], "poison": 6, "stun": 1.5, "desc": "Versteinernder Blick: 40 Schaden, Gift und 1,5 s Starre."},
	"Miasmalisk": {"name": "Steinerner Blick", "el": "Virus", "anim": "field", "hits": [55], "poison": 8, "stun": 2.0, "desc": "Der Blick trifft das ganze Feld: 55 Schaden, starkes Gift, 2 s Starre."},
	"Funkengreif": {"name": "Sturzflug", "el": "Elektro", "anim": "jump", "hits": [20, 20, 20], "stun": 0.5, "desc": "Blitzschneller Sturzflug: 3 × 20, betäubt kurz."},
	"Donnergryph": {"name": "Donnersturz", "el": "Elektro", "anim": "jump", "hits": [28, 28, 28], "stun": 1.0, "desc": "Sturz aus dem Gewitter: 3 × 28, betäubt 1 s."},
	"Chiffrasphinx": {"name": "Rätselstrahl", "el": "Code", "anim": "row", "hits": [45], "shield": 5.0, "desc": "Ein Strahl aus Glyphen: 45 Schaden, Firewall-Schild (5 s)."},
	"Algosphinx": {"name": "Ur-Algorithmus", "el": "Code", "anim": "field", "hits": [60], "shield": 6.0, "recharge": true, "desc": "Uralter Code: 60 Schaden aufs ganze Feld, Schild (6 s), alle Chips sofort geladen."},
	"Pustebacke": {"name": "Gasexplosion", "el": "Virus", "anim": "field", "hits": [15, 15], "poison": 10, "desc": "Platzt fast vor Gas: Giftwolke übers ganze Feld, 2 × 15 + langes Gift."},
	"Pilzbrumm": {"name": "Sporenwolke", "el": "Virus", "anim": "field", "hits": [20], "poison": 6, "desc": "Giftige Sporenwolke übers ganze Feld: 20 + Gift."},
	"Sporenpranke": {"name": "Giftpranke", "el": "Virus", "anim": "jump", "hits": [50], "poison": 8, "knock": true, "desc": "Pilzbesetzter Prankenhieb: 50 + langes Gift, stößt zurück."},
	"Myzelgrizz": {"name": "Myzelnetz", "el": "Virus", "anim": "field", "hits": [45], "poison": 12, "heal": 40, "desc": "Pilzgeflecht überzieht das Feld: 45 + sehr langes Gift, heilt 40 HP."},
	"Perlhopp": {"name": "Perlenschuss", "el": "Wasser", "anim": "row", "hits": [30], "knock": true, "desc": "Perlenblasen über die Reihe: 30, stößt zurück."},
	"Gischthase": {"name": "Gischtsprung", "el": "Wasser", "anim": "jump", "hits": [25, 25], "stun": 1.0, "desc": "Zwei Sprungtritte aus Gischt à 25, friert 1 s ein."},
	"Lunaflut": {"name": "Springflut", "el": "Wasser", "anim": "field", "hits": [35, 35], "stun": 2.0, "heal": 30, "desc": "Mondflut übers ganze Feld: 2 × 35, friert 2 s ein, heilt 30 HP."},
	"Spukatz": {"name": "Spukschlag", "el": "Virus", "anim": "jump", "hits": [45], "poison": 6, "decoy": 1, "decoy_t": 6.0, "desc": "Geisterhafter Sprung: 45 + Gift, ein Abbild fängt den nächsten Treffer ab."},
}

## ---------- Resonanz und Element-Gaben (08.10.2026, Game-Design-Analyse) ----------
## Die Evolution soll verändern, wie man spielt: Ab Rookie verstärkt die Form ihr eigenes Element.
## Resonanz: Chips im Element der Form machen mehr Schaden (je Stufe). Gabe: eine Regel je Element, mit jeder Stufe stärker.
## Neutrale Formen (Babys, Glimmhirsch-Linie) haben weder Resonanz noch Gabe.
const RESONANCE := {2: 0.2, 3: 0.3, 4: 0.4}
const GIFTS := {
	"Feuer": {"name": "Zündeln", "desc": "Feuer-Treffer setzen den Gegner %s s in Brand.", "v": {2: 2, 3: 3, 4: 4}},
	"Wasser": {"name": "Sog", "desc": "Wasser-Treffer verlangsamen den Gegner %s s.", "v": {2: 1.0, 3: 1.5, 4: 2.0}},
	"Code": {"name": "Schutzroutine", "desc": "Blockst oder vermeidest du einen Treffer, lädt die Signatur um %s %%.", "v": {2: 10, 3: 15, 4: 20}},
	"Elektro": {"name": "Funkenflug", "desc": "Elektro-Treffer betäuben den Gegner %s s.", "v": {2: 0.2, 3: 0.3, 4: 0.4}},
	"Virus": {"name": "Ansteckung", "desc": "Virus-Treffer vergiften den Gegner %s s.", "v": {2: 2, 3: 3, 4: 4}},
}


## Resonanz-Bonus einer Form für ein Chip-Element (0 = keiner)
static func resonance(form: String, chip_el: String) -> float:
	var F: Dictionary = FORMS.get(form, {})
	if F.is_empty() or F.el == "Neutral" or F.el != chip_el:
		return 0.0
	return RESONANCE.get(int(F.stage), 0.0)


## Gabe einer Form: {} oder {name, desc (mit Wert), el, v}
static func gift(form: String) -> Dictionary:
	var F: Dictionary = FORMS.get(form, {})
	if F.is_empty() or not GIFTS.has(F.el) or int(F.stage) < 2:
		return {}
	var G: Dictionary = GIFTS[F.el]
	var v = G.v[clampi(int(F.stage), 2, 4)]
	return {"name": G.name, "desc": T.t(G.desc) % T.dec(v) if v is float else T.t(G.desc) % str(v), "el": F.el, "v": v}


const BEATS := {"Feuer": "Code", "Code": "Wasser", "Wasser": "Feuer"}
const RARITY_WEIGHT := {"Gewöhnlich": 6, "Selten": 3, "Episch": 1}

## Module: passive Gegenstände, die nur für den laufenden Run gelten (Quelle: Elite, Händler, Modulkapsel).
## pic = Piktogramm (PICTOS), col = Farbe des Symbols
const MODULES := {
	"verstaerker": {"name": "Verstärker", "rar": "Gewöhnlich", "pic": "star", "col": "#FFC83D", "desc": "Chip-Treffer machen +3 Schaden."},
	"schnelllader": {"name": "Schnelllader", "rar": "Gewöhnlich", "pic": "gear", "col": "#6EE7C5", "desc": "Chips laden 15 % schneller."},
	"startsignal": {"name": "Startsignal", "rar": "Gewöhnlich", "pic": "bolt", "col": "#FFE45C", "desc": "Die Signatur-Leiste startet jeden Kampf zu einem Viertel gefüllt."},
	"panzerplatte": {"name": "Panzerplatte", "rar": "Gewöhnlich", "pic": "shield", "col": "#58B7FF", "desc": "Jeder Treffer gegen dich macht 2 Schaden weniger."},
	"sammler": {"name": "Sammler", "rar": "Gewöhnlich", "pic": "coin", "col": "#FFC83D", "desc": "+30 % Fragmente aus Kämpfen."},
	"lebensbit": {"name": "Lebensbit", "rar": "Gewöhnlich", "pic": "heart", "col": "#FF7A8A", "desc": "Nach jedem Sieg heilst du 8 HP zusätzlich."},
	"schleimschuhe": {"name": "Schleimschuhe", "rar": "Gewöhnlich", "pic": "boot", "col": "#7BD35A", "desc": "Schleim bremst dich nicht, Lava schadet dir nur halb so viel."},
	"rabattchip": {"name": "Rabattchip", "rar": "Gewöhnlich", "pic": "coin", "col": "#58D68D", "desc": "Beim Datenhändler ist alles 25 % billiger."},
	"ueberhitzer": {"name": "Überhitzer", "rar": "Selten", "pic": "flame", "col": "#FF8A4C", "desc": "Brand verursacht doppelten Schaden."},
	"giftkapsel": {"name": "Giftkapsel", "rar": "Selten", "pic": "skull", "col": "#C77DFF", "desc": "Gift verursacht 50 % mehr Schaden."},
	"kaeltekern": {"name": "Kältekern", "rar": "Selten", "pic": "snow", "col": "#8FD8FF", "desc": "Einfrieren und Betäuben halten 50 % länger."},
	"elementlinse": {"name": "Elementlinse", "rar": "Selten", "pic": "eye", "col": "#FF8FD8", "desc": "Element-Vorteil macht doppelten statt 1,5-fachen Schaden."},
	"dornenpanzer": {"name": "Dornenpanzer", "rar": "Selten", "pic": "spike", "col": "#58B7FF", "desc": "Wirst du getroffen, erleidet der Gegner 6 Schaden."},
	"reflexbooster": {"name": "Reflexbooster", "rar": "Selten", "pic": "arrow", "col": "#6EE7C5", "desc": "Du bewegst dich 25 % schneller."},
	"prisma": {"name": "Prisma", "rar": "Selten", "pic": "gem", "col": "#FFE45C", "desc": "Element-Chips prägen doppelt: Evolution kommt schneller."},
	"kondensator": {"name": "Kondensator", "rar": "Selten", "pic": "bolt", "col": "#4CC3F0", "desc": "Die Signatur-Leiste lädt 30 % schneller."},
	"notschild": {"name": "Notschild", "rar": "Selten", "pic": "shield", "col": "#8FD8FF", "desc": "Jeder Kampf beginnt mit einer Blase, die 20 Schaden abfängt."},
	"suchalgorithmus": {"name": "Suchalgorithmus", "rar": "Selten", "pic": "eye", "col": "#FFC83D", "desc": "Bei jeder Chipwahl ist mindestens ein seltener oder epischer Chip."},
	"backupkern": {"name": "Backup-Kern", "rar": "Episch", "pic": "heart", "col": "#FFC83D", "desc": "Einmal pro Run: Statt zu verlieren kämpfst du mit 30 % HP weiter."},
	"kritbit": {"name": "Kritbit", "rar": "Episch", "pic": "star", "col": "#FF5470", "desc": "20 % Chance auf doppelten Schaden."},
	"saugbit": {"name": "Saugbit", "rar": "Episch", "pic": "heart", "col": "#C77DFF", "desc": "Heilt 1 HP pro 10 Schaden, den du austeilst."},
	"echochip": {"name": "Echochip", "rar": "Episch", "pic": "gear", "col": "#FF8FD8", "desc": "Jeder 4. Chip wird doppelt ausgelöst."},
}
## Station-Ausbau (30.09.2026): dauerhafte Verbesserungen für Fragmente. costs = Preis je Stufe.
const STATION_UPGRADES := [
	{"id": "werkbank", "name": "Werkbank", "costs": [120, 260], "desc": "Jeder Run startet mit %d verbesserten Chip(s)."},
	{"id": "vorrat", "name": "Vorratslager", "costs": [100, 200, 350], "desc": "Jeder Run startet mit +%d max. HP."},
	{"id": "modulschacht", "name": "Modulschacht", "costs": [220, 420], "desc": "Jeder Run startet mit einem Modul (Stufe 2: auch seltene und epische)."},
	{"id": "filter", "name": "Fragmentfilter", "costs": [150, 300], "desc": "+%d %% Fragmente aus Kämpfen."},
	{"id": "brutwaermer", "name": "Brutwärmer", "costs": [180], "desc": "Nach jedem Run mit mindestens 2 Siegen ein zusätzliches Ei."},
	{"id": "nestplatz", "name": "Nest-Erweiterung", "costs": [150], "desc": "Ein vierter Platz im Brutnest."},
]


## ---------- Herausforderungen (09.10.2026, Endgame) ----------
## Ein Brett in der Station (Reiter „Aufgaben“): Aufgaben, die zu einer anderen Spielweise zwingen. Jede gibt es einmal,
## die Belohnung holt man im Reiter ab. goal = Zielwert (Fortschrittsbalken ab 2), need = Zonen, ohne die es nicht geht
## (Testfassung blendet sie aus), reward = {"frag": n} | {"egg": 1} | {"egg_new": 1} (Ei mit einer Art, die noch fehlt).
## Fortschritt: SaveGame.challenge_progress, Bestwerte je Reise: RunState.ch (Schlüssel = id).
const CHALLENGE_CATS := ["Reise", "Kampf", "Spielweise", "Glitchlinge", "Meister"]
const CHALLENGES := [
	{"id": "wiesen", "cat": "Reise", "name": "Erste Säuberung", "desc": "Besiege den Boss der Cache-Wiesen.", "goal": 1, "reward": {"frag": 50}},
	{"id": "wege2", "cat": "Reise", "name": "Feuer und Wasser", "desc": "Besiege die Bosse von Firewall-Vulkan und Kühlwasser-See.", "goal": 2, "need": ["vulkan", "see"], "reward": {"egg": 1}},
	{"id": "wege3", "cat": "Reise", "name": "Sumpf und Steppe", "desc": "Besiege die Bosse der Viren-Sümpfe und der Hochspannungs-Steppe.", "goal": 2, "need": ["sumpf", "steppe"], "reward": {"egg": 1}},
	{"id": "finale", "cat": "Reise", "name": "Retter des NEST", "desc": "Besiege den Ur-Glitch.", "goal": 1, "need": ["kern"], "reward": {"frag": 200}},
	{"id": "finale3", "cat": "Reise", "name": "Viele Helden", "desc": "Besiege den Ur-Glitch mit drei verschiedenen Glitchling-Arten.", "goal": 3, "need": ["kern"], "reward": {"egg_new": 1}},
	{"id": "protokoll3", "cat": "Reise", "name": "Protokoll 3", "desc": "Schaffe eine ganze Reise auf Glitch-Protokoll 3 oder höher.", "goal": 3, "need": ["kern"], "reward": {"frag": 300}},
	{"id": "konter10", "cat": "Kampf", "name": "Konterkunst", "desc": "Lande 10 Konter in einem einzigen Kampf.", "goal": 10, "reward": {"frag": 100}},
	{"id": "felsenfest", "cat": "Kampf", "name": "Felsenfest", "desc": "Besiege einen Elite-Gegner, ohne dich ein einziges Mal zu bewegen.", "goal": 1, "reward": {"frag": 100}},
	{"id": "blitz", "cat": "Kampf", "name": "Blitzsieg", "desc": "Besiege einen Wächter in weniger als 20 Sekunden.", "goal": 1, "reward": {"frag": 150}},
	{"id": "gold", "cat": "Kampf", "name": "Goldener Tänzer", "desc": "Weiche in einem Bosskampf allen goldenen Großangriffen aus (mindestens 3).", "goal": 1, "reward": {"egg": 1}},
	{"id": "glitch2", "cat": "Kampf", "name": "Risikofreude", "desc": "Besiege in einer Reise 2 Glitch-Elites.", "goal": 2, "reward": {"egg": 1}},
	{"id": "waechter", "cat": "Kampf", "name": "Unberührt", "desc": "Besiege einen Wächter, ohne Schaden zu nehmen.", "goal": 1, "reward": {"frag": 150}},
	{"id": "el_feuer", "cat": "Spielweise", "name": "Feuerseele", "desc": "Spiele in einer Reise %d Feuer-Chips.", "goal": 200, "reward": {"egg": 1}},
	{"id": "el_wasser", "cat": "Spielweise", "name": "Wasserseele", "desc": "Spiele in einer Reise %d Wasser-Chips.", "goal": 200, "reward": {"egg": 1}},
	{"id": "el_code", "cat": "Spielweise", "name": "Codeseele", "desc": "Spiele in einer Reise %d Code-Chips.", "goal": 200, "reward": {"egg": 1}},
	{"id": "el_elektro", "cat": "Spielweise", "name": "Elektroseele", "desc": "Spiele in einer Reise %d Elektro-Chips.", "goal": 200, "reward": {"egg": 1}},
	{"id": "el_virus", "cat": "Spielweise", "name": "Virusseele", "desc": "Spiele in einer Reise %d Virus-Chips.", "goal": 200, "reward": {"egg": 1}},
	{"id": "minimal", "cat": "Spielweise", "name": "Leichtes Gepäck", "desc": "Besiege einen Zonen-Boss mit höchstens 10 Chips im Deck.", "goal": 1, "reward": {"frag": 150}},
	{"id": "rookie", "cat": "Glitchlinge", "name": "Erste Entwicklung", "desc": "Ein Glitchling entwickelt sich zum Rookie.", "goal": 1, "reward": {"frag": 50}},
	{"id": "champion", "cat": "Glitchlinge", "name": "Champion", "desc": "Ein Glitchling entwickelt sich zum Champion.", "goal": 1, "reward": {"egg": 1}},
	{"id": "ultra", "cat": "Glitchlinge", "name": "Ultra", "desc": "Ein Glitchling entwickelt sich zum Ultra.", "goal": 1, "reward": {"frag": 300}},
	{"id": "fusion", "cat": "Glitchlinge", "name": "Verschmolzen", "desc": "Erschaffe im Labor eine Fusion.", "goal": 1, "reward": {"egg": 1}},
	{"id": "dex40", "cat": "Glitchlinge", "name": "Forscher", "desc": "Entdecke 40 Formen im Monsterdex.", "goal": 40, "reward": {"egg_new": 1}},
	{"id": "arten", "cat": "Glitchlinge", "name": "Großfamilie", "desc": "Habe alle 13 Baby-Arten im Monsterdex.", "goal": 13, "reward": {"frag": 300}},
	{"id": "korrumpiert", "cat": "Meister", "name": "Korrumpiert", "desc": "Besiege den Ur-Glitch auf der Schwierigkeit Korrumpiert.", "goal": 1, "need": ["kern"], "reward": {"frag": 500}},
	{"id": "protokoll10", "cat": "Meister", "name": "Glitch-Sturm", "desc": "Schaffe eine ganze Reise auf Glitch-Protokoll 10.", "goal": 10, "need": ["kern"], "reward": {"frag": 500}},
	{"id": "baby2", "cat": "Meister", "name": "Kleiner Held", "desc": "Besiege den Boss in Akt 2 mit einem Baby.", "goal": 1, "reward": {"egg_new": 1}},
	{"id": "ohne_heilung", "cat": "Meister", "name": "Eiserne Reserve", "desc": "Besiege den Ur-Glitch, ohne in der Reise einen Heil-Chip zu spielen.", "goal": 1, "need": ["kern"], "reward": {"frag": 300}},
	{"id": "final_ohne", "cat": "Meister", "name": "Makellos", "desc": "Besiege den Ur-Glitch, ohne Schaden zu nehmen.", "goal": 1, "need": ["kern"], "reward": {"frag": 500}},
	{"id": "serie", "cat": "Meister", "name": "Unaufhaltsam", "desc": "Schaffe 3 ganze Reisen hintereinander, ohne zu verlieren.", "goal": 3, "need": ["kern"], "reward": {"frag": 500}},
]
## Heil-Chips („Eiserne Reserve“), Zeit gegen einen Wächter („Blitzsieg“), Deckgröße („Leichtes Gepäck“),
## ausgewichene Großangriffe im Bosskampf („Goldener Tänzer“)
const HEAL_CHIPS := ["Heilpatch", "Neustart", "Kiemenatmung"]
const BLITZ_TIME := 20.0
const MINI_DECK := 10
const GOLD_DODGES := 3


static func challenge(id: String) -> Dictionary:
	for c in CHALLENGES:
		if c.id == id:
			return c
	return {}


## Aufgabentext (Element-Aufgaben setzen ihren Zielwert ein)
static func challenge_desc(c: Dictionary) -> String:
	return T.t(c.desc) % int(c.goal) if String(c.desc).contains("%d") else T.t(c.desc)


## Wirkung eines Ausbaus auf Stufe lv (1-basiert) als Text
static func upgrade_desc(u: Dictionary, lv: int) -> String:
	match u.id:
		"werkbank":
			return T.t(u.desc) % lv
		"vorrat":
			return T.t(u.desc) % (10 * lv)
		"filter":
			return T.t(u.desc) % (15 * lv)
	return T.t(u.desc)


const MODULE_PRICE := {"Gewöhnlich": 45, "Selten": 70, "Episch": 100}
const MODULE_WEIGHT_ELITE := {"Gewöhnlich": 3, "Selten": 4, "Episch": 2}
## Piktogramme 6×6 für Modul-Symbole
const PICTOS := {
	"star": ["..##..", "..##..", "######", ".####.", ".#..#.", "#....#"],
	"gear": [".#..#.", "######", "##..##", "##..##", "######", ".#..#."],
	"bolt": ["...##.", "..##..", ".####.", "..##..", ".##...", ".#...."],
	"shield": ["######", "######", "######", ".####.", ".####.", "..##.."],
	"coin": [".####.", "##..##", "#.##.#", "#.##.#", "##..##", ".####."],
	"heart": ["##.##.", "######", "######", ".####.", "..##..", "......"],
	"boot": [".##...", ".##...", ".##...", ".####.", "######", "......"],
	"flame": ["..#...", ".##.#.", ".####.", "######", "######", ".####."],
	"skull": [".####.", "######", "#.##.#", "######", ".#.#..", "......"],
	"snow": ["#.#.#.", ".###..", "#####.", ".###..", "#.#.#.", "......"],
	"eye": ["......", ".####.", "##..##", "#.##.#", "##..##", ".####."],
	"spike": ["#...#.", ".#.#..", "..#...", ".#.#..", "#...#.", "......"],
	"arrow": ["..#...", "..##..", "######", "######", "..##..", "..#..."],
	"gem": ["..##..", ".####.", "######", ".####.", "..##..", "......"],
	"check": ["......", ".....#", "....##", "#..##.", "####..", ".##..."],
}


## Element, das gegen d besonders stark ist (für Hinweise)
static func strong_against(d: String) -> String:
	for a in BEATS:
		if BEATS[a] == d:
			return a
	return {"Virus": "Elektro", "Elektro": "Virus"}.get(d, "")


static func mult(a: String, d: String) -> float:
	if BEATS.get(a, "") == d:
		return 1.5
	if BEATS.get(d, "") == a:
		return 0.75
	if (a == "Elektro" and d == "Virus") or (a == "Virus" and d == "Elektro"):
		return 1.5
	return 1.0
