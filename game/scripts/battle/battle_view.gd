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
const SKIP_FRAG := 10     # Chipwahl überspringen: Fragmente statt Chip
const GUARD_HEAL := 0.3   # Wächter besiegt: +30 % der max. HP
const GLITCH_WEIGHT := {"Gewöhnlich": 0, "Selten": 1, "Episch": 3}   # Chipwahl nach einer Glitch-Elite
const BABY_SCALE := 1     # Babys (32 px) im Kampf in Originalgröße, damit die Evolution sichtbar wächst

enum Mode { FIGHT, PAUSE, EVOLVE, PICK, INTRO, READY }
## Boss-Intro: Zeitpunkte in Sekunden
const INTRO_REVEAL := 1.7    # Silhouette wird farbig, Musik setzt ein
const INTRO_END := 4.2       # danach beginnt der Kampf
const INTRO_FADE := 0.5

const EVO_REVEAL := 1.8   # Sekunden bis zur Enthüllung der neuen Form

const PAUSE_ITEMS := ["Weiter", "Handbuch", "Aufgeben"]

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
## Kampf-Animationen (07.10.2026): Materialisieren/Defragmentieren, Signatur-Einblendung, Siegerpose, Treffer-Reaktion
const MAT_TIME := 0.7      # Gegner setzt sich zu Kampfbeginn aus Pixeln zusammen
const END_WIN := 1.5       # Sieg: Gegner zerfällt, Glitchling jubelt (vorher 0,65 s)
const END_LOSE := 0.65
const CUTIN := 0.85        # Signatur-Einblendung, der Kampf steht so lange still
var mat_t := 0.0
var e_pix: Array = []      # Pixel des Gegners [x, y, Farbe, Zufall] relativ zur linken oberen Ecke (2er-Raster)
var e_pix_size := 2
var dis_origin := Vector2.ZERO   # Position des Gegners beim Sieg (Zerfall startet dort)
var dis_set := false
var cutin_t := 0.0
var p_hurt := 0.0          # Treffer-Reaktion: Zittern und roter Nachglimm-Ton
var p_hop := 0.0        # kleiner Hüpfer beim Bewegen
var e_knock := 0.0
var e_strike := 0.0     # Gegner schnellt beim Zuschlagen vor
var muzzle := 0.0
var muzzle_col := Color.WHITE
var dust: Array = []    # Staubwolken {x, y, t}
var last_cell := Vector2i(1, 1)
# Karten-Animation: neue Karte kommt vom Stapel, die gespielte schwebt als Name davon
var prev_chips := ["", "", ""]
var card_t := [0.0, 0.0, 0.0]
var ghosts: Array = []          # {text, x, y, t}
# Neuer Chip (einmal pro Chip und Spielstand): kleines blinkendes „Neu!“ auf der Karte, ohne Zeitlupe
# (03.10.2026: Zeitlupe und Erklärkasten waren dem Produzenten zu viel)
var new_t := [0.0, 0.0, 0.0]
const NEW_TIME := 3.0
var skip_ready := false         # Tests/Screenshots: ohne Bereit-Pause starten
var autopilot: BattleBot = null  # Trailer: der Bot spielt live (sonst nur in simulate())
var mystery_foe := false         # Trailer: Gegner nur als Umriss (Ur-Glitch), Werte im Intro verborgen
var mod_reveal := false          # „Neues Modul!“ wird vor der Chipwahl groß gezeigt (09.10.2026, Spieltest)
const LUNGE := 0.16
## Angriffsanimationen (05.10.2026): Dauer beim eigenen Glitchling; beim Gegner laufen die Ausholbilder
## synchron zur Warnung bis ATK_HIT, der Rest nach dem Einschlag in E_ATK_POST Sekunden
const ATK_TIME := 0.36
const ATK_HIT := 0.55
const E_ATK_POST := 0.24
var p_atk := 0.0          # Restzeit der Angriffsanimation des Spielers
var e_atk_post := 0.0     # Restzeit der Nachbewegung des Gegners nach dem Einschlag
const KNOCK := 0.14


func setup(run_state: RunState, foe: Dictionary, type := "fight") -> void:
	run = run_state
	node_type = type
	st = BattleState.new(run, foe)
	run.last_foe = foe.name
	ArenaTiles.preload_bg(GameData.ZONES[run.map.zone].bg)
	if foe.get("elite", false):
		PixelCanvas.preload_silhouettes(foe.spr)
	if run.tutorial and run.fights_won == 0 and type == "fight":
		tut = Tutorial.new()
		st.status = ""
		skip_ready = true   # das Training erklärt die Karten selbst
	if type in ["boss", "guard"]:
		# Boss-/Wächter-Intro: erst Stille und Warnung, die Bossmusik setzt mit der Enthüllung ein
		Music.stop()
		_set_mode(Mode.INTRO)
	else:
		Music.play(Music.zone_key("battle", run.map.zone))
		_set_mode(Mode.READY if _needs_ready() else Mode.FIGHT)
	for i in 3:
		prev_chips[i] = st.hand[i].chip
	_build_enemy_pixels()
	# Bosse und Wächter haben ihr eigenes Intro, alle anderen materialisieren sich
	if not type in ["boss", "guard"]:
		mat_t = MAT_TIME


## Pixel des Gegner-Sprites einmal auslesen (gespiegelt wie im Kampf), für Materialisieren und Zerfall
func _build_enemy_pixels() -> void:
	e_pix.clear()
	var s := sprite(st.def.spr)
	var img: Image = s.tex.get_image()
	if img.is_compressed():
		img.decompress()
	var sc: int = 2 if s.n <= 32 else 1
	var stepw := 2
	e_pix_size = stepw * sc
	var rng := RandomNumberGenerator.new()
	rng.seed = st.def.spr.hash()
	for y in range(0, s.n, stepw):
		for x in range(0, s.n, stepw):
			var c := img.get_pixel(x, y)
			if c.a < 0.5:
				c = img.get_pixel(mini(x + 1, s.n - 1), mini(y + 1, s.n - 1))
				if c.a < 0.5:
					continue
			e_pix.append([float((s.n - stepw - x) * sc), float(y * sc), c, rng.randf()])


# ---------- Ablauf ----------

func _animate_event(ev: String) -> void:
	match ev:
		"shoot", "slash", "chip":
			p_lunge = LUNGE
			# Angriffsanimation nur bei Angriffs-Chips (nicht bei Schild, Heilung, Hilfen)
			if st.last_chip != "" and GameData.role(st.last_chip) == 0:
				p_atk = ATK_TIME
			if ev != "chip":
				muzzle = 0.09
				muzzle_col = GameData.EL[GameData.chip(st.last_chip).el] if st.last_chip != "" else Color.WHITE
		"hit", "hit_big":
			e_knock = KNOCK * (1.5 if ev == "hit_big" else 1.0)
		"hurt":
			p_knock = KNOCK
			p_hurt = 0.3
		"signature":
			# Signatur-Einblendung: der Kampf steht kurz still (Ton spielt _process wie bisher über „special“;
			# 09.10.2026: vorher reagierte sie auf „special“ und erschien fälschlich auch bei Feuersbrunst, Tsunami und Blackout)
			cutin_t = CUTIN
		"strike":
			e_strike = 0.12
			e_atk_post = E_ATK_POST
		"move":
			p_hop = 0.09
			var fy := feet_y(last_cell.y)
			var fx := gx(last_cell.x) + CW / 2.0
			for i in 4:
				dust.append({"x": fx + randf_range(-10, 10), "y": fy - randf_range(0, 3), "vx": randf_range(-14, 14), "t": 0.35})
	last_cell = Vector2i(st.p.c, st.p.r)


func _tick_anims(dt: float) -> void:
	p_lunge = maxf(0.0, p_lunge - dt)
	p_atk = maxf(0.0, p_atk - dt)
	e_atk_post = maxf(0.0, e_atk_post - dt)
	p_knock = maxf(0.0, p_knock - dt)
	p_hurt = maxf(0.0, p_hurt - dt)
	mat_t = maxf(0.0, mat_t - dt)
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
	# Training: keine Entwicklung, keine Chipwahl, keine Belohnung
	if run.training:
		finished.emit(true)
		set_process(false)
		return
	# Reise (08.10.2026): Nach einem Zonen-Boss geht es weiter, also Evolution und Belohnung wie nach einem Wächter.
	# Nur der letzte Boss der Reise führt direkt zum Ende.
	if st.outcome == "lost" or (node_type == "boss" and run.final_act()):
		finished.emit(st.outcome == "won")
		set_process(false)
		return
	if mode != Mode.EVOLVE:
		evo = run.try_evolve()
		if not evo.is_empty():
			_set_mode(Mode.EVOLVE)
			Sfx.play("charge", 0.0)
			return
	# Wächter: zusätzlich 30 % der max. HP als Verschnaufpause vor der nächsten Ebene
	var heal_amt := HEAL_AFTER_FIGHT + (8 if run.has_mod("lebensbit") else 0)
	if node_type == "guard":
		heal_amt += roundi(run.max_hp * GUARD_HEAL)
	heal_info = run.heal(heal_amt)
	var weights: Dictionary = GameData.RARITY_WEIGHT
	if node_type in ["elite", "guard"]:
		weights = RunState.ELITE_WEIGHT
	elif node_type in ["glitch", "boss"]:
		weights = GLITCH_WEIGHT
	choices = run.roll_pick(weights)
	# Elite-, Glitch-Elite-, Wächter- und Boss-Belohnung: ein neues Modul
	new_module = ""
	if node_type in ["elite", "glitch", "guard", "boss"]:
		new_module = run.roll_module(GameData.MODULE_WEIGHT_ELITE)
		run.add_module(new_module)
		mod_reveal = new_module != ""
		if mod_reveal:
			Sfx.play("evolve", 0.0)
	pick_idx = 1
	_set_mode(Mode.PICK)


func _take_pick(skip := false) -> void:
	if not skip:
		run.deck.append(choices[pick_idx])
	else:
		# Überspringen lohnt sich (08.10.2026): schlanke Decks sind eine echte Strategie
		run.frag += SKIP_FRAG
	set_process(false)
	finished.emit(true)


# ---------- Eingabe ----------

func _set_mode(m: Mode) -> void:
	mode = m
	mode_t = 0.0


func _process(delta: float) -> void:
	anim_t += delta
	if handbook != null:
		queue_redraw()
		return
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
	if mode == Mode.READY:
		# Hand lesen, dann mit Bestätigen (oder einer Chip-Taste) loslegen
		var go := Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("special")
		for i in 3:
			go = go or Input.is_action_just_pressed("chip_%d" % (i + 1))
		if mode_t > 0.3 and go:
			Sfx.play("confirm")
			_mark_seen_hand()
			_set_mode(Mode.FIGHT)
		elif Input.is_action_just_pressed("pause"):
			_set_mode(Mode.PAUSE)
			pause_idx = 0
		queue_redraw()
		return
	match mode:
		Mode.FIGHT:
			_process_fight(delta)
		Mode.PAUSE:
			if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("back"):
				Sfx.play("back")
				_set_mode(Mode.FIGHT)
			elif Input.is_action_just_pressed("move_up"):
				pause_idx = (pause_idx + PAUSE_ITEMS.size() - 1) % PAUSE_ITEMS.size()
				Sfx.play("select")
			elif Input.is_action_just_pressed("move_down"):
				pause_idx = (pause_idx + 1) % PAUSE_ITEMS.size()
				Sfx.play("select")
			elif Input.is_action_just_pressed("handbook"):
				open_handbook()
			elif Input.is_action_just_pressed("confirm"):
				Sfx.play("confirm")
				if pause_idx == 0:
					_set_mode(Mode.FIGHT)
				elif pause_idx == 1:
					open_handbook()
				else:
					set_process(false)
					gave_up.emit()
		Mode.PICK:
			# Erst das neue Modul groß zeigen, dann die Chipwahl
			if mod_reveal:
				if mode_t > 0.6 and (Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("back")):
					Sfx.play("confirm")
					mod_reveal = false
					mode_t = 0.0
				queue_redraw()
				return
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
		if Input.is_action_just_pressed("handbook"):
			# Handbuch mitten im Kampf: Kampf pausiert
			_set_mode(Mode.PAUSE)
			pause_idx = 1
			open_handbook()
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
		if cutin_t > 0:
			st.pend_move = null
		elif autopilot != null:
			autopilot.act(st)
	_tick_anims(delta)
	_track_cards(delta)
	if cutin_t > 0:
		cutin_t = maxf(0.0, cutin_t - delta)
		if cutin_t <= 0:
			p_atk = ATK_TIME   # die Attacke selbst beginnt nach der Einblendung
		queue_redraw()
		return
	st.advance(delta)
	if tut != null and tut.active():
		tut.update(st, delta)
		if tut.just_finished:
			Sfx.play("confirm")
			run.tutorial = false
			SaveGame.data["tutorial_done"] = true
			SaveGame.save_game()
	for ev in st.events:
		_animate_event(ev)
		if ev == "win" or ev == "signature":
			continue  # Sieg: Siegesfanfare bzw. Ergebnis-Musik · Signatur: nur Einblendung, der Ton kommt über „special“
		Sfx.play(ev)
	st.events.clear()
	if st.over:
		if end_timer < 0:
			end_timer = END_WIN if st.outcome == "won" else END_LOSE
			# Training geschafft: kurzes Abschluss-Banner, bevor es zur Station geht
			if run.training and st.outcome == "won":
				end_timer += 1.0
				st.banner = {"text": T.t("Training geschafft!"), "color": GameData.COL.sun, "t": 2.4, "max": 2.4}
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


## Text auf eine Breite kürzen (mit Punkt), z. B. Chipnamen neben langen Tastennamen wie „Umschalt“
func _fit(s: String, w: float) -> String:
	if text_width(s, 8, true) <= w:
		return s
	while s.length() > 1 and text_width(s + ".", 8, true) > w:
		s = s.left(-1)
	return s + "."


func _glyph_chip(i: int) -> String:
	return InputSetup.btn(["X", "A", "B"][i]) if InputSetup.pad else InputSetup.key_label(["chip_1", "chip_2", "chip_3"][i])


# ---------- Zeichnen ----------

