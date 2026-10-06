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
	# ---------- Kühlwasser-See (06.10.2026) ----------
	"kuehlrohr": {
		"title": "Kühlrohr-Leck", "zone": "see",
		"text": "Aus einem dicken Kühlrohr zischt eiskaltes Wasser. Darin treiben Eissplitter, scharf wie Daten-Klingen.",
	},
	"eisscholle": {
		"title": "Treibende Eisscholle", "zone": "see",
		"text": "Auf einer Eisscholle treibt ein eingefrorener Chip vorbei. Das Eis knackt verdächtig.",
	},
	"taucherglocke": {
		"title": "Taucherglocke", "zone": "see",
		"text": "Eine alte Taucherglocke liegt im flachen Wasser. Drinnen ist noch Luft – und eine kleine Werkbank.",
	},
	"spiegelsee": {
		"title": "Stiller Spiegelsee", "zone": "see",
		"text": "Das Wasser ist so still, dass sich der ganze Server-Himmel darin spiegelt. Dein Glitchling sieht darin ein anderes Ich.",
	},
	# ---------- Hochspannungs-Steppe (06.10.2026) ----------
	"umspannwerk": {
		"title": "Verlassenes Umspannwerk", "zone": "steppe",
		"text": "Mitten in der Steppe brummt ein Umspannwerk. Die Spulen sind noch geladen, die Luft knistert.",
	},
	"gewitter": {
		"title": "Aufziehendes Gewitter", "zone": "steppe",
		"text": "Schwarze Wolken türmen sich auf. Blitze schlagen in die Masten ein, einer nach dem anderen.",
	},
	"datenherde": {
		"title": "Wilde Datenherde", "zone": "steppe",
		"text": "Eine Herde grasender Datenbüffel zieht vorbei. Ein Jungtier hat sich in einer alten Leitung verfangen.",
	},
	"relaisturm": {
		"title": "Relaisturm", "zone": "steppe",
		"text": "Ein hoher Relaisturm sendet noch immer Signale. Von oben sieht man die ganze Steppe.",
	},
}


# ---------- Rastplatz ----------

static func rest_options(run: RunState) -> Array:
	var h := roundi(run.max_hp * REST_HEAL)
	return [
		{"id": "heal", "label": T.t("Ausruhen"), "desc": T.t("Heilt %d HP.") % h, "enabled": run.hp < run.max_hp},
		{"id": "upgrade", "label": T.t("Chip verbessern"), "desc": T.t("Ein Chip wird stärker und lädt schneller (z. B. Glutball > Glutball+)."), "enabled": not run.upgradable().is_empty()},
		{"id": "remove", "label": T.t("Deck ausdünnen"), "desc": T.t("Entferne einen Chip aus deinem Deck."), "enabled": run.deck.size() > MIN_DECK},
	]


