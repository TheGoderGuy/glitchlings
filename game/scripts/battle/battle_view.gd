extends PixelCanvas
## Kampfbildschirm eines Karten-Knotens: Kampf → (bei Sieg) Chipwahl → zurück zur Karte.
## Wird von main.gd mit setup() vorbereitet und meldet sich über Signale zurück.

signal finished(won: bool)
signal gave_up

const CW := 88          # Feldbreite
const CH := 50          # Feldhöhe
const GAP := 16         # Abstand zwischen Spieler- und Gegnerseite
const X0 := 48
const Y0 := 136
const FEET := 39        # Fußlinie innerhalb eines Feldes
const CARD_W := 136
const CARD_H := 44
const HAND_Y := 310
const HAND_X := 42
const HEAL_AFTER_FIGHT := 10
const BABY_SCALE := 1     # Babys (32 px) im Kampf in Originalgröße, damit die Evolution sichtbar wächst

enum Mode { FIGHT, PAUSE, EVOLVE, PICK, INTRO }
## Boss-Intro: Zeitpunkte in Sekunden
const INTRO_REVEAL := 1.7    # Silhouette wird farbig, Musik setzt ein
const INTRO_END := 4.2       # danach beginnt der Kampf
const INTRO_FADE := 0.5

const EVO_REVEAL := 1.8   # Sekunden bis zur Enthüllung der neuen Form

const PAUSE_ITEMS := ["Weiter", "Aufgeben"]

var run: RunState
var st: BattleState
var node_type := "fight"
var mode := Mode.FIGHT
var end_timer := -1.0
var choices: Array = []
var pick_idx := 1
var pause_idx := 0
var heal_info := 0
var mode_t := 0.0     # Zeit im aktuellen Modus (Eingabesperre gegen versehentliches Durchdrücken)
var new_module := ""  # Modul aus einem Elite-Sieg (Anzeige in der Chipwahl)
var evo := {}
var tut: Tutorial = null
# Animations-Timer (prozedural, nur Versatz – keine Skalierung, damit Pixel scharf bleiben)
var p_lunge := 0.0      # Vorschnellen beim Angriff
var p_knock := 0.0      # Zurückweichen bei Treffer
var p_hop := 0.0        # kleiner Hüpfer beim Bewegen
var e_knock := 0.0
var e_strike := 0.0     # Gegner schnellt beim Zuschlagen vor
var muzzle := 0.0
var muzzle_col := Color.WHITE
var dust: Array = []    # Staubwolken {x, y, t}
var last_cell := Vector2i(1, 1)
const LUNGE := 0.16
const KNOCK := 0.14


func setup(run_state: RunState, foe: Dictionary, type := "fight") -> void:
	run = run_state
	node_type = type
	st = BattleState.new(run, foe)
	run.last_foe = foe.name
	if run.tutorial and run.fights_won == 0 and type == "fight":
		tut = Tutorial.new()
		st.status = ""
	if type == "boss":
		# Boss-Intro: erst Stille und Warnung, die Bossmusik setzt mit der Enthüllung ein
		Music.stop()
		_set_mode(Mode.INTRO)
	else:
		Music.play(Music.zone_key("battle", run.map.zone))
		_set_mode(Mode.FIGHT)


# ---------- Ablauf ----------

func _animate_event(ev: String) -> void:
	match ev:
		"shoot", "slash", "chip":
			p_lunge = LUNGE
			if ev != "chip":
				muzzle = 0.09
				muzzle_col = GameData.EL[GameData.CHIPS[st.last_chip].el] if st.last_chip != "" else Color.WHITE
		"hit", "hit_big":
			e_knock = KNOCK * (1.5 if ev == "hit_big" else 1.0)
		"hurt":
			p_knock = KNOCK
		"strike":
			e_strike = 0.12
		"move":
			p_hop = 0.09
			var fy := feet_y(last_cell.y)
			var fx := gx(last_cell.x) + CW / 2.0
			for i in 4:
				dust.append({"x": fx + randf_range(-10, 10), "y": fy - randf_range(0, 3), "vx": randf_range(-14, 14), "t": 0.35})
	last_cell = Vector2i(st.p.c, st.p.r)


func _tick_anims(dt: float) -> void:
	p_lunge = maxf(0.0, p_lunge - dt)
	p_knock = maxf(0.0, p_knock - dt)
	p_hop = maxf(0.0, p_hop - dt)
	e_knock = maxf(0.0, e_knock - dt)
	e_strike = maxf(0.0, e_strike - dt)
	muzzle = maxf(0.0, muzzle - dt)
	for i in range(dust.size() - 1, -1, -1):
		var d: Dictionary = dust[i]
		d.t -= dt
		d.x += d.vx * dt
		d.y -= 10.0 * dt
		if d.t <= 0:
			dust.remove_at(i)


func _fight_over() -> void:
	if st.outcome == "lost" or node_type == "boss":
		finished.emit(st.outcome == "won")
		set_process(false)
		return
	if mode != Mode.EVOLVE:
		evo = run.try_evolve()
		if not evo.is_empty():
			_set_mode(Mode.EVOLVE)
			Sfx.play("charge", 0.0)
			return
	heal_info = run.heal(HEAL_AFTER_FIGHT + (8 if run.has_mod("lebensbit") else 0))
	choices = run.roll_pick(RunState.ELITE_WEIGHT if node_type == "elite" else GameData.RARITY_WEIGHT)
	# Elite-Belohnung: ein neues Modul
	new_module = ""
	if node_type == "elite":
		new_module = run.roll_module(GameData.MODULE_WEIGHT_ELITE)
		run.add_module(new_module)
	pick_idx = 1
	_set_mode(Mode.PICK)


func _take_pick(skip := false) -> void:
	if not skip:
		run.deck.append(choices[pick_idx])
	set_process(false)
	finished.emit(true)


# ---------- Eingabe ----------

func _set_mode(m: Mode) -> void:
	mode = m
	mode_t = 0.0


func _process(delta: float) -> void:
	anim_t += delta
	mode_t += delta
	if mode == Mode.EVOLVE:
		if mode_t - delta < EVO_REVEAL and mode_t >= EVO_REVEAL:
			Sfx.play("evolve", 0.0)
		if mode_t > EVO_REVEAL + 0.6 and Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			_fight_over()
		queue_redraw()
		return
	if mode == Mode.PICK and mode_t < 0.5:
		queue_redraw()
		return
	if mode == Mode.INTRO:
		_process_intro(delta)
		queue_redraw()
		return
	match mode:
		Mode.FIGHT:
			_process_fight(delta)
		Mode.PAUSE:
			if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("back"):
				Sfx.play("back")
				_set_mode(Mode.FIGHT)
			elif Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
				pause_idx = 1 - pause_idx
				Sfx.play("select")
			elif Input.is_action_just_pressed("confirm"):
				Sfx.play("confirm")
				if pause_idx == 0:
					_set_mode(Mode.FIGHT)
				else:
					set_process(false)
					gave_up.emit()
		Mode.PICK:
			if Input.is_action_just_pressed("move_left"):
				pick_idx = (pick_idx + 2) % 3
				Sfx.play("select")
			if Input.is_action_just_pressed("move_right"):
				pick_idx = (pick_idx + 1) % 3
				Sfx.play("select")
			if Input.is_action_just_pressed("confirm"):
				Sfx.play("confirm")
				_take_pick()
			elif Input.is_action_just_pressed("back"):
				Sfx.play("back")
				_take_pick(true)
	queue_redraw()


