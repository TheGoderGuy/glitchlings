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
const PRICE_UPGRADE := 45
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
		"title": "Wartungsdrohne",
		"text": "Eine kleine Wartungsdrohne summt heran. Sie bietet an, einen deiner Chips aufzurüsten.",
	},
	"beeren": {
		"title": "Bit-Beeren", "zone": "wiesen",
		"text": "Am Wegrand wächst ein Strauch voller leuchtender Bit-Beeren. Sie knistern leise.",
	},
	"backup": {
		"title": "Backup-Station",
		"text": "Eine alte Backup-Station summt vor sich hin. Auf dem Display blinkt: KOPIEREN?",
	},
	"modulkapsel": {
		"title": "Modulkapsel",
		"text": "Eine halb vergrabene Kapsel summt leise. Darin steckt ein Modul, das noch funktioniert.",
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
	# ---------- Viren-Sümpfe ----------
	"datenleitung": {
		"title": "Verstopfte Datenleitung", "zone": "sumpf",
		"text": "Eine dicke Datenleitung ragt aus dem Moor und ist verstopft. Zwischen altem Datenschlamm blinkt etwas.",
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
	# ---------- Erweiterung 30.09.2026: je 2 pro Zone, 3 Lore-Ereignisse im NEST-Kern ----------
	"werkbank": {
		"title": "Alte Werkbank", "zone": "wiesen",
		"text": "Unter einem Datenbaum steht eine verlassene Werkbank. Das Werkzeug liegt noch ordentlich sortiert da.",
	},
	"pusteblumen": {
		"title": "Pusteblumenfeld", "zone": "wiesen",
		"text": "Ein ganzes Feld digitaler Pusteblumen. Jeder Windhauch trägt kleine leuchtende Bits davon.",
	},
	"obsidian": {
		"title": "Obsidianspiegel", "zone": "vulkan",
		"text": "Ein Spiegel aus schwarzem Vulkanglas. Darin sieht dein Glitchling stärker aus, als es sich gerade fühlt.",
	},
	"glutkaefer": {
		"title": "Glutkäfer-Nest", "zone": "vulkan",
		"text": "Zwischen schlafenden Glutkäfern glitzern Fragmente. Ein falscher Schritt, und das Nest wacht auf.",
	},
	"wrack": {
		"title": "Versunkenes Wrack", "zone": "sumpf",
		"text": "Ein altes Server-Gehäuse ragt schief aus dem Moor. Drinnen blinken noch ein paar Lämpchen.",
	},
	"gluehwuermer": {
		"title": "Glühwürmchen-Schwarm", "zone": "sumpf",
		"text": "Tausende Glühwürmchen tanzen über dem Wasser und summen im Takt einer Melodie, die du fast kennst.",
	},
	"logbuch": {
		"title": "Server-Logbuch", "zone": "kern",
		"text": "Ein Terminal zeigt die letzten Einträge vor dem Absturz: Fehler 0x0 … Fehler 0x0 … Ein einziger Fehler hat sich immer wieder selbst kopiert.",
	},
	"nestbewohner": {
		"title": "Versteckte Glitchlings", "zone": "kern",
		"text": "Hinter einem Lüfter kauern drei winzige Glitchlings. Sie sind nie geflohen und haben den Kern die ganze Zeit bewacht.",
	},
	"kernspeicher": {
		"title": "Kernspeicher", "zone": "kern",
		"text": "Ein Speicherturm voller alter Chips, die seit dem Absturz hier liegen. Manche sind beschädigt, andere perfekt erhalten.",
	},
}


# ---------- Rastplatz ----------

static func rest_options(run: RunState) -> Array:
	var h := roundi(run.max_hp * REST_HEAL)
	return [
		{"id": "heal", "label": "Ausruhen", "desc": "Heilt %d HP." % h, "enabled": run.hp < run.max_hp},
		{"id": "upgrade", "label": "Chip verbessern", "desc": "Ein Chip wird stärker und lädt schneller (z. B. Glutball > Glutball+).", "enabled": not run.upgradable().is_empty()},
		{"id": "remove", "label": "Deck ausdünnen", "desc": "Entferne einen Chip aus deinem Deck.", "enabled": run.deck.size() > MIN_DECK},
	]


static func rest_apply(run: RunState, id: String) -> String:
	match id:
		"heal":
			return "%s ruht sich aus: +%d HP." % [run.species, run.heal(roundi(run.max_hp * REST_HEAL))]
		"remove":
			return "remove"
		"upgrade":
			return "upgrade"
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
			var commons: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
			return [
				{"id": "install", "label": "Aufrüsten lassen", "desc": "Ein zufälliger gewöhnlicher Chip wird zu einem seltenen.", "enabled": not commons.is_empty()},
				{"id": "later", "label": "Ablehnen", "desc": "Die Drohne lässt zum Abschied 10 Fragmente da.", "enabled": true},
			]
		"beeren":
			return [
				{"id": "collect", "label": "Pflücken", "desc": "+25 Fragmente.", "enabled": true},
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
		"modulkapsel":
			return [
				{"id": "open", "label": "Einbauen", "desc": "Ein zufälliges Modul für diesen Run.", "enabled": true},
				{"id": "scrap", "label": "Ausschlachten", "desc": "+25 Fragmente.", "enabled": true},
			]
		"schmiede":
			var commons2: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
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
		"datenleitung":
			return [
				{"id": "clean", "label": "Ausmisten", "desc": "Entferne einen Chip aus deinem Deck.", "enabled": run.deck.size() > MIN_DECK},
				{"id": "read", "label": "Durchwühlen", "desc": "+30 Fragmente, aber ein Stromschlag: −10 HP.", "enabled": run.hp > 10},
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
		"werkbank":
			return [
				{"id": "tinker", "label": "Chip verbessern", "desc": "Wähle einen Chip, der stärker wird und schneller lädt.", "enabled": not run.upgradable().is_empty()},
				{"id": "sell", "label": "Werkzeug verkaufen", "desc": "+20 Fragmente.", "enabled": true},
			]
		"pusteblumen":
			return [
				{"id": "blow", "label": "Kräftig pusten", "desc": "Die Bits fliegen davon – und einer deiner Chips wird zufällig verbessert.", "enabled": not run.upgradable().is_empty()},
				{"id": "walk", "label": "Hindurchlaufen", "desc": "+15 HP.", "enabled": run.hp < run.max_hp},
			]
		"obsidian":
			return [
				{"id": "look", "label": "Hineinsehen", "desc": "+8 max. HP.", "enabled": true},
				{"id": "smash", "label": "Zerschlagen (−10 HP)", "desc": "+35 Fragmente.", "enabled": run.hp > 10},
			]
		"glutkaefer":
			return [
				{"id": "sneak", "label": "Leise sammeln", "desc": "Meist +40 Fragmente. Wacht das Nest auf: −15 HP.", "enabled": run.hp > 15},
				{"id": "take", "label": "Einen Käfer mitnehmen", "desc": "Funkenregen (Selten) kommt in dein Deck.", "enabled": true},
			]
		"wrack":
			return [
				{"id": "dive", "label": "Tauchen (−10 HP)", "desc": "Zwei zufällige Chips deines Decks werden verbessert.", "enabled": run.hp > 10 and not run.upgradable().is_empty()},
				{"id": "search", "label": "Außen absuchen", "desc": "+20 Fragmente.", "enabled": true},
			]
		"gluehwuermer":
			return [
				{"id": "dance", "label": "Mittanzen", "desc": "Heilt 30 %% deiner max. HP (%d)." % roundi(run.max_hp * 0.3), "enabled": run.hp < run.max_hp},
				{"id": "catch", "label": "Einfangen", "desc": "Ladungsfeld ins Deck und +%d Elektro-Prägung." % EVENT_PRAEG, "enabled": true},
			]
		"logbuch":
			return [
				{"id": "read", "label": "Weiterlesen", "desc": "+%d Code-Prägung. Vielleicht verstehst du, wie alles begann." % EVENT_PRAEG, "enabled": true},
				{"id": "free", "label": "Speicher freigeben", "desc": "+30 Fragmente.", "enabled": true},
			]
		"nestbewohner":
			return [
				{"id": "cheer", "label": "Mut zusprechen", "desc": "+20 HP. Im nächsten Kampf startet die Signatur-Leiste halb voll.", "enabled": true},
				{"id": "guide", "label": "Nach dem Weg fragen", "desc": "Sie kennen eine Abkürzung: Der nächste Gegner startet mit 25 % weniger HP.", "enabled": not run.foe_weak},
			]
		"kernspeicher":
			return [
				{"id": "repair", "label": "Chip reparieren", "desc": "Wähle einen Chip, der stärker wird und schneller lädt.", "enabled": not run.upgradable().is_empty()},
				{"id": "salvage", "label": "Bergen (−12 HP)", "desc": "Ein zufälliger epischer Chip.", "enabled": run.hp > 12},
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
			var commons: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
			var old: String = commons[run.rng.randi_range(0, commons.size() - 1)]
			var neu := run.random_chip("Selten")
			run.deck.erase(old)
			run.deck.append(neu)
			return "Die Drohne schraubt und piept: %s wurde zu %s." % [old, neu]
		["update", "later"]:
			run.frag += 10
			return "Die Drohne piept enttäuscht und lässt 10 Fragmente fallen."
		["beeren", "collect"]:
			run.frag += 25
			return "Du pflückst die Beeren und tauschst sie gegen 25 Fragmente."
		["beeren", "snack"]:
			return "Mmh, knisternd süß! +%d HP." % run.heal(15)
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
		["modulkapsel", "open"]:
			var m := run.roll_module({"Gewöhnlich": 5, "Selten": 3, "Episch": 1})
			if m == "":
				run.frag += 25
				return "Die Kapsel ist leer … aber 25 Fragmente liegen darin."
			run.add_module(m)
			return "Modul eingebaut: %s. %s" % [GameData.MODULES[m].name, GameData.MODULES[m].desc]
		["modulkapsel", "scrap"]:
			run.frag += 25
			return "Du zerlegst die Kapsel: 25 Fragmente."
		["schmiede", "forge"]:
			var commons: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
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
		["datenleitung", "clean"]:
			return "remove"
		["datenleitung", "read"]:
			run.frag += 30
			run.hp -= 10
			return "Im Datenschlamm liegen 30 Fragmente. Dabei bekommst du einen Stromschlag: −10 HP."
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
		["werkbank", "tinker"], ["kernspeicher", "repair"]:
			return "upgrade"
		["werkbank", "sell"]:
			run.frag += 20
			return "Ein vorbeiziehender Händler-Bot zahlt 20 Fragmente für das Werkzeug."
		["pusteblumen", "blow"]:
			var up := run.upgrade_random(1)
			return "Die Bits wirbeln um deine Chips: %s!" % up[0] if not up.is_empty() else "Die Bits fliegen davon."
		["pusteblumen", "walk"]:
			return "Die weichen Blüten kitzeln: +%d HP." % run.heal(15)
		["obsidian", "look"]:
			run.max_hp += 8
			run.hp += 8
			return "%s richtet sich auf und sieht sich selbst in die Augen: +8 max. HP." % run.species
		["obsidian", "smash"]:
			run.hp -= 10
			run.frag += 35
			return "Klirr! Die Splitter sind wertvoll: +35 Fragmente, aber −10 HP."
		["glutkaefer", "sneak"]:
			if run.rng.randf() < 0.65:
				run.frag += 40
				return "Auf Zehenspitzen sammelst du 40 Fragmente ein. Die Käfer schnarchen weiter."
			run.hp -= 15
			run.frag += 15
			return "Ein Käfer wacht auf und zwickt! −15 HP, aber immerhin 15 Fragmente."
		["glutkaefer", "take"]:
			run.deck.append("Funkenregen")
			return "Der kleine Käfer glüht zufrieden: Funkenregen kommt in dein Deck."
		["wrack", "dive"]:
			run.hp -= 10
			var up2 := run.upgrade_random(2)
			return "Im Wrack findest du Ersatzteile: %s (−10 HP)." % ", ".join(up2)
		["wrack", "search"]:
			run.frag += 20
			return "Außen am Gehäuse klemmen 20 Fragmente."
		["gluehwuermer", "dance"]:
			return "Du tanzt mit den Glühwürmchen, bis alle Sorgen verschwinden: +%d HP." % run.heal(roundi(run.max_hp * 0.3))
		["gluehwuermer", "catch"]:
			run.deck.append("Ladungsfeld")
			return _imprint(run, "Elektro", "Die Glühwürmchen summen in einem Chip weiter: Ladungsfeld kommt in dein Deck.")
		["logbuch", "read"]:
			return _imprint(run, "Code", "Ganz unten steht: „Fehler 0x0 hat sich selbst einen Namen gegeben: Ur-Glitch.“")
		["logbuch", "free"]:
			run.frag += 30
			return "Du löschst die Fehlermeldungen. Übrig bleiben 30 Fragmente."
		["nestbewohner", "cheer"]:
			run.sp_bonus = true
			return "Die drei piepsen dir hinterher: „Hol unseren NEST zurück, Operator!“ +%d HP." % run.heal(20)
		["nestbewohner", "guide"]:
			run.foe_weak = true
			return "Sie zeigen dir einen Lüftungsschacht. Der nächste Gegner wird überrascht."
		["kernspeicher", "salvage"]:
			run.hp -= 12
			var c := run.random_chip("Episch")
			run.deck.append(c)
			return "Zwischen Kurzschlüssen ziehst du %s heraus (−12 HP)." % c
	return "Du gehst weiter."


## Element-Prägung aus einem Ereignis: zählt wie gespielte Element-Chips (Evolution)
static func _imprint(run: RunState, el: String, text: String) -> String:
	run.praeg[el] = run.praeg.get(el, 0) + EVENT_PRAEG
	return "%s +%d %s-Prägung." % [text, EVENT_PRAEG, el]


# ---------- Datenhändler ----------

static func _combo_suffix(run: RunState, chip: String) -> String:
	var s := GameData.synergy(chip, run.deck, run.modules, run.mon.passive)
	return "" if s == "" else " (%s!)" % s


## Preis nach Rabattchip-Modul
static func price(run: RunState, base: int) -> int:
	return roundi(base * 0.75) if run.has_mod("rabattchip") else base


static func shop_init(run: RunState, node: Dictionary) -> void:
	if node.has("shop"):
		return
	var offers: Array = []
	for c in run.roll_choices({"Gewöhnlich": 5, "Selten": 4, "Episch": 2}):
		offers.append({"chip": c, "price": PRICE[GameData.CHIPS[c].rar], "sold": false})
	# ein Modul im Angebot
	var m := run.roll_module({"Gewöhnlich": 4, "Selten": 3, "Episch": 1})
	if m != "":
		offers.append({"module": m, "price": GameData.MODULE_PRICE[GameData.MODULES[m].rar], "sold": false})
	node.shop = {"offers": offers, "repair": false, "remove": false, "upgrade": false}


static func shop_options(run: RunState, node: Dictionary) -> Array:
	var out: Array = []
	for i in node.shop.offers.size():
		var o: Dictionary = node.shop.offers[i]
		var pr := price(run, o.price)
		if o.has("module"):
			var M: Dictionary = GameData.MODULES[o.module]
			out.append({"id": "buy_%d" % i, "label": "Modul: %s (%d)" % [M.name, pr] if not o.sold else "Modul: %s – verkauft" % M.name,
				"desc": "%s: %s" % [M.rar, M.desc], "enabled": not o.sold and run.frag >= pr, "module": o.module})
			continue
		var ch: Dictionary = GameData.CHIPS[o.chip]
		out.append({"id": "buy_%d" % i, "label": "%s (%d)" % [o.chip, pr] if not o.sold else "%s – verkauft" % o.chip,
			"desc": "%s · %s: %s%s" % [ch.el, ch.rar, ch.desc, _combo_suffix(run, o.chip)], "enabled": not o.sold and run.frag >= pr, "chip": o.chip})
	var p_rep := price(run, PRICE_REPAIR)
	var p_rem := price(run, PRICE_REMOVE)
	out.append({"id": "repair", "label": "Reparatur (%d)" % p_rep, "desc": "Heilt 25 HP. Einmal pro Besuch.",
		"enabled": not node.shop.repair and run.frag >= p_rep and run.hp < run.max_hp})
	var p_up := price(run, PRICE_UPGRADE)
	out.append({"id": "upgrade", "label": "Chip verbessern (%d)" % p_up, "desc": "Ein Chip deiner Wahl wird stärker und lädt schneller. Einmal pro Besuch.",
		"enabled": not node.shop.get("upgrade", false) and run.frag >= p_up and not run.upgradable().is_empty()})
	out.append({"id": "remove", "label": "Chip entfernen (%d)" % p_rem, "desc": "Entferne einen Chip aus deinem Deck. Einmal pro Besuch.",
		"enabled": not node.shop.remove and run.frag >= p_rem and run.deck.size() > MIN_DECK})
	return out


static func shop_apply(run: RunState, node: Dictionary, id: String) -> String:
	if id.begins_with("buy_"):
		var o: Dictionary = node.shop.offers[int(id.substr(4))]
		run.frag -= price(run, o.price)
		o.sold = true
		if o.has("module"):
			run.add_module(o.module)
			return "Modul eingebaut: %s. %s" % [GameData.MODULES[o.module].name, GameData.MODULES[o.module].desc]
		run.deck.append(o.chip)
		return "%s kommt in dein Deck." % o.chip
	match id:
		"repair":
			run.frag -= price(run, PRICE_REPAIR)
			node.shop.repair = true
			return "Repariert: +%d HP." % run.heal(25)
		"remove":
			run.frag -= price(run, PRICE_REMOVE)
			node.shop.remove = true
			return "remove"
		"upgrade":
			run.frag -= price(run, PRICE_UPGRADE)
			node.shop.upgrade = true
			return "upgrade"
	return ""
