class_name HomeSim
extends RefCounted
## Zuhause in der Station (06.10.2026): Die Team-Glitchlinge laufen herum, schlafen, spielen miteinander,
## besuchen ihren Lieblingsplatz (je Element) und freuen sich übers Streicheln. Reine Atmosphäre, keine Spielwerte.

const MAX := 12
## Laufbereich (Fußpositionen) unter dem Horizont
const AREA := Rect2(36, 242, 568, 96)
## Gewicht der Tiefe beim Abstandhalten (kleiner = Bewohner verteilen sich vor allem nebeneinander)
const DEPTH := 0.6
## Lieblingsplätze je Element (Fußposition); die Requisiten zeichnet die Station an diese Stellen
const SPOTS := {
	"Feuer": Vector2(536, 318), "Wasser": Vector2(150, 330), "Elektro": Vector2(380, 256),
	"Code": Vector2(470, 252), "Virus": Vector2(270, 334), "Neutral": Vector2(318, 288),
}
## Linien, die schweben statt zu laufen
const FLYERS := ["Kauzbit", "Plapperli", "Sternwal"]
## Reaktion aufs Streicheln je Tierart (bei Fusionen zählt das erste Tier)
const PET_TEXT := {
	"Katze": "%s schnurrt zufrieden.", "Welpe": "%s wedelt wild mit dem Schwanz.", "Axolotl": "%s blubbert fröhlich.",
	"Hamster": "%s quiekt vergnügt.", "Hase": "%s klopft glücklich mit der Pfote.", "Frosch": "%s quakt begeistert.",
	"Salamander": "%s schmiegt sich an dich.", "Bär": "%s brummt zufrieden.", "Robo-Eule": "%s piept und plustert sich auf.",
	"Dachs": "%s rollt sich auf den Rücken.", "Waschbär": "%s putzt sich verlegen die Pfoten.",
	"Otter": "%s schlägt einen kleinen Purzelbaum.", "Ara": "%s plappert: „Nochmal! Nochmal!“",
	"Hirsch": "%s neigt sanft das Geweih.", "Kirin": "%s schnaubt kleine Funken.", "Wal": "%s singt ein leises Walsignal.",
	"Basilisk": "%s blinzelt dich ganz vorsichtig an.", "Greif": "%s plustert stolz die Federn auf.", "Sphinx": "%s stellt dir ein Rätsel und schnurrt.",
}

## Tageszeiten (07.10.2026): wechseln mit jedem Run; nachts wird mehr geschlafen, tagsüber mehr gespielt.
## Anteile für walk, idle, sleep, spot; der Rest ist Spielen.
const DAYTIMES := ["morgen", "tag", "abend", "nacht"]
const DAY_MOOD := {
	"morgen": [0.40, 0.18, 0.10, 0.18], "tag": [0.42, 0.14, 0.04, 0.20],
	"abend": [0.34, 0.18, 0.14, 0.20], "nacht": [0.22, 0.14, 0.42, 0.12],
}

var residents: Array = []
var fx: Array = []        # kleine Effekte {kind, x, y, t, max, vx, vy}
var daytime := "nacht"
var newcomer := -1        # Index des Bewohners, der gerade einzieht
var rng := RandomNumberGenerator.new()


func setup(team: Array, seed_v := 0) -> void:
	if seed_v != 0:
		rng.seed = seed_v
	else:
		rng.randomize()
	residents.clear()
	fx.clear()
	for i in mini(team.size(), MAX):
		var m: Dictionary = team[i]
		var F: Dictionary = GameData.FORMS[m.form]
		residents.append({
			"id": int(m.id), "form": m.form, "species": m.species, "el": F.el, "stage": int(m.stage),
			"x": rng.randf_range(AREA.position.x, AREA.end.x), "y": rng.randf_range(AREA.position.y, AREA.end.y),
			"tx": 0.0, "ty": 0.0, "state": "idle", "t": rng.randf_range(0.3, 2.5), "flip": rng.randf() < 0.5,
			"hop": 0.0, "hops": 0, "partner": -1, "fx_t": 0.0,
			"fly": FLYERS.has(m.species), "speed": rng.randf_range(20.0, 32.0),
		})


static func daytime_for(runs: int) -> String:
	return DAYTIMES[posmod(runs, DAYTIMES.size())]


