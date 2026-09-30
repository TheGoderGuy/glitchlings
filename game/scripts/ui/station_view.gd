extends PixelCanvas
## Station (Hub): Team, Brutnest, Monsterdex. Startet Runs und lässt bereite Eier schlüpfen.

signal start_run(monster_id: int, zone: String)
signal to_title

enum Tab { TEAM, NEST, LAB, DEX, UPGRADE }
const TAB_NAMES := ["Team", "Brutnest", "Labor", "Monsterdex", "Ausbau"]
## Nach Linien: Baby → Rookies → Champions → Ultras, am Ende die Fusionen
const DEX_ORDER := [
	"Pixmiez", "Firewallo", "Virulina", "Prismiez", "Bollwerkatz", "Toxipanth", "Prismalynx", "Bastionkatz", "Venomynx", "Aurorlynx",
	"Funkling", "Glutbyte", "Overclocko", "Magmawulf", "Turbowulf", "Glutfenrir", "Hyperwulf",
	"Tröpfel", "Kaskadi", "Pufferling", "Frostbyte", "Tsunamander", "Panzerpuff", "Glaziolotl", "Leviamander", "Kolosspuff", "Kryolotl",
	"Kekso", "Tracko", "Cachy", "Schattnager", "Glanzbacke", "Phantomnager", "Stellarbacke",
	"Lumi", "Blinki", "Perlhopp", "Strahlhase", "Gischthase", "Plasmahase", "Lunaflut",
	"Quakli", "Virulurch", "Hüpfbyte", "Toxikröt", "Mechaquak", "Miasmakröt", "Gigaquak",
	"Molchi", "Toxmolch", "Magmolch", "Sumpfdrak", "Lavadrak", "Hydradrak", "Vulkandrak",
	"Brummbit", "Pilzbrumm", "Bärtron", "Sporenpranke", "Titanbrumm", "Myzelgrizz", "Kolossbrumm",
	"Kauzbit", "Optikauz", "Raketauz", "Radarkauz", "Phönixkauz", "Orbitkauz", "Infernokauz",
	"Buddli", "Glimmdachs", "Zackdachs", "Magmadachs", "Donnerdachs", "Pyromeles", "Voltameles",
	"Maskli", "Plätschbär", "Klaubär", "Flutmaske", "Nachtmaske", "Hydrocyon", "Virocyon",
	"Wolkerich", "Spukatz", "Wolperling", "Schlummerbit", "Pustebacke"]
const HATCH_REVEAL := 2.2
## Vorladen! Texturen, die erst in _draw() zum ersten Mal geladen werden, erscheinen weiß.
const EGG_TEX := {"egg_g": preload("res://assets/sprites/egg_g.png"), "egg_s": preload("res://assets/sprites/egg_s.png"), "egg_e": preload("res://assets/sprites/egg_e.png")}

