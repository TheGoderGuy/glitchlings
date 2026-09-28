class_name ZoneMap
extends RefCounted
## Verzweigte Zonenkarte (ähnlich Slay the Spire): Etagen 0–6, danach der Boss.
## Knoten: {"type": fight|elite|event|rest|shop|boss, "x": 0..1, "next": [Indizes der nächsten Etage]}

const FLOORS := 7

const TYPE_NAMES := {
	"fight": "Kampf", "elite": "Elite", "event": "Ereignis", "rest": "Rastplatz", "shop": "Datenhändler", "boss": "Boss",
}
const TYPE_DESC := {
	"fight": "Ein korrumpierter Glitchling. Belohnung: Chipwahl und Fragmente.",
	"elite": "Ein besonders starker Gegner. Belohnung: seltenere Chips und viele Fragmente.",
	"event": "Irgendetwas passiert hier. Überraschung!",
	"rest": "Ausruhen oder dein Deck ausdünnen.",
	"shop": "Tausche Fragmente gegen Chips, Reparaturen und mehr.",
	"boss": "Der Herrscher dieser Zone.",
}

var zone_name := "Cache-Wiesen"
var floors: Array = []


static func generate(rng: RandomNumberGenerator) -> ZoneMap:
	var m := ZoneMap.new()
	for f in FLOORS:
		var n := 3 if f == 0 else rng.randi_range(2, 4)
		var row: Array = []
		for i in n:
			var x := (i + 0.5) / n + rng.randf_range(-0.05, 0.05)
			row.append({"type": _roll_type(rng, f), "x": clampf(x, 0.05, 0.95), "next": []})
		m.floors.append(row)
	m.floors.append([{"type": "boss", "x": 0.5, "next": []}])
	for f in m.floors.size() - 1:
		_connect(rng, m.floors[f], m.floors[f + 1])
	return m


static func _roll_type(rng: RandomNumberGenerator, f: int) -> String:
	if f == 0:
		return "fight"
	if f == FLOORS - 1:
		return "rest"
	var w := {"fight": 45, "event": 22}
	if f >= 2:
		w["elite"] = 12
		w["shop"] = 11
	if f >= 3:
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