static func rest_apply(run: RunState, id: String) -> String:
	match id:
		"heal":
			return T.t("%s ruht sich aus: +%d HP.") % [T.t(run.species), run.heal(roundi(run.max_hp * REST_HEAL))]
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
				{"id": "open", "label": T.t("Öffnen"), "desc": T.t("Ein zufälliger Chip kommt in dein Deck."), "enabled": true},
				{"id": "send", "label": T.t("Zum NEST schicken"), "desc": T.t("+20 Fragmente."), "enabled": true},
			]
		"brunnen":
			return [
				{"id": "drink", "label": T.t("Trinken"), "desc": T.t("+20 HP."), "enabled": run.hp < run.max_hp},
				{"id": "throw", "label": T.t("Bits hineinwerfen (15)"), "desc": T.t("Ein zufälliger seltener Chip."), "enabled": run.frag >= 15},
				{"id": "leave", "label": T.t("Weitergehen"), "desc": T.t("Nichts passiert."), "enabled": true},
			]
		"korrupt":
			return [
				{"id": "take", "label": T.t("Nehmen"), "desc": T.t("Defrag (Episch) ins Deck, aber −10 max. HP."), "enabled": run.max_hp > 20},
				{"id": "leave", "label": T.t("Liegen lassen"), "desc": T.t("Nichts passiert."), "enabled": true},
			]
		"glitchling":
			return [
				{"id": "feed", "label": T.t("Füttern (10)"), "desc": T.t("+5 max. HP und 10 HP heilen."), "enabled": run.frag >= 10},
				{"id": "wave", "label": T.t("Winken"), "desc": T.t("Deine Signatur-Leiste startet im nächsten Kampf halb voll."), "enabled": true},
			]
		"update":
			var commons: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
			return [
				{"id": "install", "label": T.t("Aufrüsten lassen"), "desc": T.t("Ein zufälliger gewöhnlicher Chip wird zu einem seltenen."), "enabled": not commons.is_empty()},
				{"id": "later", "label": T.t("Ablehnen"), "desc": T.t("Die Drohne lässt zum Abschied 10 Fragmente da."), "enabled": true},
			]
		"beeren":
			return [
				{"id": "collect", "label": T.t("Pflücken"), "desc": T.t("+25 Fragmente."), "enabled": true},
				{"id": "snack", "label": T.t("Naschen"), "desc": T.t("+15 HP."), "enabled": run.hp < run.max_hp},
			]
		"backup":
			return [
				{"id": "copy", "label": T.t("Chip kopieren"), "desc": T.t("Ein Chip deiner Wahl kommt ein zweites Mal ins Deck."), "enabled": true},
				{"id": "leave", "label": T.t("Nicht anfassen"), "desc": T.t("Nichts passiert."), "enabled": true},
			]
		"minibot":
			return [
				{"id": "home", "label": T.t("Heimbringen"), "desc": T.t("Der Bot schließt sich dir an: Mini-Bot ins Deck."), "enabled": true},
				{"id": "repair", "label": T.t("Rad reparieren (10)"), "desc": T.t("Er bedankt sich mit einem zufälligen seltenen Chip."), "enabled": run.frag >= 10},
			]
		"modulkapsel":
			return [
				{"id": "open", "label": T.t("Einbauen"), "desc": T.t("Ein zufälliges Modul für diesen Run."), "enabled": true},
				{"id": "scrap", "label": T.t("Ausschlachten"), "desc": T.t("+25 Fragmente."), "enabled": true},
			]
		"schmiede":
			var commons2: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
			return [
				{"id": "forge", "label": T.t("Schmieden (−10 HP)"), "desc": T.t("Ein zufälliger gewöhnlicher Chip wird zu einem epischen."), "enabled": not commons2.is_empty() and run.hp > 10},
				{"id": "slag", "label": T.t("Schlacke verkaufen"), "desc": T.t("+15 Fragmente."), "enabled": true},
			]
		"lavaquelle":
			return [
				{"id": "bathe", "label": T.t("Baden"), "desc": T.t("+25 HP."), "enabled": run.hp < run.max_hp},
				{"id": "absorb", "label": T.t("Glut aufnehmen"), "desc": T.t("+%d Feuer-Prägung (zählt für die Evolution).") % EVENT_PRAEG, "enabled": true},
			]
		"firewallriss":
			return [
				{"id": "sneak", "label": T.t("Durchschlüpfen"), "desc": T.t("Der nächste Gegner startet mit 25 % weniger HP."), "enabled": not run.foe_weak},
				{"id": "patch", "label": T.t("Flicken (15)"), "desc": T.t("Firewall-Chip ins Deck und +5 max. HP."), "enabled": run.frag >= 15},
			]
		"ascheregen":
			return [
				{"id": "dig", "label": T.t("Durchwühlen"), "desc": T.t("Halbe Chance: epischer Chip. Sonst verbrennst du dich (−15 HP)."), "enabled": run.hp > 15},
				{"id": "wait", "label": T.t("Abwarten"), "desc": T.t("Die Asche legt sich. +10 Fragmente."), "enabled": true},
			]
		"datenleitung":
			return [
				{"id": "clean", "label": T.t("Ausmisten"), "desc": T.t("Entferne einen Chip aus deinem Deck."), "enabled": run.deck.size() > MIN_DECK},
				{"id": "read", "label": T.t("Durchwühlen"), "desc": T.t("+30 Fragmente, aber ein Stromschlag: −10 HP."), "enabled": run.hp > 10},
			]
		"irrlicht":
			return [
				{"id": "follow", "label": T.t("Folgen"), "desc": T.t("Meist ein seltener Chip. Manchmal ein Sumpfloch (−12 HP)."), "enabled": run.hp > 12},
				{"id": "charge", "label": T.t("Ladung abgreifen"), "desc": T.t("+%d Elektro-Prägung (zählt für die Evolution).") % EVENT_PRAEG, "enabled": true},
			]
		"giftmoor":
			return [
				{"id": "dive", "label": T.t("Eintauchen (−8 HP)"), "desc": T.t("+%d Virus-Prägung (zählt für die Evolution).") % EVENT_PRAEG, "enabled": run.hp > 8},
				{"id": "mud", "label": T.t("Heilschlamm"), "desc": T.t("+20 HP."), "enabled": run.hp < run.max_hp},
			]
		"orakel":
			return [
				{"id": "offer", "label": T.t("Opfergabe (20)"), "desc": T.t("Ein zufälliger epischer Chip."), "enabled": run.frag >= 20},
				{"id": "listen", "label": T.t("Zuhören"), "desc": T.t("+%d Wasser-Prägung, und das Orakel verrät deinen Weg.") % EVENT_PRAEG, "enabled": true},
			]
		"werkbank":
			return [
				{"id": "tinker", "label": T.t("Chip verbessern"), "desc": T.t("Wähle einen Chip, der stärker wird und schneller lädt."), "enabled": not run.upgradable().is_empty()},
				{"id": "sell", "label": T.t("Werkzeug verkaufen"), "desc": T.t("+20 Fragmente."), "enabled": true},
			]
		"pusteblumen":
			return [
				{"id": "blow", "label": T.t("Kräftig pusten"), "desc": T.t("Die Bits fliegen davon – und einer deiner Chips wird zufällig verbessert."), "enabled": not run.upgradable().is_empty()},
				{"id": "walk", "label": T.t("Hindurchlaufen"), "desc": T.t("+15 HP."), "enabled": run.hp < run.max_hp},
			]
		"obsidian":
			return [
				{"id": "look", "label": T.t("Hineinsehen"), "desc": T.t("+8 max. HP."), "enabled": true},
				{"id": "smash", "label": T.t("Zerschlagen (−10 HP)"), "desc": T.t("+35 Fragmente."), "enabled": run.hp > 10},
			]
		"glutkaefer":
			return [
				{"id": "sneak", "label": T.t("Leise sammeln"), "desc": T.t("Meist +40 Fragmente. Wacht das Nest auf: −15 HP."), "enabled": run.hp > 15},
				{"id": "take", "label": T.t("Einen Käfer mitnehmen"), "desc": T.t("Funkenregen (Selten) kommt in dein Deck."), "enabled": true},
			]
		"wrack":
			return [
				{"id": "dive", "label": T.t("Tauchen (−10 HP)"), "desc": T.t("Zwei zufällige Chips deines Decks werden verbessert."), "enabled": run.hp > 10 and not run.upgradable().is_empty()},
				{"id": "search", "label": T.t("Außen absuchen"), "desc": T.t("+20 Fragmente."), "enabled": true},
			]
		"gluehwuermer":
			return [
				{"id": "dance", "label": T.t("Mittanzen"), "desc": T.t("Heilt 30 %% deiner max. HP (%d).") % roundi(run.max_hp * 0.3), "enabled": run.hp < run.max_hp},
				{"id": "catch", "label": T.t("Einfangen"), "desc": T.t("Ladungsfeld ins Deck und +%d Elektro-Prägung.") % EVENT_PRAEG, "enabled": true},
			]
		"kuehlrohr":
			return [
				{"id": "seal", "label": T.t("Abdichten (−10 HP)"), "desc": T.t("Frostsplitter kommt in dein Deck."), "enabled": run.hp > 10},
				{"id": "cool", "label": T.t("Abkühlen"), "desc": T.t("+%d Wasser-Prägung (zählt für die Evolution).") % EVENT_PRAEG, "enabled": true},
			]
		"eisscholle":
			return [
				{"id": "break", "label": T.t("Herausbrechen"), "desc": T.t("Meist ein seltener Chip. Manchmal kippt die Scholle (−12 HP)."), "enabled": run.hp > 12},
				{"id": "float", "label": T.t("Auf der Scholle ausruhen"), "desc": T.t("+15 HP."), "enabled": run.hp < run.max_hp},
			]
		"taucherglocke":
			return [
				{"id": "tinker", "label": T.t("Chip verbessern"), "desc": T.t("Wähle einen Chip, der stärker wird und schneller lädt."), "enabled": not run.upgradable().is_empty()},
				{"id": "salvage", "label": T.t("Ausräumen"), "desc": T.t("+25 Fragmente."), "enabled": true},
			]
		"spiegelsee":
			return [
				{"id": "look", "label": T.t("Hineinschauen"), "desc": T.t("+%d Code-Prägung (zählt für die Evolution).") % EVENT_PRAEG, "enabled": true},
				{"id": "wish", "label": T.t("Wunsch (20 Fragmente)"), "desc": T.t("+10 max. HP."), "enabled": run.frag >= 20},
			]
		"umspannwerk":
			return [
				{"id": "charge", "label": T.t("Aufladen (−10 HP)"), "desc": T.t("+%d Elektro-Prägung, und im nächsten Kampf startet die Signatur-Leiste halb voll.") % EVENT_PRAEG, "enabled": run.hp > 10},
				{"id": "copper", "label": T.t("Kupfer abbauen"), "desc": T.t("+30 Fragmente."), "enabled": true},
			]
		"gewitter":
			return [
				{"id": "shelter", "label": T.t("Unterstellen"), "desc": T.t("+15 HP."), "enabled": run.hp < run.max_hp},
				{"id": "catch", "label": T.t("Blitz einfangen (−12 HP)"), "desc": T.t("Kettenblitz kommt in dein Deck."), "enabled": run.hp > 12},
			]
		"datenherde":
			return [
				{"id": "free", "label": T.t("Befreien"), "desc": T.t("+8 max. HP – die Herde dankt es dir."), "enabled": true},
				{"id": "follow", "label": T.t("Den Spuren folgen"), "desc": T.t("+25 Fragmente."), "enabled": true},
			]
		"relaisturm":
			return [
				{"id": "climb", "label": T.t("Hochklettern (−8 HP)"), "desc": T.t("Von oben siehst du eine Abkürzung: Der nächste Gegner startet mit 25 % weniger HP."), "enabled": run.hp > 8 and not run.foe_weak},
				{"id": "jam", "label": T.t("Signal stören"), "desc": T.t("+%d Virus-Prägung (zählt für die Evolution).") % EVENT_PRAEG, "enabled": true},
			]
		"logbuch":
			return [
				{"id": "read", "label": T.t("Weiterlesen"), "desc": T.t("+%d Code-Prägung. Vielleicht verstehst du, wie alles begann.") % EVENT_PRAEG, "enabled": true},
				{"id": "free", "label": T.t("Speicher freigeben"), "desc": T.t("+30 Fragmente."), "enabled": true},
			]
		"nestbewohner":
			return [
				{"id": "cheer", "label": T.t("Mut zusprechen"), "desc": T.t("+20 HP. Im nächsten Kampf startet die Signatur-Leiste halb voll."), "enabled": true},
				{"id": "guide", "label": T.t("Nach dem Weg fragen"), "desc": T.t("Sie kennen eine Abkürzung: Der nächste Gegner startet mit 25 % weniger HP."), "enabled": not run.foe_weak},
			]
		"kernspeicher":
			return [
				{"id": "repair", "label": T.t("Chip reparieren"), "desc": T.t("Wähle einen Chip, der stärker wird und schneller lädt."), "enabled": not run.upgradable().is_empty()},
				{"id": "salvage", "label": T.t("Bergen (−12 HP)"), "desc": T.t("Ein zufälliger epischer Chip."), "enabled": run.hp > 12},
			]
	return []