func _process_fight(delta: float) -> void:
	if not st.over:
		if Input.is_action_just_pressed("pause"):
			_set_mode(Mode.PAUSE)
			pause_idx = 0
			Sfx.play("select")
			return
		if Input.is_action_just_pressed("move_left"):
			st.move_player(-1, 0)
		if Input.is_action_just_pressed("move_right"):
			st.move_player(1, 0)
		if Input.is_action_just_pressed("move_up"):
			st.move_player(0, -1)
		if Input.is_action_just_pressed("move_down"):
			st.move_player(0, 1)
		for i in 3:
			if Input.is_action_just_pressed("chip_%d" % (i + 1)):
				st.use_slot(i)
		if Input.is_action_just_pressed("special"):
			st.use_special()
	_tick_anims(delta)
	if st.freeze > 0:
		st.freeze -= delta
	else:
		st.update(delta)
	if tut != null and tut.active():
		tut.update(st, delta)
		if tut.just_finished:
			Sfx.play("confirm")
			run.tutorial = false
			SaveGame.data["tutorial_done"] = true
			SaveGame.save_game()
	for ev in st.events:
		_animate_event(ev)
		if ev == "win":
			continue  # ersetzt durch die Siegesfanfare bzw. die Ergebnis-Musik
		Sfx.play(ev)
	st.events.clear()
	if st.over:
		if end_timer < 0:
			end_timer = 0.65
			if st.outcome == "won":
				Music.play("victory" if node_type != "boss" else "title")
			else:
				Music.stop()
		end_timer -= delta
		if end_timer <= 0:
			_fight_over()


# ---------- Hilfen ----------

func gx(x: float) -> float:
	var c := clampi(floori(x), 0, 5)
	return X0 + c * CW + (GAP if c >= 3 else 0) + (x - c) * CW


func cell_rect(c: int, r: int) -> Rect2:
	return Rect2(gx(c) + 2, Y0 + r * CH + 2, CW - 4, CH - 4)


func feet_y(r: float) -> float:
	return Y0 + r * CH + FEET


func _glyph_chip(i: int) -> String:
	return ["X", "Y", "B"][i] if InputSetup.pad else ["J", "K", "L"][i]


# ---------- Zeichnen ----------

func _draw() -> void:
	off = Vector2.ZERO
	draw_set_transform(off)
	if st == null:
		_draw_background()
		return
	var zbg: String = GameData.ZONES[run.map.zone].bg
	_draw_zone(zbg + "_boss" if st.def.boss else zbg)
	if st == null:
		return
	if mode == Mode.EVOLVE:
		_draw_evolve()
		return
	if mode == Mode.INTRO and mode_t < INTRO_END - INTRO_FADE:
		_draw_boss_intro()
		return
	if st.shake > 0 and Settings.screen_shake:
		var s := st.shake * 0.5
		off = Vector2(roundi(randf_range(-s, s)), roundi(randf_range(-s, s)))
		draw_set_transform(off)
	_draw_arena()
	_draw_arena_overlays()
	_draw_actors()
	_draw_effects()
	off = Vector2.ZERO
	draw_set_transform(off)
	_draw_hud()
	_draw_hand()
	if tut != null and tut.active() and mode == Mode.FIGHT:
		_draw_tutorial()
	if st.hurt > 0:
		var a := st.hurt / 0.3 * 0.35
		for i in 6:
			var g := Color(1, 0.24, 0.35, a * (1.0 - i / 6.0))
			draw_rect(Rect2(i * 3, 0, 3, H), g)
			draw_rect(Rect2(W - (i + 1) * 3, 0, 3, H), g)
			draw_rect(Rect2(0, i * 3, W, 3), g)
			draw_rect(Rect2(0, H - (i + 1) * 3, W, 3), g)
	match mode:
		Mode.PAUSE:
			_draw_pause()
		Mode.PICK:
			_draw_pick()
		Mode.INTRO:
			# Übergang: das Intro blendet in den Kampf über
			var k := clampf((INTRO_END - mode_t) / INTRO_FADE, 0.0, 1.0)
			draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, k))


func _draw_arena() -> void:
	# Sockel unter dem Spielfeld mit Schatten, damit es auf dem Hintergrund steht
	var full := Rect2(X0 - 6, Y0 - 5, 6 * CW + GAP + 12, 3 * CH + 12)
	draw_rect(Rect2(full.position + Vector2(4, 8), full.size), Color(0.02, 0.01, 0.06, 0.45))
	var left := Rect2(full.position, Vector2(3 * CW + 6 + GAP / 2.0, full.size.y))
	var right := Rect2(Vector2(left.end.x, full.position.y), Vector2(full.end.x - left.end.x, full.size.y))
	draw_rect(left, GameData.COL.tileP.darkened(0.72))
	draw_rect(right, GameData.COL.tileE.darkened(0.72))
	draw_rect(Rect2(full.position, Vector2(full.size.x, 1)), Color(1, 1, 1, 0.12))
	draw_rect(Rect2(full.position.x, full.end.y - 3, full.size.x, 3), Color(0, 0, 0, 0.35))
	for c in 6:
		for r in 3:
			_draw_panel(c, r)
	# Mittellinie: leuchtender Datenstrom
	var mx := X0 + 3 * CW + GAP / 2 - 1
	draw_rect(Rect2(mx - 2, Y0 - 2, 6, 3 * CH), Color(GameData.COL.sun, 0.08))
	for y in range(Y0, Y0 + 3 * CH - 2, 4):
		var a := 0.2 + 0.6 * maxf(0.0, sin(y * 0.1 - anim_t * 5.0))
		draw_rect(Rect2(mx, y, 2, 2), Color(GameData.COL.sun, a))


