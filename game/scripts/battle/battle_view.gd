extends Node2D
## Kampfbildschirm: Ablauf eines Runs (Kampf → Chipwahl → … → Boss → Ergebnis), Eingabe und Zeichnen.
## Alles wird in 640×360 gezeichnet und vom Fenster ganzzahlig hochskaliert.
##
## Screenshot-Modus (für Tests/Review), Argumente nach „--“:
##   --shot=<pfad.png> [--mode=fight|pick|pause|result] [--room=0..3] [--sim=<sekunden>] [--pad]

const W := 640
const H := 360
const CW := 80          # Feldbreite
const CH := 44          # Feldhöhe
const GAP := 14         # Abstand zwischen Spieler- und Gegnerseite
const X0 := 73
const Y0 := 150
const FEET := 36        # Fußlinie innerhalb eines Feldes
const CARD_W := 136
const CARD_H := 46
const HAND_Y := 306
const HAND_X := 57

enum Mode { FIGHT, PAUSE, PICK, RESULT }

const SPRITE_FILES := {"pixi": "pixi_32", "bug": "bug_64", "moth": "moth_64", "spam": "spam_64", "boss": "boss_96"}

var run: RunState
var st: BattleState
var mode := Mode.FIGHT
var end_timer := -1.0
var choices: Array = []
var pick_idx := 1
var heal_info := 0
var won_run := false
var pad := false
var font: Font
var spr := {}
var shot := {}
var off := Vector2.ZERO
var anim_t := 0.0


func _ready() -> void:
	font = _make_font()
	for key in SPRITE_FILES:
		spr[key] = _load_sprite(SPRITE_FILES[key])
	_parse_args()
	if shot.is_empty():
		new_run()
	else:
		_take_screenshot()


# ---------- Ablauf ----------

func new_run(seed_value := -1) -> void:
	run = RunState.new("Pixmiez", seed_value)
	won_run = false
	_start_fight()


func _start_fight() -> void:
	st = BattleState.new(run, run.room)
	mode = Mode.FIGHT
	end_timer = -1.0


func _fight_over() -> void:
	if st.outcome == "lost":
		won_run = false
		mode = Mode.RESULT
	elif run.is_last_room():
		won_run = true
		mode = Mode.RESULT
	else:
		heal_info = mini(15, run.max_hp - run.hp)
		run.hp += heal_info
		choices = run.roll_choices()
		pick_idx = 1
		mode = Mode.PICK


func _take_pick() -> void:
	run.deck.append(choices[pick_idx])
	run.room += 1
	_start_fight()


# ---------- Eingabe ----------

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5):
		pad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		pad = false


func _process(delta: float) -> void:
	anim_t += delta
	match mode:
		Mode.FIGHT:
			_process_fight(delta)
		Mode.PAUSE:
			if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("confirm"):
				mode = Mode.FIGHT
		Mode.PICK:
			if Input.is_action_just_pressed("move_left"):
				pick_idx = (pick_idx + 2) % 3
			if Input.is_action_just_pressed("move_right"):
				pick_idx = (pick_idx + 1) % 3
			if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("chip_1"):
				_take_pick()
		Mode.RESULT:
			if Input.is_action_just_pressed("confirm"):
				new_run()
	queue_redraw()


func _process_fight(delta: float) -> void:
	if not st.over:
		if Input.is_action_just_pressed("pause"):
			mode = Mode.PAUSE
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
	if st.freeze > 0:
		st.freeze -= delta
	else:
		st.update(delta)
	if st.over:
		if end_timer < 0:
			end_timer = 0.65
		end_timer -= delta
		if end_timer <= 0:
			_fight_over()


# ---------- Hilfen ----------

func _make_font() -> Font:
	var f: Font = ThemeDB.fallback_font
	if f is FontFile:
		var ff: FontFile = f.duplicate()
		ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		ff.hinting = TextServer.HINTING_NORMAL
		ff.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		return ff
	return f


