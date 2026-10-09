class_name BattleBot
extends RefCounted
## Einfacher Autopilot für Tests, Screenshots und Balancing-Simulationen.
## reaction: Sekunden, die der Bot braucht, um auf eine neue Warnung zu reagieren (0 = perfekt).
## Für Balancing gibt es den „Mensch“-Bot (human()): er zielt verzögert, zögert vor jedem Chip und verpatzt
## manche Ausweichschritte. So gemessene Werte liegen näher an echten Spielern als der perfekte Bot.

var reaction := 0.0
var aim_delay := 0.0     # Sekunden, bis der Bot in die Reihe des Gegners nachrückt
var fire_delay := 0.0    # Sekunden, die ein bereiter Chip liegen bleibt
var slip := 0.0          # Anteil der Ausweichschritte, die in eine zufällige Richtung gehen
var counter_wait := false  # wartet mit einem bereiten Angriff auf das Ausholen des Gegners (Konter)
var allow_special := true  # Trailer: Signatur nur auf Kommando
var lapse := 0.0         # Anteil der Warnungen, die der Bot erst spät bemerkt (abgelenkt, zielt gerade)
var _rng := RandomNumberGenerator.new()
var _off_row_since := -1.0
var _ready_since := [-1.0, -1.0, -1.0]


func _init(reaction_time := 0.0) -> void:
	reaction = reaction_time
	_rng.seed = 4242


## Durchschnittlicher Spieler (08.10.2026, Game-Design-Analyse)
static func human() -> BattleBot:
	var b := BattleBot.new(0.5)
	b.aim_delay = 0.35
	b.fire_delay = 0.3
	b.slip = 0.08
	b.lapse = 0.2
	return b


func act(st: BattleState) -> void:
	if st.over:
		return
	var danger := {}
	for w in st.warns:
		# Warnungen erst nach der Reaktionszeit „sehen“; manche erst 0,35 s später (Unaufmerksamkeit)
		if not w.has("_bot_late"):
			w["_bot_late"] = lapse > 0 and _rng.randf() < lapse
		if w.max - w.t < reaction + (0.35 if w._bot_late else 0.0):
			continue
		for cell in w.cells:
			danger[cell] = true
	for hz in st.hazards:
		danger[Vector2i(hz.c, hz.r)] = true
	var here := Vector2i(st.p.c, st.p.r)
	if st.e.r != st.p.r:
		if _off_row_since < 0:
			_off_row_since = st.t
	else:
		_off_row_since = -1.0
	if st.p.cd <= 0 and st.pend_move == null:
		if danger.has(here):
			# Breitensuche zum nächsten sicheren Feld (Großangriffe lassen oft nur ein Feld frei)
			var d := _escape(here, danger)
			if d != Vector2i.ZERO and slip > 0 and _rng.randf() < slip:
				d = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)][_rng.randi_range(0, 3)]
			if d != Vector2i.ZERO:
				st.move_player(d.x, d.y)
		elif not st.pops.is_empty():
			var q: Dictionary = st.pops[0]
			var d := _step_towards(here, Vector2i(q.c, q.r))
			if not danger.has(here + d):
				st.move_player(d.x, d.y)
		elif st.e.r != st.p.r and st.t - _off_row_since >= aim_delay:
			var d := Vector2i(0, signi(st.e.r - st.p.r))
			if not danger.has(here + d):
				st.move_player(d.x, d.y)
	# Heilpatch aufsparen, außer die ganze Hand besteht nur noch daraus
	var only_heal: bool = st.hand.all(func(s): return s.chip == "" or s.chip == "Heilpatch")
	for i in 3:
		var s: Dictionary = st.hand[i]
		if s.chip == "" or s.rem > 0:
			_ready_since[i] = -1.0
			continue
		if _ready_since[i] < 0:
			_ready_since[i] = st.t
		if st.t - _ready_since[i] < fire_delay:
			continue
		if s.chip == "Heilpatch" and st.run.hp > st.run.max_hp - 20 and not only_heal:
			continue
		# Konter-Spieler: Angriffe halten, bis der Gegner ausholt (höchstens 2 s)
		if counter_wait and GameData.role(s.chip) == 0 and not st.counter_open() and st.t - _ready_since[i] < 2.0:
			continue
		st.use_slot(i)
		_ready_since[i] = -1.0
	if st.sp >= 100 and allow_special:
		st.use_special()


static func _escape(from: Vector2i, danger: Dictionary) -> Vector2i:
	var dirs := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	var first := {from: Vector2i.ZERO}
	var queue: Array = [from]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if c != from and not danger.has(c):
			return first[c]
		for d in dirs:
			var n: Vector2i = c + d
			if _inside(n) and not first.has(n):
				first[n] = d if c == from else first[c]
				queue.append(n)
	return Vector2i.ZERO


static func _inside(n: Vector2i) -> bool:
	return n.x >= 0 and n.x < 3 and n.y >= 0 and n.y < 3


static func _step_towards(a: Vector2i, b: Vector2i) -> Vector2i:
	if a.x != b.x:
		return Vector2i(signi(b.x - a.x), 0)
	return Vector2i(0, signi(b.y - a.y))