## Einzug (07.10.2026): Der Neue kommt von links herein, alle anderen drehen sich um und freuen sich
func welcome(id: int) -> void:
	for i in residents.size():
		if residents[i].id == id:
			newcomer = i
			var r: Dictionary = residents[i]
			_leave_partner(r)
			r.x = AREA.position.x - 50.0
			r.y = AREA.get_center().y
			r.flip = false
			r.speed = 34.0
			r.tx = AREA.position.x + 150.0
			r.ty = AREA.get_center().y
			r.state = "arrive"
			r.t = 99.0
	for j in residents.size():
		if j != newcomer:
			var o: Dictionary = residents[j]
			_leave_partner(o)
			o.state = "greet"
			o.t = rng.randf_range(4.0, 5.5)
			o.hop = 0.0


func update(dt: float) -> void:
	for i in residents.size():
		var r: Dictionary = residents[i]
		r.hop = maxf(0.0, r.hop - dt)
		r.t -= dt
		match r.state:
			"walk", "go_spot", "go_play", "arrive":
				var d := Vector2(r.tx - r.x, r.ty - r.y)
				var step: float = r.speed * dt
				if d.length() <= step:
					r.x = r.tx
					r.y = r.ty
					_arrive(i)
				else:
					var v := d.normalized() * step
					r.x += v.x
					r.y += v.y
					if absf(d.x) > 1.0:
						r.flip = d.x < 0
					# Laufen: kleine Hüpfer im Takt
					if r.hop <= 0.0 and not r.fly:
						r.hop = 0.22
			"play":
				# abwechselnd hüpfen, dazwischen Noten
				if r.hop <= 0.0 and fmod(r.t, 0.7) < 0.05:
					r.hop = 0.3
				_emit(r, "note", 0.5, dt)
				if r.t <= 0:
					_choose(i)
			"greet":
				# zum Neuen schauen, hüpfen, Noten
				if newcomer >= 0 and newcomer < residents.size():
					r.flip = residents[newcomer].x < r.x
				if r.hop <= 0.0 and fmod(r.t + r.id * 0.3, 0.8) < 0.05:
					r.hop = 0.3
				_emit(r, "note", 0.6, dt)
				if r.t <= 0:
					_choose(i)
			"pet":
				if r.hops < 2 and r.hop <= 0.0:
					r.hops += 1
					r.hop = 0.35
				if r.t <= 0:
					_choose(i)
			"sleep":
				_emit(r, "zzz", 1.1, dt)
				if r.t <= 0:
					_choose(i)
			"spot":
				_emit(r, {"Feuer": "ember", "Wasser": "drop", "Elektro": "spark", "Code": "bit", "Virus": "bubble"}.get(r.el, "ball"), 0.45, dt)
				if r.el == "Neutral" and r.hop <= 0.0 and fmod(r.t, 1.1) < 0.05:
					r.hop = 0.35
				if r.t <= 0:
					_choose(i)
			_:
				if r.t <= 0:
					_choose(i)
	_separate(dt)
	for k in range(fx.size() - 1, -1, -1):
		var f: Dictionary = fx[k]
		f.t -= dt
		f.x += f.vx * dt
		f.y += f.vy * dt
		if f.kind == "drop":
			f.vy += 140.0 * dt
		if f.t <= 0:
			fx.remove_at(k)


## Sichtbare Breite eines Bewohners in Pixeln (Babys werden doppelt gezeichnet)
static func width(r: Dictionary) -> float:
	return {1: 52.0, 2: 54.0, 3: 66.0, 4: 80.0}.get(int(r.stage), 60.0)