func _load_sprite(file: String) -> Dictionary:
	var tex: Texture2D = load("res://assets/sprites/%s.png" % file)
	var blink_path := "res://assets/sprites/%s_blink.png" % file
	var blink: Texture2D = load(blink_path) if ResourceLoader.exists(blink_path) else tex
	var img := tex.get_image()
	if img.is_compressed():
		img.decompress()
	# Transparente Zeilen unter den Füßen zählen, damit das Monster auf der Plattform steht
	var foot := 0
	for y in range(img.get_height() - 1, -1, -1):
		var empty := true
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.1:
				empty = false
				break
		if not empty:
			break
		foot += 1
	var white: Image = img.duplicate()
	for y in white.get_height():
		for x in white.get_width():
			var a := white.get_pixel(x, y).a
			if a > 0.0:
				white.set_pixel(x, y, Color(1, 1, 1, a))
	return {"tex": tex, "blink": blink, "flash": ImageTexture.create_from_image(white), "n": img.get_width(), "foot": foot}


## Spieler-Babys (32 px) werden verdoppelt, ab Rookie 1 Kunstpixel = 1 Pixel.
func _sprite_scale(key: String) -> int:
	return 2 if spr[key].n <= 32 else 1


func _draw_sprite(key: String, cx: float, feet_y: float, flip: bool, opts := {}) -> void:
	var s: Dictionary = spr[key]
	var sc := _sprite_scale(key)
	var size: int = s.n * sc
	var top := roundi(feet_y - size + s.foot * sc - opts.get("bob", 0))
	var left := roundi(cx - size / 2.0)
	var tex: Texture2D = s.flash if opts.get("flash", false) else (s.blink if opts.get("blink", false) else s.tex)
	var mod: Color = opts.get("mod", Color.WHITE)
	if flip:
		draw_set_transform(off + Vector2(left + size, top), 0, Vector2(-sc, sc))
	else:
		draw_set_transform(off + Vector2(left, top), 0, Vector2(sc, sc))
	draw_texture(tex, Vector2.ZERO, mod)
	draw_set_transform(off)


func _text(pos: Vector2, s: String, size := 10, color: Color = GameData.COL.ink, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0, outline := true) -> void:
	if outline:
		draw_string_outline(font, pos, s, align, width, size, 4, GameData.COL.dark)
	draw_string(font, pos, s, align, width, size, color)


func _box(r: Rect2, fill: Color, border: Color) -> void:
	draw_rect(r, border)
	draw_rect(r.grow(-1), fill)


func _bar(r: Rect2, k: float, color: Color, back: Color = GameData.COL.dark) -> void:
	draw_rect(r, back)
	var w := floorf((r.size.x - 2) * clampf(k, 0.0, 1.0))
	if w > 0:
		draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(w, r.size.y - 2)), color)


func gx(x: float) -> float:
	var c := clampi(floori(x), 0, 5)
	return X0 + c * CW + (GAP if c >= 3 else 0) + (x - c) * CW


func cell_rect(c: int, r: int) -> Rect2:
	return Rect2(gx(c) + 2, Y0 + r * CH + 2, CW - 4, CH - 4)


func feet_y(r: float) -> float:
	return Y0 + r * CH + FEET


func _glyph_chip(i: int) -> String:
	return ["X", "Y", "B"][i] if pad else ["J", "K", "L"][i]


func _glyph_special() -> String:
	return "A" if pad else "Leer"


func _glyph_confirm() -> String:
	return "A" if pad else "Enter"


# ---------- Zeichnen ----------

func _draw() -> void:
	off = Vector2.ZERO
	draw_set_transform(off)
	_draw_background()
	if st == null:
		return
	if st.shake > 0:
		var s := st.shake * 0.5
		off = Vector2(roundi(randf_range(-s, s)), roundi(randf_range(-s, s)))
		draw_set_transform(off)
	_draw_arena()
	_draw_actors()
	_draw_effects()
	off = Vector2.ZERO
	draw_set_transform(off)
	_draw_hud()
	_draw_hand()
	if st.hurt > 0:
		var a := st.hurt / 0.3 * 0.35
		var c := Color(1, 0.24, 0.35, a)
		for i in 6:
			var g := Color(c, a * (1.0 - i / 6.0))
			draw_rect(Rect2(i * 3, 0, 3, H), g)
			draw_rect(Rect2(W - (i + 1) * 3, 0, 3, H), g)
			draw_rect(Rect2(0, i * 3, W, 3), g)
			draw_rect(Rect2(0, H - (i + 1) * 3, W, 3), g)
	match mode:
		Mode.PAUSE:
			_draw_pause()
		Mode.PICK:
			_draw_pick()
		Mode.RESULT:
			_draw_result()


