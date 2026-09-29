class_name BattleBot
extends RefCounted
## Einfacher Autopilot für Tests, Screenshots und später Balancing-Simulationen.
## reaction: Sekunden, die der Bot braucht, um auf eine neue Warnung zu reagieren (0 = perfekt).

var reaction := 0.0


func _init(reaction_time := 0.0) -> void:
	reaction = reaction_time


func act(st: BattleState) -> void:
	if st.over:
		return
	var danger := {}
	for w in st.warns:
		# Warnungen erst nach der Reaktionszeit „sehen“
		if w.max - w.t < reaction:
			continue
		for cell in w.cells:
			danger[cell] = true
	for hz in st.hazards:
		danger[Vector2i(hz.c, hz.r)] = true
	var here := Vector2i(st.p.c, st.p.r)
	var dirs := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	if st.p.cd <= 0 and st.pend_move == null:
		if danger.has(here):
			for d in dirs:
				var n: Vector2i = here + d
				if _inside(n) and not danger.has(n):
					st.move_player(d.x, d.y)
					break
		elif not st.pops.is_empty():
			var q: Dictionary = st.pops[0]
			var d := _step_towards(here, Vector2i(q.c, q.r))
			if not danger.has(here + d):
				st.move_player(d.x, d.y)
		elif st.e.r != st.p.r:
			var d := Vector2i(0, signi(st.e.r - st.p.r))
			if not danger.has(here + d):
				st.move_player(d.x, d.y)
	# Heilpatch aufsparen, außer die ganze Hand besteht nur noch daraus
	var only_heal: bool = st.hand.all(func(s): return s.chip == "" or s.chip == "Heilpatch")
	for i in 3:
		var s: Dictionary = st.hand[i]
		if s.chip == "" or s.rem > 0:
			continue
		if s.chip == "Heilpatch" and st.run.hp > st.run.max_hp - 20 and not only_heal:
			continue
		st.use_slot(i)
	if st.sp >= 100:
		st.use_special()


static func _inside(n: Vector2i) -> bool:
	return n.x >= 0 and n.x < 3 and n.y >= 0 and n.y < 3


static func _step_towards(a: Vector2i, b: Vector2i) -> Vector2i:
	if a.x != b.x:
		return Vector2i(signi(b.x - a.x), 0)
	return Vector2i(0, signi(b.y - a.y))