## Ein Feld im Battle-Network-Stil: Fläche mit Kante, Innenplatte, Datenraster und Vorderkante
func _draw_panel(c: int, r: int) -> void:
	var rect := cell_rect(c, r)
	var base: Color = GameData.COL.tileP if c < 3 else GameData.COL.tileE
	base = base.darkened(0.1 * (2 - r) / 2.0)   # hintere Reihe etwas dunkler (Tiefe)
	var edge := 6
	var face := Rect2(rect.position, Vector2(rect.size.x, rect.size.y - edge))
	draw_rect(rect.grow(1), GameData.COL.dark)
	# Vorderkante
	draw_rect(Rect2(rect.position.x, face.end.y, rect.size.x, edge), base.darkened(0.55))
	draw_rect(Rect2(rect.position.x, face.end.y, rect.size.x, 1), base.darkened(0.2))
	draw_rect(Rect2(rect.position.x + 3, face.end.y + 2, rect.size.x - 6, 1), base.darkened(0.4))
	# Fläche mit Fase
	draw_rect(face, base)
	var inner := face.grow(-4)
	draw_rect(inner, base.lightened(0.07))
	var grid := Color(base.lightened(0.3), 0.18)
	for gx in range(int(inner.position.x) + 7, int(inner.end.x) - 2, 8):
		draw_rect(Rect2(gx, inner.position.y + 1, 1, inner.size.y - 2), grid)
	for gy in range(int(inner.position.y) + 6, int(inner.end.y) - 2, 7):
		draw_rect(Rect2(inner.position.x + 1, gy, inner.size.x - 2, 1), grid)
	draw_rect(Rect2(face.position, Vector2(face.size.x, 1)), base.lightened(0.4))
	draw_rect(Rect2(face.position, Vector2(1, face.size.y)), base.lightened(0.22))
	draw_rect(Rect2(face.position.x, face.end.y - 1, face.size.x, 1), base.darkened(0.3))
	draw_rect(Rect2(face.end.x - 1, face.position.y, 1, face.size.y), base.darkened(0.3))
	# kleine Eckmarken
	var mk := base.lightened(0.5)
	for p in [inner.position, Vector2(inner.end.x - 2, inner.position.y)]:
		draw_rect(Rect2(p, Vector2(2, 2)), Color(mk, 0.7))


func _draw_arena_overlays() -> void:
	for m in st.marks:
		for r in 3:
			draw_rect(cell_rect(3 + m.col, r), Color(m.color, 0.35 + 0.3 * sin(anim_t * 30.0)))
	for w in st.warns:
		var k: float = 1.0 - w.t / w.max
		var a := 0.5 + 0.4 * k * (0.6 + 0.4 * sin(anim_t * 28.0))
		for cell in w.cells:
			var rect := cell_rect(cell.x, cell.y)
			draw_rect(rect, Color(GameData.COL.coral, a))
			_text(rect.position + Vector2(0, 26), "!", 16, Color(1, 1, 1, minf(1.0, 0.4 + k)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, true, true)
	for hz in st.hazards:
		var rect := cell_rect(hz.c, hz.r)
		var fade := minf(1.0, hz.t / 0.5)
		if hz.get("kind", "lava") == "slime":
			draw_rect(rect, Color("#2E5A24", 0.85 * fade))
			for k in 4:
				var bx2 := rect.position.x + 8 + (k * 19) % int(rect.size.x - 16)
				var by2 := rect.position.y + 10 + (k * 11) % int(rect.size.y - 18) + sin(anim_t * 3.0 + k) * 2.0
				draw_circle(Vector2(bx2, by2), 3.0 + (k % 2), Color("#7BD35A", 0.7 * fade))
			draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2)), Color("#A8F07A", fade))
			continue
		draw_rect(rect, Color("#7A1F0E", 0.85 * fade))
		for k in 5:
			var bx := rect.position.x + 6 + fmod(k * 17.0 + anim_t * 9.0 * (1 + k % 2), rect.size.x - 12)
			var by := rect.position.y + 6 + (k * 7) % int(rect.size.y - 12)
			draw_rect(Rect2(roundi(bx), roundi(by), 3, 3), Color("#FFB347", fade * (0.6 + 0.4 * sin(anim_t * 8.0 + k))))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2)), Color("#FF8A4C", fade))
	for w in st.warns:
		if w.get("lava", false):
			var wc := Color("#7BD35A") if w.get("kind", "lava") == "slime" else Color("#FF8A4C")
			for cell in w.cells:
				var rr := cell_rect(cell.x, cell.y)
				draw_rect(rr.grow(-2), Color(wc, 0.25 + 0.25 * sin(anim_t * 20.0)))
	for q in st.parts:
		if q.has("cell"):
			draw_rect(cell_rect(q.c, q.r), Color(q.color, q.t / q.max * 0.8))
	for mn in st.mines:
		var x := gx(3 + mn.c) + CW / 2
		var y: float = Y0 + mn.r * CH + FEET - 4
		draw_rect(Rect2(x - 6, y - 3, 12, 6), GameData.EL.Virus.darkened(0.5))
		draw_rect(Rect2(x - 3, y - 6, 6, 12), GameData.EL.Virus.darkened(0.5))
		draw_rect(Rect2(x - 3, y - 3, 6, 6), GameData.COL.muted if mn.arm > 0 else GameData.EL.Virus)
		if mn.arm <= 0 and sin(anim_t * 12.0) > 0:
			draw_rect(Rect2(x - 1, y - 1, 2, 2), Color("#FF5470"))


func _shadow(cx: float, y: float, w: int) -> void:
	var c := Color(0.05, 0.02, 0.12, 0.35)
	draw_rect(Rect2(roundi(cx - w / 2.0), roundi(y - 2), w, 4), c)
	draw_rect(Rect2(roundi(cx - w / 2.0 + 3), roundi(y - 3), w - 6, 6), c)


