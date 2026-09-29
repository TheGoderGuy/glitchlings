extends PixelCanvas
## Station (Hub): Team, Brutnest, Monsterdex. Startet Runs und lässt bereite Eier schlüpfen.

signal start_run(monster_id: int)
signal to_title

enum Tab { TEAM, NEST, DEX }
const TAB_NAMES := ["Team", "Brutnest", "Monsterdex"]
const DEX_ORDER := ["Pixmiez", "Blazebit", "Firewallo", "Virulina", "Prismiez", "Glutluchs", "Bollwerkatz",
	"Funkling", "Glutbyte", "Overclocko", "Magmawulf", "Turbowulf",
	"Tröpfel", "Kaskadi", "Pufferling", "Frostbyte", "Tsunamander", "Panzerpuff",
	"Kekso", "Tracko", "Cachy", "Lumi", "Blinki", "Screenshina", "Holohas",
	"Quakli", "Virulurch", "Hüpfbyte", "Mechaquak", "Molchi", "Toxmolch", "Magmolch",
	"Brummbit", "Sonnbrumm", "Bärtron", "Titanbrumm", "Kauzbit", "Optikauz", "Raketauz", "Radarkauz"]
const HATCH_REVEAL := 2.2
## Vorladen! Texturen, die erst in _draw() zum ersten Mal geladen werden, erscheinen weiß.
const EGG_TEX := {"egg_g": preload("res://assets/sprites/egg_g.png"), "egg_s": preload("res://assets/sprites/egg_s.png"), "egg_e": preload("res://assets/sprites/egg_e.png")}

var tab := Tab.TEAM
var sel := 0
var t_in := 0.0
var hatch := {}          # laufende Schlüpf-Szene
var hatch_t := 0.0
var hatch_egg := {}


func _ready() -> void:
	Music.play("title")
	_check_hatch()


func _check_hatch() -> void:
	var ready := SaveGame.ready_eggs()
	if ready.is_empty():
		hatch = {}
		return
	hatch_egg = ready[0].duplicate()
	hatch = SaveGame.hatch_next()
	hatch_t = 0.0
	Sfx.play("charge", 0.0)


func _process(delta: float) -> void:
	anim_t += delta
	t_in += delta
	if not hatch.is_empty():
		hatch_t += delta
		if hatch_t - delta < HATCH_REVEAL and hatch_t >= HATCH_REVEAL:
			Sfx.play("evolve", 0.0)
		if hatch_t > HATCH_REVEAL + 0.6 and Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			_check_hatch()
			if hatch.is_empty():
				tab = Tab.TEAM
				sel = SaveGame.team().size() - 1
		queue_redraw()
		return
	if t_in < 0.2:
		queue_redraw()
		return
	if Input.is_action_just_pressed("tab_next"):
		tab = ((tab + 1) % 3) as Tab
		sel = 0
		Sfx.play("select")
	elif Input.is_action_just_pressed("tab_prev"):
		tab = ((tab + 2) % 3) as Tab
		sel = 0
		Sfx.play("select")
	elif Input.is_action_just_pressed("back") or Input.is_action_just_pressed("pause"):
		Sfx.play("back")
		set_process(false)
		to_title.emit()
	else:
		match tab:
			Tab.TEAM:
				var n := SaveGame.team().size()
				_nav_v(n)
				if Input.is_action_just_pressed("confirm") and n > 0:
					Sfx.play("confirm")
					set_process(false)
					start_run.emit(int(SaveGame.team()[sel].id))
			Tab.DEX:
				var n := DEX_ORDER.size()
				if Input.is_action_just_pressed("move_right"):
					sel = (sel + 1) % n
					Sfx.play("select")
				elif Input.is_action_just_pressed("move_left"):
					sel = (sel + n - 1) % n
					Sfx.play("select")
				elif Input.is_action_just_pressed("move_down"):
					sel = (sel + 6) % n
					Sfx.play("select")
				elif Input.is_action_just_pressed("move_up"):
					sel = (sel + n - 6) % n
					Sfx.play("select")
	queue_redraw()


