class_name Rooms
extends RefCounted
## Logik der Nicht-Kampf-Knoten (Rastplatz, Ereignis, Datenhändler), ohne Grafik.
## Jede Option: {"id", "label", "desc", "enabled"}. apply() gibt einen Ergebnistext zurück.
## Ergebnis "remove" bedeutet: Die Ansicht soll den Spieler einen Chip zum Entfernen wählen lassen.
## Ereignisse mit "zone" kommen nur dort vor, alle anderen überall.

const REST_HEAL := 0.35
const MIN_DECK := 5
const PRICE := {"Gewöhnlich": 25, "Selten": 40, "Episch": 60}
const PRICE_REPAIR := 20
const PRICE_REMOVE := 35
## Prägung, die ein Element-Ereignis schenkt (zählt wie gespielte Element-Chips)
const EVENT_PRAEG := 3

const EVENTS := {
	"datenpaket": {
		"title": "Verlorenes Datenpaket", "zone": "wiesen",
		"text": "Im hohen Gras der Cache-Wiesen liegt ein versiegeltes Datenpaket. Es summt leise.",
	},
	"brunnen": {
		"title": "Bit-Brunnen", "zone": "wiesen",
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
	"update": {
		"title": "Update verfügbar",
		"text": "Ein freundliches Fenster (wirklich kein Spam!) bietet ein Update für einen deiner Chips an.",
	},
	"cookies": {
		"title": "Cookie-Spur", "zone": "wiesen",
		"text": "Eine Spur aus Browser-Cookies führt quer über die Wiese. Sie riechen nach Vanille.",
	},
	"backup": {
		"title": "Backup-Station",
		"text": "Eine alte Backup-Station summt vor sich hin. Auf dem Display blinkt: KOPIEREN?",
	},
	"minibot": {
		"title": "Verirrter Mini-Bot",
		"text": "Ein kleiner Bot piept verzweifelt. Er hat seinen Heimweg verloren und ein Rad klemmt.",
	},
	# ---------- Firewall-Vulkan ----------
	"schmiede": {
		"title": "Glut-Schmiede", "zone": "vulkan",
		"text": "An einer verlassenen Esse glüht noch Datenstahl. Ein Chip ließe sich hier härten, wenn du die Hitze aushältst.",
	},
	"lavaquelle": {
		"title": "Heiße Quelle", "zone": "vulkan",
		"text": "Zwischen schwarzen Felsen dampft eine Quelle. Das Wasser ist angenehm warm, der Rand glüht orange.",
	},
	"firewallriss": {
		"title": "Riss in der Firewall", "zone": "vulkan",
		"text": "Eine glühende Sicherheitsmauer hat einen Riss. Dahinter hört man etwas schnarchen.",
	},
	"ascheregen": {
		"title": "Ascheregen", "zone": "vulkan",
		"text": "Graue Asche rieselt vom Himmel. Darunter glitzert etwas. Ein Chip? Oder nur Glut?",
	},
	# ---------- Spam-Sümpfe ----------
	"spamfilter": {
		"title": "Verstopfter Spamfilter", "zone": "sumpf",
		"text": "Ein riesiger Spamfilter ist bis obenhin verstopft. Zwischen dem Müll blinken ein paar Werbebanner.",
	},
	"irrlicht": {
		"title": "Irrlicht", "zone": "sumpf",
		"text": "Ein flackerndes Licht tanzt über das Moor und knistert elektrisch. Es will, dass du ihm folgst.",
	},
	"giftmoor": {
		"title": "Giftmoor", "zone": "sumpf",
		"text": "Violetter Schlamm blubbert vor sich hin. Er riecht streng, aber irgendwie auch belebend.",
	},
	"orakel": {
		"title": "Quak-Orakel", "zone": "sumpf",
		"text": "Eine uralte Kröte sitzt auf einem Seerosenblatt aus Pixeln. Sie soll alles über Evolutionen wissen.",
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

static func events_for_zone(zone: String) -> Array:
	return EVENTS.keys().filter(func(k): return EVENTS[k].get("zone", zone) == zone)


static func pick_event(run: RunState) -> String:
	var pool := events_for_zone(run.map.zone)
	var free: Array = pool.filter(func(k): return not run.seen_events.has(k))
	if free.is_empty():
		free = pool
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
		"update":
			var commons: Array = run.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich")
			return [
				{"id": "install", "label": "Installieren", "desc": "Ein zufälliger gewöhnlicher Chip wird zu einem seltenen.", "enabled": not commons.is_empty()},
				{"id": "later", "label": "Später erinnern", "desc": "+10 Fragmente fürs Warten.", "enabled": true},
			]
		"cookies":
			return [
				{"id": "collect", "label": "Aufsammeln", "desc": "+25 Fragmente.", "enabled": true},
				{"id": "snack", "label": "Naschen", "desc": "+15 HP.", "enabled": run.hp < run.max_hp},
			]
		"backup":
			return [
				{"id": "copy", "label": "Chip kopieren", "desc": "Ein Chip deiner Wahl kommt ein zweites Mal ins Deck.", "enabled": true},
				{"id": "leave", "label": "Nicht anfassen", "desc": "Nichts passiert.", "enabled": true},
			]
		"minibot":
			return [
				{"id": "home", "label": "Heimbringen", "desc": "Der Bot schließt sich dir an: Mini-Bot ins Deck.", "enabled": true},
				{"id": "repair", "label": "Rad reparieren (10)", "desc": "Er bedankt sich mit einem zufälligen seltenen Chip.", "enabled": run.frag >= 10},
			]
		"schmiede":
			var commons2: Array = run.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich")
			return [
				{"id": "forge", "label": "Schmieden (−10 HP)", "desc": "Ein zufälliger gewöhnlicher Chip wird zu einem epischen.", "enabled": not commons2.is_empty() and run.hp > 10},
				{"id": "slag", "label": "Schlacke verkaufen", "desc": "+15 Fragmente.", "enabled": true},
			]
		"lavaquelle":
			return [
				{"id": "bathe", "label": "Baden", "desc": "+25 HP.", "enabled": run.hp < run.max_hp},
				{"id": "absorb", "label": "Glut aufnehmen", "desc": "+%d Feuer-Prägung (zählt für die Evolution)." % EVENT_PRAEG, "enabled": true},
			]
		"firewallriss":
			return [
				{"id": "sneak", "label": "Durchschlüpfen", "desc": "Der nächste Gegner startet mit 25 % weniger HP.", "enabled": not run.foe_weak},
				{"id": "patch", "label": "Flicken (15)", "desc": "Firewall-Chip ins Deck und +5 max. HP.", "enabled": run.frag >= 15},
			]
		"ascheregen":
			return [
				{"id": "dig", "label": "Durchwühlen", "desc": "Halbe Chance: epischer Chip. Sonst verbrennst du dich (−15 HP).", "enabled": run.hp > 15},
				{"id": "wait", "label": "Abwarten", "desc": "Die Asche legt sich. +10 Fragmente.", "enabled": true},
			]
		"spamfilter":
			return [
				{"id": "clean", "label": "Ausmisten", "desc": "Entferne einen Chip aus deinem Deck.", "enabled": run.deck.size() > MIN_DECK},
				{"id": "read", "label": "Spam lesen", "desc": "+30 Fragmente, aber Kopfschmerzen: −10 HP.", "enabled": run.hp > 10},
			]
		"irrlicht":
			return [
				{"id": "follow", "label": "Folgen", "desc": "Meist ein seltener Chip. Manchmal ein Sumpfloch (−12 HP).", "enabled": run.hp > 12},
				{"id": "charge", "label": "Ladung abgreifen", "desc": "+%d Elektro-Prägung (zählt für die Evolution)." % EVENT_PRAEG, "enabled": true},
			]
		"giftmoor":
			return [
				{"id": "dive", "label": "Eintauchen (−8 HP)", "desc": "+%d Virus-Prägung (zählt für die Evolution)." % EVENT_PRAEG, "enabled": run.hp > 8},
				{"id": "mud", "label": "Heilschlamm", "desc": "+20 HP.", "enabled": run.hp < run.max_hp},
			]
		"orakel":
			return [
				{"id": "offer", "label": "Opfergabe (20)", "desc": "Ein zufälliger epischer Chip.", "enabled": run.frag >= 20},
				{"id": "listen", "label": "Zuhören", "desc": "+%d Wasser-Prägung, und das Orakel verrät deinen Weg." % EVENT_PRAEG, "enabled": true},
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
		["update", "install"]:
			var commons: Array = run.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich")
			var old: String = commons[run.rng.randi_range(0, commons.size() - 1)]
			var neu := run.random_chip("Selten")
			run.deck.erase(old)
			run.deck.append(neu)
			return "Update installiert: %s wurde zu %s." % [old, neu]
		["update", "later"]:
			run.frag += 10
			return "Das Fenster schließt sich höflich. Für deine Geduld gibt es 10 Fragmente."
		["cookies", "collect"]:
			run.frag += 25
			return "Du sammelst die Cookies ein und tauschst sie gegen 25 Fragmente."
		["cookies", "snack"]:
			return "Mmh, Vanille! +%d HP." % run.heal(15)
		["backup", "copy"]:
			return "copy"
		["minibot", "home"]:
			run.deck.append("Mini-Bot")
			return "Der Mini-Bot piept glücklich und rollt in dein Deck."
		["minibot", "repair"]:
			run.frag -= 10
			var c := run.random_chip("Selten")
			run.deck.append(c)
			return "Das Rad läuft wieder! Zum Dank schenkt er dir %s." % c
		["schmiede", "forge"]:
			var commons: Array = run.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich")
			var old: String = commons[run.rng.randi_range(0, commons.size() - 1)]
			var neu := run.random_chip("Episch")
			run.deck.erase(old)
			run.deck.append(neu)
			run.hp -= 10
			return "Zischend kühlt der Stahl ab: %s ist jetzt %s. Die Hitze kostet 10 HP." % [old, neu]
		["schmiede", "slag"]:
			run.frag += 15
			return "Ein Händler zahlt 15 Fragmente für die Schlacke."
		["lavaquelle", "bathe"]:
			return "Herrlich warm! +%d HP." % run.heal(25)
		["lavaquelle", "absorb"]:
			return _imprint(run, "Feuer", "%s atmet die Glut ein." % run.species)
		["firewallriss", "sneak"]:
			run.foe_weak = true
			return "Du schlüpfst durch den Riss und stellst dem Wächter ein Bein. Der nächste Gegner ist geschwächt."
		["firewallriss", "patch"]:
			run.frag -= 15
			run.deck.append("Firewall")
			run.max_hp += 5
			run.hp += 5
			return "Die Mauer ist geflickt. Ein Firewall-Chip bleibt übrig, +5 max. HP."
		["ascheregen", "dig"]:
			if run.rng.randf() < 0.5:
				var c := run.random_chip("Episch")
				run.deck.append(c)
				return "Unter der Asche liegt %s! Er kommt in dein Deck." % c
			run.hp -= 15
			return "Autsch, nur Glut! −15 HP."
		["ascheregen", "wait"]:
			run.frag += 10
			return "Als sich die Asche legt, glitzern 10 Fragmente am Boden."
		["spamfilter", "clean"]:
			return "remove"
		["spamfilter", "read"]:
			run.frag += 30
			run.hp -= 10
			return "„Sie haben gewonnen!“ … tatsächlich: 30 Fragmente. Aber der Kopf brummt: −10 HP."
		["irrlicht", "follow"]:
			if run.rng.randf() < 0.6:
				var c := run.random_chip("Selten")
				run.deck.append(c)
				return "Das Irrlicht führt dich zu %s und verpufft zufrieden." % c
			run.hp -= 12
			return "Platsch! Ein Sumpfloch. Das Irrlicht kichert: −12 HP."
		["irrlicht", "charge"]:
			return _imprint(run, "Elektro", "Es knistert! %s saugt die Ladung auf." % run.species)
		["giftmoor", "dive"]:
			run.hp -= 8
			return _imprint(run, "Virus", "%s taucht in den Schlamm (−8 HP)." % run.species)
		["giftmoor", "mud"]:
			return "Der Schlamm kühlt und heilt: +%d HP." % run.heal(20)
		["orakel", "offer"]:
			run.frag -= 20
			var c := run.random_chip("Episch")
			run.deck.append(c)
			return "Die Kröte verschluckt die Fragmente und rülpst %s aus." % c
		["orakel", "listen"]:
			var msg := _imprint(run, "Wasser", "Die Kröte murmelt uralte Weisheiten.")
			var es := run.evo_status()
			if int(es.need) == 0:
				return msg + " „Du bist am Ziel deines Weges.“"
			if es.target != "" and SaveGame.data.get("dex", {}).has(es.target):
				return msg + " „Dein Weg führt zu %s.“" % es.target
			if es.leader != "":
				return msg + " „Dein Weg führt zu %s.“" % es.leader
			return msg + " „Dein Weg ist noch offen.“"
	return "Du gehst weiter."


## Element-Prägung aus einem Ereignis: zählt wie gespielte Element-Chips (Evolution)
static func _imprint(run: RunState, el: String, text: String) -> String:
	run.praeg[el] = run.praeg.get(el, 0) + EVENT_PRAEG
	return "%s +%d %s-Prägung." % [text, EVENT_PRAEG, el]


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