func _draw_actors() -> void:
	var p: Dictionary = st.p
	var e: Dictionary = st.e
	var mkey: String = run.form
	var bob_p := 1 if sin(anim_t * 4.0) > 0 else 0
	var bob_e := 1 if sin(anim_t * 4.0 + 1.6) > 0 else 0
	var blink_p := fmod(anim_t + 0.3, 3.2) < 0.13
	var blink_e := fmod(anim_t + 1.7, 2.7) < 0.13

	# Spieler (beim Signatur-Sprung im Bogen zum Gegner und zurück)
	var pcx := gx(p.c) + CW / 2.0
	var pfy := feet_y(p.r)
	if st.jump_t > 0:
		var k := 1.0 - st.jump_t / BattleState.SPECIAL_JUMP
		var u := sin(k * PI)
		pcx = lerpf(pcx, gx(3 + e.c) + CW / 2.0 - 30, u)
		pfy = lerpf(pfy, feet_y(e.r), u) - u * 26.0
	# Vorschnellen (Bogen hin und zurück), Rückstoß, Hüpfer
	if p_lunge > 0:
		pcx += sin((1.0 - p_lunge / LUNGE) * PI) * 7.0
	if p_knock > 0:
		pcx -= sin((1.0 - p_knock / KNOCK) * PI) * 5.0
	if p_hop > 0:
		pfy -= 2.0
	for d in dust:
		var a: float = d.t / 0.35
		var s := 3 if a > 0.5 else 2
		draw_rect(Rect2(roundi(d.x), roundi(d.y), s, s), Color(0.85, 0.85, 0.95, 0.5 * a))
	_shadow(gx(p.c) + CW / 2.0, feet_y(p.r), 30)
	if st.decoy > 0 and st.decoy_t > 0:
		for k in st.decoy:
			_draw_sprite(mkey, pcx - 16 - k * 10, pfy, false, {"scale": BABY_SCALE if run.stage == 1 else 1, "mod": Color(0.6, 1.0, 0.8, 0.35 + 0.1 * sin(anim_t * 8.0 + k))})
	_draw_sprite(mkey, pcx, pfy, false, {"flash": p.flash > 0, "blink": blink_p, "bob": bob_p, "scale": BABY_SCALE if run.stage == 1 else 1})
	var body := Vector2(gx(p.c) + CW / 2.0, feet_y(p.r) - 24)
	if muzzle > 0:
		# Mündungsblitz vorn am Monster
		var mz := Vector2(roundi(pcx + 22), roundi(pfy - 22))
		var k := muzzle / 0.09
		draw_rect(Rect2(mz - Vector2(5, 1) * k * 2, Vector2(10, 2) * k * 2), Color(muzzle_col, 0.9))
		draw_rect(Rect2(mz - Vector2(1, 4) * k * 2, Vector2(2, 8) * k * 2), Color(muzzle_col, 0.9))
		draw_rect(Rect2(mz - Vector2(2, 2), Vector2(4, 4)), Color.WHITE)
	if st.shield > 0:
		for i in 12:
			var a0 := i * TAU / 12.0 + anim_t * 2.0
			draw_arc(body, 30, a0, a0 + TAU / 24.0, 3, GameData.EL.Code, 2)
	if st.heat > 0:
		for i in 12:
			var a1 := i * TAU / 12.0 - anim_t * 3.0
			draw_arc(body, 28, a1, a1 + TAU / 24.0, 3, GameData.EL.Feuer, 2)
	if st.mist > 0:
		draw_circle(body, 32, Color(0.85, 0.9, 1.0, 0.18 + 0.05 * sin(anim_t * 6.0)))
	if st.bubble > 0 and st.bubble_t > 0:
		draw_circle(body, 30, Color(GameData.EL.Wasser, 0.2))
		draw_arc(body, 30, 0, TAU, 32, Color(GameData.EL.Wasser, 0.8), 1)
		draw_rect(Rect2(body + Vector2(-14, -18), Vector2(4, 4)), Color.WHITE)
	for i in st.bots.size():
		var bp := body + Vector2(-26 + i * 8, -26 + sin(anim_t * 8.0 + i) * 2)
		draw_rect(Rect2(bp, Vector2(8, 6)), GameData.COL.dark)
		draw_rect(Rect2(bp + Vector2(1, 1), Vector2(6, 4)), GameData.EL.Code)

	# Gegner
	var defeated: bool = st.outcome == "won"
	if e.hp > 0 or defeated:
		var ecx := gx(3 + e.c) + CW / 2.0
		var efy := feet_y(e.r)
		# Ausholen während einer Warnung, dann Vorschnellen
		var windup := 0.0
		for w in st.warns:
			windup = maxf(windup, 1.0 - w.t / w.max)
		ecx += windup * 4.0
		if e_strike > 0:
			ecx -= sin((1.0 - e_strike / 0.12) * PI) * 9.0
		if e_knock > 0:
			ecx += sin((1.0 - e_knock / (KNOCK * 1.5)) * PI) * 6.0
		var fade := 1.0
		if defeated:
			# Niederlage: blinken, absinken, verblassen
			var k2 := clampf(1.0 - end_timer / 0.65, 0.0, 1.0)
			fade = 1.0 - k2
			efy += k2 * 10.0
			if fmod(anim_t, 0.1) < 0.05:
				fade *= 0.4
		_shadow(ecx, efy, 44 if st.def.boss else 34)
		var tint := Color.WHITE
		if st.boss_phase() == 3 and sin(anim_t * 14.0) > 0.4:
			tint = Color("#FF9DB3")
		elif st.def.get("elite", false):
			tint = Color(1.0, 0.78, 0.72)
		tint.a = fade
		_draw_sprite(st.def.spr, ecx, efy, true, {"flash": e.flash > 0 or (defeated and fade > 0.6), "blink": blink_e, "bob": bob_e, "mod": tint})
		if e.frozen > 0:
			var rect := cell_rect(3 + e.c, e.r)
			draw_rect(Rect2(rect.position.x + 4, rect.position.y - 40, rect.size.x - 8, rect.size.y + 34), Color(GameData.EL.Wasser, 0.3))
		if st.delayed.any(func(d): return d.mark):
			var cc := Vector2(ecx, efy - 26)
			var rad := 22.0 + 3.0 * sin(anim_t * 20.0)
			draw_arc(cc, rad, 0, TAU, 24, GameData.EL.Elektro, 1)
			draw_rect(Rect2(cc.x - 32, cc.y, 64, 1), GameData.EL.Elektro)
			draw_rect(Rect2(cc.x, cc.y - 32, 1, 64), GameData.EL.Elektro)


func _proj_pos(pr: Dictionary) -> Vector2:
	if pr.lob:
		var k: float = pr.t / pr.dur
		var fx := gx(pr.fx)
		var tx := gx(pr.tx)
		return Vector2(fx + (tx - fx) * k, feet_y(pr.fr) - 22 + (feet_y(pr.tr) - feet_y(pr.fr)) * k - sin(k * PI) * 40.0)
	return Vector2(gx(pr.x), feet_y(pr.row) - 22)


