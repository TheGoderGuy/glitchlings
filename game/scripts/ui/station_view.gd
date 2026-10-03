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
	"Bachli", "Strudli", "Knisterli", "Wogotter", "Lutrion", "Hydrolutra", "Fulgurlutra",
	"Plapperli", "Surrfeder", "Glutfeder", "Sturmschwinge", "Flammschwinge", "Fulgopsitta", "Heliopsitta",
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
var up_msg := ""             # Rückmeldung im Ausbau-Reiter
var nest_msg := ""           # Rückmeldung beim Ei-Kauf
var zone_pick := false       # Zonenwahl offen (nach Enter im Team-Reiter)
var zone_sel := 0            # gewählte Zone (Index in GameData.ZONE_ORDER)
var zone_msg := ""
var guide := -1              # Schritt der Station-Führung (-1 = aus)

## Station-Führung: [Reiter, hervorgehobener Bereich, Titel, Text] – %s wird durch Tasten ersetzt
const GUIDE := [
	[0, "tabs", "Willkommen in der Station!", "Hier ist dein Zuhause zwischen den Runs. Mit %s wechselst du die Reiter oben."],
	[0, "team", "Team", "Das sind deine Glitchlinge. Wähle eins aus und drücke %s – dann suchst du dir eine Zone für den Run aus."],
	[1, "tab", "Brutnest", "Nach jedem Run mit mindestens zwei Siegen bekommst du ein Ei, oder du kaufst eins für 200 Fragmente. Es schlüpft nach zwei Runs – so wächst dein Team."],
	[2, "tab", "Labor", "Hier verschmelzen zwei Glitchlinge zu einer seltenen Fusion. Die Rezepte sind geheim, aber Gerüchte helfen dir."],
	[3, "tab", "Monsterdex", "Alle Formen, die du entdeckt hast. Wie sich ein Glitchling entwickelt, bestimmen die Chips, die du im Kampf spielst!"],
	[4, "tab", "Ausbau", "Fragmente aus deinen Runs machen die Station dauerhaft stärker: mehr HP, verbesserte Start-Chips, ein vierter Nestplatz …"],
	[0, "team", "Los geht's!", "Wähle ein Glitchling und drücke %s. Diese Hilfe öffnest du jederzeit wieder mit %s, das Kampf-Handbuch mit %s (auch im Pause-Menü)."],
]


