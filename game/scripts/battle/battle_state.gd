class_name BattleState
extends RefCounted
## Reine Kampflogik ohne Grafik (Port aus prototype/index.html).
## Raster: Spalten 0–2 = Spielerseite, 3–5 = Gegnerseite. Der Gegner speichert c = 0–2 (gezeichnet bei 3 + c).
## Effektlisten (fx, parts, marks …) liegen ebenfalls hier, damit die Ansicht sie nur noch zeichnen muss.

const WARN_TIME := 0.7
const SPECIAL_JUMP := 0.35

var run: RunState
var mon: Dictionary
var def: Dictionary
var rng: RandomNumberGenerator

var t := 0.0
var p := {}
var e := {}
var draw_pile: Array = []
var disc: Array = []
var hand: Array = []
var proj: Array = []
var warns: Array = []
var mines: Array = []
var pops: Array = []
var delayed: Array = []
var bots: Array = []
var marks: Array = []
var fx: Array = []     # schwebende Texte {x, y, text, color, t, max}
var parts: Array = []  # Partikel / Ringe / Feld-Blitze
var events: Array = [] # Sound-/Ereignisnamen für die Ansicht (wird dort geleert)

var shield := 0.0
var bubble := 0
var bubble_t := 0.0
var oc := 0.0
var shake := 0.0
var freeze := 0.0      # Hitstop, wird von der Ansicht abgebaut
var hurt := 0.0
var sp := 0.0          # Signatur-Leiste 0–100
var since_hit := 0.0
var reflex := 0
var in_special := false
var jump_t := 0.0
var banner := {}
var status := ""
var over := false
var outcome := ""      # "won" / "lost"
var pend_move = null   # vorgemerkter Schritt (Vector2i), wenn noch Bewegungs-Cooldown läuft


func _init(run_state: RunState, foe_index: int) -> void:
	run = run_state
	mon = run.mon
	rng = run.rng
	def = GameData.FOES[foe_index]
	p = {"c": 1, "r": 1, "cd": 0.0, "flash": 0.0}
	e = {"c": 1, "r": 1, "hp": def.hp, "max": def.hp, "move_t": def.move, "atk_t": def.atk * 0.8,
		"pi": 0, "frozen": 0.0, "flash": 0.0, "burn": 0, "poison": 0, "dot_t": 1.0, "pop_t": 1.5}
	draw_pile = _shuffle(run.deck)
	for i in 3:
		hand.append({"chip": _draw_one(), "rem": 0.0, "max": 1.0, "queued": false})
	if mon.passive == "Katzenreflex":
		reflex = 1
	if def.boss:
		status = "Boss! Ab der Hälfte seiner HP tauchen Pop-ups auf. Tritt drauf, um sie zu schließen."
	elif foe_index == 0:
		status = "Rote Felder warnen vor Angriffen. Weiche aus!"


# ---------- Deck ----------

func _shuffle(a: Array) -> Array:
	var b := a.duplicate()
	for i in range(b.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = b[i]
		b[i] = b[j]
		b[j] = tmp
	return b


func _draw_one() -> String:
	if draw_pile.is_empty():
		draw_pile = _shuffle(disc)
		disc.clear()
	if draw_pile.is_empty():
		return ""
	return draw_pile.pop_back()


func next_chip() -> String:
	return draw_pile.back() if not draw_pile.is_empty() else ""


# ---------- Eingaben ----------

func move_player(dc: int, dr: int) -> void:
	if over:
		return
	if p.cd > 0:
		pend_move = Vector2i(dc, dr)
		return
	var c: int = p.c + dc
	var r: int = p.r + dr
	if c < 0 or c > 2 or r < 0 or r > 2:
		return
	p.c = c
	p.r = r
	p.cd = mon.move
	events.append("move")
	for i in range(pops.size() - 1, -1, -1):
		var q: Dictionary = pops[i]
		if q.c == c and q.r == r:
			pops.remove_at(i)
			events.append("pop_close")
			burst(c + 0.5, r + 0.5, GameData.COL.mint, 10)
			float_at(c, r, "Zu!", GameData.COL.mint)


func use_slot(i: int) -> void:
	if over:
		return
	var s: Dictionary = hand[i]
	if s.chip == "":
		return
	if s.rem > 0:
		s.queued = not s.queued
		return
	s.queued = false
	var id: String = s.chip
	var ch: Dictionary = GameData.CHIPS[id]
	run.praeg[ch.el] = run.praeg.get(ch.el, 0) + 1
	run.chips_used += 1
	disc.append(id)
	var nx := _draw_one()
	s.chip = nx
	s.max = GameData.CHIPS[nx].cd if nx != "" else 1.0
	s.rem = s.max
	_apply_chip(id)


func use_special() -> void:
	if over or sp < 100:
		return
	sp = 0.0
	events.append("special")
	banner = {"text": mon.special + "!", "color": GameData.EL[mon.special_el], "t": 1.1, "max": 1.1}
	shake = maxf(shake, 9.0)
	jump_t = SPECIAL_JUMP
	burst(p.c + 0.5, p.r + 0.5, Color("#C9B8FF"), 16)
	# Der Kratzer landet auf dem Höhepunkt des Sprungs
	delayed.append({"t": SPECIAL_JUMP * 0.5, "fn": _special_hit.bind(40, mon.special_el), "mark": false})


func _special_hit(d: int, el: String) -> void:
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL[el], 18)
	in_special = true
	hit_enemy(d, el)
	in_special = false


