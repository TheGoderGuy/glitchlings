class_name Rooms
extends RefCounted
## Logik der Nicht-Kampf-Knoten (Rastplatz, Ereignis, Datenhändler), ohne Grafik.
## Jede Option: {"id", "label", "desc", "enabled"}. apply() gibt einen Ergebnistext zurück.
## Ergebnis "remove" bedeutet: Die Ansicht soll den Spieler einen Chip zum Entfernen wählen lassen.

const REST_HEAL := 0.35
const MIN_DECK := 5
const PRICE := {"Gewöhnlich": 25, "Selten": 40, "Episch": 60}
const PRICE_REPAIR := 20
const PRICE_REMOVE := 35

const EVENTS := {
	"datenpaket": {
		"title": "Verlorenes Datenpaket",
		"text": "Im hohen Gras der Cache-Wiesen liegt ein versiegeltes Datenpaket. Es summt leise.",
	},
	"brunnen": {
		"title": "Bit-Brunnen",
		"text": "Ein Brunnen voller glitzernder Bits. Das Plätschern klingt wie ein alter Modem-Ton.",
	},
	"korrupt": {
		"title": "Flackernder Chip",
		"text": "Ein Chip steckt schief im Boden und flackert. Er ist mächtig, aber instabil.",
	},
	"glitchling": {
		"title": "Wilder Glitchling",
		"text": "Ein kleiner wilder Glitchling beobachtet dich schüchtern hinter einem Datenhalm.",
	},
}


# ---------- Rastplatz ----------

static func rest_options(run: RunState) -> Array:
	var h := roundi(run.max_hp * REST_HEAL)
	return [
		{"id": "heal", "label": "Ausruhen", "desc": "Heilt %d HP." % h, "enabled": run.hp < run.max_hp},
		{"id": "remove", "label": "Deck ausdünnen", "desc": "Entferne einen Chip aus deinem Deck.", "enabled": run.deck.size() > MIN_DECK},
	]


static func rest_apply(run: RunState, id: String) -> String:
	match id:
		"heal":
			return "%s ruht sich aus: +%d HP." % [run.species, run.heal(roundi(run.max_hp * REST_HEAL))]
		"remove":
			return "remove"
	return ""


# ---------- Ereignisse ----------

static func pick_event(run: RunState) -> String:
	var free: Array = EVENTS.keys().filter(func(k): return not run.seen_events.has(k))
	if free.is_empty():
		free = EVENTS.keys()
	var key: String = free[run.rng.randi_range(0, free.size() - 1)]
	run.seen_events.append(key)
	return key


static func event_options(run: RunState, key: String) -> Array:
	match key:
		"datenpaket":
			return [
				{"id": "open", "label": "Öffnen", "desc": "Ein zufälliger Chip kommt in dein Deck.", "enabled": true},
				{"id": "send", "label": "Zum NEST schicken", "desc": "+20 Fragmente.", "enabled": true},
			]
		"brunnen":
			return [
				{"id": "drink", "label": "Trinken", "desc": "+20 HP.", "enabled": run.hp < run.max_hp},
				{"id": "throw", "label": "Bits hineinwerfen (15)", "desc": "Ein zufälliger seltener Chip.", "enabled": run.frag >= 15},
				{"id": "leave", "label": "Weitergehen", "desc": "Nichts passiert.", "enabled": true},
			]
		"korrupt":
			return [
				{"id": "take", "label": "Nehmen", "desc": "Defrag (Episch) ins Deck, aber −10 max. HP.", "enabled": run.max_hp > 20},
				{"id": "leave", "label": "Liegen lassen", "desc": "Nichts passiert.", "enabled": true},
			]
		"glitchling":
			return [
				{"id": "feed", "label": "Füttern (10)", "desc": "+5 max. HP und 10 HP heilen.", "enabled": run.frag >= 10},
				{"id": "wave", "label": "Winken", "desc": "Deine Signatur-Leiste startet im nächsten Kampf halb voll.", "enabled": true},
			]
	return []


static func event_apply(run: RunState, key: String, id: String) -> String:
	match [key, id]:
		["datenpaket", "open"]:
			var c := run.random_chip()
			run.deck.append(c)
			return "Im Paket steckt %s. Er kommt in dein Deck." % c
		["datenpaket", "send"]:
			run.frag += 20
			return "Der NEST bedankt sich mit 20 Fragmenten."
		["brunnen", "drink"]:
			return "Erfrischend! +%d HP." % run.heal(20)
		["brunnen", "throw"]:
			run.frag -= 15
			var c := run.random_chip("Selten")
			run.deck.append(c)
			return "Der Brunnen blubbert und spuckt %s aus." % c
		["korrupt", "take"]:
			run.deck.append("Defrag")
			run.max_hp -= 10
			run.hp = mini(run.hp, run.max_hp)
			return "Defrag gehört jetzt dir. Das Flackern kostet 10 max. HP."
		["glitchling", "feed"]:
			run.frag -= 10
			run.max_hp += 5
			run.heal(10)
			return "Der Glitchling mampft glücklich und schenkt dir etwas Energie: +5 max. HP."
		["glitchling", "wave"]:
			run.sp_bonus = true
			return "Der Glitchling winkt zurück. Du fühlst dich motiviert!"
	return "Du gehst weiter."


# ---------- Datenhändler ----------

static func shop_init(run: RunState, node: Dictionary) -> void:
	if node.has("shop"):
		return
	var offers: Array = []
	for c in run.roll_choices({"Gewöhnlich": 5, "Selten": 4, "Episch": 2}):
		offers.append({"chip": c, "price": PRICE[GameData.CHIPS[c].rar], "sold": false})
	node.shop = {"offers": offers, "repair": false, "remove": false}


static func shop_options(run: RunState, node: Dictionary) -> Array:
	var out: Array = []
	for i in node.shop.offers.size():
		var o: Dictionary = node.shop.offers[i]
		var ch: Dictionary = GameData.CHIPS[o.chip]
		out.append({"id": "buy_%d" % i, "label": "%s (%d)" % [o.chip, o.price] if not o.sold else "%s – verkauft" % o.chip,
			"desc": "%s · %s: %s" % [ch.el, ch.rar, ch.desc], "enabled": not o.sold and run.frag >= o.price, "chip": o.chip})
	out.append({"id": "repair", "label": "Reparatur (%d)" % PRICE_REPAIR, "desc": "Heilt 25 HP. Einmal pro Besuch.",
		"enabled": not node.shop.repair and run.frag >= PRICE_REPAIR and run.hp < run.max_hp})
	out.append({"id": "remove", "label": "Chip entfernen (%d)" % PRICE_REMOVE, "desc": "Entferne einen Chip aus deinem Deck. Einmal pro Besuch.",
		"enabled": not node.shop.remove and run.frag >= PRICE_REMOVE and run.deck.size() > MIN_DECK})
	return out


static func shop_apply(run: RunState, node: Dictionary, id: String) -> String:
	if id.begins_with("buy_"):
		var o: Dictionary = node.shop.offers[int(id.substr(4))]
		run.frag -= o.price
		o.sold = true
		run.deck.append(o.chip)
		return "%s kommt in dein Deck." % o.chip
	match id:
		"repair":
			run.frag -= PRICE_REPAIR
			node.shop.repair = true
			return "Repariert: +%d HP." % run.heal(25)
		"remove":
			run.frag -= PRICE_REMOVE
			node.shop.remove = true
			return "remove"
	return ""