func _draw() -> void:
	off = Vector2.ZERO
	draw_set_transform(off)
	if st == null:
		_draw_background()
		return
	var zbg: String = GameData.ZONES[run.map.zone].bg
	_draw_zone(zbg + "_boss" if st.def.boss and not st.def.get("guard", false) else zbg)
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
	if cutin_t > 0:
		_draw_cutin()
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
			if mod_reveal:
				_draw_module_reveal()
		Mode.INTRO:
			# Übergang: das Intro blendet in den Kampf über
			var k := clampf((INTRO_END - mode_t) / INTRO_FADE, 0.0, 1.0)
			draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, k))


func _draw_arena() -> void:
	# Kampffeld (08.10.2026): einzelne Platten im Material der Zone, ohne Sockel, damit die Kulisse sichtbar bleibt
	var bg: String = GameData.ZONES[run.map.zone].bg
	for c in 6:
		for r in 3:
			var sr := cell_rect(c, r)
			draw_rect(Rect2(sr.position + Vector2(3, 5), sr.size), Color(0.02, 0.01, 0.06, 0.42))
	for c in 6:
		for r in 3:
			_draw_panel(c, r, bg)
	# Mittellinie: leuchtender Datenstrom
	var mx := X0 + 3 * CW + GAP / 2 - 1
	draw_rect(Rect2(mx - 2, Y0 - 2, 6, 3 * CH), Color(GameData.COL.sun, 0.08))
	for y in range(Y0, Y0 + 3 * CH - 2, 4):
		var a := 0.2 + 0.6 * maxf(0.0, sin(y * 0.1 - anim_t * 5.0))
		draw_rect(Rect2(mx, y, 2, 2), Color(GameData.COL.sun, a))


## Eine Platte: Material der Zone (ArenaTiles), hintere Reihen etwas dunkler, Leuchtebene pulsiert je Platte versetzt
func _draw_panel(c: int, r: int, bg: String) -> void:
	var rect := cell_rect(c, r)
	var T: Array = ArenaTiles.tile(bg, 0 if c < 3 else 1, (c * 7 + r * 5) % ArenaTiles.VARIANTS)
	var shade := 1.0 - 0.07 * (2 - r)
	draw_texture(T[0], rect.position, Color(shade, shade, shade))
	draw_texture(T[1], rect.position, Color(1, 1, 1, 0.5 + 0.45 * sin(anim_t * 2.2 + c * 1.7 + r * 2.3)))