# ---------- Chips ----------

func _apply_chip(id: String) -> void:
	var ch: Dictionary = GameData.CHIPS[id]
	var el: String = ch.el
	events.append(_chip_sound(id))
	match id:
		"Pixelstrahl", "Wasserstrahl", "Virusspritzer":
			proj.append({"lob": false, "row": p.r, "x": p.c + 0.5, "v": 11.0, "el": el, "dmg": ch.dmg, "id": id})
		"Byteschlag":
			for c in [0, 1]:
				fx_cell(3 + c, p.r, GameData.EL.Neutral, 0.25)
			if e.r == p.r and e.c <= 1:
				hit_enemy(ch.dmg, el)
			else:
				_miss()
		"Glutball":
			proj.append({"lob": true, "fx": p.c + 0.5, "fr": p.r, "tx": 3 + p.c + 0.5, "tr": p.r, "t": 0.0, "dur": 0.3,
				"el": "Feuer", "land": _land_glutball.bind(p.c, p.r)})
		"Flammenwelle":
			var col: int = e.c
			marks.append({"col": col, "t": 0.4, "max": 0.4, "color": GameData.EL.Feuer})
			delayed.append({"t": 0.4, "fn": _flammenwelle.bind(col), "mark": false})
		"Firewall":
			shield = 4.0
			float_at(p.c, p.r, "Firewall", GameData.EL.Code)
		"Blubberschild":
			bubble = 30
			bubble_t = 5.0
			float_at(p.c, p.r, "Blase", GameData.EL.Wasser)
		"Bug-Mine":
			mines.append({"c": e.c, "r": e.r, "arm": 0.8, "t": 6.0})
		"Übertakten":
			oc = 5.0
			float_at(p.c, p.r, "Übertaktet!", GameData.EL.Feuer)
		"Eisfeld":
			e.frozen = 2.0
			fx_cell(3 + e.c, e.r, GameData.EL.Wasser, 0.4)
			float_at(3 + e.c, e.r, "Eingefroren", GameData.EL.Wasser)
		"Heilpatch":
			var h: int = mini(25, run.max_hp - run.hp)
			run.hp += h
			float_at(p.c, p.r, "+%d" % h, GameData.COL.mint)
			burst(p.c + 0.5, p.r + 0.5, GameData.EL.Licht, 10)
		"Blitzcursor":
			delayed.append({"t": 0.5, "fn": _blitz, "mark": true})
		"Mini-Bot":
			bots.append({"t": 6.0, "tick": 1.0})
			float_at(p.c, p.r, "Mini-Bot", GameData.EL.Code)
		"Defrag":
			for s in hand:
				if s.chip != "":
					s.rem = 0.0
			float_at(p.c, p.r, "Defrag!", GameData.EL.Neutral)


