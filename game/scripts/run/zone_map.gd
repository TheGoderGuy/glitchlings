class_name ZoneMap
extends RefCounted
## Verzweigte Karte einer Ebene (ähnlich Slay the Spire): Etagen 0–4, danach der Wächter (Ebene 1 und 2)
## bzw. der Zonenboss (letzte Ebene). Eine Zone hat 3 Ebenen, die Finalzone 2.
## Knoten: {"type": fight|elite|event|rest|shop|guard|boss, "x": 0..1, "next": [Indizes der nächsten Etage]}

const FLOORS := 5   # Etagen je Ebene (ohne Wächter/Boss)
const LEVELS := 3   # Ebenen je Zone

const TYPE_NAMES := {
	"fight": "Kampf", "elite": "Elite", "event": "Ereignis", "rest": "Rastplatz", "shop": "Datenhändler", "guard": "Wächter", "boss": "Boss",
}
const TYPE_DESC := {
	"fight": "Ein korrumpierter Glitchling. Belohnung: Chipwahl und Fragmente.",
	"elite": "Ein besonders starker Gegner. Belohnung: seltenere Chips und viele Fragmente.",
	"event": "Irgendetwas passiert hier. Überraschung!",
	"rest": "Ausruhen oder dein Deck ausdünnen.",
	"shop": "Tausche Fragmente gegen Chips, Reparaturen und mehr.",
	"guard": "Bewacht den Weg zur nächsten Ebene. Belohnung: ein Modul, ein seltener Chip und Erholung.",
	"boss": "Der Herrscher dieser Zone.",
}

var zone := "wiesen"
var zone_name := "Cache-Wiesen"
var floors: Array = []
var level := 0      # 0-basiert
var levels := LEVELS


static func generate(rng: RandomNumberGenerator, zone := "wiesen", level := 0) -> ZoneMap:
	var m := ZoneMap.new()
	m.zone = zone
	m.zone_name = GameData.ZONES[zone].name
	m.level = level
	m.levels = GameData.ZONES[zone].get("levels", LEVELS)   # Finalzone ist kürzer
	var n_floors: int = GameData.ZONES[zone].get("floors", FLOORS)
	for f in n_floors:
		var n := 3 if f == 0 else rng.randi_range(2, 4)
		var row: Array = []
		for i in n:
			var x := (i + 0.5) / n + rng.randf_range(-0.05, 0.05)
			row.append({"type": _roll_type(rng, f, n_floors, level), "x": clampf(x, 0.05, 0.95), "next": []})
		m.floors.append(row)
	m.floors.append([{"type": "boss" if m.is_last_level() else "guard", "x": 0.5, "next": []}])
	for f in m.floors.size() - 1:
		_connect(rng, m.floors[f], m.floors[f + 1])
	return m


## Etage 0 der ersten Ebene ist immer ein Kampf, die letzte Etage jeder Ebene eine Rast vor Wächter/Boss.
static func _roll_type(rng: RandomNumberGenerator, f: int, n_floors := FLOORS, level := 0) -> String:
	if f == 0 and level == 0:
		return "fight"
	if f == n_floors - 1:
		return "rest"
	var g := level * n_floors + f   # Etage über die ganze Zone gezählt
	var w := {"fight": 45, "event": 22}
	if g >= 2:
		w["elite"] = 12
		w["shop"] = 11
	if g >= 3 and f >= 1:
		w["rest"] = 10
	var total := 0
	for k in w:
		total += w[k]
	var roll := rng.randi_range(1, total)
	for k in w:
		roll -= w[k]
		if roll <= 0:
			return k
	return "fight"


## Treppen-Verbindung zweier sortierter Etagen: jeder Knoten bekommt mindestens eine Kante,
## Kanten kreuzen sich nie.
static func _connect(rng: RandomNumberGenerator, a: Array, b: Array) -> void:
	var i := 0
	var k := 0
	while true:
		if not a[i].next.has(k):
			a[i].next.append(k)
		if i == a.size() - 1 and k == b.size() - 1:
			break
		if i == a.size() - 1:
			k += 1
		elif k == b.size() - 1:
			i += 1
		else:
			match rng.randi_range(0, 2):
				0:
					i += 1
				1:
					k += 1
				_:
					i += 1
					k += 1


func node(f: int, i: int) -> Dictionary:
	return floors[f][i]


func boss_floor() -> int:
	return floors.size() - 1


func is_last_level() -> bool:
	return level >= levels - 1