func _draw_effects() -> void:
	for pr in st.proj:
		var pos := _proj_pos(pr)
		var col: Color = GameData.EL.get(pr.el, GameData.EL.Feuer)
		if not pr.has("hist"):
			pr.hist = []
		pr.hist.append(pos)
		if pr.hist.size() > 6:
			pr.hist.pop_front()
		for i in pr.hist.size():
			var k: float = float(i + 1) / pr.hist.size()
			var s := roundi((6.0 if pr.lob else 4.0) * k)
			draw_rect(Rect2(pr.hist[i] - Vector2(s, s) / 2, Vector2(s, s)), Color(col, k * 0.4))
		if pr.lob:
			draw_rect(Rect2(pos - Vector2(6, 6), Vector2(12, 12)), col.darkened(0.55))
			draw_rect(Rect2(pos - Vector2(4, 4), Vector2(8, 8)), col)
			draw_rect(Rect2(pos - Vector2(2, 3), Vector2(3, 3)), Color("#FFF1B8"))
		else:
			draw_rect(Rect2(pos - Vector2(13, 3), Vector2(26, 7)), col.darkened(0.5))
			draw_rect(Rect2(pos - Vector2(12, 2), Vector2(24, 5)), col)
			draw_rect(Rect2(pos + Vector2(0, -1), Vector2(9, 2)), Color.WHITE)
	for q in st.pops:
		_draw_minion(q)
	for q in st.parts:
		if q.has("cell"):
			continue
		var x := gx(q.x)
		var y: float = Y0 + q.y * CH + FEET - 2.5 * CH / 2.0
		if q.has("ring"):
			var k: float = 1.0 - q.t / q.max
			draw_arc(Vector2(x, y), 6.0 + 20.0 * k, 0, TAU, 20, Color(q.color, q.t / q.max), maxf(1.0, 3.0 * (1.0 - k)))
			continue
		var s := 3 if q.t / q.max > 0.5 else 2
		draw_rect(Rect2(roundi(x - s / 2.0), roundi(y - s / 2.0), s, s), Color(q.color, q.t / q.max))
	for f in st.fx:
		var k: float = f.t / f.max
		var big := k > 0.8
		var pos := Vector2(gx(f.x) - 70, Y0 + f.y * CH - 30)
		_text(pos, f.text, 16 if big else 8, Color(f.color, minf(1.0, k * 1.6)), HORIZONTAL_ALIGNMENT_CENTER, 140, true, true)
	if not st.banner.is_empty():
		var b: Dictionary = st.banner
		var k: float = b.t / b.max
		var a := minf(1.0, k * 2.5)
		draw_rect(Rect2(-off, Vector2(W, H)), Color(b.color, a * 0.15))
		_text(Vector2(0, 120 - (1.0 - k) * 6), b.text.to_upper(), 24, Color(b.color, a), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


func _draw_hud() -> void:
	# Spieler links
	var P := Rect2(8, 8, 200, 34)
	_box(P, Color(GameData.COL.panel, 0.9), GameData.COL.line)
	_text(P.position + Vector2(6, 12), run.form, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(P.position + Vector2(6, 12), _hud_sub(run.form, "%s · %s" % [GameData.STAGE_NAMES[run.stage], run.form_el()], GameData.STAGE_NAMES[run.stage], P.size.x - 12), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, P.size.x - 12)
	_bar(Rect2(P.position + Vector2(6, 18), Vector2(128, 9)), float(run.hp) / run.max_hp, GameData.COL.mint)
	_text(P.position + Vector2(6, 26), "%d/%d" % [run.hp, run.max_hp], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, P.size.x - 12)
	var buffs: Array = []
	if st.reflex > 0:
		buffs.append(["Katzenreflex", GameData.COL.mint])
	if st.oc > 0:
		buffs.append(["Übertaktet", GameData.EL.Feuer])
	if st.scan > 0:
		buffs.append(["Scan x%d" % st.scan, GameData.EL.Code])
	if st.mist > 0:
		buffs.append(["Nebel", GameData.EL.Wasser])
	var bx := 8.0
	for bf in buffs:
		var bw := text_width(bf[0]) + 8
		_box(Rect2(bx, 45, bw, 13), GameData.COL.dark, bf[1])
		_text(Vector2(bx, 55), bf[0], 8, bf[1], HORIZONTAL_ALIGNMENT_CENTER, bw, false)
		bx += bw + 3
	# Module: kleine Symbole neben den Buffs
	if not run.modules.is_empty():
		_draw_module_row(run.modules, bx + (4 if buffs.size() > 0 else 0), 44, 8)
	# Gegner rechts
	var E := Rect2(W - 208, 8, 200, 34)
	_box(E, Color(GameData.COL.panel, 0.9), GameData.EL[st.def.el].darkened(0.3))
	_text(E.position + Vector2(6, 12), st.def.name, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(E.position + Vector2(6, 12), st.def.el, 8, GameData.EL[st.def.el], HORIZONTAL_ALIGNMENT_RIGHT, E.size.x - 12)
	_bar(Rect2(E.position + Vector2(6, 18), Vector2(128, 9)), float(st.e.hp) / st.e.max, GameData.COL.coral)
	_text(E.position + Vector2(6, 26), "%d/%d" % [st.e.hp, st.e.max], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, E.size.x - 12)
	var tags: Array = []
	if st.e.burn > 0:
		tags.append(["Brand", GameData.EL.Feuer])
	if st.e.poison > 0:
		tags.append(["Gift", GameData.EL.Virus])
	if st.e.frozen > 0:
		tags.append(["Eis", GameData.EL.Wasser])
	if st.e.slow > 0:
		tags.append(["Langsam", GameData.EL.Wasser])
	var tx := W - 8.0
	for tg in tags:
		var w := text_width(tg[0]) + 8
		tx -= w
		_box(Rect2(tx, 45, w, 13), GameData.COL.dark, tg[1])
		_text(Vector2(tx, 55), tg[0], 8, tg[1], HORIZONTAL_ALIGNMENT_CENTER, w, false)
		tx -= 3
	# Raum + Hinweis
	var kind: String = ZoneMap.TYPE_NAMES[node_type]
	_text(Vector2(0, 20), "%s · Etage %d · %s" % [run.map.zone_name, run.floor_idx + 1, kind], 8, GameData.COL.sun if node_type != "fight" else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	if st.status != "" and st.t < 6.0:
		_text(Vector2(0, 76), st.status, 8, Color(GameData.COL.sun, clampf(6.0 - st.t, 0.0, 1.0)), HORIZONTAL_ALIGNMENT_CENTER, W)


## Untertitel im HUD kürzen, wenn er mit einem langen Namen kollidieren würde
func _hud_sub(name: String, full: String, short: String, w: float) -> String:
	return full if text_width(name, 8, true) + text_width(full) + 10 <= w else short


func _draw_hand() -> void:
	var nx := st.next_chip()
	_text(Vector2(HAND_X, 302), "Als Nächstes: " + (nx if nx != "" else "–"), 8, GameData.COL.muted)
	_text(Vector2(HAND_X, 302), ("Start" if InputSetup.pad else "Esc") + ": Pause", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, 3 * CARD_W + 2 * 6 + 6 + 130)
	for i in 3:
		var s: Dictionary = st.hand[i]
		var r := Rect2(HAND_X + i * (CARD_W + 6), HAND_Y, CARD_W, CARD_H)
		if s.chip == "":
			_box(r, GameData.COL.bg2, GameData.COL.line)
			continue
		var ch: Dictionary = GameData.CHIPS[s.chip]
		var el: Color = GameData.EL[ch.el]
		var ready: bool = s.rem <= 0
		_box(r, GameData.COL.panel if ready else GameData.COL.bg2, el if ready else GameData.COL.line)
		draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(3, r.size.y - 2)), el)
		# Tasten-Symbol
		var g := Rect2(r.position + Vector2(8, 5), Vector2(15, 14))
		_box(g, GameData.COL.dark, el if ready else GameData.COL.line)
		_text(g.position + Vector2(1, 11), _glyph_chip(i), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, g.size.x, false, true)
		_text(r.position + Vector2(29, 16), s.chip, 8, GameData.COL.ink if ready else GameData.COL.muted, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		var info: String = ch.cat + (" %d" % ch.dmg if ch.dmg > 0 else "")
		_text(r.position + Vector2(8, 33), info, 8, GameData.COL.muted)
		if ready:
			_text(r.position + Vector2(8, 33), "bereit", 8, el, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 14)
		else:
			_bar(Rect2(r.position + Vector2(6, r.size.y - 8), Vector2(r.size.x - 12, 5)), 1.0 - s.rem / s.max, el.darkened(0.2))
			if s.queued:
				_text(r.position + Vector2(8, 33), "gemerkt", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 14)
	# Signatur-Attacke
	var R := Rect2(HAND_X + 3 * (CARD_W + 6), HAND_Y, 130, CARD_H)
	var full := st.sp >= 100
	var S: Dictionary = run.special()
	var sel: Color = GameData.EL[S.el]
	var pulse := full and sin(anim_t * 8.0) > 0
	_box(R, GameData.COL.panel if full else GameData.COL.bg2, GameData.COL.sun if pulse else GameData.COL.line)
	var glyph := "A" if InputSetup.pad else "Leer"
	var g2 := Rect2(R.position + Vector2(6, 5), Vector2(text_width(glyph, 8, true) + 8, 14))
	_box(g2, GameData.COL.dark, GameData.COL.sun if full else GameData.COL.line)
	_text(g2.position + Vector2(1, 11), glyph, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, g2.size.x, false, true)
	_text(R.position + Vector2(g2.size.x + 10, 16), "Signatur", 8, GameData.COL.sun if full else GameData.COL.muted)
	_text(R.position + Vector2(6, 33), S.name, 8, GameData.COL.ink if full else GameData.COL.muted)
	_bar(Rect2(R.position + Vector2(6, R.size.y - 8), Vector2(R.size.x - 12, 5)), st.sp / 100.0, GameData.COL.sun if full else sel.darkened(0.2))


func _panel(r: Rect2) -> void:
	_dim()
	_box(r, GameData.COL.panel, GameData.COL.line)


func _draw_pause() -> void:
	var r := Rect2(60, 40, 520, 280)
	_panel(r)
	_text(r.position + Vector2(0, 28), "Pause", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	_text(Vector2(r.position.x + 20, r.position.y + 46), "Dein Deck", 8, GameData.COL.muted)
	_draw_deck_list(run.deck, r.position.x + 20, r.position.y + 66, 220, 10)
	_text(Vector2(r.position.x + 270, r.position.y + 46), "Module (%d)" % run.modules.size(), 8, GameData.COL.muted)
	_draw_module_list(run.modules, r.position.x + 270, r.position.y + 58, 230, 4)
	_text(Vector2(r.position.x + 20, r.end.y - 62), "Ziehstapel %d · Abwurf %d" % [st.draw_pile.size(), st.disc.size()], 8, GameData.COL.muted)
	_menu(PAUSE_ITEMS, pause_idx, r.get_center().x, r.end.y - 50, 160)


func _draw_pick() -> void:
	var es := run.evo_status()
	var r := Rect2(40, 30, 560, 300)
	_panel(r)
	_text(r.position + Vector2(0, 30), "Sieg!", 16, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	var line := "%s ist defragmentiert. +%d Fragmente" % [st.def.name, st.loot_gained if st.loot_gained > 0 else st.def.loot]
	if heal_info > 0:
		line += ", +%d HP" % heal_info
	_text(r.position + Vector2(0, 48), line + ".", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(r.position + Vector2(0, 62), "Wähle einen Chip für den Rest des Runs.", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	# Elite-Belohnung: neues Modul unter den Karten
	if new_module != "":
		var M: Dictionary = GameData.MODULES[new_module]
		var head: String = "Neues Modul: " + M.name
		var tw := text_width(head, 8, true)
		var tx := r.get_center().x - tw / 2.0 + 9
		_draw_module_icon(new_module, Vector2(tx - 20, r.position.y + 213))
		_text(Vector2(tx, r.position.y + 224), head, 8, Color(M.col), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		_text(Vector2(r.position.x, r.position.y + 240), M.desc, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	for i in 3:
		var k: String = choices[i]
		var ch: Dictionary = GameData.CHIPS[k]
		var el: Color = GameData.EL[ch.el]
		var sel := i == pick_idx
		var c := Rect2(r.position.x + 24 + i * 176, r.position.y + 78 - (4 if sel else 0), 160, 122)
		_box(c, GameData.COL.panel.lightened(0.08) if sel else GameData.COL.bg2, GameData.COL.sun if sel else el.darkened(0.3))
		draw_rect(Rect2(c.position + Vector2(1, 1), Vector2(c.size.x - 2, 4)), el)
		_text(c.position + Vector2(0, 24), k, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, c.size.x, true, true)
		_text(c.position + Vector2(0, 38), "%s · %s" % [ch.el, ch.rar], 8, el, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		var stats: String = ch.cat + (" · %d" % ch.dmg if ch.dmg > 0 else "") + " · %.1fs" % ch.cd
		_text(c.position + Vector2(0, 52), stats, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		draw_multiline_string(font(), c.position + Vector2(8, 70), ch.desc, HORIZONTAL_ALIGNMENT_CENTER, c.size.x - 16, 8, 3, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
		# Wirkung auf die Evolution
		var tag := ""
		var tag_col: Color = GameData.COL.muted
		if ch.el == "Neutral":
			tag = "Neutral: prägt nicht"
		elif int(es.need) > 0 and run.stage == 1:
			if run.mon.evo.has(ch.el):
				var f: String = run.mon.evo[ch.el]
				tag = "Prägt > %s" % (f if SaveGame.data.get("dex", {}).has(f) else ch.el + "-Form")
				tag_col = el
			else:
				tag = "Ohne Wirkung auf %s" % run.form
		elif int(es.need) > 0:
			tag = "Zählt zur nächsten Stufe"
			tag_col = el
		_text(Vector2(c.position.x, c.end.y - 6), tag, 8, tag_col, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
	var evo_line := ""
	if int(es.need) > 0:
		var lead: String = ("Richtung %s" % es.leader) if es.leader != "" else "Richtung offen"
		evo_line = " · Element-Chips %d/%d · %s" % [mini(int(es.total), int(es.need)), int(es.need), lead]
	_text(Vector2(r.position.x, r.end.y - 36), "Deck: %d Chips · Fragmente: %d%s" % [run.deck.size(), run.frag, evo_line], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var pad: bool = InputSetup.pad
	_text(Vector2(r.position.x, r.end.y - 16), "< > wählen   %s nehmen   %s überspringen" % ["A" if pad else "Enter", "B" if pad else "Esc"], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)


func _draw_evolve() -> void:
	var t := mode_t
	var c := Vector2(W / 2.0, 220)
	var from: String = evo.from
	var to: String = evo.to
	var el: Color = GameData.EL[GameData.FORMS[to].el]
	# Lichtsäule
	var glow := clampf(t / EVO_REVEAL, 0.0, 1.0)
	draw_rect(Rect2(c.x - 40 * glow, 0, 80 * glow, H), Color(el, 0.12 * glow))
	for i in 12:
		var a := i * TAU / 12.0 + t * 2.0
		var rad := 70.0 - fmod(t * 40.0 + i * 13.0, 60.0)
		draw_rect(Rect2(c + Vector2(cos(a), sin(a) * 0.5) * rad - Vector2(1, 60), Vector2(2, 2)), el.lightened(0.4))
	if t < EVO_REVEAL:
		# Wechsel zwischen alter und neuer Silhouette, immer schneller
		var freq := 2.0 + t * t * 6.0
		var show_new := fmod(t * freq, 1.0) > 0.5
		var key := to if show_new else from
		_draw_sprite(key, c.x, c.y, false, {"flash": true, "scale": 2 if GameData.FORMS[key].stage == 1 else 1})
		_text(Vector2(0, 60), "%s entwickelt sich …" % from, 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	else:
		var k := t - EVO_REVEAL
		if k < 0.25:
			draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k / 0.25))
		var bob := 1 if sin(anim_t * 4.0) > 0 else 0
		_draw_sprite(to, c.x, c.y, false, {"bob": bob})
		_text(Vector2(0, 60), "%s ist jetzt %s!" % [from, to], 16, el, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		var S: Dictionary = GameData.SPECIALS[to]
		_text(Vector2(0, 80), "%s · %s · +10 max. HP" % [GameData.STAGE_NAMES[run.stage], GameData.FORMS[to].el], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
		_text(Vector2(0, 256), "Neue Signatur: " + S.name, 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		_text(Vector2(0, 270), S.desc, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
		if k > 0.6:
			_text(Vector2(0, 300), "%s weiter" % ("A" if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


func _draw_tutorial() -> void:
	var tx: Array = tut.texts(InputSetup.pad)
	if tx.is_empty():
		return
	var r := Rect2(130, 66, 380, 50)
	var pulse := 0.5 + 0.5 * sin(anim_t * 4.0)
	_box(r, Color(GameData.COL.panel, 0.95), GameData.COL.sun.lerp(GameData.COL.mint, pulse))
	_text(Vector2(r.position.x + 10, r.position.y + 16), tx[0], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	# Fortschrittspunkte der vier Lernschritte
	for i in 4:
		var done: bool = tut.step > i
		var cur: bool = tut.step == i
		draw_rect(Rect2(r.end.x - 52 + i * 11, r.position.y + 9, 7, 7), GameData.COL.mint if done else (GameData.COL.sun if cur else GameData.COL.line))
	draw_multiline_string(font(), Vector2(r.position.x + 10, r.position.y + 32), tx[1], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 20, 8, 2, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)


## Für Screenshots/Tests: den Kampf mit Autopilot vorspulen.
func simulate(seconds: float) -> void:
	if mode == Mode.INTRO:
		_start_boss_fight()
	var bot := BattleBot.new(0.15)
	var dt := 1.0 / 60.0
	var steps := 0
	while steps * dt < seconds and (not st.over or end_timer > 0.1):
		bot.act(st)
		st.update(dt)
		for ev in st.events:
			_animate_event(ev)
		st.events.clear()
		_tick_anims(dt)
		anim_t += dt
		steps += 1
		if st.over:
			end_timer = 0.65 if end_timer < 0 else end_timer - dt
	st.events.clear()


func show_pick_for_screenshot() -> void:
	st.over = true
	st.outcome = "won"
	_fight_over()


## Boss-Diener auf dem Spielerfeld: Bitmilbe (Krabbel-Bot) oder Glitch-Spore; beide platzen, wenn die Zeit abläuft
func _draw_minion(q: Dictionary) -> void:
	var rect := cell_rect(q.c, q.r)
	var k: float = 1.0 - q.t / q.max          # 0 = frisch, 1 = platzt gleich
	var fast := fmod(anim_t, 0.5 - 0.35 * k) < 0.12
	var cx := roundf(rect.get_center().x)
	var fy := roundf(rect.position.y + FEET - 6)
	if q.get("kind", "milbe") == "spore":
		# pulsierende Spore, die anschwillt
		var rad := roundf(6.0 + 4.0 * k + sin(anim_t * 8.0) * 1.0)
		var c := Vector2(cx, fy - rad)
		draw_circle(c, rad + 1.0, GameData.COL.dark)
		draw_circle(c, rad, Color("#5E2A86"))
		draw_circle(c + Vector2(-1, -1), rad - 2.0, Color("#7BD35A") if not fast else Color("#D8FF6A"))
		draw_rect(Rect2(c.x - rad * 0.5, c.y - rad * 0.6, 2, 2), Color(1, 1, 1, 0.8))
		for i in 3:
			var a := anim_t * 2.0 + i * TAU / 3.0
			var pp := c + Vector2(cos(a), sin(a)) * (rad + 4.0)
			draw_rect(Rect2(roundi(pp.x), roundi(pp.y), 1, 1), Color("#D8FF6A", 0.8))
	else:
		# Bitmilbe: Krabbel-Bot mit blinkendem roten Auge, glüht kurz vor dem Platzen
		var bob := roundi(sin(anim_t * 12.0 + q.c) * 1.0)
		var body := Rect2(cx - 11, fy - 13 + bob, 22, 11)
		for i in 3:
			var lx := cx - 8 + i * 8
			var step := 1 if fmod(anim_t * 10.0 + i, 2.0) < 1.0 else -1
			draw_line(Vector2(lx, fy - 3 + bob), Vector2(lx - 4 + step, fy + 2), GameData.COL.dark, 2.0)
			draw_line(Vector2(lx, fy - 3 + bob), Vector2(lx + 4 - step, fy + 2), GameData.COL.dark, 2.0)
		if k > 0.6:
			draw_rect(body.grow(3), Color("#FF5470", 0.25 + 0.25 * sin(anim_t * 30.0)))
		draw_rect(body.grow(1), GameData.COL.dark)
		draw_rect(body, Color("#8A84A0"))
		draw_rect(Rect2(body.position, Vector2(body.size.x, 3)), Color("#B8B0C8"))
		draw_rect(Rect2(body.position.x + 3, body.end.y - 3, body.size.x - 6, 1), Color("#FF5470"))
		var head := Rect2(cx - 17, fy - 12 + bob, 7, 7)
		draw_rect(head.grow(1), GameData.COL.dark)
		draw_rect(head, Color("#8A84A0"))
		draw_rect(Rect2(head.position.x + 1, head.position.y + 2, 3, 3), Color("#FF5470") if fast else Color("#B02A50"))
		draw_rect(Rect2(cx + 2, fy - 18 + bob, 1, 5), GameData.COL.dark)
		draw_rect(Rect2(cx + 1, fy - 19 + bob, 3, 2), Color("#FF5470") if fast else Color("#B8B0C8"))
	# Zündschnur
	draw_rect(Rect2(cx - 12, fy + 4, 24, 2), GameData.COL.dark)
	draw_rect(Rect2(cx - 12, fy + 4, 24.0 * q.t / q.max, 2), Color("#FF5470"))


# ---------- Boss-Intro ----------

func _process_intro(_delta: float) -> void:
	var t := mode_t
	var cues := [[0.05, "warn"], [0.45, "warn"], [0.85, "warn"], [1.0, "charge"], [INTRO_REVEAL, "hit_big"]]
	for c in cues:
		if t - _delta < c[0] and t >= c[0]:
			Sfx.play(c[1], 0.0)
			if c[1] == "hit_big":
				st.shake = 10.0
				Music.play(_boss_track())
	if st.shake > 0:
		st.shake = maxf(0.0, st.shake - _delta * 20.0)
	# überspringen (kurze Sperre, damit der Tastendruck von der Karte nicht durchrutscht)
	if t > 0.35 and (Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("pause")):
		Sfx.play("confirm")
		_start_boss_fight()
		return
	if t >= INTRO_END:
		_start_boss_fight()


func _boss_track() -> String:
	return "finale" if st.def.get("final", false) else "boss"


func _start_boss_fight() -> void:
	if Music.current != _boss_track():
		Music.play(_boss_track())
	st.shake = 0.0
	_set_mode(Mode.FIGHT)


func _draw_boss_intro() -> void:
	var t := mode_t
	var def: Dictionary = st.def
	var el: Color = GameData.EL[def.el]
	# Abgedunkelter Boss-Hintergrund
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.55))
	var shake := Vector2.ZERO
	if st.shake > 0 and Settings.screen_shake:
		shake = Vector2(roundi(randf_range(-st.shake, st.shake) * 0.5), roundi(randf_range(-st.shake, st.shake) * 0.5))
	# Lichtkegel hinter dem Boss nach der Enthüllung
	var cx := W / 2.0 + 140.0
	if t > INTRO_REVEAL:
		var g := clampf((t - INTRO_REVEAL) / 0.4, 0.0, 1.0)
		for i in 12:
			var a := i * TAU / 12.0 + anim_t * 0.3
			var d := Vector2(cos(a), sin(a))
			var nn := Vector2(-d.y, d.x)
			var c0 := Vector2(cx, 170)
			draw_colored_polygon(PackedVector2Array([c0, c0 + d * 420.0 + nn * 36.0, c0 + d * 420.0 - nn * 36.0]), Color(el, 0.06 * g))
	# Boss: gleitet als Silhouette herein, wird bei der Enthüllung farbig (doppelte Größe, ganzzahlig)
	var slide := clampf((t - 0.5) / 1.1, 0.0, 1.0)
	slide = 1.0 - pow(1.0 - slide, 3.0)
	var bx := lerpf(W + 120.0, cx, slide) + shake.x
	var feet := 268.0 + shake.y
	if t > 0.5:
		off = Vector2.ZERO
		if t < INTRO_REVEAL:
			_draw_sprite(def.spr, bx, feet, true, {"scale": 2, "flash": true, "mod": Color(0.02, 0.01, 0.06, 1.0)})
			# glühende Augen-Andeutung in der Silhouette: roter Schimmer am Boden
			draw_rect(Rect2(bx - 90, feet - 2, 180, 3), Color(el, 0.25))
		else:
			_draw_sprite(def.spr, bx, feet, true, {"scale": 2, "blink": fmod(anim_t, 3.0) < 0.12})
			if def.get("final", false):
				# Glitch-Streifen über dem Endboss
				for i in 4:
					if fmod(anim_t * 3.0 + i * 0.37, 1.0) < 0.12:
						var gy := feet - 20.0 - fmod(i * 47.0 + anim_t * 90.0, 170.0)
						draw_rect(Rect2(bx - 96, gy, 192, 3), Color("#4CC3F0", 0.5) if i % 2 else Color("#FF5470", 0.5))
	# Warnstreifen oben und unten
	var bars := clampf(t / 0.35, 0.0, 1.0)
	var bh := 26.0
	for top in [true, false]:
		var y := (-bh + bh * bars) if top else (H - bh * bars)
		draw_rect(Rect2(0, y, W, bh), Color("#1A0610"))
		var sh := fmod(anim_t * 60.0, 24.0) * (1.0 if top else -1.0)
		for i in range(-2, 30):
			var x0 := i * 24.0 + sh
			draw_colored_polygon(PackedVector2Array([Vector2(x0, y + 4), Vector2(x0 + 12, y + 4), Vector2(x0 + 4, y + bh - 4), Vector2(x0 - 8, y + bh - 4)]), Color("#FF5470", 0.85))
		var txt := "  WARNUNG  ·  BOSS  ·  WARNUNG  ·  BOSS  ·  WARNUNG  ·  BOSS  ·  WARNUNG  ·  BOSS"
		var tx := -fmod(anim_t * 80.0, 200.0) if top else -200.0 + fmod(anim_t * 80.0, 200.0)
		_text(Vector2(tx, y + bh / 2.0 + 4), txt, 8, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	# Weißer Blitz bei der Enthüllung
	if t > INTRO_REVEAL and t < INTRO_REVEAL + 0.35:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - (t - INTRO_REVEAL) / 0.35))
	# Name mit Glitch-Versatz, darunter der Titel
	if t > INTRO_REVEAL + 0.15:
		var k := clampf((t - INTRO_REVEAL - 0.15) / 0.3, 0.0, 1.0)
		var nx := lerpf(-260.0, 36.0, 1.0 - pow(1.0 - k, 3.0))
		var name_s: String = def.name.to_upper()
		var jit := Vector2(randi_range(-2, 2), 0) if fmod(anim_t, 1.3) < 0.08 else Vector2.ZERO
		var f := font(true)
		var fs := 24 if text_width(name_s, 24, true) <= 290 else 16
		draw_rect(Rect2(nx - 12, 96, 300, 3), el)
		draw_string(f, Vector2(nx - 1, 136) + jit, name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("#4CC3F0", 0.8))
		draw_string(f, Vector2(nx + 1, 136) - jit, name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("#FF5470", 0.8))
		draw_string_outline(f, Vector2(nx, 136), name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, GameData.COL.dark)
		draw_string(f, Vector2(nx, 136), name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
		if t > INTRO_REVEAL + 0.45:
			var tk := clampf((t - INTRO_REVEAL - 0.45) / 0.3, 0.0, 1.0)
			_text(Vector2(nx, 156), def.get("title", "Herrscher dieser Zone"), 8, Color(el.lightened(0.3), tk), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
			_text(Vector2(nx, 172), "%s · %d HP" % [def.el, def.hp], 8, Color(GameData.COL.muted, tk))
	_text(Vector2(0, H - 34), "%s überspringen" % ("A" if InputSetup.pad else "Enter"), 8, Color(GameData.COL.muted, 0.7), HORIZONTAL_ALIGNMENT_RIGHT, W - 12)


func show_intro_for_screenshot(t: float) -> void:
	_set_mode(Mode.INTRO)
	mode_t = t
	anim_t = t
	st.shake = 0.0


func show_pick_modules_for_screenshot(mods: Array, elite_mod: String) -> void:
	for m in mods:
		run.add_module(m)
	new_module = elite_mod


func show_evolve_for_screenshot(t: float) -> void:
	st.over = true
	st.outcome = "won"
	run.chips_used = maxi(run.chips_used, GameData.EVO_AT[2])
	var evo_el: String = "Feuer" if run.stage == 1 else GameData.FORMS[run.form].el
	run.praeg[evo_el] = run.praeg.get(evo_el, 0) + maxi(9, run.evo_need())
	_fight_over()
	mode_t = t


func show_pause_for_screenshot() -> void:
	_set_mode(Mode.PAUSE)