## Abstand halten (08.10.2026): Wer zu nah an einem anderen steht, wird sanft weggeschoben – vorher ballten sich
## große Champions und Ultras in der Mitte und verdeckten sich. Die Tiefe (y) zählt nur wenig: Bei 80–96 px großen
## Sprites verdecken sich zwei Bewohner auch, wenn einer etwas weiter hinten steht.
## Laufende werden nur geschoben, wenn beide laufen; Spielpartner dürfen etwas näher zusammen.
func _separate(dt: float) -> void:
	var walking := ["walk", "go_spot", "go_play", "arrive"]
	for i in residents.size():
		for j in range(i + 1, residents.size()):
			var a: Dictionary = residents[i]
			var b: Dictionary = residents[j]
			if a.state == "arrive" or b.state == "arrive":
				continue
			var need := (width(a) + width(b)) * (0.32 if a.partner == j else 0.45)
			var d := Vector2(b.x - a.x, (b.y - a.y) * DEPTH)
			var dist := d.length()
			if dist >= need:
				continue
			var dir := d / dist if dist > 0.01 else Vector2(1.0 if i % 2 == 0 else -1.0, 0.0)
			var push := minf(need - dist, 90.0 * dt)
			var move_a := not walking.has(a.state) or walking.has(b.state)
			var move_b := not walking.has(b.state) or walking.has(a.state)
			var share := 0.5 if move_a and move_b else 1.0
			if move_a:
				a.x = _clamp_x(a, a.x - dir.x * push * share)
				a.y = clampf(a.y - dir.y / DEPTH * push * share, AREA.position.y, AREA.end.y)
			if move_b:
				b.x = _clamp_x(b, b.x + dir.x * push * share)
				b.y = clampf(b.y + dir.y / DEPTH * push * share, AREA.position.y, AREA.end.y)


## Streicheln: Hüpfer, Herzchen, kurze Reaktion (Text zum Anzeigen)
func pet(i: int) -> String:
	if i < 0 or i >= residents.size():
		return ""
	var r: Dictionary = residents[i]
	_leave_partner(r)
	r.state = "pet"
	r.t = 1.6
	r.hop = 0.35
	r.hops = 0
	for k in 4:
		fx.append({"kind": "heart", "x": r.x + rng.randf_range(-12, 12), "y": _head_y(r) + rng.randf_range(-4, 4),
			"t": 1.1 + k * 0.15, "max": 1.1 + k * 0.15, "vx": rng.randf_range(-8, 8), "vy": -22.0})
	var animal: String = String(GameData.MONS.get(r.species, {}).get("animal", "")).get_slice(" × ", 0)
	return T.t(PET_TEXT.get(animal, "%s freut sich.")) % T.t(r.form)


## Index der Bewohner von links nach rechts (für die Auswahl mit < >)
func order() -> Array:
	var idx: Array = range(residents.size())
	idx.sort_custom(func(a, b): return residents[a].x < residents[b].x)
	return idx


## Ungefähre Kopfhöhe (für Herzchen und Auswahlpfeil)
func _head_y(r: Dictionary) -> float:
	var size: float = 64.0 if int(r.stage) == 1 else {2: 64.0, 3: 80.0, 4: 96.0}.get(int(r.stage), 64.0)
	return r.y - size * 0.75 - (30.0 if r.fly else 0.0)


func _choose(i: int) -> void:
	var r: Dictionary = residents[i]
	_leave_partner(r)
	var roll := rng.randf()
	var m: Array = DAY_MOOD.get(daytime, DAY_MOOD.nacht)
	if roll < m[0]:
		_walk_to(r, _free_spot(i), "walk")
	elif roll < m[0] + m[1]:
		r.state = "idle"
		r.t = rng.randf_range(1.5, 4.0)
	elif roll < m[0] + m[1] + m[2] and not r.fly:
		r.state = "sleep"
		r.t = rng.randf_range(6.0, 10.0)
	elif roll < m[0] + m[1] + m[2] + m[3]:
		# am Lieblingsplatz verteilen sich mehrere Bewohner im Halbkreis statt aufeinander zu stehen
		var s: Vector2 = SPOTS.get(r.el, SPOTS.Neutral)
		var there := 0
		for j in residents.size():
			if j != i and residents[j].el == r.el and residents[j].state in ["go_spot", "spot"]:
				there += 1
		var ang: float = [0.0, PI, PI * 0.5, PI * 1.5][there % 4]
		_walk_to(r, s + Vector2(cos(ang) * 46.0, sin(ang) * 14.0) * (0.0 if there == 0 else 1.0) + Vector2(rng.randf_range(-6, 6), rng.randf_range(-3, 3)), "go_spot")
	else:
		# Spielpartner: jemand, der gerade nichts Wichtiges tut
		var free: Array = []
		for j in residents.size():
			if j != i and residents[j].state in ["idle", "walk"]:
				free.append(j)
		if free.is_empty():
			r.state = "idle"
			r.t = rng.randf_range(1.0, 3.0)
			return
		var j: int = free[rng.randi_range(0, free.size() - 1)]
		var o: Dictionary = residents[j]
		var mid := Vector2((r.x + o.x) / 2.0, (r.y + o.y) / 2.0)
		mid.x = clampf(mid.x, AREA.position.x + 20, AREA.end.x - 20)
		r.partner = j
		o.partner = i
		var gap := (width(r) + width(o)) * 0.36
		mid.x = clampf(mid.x, AREA.position.x + gap, AREA.end.x - gap)
		_walk_to(r, mid + Vector2(-gap, 0), "go_play")
		_walk_to(o, mid + Vector2(gap, 0), "go_play")