func _chip_sound(id: String) -> String:
	match id:
		"Pixelstrahl", "Wasserstrahl", "Virusspritzer", "Glutball":
			return "shoot"
		"Byteschlag":
			return "slash"
		"Firewall", "Blubberschild":
			return "shield"
		"Heilpatch":
			return "heal"
	return "chip"


func _miss() -> void:
	float_at(3 + e.c, e.r, "verfehlt", GameData.COL.muted)


func _land_glutball(col: int, row: int) -> void:
	fx_cell(3 + col, row, GameData.EL.Feuer, 0.4)
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var c: int = col + d.x
		var r: int = row + d.y
		if c >= 0 and c < 3 and r >= 0 and r < 3:
			fx_cell(3 + c, r, GameData.EL.Feuer, 0.25)
	burst(3 + col + 0.5, row + 0.5, GameData.EL.Feuer, 16)
	var dist: int = absi(e.c - col) + absi(e.r - row)
	if dist == 0:
		hit_enemy(45, "Feuer")
		e.burn = 3
	elif dist == 1:
		hit_enemy(20, "Feuer")
		e.burn = 3
	else:
		_miss()


func _flammenwelle(col: int) -> void:
	for r in 3:
		fx_cell(3 + col, r, GameData.EL.Feuer, 0.3)
	if e.c == col:
		hit_enemy(25, "Feuer")
	else:
		_miss()


func _blitz() -> void:
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL.Licht, 12)
	hit_enemy(20, "Licht")


# ---------- Treffer ----------

func hit_enemy(d: int, el: String, dot := false) -> void:
	if over:
		return
	var m := 1.0 if dot else GameData.mult(el, def.el)
	d = roundi(d * m)
	e.hp = maxi(0, e.hp - d)
	e.flash = 0.09
	if not dot and not in_special:
		sp = minf(100.0, sp + d * 1.2)
	events.append("tick" if dot else ("hit_big" if d >= 30 or m > 1 else "hit"))
	var col: Color = GameData.COL.sun if m > 1 else (GameData.EL[el] if dot else GameData.COL.ink)
	float_at(3 + e.c, e.r, ("Effektiv! " if m > 1 else "") + str(d), col)
	if not dot:
		parts.append({"ring": true, "x": 3 + e.c + 0.5, "y": e.r + 0.45, "color": GameData.COL.sun if m > 1 else Color.WHITE, "t": 0.3, "max": 0.3})
		shake = maxf(shake, 7.0 if d >= 30 else 4.0)
		if d >= 30:
			freeze = 0.06
		burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL.get(el, Color.WHITE), 8)
	if e.hp <= 0:
		_win()


func hurt_player(d: int) -> void:
	if over:
		return
	if reflex > 0:
		reflex -= 1
		events.append("dodge")
		float_at(p.c, p.r, "Katzenreflex!", GameData.COL.mint)
		burst(p.c + 0.5, p.r + 0.5, Color("#C9B8FF"), 14)
		return
	if shield > 0:
		shield = 0.0
		events.append("block")
		float_at(p.c, p.r, "Geblockt", GameData.EL.Code)
		return
	if bubble > 0 and bubble_t > 0:
		var a := mini(bubble, d)
		bubble -= a
		d -= a
		if bubble <= 0:
			float_at(p.c, p.r, "Blase platzt", GameData.EL.Wasser)
		if d <= 0:
			return
	run.hp = maxi(0, run.hp - d)
	events.append("hurt")
	since_hit = 0.0
	sp = minf(100.0, sp + d * 1.5)
	p.flash = 0.12
	hurt = 0.3
	parts.append({"ring": true, "x": p.c + 0.5, "y": p.r + 0.45, "color": GameData.COL.coral, "t": 0.3, "max": 0.3})
	shake = maxf(shake, 8.0)
	float_at(p.c, p.r, "-%d" % d, GameData.COL.coral)
	if run.hp <= 0:
		_lose()


func _win() -> void:
	if over:
		return
	over = true
	outcome = "won"
	events.append("win")
	run.frag += def.loot
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL[def.el], 24)


func _lose() -> void:
	if over:
		return
	over = true
	outcome = "lost"
	events.append("lose")


# ---------- Effekte ----------

func float_at(c: float, r: float, text: String, color: Color) -> void:
	fx.append({"x": c + 0.5, "y": r + 0.35, "text": text, "color": color, "t": 0.9, "max": 0.9})