func _nav_v(n: int) -> void:
	if n == 0:
		return
	if Input.is_action_just_pressed("move_down"):
		sel = (sel + 1) % n
		Sfx.play("select")
	elif Input.is_action_just_pressed("move_up"):
		sel = (sel + n - 1) % n
		Sfx.play("select")


# ---------- Zeichnen ----------

func _draw() -> void:
	_draw_zone("wiesen")
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.45))
	_draw_tabs()
	match tab:
		Tab.TEAM:
			_draw_team()
		Tab.NEST:
			_draw_nest()
		Tab.DEX:
			_draw_dex()
	var pad: bool = InputSetup.pad
	var hint := "%s/%s Reiter   %s zurück zum Titel" % ["LB" if pad else "Q", "RB" if pad else "E", "B" if pad else "Esc"]
	_text(Vector2(0, H - 8), hint, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	if not hatch.is_empty():
		_draw_hatch()


func _draw_tabs() -> void:
	_text(Vector2(12, 22), "STATION", 16, GameData.COL.mint, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var x := 150.0
	for i in 3:
		var w := text_width(TAB_NAMES[i], 8, true) + 20
		var r := Rect2(x, 8, w, 18)
		var active := i == tab
		_box(r, GameData.COL.panel if active else Color(GameData.COL.bg2, 0.9), GameData.COL.sun if active else GameData.COL.line)
		_text(Vector2(r.position.x, r.position.y + 13), TAB_NAMES[i], 8, GameData.COL.ink if active else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, w, true, active)
		x += w + 4
	var st: Dictionary = SaveGame.data.get("stats", {})
	_text(Vector2(0, 21), "Runs %d · Siege %d · Dex %d/%d " % [int(st.get("runs", 0)), int(st.get("wins", 0)), SaveGame.dex_count(), DEX_ORDER.size()], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, W - 8)


func _draw_team() -> void:
	var team := SaveGame.team()
	# Liste links
	var L := Rect2(8, 34, 170, 306)
	_box(L, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	var first := clampi(sel - 12, 0, maxi(0, team.size() - 14))
	for i in range(first, mini(team.size(), first + 14)):
		var m: Dictionary = team[i]
		var r := Rect2(L.position.x + 4, L.position.y + 4 + (i - first) * 21, L.size.x - 8, 19)
		var active := i == sel
		var el: Color = GameData.EL[GameData.FORMS[m.form].el]
		_box(r, GameData.COL.panel.lightened(0.08) if active else GameData.COL.bg2, GameData.COL.sun if active else GameData.COL.line)
		draw_rect(Rect2(r.position + Vector2(5, 6), Vector2(7, 7)), el)
		_text(Vector2(r.position.x + 17, r.position.y + 13), m.form, 8, GameData.COL.ink if active else GameData.COL.muted, HORIZONTAL_ALIGNMENT_LEFT, -1, true, active)
		_text(Vector2(r.position.x, r.position.y + 13), GameData.STAGE_NAMES[int(m.stage)], 8, el, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 6)
	if team.is_empty():
		return
	var m: Dictionary = team[sel]
	var form: String = m.form
	var F: Dictionary = GameData.FORMS[form]
	var M: Dictionary = GameData.MONS[m.species]
	var el: Color = GameData.EL[F.el]
	var R := Rect2(186, 34, 446, 306)
	_box(R, Color(GameData.COL.panel, 0.92), el.darkened(0.35))
	# Monster auf Plattform
	var cx := R.position.x + 90
	draw_rect(Rect2(cx - 44, R.position.y + 152, 88, 6), Color(0.05, 0.02, 0.12, 0.4))
	var sc := 2 if int(m.stage) == 1 else 1
	_draw_sprite(form, cx, R.position.y + 154, false, {"scale": sc, "bob": 1 if sin(anim_t * 4.0) > 0 else 0, "blink": fmod(anim_t, 3.3) < 0.13})
	_text(Vector2(R.position.x, R.position.y + 176), form, 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, 180, true, true)
	_text(Vector2(R.position.x, R.position.y + 190), "%s · %s · %d HP" % [GameData.STAGE_NAMES[int(m.stage)], F.el, int(M.hp) + 10 * (int(m.stage) - 1)], 8, el, HORIZONTAL_ALIGNMENT_CENTER, 180)
	_text(Vector2(R.position.x, R.position.y + 204), "Runs %d · Siege %d" % [int(m.runs), int(m.wins)], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, 180)
	# Details rechts
	var x := R.position.x + 190
	var w := R.size.x - 204
	var y := R.position.y + 20
	var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	var S: Dictionary = GameData.SPECIALS[form]
	_text(Vector2(x, y), "Signatur: " + S.name, 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	draw_multiline_string(font(), Vector2(x, y + 14), S.desc, HORIZONTAL_ALIGNMENT_LEFT, w, 8, 2, GameData.COL.ink, wrap)
	y += 44
	_text(Vector2(x, y), "Passiv: " + M.passive, 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	draw_multiline_string(font(), Vector2(x, y + 14), M.passive_desc, HORIZONTAL_ALIGNMENT_LEFT, w, 8, 3, GameData.COL.ink, wrap)
	y += 56
	# Lebenszeit-Prägung
	_text(Vector2(x, y), "Prägung (gesamt)", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var total := 0
	for k in m.praeg:
		total += int(m.praeg[k])
	y += 8
	for e in GameData.EL:
		var n := int(m.praeg.get(e, 0))
		_text(Vector2(x, y + 8), e, 8, GameData.EL[e])
		_bar(Rect2(x + 56, y + 1, w - 90, 7), float(n) / maxi(1, total), GameData.EL[e])
		_text(Vector2(x, y + 8), str(n), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, w)
		y += 12
	# Evolution
	var probe := RunState.from_monster(m, 1)
	var need := probe.evo_need()
	y += 8
	if need > 0:
		var tgt := probe.evo_target()
		var ec: Color = GameData.EL[GameData.FORMS[tgt].el] if tgt != "" else GameData.COL.muted
		_text(Vector2(x, y), "Nächste Stufe: %d/%d" % [int(m.chips), need], 8, GameData.COL.ink)
		_text(Vector2(x, y), ("Richtung " + GameData.FORMS[tgt].el) if tgt != "" else "Richtung offen", 8, ec, HORIZONTAL_ALIGNMENT_RIGHT, w)
		_bar(Rect2(x, y + 5, w, 7), float(m.chips) / need, ec)
	else:
		_text(Vector2(x, y), "Höchste Stufe erreicht", 8, GameData.COL.muted)
	var pad: bool = InputSetup.pad
	_text(Vector2(R.position.x, R.end.y - 12), "%s Mit %s in die %s" % ["A" if pad else "Enter", form, "Cache-Wiesen"], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)


func _draw_nest() -> void:
	var R := Rect2(40, 40, 560, 296)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(R.position.x, R.position.y + 22), "Brutnest", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	_text(Vector2(R.position.x, R.position.y + 38), "Eier gibt es nach Runs mit mindestens %d gewonnenen Kämpfen, seltenere nach einem Boss-Sieg." % SaveGame.EGG_MIN_WINS, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)
	var eggs := SaveGame.nest()
	for i in SaveGame.NEST_SLOTS:
		var r := Rect2(R.position.x + 40 + i * 170, R.position.y + 64, 140, 180)
		_box(r, GameData.COL.bg2, GameData.COL.line)
		if i >= eggs.size():
			_text(Vector2(r.position.x, r.get_center().y), "leer", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
			continue
		var e: Dictionary = eggs[i]
		var left := int(e.runs_left)
		var wob := roundi(sin(anim_t * (10.0 if left <= 1 else 4.0) + i) * (2.0 if left <= 1 else 0.0))
		draw_rect(Rect2(r.get_center().x - 26, r.position.y + 112, 52, 4), Color(0.05, 0.02, 0.12, 0.35))
		_draw_egg(e.rarity, Vector2(r.get_center().x + wob, r.position.y + 114), 2)
		var rc := _rarity_col(e.rarity)
		_text(Vector2(r.position.x, r.position.y + 136), "%s Ei" % e.rarity, 8, rc, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
		var txt := "schlüpft nach dem nächsten Run" if left == 1 else ("bereit!" if left <= 0 else "noch %d Runs" % left)
		draw_multiline_string(font(), Vector2(r.position.x + 8, r.position.y + 152), txt, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, 8, 2, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	_text(Vector2(R.position.x, R.end.y - 18), "Gewöhnlich 1 Run · Selten 2 · Episch 3 · Legendär 5", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)


func _draw_dex() -> void:
	var R := Rect2(20, 34, 600, 306)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	# 3 sichtbare Reihen, blättert mit der Auswahl mit
	var first_row := clampi(sel / 6 - 1, 0, maxi(0, (DEX_ORDER.size() - 1) / 6 - 2))
	for i in range(first_row * 6, mini(DEX_ORDER.size(), first_row * 6 + 18)):
		var f: String = DEX_ORDER[i]
		var known: bool = SaveGame.data.get("dex", {}).has(f)
		var cell := Rect2(R.position.x + 8 + (i % 6) * 98, R.position.y + 8 + (i / 6 - first_row) * 96, 94, 92)
		var active := i == sel
		_box(cell, GameData.COL.panel.lightened(0.06) if active else GameData.COL.bg2, GameData.COL.sun if active else GameData.COL.line)
		var F: Dictionary = GameData.FORMS[f]
		var feet := cell.position.y + 77
		if known:
			_draw_sprite(f, cell.get_center().x, feet, false, {"scale": 1, "bob": 1 if active and sin(anim_t * 4.0) > 0 else 0})
		else:
			_draw_sprite(f, cell.get_center().x, feet, false, {"scale": 1, "flash": true, "mod": Color(0.2, 0.17, 0.34, 0.95)})
		_text(Vector2(cell.position.x, cell.end.y - 6), f if known else "???", 8, GameData.EL[F.el] if known else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, cell.size.x)


func _draw_egg(rarity: String, feet: Vector2, scale: int) -> void:
	var tex: Texture2D = EGG_TEX[SaveGame.EGG_SPRITE[rarity]]
	var size := tex.get_width() * scale
	draw_set_transform(Vector2(roundi(feet.x - size / 2.0), roundi(feet.y - size)), 0, Vector2(scale, scale))
	draw_texture(tex, Vector2.ZERO, Color(1, 0.85, 0.6) if rarity == "Legendär" else Color.WHITE)
	draw_set_transform(Vector2.ZERO)


func _rarity_col(r: String) -> Color:
	return {"Gewöhnlich": GameData.COL.ink, "Selten": GameData.EL.Wasser, "Episch": GameData.EL.Virus, "Legendär": GameData.COL.sun}[r]


func _draw_hatch() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.88))
	var c := Vector2(W / 2.0, 220)
	var t := hatch_t
	if t < HATCH_REVEAL:
		# Ei wackelt immer stärker, Lichtstrahlen
		var amp := t * t * 2.0
		var wob := roundi(sin(t * (6.0 + t * 10.0)) * amp)
		for i in 10:
			var a := i * TAU / 10.0 + t
			draw_line(c + Vector2(0, -30), c + Vector2(0, -30) + Vector2(cos(a), sin(a)) * (40.0 + 60.0 * t / HATCH_REVEAL), Color(1, 1, 0.8, 0.12 * t), 2)
		_draw_egg(hatch_egg.get("rarity", "Gewöhnlich"), Vector2(c.x + wob, c.y), 3)
		_text(Vector2(0, 70), "Oh? Ein Ei bewegt sich …", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	else:
		var k := t - HATCH_REVEAL
		if k < 0.25:
			draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k / 0.25))
		var sp: String = hatch.species
		var el: Color = GameData.EL[GameData.MONS[sp].el]
		draw_rect(Rect2(c.x - 50, c.y - 2, 100, 6), Color(0.05, 0.02, 0.12, 0.4))
		_draw_sprite(sp, c.x, c.y, false, {"scale": 3, "bob": 1 if sin(anim_t * 4.0) > 0 else 0, "blink": fmod(anim_t, 3.0) < 0.13})
		_text(Vector2(0, 70), "%s ist geschlüpft!" % sp, 16, el, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		if hatch.new_in_dex:
			_text(Vector2(0, 88), "Neu im Monsterdex!", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		_text(Vector2(0, 250), "%s kommt in dein Team." % sp, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
		if k > 0.6:
			_text(Vector2(0, 290), "%s weiter" % ("A" if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