## Ein Ziel mit möglichst viel Abstand zu den anderen (sonst ballt sich alles in der Mitte)
func _free_spot(i: int) -> Vector2:
	var best := Vector2.ZERO
	var best_d := -1.0
	for k in 6:
		var c := Vector2(rng.randf_range(AREA.position.x, AREA.end.x), rng.randf_range(AREA.position.y, AREA.end.y))
		var d := INF
		for j in residents.size():
			if j != i:
				var o: Dictionary = residents[j]
				var ox: float = o.tx if o.state in ["walk", "go_spot", "go_play"] else o.x
				var oy: float = o.ty if o.state in ["walk", "go_spot", "go_play"] else o.y
				d = minf(d, Vector2(ox - c.x, (oy - c.y) * DEPTH).length())
		if d > best_d:
			best_d = d
			best = c
	return best


func _arrive(i: int) -> void:
	var r: Dictionary = residents[i]
	match r.state:
		"go_spot":
			r.state = "spot"
			r.t = rng.randf_range(4.0, 7.0)
			# Feuer schaut zum Lagerfeuer (rechts), Wasser zum Teich (links)
			r.flip = {"Feuer": false, "Wasser": true}.get(r.el, r.flip)
		"arrive":
			# angekommen: Freudensprünge mit Herzchen
			newcomer = -1
			pet(i)
		"go_play":
			r.state = "play"
			r.t = 3.2
			if r.partner >= 0:
				r.flip = residents[r.partner].x < r.x
		_:
			r.state = "idle"
			r.t = rng.randf_range(1.0, 3.0)


## Große Sprites dürfen nicht über den Bildrand hinaus (Bildbreite 640)
func _clamp_x(r: Dictionary, x: float) -> float:
	var half := width(r) / 2.0 + (10.0 if r.fly else 0.0)
	return clampf(x, maxf(AREA.position.x, 8.0 + half), minf(AREA.end.x, 632.0 - half))


func _walk_to(r: Dictionary, p: Vector2, state: String) -> void:
	r.tx = _clamp_x(r, p.x)
	r.ty = clampf(p.y, AREA.position.y, AREA.end.y)
	r.state = state
	r.t = 99.0


func _leave_partner(r: Dictionary) -> void:
	var j: int = r.partner
	r.partner = -1
	if j >= 0 and j < residents.size() and residents[j].partner >= 0:
		residents[j].partner = -1


## Effekt in festem Takt ausstoßen
func _emit(r: Dictionary, kind: String, every: float, dt: float) -> void:
	r.fx_t -= dt
	if r.fx_t > 0:
		return
	r.fx_t = every
	var hy := _head_y(r)
	match kind:
		"zzz":
			fx.append({"kind": "zzz", "x": r.x + (-10.0 if r.flip else 10.0), "y": hy, "t": 1.6, "max": 1.6, "vx": 6.0, "vy": -12.0})
		"note":
			fx.append({"kind": "note", "x": r.x + rng.randf_range(-8, 8), "y": hy, "t": 0.9, "max": 0.9, "vx": rng.randf_range(-6, 6), "vy": -20.0})
		"drop":
			fx.append({"kind": "drop", "x": r.x + rng.randf_range(-14, 14), "y": r.y - 4, "t": 0.6, "max": 0.6, "vx": rng.randf_range(-20, 20), "vy": -40.0})
		"ember", "spark", "bit", "bubble":
			fx.append({"kind": kind, "x": r.x + rng.randf_range(-16, 16), "y": r.y - rng.randf_range(4, 24), "t": 0.9, "max": 0.9, "vx": rng.randf_range(-5, 5), "vy": -18.0})