func _ready() -> void:
	Music.play("title")
	_check_hatch()
	# Erster Besuch: kurze Führung durch die Reiter (nach dem Schlüpfen)
	if not SaveGame.data.get("station_guide_done", false):
		guide = 0
		tab = Tab.TEAM
	# Zonenwahl startet bei der vordersten freigeschalteten, noch nicht geschafften Zone
	zone_sel = _default_zone()


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
	if handbook != null:
		queue_redraw()
		return
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
	if guide >= 0:
		_process_guide()
		queue_redraw()
		return
	if zone_pick:
		_process_zone_pick()
		queue_redraw()
		return
	if Input.is_action_just_pressed("special"):
		guide = 0
		tab = Tab.TEAM
		Sfx.play("select")
	elif Input.is_action_just_pressed("handbook"):
		open_handbook()
	elif Input.is_action_just_pressed("tab_next"):
		tab = ((tab + 1) % TAB_NAMES.size()) as Tab
		up_msg = ""
		nest_msg = ""
		sel = 0
		Sfx.play("select")
	elif Input.is_action_just_pressed("tab_prev"):
		tab = ((tab + TAB_NAMES.size() - 1) % TAB_NAMES.size()) as Tab
		up_msg = ""
		nest_msg = ""
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
					# weiter zur Zonenwahl
					Sfx.play("confirm")
					zone_pick = true
					zone_msg = ""
					t_in = 0.0
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
			Tab.NEST:
				if Input.is_action_just_pressed("confirm"):
					if SaveGame.nest().size() >= SaveGame.nest_slots():
						nest_msg = T.t("Das Brutnest ist voll.")
						Sfx.play("back")
					elif SaveGame.frag() < SaveGame.EGG_PRICE:
						nest_msg = T.t("Dafür fehlen noch %d Fragmente.") % (SaveGame.EGG_PRICE - SaveGame.frag())
						Sfx.play("back")
					else:
						var rng := RandomNumberGenerator.new()
						rng.randomize()
						SaveGame.buy_egg(rng)
						nest_msg = T.t("Ei gekauft! Es schlüpft nach %d Runs.") % maxi(1, SaveGame.EGG_RUNS - SaveGame.upgrade_level("brutwaermer"))
						Sfx.play("pop", 0.0)
			Tab.UPGRADE:
				_nav_v(GameData.STATION_UPGRADES.size())
				if Input.is_action_just_pressed("confirm"):
					var u: Dictionary = GameData.STATION_UPGRADES[sel]
					var cost := SaveGame.upgrade_cost(u.id)
					if cost < 0:
						up_msg = T.t("%s ist schon ganz ausgebaut.") % T.t(u.name)
						Sfx.play("back")
					elif SaveGame.buy_upgrade(u.id):
						up_msg = T.t("%s ausgebaut: Stufe %d!") % [T.t(u.name), SaveGame.upgrade_level(u.id)]
						Sfx.play("evolve", 0.0)
					else:
						up_msg = T.t("Dafür fehlen noch %d Fragmente.") % (cost - SaveGame.frag())
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
	var hint := T.t("%s/%s Reiter   %s Hilfe   %s Handbuch   %s Titel") % [InputSetup.btn("LB") if pad else "Q", InputSetup.btn("RB") if pad else "E", InputSetup.btn("Y") if pad else T.t("Leertaste"), InputSetup.btn("Back") if pad else "H", InputSetup.btn("B") if pad else "Esc"]
	_text(Vector2(0, H - 8), hint, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	if zone_pick:
		_draw_zone_pick()
	if guide >= 0 and hatch.is_empty():
		_draw_guide()
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
	_text(Vector2(0, H - 8), T.t("Fragmente %d · Dex %d/%d ") % [SaveGame.frag(), SaveGame.dex_count(), DEX_ORDER.size()], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_RIGHT, W - 8)


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
	_text(Vector2(R.position.x, R.position.y + 190), "%s · %s · %d HP" % [T.t(GameData.STAGE_NAMES[int(m.stage)]), T.t(F.el), int(M.hp) + 10 * (int(m.stage) - 1)], 8, el, HORIZONTAL_ALIGNMENT_CENTER, 180)
	_text(Vector2(R.position.x, R.position.y + 204), T.t("Runs %d · Siege %d") % [int(m.runs), int(m.wins)], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, 180)
	# Details rechts
	var x := R.position.x + 190
	var w := R.size.x - 204
	var y := R.position.y + 20
	var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	var S: Dictionary = GameData.SPECIALS[form]
	_text(Vector2(x, y), T.t("Signatur:") + " " + T.t(S.name), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	draw_multiline_string(font(), Vector2(x, y + 14), T.t(S.desc), HORIZONTAL_ALIGNMENT_LEFT, w, tsz(8), 2, GameData.COL.ink, wrap)
	y += 44
	_text(Vector2(x, y), T.t("Passiv:") + " " + T.t(M.passive), 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	draw_multiline_string(font(), Vector2(x, y + 14), T.t(M.passive_desc), HORIZONTAL_ALIGNMENT_LEFT, w, tsz(8), 3, GameData.COL.ink, wrap)
	y += 56
	# Entwicklung: mögliche Richtungen mit Lebenszeit-Prägung
	_text(Vector2(x, y), "Entwicklung", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var probe := RunState.from_monster(m, 1)
	_draw_evo(probe.evo_status(), x, y + 4, w)
	var pad: bool = InputSetup.pad
	var zones := SaveGame.unlocked_zones()
	_text(Vector2(R.position.x, R.end.y - 26), T.t("%d von %d Zonen frei") % [zones.size(), GameData.ZONE_ORDER.size()], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)
	var pulse := 0.75 + 0.25 * sin(anim_t * 4.0)
	_text(Vector2(R.position.x, R.end.y - 12), T.t("%s Mit %s eine Zone wählen") % [InputSetup.btn("A") if pad else "Enter", T.t(form)], 8, Color(GameData.COL.sun, pulse), HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)


# ---------- Zonenwahl ----------

func _default_zone() -> int:
	var best := 0
	for i in GameData.ZONE_ORDER.size():
		var z: String = GameData.ZONE_ORDER[i]
		if SaveGame.zone_unlocked(z):
			best = i
			if not SaveGame.data.get("cleared", []).has(z):
				return i
	return best


func _process_zone_pick() -> void:
	var n: int = GameData.ZONE_ORDER.size()
	if Input.is_action_just_pressed("move_right"):
		zone_sel = (zone_sel + 1) % n
		zone_msg = ""
		Sfx.play("select")
	elif Input.is_action_just_pressed("move_left"):
		zone_sel = (zone_sel + n - 1) % n
		zone_msg = ""
		Sfx.play("select")
	elif Input.is_action_just_pressed("back") or Input.is_action_just_pressed("pause"):
		zone_pick = false
		Sfx.play("back")
	elif Input.is_action_just_pressed("confirm"):
		var z: String = GameData.ZONE_ORDER[zone_sel]
		if not SaveGame.zone_unlocked(z):
			zone_msg = "Nicht in dieser Testversion enthalten." if not SaveGame.zone_in_build(z) else "Noch gesperrt: Besiege zuerst den Boss der Zone davor."
			Sfx.play("back")
			return
		Sfx.play("confirm")
		zone_pick = false
		set_process(false)
		start_run.emit(int(SaveGame.team()[sel].id), z)


## Aufbau einer Zone als Text, z. B. „3 Ebenen · 2 Wächter“ (der Boss steht darunter)
static func zone_layout(z: String) -> String:
	var Z: Dictionary = GameData.ZONES[z]
	var lv: int = Z.get("levels", ZoneMap.LEVELS)
	return T.t("%d Ebenen · %d Wächter") % [lv, lv - 1]


func _draw_zone_pick() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.97))
	var form: String = SaveGame.team()[sel].form
	_text(Vector2(0, 30), "Wohin geht die Reise?", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	_text(Vector2(0, 46), T.t("Mit %s durch eine Zone des NEST. Jede Zone hat ihre eigenen Gegner, Ereignisse und Musik.") % T.t(form), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	var n: int = GameData.ZONE_ORDER.size()
	var cw := 146.0
	var gap := 8.0
	var x0 := (W - n * cw - (n - 1) * gap) / 2.0
	var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	for i in n:
		var z: String = GameData.ZONE_ORDER[i]
		var Z: Dictionary = GameData.ZONES[z]
		var open := SaveGame.zone_unlocked(z)
		var done: bool = SaveGame.data.get("cleared", []).has(z)
		var active := i == zone_sel
		var r := Rect2(x0 + i * (cw + gap), 60 - (4 if active else 0), cw, 236)
		_box(r, GameData.COL.panel.lightened(0.08) if active else GameData.COL.bg2, GameData.COL.sun if active else GameData.COL.line)
		# Landschaft als Ausschnitt der Zonen-Kulisse (1:1, nicht skaliert)
		var img := Rect2(r.position.x + 4, r.position.y + 4, cw - 8, 78)
		draw_texture_rect_region(zone_texture(Z.bg), img, Rect2(250, 196, img.size.x, img.size.y), Color(1, 1, 1, 1.0 if open else 0.3))
		_text(Vector2(r.position.x + 8, r.position.y + 16), T.t("Zone %d") % (i + 1), 8, Color.WHITE)
		if open:
			var tag := "Geschafft!" if done else "Neu!"
			_text(Vector2(r.position.x, r.position.y + 16), tag, 8, GameData.COL.mint if done else GameData.COL.sun, HORIZONTAL_ALIGNMENT_RIGHT, cw - 8, true, true)
		else:
			_draw_lock(img.get_center())
		_text(Vector2(r.position.x, r.position.y + 98), Z.name, 8, GameData.COL.ink if open else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, cw, true, true)
		# Gefahr: 1–4 Kästchen
		for k in n:
			draw_rect(Rect2(r.get_center().x - 22 + k * 12, r.position.y + 106, 8, 5), GameData.COL.coral if k <= i else GameData.COL.dark)
		_text(Vector2(r.position.x, r.position.y + 124), zone_layout(z), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, cw)
		var desc: String = T.t(Z.desc) if open else T.t("Gesperrt. Besiege den Boss von %s, um diese Zone freizuschalten.") % T.t(GameData.ZONES[Z.unlock].name)
		if not SaveGame.zone_in_build(z):
			desc = T.t("Nicht in dieser Testversion enthalten. Im fertigen Spiel geht es hier weiter!")
		draw_multiline_string(font(), Vector2(r.position.x + 8, r.position.y + 142), desc, HORIZONTAL_ALIGNMENT_CENTER, cw - 16, tsz(8), 5, GameData.COL.ink if open else GameData.COL.muted, wrap)
		var boss: String = T.t(GameData.FOES[Z.boss].name) if done else "???"
		_text(Vector2(r.position.x, r.end.y - 10), T.t("Endboss:" if Z.get("final", false) else "Boss:") + " " + boss, 8, GameData.COL.coral if open else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, cw)
	var pad: bool = InputSetup.pad
	var foot := zone_msg if zone_msg != "" else T.t("< > Zone wählen   %s losziehen   %s zurück") % [InputSetup.btn("A") if pad else "Enter", InputSetup.btn("B") if pad else "Esc"]
	_text(Vector2(0, 322), foot, 8, GameData.COL.coral if zone_msg != "" else GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


func _draw_lock(c: Vector2) -> void:
	draw_arc(c + Vector2(0, -6), 7.0, PI, TAU, 12, GameData.COL.ink, 3.0)
	draw_rect(Rect2(c.x - 10, c.y - 6, 20, 16), GameData.COL.dark)
	draw_rect(Rect2(c.x - 9, c.y - 5, 18, 14), GameData.COL.muted)
	draw_rect(Rect2(c.x - 1, c.y, 2, 5), GameData.COL.dark)


# ---------- Station-Führung ----------

func _process_guide() -> void:
	if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("pause"):
		_end_guide()
		Sfx.play("back")
	elif Input.is_action_just_pressed("confirm"):
		guide += 1
		Sfx.play("confirm")
		if guide >= GUIDE.size():
			_end_guide()
		else:
			tab = GUIDE[guide][0] as Tab
			sel = 0


func _end_guide() -> void:
	guide = -1
	tab = Tab.TEAM
	sel = 0
	SaveGame.data["station_guide_done"] = true
	SaveGame.save_game()


## Rechteck eines Reiters oben (wie in _draw_tabs)
func _tab_rect(i: int) -> Rect2:
	var x := 150.0
	for k in TAB_NAMES.size():
		var w := text_width(TAB_NAMES[k], 8, true) + 20
		if k == i:
			return Rect2(x, 8, w, 18)
		x += w + 4
	return Rect2()


func _draw_guide() -> void:
	var g: Array = GUIDE[guide]
	var pad: bool = InputSetup.pad
	var hl := Rect2()
	match g[1]:
		"tabs":
			hl = _tab_rect(0).merge(_tab_rect(TAB_NAMES.size() - 1))
		"tab":
			hl = _tab_rect(g[0])
		"team":
			hl = Rect2(8, 34, 170, 306)
	# alles außer dem hervorgehobenen Bereich abdunkeln
	var dim := Color(GameData.COL.dark, 0.6)
	draw_rect(Rect2(0, 0, W, hl.position.y), dim)
	draw_rect(Rect2(0, hl.end.y, W, H - hl.end.y), dim)
	draw_rect(Rect2(0, hl.position.y, hl.position.x, hl.size.y), dim)
	draw_rect(Rect2(hl.end.x, hl.position.y, W - hl.end.x, hl.size.y), dim)
	var pulse := 0.6 + 0.4 * sin(anim_t * 6.0)
	draw_rect(hl.grow(2), Color(GameData.COL.sun, pulse), false, 2.0)
	# Textkasten
	var keys_tabs := "%s/%s" % [InputSetup.btn("LB"), InputSetup.btn("RB")] if pad else "Q/E"
	var key_ok: String = InputSetup.btn("A") if pad else "Enter"
	var key_help: String = InputSetup.btn("Y") if pad else T.t("der Leertaste")
	var txt: String = T.t(g[3])
	match guide:
		0:
			txt = txt % keys_tabs
		1:
			txt = txt % key_ok
		6:
			txt = txt % [key_ok, key_help, InputSetup.btn("Back") if pad else "H"]
	var B := Rect2(196, 214 if g[1] != "team" else 200, 420, 110)
	_box(B, Color(GameData.COL.panel, 0.97), GameData.COL.sun)
	_text(Vector2(B.position.x + 14, B.position.y + 20), g[2], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(Vector2(B.position.x, B.position.y + 20), "%d/%d" % [guide + 1, GUIDE.size()], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, B.size.x - 14)
	draw_multiline_string(font(), Vector2(B.position.x + 14, B.position.y + 40), txt, HORIZONTAL_ALIGNMENT_LEFT, B.size.x - 28, tsz(8), 4, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	_text(Vector2(B.position.x, B.end.y - 10), T.t("%s weiter   %s überspringen") % [key_ok, InputSetup.btn("B") if pad else "Esc"], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, B.size.x - 14)


func _draw_upgrades() -> void:
	var R := Rect2(40, 40, 560, 296)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(R.position.x, R.position.y + 22), "Station-Ausbau", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	_text(Vector2(R.position.x, R.position.y + 38), T.t("Fragmente aus deinen Runs machen die Station dauerhaft besser. Du hast %d.") % SaveGame.frag(), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)
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
		var prefix := T.t("Jetzt:") + " " if cost < 0 else (T.t("Nächste Stufe:") + " " if lv > 0 else "")
		_text(Vector2(r.position.x + 10, r.position.y + 26), prefix + desc, 8, GameData.COL.muted)
		var price_txt := T.t("ganz ausgebaut") if cost < 0 else T.t("%d Fragmente") % cost
		var pcol: Color = GameData.COL.mint if cost < 0 else (GameData.COL.sun if SaveGame.frag() >= cost else Color(GameData.COL.coral, 0.9))
		_text(Vector2(r.position.x, r.position.y + 13), price_txt, 8, pcol, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 10, true, true)
	var foot := up_msg if up_msg != "" else T.t("%s ausbauen") % (InputSetup.btn("A") if InputSetup.pad else "Enter")
	_text(Vector2(R.position.x, R.end.y - 10), foot, 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)


func _draw_nest() -> void:
	var R := Rect2(40, 40, 560, 296)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(R.position.x, R.position.y + 22), "Brutnest", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, R.size.x, true, true)
	_text(Vector2(R.position.x, R.position.y + 38), T.t("Ein Ei gibt es nach jedem Run mit mindestens %d gewonnenen Kämpfen.") % SaveGame.EGG_MIN_WINS, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)
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
		_draw_egg(Vector2(r.get_center().x + wob, r.position.y + 114), 2)
		_text(Vector2(r.position.x, r.position.y + 136), "Ei", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
		var txt := T.t("schlüpft nach dem nächsten Run") if left == 1 else (T.t("bereit!") if left <= 0 else T.t("noch %d Runs") % left)
		draw_multiline_string(font(), Vector2(r.position.x + 8, r.position.y + 152), txt, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, tsz(8), 2, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	# Ei kaufen
	var can_buy := SaveGame.frag() >= SaveGame.EGG_PRICE and SaveGame.nest().size() < SaveGame.nest_slots()
	var B := Rect2(R.get_center().x - 120, R.end.y - 50, 240, 18)
	_box(B, GameData.COL.panel.lightened(0.08) if can_buy else GameData.COL.bg2, GameData.COL.sun if can_buy else GameData.COL.line)
	var key: String = InputSetup.btn("A") if InputSetup.pad else "Enter"
	_text(Vector2(B.position.x, B.position.y + 13), T.t("%s Ei kaufen (%d Fragmente)") % [key, SaveGame.EGG_PRICE], 8, GameData.COL.ink if can_buy else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, B.size.x, true, can_buy)
	var foot := nest_msg if nest_msg != "" else "Eier schlüpfen nach 2 Runs. Arten, die dir noch fehlen, schlüpfen häufiger."
	_text(Vector2(R.position.x, R.end.y - 14), foot, 8, GameData.COL.sun if nest_msg != "" else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, R.size.x)


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
			_text(Vector2(r.position.x, r.position.y + 13), T.t("Fusionieren (%d)") % GameData.FUSION_COST, 8, GameData.COL.mint if can else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
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
	var info := T.t(fuse_msg) if fuse_msg != "" else T.t("Kostet %d Fragmente, nur bei Erfolg. Beide verschmelzen.") % GameData.FUSION_COST
	draw_multiline_string(font(), Vector2(R.position.x + 12, R.end.y - 10), info, HORIZONTAL_ALIGNMENT_CENTER, R.size.x - 24, tsz(8), 2, GameData.COL.sun if fuse_msg != "" else GameData.COL.muted, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	# Rezeptbuch
	var B := Rect2(206, 190, 426, 150)
	_box(B, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	_text(Vector2(B.position.x + 12, B.position.y + 16), "Rezeptbuch", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var y := B.position.y + 32
	var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	for i in GameData.RECIPES.size():
		var R2: Dictionary = GameData.RECIPES[i]
		var line := ""
		var col: Color = GameData.COL.muted
		if SaveGame.data.get("recipes", []).has(R2.r):
			line = "%s + %s = %s" % [T.t(R2.a), T.t(R2.b), T.t(R2.r)]
			col = GameData.EL[GameData.FORMS[R2.r].el]
		elif SaveGame.data.get("hints", []).has(float(i)) or SaveGame.data.get("hints", []).has(i):
			line = T.t("Gerücht:") + " " + T.t(R2.hint)
			col = GameData.COL.ink
		else:
			line = "???"
		draw_multiline_string(font(), Vector2(B.position.x + 12, y), line, HORIZONTAL_ALIGNMENT_LEFT, B.size.x - 24, tsz(8), 2, col, wrap)
		# Zeilenabstand nach tatsächlicher Höhe (Gerüchte brauchen oft zwei Zeilen)
		y += font().get_multiline_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, B.size.x - 24, tsz(8), 2, wrap).y + 5


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
		_text(Vector2(0, 70), T.t("%s und %s verschmelzen …") % [T.t(fusion.a), T.t(fusion.b)], 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	else:
		var k2 := t - HATCH_REVEAL
		if k2 < 0.25:
			draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k2 / 0.25))
		var f: String = fusion.result
		draw_rect(Rect2(c.x - 50, c.y - 2, 100, 6), Color(0.05, 0.02, 0.12, 0.4))
		_draw_sprite(f, c.x, c.y, false, {"bob": 1 if sin(anim_t * 4.0) > 0 else 0, "blink": fmod(anim_t, 3.0) < 0.13})
		_text(Vector2(0, 70), T.t("Es ist %s!") % T.t(f), 16, GameData.EL[GameData.FORMS[f].el], HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		if fusion.new_in_dex:
			_text(Vector2(0, 88), "Neu im Monsterdex – Rezept notiert!", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		var S: Dictionary = GameData.SPECIALS[f]
		_text(Vector2(0, 246), T.t("Signatur: %s – %s") % [T.t(S.name), T.t(S.desc)], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
		_text(Vector2(0, 262), T.t("Passiv: %s") % T.t(GameData.MONS[f].passive_desc), 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W)
		if k2 > 0.6:
			_text(Vector2(0, 296), T.t("%s weiter") % (InputSetup.btn("A") if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


func _draw_egg(feet: Vector2, scale: int) -> void:
	var tex: Texture2D = EGG_TEX.egg_s
	var size := tex.get_width() * scale
	draw_set_transform(Vector2(roundi(feet.x - size / 2.0), roundi(feet.y - size)), 0, Vector2(scale, scale))
	draw_texture(tex, Vector2.ZERO)
	draw_set_transform(Vector2.ZERO)


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
		_draw_egg(Vector2(c.x + wob, c.y), 3)
		_text(Vector2(0, 70), "Oh? Ein Ei bewegt sich …", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	else:
		var k := t - HATCH_REVEAL
		if k < 0.25:
			draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k / 0.25))
		var sp: String = hatch.species
		var el: Color = GameData.EL[GameData.MONS[sp].el]
		draw_rect(Rect2(c.x - 50, c.y - 2, 100, 6), Color(0.05, 0.02, 0.12, 0.4))
		_draw_sprite(sp, c.x, c.y, false, {"scale": 3, "bob": 1 if sin(anim_t * 4.0) > 0 else 0, "blink": fmod(anim_t, 3.0) < 0.13})
		_text(Vector2(0, 70), T.t("%s ist geschlüpft!") % T.t(sp), 16, el, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		if hatch.new_in_dex:
			_text(Vector2(0, 88), "Neu im Monsterdex!", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		_text(Vector2(0, 250), T.t("%s kommt in dein Team.") % T.t(sp), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
		if k > 0.6:
			_text(Vector2(0, 290), T.t("%s weiter") % (InputSetup.btn("A") if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