func _draw_arena_overlays() -> void:
	for m in st.marks:
		for r in 3:
			draw_rect(cell_rect(3 + m.col, r), Color(m.color, 0.35 + 0.3 * sin(anim_t * 30.0)))
	for w in st.warns:
		var k: float = 1.0 - w.t / w.max
		var a := 0.5 + 0.4 * k * (0.6 + 0.4 * sin(anim_t * 28.0))
		var big: bool = w.get("big", false)
		for cell in w.cells:
			var rect := cell_rect(cell.x, cell.y)
			if big:
				# Großangriff: goldenes Feld mit pulsierendem Rahmen, kurz vor dem Einschlag weiß
				var gold := Color("#FFB23D").lerp(Color.WHITE, clampf((k - 0.75) * 3.0, 0.0, 0.7))
				draw_rect(rect, Color(gold, 0.35 + 0.35 * k))
				var bw := 2 if sin(anim_t * (14.0 + 20.0 * k)) > 0 else 3
				draw_rect(rect, gold, false, bw)
				_text(rect.position + Vector2(0, 26), "!!", 16, Color(1, 1, 1, minf(1.0, 0.5 + k)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, true, true)
				continue
			if w.get("lava", false):
				_draw_ground_warn(rect, k, w.get("kind", "lava"), cell, int(w.get("dir", 1)))
				continue
			draw_rect(rect, Color(GameData.COL.coral, a))
			_text(rect.position + Vector2(0, 26), "!", 16, Color(1, 1, 1, minf(1.0, 0.4 + k)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, true, true)
	for hz in st.hazards:
		var rect := cell_rect(hz.c, hz.r)
		match hz.get("kind", "lava"):
			"slime":
				_draw_slime_pool(rect, hz)
			"current":
				_draw_current_pool(rect, hz)
			"spark":
				_draw_spark_pool(rect, hz)
			"thorn":
				_draw_thorn_patch(rect, hz)
			_:
				_draw_lava_pool(rect, hz)
	for q in st.parts:
		if q.has("cell"):
			draw_rect(cell_rect(q.c, q.r), Color(q.color, q.t / q.max * 0.8))
	# Training: Ziel-Feld (Dornen-Parcours)
	if tut != null and tut.active() and tut.goal.x >= 0:
		var gr := cell_rect(tut.goal.x, tut.goal.y)
		var pulse := 0.5 + 0.5 * sin(anim_t * 6.0)
		draw_rect(gr, Color(GameData.COL.mint, 0.18 + 0.15 * pulse))
		draw_rect(gr, Color(GameData.COL.mint, 0.7 + 0.3 * pulse), false, 2)
		_text(gr.position + Vector2(0, 14), "Ziel", 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, gr.size.x, true, true)
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
	# Vorschnellen bleibt auch mit Angriffsanimation (die Bilder allein sind eher dezent)
	if p_lunge > 0:
		pcx += sin((1.0 - p_lunge / LUNGE) * PI) * 7.0
	if p_knock > 0:
		pcx -= sin((1.0 - p_knock / KNOCK) * PI) * 5.0
	if p_hop > 0:
		pfy -= 2.0
	# Treffer: kurzes Zittern (pixelgetreu, kein Stauchen)
	if p_hurt > 0.12:
		pcx += 2.0 if fmod(p_hurt, 0.06) < 0.03 else -2.0
	# Siegerpose: zwei Freudensprünge, Funken steigen auf
	var win_t := -1.0
	if st.over and st.outcome == "won" and end_timer > 0:
		win_t = END_WIN - end_timer
		if win_t > 0.25 and win_t < 1.15:
			pfy -= roundf(absf(sin((win_t - 0.25) / 0.45 * PI)) * 12.0)
	for d in dust:
		var a: float = d.t / 0.35
		var s := 3 if a > 0.5 else 2
		draw_rect(Rect2(roundi(d.x), roundi(d.y), s, s), Color(0.85, 0.85, 0.95, 0.5 * a))
	_shadow(gx(p.c) + CW / 2.0, feet_y(p.r), 30)
	if st.decoy > 0 and st.decoy_t > 0:
		for k in st.decoy:
			_draw_sprite(mkey, pcx - 16 - k * 10, pfy, false, {"scale": BABY_SCALE if run.stage == 1 else 1, "mod": Color(0.6, 1.0, 0.8, 0.35 + 0.1 * sin(anim_t * 8.0 + k))})
	var hurt_tint := Color(1.0, 0.55, 0.55) if (p_hurt > 0 and p.flash <= 0) else Color.WHITE
	if st.burrow_t > 0:
		# Graben (Buddli-Linie): eingegraben – nur ein Erdhügel mit rieselnder Erde ist zu sehen
		var mx := roundi(pcx)
		var my := roundi(pfy)
		var dirt := Color("#6A4A2E")
		draw_rect(Rect2(mx - 16, my - 6, 32, 6), dirt)
		draw_rect(Rect2(mx - 11, my - 10, 22, 4), dirt)
		draw_rect(Rect2(mx - 6, my - 13, 12, 3), dirt)
		draw_rect(Rect2(mx - 11, my - 10, 22, 1), Color("#8A6A46"))
		for i in 4:
			var dx := fmod(anim_t * 37.0 + i * 11.0, 30.0) - 15.0
			draw_rect(Rect2(mx + roundi(dx), my - 14 - (i % 2) * 3, 2, 2), Color("#C8A878"))
	else:
		_draw_sprite(mkey, pcx, pfy, false, {"flash": p.flash > 0, "blink": blink_p, "bob": bob_p, "scale": BABY_SCALE if run.stage == 1 else 1, "atk": (1.0 - p_atk / ATK_TIME) if p_atk > 0 else -1.0, "mod": hurt_tint})
	if win_t > 0.2:
		_draw_victory_sparks(Vector2(pcx, pfy - 30), win_t)
	var body := Vector2(gx(p.c) + CW / 2.0, feet_y(p.r) - 24)
	if muzzle > 0:
		# Mündungsblitz vorn am Monster
		var mz := Vector2(roundi(pcx + 22), roundi(pfy - 22))
		var k := muzzle / 0.09
		draw_rect(Rect2(mz - Vector2(5, 1) * k * 2, Vector2(10, 2) * k * 2), Color(muzzle_col, 0.9))
		draw_rect(Rect2(mz - Vector2(1, 4) * k * 2, Vector2(2, 8) * k * 2), Color(muzzle_col, 0.9))
		draw_rect(Rect2(mz - Vector2(2, 2), Vector2(4, 4)), Color.WHITE)
	if st.shield > 0:
		_draw_shield(body)
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
		if st.bots[i].get("kind", "bot") == "turret":
			# Geschützturm: kleiner Sockel mit Lauf nach rechts
			var tp := body + Vector2(18, -4)
			draw_rect(Rect2(tp + Vector2(-5, -8), Vector2(10, 10)), GameData.COL.dark)
			draw_rect(Rect2(tp + Vector2(-4, -7), Vector2(8, 8)), GameData.EL.Code)
			draw_rect(Rect2(tp + Vector2(3, -5), Vector2(8, 3)), GameData.COL.dark)
			draw_rect(Rect2(tp + Vector2(-2, -5), Vector2(3, 3)), Color.WHITE if fmod(anim_t, 0.6) < 0.3 else GameData.EL.Code.lightened(0.4))
			continue
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
		var e_has_atk := PixelCanvas.has_attack(st.def.spr)
		var e_atk := -1.0
		if e_has_atk:
			if e_atk_post > 0:
				e_atk = ATK_HIT + (1.0 - ATK_HIT) * (1.0 - e_atk_post / E_ATK_POST)
			elif windup > 0:
				e_atk = windup * ATK_HIT
		ecx += windup * 4.0
		if e_strike > 0:
			ecx -= sin((1.0 - e_strike / 0.12) * PI) * 9.0
		if e_knock > 0:
			ecx += sin((1.0 - e_knock / (KNOCK * 1.5)) * PI) * 6.0
		var fade := 1.0
		if defeated:
			# Defragmentieren: der Gegner zerfällt in Datenpixel, die nach oben wegrieseln
			if not dis_set:
				dis_origin = Vector2(ecx, efy)
				dis_set = true
			var dk := END_WIN - maxf(end_timer, 0.0)
			_shadow(dis_origin.x, dis_origin.y, roundi((44 if st.def.boss else 34) * clampf(1.0 - dk / 0.8, 0.0, 1.0)))
			_draw_dissolve(dis_origin, dk)
			return
		if mat_t > 0:
			# Materialisieren: die Pixel fliegen von außen herbei
			_shadow(ecx, efy, roundi((44 if st.def.boss else 34) * (1.0 - mat_t / MAT_TIME)))
			_draw_materialize(Vector2(ecx, efy), 1.0 - mat_t / MAT_TIME)
			return
		var elite: bool = st.def.get("elite", false)
		_shadow(ecx, efy, 44 if st.def.boss else (40 if elite else 34))
		var tint := Color.WHITE
		if st.boss_phase() == 3 and sin(anim_t * 14.0) > 0.4:
			tint = Color("#FF9DB3")
		elif st.def.get("glitch", false):
			tint = Color("#FF9DF0") if fmod(anim_t, 0.9) < 0.12 else Color("#E8B0FF")
		elif st.def.get("elite", false):
			tint = Color(1.0, 0.78, 0.72)
		# Konter-Fenster: der Gegner glüht beim Ausholen rot-weiß auf (jetzt treffen = Konter)
		var c_open := not defeated and st.counter_open()
		if c_open:
			tint = tint.lerp(Color("#FFD0D8"), 0.5 + 0.5 * sin(anim_t * 40.0))
		tint.a = fade
		# Elite: glühende Aura-Kontur (rot), Glitch-Elite flackert magenta – sie sollen auf einen Blick gefährlich wirken
		var aura := Color.TRANSPARENT
		if st.def.get("glitch", false):
			aura = Color("#FF4FD8", 0.85 if fmod(anim_t, 0.5) < 0.38 else 0.35)
		elif elite:
			aura = Color("#FF5A3C", 0.45 + 0.3 * sin(anim_t * 4.0))
		aura.a *= fade
		_draw_sprite(st.def.spr, ecx, efy, true, {"flash": e.flash > 0 or (defeated and fade > 0.6), "blink": blink_e, "bob": bob_e, "mod": tint, "atk": -1.0 if defeated else e_atk, "outline": aura, "mystery": mystery_foe})
		_draw_status_fx(ecx, efy)
		if c_open:
			# Fadenkreuz über dem Kopf: „jetzt zuschlagen“
			var tl := _enemy_topleft(Vector2(ecx, efy))
			var cc := Vector2(roundi(ecx), roundi(maxf(tl.y, Y0 - 40) - 8))
			var rr := 6.0 + (1.0 if sin(anim_t * 30.0) > 0 else 0.0)
			var red := Color("#FF5470")
			draw_arc(cc, rr, 0, TAU, 16, red, 2.0)
			for d in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
				draw_line(cc + d * (rr - 3), cc + d * (rr + 3), Color.WHITE, 1.0)
		if st.delayed.any(func(d): return d.mark):
			var cc := Vector2(ecx, efy - 26)
			var rad := 22.0 + 3.0 * sin(anim_t * 20.0)
			draw_arc(cc, rad, 0, TAU, 24, GameData.EL.Elektro, 1)
			draw_rect(Rect2(cc.x - 32, cc.y, 64, 1), GameData.EL.Elektro)
			draw_rect(Rect2(cc.x, cc.y - 32, 1, 64), GameData.EL.Elektro)


## Linke obere Ecke des Gegner-Sprites für Fußposition c (wie in _draw_sprite)
func _enemy_topleft(c: Vector2) -> Vector2:
	var s := sprite(st.def.spr)
	var sc: int = 2 if s.n <= 32 else 1
	var size: int = s.n * sc
	return Vector2(roundi(c.x - size / 2.0), roundi(c.y - size + s.foot * sc))


## Defragmentieren: erst ein weißer Blitz, dann lösen sich die Pixel von oben nach unten und rieseln als Daten nach oben
func _draw_dissolve(c: Vector2, t: float) -> void:
	var tl := _enemy_topleft(c)
	var n := float(sprite(st.def.spr).n)
	var mint := Color("#6EE7C5")
	for px in e_pix:
		var start: float = 0.12 + (px[1] / maxf(1.0, n * (2.0 if n <= 32 else 1.0))) * 0.45 + px[3] * 0.15
		var q := tl + Vector2(px[0], px[1])
		var col: Color = px[2]
		if t < 0.12:
			col = Color.WHITE
		elif t > start:
			var k := clampf((t - start) / 0.7, 0.0, 1.0)
			q += Vector2((px[3] - 0.5) * 30.0 * k, -k * k * 60.0 - k * 10.0)
			col = col.lerp(mint, k)
			col.a = 1.0 - k
			if col.a <= 0.02:
				continue
		draw_rect(Rect2(roundi(q.x), roundi(q.y), e_pix_size, e_pix_size), col)


## Materialisieren: Pixel kommen aus allen Richtungen, leuchten zuerst mint und nehmen dann ihre Farbe an
func _draw_materialize(c: Vector2, k: float) -> void:
	var tl := _enemy_topleft(c)
	var mint := Color("#6EE7C5")
	for px in e_pix:
		var a: float = px[3] * TAU
		var dist: float = (1.0 - k) * (1.0 - k) * (40.0 + px[3] * 50.0)
		var q: Vector2 = tl + Vector2(px[0], px[1]) + Vector2(cos(a), sin(a)) * dist
		var col: Color = mint.lerp(px[2], clampf((k - 0.5) * 2.0, 0.0, 1.0))
		col.a = clampf(k * 2.0, 0.0, 1.0)
		draw_rect(Rect2(roundi(q.x), roundi(q.y), e_pix_size, e_pix_size), col)


## Siegerpose: Sterne und Funken steigen um den Glitchling auf
func _draw_victory_sparks(c: Vector2, t: float) -> void:
	for i in 10:
		var ph := fmod(t * 0.9 + i * 0.1, 1.0)
		var a := i * TAU / 10.0
		var q := c + Vector2(cos(a) * (14.0 + ph * 22.0), -ph * 34.0 + sin(a) * 8.0)
		var col: Color = [GameData.COL.sun, GameData.COL.mint, Color.WHITE][i % 3]
		col.a = 1.0 - ph
		if i % 3 == 0:
			_plus(q, 2, col)
		else:
			draw_rect(Rect2(roundi(q.x), roundi(q.y), 2, 2), col)


## Signatur-Einblendung: Streifen mit dem Glitchling in groß und dem Namen der Attacke
func _draw_cutin() -> void:
	var t := CUTIN - cutin_t
	var S: Dictionary = run.special()
	var el: Color = GameData.EL[S.el]
	var slide := clampf(t / 0.14, 0.0, 1.0)
	var out := clampf((t - (CUTIN - 0.14)) / 0.14, 0.0, 1.0)
	draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.35 * (1.0 - out)))
	var band_y := 112.0
	var band_h := 128.0
	var bx := -W * (1.0 - slide) + W * out
	draw_rect(Rect2(bx, band_y - 4, W, band_h + 8), Color(el.darkened(0.5), 0.95))
	draw_rect(Rect2(bx, band_y, W, band_h), Color(GameData.COL.dark, 0.92))
	draw_rect(Rect2(bx, band_y, W, 2), el)
	draw_rect(Rect2(bx, band_y + band_h - 2, W, 2), el)
	# Tempolinien
	for i in 14:
		var ly := band_y + 8 + fmod(i * 37.0, band_h - 16)
		var lx := fposmod(-t * 900.0 - i * 97.0, W + 120.0) - 60.0 + bx
		draw_rect(Rect2(roundi(lx), roundi(ly), 40 + (i % 3) * 20, 1), Color(el.lightened(0.3), 0.6))
	# Glitchling in groß (ganzzahlig), leuchtender Umriss in Element-Farbe
	var s := sprite(run.form)
	var sc := 4 if s.n <= 32 else (2 if s.n <= 64 else 1)
	var drift := t * 18.0
	var mx := bx + 170.0 + drift
	var feet: float = band_y + band_h - 6.0
	for o in [Vector2(-2, 0), Vector2(2, 0), Vector2(0, -2), Vector2(0, 2)]:
		_draw_sprite(run.form, mx + o.x, feet + o.y, false, {"scale": sc, "flash": true, "mod": Color(el, 0.8), "anim": false})
	_draw_sprite(run.form, mx, feet, false, {"scale": sc, "anim": false})
	# Name der Attacke
	var tx := bx + 300.0
	_text(Vector2(tx, band_y + 48), T.t(run.form).to_upper(), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(Vector2(tx, band_y + 76), T.t(S.name).to_upper() + "!", 24, el.lightened(0.25), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(Vector2(tx, band_y + 96), T.t("Signatur-Attacke"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)


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
		_draw_proj(pr, pos, col)
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
	_draw_vfx()
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
		_text(Vector2(0, 120 - (1.0 - k) * 6), T.t(b.text).to_upper(), 24, Color(b.color, a), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


func _draw_hud() -> void:
	# Spieler links
	var P := Rect2(8, 8, 200, 34)
	_box(P, Color(GameData.COL.panel, 0.9), GameData.COL.line)
	_text(P.position + Vector2(6, 12), run.form, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(P.position + Vector2(6, 12), _hud_sub(run.form, "%s · %s" % [T.t(GameData.STAGE_NAMES[run.stage]), T.t(run.form_el())], T.t(GameData.STAGE_NAMES[run.stage]), P.size.x - 12), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, P.size.x - 12)
	_bar(Rect2(P.position + Vector2(6, 18), Vector2(128, 9)), float(run.hp) / run.max_hp, GameData.COL.mint)
	_text(P.position + Vector2(6, 26), "%d/%d" % [run.hp, run.max_hp], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, P.size.x - 12)
	var buffs: Array = []
	# Element-Gabe der Form (dauerhaft, ab Rookie)
	var G: Dictionary = st.gift
	if not G.is_empty():
		buffs.append([G.name, GameData.EL[G.el]])
	if st.reflex > 0:
		buffs.append(["Katzenreflex", GameData.COL.mint])
	if st.oc > 0:
		buffs.append(["Übertaktet", GameData.EL.Feuer])
	if st.scan > 0:
		buffs.append([T.t("Scan x%d") % st.scan, GameData.EL.Code])
	if st.mist > 0:
		buffs.append(["Nebel", GameData.EL.Wasser])
	if st.gills_t > 0:
		buffs.append(["Kiemen", GameData.COL.mint])
	if st.owl_t > 0:
		buffs.append(["Eulenauge", Color("#8FD8FF")])
	if st.burrow_t > 0:
		buffs.append(["Eingegraben", Color("#C8A878")])
	var bx := 8.0
	for bf in buffs:
		var bw := text_width(bf[0]) + 8
		_box(Rect2(bx, 45, bw, 13), GameData.COL.dark, bf[1])
		_text(Vector2(bx, 55), bf[0], 8, bf[1], HORIZONTAL_ALIGNMENT_CENTER, bw, false)
		bx += bw + 3
	# Module: doppelt große Symbole in einer eigenen Zeile unter den Zuständen, sie leuchten auf, wenn sie wirken (09.10.2026)
	if not run.modules.is_empty():
		_draw_battle_modules(8, 62)
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
	var kind: String = T.t(ZoneMap.TYPE_NAMES[node_type])
	_text(Vector2(0, 20), T.t("Akt %d · Ebene %d · Etage %d · %s") % [run.act + 1, run.map.level + 1, run.floor_idx + 1, kind], 8, GameData.COL.sun if node_type != "fight" else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	if st.status != "" and st.t < 6.0:
		_text(Vector2(0, 76), st.status, 8, Color(GameData.COL.sun, clampf(6.0 - st.t, 0.0, 1.0)), HORIZONTAL_ALIGNMENT_CENTER, W)


## Untertitel im HUD kürzen, wenn er mit einem langen Namen kollidieren würde
func _hud_sub(name: String, full: String, short: String, w: float) -> String:
	return full if text_width(T.t(name), 8, true) + text_width(full) + 10 <= w else short


## Module im Kampf: 28 px, wirkende leuchten weiß auf und springen kurz hoch, daneben der Name des zuletzt wirkenden
func _draw_battle_modules(x: float, y: float) -> void:
	var n := mini(run.modules.size(), 6)
	for i in n:
		var id: String = run.modules[i]
		var k: float = st.mod_fx.get(id, 0.0) / st.MOD_FX
		var pos := Vector2(x + i * 31, y - roundf(3.0 * k))
		if k > 0:
			draw_rect(Rect2(pos - Vector2(2, 2), Vector2(32, 32)), Color(1, 1, 1, 0.85 * k))
		_draw_module_icon(id, pos, 2)
	if run.modules.size() > n:
		_text(Vector2(x + n * 31, y + 18), "+%d" % (run.modules.size() - n), 8, GameData.COL.muted)
	if st.mod_last != "" and st.mod_fx.has(st.mod_last) and run.modules.find(st.mod_last) < n:
		var M: Dictionary = GameData.MODULES[st.mod_last]
		var a := clampf(st.mod_fx[st.mod_last] / 0.3, 0.0, 1.0)
		_text(Vector2(x + run.modules.find(st.mod_last) * 31, y + 40), M.name, 8, Color(Color(M.col), a), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)


## Kette (09.10.2026): links über dem Spielfeld, mit Restzeit bis sie reißt
func _draw_chain() -> void:
	if st.chain_n < 2 or st.t - st.chain_last > GameData.CHAIN_GAP:
		return
	var col: Color = GameData.EL[st.chain_el]
	var s := T.t("Kette %s") % GameData.mult_text(GameData.chain_mult(st.chain_n))
	var pos := Vector2(X0, Y0 - 10)
	_text(pos, s, 16, col, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_bar(Rect2(pos.x, pos.y + 3, text_width(s, 16, true), 3), 1.0 - (st.t - st.chain_last) / GameData.CHAIN_GAP, col)


func _draw_hand() -> void:
	_draw_chain()
	# Signatur-Karte rechts (Hinweis zur Pause darüber)
	_text(Vector2(HAND_X + 3 * (CARD_W + 6), 302), (InputSetup.btn("Start") if InputSetup.pad else "Esc") + ": " + T.t("Pause"), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, 130)
	for i in 3:
		var s: Dictionary = st.hand[i]
		var ro: int = GameData.SLOT_ROLE[i]
		var rc := Color(GameData.ROLE_COL[ro])
		# Kopfzeile: Rolle links, nächster Chip aus dem Stapel rechts (beim Angriffspaar nur einmal, über dem zweiten Slot)
		var x0 := HAND_X + i * (CARD_W + 6)
		_text(Vector2(x0 + 1, 302), T.t(GameData.ROLE_NAMES[ro]), 8, rc, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		var nx := st.next_chip(i) if i > 0 else ""
		if nx != "":
			_text(Vector2(x0, 302), "> " + T.chip(nx), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, CARD_W - 1)
		# Stapel hinter der Karte (bis zu zwei Kartenrücken)
		var r := Rect2(x0, HAND_Y, CARD_W, CARD_H)
		for k in range(mini(st.piles[ro].size(), 2) if i > 0 else 0, 0, -1):
			_box(Rect2(r.position + Vector2(2 * k, -2 * k), r.size), GameData.COL.bg2.darkened(0.2 * k), rc.darkened(0.55))
		# neue Karte gleitet vom Stapel herein
		var ka: float = card_t[i] / 0.18
		r.position += Vector2(roundf(4.0 * ka), roundf(-4.0 * ka))
		if s.chip == "":
			_box(r, GameData.COL.bg2, GameData.COL.line)
			draw_multiline_string(font(), r.position + Vector2(8, 18), T.t("Kein %s-Chip im Deck") % T.t(GameData.ROLE_NAMES[ro]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, tsz(8), 2, GameData.COL.muted, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
			continue
		var ch: Dictionary = GameData.chip(s.chip)
		var el: Color = GameData.EL[ch.el]
		var ready: bool = s.rem <= 0
		_box(r, GameData.COL.panel if ready else GameData.COL.bg2, rc if ready else GameData.COL.line)
		draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(3, r.size.y - 2)), el)
		# Resonanz: Chip im Element der Form – breiterer, schimmernder Element-Streifen
		if GameData.resonance(run.form, ch.el) > 0 and int(ch.dmg) > 0:
			var sh := 0.5 + 0.5 * sin(anim_t * 6.0 + i)
			draw_rect(Rect2(r.position + Vector2(4, 1), Vector2(1, r.size.y - 2)), el.lightened(0.5 * sh))
			var py := r.position.y + 2 + fmod(anim_t * 30.0 + i * 13.0, r.size.y - 6)
			draw_rect(Rect2(r.position.x + 1, py, 3, 2), Color(1, 1, 1, 0.8))
		# Tasten-Symbol
		var g := Rect2(r.position + Vector2(8, 5), Vector2(maxf(15.0, text_width(_glyph_chip(i), 8, true) + 6), 14))
		_box(g, GameData.COL.dark, rc if ready else GameData.COL.line)
		_text(g.position + Vector2(1, 11), _glyph_chip(i), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, g.size.x, false, true)
		_text(Vector2(g.end.x + 6, r.position.y + 16), _fit(T.t(s.chip), r.end.x - 21 - g.end.x - 6), 8, GameData.COL.ink if ready else GameData.COL.muted, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		# Trefferbild oder Symbol oben rechts
		_draw_chip_icon(s.chip, r.position + Vector2(r.size.x - 17, 5), ready)
		_text(r.position + Vector2(8, 33), GameData.chip_short(s.chip), 8, GameData.COL.ink if ready else GameData.COL.muted)
		if ready:
			_text(r.position + Vector2(8, 33), "bereit", 8, rc, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 14)
		else:
			_bar(Rect2(r.position + Vector2(6, r.size.y - 8), Vector2(r.size.x - 12, 5)), 1.0 - s.rem / s.max, el.darkened(0.2))
			if s.get("shuf", false) and s.rem > GameData.chip(s.chip).cd:
				_text(r.position + Vector2(8, 33), "mischt …", 8, rc, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 14)
		# neuer Chip: kleines blinkendes „Neu!“ an der oberen Kante
		if new_t[i] > 0 and fmod(new_t[i], 0.5) > 0.15:
			var nw := text_width("Neu!", 8, true) + 6
			_box(Rect2(r.end.x - nw - 20, r.position.y - 5, nw, 11), GameData.COL.sun, GameData.COL.dark)
			_text(Vector2(r.end.x - nw - 20, r.position.y + 4), "Neu!", 8, GameData.COL.dark, HORIZONTAL_ALIGNMENT_CENTER, nw, false, true)
		# zu früh gedrückt: roter Rahmen blinkt kurz
		if s.get("deny", 0.0) > 0 and fmod(s.deny, 0.1) < 0.06:
			draw_rect(r, GameData.COL.coral, false, 2.0)
	# gespielte Chips schweben als Name davon
	for gh in ghosts:
		_text(Vector2(gh.x, gh.y - (1.0 - gh.t / 0.4) * 14.0), gh.text, 8, Color(GameData.COL.ink, gh.t / 0.4), HORIZONTAL_ALIGNMENT_CENTER, CARD_W, true, true)
	# Signatur-Attacke
	var R := Rect2(HAND_X + 3 * (CARD_W + 6), HAND_Y, 130, CARD_H)
	var full := st.sp >= 100
	var S: Dictionary = run.special()
	var sel: Color = GameData.EL[S.el]
	var pulse := full and sin(anim_t * 8.0) > 0
	_box(R, GameData.COL.panel if full else GameData.COL.bg2, GameData.COL.sun if pulse else GameData.COL.line)
	var glyph := InputSetup.btn("Y") if InputSetup.pad else InputSetup.key_label("special")
	var g2 := Rect2(R.position + Vector2(6, 5), Vector2(text_width(glyph, 8, true) + 8, 14))
	_box(g2, GameData.COL.dark, GameData.COL.sun if full else GameData.COL.line)
	_text(g2.position + Vector2(1, 11), glyph, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, g2.size.x, false, true)
	_text(R.position + Vector2(g2.size.x + 10, 16), "Signatur", 8, GameData.COL.sun if full else GameData.COL.muted)
	_text(R.position + Vector2(6, 33), S.name, 8, GameData.COL.ink if full else GameData.COL.muted)
	_bar(Rect2(R.position + Vector2(6, R.size.y - 8), Vector2(R.size.x - 12, 5)), st.sp / 100.0, GameData.COL.sun if full else sel.darkened(0.2))
	if mode == Mode.READY:
		_draw_ready()


## Bereit-Pause vor jedem Kampf: über jeder Karte steht, was sie tut
func _draw_ready() -> void:
	draw_rect(Rect2(0, 0, W, 296), Color(GameData.COL.dark, 0.55))
	var pulse := 0.7 + 0.3 * sin(anim_t * 5.0)
	_text(Vector2(0, 116), "Bereit?", 24, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	var go := InputSetup.btn("A") if InputSetup.pad else "Enter"
	_text(Vector2(0, 140), T.t("Lies deine Chips – %s: Los!") % go, 8, Color(GameData.COL.sun, pulse), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	for i in 3:
		if st.hand[i].chip != "":
			_draw_chip_tip(i, st.hand[i].chip, false)
	# Signatur
	var S: Dictionary = run.special()
	var R := Rect2(HAND_X + 3 * (CARD_W + 6), 230, 130, 64)
	_box(R, Color(GameData.COL.panel, 0.96), GameData.COL.sun)
	_text(R.position + Vector2(6, 12), T.t("Signatur-Attacke"), 8, GameData.COL.sun)
	draw_multiline_string(font(), R.position + Vector2(6, 25), T.t(S.desc), HORIZONTAL_ALIGNMENT_LEFT, R.size.x - 12, tsz(8), 3, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)


## Erklärkasten über der Karte von Slot i (Beschreibung des Chips)
func _draw_chip_tip(i: int, id: String, is_new := true) -> void:
	var ch: Dictionary = GameData.chip(id)
	var rc := Color(GameData.ROLE_COL[GameData.SLOT_ROLE[i]])
	var R := Rect2(HAND_X + i * (CARD_W + 6), 230, CARD_W, 64)
	_box(R, Color(GameData.COL.panel, 0.96), rc)
	var head := (T.t("Neu:") + " " + T.chip(id)) if is_new else T.t(GameData.ROLE_NAMES[GameData.SLOT_ROLE[i]]) + " · " + T.t(ch.el)
	_text(R.position + Vector2(6, 12), head, 8, rc, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	draw_multiline_string(font(), R.position + Vector2(6, 25), T.t(ch.desc), HORIZONTAL_ALIGNMENT_LEFT, R.size.x - 12, tsz(8), 3, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	# Pfeil zur Karte
	for k in 4:
		draw_rect(Rect2(R.get_center().x - 4 + k, R.end.y + k, 9 - k * 2, 1), rc)


## Bereit-Pause nur, wenn auf der Starthand ein Chip liegt, den der Spieler noch nicht kennt
## (Produzent 03.10.2026: vor jedem Kampf war zu viel)
func _needs_ready() -> bool:
	if skip_ready:
		return false
	var seen: Array = SaveGame.data.get("seen_chips", [])
	for s in st.hand:
		if s.chip != "" and not seen.has(GameData.base_chip(s.chip)):
			return true
	return false


## Gesehene Chips merken (Erklärung erscheint pro Spielstand nur einmal)
func _mark_seen_hand() -> void:
	for s in st.hand:
		_mark_seen(s.chip)


func _mark_seen(id: String) -> void:
	if id == "" or not SaveGame.persist:
		return
	var seen: Array = SaveGame.data.get("seen_chips", [])
	var b := GameData.base_chip(id)
	if not seen.has(b):
		seen.append(b)
		SaveGame.data["seen_chips"] = seen


## Kartenwechsel erkennen: Animation starten, neue Chips einmal erklären
func _track_cards(delta: float) -> void:
	for i in 3:
		card_t[i] = maxf(0.0, card_t[i] - delta)
		new_t[i] = maxf(0.0, new_t[i] - delta)
		var c: String = st.hand[i].chip
		if c != prev_chips[i]:
			if prev_chips[i] != "":
				ghosts.append({"text": T.chip(prev_chips[i]), "x": HAND_X + i * (CARD_W + 6), "y": HAND_Y + 16, "t": 0.4})
			card_t[i] = 0.18
			prev_chips[i] = c
			var seen: Array = SaveGame.data.get("seen_chips", [])
			if c != "" and SaveGame.persist and not seen.has(GameData.base_chip(c)):
				new_t[i] = NEW_TIME
				_mark_seen(c)
	for k in range(ghosts.size() - 1, -1, -1):
		ghosts[k].t -= delta
		if ghosts[k].t <= 0:
			ghosts.remove_at(k)


func _panel(r: Rect2) -> void:
	_dim()
	_box(r, GameData.COL.panel, GameData.COL.line)


func _draw_pause() -> void:
	var r := Rect2(60, 40, 520, 280)
	_panel(r)
	_text(r.position + Vector2(0, 28), "Pause", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	_text(Vector2(r.position.x + 20, r.position.y + 46), "Dein Deck", 8, GameData.COL.muted)
	_draw_deck_list(run.deck, r.position.x + 20, r.position.y + 66, 220, 10)
	_text(Vector2(r.position.x + 270, r.position.y + 46), T.t("Module (%d)") % run.modules.size(), 8, GameData.COL.muted)
	_draw_module_list(run.modules, r.position.x + 270, r.position.y + 58, 230, 4)
	_text(Vector2(r.position.x + 20, r.end.y - 62), T.t("Ziehstapel %d · Abwurf %d") % [st.pile_count(), st.disc_count()], 8, GameData.COL.muted)
	_menu(PAUSE_ITEMS, pause_idx, r.get_center().x, r.end.y - 72, 160)


func _draw_pick() -> void:
	var es := run.evo_status()
	var r := Rect2(40, 30, 560, 300)
	_panel(r)
	var head_txt := "Sieg!"
	if node_type == "guard":
		head_txt = T.t("Wächter besiegt! Ebene %d ist frei.") % (run.map.level + 2)
	elif node_type == "glitch":
		head_txt = "Glitch-Elite besiegt! Epische Beute!"
	elif node_type == "boss":
		head_txt = T.t("%s ist befreit!") % T.t(run.map.zone_name)
	_text(r.position + Vector2(0, 30), head_txt, 16, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	var line := T.t("%s ist defragmentiert. +%d Fragmente") % [T.t(st.def.name), st.loot_gained if st.loot_gained > 0 else st.def.loot]
	if heal_info > 0:
		line += ", +%d HP" % heal_info
	_text(r.position + Vector2(0, 48), line + ".", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(r.position + Vector2(0, 62), "Wähle einen Chip für den Rest des Runs.", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	# Elite-Belohnung: neues Modul unter den Karten
	if new_module != "":
		var M: Dictionary = GameData.MODULES[new_module]
		var head: String = T.t("Neues Modul:") + " " + T.t(M.name)
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
		_text(c.position + Vector2(0, 26), k, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, c.size.x, true, true)
		var ro := GameData.role(k)
		_text(c.position + Vector2(0, 38), "%s · %s" % [T.t(ch.el), T.t(ch.rar)], 8, el, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		# Slot, in den der Chip kommt
		_text(c.position + Vector2(0, 14), (T.t("Angriffs-Slot (%s)") % (_glyph_chip(0) + "/" + _glyph_chip(1))) if ro == 0 else (T.t("Support-Slot (%s)") % _glyph_chip(2)), 8, Color(GameData.ROLE_COL[ro]), HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		var stats: String = T.t(ch.cat) + (" · %d" % ch.dmg if ch.dmg > 0 else "") + " · %ss" % T.dec(ch.cd)
		_text(c.position + Vector2(0, 52), stats, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
		draw_multiline_string(font(), c.position + Vector2(8, 70), T.t(ch.desc), HORIZONTAL_ALIGNMENT_CENTER, c.size.x - 16, tsz(8), 3, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
		# Synergie mit Deck, Modulen oder Passiv
		var combo := GameData.synergy(k, run.deck, run.modules, run.mon.passive)
		if combo != "":
			var pulse := 0.75 + 0.25 * sin(anim_t * 5.0 + i)
			_text(Vector2(c.position.x, c.end.y - 19), T.t(combo) + "!", 8, Color(GameData.COL.sun, pulse), HORIZONTAL_ALIGNMENT_CENTER, c.size.x, true, true)
		# Wirkung auf die Evolution
		var tag := ""
		var tag_col: Color = GameData.COL.muted
		if ch.el == "Neutral":
			tag = T.t("Neutral: prägt nicht")
		elif int(es.need) > 0 and run.stage == 1:
			if run.mon.evo.has(ch.el):
				var f: String = run.mon.evo[ch.el]
				tag = T.t("Prägt > %s") % (T.t(f) if SaveGame.data.get("dex", {}).has(f) else T.t("%s-Form") % T.t(ch.el))
				tag_col = el
			else:
				tag = T.t("Ohne Wirkung auf %s") % T.t(run.form)
		elif GameData.resonance(run.form, ch.el) > 0 and int(ch.dmg) > 0:
			tag = T.t("Resonanz: +%d %% Schaden") % roundi(GameData.resonance(run.form, ch.el) * 100)
			tag_col = el
		elif int(es.need) > 0:
			tag = "Zählt zur nächsten Stufe"
			tag_col = el
		_text(Vector2(c.position.x, c.end.y - 6), tag, 8, tag_col, HORIZONTAL_ALIGNMENT_CENTER, c.size.x)
	var evo_line := ""
	if int(es.need) > 0:
		var lead: String = (T.t("Richtung %s") % T.t(es.leader)) if es.leader != "" else T.t("Richtung offen")
		evo_line = T.t(" · Element-Chips %d/%d · %s") % [mini(int(es.total), int(es.need)), int(es.need), lead]
	_text(Vector2(r.position.x, r.end.y - 36), T.t("Deck: %d Chips · Fragmente: %d%s") % [run.deck.size(), run.frag, evo_line], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var pad: bool = InputSetup.pad
	_text(Vector2(r.position.x, r.end.y - 16), T.t("< > wählen   %s nehmen   %s überspringen (+%d Fragmente)") % [InputSetup.btn("A") if pad else "Enter", InputSetup.btn("B") if pad else "Esc", SKIP_FRAG], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)


## „Neues Modul!“: großes Symbol, Name, Seltenheit und Wirkung, Strahlen in der Seltenheitsfarbe
func _draw_module_reveal() -> void:
	var M: Dictionary = GameData.MODULES[new_module]
	var rc: Color = {"Gewöhnlich": GameData.COL.ink, "Selten": Color("#58B7FF"), "Episch": Color("#FFC83D")}[M.rar]
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.82))
	var c := Vector2(W / 2.0, 150)
	for i in 12:
		var a := i * TAU / 12.0 + anim_t * 0.4
		var d1 := Vector2(cos(a - 0.08), sin(a - 0.08)) * 260.0
		var d2 := Vector2(cos(a + 0.08), sin(a + 0.08)) * 260.0
		draw_colored_polygon(PackedVector2Array([c, c + d1, c + d2]), Color(rc, 0.07))
	var R := Rect2(W / 2.0 - 170, 70, 340, 200)
	_box(R, Color(GameData.COL.panel, 0.97), rc)
	_text(Vector2(R.position.x, R.position.y + 24), "Neues Modul!", 16, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	var bob := roundf(sin(anim_t * 3.0) * 2.0)
	_draw_module_icon(new_module, Vector2(c.x - 21, R.position.y + 38 + bob), 3)
	_text(Vector2(R.position.x, R.position.y + 104), M.name, 16, Color(M.col), HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	_text(Vector2(R.position.x, R.position.y + 120), T.t("%s · wirkt für den ganzen Run") % T.t(M.rar), 8, rc, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)
	draw_multiline_string(font(), Vector2(R.position.x + 20, R.position.y + 142), T.t(M.desc), HORIZONTAL_ALIGNMENT_CENTER, R.size.x - 40, tsz(8), 2, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	if mode_t > 0.6 and not cinematic:
		_text(Vector2(R.position.x, R.end.y - 10), T.t("%s weiter") % (InputSetup.btn("A") if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)


func _draw_evolve() -> void:
	var t := mode_t
	var c := Vector2(W / 2.0, 240)
	var from: String = evo.from
	var to: String = evo.to
	var el: Color = GameData.EL[GameData.FORMS[to].el]
	var body := c - Vector2(0, 70)
	# Lichtsäule
	var glow := clampf(t / EVO_REVEAL, 0.0, 1.0)
	draw_rect(Rect2(c.x - 40 * glow, 0, 80 * glow, H), Color(el, 0.12 * glow))
	# Strahlenkranz nach der Enthüllung (08.10.2026: das wichtigste Ereignis des Spiels groß inszenieren)
	if t >= EVO_REVEAL:
		var kr := clampf((t - EVO_REVEAL) / 0.4, 0.0, 1.0)
		for i in 12:
			var a := i * TAU / 12.0 + t * 0.35
			var d1 := Vector2(cos(a - 0.07), sin(a - 0.07)) * 420.0 * kr
			var d2 := Vector2(cos(a + 0.07), sin(a + 0.07)) * 420.0 * kr
			draw_colored_polygon(PackedVector2Array([body, body + d1, body + d2]), Color(el, 0.10))
	for i in 12:
		var a := i * TAU / 12.0 + t * 2.0
		var rad := 70.0 - fmod(t * 40.0 + i * 13.0, 60.0)
		draw_rect(Rect2(c + Vector2(cos(a), sin(a) * 0.5) * rad - Vector2(1, 60), Vector2(2, 2)), el.lightened(0.4))
	if t < EVO_REVEAL:
		# Wechsel zwischen alter und neuer Silhouette, immer schneller
		var freq := 2.0 + t * t * 6.0
		var show_new := fmod(t * freq, 1.0) > 0.5
		var key := to if show_new else from
		_draw_sprite(key, c.x, c.y, false, {"flash": true, "scale": 4 if GameData.FORMS[key].stage == 1 else 2})
		_text(Vector2(0, 34), T.t("%s entwickelt sich …") % T.t(from), 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	else:
		var k := t - EVO_REVEAL
		if k < 0.25:
			draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k / 0.25))
		var bob := 1 if sin(anim_t * 4.0) > 0 else 0
		_draw_sprite(to, c.x, c.y, false, {"bob": bob, "scale": 2})
		_text(Vector2(0, 34), T.t("%s ist jetzt %s!") % [T.t(from), T.t(to)], 16, el, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		var S: Dictionary = GameData.SPECIALS[to]
		_text(Vector2(0, 50), T.t("%s · %s · +10 max. HP") % [T.t(GameData.STAGE_NAMES[run.stage]), T.t(GameData.FORMS[to].el)], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
		# Was sich spielerisch ändert: Signatur, Gabe, Resonanz
		var y := 262.0
		_text(Vector2(0, y), T.t("Neue Signatur:") + " " + T.t(S.name), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		_text(Vector2(0, y + 12), S.desc, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
		var G := GameData.gift(to)
		if not G.is_empty():
			var had: bool = not GameData.gift(from).is_empty() and GameData.gift(from).name == G.name
			_text(Vector2(0, y + 32), (T.t("Gabe verstärkt:") if had else T.t("Neue Gabe:")) + " " + T.t(G.name), 8, el, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
			_text(Vector2(0, y + 44), G.desc, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
			_text(Vector2(0, y + 60), T.t("Resonanz: %s-Chips machen +%d %% Schaden") % [T.t(G.el), roundi(GameData.resonance(to, G.el) * 100)], 8, el, HORIZONTAL_ALIGNMENT_CENTER, W)
		if k > 0.6 and not cinematic:
			_text(Vector2(0, 350), T.t("%s weiter") % (InputSetup.btn("A") if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


func _draw_tutorial() -> void:
	var tx: Array = tut.texts(InputSetup.pad)
	if tx.is_empty():
		return
	var r := Rect2(130, 66, 380, 50)
	var pulse := 0.5 + 0.5 * sin(anim_t * 4.0)
	_box(r, Color(GameData.COL.panel, 0.95), GameData.COL.sun.lerp(GameData.COL.mint, pulse))
	_text(Vector2(r.position.x + 10, r.position.y + 16), tx[0], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	# Fortschrittspunkte der Lernschritte
	var n: int = Tutorial.LEARN_STEPS
	for i in n:
		var done: bool = tut.step > i
		var cur: bool = tut.step == i
		draw_rect(Rect2(r.end.x - 8 - n * 11 + i * 11, r.position.y + 9, 7, 7), GameData.COL.mint if done else (GameData.COL.sun if cur else GameData.COL.line))
	draw_multiline_string(font(), Vector2(r.position.x + 10, r.position.y + 32), T.t(tx[1]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 20, tsz(8), 2, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)


## Für Screenshots/Tests: den Kampf mit Autopilot vorspulen (Trailer: eigener Bot).
func simulate(seconds: float, bot: BattleBot = null) -> void:
	if mode == Mode.INTRO:
		_start_boss_fight()
	if mode == Mode.READY:
		_set_mode(Mode.FIGHT)
	if bot == null:
		bot = BattleBot.new(0.15)
	var dt := 1.0 / 60.0
	var steps := 0
	while steps * dt < seconds and (not st.over or end_timer > 0.1):
		bot.act(st)
		st.update(dt)
		for ev in st.events:
			_animate_event(ev)
		st.events.clear()
		if cutin_t > 0:
			# Simulation überspringt die Einblendung
			cutin_t = 0.0
			p_atk = ATK_TIME
		_tick_anims(dt)
		anim_t += dt
		steps += 1
		if st.over:
			end_timer = (END_WIN if st.outcome == "won" else END_LOSE) if end_timer < 0 else end_timer - dt
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
	var mk: String = q.get("kind", "milbe")
	if mk == "bubble":
		# Glitch-Blase: schwillt an, kurz vor dem Platzen hell
		var brad := roundf(7.0 + 5.0 * k + sin(anim_t * 6.0) * 1.0)
		var bc := Vector2(cx, fy - brad - 2)
		draw_circle(bc, brad + 1.0, Color(WATER_DARK, 0.9))
		draw_circle(bc, brad, Color(WATER_LIGHT, 0.7) if fast else Color(WATER_MID, 0.55))
		draw_arc(bc, brad, 0, TAU, 20, WATER_LIGHT, 1)
		draw_rect(Rect2(roundi(bc.x - brad * 0.5), roundi(bc.y - brad * 0.55), 3, 2), Color(1, 1, 1, 0.9))
		_px(bc + Vector2(2, 1), 2, Color("#FF5470", 0.85))
		_px(bc + Vector2(-2, 3), 2, Color("#C77DFF", 0.7))
	elif mk == "spore":
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
	if st.def.get("final", false):
		return "finale"
	return "guard" if st.def.get("guard", false) else "boss"


func _start_boss_fight() -> void:
	if Music.current != _boss_track():
		Music.play(_boss_track())
	st.shake = 0.0
	_set_mode(Mode.READY if _needs_ready() else Mode.FIGHT)


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
			_draw_sprite(def.spr, bx, feet, true, {"scale": 2, "blink": fmod(anim_t, 3.0) < 0.12, "mystery": mystery_foe})
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
		var who := T.t("WÄCHTER") if def.get("guard", false) else "BOSS"
		var wn := T.t("WARNUNG")
		var txt := "  %s  ·  %s  ·  %s  ·  %s  ·  %s  ·  %s  ·  %s  ·  %s" % [wn, who, wn, who, wn, who, wn, who]
		var tx := -fmod(anim_t * 80.0, 200.0) if top else -200.0 + fmod(anim_t * 80.0, 200.0)
		_text(Vector2(tx, y + bh / 2.0 + 4), txt, 8, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	# Weißer Blitz bei der Enthüllung
	if t > INTRO_REVEAL and t < INTRO_REVEAL + 0.35:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - (t - INTRO_REVEAL) / 0.35))
	# Name mit Glitch-Versatz, darunter der Titel
	if t > INTRO_REVEAL + 0.15:
		var k := clampf((t - INTRO_REVEAL - 0.15) / 0.3, 0.0, 1.0)
		var nx := lerpf(-260.0, 36.0, 1.0 - pow(1.0 - k, 3.0))
		var name_s: String = T.t(def.name).to_upper()
		var jit := Vector2(randi_range(-2, 2), 0) if fmod(anim_t, 1.3) < 0.08 else Vector2.ZERO
		var f := font(true, 24)
		var fs := 24 if text_width(name_s, 24, true) <= 290 else 16
		draw_rect(Rect2(nx - 12, 96, 300, 3), el)
		draw_string(f, Vector2(nx - 1, 136) + jit, name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("#4CC3F0", 0.8))
		draw_string(f, Vector2(nx + 1, 136) - jit, name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("#FF5470", 0.8))
		draw_string_outline(f, Vector2(nx, 136), name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, GameData.COL.dark)
		draw_string(f, Vector2(nx, 136), name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
		if t > INTRO_REVEAL + 0.45:
			var tk := clampf((t - INTRO_REVEAL - 0.45) / 0.3, 0.0, 1.0)
			_text(Vector2(nx, 156), T.t(def.get("title", "Herrscher dieser Zone")) if not def.get("guard", false) else T.t("Wächter der Ebene %d · %s") % [run.map.level + 1, T.t(def.get("title", ""))], 8, Color(el.lightened(0.3), tk), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
			if not mystery_foe:
				_text(Vector2(nx, 172), "%s · %d HP" % [T.t(def.el), def.hp], 8, Color(GameData.COL.muted, tk))
	if not cinematic:
		_text(Vector2(0, H - 34), T.t("%s überspringen") % (InputSetup.btn("A") if InputSetup.pad else "Enter"), 8, Color(GameData.COL.muted, 0.7), HORIZONTAL_ALIGNMENT_RIGHT, W - 12)


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
	var evo_el: String = run.mon.evo.keys()[0] if run.stage == 1 else GameData.FORMS[run.form].el
	run.praeg[evo_el] = run.praeg.get(evo_el, 0) + maxi(9, run.evo_need())
	_fight_over()
	mode_t = t


func show_pause_for_screenshot() -> void:
	_set_mode(Mode.PAUSE)


# ---------- Chip-Effekte passend zur Karte (04.10.2026, Tester-Feedback) ----------

const FIRE_DARK := Color("#FF4B2B")
const FIRE_MID := Color("#FF9A2E")
const FIRE_HOT := Color("#FFE27A")
const ICE := Color("#BFF4FF")


## Mitte eines Feldes auf Körperhöhe
func _vc(c: float, r: float) -> Vector2:
	return Vector2(gx(c) + CW / 2.0, feet_y(r) - 20)


func _px(pos: Vector2, size: float, col: Color) -> void:
	draw_rect(Rect2((pos - Vector2(size, size) / 2.0).round(), Vector2(size, size)), col)


func _plus(q: Vector2, s: int, col: Color) -> void:
	draw_rect(Rect2(roundi(q.x) - s, roundi(q.y) - 1, 2 * s + 1, 3), col)
	draw_rect(Rect2(roundi(q.x) - 1, roundi(q.y) - s, 3, 2 * s + 1), col)


## Zackenlinie (Blitz) von a nach b; die Form hängt nur am Seed und flackert daher nicht
func _zigzag(a: Vector2, b: Vector2, seed_v: int, col: Color, width := 2.0, steps := 7) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var n := (b - a).orthogonal().normalized()
	var prev := a
	for i in range(1, steps + 1):
		var q := a.lerp(b, float(i) / steps)
		if i < steps:
			q += n * rng.randf_range(-7.0, 7.0)
		draw_line(prev.round(), q.round(), col, width)
		prev = q


func _diamond(q: Vector2, s: float, col: Color, edge: Color) -> void:
	if s < 1.0:
		return
	draw_colored_polygon(PackedVector2Array([q + Vector2(0, -s * 1.6), q + Vector2(s, 0), q + Vector2(0, s * 1.6), q + Vector2(-s, 0)]), col)
	draw_line(q + Vector2(-s, 0), q + Vector2(0, -s * 1.6), edge, 1)


## Flammenzungen über einem Feld (Fußpunkt base)
func _flame(base: Vector2, k: float, a: float, seed_v: int, n := 4) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var grow := sin(clampf(k, 0.0, 1.0) * PI)
	for i in n:
		var x := base.x - 22.0 + i * (44.0 / maxf(1, n - 1)) + rng.randf_range(-3, 3)
		var h := (16.0 + rng.randf_range(0, 18)) * grow * (0.85 + 0.15 * sin(anim_t * 22.0 + i))
		draw_rect(Rect2(roundi(x - 5), roundi(base.y - h), 10, roundi(h)), Color(FIRE_DARK, a))
		draw_rect(Rect2(roundi(x - 3), roundi(base.y - h * 0.75), 6, roundi(h * 0.75)), Color(FIRE_MID, a))
		draw_rect(Rect2(roundi(x - 1), roundi(base.y - h * 0.45), 3, roundi(h * 0.45)), Color(FIRE_HOT, a))


## Pflaster des Heilpatches
func _bandage(q: Vector2, a: float) -> void:
	q = q.round()
	draw_rect(Rect2(q - Vector2(11, 5), Vector2(22, 10)), Color("#2B1E1A", a))
	draw_rect(Rect2(q - Vector2(10, 4), Vector2(20, 8)), Color("#F2C9A0", a))
	draw_rect(Rect2(q - Vector2(4, 4), Vector2(8, 8)), Color("#FFF4E8", a))
	_plus(q, 2, Color("#FF6B8A", a))
	for dx in [-8, -6, 6, 8]:
		_px(q + Vector2(dx, -1 if dx < 0 else 1), 1, Color("#C99A72", a))


## Geschosse sehen je nach Chip anders aus
func _draw_proj(pr: Dictionary, pos: Vector2, col: Color) -> void:
	if pr.get("id", "") == "Kieselwurf":
		# Kiesel: grauer Stein mit Lichtkante, dreht sich
		draw_circle(pos, 6, Color("#3A3448"))
		draw_circle(pos, 5, Color("#8A84A0"))
		_px(pos + Vector2(-2, -2).rotated(anim_t * 12.0), 2, Color("#D8D2E8"))
		return
	if pr.lob:
		# Glutball: Feuerball
		draw_circle(pos, 8, FIRE_DARK)
		draw_circle(pos, 6, FIRE_MID)
		draw_circle(pos + Vector2(-1, -1), 3, FIRE_HOT)
		return
	match pr.get("id", ""):
		"Wasserstrahl":
			draw_rect(Rect2(pos.x - 34, pos.y - 3, 34, 6), Color(GameData.EL.Wasser, 0.55))
			for i in 4:
				_px(pos + Vector2(-8 - i * 9, sin(anim_t * 30.0 + i) * 4), 3, Color(GameData.EL.Wasser.lightened(0.35), 0.9))
			draw_circle(pos, 6, GameData.EL.Wasser)
			draw_circle(pos + Vector2(2, -2), 2, Color.WHITE)
		"Virusspritzer":
			var w := 1.0 + 0.2 * sin(anim_t * 25.0)
			draw_circle(pos, 6 * w, GameData.EL.Virus.darkened(0.45))
			draw_circle(pos, 5 * w, GameData.EL.Virus)
			_px(pos + Vector2(-2, -2), 2, Color.WHITE)
			for i in 3:
				_px(pos + Vector2(-7 - i * 5, 4 + i * 2), 3 - i, GameData.EL.Virus)
		"Datenfresser":
			var open := absf(sin(anim_t * 18.0)) * 0.9
			draw_circle(pos, 7, GameData.COL.dark)
			draw_circle(pos, 6, GameData.EL.Virus)
			draw_colored_polygon(PackedVector2Array([pos, pos + Vector2(8, -8 * open - 0.5), pos + Vector2(8, 8 * open + 0.5)]), GameData.COL.dark)
			_px(pos + Vector2(-1, -3), 2, Color.WHITE)
		"Kurzschluss":
			draw_circle(pos, 5, GameData.EL.Elektro)
			draw_circle(pos, 2, Color.WHITE)
			_zigzag(pos + Vector2(-16, -6), pos + Vector2(4, -2), int(anim_t * 20.0), Color(GameData.EL.Elektro, 0.9), 1.0, 4)
			_zigzag(pos + Vector2(-16, 6), pos + Vector2(4, 2), int(anim_t * 20.0) + 7, Color(GameData.EL.Elektro, 0.9), 1.0, 4)
		"Frostsplitter":
			draw_colored_polygon(PackedVector2Array([pos + Vector2(10, 0), pos + Vector2(0, -4), pos + Vector2(-9, 0), pos + Vector2(0, 4)]), ICE)
			draw_line(pos + Vector2(-9, 0), pos + Vector2(10, 0), Color.WHITE, 1)
			_px(pos + Vector2(-14, 0), 2, Color(ICE, 0.6))
		"Parasit":
			for i in 3:
				draw_line(pos + Vector2(-2 + i * 2, 3), pos + Vector2(-4 + i * 3, 7), Color("#5A0F28"), 1)
			draw_circle(pos, 5, Color("#8C1D40"))
			draw_circle(pos + Vector2(1, -1), 3, Color("#E0427A"))
		"Stöckchen":
			# Stöckchen: dreht sich im Flug
			var dir := Vector2(cos(anim_t * 20.0), sin(anim_t * 20.0)) * 7.0
			draw_line(pos - dir, pos + dir, Color("#5A3A22"), 3)
			draw_line(pos - dir, pos + dir, Color("#A8784A"), 1)
		"Hautgift":
			draw_circle(pos, 5, Color("#3A5A2A"))
			draw_circle(pos, 4, Color("#9AD85A"))
			_px(pos + Vector2(-1, -2), 2, Color("#E0FFB0"))
			_px(pos + Vector2(-8, 2), 2, Color(GameData.EL.Virus, 0.8))
		"Stibitzen":
			# Beutel mit Knoten
			draw_circle(pos, 5, Color("#4A3A5A"))
			draw_rect(Rect2(pos + Vector2(-2, -8), Vector2(4, 3)), Color("#4A3A5A"))
			_px(pos + Vector2(-1, -1), 2, GameData.COL.sun)
		"Doppelklick":
			for dx in [0, 7]:
				var q := pos + Vector2(dx, 0)
				draw_line(q + Vector2(-6, -5), q, Color.WHITE, 2)
				draw_line(q, q + Vector2(-6, 5), Color.WHITE, 2)
		_:
			# Pixelstrahl: Datenstrahl mit abplatzenden Pixeln
			draw_rect(Rect2(pos - Vector2(12, 3), Vector2(24, 7)), col.darkened(0.5))
			draw_rect(Rect2(pos - Vector2(11, 2), Vector2(22, 5)), col)
			draw_rect(Rect2(pos + Vector2(2, -1), Vector2(8, 2)), Color.WHITE)
			for i in 3:
				_px(pos + Vector2(-16 - i * 6, ((i * 7 + int(anim_t * 30.0)) % 5) - 2), 2, Color(col, 0.7))


## Schilde: Firewall als glühende Mauer, Kopierschutz als Sechseck, Konter als gekreuzte Klingen
func _draw_shield(body: Vector2) -> void:
	match st.shield_kind:
		"firewall":
			# Grünes Hexagon um den Glitchling (Spieltest 09.10.2026, vorher Mauer mit Flammen), passt sich der Größe an
			var hgt: float = sprite(run.form).n * (BABY_SCALE if run.stage == 1 else 1)
			var cen := Vector2(roundi(body.x), roundi(body.y + 24 - hgt * 0.45))
			var rad := roundf(maxf(26.0, hgt * 0.62))
			var pulse := 0.5 + 0.5 * sin(anim_t * 5.0)
			var code: Color = GameData.EL.Code
			var pts := PackedVector2Array()
			for i in 6:
				var a := PI / 6.0 + i * PI / 3.0
				pts.append((cen + Vector2(cos(a), sin(a)) * rad).round())
			draw_colored_polygon(pts, Color(code, 0.10 + 0.06 * pulse))
			var inner := PackedVector2Array()
			for q in pts:
				inner.append((cen + (q - cen) * 0.84).round())
			inner.append(inner[0])
			draw_polyline(inner, Color(code, 0.3), 1.0)
			var outer := pts.duplicate()
			outer.append(pts[0])
			draw_polyline(outer, Color(code.lightened(0.25), 0.75 + 0.25 * pulse), 2.0)
			for q in pts:
				_px(q, 3, code.lightened(0.5))
			# ein Lichtpunkt läuft am Rand entlang
			var seg := fmod(anim_t * 2.5, 6.0)
			var i0 := int(seg)
			_px(pts[i0].lerp(pts[(i0 + 1) % 6], seg - i0).round(), 3, Color.WHITE)
		"lock":
			draw_circle(body, 28, Color(GameData.EL.Code, 0.12))
			draw_arc(body, 30, anim_t, anim_t + TAU, 7, GameData.EL.Code, 2)
			var lq := body + Vector2(0, -36)
			draw_arc(lq + Vector2(0, -2), 4, PI, TAU, 8, GameData.EL.Code, 2)
			draw_rect(Rect2(lq.x - 5, lq.y - 2, 10, 7), GameData.EL.Code)
			_px(lq + Vector2(0, 1), 2, GameData.COL.dark)
		"konter":
			var glint := 0.6 + 0.4 * sin(anim_t * 20.0)
			draw_line(body + Vector2(16, -18), body + Vector2(32, 10), Color(1, 1, 1, glint), 2)
			draw_line(body + Vector2(16, 10), body + Vector2(32, -18), Color(1, 1, 1, glint), 2)
			_px(body + Vector2(24, -4), 4, Color(GameData.COL.sun, glint))
		_:
			for i in 12:
				var a0 := i * TAU / 12.0 + anim_t * 2.0
				draw_arc(body, 30, a0, a0 + TAU / 24.0, 3, GameData.EL.Code, 2)


func _draw_vfx() -> void:
	for v in st.vfx:
		var k: float = 1.0 - v.t / v.max
		var a: float = clampf(v.t / v.max * 1.6, 0.0, 1.0)
		if v.has("delay"):
			var run_t: float = v.max - v.t
			if run_t < v.delay:
				continue
			k = clampf((run_t - v.delay) / maxf(0.01, v.max - v.delay), 0.0, 1.0)
		var cen := _vc(v.c, v.r)
		var rng := RandomNumberGenerator.new()
		rng.seed = v.seed
		match v.kind:
			"slash":
				var col: Color = GameData.EL[v.el] if v.el != "Neutral" else Color("#CFF6FF")
				var sc := Vector2(gx(3), feet_y(v.r) - 22)
				var sweep := minf(1.0, k * 2.5)
				draw_arc(sc, 42, -1.2, -1.2 + 2.4 * sweep, 16, Color(col, a), 4)
				draw_arc(sc, 37, -1.0, -1.0 + 2.0 * sweep, 14, Color(1, 1, 1, a), 2)
			"beam":
				var y := feet_y(v.r) - 22
				var x0 := gx(v.c) + CW / 2.0 + 18
				var x1 := gx(6)
				var col: Color = GameData.COL.mint if v.get("debug", false) else GameData.EL.Code
				var w := 7.0 * a + (2.0 if fmod(anim_t, 0.06) < 0.03 else 0.0)
				draw_rect(Rect2(x0, y - w / 2.0, x1 - x0, w), Color(col, 0.6 * a))
				draw_rect(Rect2(x0, y - 1, x1 - x0, 3), Color(1, 1, 1, a))
				if v.get("debug", false):
					var glyphs := ["{", "}", "0", "1", ";", "#"]
					for i in 6:
						_text(Vector2(x0 + 16 + i * 48 + k * 24, y - 7), glyphs[i], 8, Color(col, a), HORIZONTAL_ALIGNMENT_LEFT, -1, false)
			"bolt_col":
				var x := gx(v.c) + CW / 2.0
				_zigzag(Vector2(x, Y0 - 34), Vector2(x, feet_y(2) - 4), v.seed, Color(GameData.EL.Elektro, a), 4.0, 10)
				_zigzag(Vector2(x, Y0 - 34), Vector2(x, feet_y(2) - 4), v.seed, Color(1, 1, 1, a), 2.0, 10)
			"strike":
				var wd := 2.0 if v.get("small", false) else 4.0
				_zigzag(Vector2(cen.x, Y0 - 40), cen, v.seed, Color(GameData.EL.Elektro, a), wd, 6)
				_zigzag(Vector2(cen.x, Y0 - 40), cen, v.seed, Color(1, 1, 1, a), 1.0, 6)
				draw_circle(cen, 8 * a, Color(1, 1, 0.8, 0.6 * a))
			"chain":
				var pcen := _vc(v.pc, v.pr)
				_zigzag(pcen, cen, v.seed, Color(GameData.EL.Elektro, a), 3.0, 9)
				_zigzag(pcen, cen, v.seed, Color(1, 1, 1, a), 1.0, 9)
			"wave_row":
				var y := feet_y(v.r)
				var x0 := gx(v.c) + CW * 0.5
				var front := lerpf(x0, gx(6), k)
				draw_rect(Rect2(x0, y - 14, maxf(0, front - x0), 14), Color(GameData.EL.Wasser, 0.4 * a))
				for i in 8:
					var hh := 28.0 * (1.0 - i / 9.0)
					draw_rect(Rect2(front - i * 4 - 4, y - hh, 4, hh), Color(GameData.EL.Wasser, a))
					draw_rect(Rect2(front - i * 4 - 4, y - hh, 4, 2), Color(1, 1, 1, a))
			"tsunami":
				var top := Y0 - 16.0
				var bot := feet_y(2)
				var front := lerpf(gx(3) - 30, gx(6), k)
				draw_rect(Rect2(gx(3), top + 24, maxf(0, front - gx(3)), bot - top - 24), Color(GameData.EL.Wasser, 0.35 * a))
				for i in 10:
					var yt := top + i * 4
					draw_rect(Rect2(front - i * 5 - 5, yt, 5, bot - yt), Color(GameData.EL.Wasser, a))
					draw_rect(Rect2(front - i * 5 - 5, yt, 5, 3), Color(1, 1, 1, a))
			"inferno":
				for c in 3:
					for r in 3:
						_flame(Vector2(gx(3 + c) + CW / 2.0, feet_y(r)), k, a, v.seed + c * 3 + r, 3)
			"flames_col":
				for r in 3:
					_flame(Vector2(gx(v.c) + CW / 2.0, feet_y(r)), k, a, v.seed + r)
			"sparkfall":
				for i in 3:
					var x := cen.x - 16 + i * 16
					var y := lerpf(Y0 - 40 - i * 12, feet_y(v.r) - 8, k)
					draw_rect(Rect2(x - 1, y - 10, 3, 10), Color(FIRE_MID, a))
					_px(Vector2(x, y), 4, Color(FIRE_HOT, a))
				if k > 0.8:
					draw_circle(Vector2(cen.x, feet_y(v.r) - 8), 10, Color(FIRE_MID, 0.6 * a))
			"explode":
				var rad := 8.0 + k * 34.0
				draw_circle(cen, rad, Color(FIRE_MID, 0.45 * a))
				draw_circle(cen, rad * 0.6, Color(FIRE_HOT, 0.7 * a))
				draw_arc(cen, rad + 4, 0, TAU, 20, Color(FIRE_DARK, a), 3)
				for i in 6:
					_px(cen + Vector2(cos(i * 1.1) * rad, sin(i * 1.1) * rad * 0.6 - k * 12), 5, Color(0.3, 0.28, 0.3, 0.6 * a))
			"ice":
				var grow := minf(1.0, k * 4.0)
				for i in 6:
					var ang := i * TAU / 6.0 + 0.3
					var q := cen + Vector2(cos(ang), sin(ang)) * (18.0 + (i % 2) * 6.0)
					_diamond(q, (4.0 + (i % 3) * 2.0) * grow, Color(ICE, a), Color(1, 1, 1, a))
			"swirl":
				for j in 3:
					var a0 := anim_t * (7.0 - j * 2) + j
					draw_arc(cen, 6.0 + j * 8.0, a0, a0 + 3.6, 12, Color(GameData.EL.Wasser.lightened(0.2 * j), a), 2)
			"portal":
				var fp := Vector2(cen.x, feet_y(v.r) - 2)
				draw_set_transform(off + fp, 0, Vector2(1, 0.35))
				draw_circle(Vector2.ZERO, 30, Color(0.06, 0.0, 0.12, 0.7 * a))
				for j in 3:
					var a1 := anim_t * 5.0 + j * 2.0
					draw_arc(Vector2.ZERO, 30.0 - j * 8.0, a1, a1 + 4.5, 16, Color(GameData.EL.Virus.lightened(j * 0.2), a), 3)
				draw_set_transform(off)
			"flash":
				var rad := 10.0 + 70.0 * k
				draw_circle(cen, rad, Color(1, 1, 1, 0.5 * a))
				for i in 8:
					var dir := Vector2(cos(i * TAU / 8.0), sin(i * TAU / 8.0))
					draw_line(cen + dir * rad * 0.5, cen + dir * (rad + 14), Color(1, 1, 0.8, a), 2)
			"blackout":
				draw_rect(Rect2(gx(3) - 8, Y0 - 50, gx(6) - gx(3) + 16, 3 * CH + 60), Color(0.02, 0.01, 0.06, 0.65 * a))
				for i in 8:
					if fmod(anim_t * 12.0 + i, 2.0) < 1.0:
						_px(cen + Vector2(rng.randf_range(-26, 26), rng.randf_range(-30, 12)), 2, Color(GameData.EL.Elektro, a))
					else:
						rng.randf()
						rng.randf()
			"magnet":
				var pcen := _vc(v.pc, v.pr)
				for j in 3:
					var mid := (pcen + cen) / 2.0 + Vector2(0, -24 - j * 12)
					var prev := pcen
					for s in range(1, 13):
						var t := s / 12.0
						var q := pcen.lerp(mid, t).lerp(mid.lerp(cen, t), t)
						if (s + int(anim_t * 20.0)) % 2 == 0:
							draw_line(prev.round(), q.round(), Color(GameData.EL.Elektro, a), 2)
						prev = q
			"toxic":
				for i in 7:
					var t2 := fmod(k * 1.4 + i * 0.13, 1.0)
					var q := cen + Vector2(rng.randf_range(-22, 22), 12 - t2 * 42)
					var s := 2.0 + rng.randi_range(0, 3)
					draw_arc(q, s, 0, TAU, 8, Color(GameData.EL.Virus.lightened(0.3), a), 1)
					_px(q + Vector2(-1, -1), 1, Color(1, 1, 1, a))
			"patch":
				if k < 0.35:
					var t2 := k / 0.35
					_bandage(cen + Vector2(-34, -44) * (1.0 - t2), 1.0)
				else:
					var t3 := (k - 0.35) / 0.65
					_bandage(cen + Vector2(0, -2), a)
					for i in 3:
						_plus(cen + Vector2(-16 + i * 16, -14 - t3 * 30 - i * 4), 3, Color(GameData.COL.mint, a))
				draw_arc(cen, 20 + k * 10, 0, TAU, 20, Color(GameData.COL.mint, 0.5 * a), 1)
			"reboot":
				var rot := k * TAU * 1.5
				draw_arc(cen, 20, rot, rot + 4.6, 24, Color(GameData.COL.mint, a), 3)
				_px(cen + Vector2(cos(rot + 4.6), sin(rot + 4.6)) * 20, 7, Color(GameData.COL.mint, a))
				if k < 0.2:
					draw_circle(cen, 30, Color(1, 1, 1, 0.4 * (1.0 - k / 0.2)))
			"overclock":
				for i in 5:
					var y := cen.y - 18 + i * 8
					var x := cen.x - 28 - fmod(k * 120.0 + i * 17.0, 40.0)
					draw_rect(Rect2(x, y, 18 + (i % 3) * 6, 2), Color(GameData.EL.Feuer, a))
				var g := cen + Vector2(0, -36)
				for i in 8:
					var ang := i * TAU / 8.0 + anim_t * 6.0
					_px(g + Vector2(cos(ang), sin(ang)) * 8, 3, Color(GameData.EL.Feuer, a))
				draw_circle(g, 6, Color(GameData.EL.Feuer, a))
				draw_circle(g, 2, Color(GameData.COL.dark, a))
			"defrag":
				var cols := [GameData.EL.Feuer, GameData.EL.Wasser, GameData.EL.Code, GameData.EL.Elektro, GameData.EL.Virus, GameData.COL.mint]
				var t2 := clampf(k * 1.6, 0.0, 1.0)
				t2 = t2 * t2 * (3.0 - 2.0 * t2)
				for i in 6:
					var start := cen + Vector2(rng.randf_range(-40, 40), rng.randf_range(-50, 10))
					var q := start.lerp(cen + Vector2(-25 + i * 10, -38), t2).round()
					draw_rect(Rect2(q - Vector2(4, 4), Vector2(8, 8)), Color(GameData.COL.dark, a))
					draw_rect(Rect2(q - Vector2(3, 3), Vector2(6, 6)), Color(cols[i], a))
			"scan":
				var rr := 20.0 + k * 320.0
				draw_arc(cen, rr, -0.5, 0.5, 20, Color(GameData.EL.Code, a), 2)
				draw_arc(cen, rr * 0.8, -0.4, 0.4, 16, Color(GameData.EL.Code, a * 0.5), 1)
				if k > 0.55:
					var ec: Vector2 = _vc(3 + st.e.c, st.e.r)
					draw_arc(ec, 16, 0, TAU, 16, Color(GameData.EL.Code, a), 1)
					draw_rect(Rect2(ec.x - 22, ec.y, 44, 1), Color(GameData.EL.Code, a))
					draw_rect(Rect2(ec.x, ec.y - 22, 1, 44), Color(GameData.EL.Code, a))
			"charge":
				for i in 8:
					var t2 := fmod(k * 2.0 + i * 0.125, 1.0)
					var q := cen + Vector2(rng.randf_range(-20, 20), 10 - t2 * 50)
					_px(q, 2 + (i % 2), Color(GameData.EL.Elektro, a * (1.0 - t2)))
				draw_arc(cen, 24 - k * 8, 0, TAU, 20, Color(GameData.EL.Elektro, a), 2)
			"jump":
				var fp := Vector2(cen.x, feet_y(v.r))
				for i in 3:
					var y := fp.y - 8 - i * 9 - k * 14
					draw_line(Vector2(fp.x - 7, y + 5), Vector2(fp.x, y), Color(GameData.COL.mint, a), 2)
					draw_line(Vector2(fp.x, y), Vector2(fp.x + 7, y + 5), Color(GameData.COL.mint, a), 2)
			"shieldup":
				var col: Color = GameData.EL[v.el] if v.el != "Neutral" else GameData.COL.sun
				draw_arc(cen, 14 + k * 22, PI / 6.0, PI / 6.0 + TAU, 6, Color(col, a), 3)
			"spawn":
				for i in 8:
					var ang := i * TAU / 8.0
					_px(cen + Vector2(-22, -24) + Vector2(cos(ang), sin(ang)) * (4 + k * 16), 3, Color(GameData.EL.Code, a))
			"erupt":
				var fp := Vector2(cen.x, feet_y(v.r) - 6)
				var slime: bool = v.get("slime", false)
				var hk: String = v.get("kind", "slime" if slime else "lava")
				var c1: Color = {"slime": SLIME_MID, "current": WATER_MID, "spark": VOLT_MID, "thorn": THORN_MID}.get(hk, LAVA_GLOW)
				var c2: Color = {"slime": SLIME_LIGHT, "current": WATER_LIGHT, "spark": VOLT_HOT, "thorn": THORN_LIGHT}.get(hk, LAVA_HOT)
				if hk in ["lava", "spark"] and k < 0.3:
					draw_circle(fp, 10 + k * 40, Color(c2, 0.5 * (1.0 - k / 0.3)))
				for i in 7:
					var ang := -PI * (0.15 + 0.7 * i / 6.0) + rng.randf_range(-0.15, 0.15)
					var sp := rng.randf_range(40.0, 70.0) * (0.6 if slime else 1.0)
					var q := fp + Vector2(cos(ang) * sp * k, sin(ang) * sp * k + 60.0 * k * k)
					_px(q, 4 if i % 2 == 0 else 3, Color(c1 if i % 3 else c2, a))
			"drop":
				var fp := Vector2(cen.x, feet_y(v.r) - 4)
				if k < 0.6:
					var q := Vector2(fp.x, lerpf(Y0 - 40, fp.y, k / 0.6))
					_px(q, 8, GameData.EL.Virus.darkened(0.4))
					_px(q, 4, GameData.EL.Virus)
				else:
					draw_arc(fp, 6 + (k - 0.6) * 40, 0, TAU, 16, Color(GameData.EL.Virus, a), 2)


# ---------- Flächeneffekte und Zustände (05.10.2026, Tester-Feedback: „bei Lava ein Riss und dann Lava statt nur das !“) ----------

const LAVA_CRUST := Color("#4A140B")
const LAVA_GLOW := Color("#FF7A1F")
const LAVA_HOT := Color("#FFD24D")
const THORN_DARK := Color("#2A4519")
const THORN_MID := Color("#7CC444")
const THORN_LIGHT := Color("#E2F7A8")
const THORN_BERRY := Color("#E8486A")
const SLIME_DARK := Color("#2F5E22")
const SLIME_MID := Color("#5FA83E")
const SLIME_LIGHT := Color("#A8F07A")
const WATER_DARK := Color("#123A66")
const WATER_MID := Color("#2E7FC4")
const WATER_LIGHT := Color("#8FE3FF")
const VOLT_DARK := Color("#4A3C0E")
const VOLT_MID := Color("#E8C230")
const VOLT_HOT := Color("#FFF6A8")


## Feste Zufallsformen je Feld (Risse, Adern, Pfützen), damit nichts flackert
func _cell_rng(cell: Vector2i, salt: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = cell.x * 7919 + cell.y * 104729 + salt
	return rng


## Pixelig abgerundetes Rechteck
func _blob_rect(r: Rect2, col: Color, cut := 3.0) -> void:
	draw_rect(Rect2(r.position.x + cut, r.position.y, r.size.x - cut * 2, r.size.y), col)
	draw_rect(Rect2(r.position.x, r.position.y + cut, r.size.x, r.size.y - cut * 2), col)


## Warnung vor Lava (Risse, die immer heller glühen) bzw. Schleim (blubbernde, wachsende Pfütze)
func _draw_ground_warn(rect: Rect2, k: float, kind: String, cell: Vector2i, dir := 1) -> void:
	var slime := kind == "slime"
	var c := rect.get_center() + Vector2(0, 4)
	var danger := 0.35 + 0.35 * k * (0.6 + 0.4 * sin(anim_t * 26.0))
	draw_rect(rect, Color(GameData.COL.coral, 0.10 + 0.12 * k))
	draw_rect(rect, Color(GameData.COL.coral, danger), false, 1)
	if kind == "current":
		# Strömung: Wasser steigt, Pfeile zeigen, wohin es dich reißt
		var lvl := (rect.size.y - 6) * (0.2 + 0.7 * k)
		draw_rect(Rect2(rect.position.x + 3, rect.end.y - 3 - lvl, rect.size.x - 6, lvl), Color(WATER_MID, 0.3 + 0.35 * k))
		draw_line(Vector2(rect.position.x + 3, rect.end.y - 3 - lvl), Vector2(rect.end.x - 3, rect.end.y - 3 - lvl), Color(WATER_LIGHT, 0.6 + 0.4 * k), 1)
		for i in 2:
			var off := fposmod(anim_t * 30.0 * dir + i * rect.size.x / 2.0, rect.size.x - 20) + 10
			_chevron(Vector2(rect.position.x + off, c.y), dir, Color(WATER_LIGHT, 0.4 + 0.6 * k))
		return
	if kind == "spark":
		# Spannungsfeld: immer mehr Funken zucken über das Feld
		var rng3 := _cell_rng(cell, 17)
		draw_rect(rect.grow(-3), Color(VOLT_MID, 0.08 + 0.2 * k))
		draw_rect(rect, Color(VOLT_MID, 0.3 + 0.5 * k), false, 1)
		for i in 2 + int(k * 3.0):
			var a := c + Vector2(rng3.randf_range(-22, 22), rng3.randf_range(-13, 13))
			var b := a + Vector2(rng3.randf_range(-16, 16), rng3.randf_range(-10, 10))
			var on := sin(anim_t * 40.0 + i * 2.0) > -0.3
			_zigzag(a, b, int(anim_t * 20.0) + i, Color(VOLT_HOT, (0.5 + 0.5 * k) * (1.0 if on else 0.35)), 1.0, 4)
		draw_circle(c, 2.0 + 4.0 * k, Color(VOLT_HOT, 0.4 + 0.5 * k))
		return
	if kind == "thorn":
		# Dornenranken: Triebe brechen aus dem Boden und wachsen
		var rng4 := _cell_rng(cell, 23)
		for i in 4:
			var x := rect.position.x + 14 + i * (rect.size.x - 28) / 3.0 + rng4.randf_range(-4, 4)
			var h := 3.0 + 14.0 * k
			draw_line(Vector2(roundi(x), rect.end.y - 6), Vector2(roundi(x + sin(i * 2.0) * 3.0), roundi(rect.end.y - 6 - h)), Color(THORN_MID, 0.6 + 0.4 * k), 2.0)
		return
	if slime:
		var rad := 4.0 + 17.0 * k
		draw_circle(c, rad + 1, Color(SLIME_DARK.darkened(0.4), 0.8))
		draw_circle(c, rad, Color(SLIME_DARK, 0.9))
		draw_circle(c + Vector2(-2, -2), rad * 0.6, Color(SLIME_MID, 0.8))
		var rng := _cell_rng(cell, 3)
		for i in 4:
			var t2 := fmod(anim_t * 1.6 + i * 0.27, 1.0)
			var q := c + Vector2(rng.randf_range(-rad, rad) * 0.7, -t2 * 14.0)
			draw_arc(q, 1.5 + t2 * 2.0, 0, TAU, 8, Color(SLIME_LIGHT, 1.0 - t2), 1)
		return
	# Lava: Risse wachsen vom Feldmittelpunkt aus und glühen immer heller
	var rng2 := _cell_rng(cell, 11)
	var glow := LAVA_GLOW.lerp(LAVA_HOT, clampf((k - 0.5) * 2.0, 0.0, 1.0))
	for b in 4:
		var ang := b * TAU / 4.0 + rng2.randf_range(-0.6, 0.6)
		var pts: Array = [c]
		var q := c
		for s in 5:
			ang += rng2.randf_range(-0.7, 0.7)
			q += Vector2(cos(ang), sin(ang) * 0.55) * rng2.randf_range(5.0, 8.0)
			q.x = clampf(q.x, rect.position.x + 3, rect.end.x - 3)
			q.y = clampf(q.y, rect.position.y + 3, rect.end.y - 3)
			pts.append(q)
		var shown := int(ceil(k * 1.3 * (pts.size() - 1)))
		for s in mini(shown, pts.size() - 1):
			draw_line(pts[s].round(), pts[s + 1].round(), Color("#1A0805"), 4)
			draw_line(pts[s].round(), pts[s + 1].round(), Color(glow, 0.5 + 0.5 * k), 2 if k > 0.5 else 1)
	draw_circle(c, 2.0 + 4.0 * k, Color(glow, 0.5 + 0.5 * k))
	if k > 0.45:
		for i in 3:
			var t3 := fmod(anim_t * 2.2 + i * 0.33, 1.0)
			_px(c + Vector2(-12 + i * 12, -t3 * 22.0), 2, Color(LAVA_HOT, 1.0 - t3))


## Lavapfütze: glühende Fläche mit treibenden dunklen Krustenschollen und platzenden Blasen; kühlt am Ende grau ab
func _draw_lava_pool(rect: Rect2, hz: Dictionary) -> void:
	var cool := clampf(1.0 - hz.t / 0.8, 0.0, 1.0)
	var fade := minf(1.0, hz.t / 0.3)
	var inner := rect.grow(-3)
	var grey := Color("#4A4242")
	var pulse := 0.85 + 0.15 * sin(anim_t * 4.0 + hz.c)
	_blob_rect(inner, Color(Color("#8A220E").lerp(grey.darkened(0.3), cool), fade))
	_blob_rect(inner.grow(-2), Color(Color("#E2501A").lerp(grey, cool), fade))
	_blob_rect(inner.grow(-6), Color(Color("#FF8A2E").lerp(grey, cool), pulse * fade))
	var rng := _cell_rng(Vector2i(hz.c, hz.r), hz.get("seed", 0))
	# Krustenschollen treiben langsam
	for i in 5:
		var w := rng.randf_range(10.0, 18.0)
		var h := rng.randf_range(6.0, 10.0)
		var px := inner.position.x + 4 + fposmod(rng.randf_range(0, inner.size.x) + anim_t * rng.randf_range(2.0, 5.0), inner.size.x - w - 8)
		var py := inner.position.y + 4 + rng.randf_range(0, inner.size.y - h - 8)
		var plate := Rect2(roundi(px), roundi(py), roundi(w), roundi(h))
		_blob_rect(plate, Color(LAVA_CRUST.lerp(grey.darkened(0.2), cool), fade), 2.0)
		draw_rect(Rect2(plate.position.x + 2, plate.position.y, plate.size.x - 4, 1), Color(Color("#7A3A22").lerp(grey, cool), fade))
	if cool < 0.6:
		# heiße Stellen und platzende Blasen
		for b in 3:
			var bp := Vector2(rng.randf_range(inner.position.x + 8, inner.end.x - 8), rng.randf_range(inner.position.y + 7, inner.end.y - 6))
			var t2 := fmod(anim_t * 0.9 + b * 0.37, 1.0)
			if t2 < 0.8:
				draw_circle(bp, 1.0 + t2 * 4.0, Color(LAVA_HOT, fade))
			else:
				draw_arc(bp, 5.0 + (t2 - 0.8) * 20.0, 0, TAU, 10, Color(LAVA_HOT, (1.0 - t2) * 5.0 * fade), 1)
		for i in 2:
			var t3 := fmod(anim_t * 1.3 + i * 0.5 + hz.c * 0.2, 1.0)
			_px(Vector2(inner.position.x + 14 + i * 40, inner.position.y + 6 - t3 * 26.0), 2, Color(LAVA_HOT, (1.0 - t3) * fade))


## Strömung (Kühlwasser-See): Wasserfläche mit Wellen, die in Strömungsrichtung ziehen
func _draw_current_pool(rect: Rect2, hz: Dictionary) -> void:
	var fade := minf(1.0, hz.t / 0.5)
	var dir: int = int(hz.get("dir", 1))
	var inner := rect.grow(-3)
	_blob_rect(inner, Color(WATER_DARK, 0.9 * fade))
	_blob_rect(inner.grow(-2), Color(WATER_MID, 0.8 * fade))
	for row in 3:
		var y := roundf(inner.position.y + 8 + row * (inner.size.y - 16) / 2.0)
		for i in 3:
			var x := roundf(inner.position.x + 6 + fposmod(anim_t * 26.0 * dir + i * inner.size.x / 3.0 + row * 9.0, inner.size.x - 12))
			draw_line(Vector2(x - 5, y), Vector2(x, y - 2), Color(WATER_LIGHT, 0.8 * fade), 1)
			draw_line(Vector2(x, y - 2), Vector2(x + 5, y), Color(WATER_LIGHT, 0.8 * fade), 1)
	_chevron(inner.get_center() + Vector2(dir * 6, 0), dir, Color(1, 1, 1, 0.75 * fade))


## Spannungsfeld (Hochspannungs-Steppe): glühende Platte mit zuckenden Blitzen; „x2“ = Chips laden hier doppelt so schnell
func _draw_spark_pool(rect: Rect2, hz: Dictionary) -> void:
	var fade := minf(1.0, hz.t / 0.5)
	var inner := rect.grow(-3)
	var pulse := 0.6 + 0.4 * absf(sin(anim_t * 9.0 + hz.c))
	_blob_rect(inner, Color(VOLT_DARK, 0.85 * fade))
	_blob_rect(inner.grow(-3), Color(VOLT_MID, 0.35 * pulse * fade))
	var rng := _cell_rng(Vector2i(hz.c, hz.r), hz.get("seed", 0))
	var live := int(anim_t * 9.0) % 3
	for i in 3:
		var a := Vector2(rng.randf_range(inner.position.x + 4, inner.end.x - 4), rng.randf_range(inner.position.y + 4, inner.end.y - 4))
		var b := Vector2(rng.randf_range(inner.position.x + 4, inner.end.x - 4), rng.randf_range(inner.position.y + 4, inner.end.y - 4))
		_zigzag(a, b, int(anim_t * 15.0) * 3 + i, Color(VOLT_HOT, fade * (1.0 if i == live else 0.4)), 2.0 if i == live else 1.0, 5)
	for i in 4:
		var ph := fmod(anim_t * 1.7 + i * 0.25, 1.0)
		_px(Vector2(inner.position.x + 6 + i * (inner.size.x - 12) / 3.0, inner.end.y - 4 - ph * 14.0), 2, Color(VOLT_HOT, (1.0 - ph) * fade))
	_text(Vector2(inner.end.x - 20, inner.position.y + 13), "x2", 8, Color(VOLT_HOT, fade), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)


## Richtungspfeil aus Pixeln (">" bzw. "<")
func _chevron(q: Vector2, dir: int, col: Color, s := 2.0) -> void:
	for i in 4:
		_px(q + Vector2(-dir * i * s, -i * s), s, col)
		_px(q + Vector2(-dir * i * s, i * s), s, col)


## Giftschleim: unregelmäßige Pfütze aus Kreisen mit Blasen und Glanzlichtern
## Dornenranken (Cache-Wiesen, 09.10.2026): Ranken mit Dornen und roten Beeren wachsen aus dem Feld und wiegen sich
func _draw_thorn_patch(rect: Rect2, hz: Dictionary) -> void:
	var fade := minf(1.0, hz.t / 0.5)
	var grow := clampf((float(hz.get("max", BattleState.HAZARD_DUR.thorn)) - hz.t) / 0.35, 0.0, 1.0)
	var rng := _cell_rng(Vector2i(hz.c, hz.r), hz.get("seed", 0))
	var base_y := rect.end.y - 6
	draw_rect(rect.grow(-4), Color("#3A2A14", 0.45 * fade))
	for i in 5:
		var x := rect.position.x + 10 + i * (rect.size.x - 20) / 4.0 + rng.randf_range(-4, 4)
		var h := rng.randf_range(16.0, 30.0) * grow
		var sway := sin(anim_t * 2.0 + i) * 2.0
		var prev := Vector2(x, base_y)
		for sg in 5:
			var k := float(sg + 1) / 5.0
			var q := Vector2(x + sin(k * 5.0 + i) * 4.0 + sway * k, base_y - h * k)
			draw_line(prev.round(), q.round(), Color(THORN_DARK, fade), 4.0)
			draw_line(prev.round(), q.round(), Color(THORN_MID, fade), 2.0)
			if sg % 2 == 1:
				var side := 1.0 if sg % 4 == 1 else -1.0
				var tip := (q + Vector2(5.0 * side, -3.0)).round()
				draw_line(q.round(), tip, Color(THORN_DARK, fade), 3.0)
				draw_line(q.round(), tip, Color(THORN_LIGHT, fade), 1.0)
			prev = q
		if h > 18.0:
			_px(prev.round() + Vector2(0, -1), 3, Color(THORN_BERRY, fade))


func _draw_slime_pool(rect: Rect2, hz: Dictionary) -> void:
	var fade := minf(1.0, hz.t / 0.5)
	var cell := Vector2i(hz.c, hz.r)
	var rng := _cell_rng(cell, hz.get("seed", 0))
	var c := rect.get_center() + Vector2(0, 3)
	var blobs: Array = []
	for i in 5:
		blobs.append([c + Vector2(rng.randf_range(-24, 24), rng.randf_range(-9, 9)), rng.randf_range(9.0, 15.0)])
	for bl in blobs:
		draw_circle(bl[0], bl[1] + 1.5, Color(SLIME_DARK.darkened(0.45), 0.9 * fade))
	for bl in blobs:
		draw_circle(bl[0], bl[1], Color(SLIME_DARK, 0.92 * fade))
	for bl in blobs:
		draw_circle(bl[0] + Vector2(-2, -2), bl[1] * 0.55, Color(SLIME_MID, 0.75 * fade))
	for i in 3:
		var bp: Vector2 = blobs[i][0] + Vector2(rng.randf_range(-4, 4), rng.randf_range(-3, 3))
		var t2 := fmod(anim_t * 0.8 + i * 0.31, 1.0)
		if t2 < 0.85:
			draw_arc(bp, 1.0 + t2 * 3.5, 0, TAU, 8, Color(SLIME_LIGHT, fade), 1)
		else:
			_px(bp + Vector2(0, -4), 2, Color(SLIME_LIGHT, fade))
	_px(blobs[0][0] + Vector2(-blobs[0][1] * 0.4, -blobs[0][1] * 0.45), 2, Color(1, 1, 1, 0.7 * fade))
	_px(blobs[3][0] + Vector2(-blobs[3][1] * 0.3, -blobs[3][1] * 0.4), 2, Color(1, 1, 1, 0.5 * fade))


## Zustände sichtbar am Gegner: Brand = Flammen, Gift = Blasen und Tropfen, Langsam = Wasserwirbel, Eis = Kristalle
func _draw_status_fx(ecx: float, efy: float) -> void:
	var e: Dictionary = st.e
	# Betäubte Bosse und Wächter nehmen doppelten Schaden: pulsierendes „x2“ über dem Kopf
	if e.frozen > 0 and st.def.boss:
		var top: float = efy - sprite(st.def.spr).n - 2
		_text(Vector2(ecx - 30, top), GameData.mult_text(GameData.STUN_MULT), 16, Color(GameData.COL.sun, 0.6 + 0.4 * sin(anim_t * 10.0)), HORIZONTAL_ALIGNMENT_CENTER, 60, true, true)
	if e.frozen > 0:
		var rect := cell_rect(3 + e.c, e.r)
		draw_rect(Rect2(rect.position.x + 6, rect.position.y - 36, rect.size.x - 12, rect.size.y + 30), Color(ICE, 0.18))
		for i in 7:
			var ang := i * TAU / 7.0 + 0.4
			var q := Vector2(ecx, efy - 22) + Vector2(cos(ang) * 24.0, sin(ang) * 18.0)
			_diamond(q, 3.0 + (i % 3), Color(ICE, 0.85), Color.WHITE)
	if e.burn > 0:
		for i in 3:
			var fx := ecx - 14 + i * 14
			var h := 8.0 + 5.0 * absf(sin(anim_t * 14.0 + i * 1.7))
			var by := efy - 10 - (i % 2) * 14
			draw_rect(Rect2(roundi(fx - 3), roundi(by - h), 6, roundi(h)), Color(FIRE_DARK, 0.9))
			draw_rect(Rect2(roundi(fx - 2), roundi(by - h * 0.7), 4, roundi(h * 0.7)), Color(FIRE_MID, 0.95))
			draw_rect(Rect2(roundi(fx - 1), roundi(by - h * 0.4), 2, roundi(h * 0.4)), FIRE_HOT)
	if e.poison > 0:
		for i in 4:
			var t2 := fmod(anim_t * 0.9 + i * 0.25, 1.0)
			var q := Vector2(ecx - 16 + i * 11, efy - 14 - t2 * 34.0)
			draw_circle(q, 2.0 + t2 * 2.5, Color(SLIME_MID, 0.8 * (1.0 - t2)))
			draw_arc(q, 2.0 + t2 * 2.5, 0, TAU, 8, Color(SLIME_LIGHT, 1.0 - t2), 1)
		var dr := fmod(anim_t * 1.5, 1.0)
		_px(Vector2(ecx + 8, efy - 18 + dr * 16.0), 2, Color(GameData.EL.Virus, 1.0 - dr))
	if e.slow > 0:
		draw_set_transform(off + Vector2(ecx, efy - 1), 0, Vector2(1, 0.3))
		for j in 2:
			var a0 := anim_t * (4.0 + j * 2.0) + j
			draw_arc(Vector2.ZERO, 22.0 - j * 7.0, a0, a0 + 4.0, 16, Color(GameData.EL.Wasser.lightened(0.2 * j), 0.85), 2)
		draw_set_transform(off)