func fx_cell(c: int, r: int, color: Color, dur: float) -> void:
	parts.append({"cell": true, "c": c, "r": r, "color": color, "t": dur, "max": dur})


## Rein optische Zufallswerte laufen über randf(), damit die Kampflogik (rng) reproduzierbar bleibt.
func burst(x: float, y: float, color: Color, n: int) -> void:
	for i in n:
		var a := randf() * TAU
		var s := 1.2 + randf() * 2.5
		parts.append({"x": x, "y": y, "vx": cos(a) * s, "vy": sin(a) * s, "color": color, "t": 0.45, "max": 0.45})


func boss_phase() -> int:
	if not def.boss:
		return 1
	var k: float = float(e.hp) / e.max
	return 1 if k > 0.5 else (2 if k > 0.2 else 3)


# ---------- Hauptschleife ----------

func update(dt: float) -> void:
	if not over:
		_update_logic(dt)
	_update_fx(dt)


func _update_logic(dt: float) -> void:
	t += dt
	p.cd = maxf(0.0, p.cd - dt)
	if shield > 0:
		shield -= dt
	if bubble_t > 0:
		bubble_t -= dt
		if bubble_t <= 0:
			bubble = 0
	if oc > 0:
		oc -= dt
	since_hit += dt

	var rate: float = mon.rech * (2.0 if oc > 0 else 1.0)
	for s in hand:
		if s.rem > 0:
			s.rem = maxf(0.0, s.rem - dt * rate)
	for i in 3:
		var s: Dictionary = hand[i]
		if s.queued and s.chip != "" and s.rem <= 0:
			use_slot(i)
			if over:
				return
	if pend_move != null and p.cd <= 0:
		var m: Vector2i = pend_move
		pend_move = null
		move_player(m.x, m.y)

	for i in range(delayed.size() - 1, -1, -1):
		var d: Dictionary = delayed[i]
		d.t -= dt
		if d.t <= 0:
			delayed.remove_at(i)
			d.fn.call()
			if over:
				return
	for i in range(marks.size() - 1, -1, -1):
		marks[i].t -= dt
		if marks[i].t <= 0:
			marks.remove_at(i)

	for i in range(proj.size() - 1, -1, -1):
		var pr: Dictionary = proj[i]
		if pr.lob:
			pr.t += dt
			if pr.t >= pr.dur:
				proj.remove_at(i)
				pr.land.call()
				if over:
					return
			continue
		pr.x += pr.v * dt
		if e.r == pr.row and absf(pr.x - (3 + e.c + 0.5)) < 0.4:
			proj.remove_at(i)
			hit_enemy(pr.dmg, pr.el)
			if over:
				return
			if pr.id == "Wasserstrahl" and e.c < 2:
				e.c += 1
			if pr.id == "Virusspritzer":
				e.poison = 4
			continue
		if pr.x > 6.3:
			proj.remove_at(i)

	# Schaden über Zeit
	if e.burn > 0 or e.poison > 0:
		e.dot_t -= dt
		if e.dot_t <= 0:
			e.dot_t = 1.0
			if e.burn > 0:
				e.burn -= 1
				hit_enemy(5, "Feuer", true)
				if over:
					return
			if e.poison > 0:
				e.poison -= 1
				hit_enemy(4, "Virus", true)
				if over:
					return
	for i in range(bots.size() - 1, -1, -1):
		var b: Dictionary = bots[i]
		b.t -= dt
		b.tick -= dt
		if b.tick <= 0:
			b.tick = 1.0
			hit_enemy(5, "Code", true)
			if over:
				return
		if b.t <= 0:
			bots.remove_at(i)
	for i in range(mines.size() - 1, -1, -1):
		var mn: Dictionary = mines[i]
		mn.t -= dt
		mn.arm -= dt
		if mn.arm <= 0 and e.c == mn.c and e.r == mn.r:
			mines.remove_at(i)
			burst(3 + mn.c + 0.5, mn.r + 0.5, GameData.EL.Virus, 16)
			hit_enemy(35, "Virus")
			if over:
				return
			continue
		if mn.t <= 0:
			mines.remove_at(i)

	# Gegner-KI
	var phase := boss_phase()
	if e.frozen > 0:
		e.frozen -= dt
	else:
		e.move_t -= dt
		if e.move_t <= 0:
			e.move_t = def.move * (0.8 if phase == 3 else 1.0)
			_move_enemy()
		e.atk_t -= dt
		if e.atk_t <= 0:
			e.atk_t = 1.5 if phase == 3 else def.atk
			_enemy_attack()
		if phase >= 2:
			e.pop_t -= dt
			if e.pop_t <= 0:
				e.pop_t = 4.0
				_spawn_pop()

	for i in range(warns.size() - 1, -1, -1):
		var w: Dictionary = warns[i]
		w.t -= dt
		if w.t <= 0:
			warns.remove_at(i)
			var hit := false
			for cell in w.cells:
				fx_cell(cell.x, cell.y, GameData.COL.coral, 0.25)
				if cell.x == p.c and cell.y == p.r:
					hit = true
			if hit:
				hurt_player(w.dmg)
				if over:
					return
	for i in range(pops.size() - 1, -1, -1):
		var q: Dictionary = pops[i]
		q.t -= dt
		if q.t <= 0:
			pops.remove_at(i)
			burst(q.c + 0.5, q.r + 0.5, Color("#FF5470"), 14)
			hurt_player(15)
			if over:
				return