static func event_apply(run: RunState, key: String, id: String) -> String:
	match [key, id]:
		["datenpaket", "open"]:
			var c := run.random_chip()
			run.deck.append(c)
			return T.t("Im Paket steckt %s. Er kommt in dein Deck.") % T.chip(c)
		["datenpaket", "send"]:
			run.frag += 20
			return T.t("Der NEST bedankt sich mit 20 Fragmenten.")
		["brunnen", "drink"]:
			return T.t("Erfrischend! +%d HP.") % run.heal(20)
		["brunnen", "throw"]:
			run.frag -= 15
			var c := run.random_chip("Selten")
			run.deck.append(c)
			return T.t("Der Brunnen blubbert und spuckt %s aus.") % T.chip(c)
		["korrupt", "take"]:
			run.deck.append("Defrag")
			run.max_hp -= 10
			run.hp = mini(run.hp, run.max_hp)
			return T.t("Defrag gehört jetzt dir. Das Flackern kostet 10 max. HP.")
		["glitchling", "feed"]:
			run.frag -= 10
			run.max_hp += 5
			run.heal(10)
			return T.t("Der Glitchling mampft glücklich und schenkt dir etwas Energie: +5 max. HP.")
		["glitchling", "wave"]:
			run.sp_bonus = true
			return T.t("Der Glitchling winkt zurück. Du fühlst dich motiviert!")
		["update", "install"]:
			var commons: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
			var old: String = commons[run.rng.randi_range(0, commons.size() - 1)]
			var neu := run.random_chip("Selten")
			run.deck.erase(old)
			run.deck.append(neu)
			return T.t("Die Drohne schraubt und piept: %s wurde zu %s.") % [T.chip(old), T.chip(neu)]
		["update", "later"]:
			run.frag += 10
			return T.t("Die Drohne piept enttäuscht und lässt 10 Fragmente fallen.")
		["beeren", "collect"]:
			run.frag += 25
			return T.t("Du pflückst die Beeren und tauschst sie gegen 25 Fragmente.")
		["beeren", "snack"]:
			return T.t("Mmh, knisternd süß! +%d HP.") % run.heal(15)
		["backup", "copy"]:
			return "copy"
		["minibot", "home"]:
			run.deck.append("Mini-Bot")
			return T.t("Der Mini-Bot piept glücklich und rollt in dein Deck.")
		["minibot", "repair"]:
			run.frag -= 10
			var c := run.random_chip("Selten")
			run.deck.append(c)
			return T.t("Das Rad läuft wieder! Zum Dank schenkt er dir %s.") % T.chip(c)
		["modulkapsel", "open"]:
			var m := run.roll_module({"Gewöhnlich": 5, "Selten": 3, "Episch": 1})
			if m == "":
				run.frag += 25
				return T.t("Die Kapsel ist leer … aber 25 Fragmente liegen darin.")
			run.add_module(m)
			return T.t("Modul eingebaut: %s. %s") % [T.t(GameData.MODULES[m].name), T.t(GameData.MODULES[m].desc)]
		["modulkapsel", "scrap"]:
			run.frag += 25
			return T.t("Du zerlegst die Kapsel: 25 Fragmente.")
		["schmiede", "forge"]:
			var commons: Array = run.deck.filter(func(c): return GameData.chip(c).rar == "Gewöhnlich")
			var old: String = commons[run.rng.randi_range(0, commons.size() - 1)]
			var neu := run.random_chip("Episch")
			run.deck.erase(old)
			run.deck.append(neu)
			run.hp -= 10
			return T.t("Zischend kühlt der Stahl ab: %s ist jetzt %s. Die Hitze kostet 10 HP.") % [T.chip(old), T.chip(neu)]
		["schmiede", "slag"]:
			run.frag += 15
			return T.t("Ein Händler zahlt 15 Fragmente für die Schlacke.")
		["lavaquelle", "bathe"]:
			return T.t("Herrlich warm! +%d HP.") % run.heal(25)
		["lavaquelle", "absorb"]:
			return _imprint(run, "Feuer", T.t("%s atmet die Glut ein.") % T.t(run.species))
		["firewallriss", "sneak"]:
			run.foe_weak = true
			return T.t("Du schlüpfst durch den Riss und stellst dem Wächter ein Bein. Der nächste Gegner ist geschwächt.")
		["firewallriss", "patch"]:
			run.frag -= 15
			run.deck.append("Firewall")
			run.max_hp += 5
			run.hp += 5
			return T.t("Die Mauer ist geflickt. Ein Firewall-Chip bleibt übrig, +5 max. HP.")
		["ascheregen", "dig"]:
			if run.rng.randf() < 0.5:
				var c := run.random_chip("Episch")
				run.deck.append(c)
				return T.t("Unter der Asche liegt %s! Er kommt in dein Deck.") % T.chip(c)
			run.hp -= 15
			return T.t("Autsch, nur Glut! −15 HP.")
		["ascheregen", "wait"]:
			run.frag += 10
			return T.t("Als sich die Asche legt, glitzern 10 Fragmente am Boden.")
		["datenleitung", "clean"]:
			return "remove"
		["datenleitung", "read"]:
			run.frag += 30
			run.hp -= 10
			return T.t("Im Datenschlamm liegen 30 Fragmente. Dabei bekommst du einen Stromschlag: −10 HP.")
		["irrlicht", "follow"]:
			if run.rng.randf() < 0.6:
				var c := run.random_chip("Selten")
				run.deck.append(c)
				return T.t("Das Irrlicht führt dich zu %s und verpufft zufrieden.") % T.chip(c)
			run.hp -= 12
			return T.t("Platsch! Ein Sumpfloch. Das Irrlicht kichert: −12 HP.")
		["irrlicht", "charge"]:
			return _imprint(run, "Elektro", T.t("Es knistert! %s saugt die Ladung auf.") % T.t(run.species))
		["giftmoor", "dive"]:
			run.hp -= 8
			return _imprint(run, "Virus", T.t("%s taucht in den Schlamm (−8 HP).") % T.t(run.species))
		["giftmoor", "mud"]:
			return T.t("Der Schlamm kühlt und heilt: +%d HP.") % run.heal(20)
		["orakel", "offer"]:
			run.frag -= 20
			var c := run.random_chip("Episch")
			run.deck.append(c)
			return T.t("Die Kröte verschluckt die Fragmente und rülpst %s aus.") % T.chip(c)
		["orakel", "listen"]:
			var msg := _imprint(run, "Wasser", T.t("Die Kröte murmelt uralte Weisheiten."))
			var es := run.evo_status()
			if int(es.need) == 0:
				return msg + T.t(" „Du bist am Ziel deines Weges.“")
			if es.target != "" and SaveGame.data.get("dex", {}).has(es.target):
				return msg + T.t(" „Dein Weg führt zu %s.“") % T.t(es.target)
			if es.leader != "":
				return msg + T.t(" „Dein Weg führt zu %s.“") % T.t(es.leader)
			return msg + T.t(" „Dein Weg ist noch offen.“")
		["werkbank", "tinker"], ["kernspeicher", "repair"]:
			return "upgrade"
		["werkbank", "sell"]:
			run.frag += 20
			return T.t("Ein vorbeiziehender Händler-Bot zahlt 20 Fragmente für das Werkzeug.")
		["pusteblumen", "blow"]:
			var up := run.upgrade_random(1)
			return T.t("Die Bits wirbeln um deine Chips: %s!") % T.chip(up[0]) if not up.is_empty() else T.t("Die Bits fliegen davon.")
		["pusteblumen", "walk"]:
			return T.t("Die weichen Blüten kitzeln: +%d HP.") % run.heal(15)
		["obsidian", "look"]:
			run.max_hp += 8
			run.hp += 8
			return T.t("%s richtet sich auf und sieht sich selbst in die Augen: +8 max. HP.") % T.t(run.species)
		["obsidian", "smash"]:
			run.hp -= 10
			run.frag += 35
			return T.t("Klirr! Die Splitter sind wertvoll: +35 Fragmente, aber −10 HP.")
		["glutkaefer", "sneak"]:
			if run.rng.randf() < 0.65:
				run.frag += 40
				return T.t("Auf Zehenspitzen sammelst du 40 Fragmente ein. Die Käfer schnarchen weiter.")
			run.hp -= 15
			run.frag += 15
			return T.t("Ein Käfer wacht auf und zwickt! −15 HP, aber immerhin 15 Fragmente.")
		["glutkaefer", "take"]:
			run.deck.append("Funkenregen")
			return T.t("Der kleine Käfer glüht zufrieden: Funkenregen kommt in dein Deck.")
		["wrack", "dive"]:
			run.hp -= 10
			var up2 := run.upgrade_random(2)
			return T.t("Im Wrack findest du Ersatzteile: %s (−10 HP).") % T.names(up2)
		["wrack", "search"]:
			run.frag += 20
			return T.t("Außen am Gehäuse klemmen 20 Fragmente.")
		["gluehwuermer", "dance"]:
			return T.t("Du tanzt mit den Glühwürmchen, bis alle Sorgen verschwinden: +%d HP.") % run.heal(roundi(run.max_hp * 0.3))
		["gluehwuermer", "catch"]:
			run.deck.append("Ladungsfeld")
			return _imprint(run, "Elektro", T.t("Die Glühwürmchen summen in einem Chip weiter: Ladungsfeld kommt in dein Deck."))
		["logbuch", "read"]:
			return _imprint(run, "Code", T.t("Ganz unten steht: „Fehler 0x0 hat sich selbst einen Namen gegeben: Ur-Glitch.“"))
		["logbuch", "free"]:
			run.frag += 30
			return T.t("Du löschst die Fehlermeldungen. Übrig bleiben 30 Fragmente.")
		["nestbewohner", "cheer"]:
			run.sp_bonus = true
			return T.t("Die drei piepsen dir hinterher: „Hol unseren NEST zurück, Operator!“ +%d HP.") % run.heal(20)
		["nestbewohner", "guide"]:
			run.foe_weak = true
			return T.t("Sie zeigen dir einen Lüftungsschacht. Der nächste Gegner wird überrascht.")
		["kuehlrohr", "seal"]:
			run.hp -= 10
			run.deck.append("Frostsplitter")
			return T.t("Du drückst das Leck zu. Ein Eissplitter bleibt hängen: Frostsplitter kommt in dein Deck (−10 HP).")
		["kuehlrohr", "cool"]:
			return _imprint(run, "Wasser", T.t("%s lässt sich vom kalten Wasser umspülen.") % T.t(run.species))
		["eisscholle", "break"]:
			if run.rng.randf() < 0.6:
				var c := run.random_chip("Selten")
				run.deck.append(c)
				return T.t("Krach! %s ist frei und kommt in dein Deck.") % T.chip(c)
			run.hp -= 12
			return T.t("Platsch! Die Scholle kippt: −12 HP.")
		["eisscholle", "float"]:
			return T.t("Die Scholle schaukelt sanft: +%d HP.") % run.heal(15)
		["taucherglocke", "tinker"]:
			return "upgrade"
		["taucherglocke", "salvage"]:
			run.frag += 25
			return T.t("Unter der Werkbank liegen 25 Fragmente.")
		["spiegelsee", "look"]:
			return _imprint(run, "Code", T.t("Im Spiegelbild leuchten Schaltkreise auf."))
		["spiegelsee", "wish"]:
			run.frag -= 20
			run.max_hp += 10
			run.hp += 10
			return T.t("Die Fragmente versinken glitzernd: +10 max. HP.")
		["umspannwerk", "charge"]:
			run.hp -= 10
			run.sp_bonus = true
			return _imprint(run, "Elektro", T.t("Bzzzt! %s ist bis in die Schwanzspitze geladen (−10 HP).") % T.t(run.species))
		["umspannwerk", "copper"]:
			run.frag += 30
			return T.t("Aus den alten Spulen gewinnst du 30 Fragmente.")
		["gewitter", "shelter"]:
			return T.t("Unter einem Felsvorsprung wartest du das Gewitter ab: +%d HP.") % run.heal(15)
		["gewitter", "catch"]:
			run.hp -= 12
			run.deck.append("Kettenblitz")
			return T.t("Zack! Der Blitz trifft – und bleibt als Kettenblitz in deinem Deck (−12 HP).")
		["datenherde", "free"]:
			run.max_hp += 8
			run.hp += 8
			return T.t("Das Jungtier stupst %s dankbar an: +8 max. HP.") % T.t(run.species)
		["datenherde", "follow"]:
			run.frag += 25
			return T.t("Die Spuren führen zu 25 Fragmenten im hohen Gras.")
		["relaisturm", "climb"]:
			run.hp -= 8
			run.foe_weak = true
			return T.t("Von oben siehst du einen Schleichweg. Der nächste Gegner wird überrascht (−8 HP).")
		["relaisturm", "jam"]:
			return _imprint(run, "Virus", T.t("Rauschen! %s verzerrt das Signal.") % T.t(run.species))
		["kernspeicher", "salvage"]:
			run.hp -= 12
			var c := run.random_chip("Episch")
			run.deck.append(c)
			return T.t("Zwischen Kurzschlüssen ziehst du %s heraus (−12 HP).") % T.chip(c)
	return T.t("Du gehst weiter.")