func _draw_background() -> void:
	var boss: bool = st != null and st.def.boss
	draw_rect(Rect2(0, 0, W, H), GameData.COL.bg2 if boss else GameData.COL.bg)
	# Datenraster
	var grid := Color(GameData.COL.line, 0.22)
	for x in range(0, W, 32):
		draw_rect(Rect2(x, 0, 1, H), grid)
	for y in range(0, H, 32):
		draw_rect(Rect2(0, y, W, 1), grid)
	# aufsteigende Datenpartikel
	var dust := Color("#FF5470", 0.45) if boss else Color(1, 1, 1, 0.35)
	for i in 18:
		var x := fmod(i * 97.3 + 13.0, W)
		var y := H - fmod(anim_t * 14.0 + i * 53.0, H)
		draw_rect(Rect2(roundi(x), roundi(y), 2, 2), dust)


func _draw_arena() -> void:
	for c in 6:
		for r in 3:
			var rect := cell_rect(c, r)
			var top: Color = GameData.COL.tileP if c < 3 else GameData.COL.tileE
			draw_rect(rect.grow(1), GameData.COL.dark)
			draw_rect(rect, top.darkened(0.35))
			draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y - 4)), top)
			draw_rect(Rect2(rect.position + Vector2(1, 1), Vector2(rect.size.x - 2, 1)), top.lightened(0.25))
	# Mittellinie
	var mx := X0 + 3 * CW + GAP / 2 - 1
	for y in range(Y0, Y0 + 3 * CH, 6):
		var a := 0.25 + 0.5 * maxf(0.0, sin(y * 0.12 - anim_t * 6.0))
		draw_rect(Rect2(mx, y, 2, 3), Color(GameData.COL.sun, a))
	for m in st.marks:
		for r in 3:
			draw_rect(cell_rect(3 + m.col, r), Color(m.color, 0.35 + 0.3 * sin(anim_t * 30.0)))
	for w in st.warns:
		var k: float = 1.0 - w.t / w.max
		var a := 0.25 + 0.5 * k * (0.6 + 0.4 * sin(anim_t * 28.0))
		for cell in w.cells:
			var rect := cell_rect(cell.x, cell.y)
			draw_rect(rect, Color(GameData.COL.coral, a))
			_text(rect.position + Vector2(0, 24), "!", 16, Color(1, 1, 1, minf(1.0, 0.4 + k)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)
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
	var mkey: String = st.mon.spr
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
	_shadow(gx(p.c) + CW / 2.0, feet_y(p.r), 30)
	_draw_sprite(mkey, pcx, pfy, false, {"flash": p.flash > 0, "blink": blink_p, "bob": bob_p})
	var body := Vector2(gx(p.c) + CW / 2.0, feet_y(p.r) - 24)
	if st.shield > 0:
		for i in 12:
			var a0 := i * TAU / 12.0 + anim_t * 2.0
			draw_arc(body, 30, a0, a0 + TAU / 24.0, 3, GameData.EL.Code, 2)
	if st.bubble > 0 and st.bubble_t > 0:
		draw_circle(body, 30, Color(GameData.EL.Wasser, 0.2))
		draw_arc(body, 30, 0, TAU, 32, Color(GameData.EL.Wasser, 0.8), 1)
		draw_rect(Rect2(body + Vector2(-14, -18), Vector2(4, 4)), Color.WHITE)
	for i in st.bots.size():
		var bp := body + Vector2(-26 + i * 8, -26 + sin(anim_t * 8.0 + i) * 2)
		draw_rect(Rect2(bp, Vector2(8, 6)), GameData.COL.dark)
		draw_rect(Rect2(bp + Vector2(1, 1), Vector2(6, 4)), GameData.EL.Code)

	# Gegner
	if e.hp > 0 or st.outcome != "won":
		var ecx := gx(3 + e.c) + CW / 2.0
		var efy := feet_y(e.r)
		_shadow(ecx, efy, 44 if st.def.boss else 34)
		var tint := Color.WHITE
		if st.boss_phase() == 3 and sin(anim_t * 14.0) > 0.4:
			tint = Color("#FF9DB3")
		_draw_sprite(st.def.spr, ecx, efy, true, {"flash": e.flash > 0, "blink": blink_e, "bob": bob_e, "mod": tint})
		if e.frozen > 0:
			var rect := cell_rect(3 + e.c, e.r)
			draw_rect(Rect2(rect.position.x + 4, rect.position.y - 40, rect.size.x - 8, rect.size.y + 34), Color(GameData.EL.Wasser, 0.3))
		if st.delayed.any(func(d): return d.mark):
			var cc := Vector2(ecx, efy - 26)
			var rad := 22.0 + 3.0 * sin(anim_t * 20.0)
			draw_arc(cc, rad, 0, TAU, 24, GameData.EL.Licht, 1)
			draw_rect(Rect2(cc.x - 32, cc.y, 64, 1), GameData.EL.Licht)
			draw_rect(Rect2(cc.x, cc.y - 32, 1, 64), GameData.EL.Licht)


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
		var rect := cell_rect(q.c, q.r)
		var bob := roundi(sin(anim_t * 6.0 + q.c) * 2)
		var r := Rect2(rect.position.x + 8, rect.position.y - 14 + bob, rect.size.x - 16, 30)
		draw_rect(r.grow(1), GameData.COL.dark)
		draw_rect(r, Color.WHITE)
		draw_rect(Rect2(r.position, Vector2(r.size.x, 7)), Color("#9B4DFF"))
		draw_rect(Rect2(r.end.x - 7, r.position.y, 7, 7), Color("#FF5470"))
		_text(Vector2(r.position.x, r.position.y + 20), "GRATIS!", 8, GameData.COL.dark, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, false)
		draw_rect(Rect2(r.position.x + 2, r.end.y - 4, (r.size.x - 4) * q.t / q.max, 2), Color("#FF5470"))
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
		var size := 12 if k > 0.8 else 10
		var pos := Vector2(gx(f.x) - 60, Y0 + f.y * CH - 30)
		_text(pos, f.text, size, Color(f.color, minf(1.0, k * 1.6)), HORIZONTAL_ALIGNMENT_CENTER, 120)
	if not st.banner.is_empty():
		var b: Dictionary = st.banner
		var k: float = b.t / b.max
		var a := minf(1.0, k * 2.5)
		draw_rect(Rect2(-off, Vector2(W, H)), Color(b.color, a * 0.15))
		_text(Vector2(0, 120 - (1.0 - k) * 6), b.text, 24, Color(b.color, a), HORIZONTAL_ALIGNMENT_CENTER, W)


func _draw_hud() -> void:
	# Spieler links
	var P := Rect2(8, 8, 200, 34)
	_box(P, Color(GameData.COL.panel, 0.9), GameData.COL.line)
	_text(P.position + Vector2(6, 13), st.mon.get("name", run.species), 10)
	_text(P.position + Vector2(6, 13), "%s · %s" % [st.mon.stage, st.mon.el], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, P.size.x - 12)
	_bar(Rect2(P.position + Vector2(6, 19), Vector2(140, 8)), float(run.hp) / run.max_hp, GameData.COL.mint)
	_text(P.position + Vector2(150, 28), "%d/%d" % [run.hp, run.max_hp], 8, GameData.COL.ink)
	if st.reflex > 0:
		_text(Vector2(8, 54), "Katzenreflex bereit", 8, GameData.COL.mint)
	# Gegner rechts
	var E := Rect2(W - 208, 8, 200, 34)
	_box(E, Color(GameData.COL.panel, 0.9), GameData.EL[st.def.el].darkened(0.3))
	_text(E.position + Vector2(6, 13), st.def.name, 10)
	_text(E.position + Vector2(6, 13), st.def.el, 8, GameData.EL[st.def.el], HORIZONTAL_ALIGNMENT_RIGHT, E.size.x - 12)
	_bar(Rect2(E.position + Vector2(6, 19), Vector2(140, 8)), float(st.e.hp) / st.e.max, GameData.COL.coral)
	_text(E.position + Vector2(150, 28), "%d/%d" % [st.e.hp, st.e.max], 8, GameData.COL.ink)
	var tags: Array = []
	if st.e.burn > 0:
		tags.append(["Brand", GameData.EL.Feuer])
	if st.e.poison > 0:
		tags.append(["Gift", GameData.EL.Virus])
	if st.e.frozen > 0:
		tags.append(["Eis", GameData.EL.Wasser])
	var tx := W - 8.0
	for tg in tags:
		var w := font.get_string_size(tg[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 8
		tx -= w
		_box(Rect2(tx, 45, w, 12), GameData.COL.dark, tg[1])
		_text(Vector2(tx, 54), tg[0], 8, tg[1], HORIZONTAL_ALIGNMENT_CENTER, w, false)
		tx -= 3
	# Raum + Hinweis
	_text(Vector2(0, 20), "Kampf %d/%d" % [run.room + 1, GameData.FOES.size()], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	if st.status != "" and st.t < 6.0:
		_text(Vector2(0, 72), st.status, 8, Color(GameData.COL.sun, clampf(6.0 - st.t, 0.0, 1.0)), HORIZONTAL_ALIGNMENT_CENTER, W)


func _draw_hand() -> void:
	var nx := st.next_chip()
	_text(Vector2(HAND_X, 298), "Als Nächstes: " + (nx if nx != "" else "–"), 8, GameData.COL.muted)
	_text(Vector2(HAND_X, 298), ("Start" if pad else "Esc") + ": Deck", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, 3 * CARD_W + 2 * 6 + 6 + 100)
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
		var g := Rect2(r.position + Vector2(8, 6), Vector2(16, 14))
		_box(g, GameData.COL.dark, el if ready else GameData.COL.line)
		_text(g.position + Vector2(0, 11), _glyph_chip(i), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, g.size.x, false)
		_text(r.position + Vector2(30, 17), s.chip, 10, GameData.COL.ink if ready else GameData.COL.muted)
		var info: String = ch.cat + (" · %d" % ch.dmg if ch.dmg > 0 else "")
		_text(r.position + Vector2(8, 33), info, 8, GameData.COL.muted)
		if ready:
			_text(r.position + Vector2(8, 33), "BEREIT", 8, el, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 14)
		else:
			_bar(Rect2(r.position + Vector2(6, r.size.y - 8), Vector2(r.size.x - 12, 5)), 1.0 - s.rem / s.max, el.darkened(0.2))
			if s.queued:
				_text(r.position + Vector2(8, 33), "vorgemerkt", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 14)
	# Signatur-Attacke
	var R := Rect2(HAND_X + 3 * (CARD_W + 6), HAND_Y, 100, CARD_H)
	var full := st.sp >= 100
	var sel: Color = GameData.EL[st.mon.special_el]
	var pulse := full and sin(anim_t * 8.0) > 0
	_box(R, GameData.COL.panel if full else GameData.COL.bg2, GameData.COL.sun if pulse else GameData.COL.line)
	var g2 := Rect2(R.position + Vector2(6, 6), Vector2(28, 14))
	_box(g2, GameData.COL.dark, GameData.COL.sun if full else GameData.COL.line)
	_text(g2.position + Vector2(0, 11), _glyph_special(), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, g2.size.x, false)
	_text(R.position + Vector2(38, 17), "Signatur", 8, GameData.COL.sun if full else GameData.COL.muted)
	_text(R.position + Vector2(6, 33), st.mon.special, 8, GameData.COL.ink if full else GameData.COL.muted)
	_bar(Rect2(R.position + Vector2(6, R.size.y - 8), Vector2(R.size.x - 12, 5)), st.sp / 100.0, GameData.COL.sun if full else sel.darkened(0.2))


func _panel(r: Rect2) -> void:
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.72))
	_box(r, GameData.COL.panel, GameData.COL.line)


func _draw_pause() -> void:
	var r := Rect2(140, 50, 360, 250)
	_panel(r)
	_text(r.position + Vector2(0, 24), "Pause – Dein Deck", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var counts := {}
	for k in run.deck:
		counts[k] = counts.get(k, 0) + 1
	var y := r.position.y + 48
	for k in counts:
		var el: Color = GameData.EL[GameData.CHIPS[k].el]
		draw_rect(Rect2(r.position.x + 24, y - 8, 8, 8), el)
		_text(Vector2(r.position.x + 40, y), "%d× %s" % [counts[k], k], 10)
		_text(Vector2(r.position.x + 40, y), GameData.CHIPS[k].cat, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 64)
		y += 16
	_text(Vector2(r.position.x, r.end.y - 30), "Ziehstapel %d · Abwurf %d" % [st.draw_pile.size(), st.disc.size()], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(Vector2(r.position.x, r.end.y - 14), "%s: weiter" % ("Start" if pad else "Esc"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


func _draw_pick() -> void:
	var r := Rect2(40, 30, 560, 300)
	_panel(r)
	_text(r.position + Vector2(0, 28), "Sieg!", 20, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var line := "%s ist defragmentiert. +%d Fragmente" % [st.def.name, st.def.loot]
	if heal_info > 0:
		line += ", +%d HP" % heal_info
	_text(r.position + Vector2(0, 46), line + ".", 10, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(r.position + Vector2(0, 60), "Wähle einen Chip, der bis zum Ende des Runs in dein Deck kommt.", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	for i in 3:
		var k: String = choices[i]
		var ch: Dictionary = GameData.CHIPS[k]
		var el: Color = GameData.EL[ch.el]
		var sel := i == pick_idx
		var c := Rect2(r.position.x + 24 + i * 176, r.position.y + 76 - (4 if sel else 0), 160, 112)
		_box(c, GameData.COL.panel.lightened(0.08) if sel else GameData.COL.bg2, GameData.COL.sun if sel else el.darkened(0.3))
		draw_rect(Rect2(c.position + Vector2(1, 1), Vector2(c.size.x - 2, 4)), el)
		_text(c.position + Vector2(0, 24), k, 12, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		_text(c.position + Vector2(0, 38), "%s · %s" % [ch.el, ch.rar], 8, el, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		var stats: String = ch.cat + (" · %d Schaden" % ch.dmg if ch.dmg > 0 else "") + " · %.1f s" % ch.cd
		_text(c.position + Vector2(0, 52), stats, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		draw_multiline_string(font, c.position + Vector2(10, 72), ch.desc, HORIZONTAL_ALIGNMENT_CENTER, c.size.x - 20, 8, 6, GameData.COL.ink)
	var nf: Dictionary = GameData.FOES[run.room + 1]
	_text(Vector2(r.position.x, r.end.y - 34), "Nächster Gegner: %s (%s) · Deck: %d Chips" % [nf.name, nf.el, run.deck.size()], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(Vector2(r.position.x, r.end.y - 16), "◀ ▶ wählen · %s: nehmen" % _glyph_confirm(), 10, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


func _draw_result() -> void:
	var r := Rect2(120, 40, 400, 280)
	_panel(r)
	_text(r.position + Vector2(0, 30), "Run geschafft!" if won_run else "Run verloren", 20, GameData.COL.sun if won_run else GameData.COL.coral, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var fights := run.room + (1 if won_run else 0)
	_text(r.position + Vector2(0, 50), "Kämpfe gewonnen: %d/%d · Chips gespielt: %d · Fragmente: %d" % [fights, GameData.FOES.size(), run.chips_used, run.frag], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(r.position + Vector2(24, 76), "Prägung in diesem Run", 10)
	var total := 0
	for k in run.praeg:
		total += run.praeg[k]
	var y := r.position.y + 94
	for el in GameData.EL:
		var n: int = run.praeg.get(el, 0)
		_text(Vector2(r.position.x + 24, y + 8), el, 8, GameData.EL[el])
		_bar(Rect2(r.position.x + 90, y, 240, 8), float(n) / maxi(1, total), GameData.EL[el])
		_text(Vector2(r.position.x + 336, y + 8), str(n), 8)
		y += 16
	_text(Vector2(r.position.x, r.end.y - 16), "%s: neuer Run" % _glyph_confirm(), 10, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


# ---------- Screenshot-Modus ----------

func _parse_args() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			shot.path = a.substr(7)
		elif a.begins_with("--mode="):
			shot.mode = a.substr(7)
		elif a.begins_with("--room="):
			shot.room = int(a.substr(7))
		elif a.begins_with("--sim="):
			shot.sim = float(a.substr(6))
		elif a == "--pad":
			shot.pad = true
	if not shot.has("path"):
		shot = {}


func _take_screenshot() -> void:
	set_process(false)
	pad = shot.get("pad", false)
	seed(7)
	run = RunState.new("Pixmiez", 7)
	run.room = shot.get("room", 0)
	_start_fight()
	var bot := BattleBot.new(0.15)
	var dt := 1.0 / 60.0
	var sim: float = shot.get("sim", 2.0)
	var steps := 0
	while steps * dt < sim and not st.over:
		bot.act(st)
		st.update(dt)
		anim_t += dt
		steps += 1
	match shot.get("mode", "fight"):
		"pick":
			st.over = true
			st.outcome = "won"
			_fight_over()
		"pause":
			mode = Mode.PAUSE
		"result":
			run.room = 2
			won_run = false
			mode = Mode.RESULT
	queue_redraw()
	for i in 3:
		await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(shot.path)
	print("Screenshot gespeichert: ", shot.path)
	get_tree().quit()