func _update_fx(dt: float) -> void:
	hurt = maxf(0.0, hurt - dt)
	p.flash = maxf(0.0, p.flash - dt)
	e.flash = maxf(0.0, e.flash - dt)
	shake = maxf(0.0, shake - dt * 30.0)
	jump_t = maxf(0.0, jump_t - dt)
	if not banner.is_empty():
		banner.t -= dt
		if banner.t <= 0:
			banner = {}
	for i in range(fx.size() - 1, -1, -1):
		var f: Dictionary = fx[i]
		f.t -= dt
		f.y -= dt * 0.8
		if f.t <= 0:
			fx.remove_at(i)
	for i in range(parts.size() - 1, -1, -1):
		var q: Dictionary = parts[i]
		q.t -= dt
		if not q.has("cell") and not q.has("ring"):
			q.x += q.vx * dt
			q.y += q.vy * dt
		if q.t <= 0:
			parts.remove_at(i)


func _move_enemy() -> void:
	if def.tele:
		var c: int = e.c
		var r: int = e.r
		while c == e.c and r == e.r:
			c = rng.randi_range(0, 2)
			r = rng.randi_range(0, 2)
		e.c = c
		e.r = r
		return
	var opts: Array = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n := Vector2i(e.c + d.x, e.r + d.y)
		if n.x >= 0 and n.x < 3 and n.y >= 0 and n.y < 3:
			opts.append(n)
	# Tendenz zur Spielerreihe, damit Kämpfe nicht verschleppen
	var pref: Array = opts.filter(func(n): return absi(n.y - p.r) < absi(e.r - p.r))
	var pool: Array = pref if (not pref.is_empty() and rng.randf() < 0.4) else opts
	var pick: Vector2i = pool[rng.randi_range(0, pool.size() - 1)]
	e.c = pick.x
	e.r = pick.y


func _enemy_attack() -> void:
	var kind: String = def.pat[e.pi % def.pat.size()]
	e.pi += 1
	var cells: Array = []
	match kind:
		"row":
			for c in 3:
				cells.append(Vector2i(c, p.r))
		"col":
			for r in 3:
				cells.append(Vector2i(p.c, r))
		_:
			cells.append(Vector2i(p.c, p.r))
	events.append("warn")
	warns.append({"cells": cells, "t": WARN_TIME, "max": WARN_TIME, "dmg": def.dmg})


func _spawn_pop() -> void:
	var free: Array = []
	for c in 3:
		for r in 3:
			if c == p.c and r == p.r:
				continue
			if pops.any(func(q): return q.c == c and q.r == r):
				continue
			free.append(Vector2i(c, r))
	if free.is_empty():
		return
	var cell: Vector2i = free[rng.randi_range(0, free.size() - 1)]
	events.append("pop")
	pops.append({"c": cell.x, "r": cell.y, "t": 3.0, "max": 3.0})