## Element-Prägung aus einem Ereignis: zählt wie gespielte Element-Chips (Evolution)
static func _imprint(run: RunState, el: String, text: String) -> String:
	run.praeg[el] = run.praeg.get(el, 0) + EVENT_PRAEG
	return T.t("%s +%d %s-Prägung.") % [text, EVENT_PRAEG, T.t(el)]


# ---------- Datenhändler ----------

static func _combo_suffix(run: RunState, chip: String) -> String:
	var s := GameData.synergy(chip, run.deck, run.modules, run.mon.passive)
	return "" if s == "" else " (%s!)" % T.t(s)


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
			out.append({"id": "buy_%d" % i, "label": T.t("Modul: %s (%d)") % [T.t(M.name), pr] if not o.sold else T.t("Modul: %s – verkauft") % T.t(M.name),
				"desc": "%s: %s" % [T.t(M.rar), T.t(M.desc)], "enabled": not o.sold and run.frag >= pr, "module": o.module})
			continue
		var ch: Dictionary = GameData.CHIPS[o.chip]
		out.append({"id": "buy_%d" % i, "label": "%s (%d)" % [T.chip(o.chip), pr] if not o.sold else T.t("%s – verkauft") % T.chip(o.chip),
			"desc": "%s · %s · %s: %s%s" % [T.t(GameData.ROLE_NAMES[GameData.role(o.chip)]), T.t(ch.el), T.t(ch.rar), T.t(ch.desc), _combo_suffix(run, o.chip)], "enabled": not o.sold and run.frag >= pr, "chip": o.chip})
	var p_rep := price(run, PRICE_REPAIR)
	var p_rem := price(run, PRICE_REMOVE)
	out.append({"id": "repair", "label": T.t("Reparatur (%d)") % p_rep, "desc": T.t("Heilt 25 HP. Einmal pro Besuch."),
		"enabled": not node.shop.repair and run.frag >= p_rep and run.hp < run.max_hp})
	var p_up := price(run, PRICE_UPGRADE)
	out.append({"id": "upgrade", "label": T.t("Chip verbessern (%d)") % p_up, "desc": T.t("Ein Chip deiner Wahl wird stärker und lädt schneller. Einmal pro Besuch."),
		"enabled": not node.shop.get("upgrade", false) and run.frag >= p_up and not run.upgradable().is_empty()})
	out.append({"id": "remove", "label": T.t("Chip entfernen (%d)") % p_rem, "desc": T.t("Entferne einen Chip aus deinem Deck. Einmal pro Besuch."),
		"enabled": not node.shop.remove and run.frag >= p_rem and run.deck.size() > MIN_DECK})
	return out


static func shop_apply(run: RunState, node: Dictionary, id: String) -> String:
	if id.begins_with("buy_"):
		var o: Dictionary = node.shop.offers[int(id.substr(4))]
		run.frag -= price(run, o.price)
		o.sold = true
		if o.has("module"):
			run.add_module(o.module)
			return T.t("Modul eingebaut: %s. %s") % [T.t(GameData.MODULES[o.module].name), T.t(GameData.MODULES[o.module].desc)]
		run.deck.append(o.chip)
		return T.t("%s kommt in dein Deck.") % T.chip(o.chip)
	match id:
		"repair":
			run.frag -= price(run, PRICE_REPAIR)
			node.shop.repair = true
			return T.t("Repariert: +%d HP.") % run.heal(25)
		"remove":
			run.frag -= price(run, PRICE_REMOVE)
			node.shop.remove = true
			return "remove"
		"upgrade":
			run.frag -= price(run, PRICE_UPGRADE)
			node.shop.upgrade = true
			return "upgrade"
	return ""