var tab := Tab.TEAM
var sel := 0
var t_in := 0.0
var hatch := {}          # laufende Schlüpf-Szene
var hatch_t := 0.0
var hatch_egg := {}
var fuse_sel: Array = []     # IDs der gewählten Labor-Monster (max. 2)
var fuse_msg := ""
var fusion := {}             # laufende Fusions-Szene
var zone_idx := 0            # gewählte Zone im Team-Reiter
var up_msg := ""             # Rückmeldung im Ausbau-Reiter


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
	if not fusion.is_empty():
		hatch_t += delta
		if hatch_t - delta < HATCH_REVEAL and hatch_t >= HATCH_REVEAL:
			Sfx.play("evolve", 0.0)
		if hatch_t > HATCH_REVEAL + 0.6 and Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			fusion = {}
		queue_redraw()
		return
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
		tab = ((tab + 1) % TAB_NAMES.size()) as Tab
		up_msg = ""
		sel = 0
		Sfx.play("select")
	elif Input.is_action_just_pressed("tab_prev"):
		tab = ((tab + TAB_NAMES.size() - 1) % TAB_NAMES.size()) as Tab
		up_msg = ""
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
				var zones := SaveGame.unlocked_zones()
				if zones.size() > 1 and Input.is_action_just_pressed("move_right"):
					zone_idx = (zone_idx + 1) % zones.size()
					Sfx.play("select")
				elif zones.size() > 1 and Input.is_action_just_pressed("move_left"):
					zone_idx = (zone_idx + zones.size() - 1) % zones.size()
					Sfx.play("select")
				if Input.is_action_just_pressed("confirm") and n > 0:
					Sfx.play("confirm")
					set_process(false)
					start_run.emit(int(SaveGame.team()[sel].id), zones[zone_idx % zones.size()])
			Tab.LAB:
				var n := SaveGame.team().size() + 1   # letzte Zeile: „Fusionieren“
				_nav_v(n)
				if Input.is_action_just_pressed("confirm"):
					if sel < SaveGame.team().size():
						var id := int(SaveGame.team()[sel].id)
						if fuse_sel.has(id):
							fuse_sel.erase(id)
						elif fuse_sel.size() < 2:
							fuse_sel.append(id)
						fuse_msg = ""
						Sfx.play("select")
					elif fuse_sel.size() == 2:
						var rng := RandomNumberGenerator.new()
						rng.randomize()
						var res := SaveGame.try_fuse(fuse_sel[0], fuse_sel[1], rng)
						if res.ok:
							fusion = res
							hatch_t = 0.0
							fuse_sel = []
							fuse_msg = ""
							sel = 0
							Sfx.play("charge", 0.0)
						else:
							fuse_msg = res.msg
							Sfx.play("back")
					else:
						fuse_msg = "Wähle zuerst zwei Monster aus."
						Sfx.play("back")
			Tab.UPGRADE:
				_nav_v(GameData.STATION_UPGRADES.size())
				if Input.is_action_just_pressed("confirm"):
					var u: Dictionary = GameData.STATION_UPGRADES[sel]
					var cost := SaveGame.upgrade_cost(u.id)
					if cost < 0:
						up_msg = "%s ist schon ganz ausgebaut." % u.name
						Sfx.play("back")
					elif SaveGame.buy_upgrade(u.id):
						up_msg = "%s ausgebaut: Stufe %d!" % [u.name, SaveGame.upgrade_level(u.id)]
						Sfx.play("evolve", 0.0)
					else:
						up_msg = "Dafür fehlen noch %d Fragmente." % (cost - SaveGame.frag())
						Sfx.play("back")
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
		Tab.LAB:
			_draw_lab()
		Tab.DEX:
			_draw_dex()
		Tab.UPGRADE:
			_draw_upgrades()
	var pad: bool = InputSetup.pad
	var hint := "%s/%s Reiter   %s zurück zum Titel" % ["LB" if pad else "Q", "RB" if pad else "E", "B" if pad else "Esc"]
	_text(Vector2(0, H - 8), hint, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	if not hatch.is_empty():
		_draw_hatch()
	if not fusion.is_empty():
		_draw_fusion()


func _draw_tabs() -> void:
	_text(Vector2(12, 22), "STATION", 16, GameData.COL.mint, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var x := 150.0
	for i in TAB_NAMES.size():
		var w := text_width(TAB_NAMES[i], 8, true) + 20
		var r := Rect2(x, 8, w, 18)
		var active := i == tab
		_box(r, GameData.COL.panel if active else Color(GameData.COL.bg2, 0.9), GameData.COL.sun if active else GameData.COL.line)
		_text(Vector2(r.position.x, r.position.y + 13), TAB_NAMES[i], 8, GameData.COL.ink if active else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, w, true, active)
		x += w + 4
	var st: Dictionary = SaveGame.data.get("stats", {})
	_text(Vector2(0, 36), "Fragmente %d · Dex %d/%d " % [SaveGame.frag(), SaveGame.dex_count(), DEX_ORDER.size()], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_RIGHT, W - 8)


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
	# Entwicklung: mögliche Richtungen mit Lebenszeit-Prägung
	_text(Vector2(x, y), "Entwicklung", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var probe := RunState.from_monster(m, 1)
	_draw_evo(probe.evo_status(), x, y + 4, w)
	var pad: bool = InputSetup.pad
	var zones := SaveGame.unlocked_zones()
	var zname: String = GameData.ZONES[zones[zone_idx % zones.size()]].name
	var arrows := zones.size() > 1
	_text(Vector2(R.position.x, R.end.y - 26), ("< %s >" if arrows else "%s") % zname, 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	_text(Vector2(R.position.x, R.end.y - 12), "%s Mit %s losziehen" % ["A" if pad else "Enter", form], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)


func _draw_upgrades() -> void:
	var R := Rect2(40, 40, 560, 296)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(R.position.x, R.position.y + 22), "Station-Ausbau", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	_text(Vector2(R.position.x, R.position.y + 38), "Fragmente aus deinen Runs machen die Station dauerhaft besser. Du hast %d." % SaveGame.frag(), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)
	var ups: Array = GameData.STATION_UPGRADES
	for i in ups.size():
		var u: Dictionary = ups[i]
		var lv := SaveGame.upgrade_level(u.id)
		var maxlv: int = u.costs.size()
		var cost := SaveGame.upgrade_cost(u.id)
		var active := i == sel
		var r := Rect2(R.position.x + 20, R.position.y + 50 + i * 36, R.size.x - 40, 32)
		_box(r, GameData.COL.panel.lightened(0.08) if active else GameData.COL.bg2, GameData.COL.sun if active else GameData.COL.line)
		_text(Vector2(r.position.x + 10, r.position.y + 13), u.name, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		# Stufen als Kästchen
		for k in maxlv:
			var pr := Rect2(r.position.x + 130 + k * 12, r.position.y + 6, 8, 8)
			draw_rect(pr, GameData.COL.mint if k < lv else GameData.COL.dark)
			draw_rect(pr, GameData.COL.line, false, 1.0)
		var desc: String = GameData.upgrade_desc(u, lv) if cost < 0 else GameData.upgrade_desc(u, lv + 1)
		var prefix := "Jetzt: " if cost < 0 else ("Nächste Stufe: " if lv > 0 else "")
		_text(Vector2(r.position.x + 10, r.position.y + 26), prefix + desc, 8, GameData.COL.muted)
		var price_txt := "ganz ausgebaut" if cost < 0 else "%d Fragmente" % cost
		var pcol: Color = GameData.COL.mint if cost < 0 else (GameData.COL.sun if SaveGame.frag() >= cost else Color(GameData.COL.coral, 0.9))
		_text(Vector2(r.position.x, r.position.y + 13), price_txt, 8, pcol, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 10, true, true)
	var foot := up_msg if up_msg != "" else "%s ausbauen" % ("A" if InputSetup.pad else "Enter")
	_text(Vector2(R.position.x, R.end.y - 10), foot, 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)


func _draw_nest() -> void:
	var R := Rect2(40, 40, 560, 296)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(R.position.x, R.position.y + 22), "Brutnest", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	_text(Vector2(R.position.x, R.position.y + 38), "Eier gibt es nach Runs mit mindestens %d gewonnenen Kämpfen, seltenere nach einem Boss-Sieg." % SaveGame.EGG_MIN_WINS, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)
	var eggs := SaveGame.nest()
	var slots := SaveGame.nest_slots()
	var sw := 140.0 if slots <= 3 else 116.0
	var gap := 170.0 if slots <= 3 else 128.0
	for i in slots:
		var r := Rect2(R.get_center().x - (gap * (slots - 1) + sw) / 2.0 + i * gap, R.position.y + 64, sw, 180)
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
			_draw_sprite(f, cell.get_center().x, feet, false, {"scale": 1, "bob": 1 if active and sin(anim_t * 4.0) > 0 else 0, "clip_top": cell.position.y + 2})
		else:
			_draw_sprite(f, cell.get_center().x, feet, false, {"scale": 1, "flash": true, "mod": Color(0.2, 0.17, 0.34, 0.95), "clip_top": cell.position.y + 2})
		_text(Vector2(cell.position.x, cell.end.y - 6), f if known else "???", 8, GameData.EL[F.el] if known else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, cell.size.x)


func _draw_lab() -> void:
	var team := SaveGame.team()
	var L := Rect2(8, 34, 190, 306)
	_box(L, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	var rows := team.size() + 1
	var first := clampi(sel - 12, 0, maxi(0, rows - 14))
	for i in range(first, mini(rows, first + 14)):
		var r := Rect2(L.position.x + 4, L.position.y + 4 + (i - first) * 21, L.size.x - 8, 19)
		var active := i == sel
		if i == team.size():
			var can := fuse_sel.size() == 2
			_box(r, GameData.COL.panel.lightened(0.1) if active else GameData.COL.bg2, GameData.COL.sun if active else (GameData.COL.mint if can else GameData.COL.line))
			_text(Vector2(r.position.x, r.position.y + 13), "Fusionieren (%d)" % GameData.FUSION_COST, 8, GameData.COL.mint if can else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
			continue
		var m: Dictionary = team[i]
		var chosen := fuse_sel.has(int(m.id))
		var el: Color = GameData.EL[GameData.FORMS[m.form].el]
		_box(r, GameData.COL.panel.lightened(0.08) if active else GameData.COL.bg2, GameData.COL.sun if active else (GameData.COL.mint if chosen else GameData.COL.line))
		draw_rect(Rect2(r.position + Vector2(5, 6), Vector2(7, 7)), el)
		_text(Vector2(r.position.x + 17, r.position.y + 13), m.form, 8, GameData.COL.ink if active or chosen else GameData.COL.muted, HORIZONTAL_ALIGNMENT_LEFT, -1, true, active)
		if chosen:
			_text(Vector2(r.position.x, r.position.y + 13), "X", 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 6, true, true)
	# Fusionskammer
	var R := Rect2(206, 34, 426, 150)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(R.position.x, R.position.y + 18), "Fusionskammer", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	for k in 2:
		var cx := R.position.x + 90 + k * 246
		var slot := Rect2(cx - 50, R.position.y + 26, 100, 94)
		_box(slot, GameData.COL.bg2, GameData.COL.mint if k < fuse_sel.size() else GameData.COL.line)
		if k < fuse_sel.size():
			var m := SaveGame.monster(fuse_sel[k])
			_draw_sprite(m.form, cx, slot.end.y - 18, false, {"scale": 2 if int(m.stage) == 1 else 1, "bob": 1 if sin(anim_t * 4.0 + k) > 0 else 0})
			_text(Vector2(slot.position.x, slot.end.y - 5), m.form, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, slot.size.x)
		else:
			_text(Vector2(slot.position.x, slot.get_center().y + 3), "?", 16, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, slot.size.x, true, true)
	_text(Vector2(R.position.x, R.position.y + 84), "+", 16, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	var info := fuse_msg if fuse_msg != "" else "Kostet %d Fragmente, nur bei Erfolg. Beide verschmelzen." % GameData.FUSION_COST
	draw_multiline_string(font(), Vector2(R.position.x + 12, R.end.y - 10), info, HORIZONTAL_ALIGNMENT_CENTER, R.size.x - 24, 8, 2, GameData.COL.sun if fuse_msg != "" else GameData.COL.muted, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	# Rezeptbuch
	var B := Rect2(206, 190, 426, 150)
	_box(B, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(B.position.x + 12, B.position.y + 16), "Rezeptbuch", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var y := B.position.y + 34
	var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	for i in GameData.RECIPES.size():
		var R2: Dictionary = GameData.RECIPES[i]
		var line := ""
		var col: Color = GameData.COL.muted
		if SaveGame.data.get("recipes", []).has(R2.r):
			line = "%s + %s = %s" % [R2.a, R2.b, R2.r]
			col = GameData.EL[GameData.FORMS[R2.r].el]
		elif SaveGame.data.get("hints", []).has(float(i)) or SaveGame.data.get("hints", []).has(i):
			line = "Gerücht: " + R2.hint
			col = GameData.COL.ink
		else:
			line = "???"
		draw_multiline_string(font(), Vector2(B.position.x + 12, y), line, HORIZONTAL_ALIGNMENT_LEFT, B.size.x - 24, 8, 2, col, wrap)
		y += 28


func _draw_fusion() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.9))
	var c := Vector2(W / 2.0, 220)
	var t := hatch_t
	if t < HATCH_REVEAL:
		# Zwei Silhouetten kreisen aufeinander zu
		var k := t / HATCH_REVEAL
		var rad := 110.0 * (1.0 - k * k)
		for j in 2:
			var a := t * (3.0 + t * 4.0) + j * PI
			var p := c + Vector2(cos(a) * rad, sin(a) * rad * 0.35)
			var f: String = fusion.a if j == 0 else fusion.b
			_draw_sprite(f, p.x, p.y, false, {"scale": 2 if GameData.FORMS[f].stage == 1 else 1, "flash": true, "mod": Color(0.7, 1.0, 0.9, 0.8)})
		draw_circle(c + Vector2(0, -30), 6.0 + 30.0 * k, Color(1, 1, 1, 0.15 + 0.4 * k))
		_text(Vector2(0, 70), "%s und %s verschmelzen …" % [fusion.a, fusion.b], 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	else:
		var k2 := t - HATCH_REVEAL
		if k2 < 0.25:
			draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k2 / 0.25))
		var f: String = fusion.result
		draw_rect(Rect2(c.x - 50, c.y - 2, 100, 6), Color(0.05, 0.02, 0.12, 0.4))
		_draw_sprite(f, c.x, c.y, false, {"bob": 1 if sin(anim_t * 4.0) > 0 else 0, "blink": fmod(anim_t, 3.0) < 0.13})
		_text(Vector2(0, 70), "Es ist %s!" % f, 16, GameData.EL[GameData.FORMS[f].el], HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		if fusion.new_in_dex:
			_text(Vector2(0, 88), "Neu im Monsterdex – Rezept notiert!", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		var S: Dictionary = GameData.SPECIALS[f]
		_text(Vector2(0, 246), "Signatur: %s – %s" % [S.name, S.desc], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
		_text(Vector2(0, 262), "Passiv: %s" % GameData.MONS[f].passive_desc, 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W)
		if k2 > 0.6:
			_text(Vector2(0, 296), "%s weiter" % ("A" if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


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
