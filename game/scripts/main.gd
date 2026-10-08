extends Node
## Ablauf des Spiels: Titel → Karte → Knoten (Kampf/Raum) → Karte … → Boss → Ergebnis.
##
## Screenshot-Modus (Argumente nach „--“):
##   --shot=<pfad.png> --mode=title|options|starter|map|event|rest|shop|fight|pick|pause|result [--floor=N] [--level=N] [--guard] [--special=S] [--sim=S] [--mon=Art] [--form=Form] [--t=S] [--pad]

const TitleScreen := preload("res://scripts/ui/title.gd")
const StarterScreen := preload("res://scripts/ui/starter_view.gd")
const OpeningScreen := preload("res://scripts/ui/opening_view.gd")
const EndingScreen := preload("res://scripts/ui/ending_view.gd")
const MapScreen := preload("res://scripts/ui/map_view.gd")
const RoomScreen := preload("res://scripts/ui/room_view.gd")
const ResultScreen := preload("res://scripts/ui/result_view.gd")
const StationScreen := preload("res://scripts/ui/station_view.gd")
const RouteScreen := preload("res://scripts/ui/route_view.gd")
const BattleScene := preload("res://scenes/battle.tscn")

var current: Node
var run: RunState
var foe_override := -1   # nur für Screenshots


func _ready() -> void:
	PixelCanvas.preload_all()
	# Pixel-Art nur ganzzahlig vergrößern; ist das Fenster kleiner als 640×360 (z. B. kleines Browserfenster),
	# lieber stufenlos verkleinern als abschneiden
	get_window().size_changed.connect(_fit_scale)
	_fit_scale()
	var shot := Shot.args()
	if shot.has("lang"):
		Settings.lang = shot.lang   # nur für Screenshots, wird nicht gespeichert
	if shot.has("testbuild"):
		SaveGame.force_test = true
	# Nur Intro bzw. Ende abspielen und beenden (Video-Aufnahme: godot --write-movie intro.avi -- --play=opening / --play=ending)
	if OS.get_cmdline_user_args().has("--play=opening"):
		SaveGame.persist = false
		show_opening(get_tree().quit)
	elif OS.get_cmdline_user_args().has("--play=ending"):
		SaveGame.persist = false
		show_ending(["Aurorlynx"], get_tree().quit)
	elif shot.is_empty():
		show_title()
	else:
		_screenshot(shot)


func _fit_scale() -> void:
	var s := get_window().size
	get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER if s.x >= 640 and s.y >= 360 else Window.CONTENT_SCALE_STRETCH_FRACTIONAL


func _swap(node: Node) -> void:
	if current:
		current.queue_free()
	current = node
	add_child(node)


func show_title() -> void:
	var t := TitleScreen.new()
	t.start_run.connect(_from_title)
	t.show_intro.connect(show_opening.bind(show_title))
	t.training.connect(start_training.bind(show_title))
	_swap(t)


## Erster Start: Opening-Szene, dann Starter wählen; sonst direkt in die Station (oder in den gespeicherten Run)
func _from_title() -> void:
	if SaveGame.has_run():
		run = SaveGame.load_run()
		if run.route_pending:
			show_route()
		else:
			show_map()
	elif SaveGame.has_save():
		show_station()
	else:
		show_opening(func():
			show_starters()
			current.from_white = true
		)


func show_ending(forms: Array, then: Callable) -> void:
	var e := EndingScreen.new()
	var team: Array = forms.duplicate()
	for m in SaveGame.team():
		if team.size() < 5 and not team.has(m.form):
			team.append(m.form)
	e.team_forms = team
	e.finished.connect(then)
	_swap(e)


func show_opening(then: Callable) -> void:
	var o := OpeningScreen.new()
	o.finished.connect(then)
	_swap(o)


func show_starters() -> void:
	var s := StarterScreen.new()
	s.chosen.connect(_first_monster)
	s.back.connect(show_title)
	_swap(s)


## Nach der Starterwahl geht es direkt in den Trainingskampf (04.10.2026, Tester: „in einen Kampf geworfen werden“)
func _first_monster(species: String) -> void:
	SaveGame.new_game(species)
	start_training(show_station)


## Geführter Trainingskampf gegen Bugsy (Cache-Wiesen) mit dem ersten Glitchling des Teams. Nicht speichern,
## keine Belohnung; danach then (Station bzw. Titel). Verlieren ist im Training nicht möglich.
func start_training(then: Callable) -> void:
	var team := SaveGame.team()
	if team.is_empty():
		then.call()
		return
	run = RunState.from_monster(team[0], -1, "wiesen")
	run.tutorial = true
	run.training = true
	var foe: Dictionary = GameData.FOES[0].duplicate(true)
	foe.specials = [{"shape": "x", "name": "Glitchkreuz"}]   # für den Großangriff-Schritt
	var b := BattleScene.instantiate()
	b.setup(run, foe, "fight")
	b.finished.connect(func(_won): _training_done(then))
	b.gave_up.connect(_training_done.bind(then))
	_swap(b)


func _training_done(then: Callable) -> void:
	SaveGame.data["tutorial_done"] = true
	SaveGame.save_game()
	run = null
	then.call()


func show_station() -> void:
	var s := StationScreen.new()
	s.start_run.connect(start_run)
	s.to_title.connect(show_title)
	_swap(s)


func start_run(monster_id: int, zone := "wiesen", seed_value := -1) -> void:
	run = RunState.from_monster(SaveGame.monster(monster_id), seed_value, zone)
	run.difficulty = Settings.difficulty if Settings.difficulty < 3 or SaveGame.game_cleared() else 2
	run.tutorial = not SaveGame.data.get("tutorial_done", false)
	run.apply_station(SaveGame.data.get("upgrades", {}))
	run.protocol = SaveGame.protocol_choice()
	run.apply_protocol()
	show_map()


func show_map() -> void:
	var m := MapScreen.new()
	m.setup(run)
	m.node_chosen.connect(_enter_node)
	m.gave_up.connect(show_result.bind(false))
	m.save_quit.connect(show_title)
	_swap(m)
	# Stand auf der Karte sichern: nach dem Beenden geht es hier weiter
	SaveGame.save_run(run)


func _enter_node() -> void:
	var node := run.current_node()
	if node.type in ["fight", "elite", "glitch", "guard", "boss"]:
		var b := BattleScene.instantiate()
		var foe: Dictionary = run.foe_for(node) if foe_override < 0 else GameData.FOES[foe_override].duplicate()
		b.setup(run, foe, node.type)
		b.finished.connect(_battle_finished)
		b.gave_up.connect(show_result.bind(false))
		_swap(b)
	else:
		var r := RoomScreen.new()
		r.setup(run)
		r.finished.connect(show_map)
		_swap(r)


func _battle_finished(won: bool) -> void:
	if not won:
		show_result(false)
	elif run.current_node().type == "boss":
		# Reise (08.10.2026): Boss der Zone besiegt. Legende prüfen, dann weiter in die nächste Zone
		run.bosses.append(run.map.zone)
		var lg := SaveGame.legend_check(run)
		if lg != "":
			run.legends_won.append(lg)
		if GameData.ZONES[run.map.zone].get("final", false):
			# Ur-Glitch besiegt: Ende und Abspann, danach die Auswertung
			show_ending([run.form], show_result.bind(true))
		elif run.final_act():
			show_result(true)   # Testfassung: hier endet die Reise
		else:
			show_route()
	elif run.current_node().type == "guard":
		# Wächter besiegt: weiter auf die nächste Ebene
		run.next_level()
		show_map()
	else:
		show_map()


## Weggabelung nach einem Zonen-Boss: nächste Zone wählen (Stand wird gesichert, falls man hier beendet)
func show_route() -> void:
	run.route_pending = true
	SaveGame.save_run(run)
	var r := RouteScreen.new()
	r.setup(run)
	r.chosen.connect(func(z: String):
		run.next_act(z)
		show_map()
	)
	_swap(r)


func show_result(won: bool) -> void:
	var sum := SaveGame.record_run(run, won)
	var r := ResultScreen.new()
	r.setup(run, won, sum)
	r.to_station.connect(show_station)
	_swap(r)


# ---------- Screenshots ----------

## Beispiel-Spielstand nur im Speicher (für Screenshots)
func _demo_save() -> void:
	SaveGame.new_game("Pixmiez")
	var a := SaveGame.add_monster("Funkling")
	a.form = "Glutbyte"
	a.stage = 2
	a.chips = 31
	a.praeg = {"Feuer": 17, "Neutral": 10, "Code": 4}
	SaveGame.see("Glutbyte")
	var b := SaveGame.add_monster("Tröpfel")
	b.chips = 9
	b.praeg = {"Wasser": 6, "Neutral": 3}
	var c := SaveGame.add_monster("Funkling")
	c.form = "Overclocko"
	c.stage = 2
	c.chips = 44
	c.praeg = {"Code": 20, "Feuer": 8, "Neutral": 16}
	SaveGame.see("Overclocko")
	var p: Dictionary = SaveGame.team()[0]
	p.form = "Prismiez"
	p.stage = 2
	p.chips = 38
	p.praeg = {"Feuer": 15, "Neutral": 19, "Code": 4}
	p.runs = 3
	p.wins = 1
	SaveGame.see("Prismiez")
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	SaveGame.add_egg(rng)
	SaveGame.add_egg(rng)
	SaveGame.data.stats = {"runs": 6, "wins": 1}
	SaveGame.data.frag = 85
	SaveGame.data.hints = [2]
	SaveGame.data.cleared = ["wiesen"]


func _screenshot(shot: Dictionary) -> void:
	InputSetup.pad = shot.get("pad", false)
	InputSetup.pad_style = "ps" if shot.get("ps", false) else "xbox"
	PixelCanvas.font_set = shot.get("font", PixelCanvas.font_set)
	seed(7)
	SaveGame.persist = false
	_demo_save()
	var mode: String = shot.get("mode", "title")
	run = RunState.new(shot.get("mon", "Pixmiez"), 7)
	if shot.has("zone") or shot.has("level"):
		run.map = ZoneMap.generate(run.rng, shot.get("zone", "wiesen"), shot.get("level", 0))
		run.act = GameData.act_of(run.map.zone)
		run.route = [run.map.zone]
	# auf der Karte bis zur gewünschten Etage vorlaufen (immer erster Weg)
	var floors: int = shot.get("floor", 0)
	for f in floors:
		run.enter(run.next_choices()[0])
	run.frag = 55
	foe_override = shot.get("foe", -1)
	for m in shot.get("mods", []):
		run.add_module(m)
	for c in shot.get("deck", []):
		run.deck.append(c)
	if mode in ["map", "pick"] and not shot.has("form"):
		run.praeg = {"Elektro": 6, "Code": 1, "Feuer": 2, "Neutral": 9}
	if shot.has("praeg"):
		run.praeg = shot.praeg
	if shot.has("bonus"):
		run.sp_bonus = true
		run.foe_weak = true
	if shot.has("form"):
		run.form = shot.form
		run.stage = GameData.FORMS[run.form].stage
	match mode:
		"handbook":
			show_title()
			current.open_handbook()
			current.handbook.page = int(shot.get("t", 0.0))
			current.handbook.t_in = 1.0
			await get_tree().process_frame
			current.handbook.set_process(false)
			current.handbook.queue_redraw()
		"title", "options", "wechsel", "keys":
			show_title()
			if mode == "options":
				current.page = TitleScreen.Page.OPTIONS
				current.sel = int(shot.get("t", 0.0))
				current.reset_armed = shot.has("bonus")   # --bonus: Rückfrage beim Zurücksetzen zeigen
			if mode == "title" and shot.has("bonus"):
				# nur die Meldung nach dem Zurücksetzen zeigen – nicht wirklich zurücksetzen (würde echte Einstellungen löschen)
				current.title_msg = "Spiel zurückgesetzt. Mit „Neues Spiel“ geht es ganz von vorn los."
				current.title_msg_t = 3.0
			if mode == "keys":
				current.page = TitleScreen.Page.KEYS
				current.sel = int(shot.get("t", 0.0))
		"starter":
			show_starters()
		"opening":
			show_opening(show_title)
			current.seek(shot.get("t", 0.0))
		"ending":
			show_ending([shot.get("form", "Aurorlynx")], show_title)
			current.seek(shot.get("t", 0.0))
		"station", "nest", "dex", "hatch", "lab", "fusion", "upgrade", "home":
			if mode == "home":
				# mehr Bewohner für das Zuhause-Bild (nur im Speicher)
				for sp in [["Kekso", "Cachy", 2], ["Lumi", "Lumi", 1], ["Plapperli", "Plapperli", 1], ["Brummbit", "Titanbrumm", 3], ["Bachli", "Fulgurlutra", 4], ["Maskli", "Maskli", 1], ["Kauzbit", "Orbitkauz", 4]]:
					var mm := SaveGame.add_monster(sp[0])
					mm.form = sp[1]
					mm.stage = sp[2]
			if mode == "upgrade":
				SaveGame.data.frag = 240
				SaveGame.data.upgrades = {"vorrat": 1, "werkbank": 1}
			if mode == "hatch":
				SaveGame.data.nest[0].runs_left = 0
			if shot.has("legendegg"):
				SaveGame.data.nest.append({"species": "Sternwal", "runs_left": 1, "legend": true})
			show_station()
			current.tab = {"station": 0, "nest": 1, "lab": 2, "dex": 3, "hatch": 0, "fusion": 2, "upgrade": 4, "home": 5}[mode]
			if mode == "home":
				current._sync_home()
				current.home.setup(SaveGame.team(), 7)
				current.home.daytime = shot.get("daytime", current.home.daytime)
				if shot.has("welcome"):
					current.home.welcome(current.home.residents[-1].id)
					current.pet_msg = T.t("%s ist eingezogen! Alle freuen sich.") % T.t(current.home.residents[-1].form)
					current.pet_t = 4.0
				for k in int(shot.get("t", 6.0) * 60.0):
					current.home.update(1.0 / 60.0)
				current.anim_t = shot.get("t", 6.0)
				if shot.has("pops"):
					current.pet_msg = current.home.pet(current.home_sel)
					current.pet_t = 2.0
					for k in 20:
						current.home.update(1.0 / 60.0)
			if mode == "lab":
				current.fuse_sel = [int(SaveGame.team()[1].id), int(SaveGame.team()[2].id)]
				current.sel = SaveGame.team().size()
			if mode == "fusion":
				SaveGame.data.frag = 150
				current.fusion = SaveGame.try_fuse(int(SaveGame.team()[1].id), int(SaveGame.team()[2].id), RandomNumberGenerator.new())
			current.hatch_t = shot.get("t", 0.0)
			if mode == "dex":
				current.sel = int(shot.get("t", 0.0))
				for f in GameData.FORMS:
					if f in ["Kekso", "Tracko", "Lumi", "Perlhopp", "Gischthase", "Quakli", "Hüpfbyte", "Brummbit", "Kauzbit", "Raketauz"]:
						SaveGame.see(f)
			current.t_in = 1.0
			if mode == "station":
				current.sel = int(shot.get("t", 0.0))
			current.guide = shot.get("guide", -1)
			if current.guide >= 0:
				current.tab = current.GUIDE[current.guide][0]
			if shot.has("zones"):
				current.zone_pick = true
			if shot.has("protocol"):
				SaveGame.data.game_cleared = true
				SaveGame.data.protocol_max = 10
				SaveGame.data.protocol_sel = shot.protocol
				SaveGame.team()[0].protocol_best = 4
		"map", "mappause":
			if shot.has("glitchnode"):
				run.map.floors[run.floor_idx + 1][0].type = "glitch"
			show_map()
			current.paused = mode == "mappause"
		"event", "rest", "shop":
			run.enter(run.next_choices()[0])
			run.current_node().type = mode
			if shot.has("event"):
				run.current_node().event = shot.event
			_enter_node()
			if shot.has("choose"):
				current._choose(shot.choose)
		"fight", "pick", "pause", "evolve", "tutorial", "bossintro", "ready", "chiptip":
			run.tutorial = mode == "tutorial"
			run.enter(run.next_choices()[0])
			if floors >= run.map.boss_floor() - 1:
				run.current_node().type = "guard" if shot.has("guard") else "boss"
			elif run.current_node().type != "elite":
				run.current_node().type = "fight"
			_enter_node()
			if mode == "bossintro":
				current.show_intro_for_screenshot(shot.get("t", 3.0))
				current.set_process(false)
				current.queue_redraw()
				await Shot.save(self, shot.path)
				return
			if mode == "ready":
				# Bereit-Pause vor dem Kampf
				current.queue_redraw()
				await Shot.save(self, shot.path)
				return
			current.simulate(shot.get("sim", 2.0))
			if mode == "chiptip":
				# neuer Chip im Schutz-Slot: „Neu!“-Marke
				current.new_t[1] = 2.9
			if shot.has("special"):
				# Großangriff auslösen und bis kurz vor dem Einschlag vorspulen
				current.st.start_special()
				current.st.update(shot.special)
				current.st.events.clear()
			if shot.has("chip"):
				# Chip-Effekt prüfen: Gegner in die Reihe, Chip spielen, --t Sekunden weiter (z. B. --chip=Heilpatch --t=0.4)
				var cs: BattleState = current.st
				cs.e.r = cs.p.r
				cs.e.atk_t = 99.0
				cs.e.move_t = 99.0
				cs.vfx.clear()
				cs.proj.clear()
				cs.parts.clear()
				cs.fx.clear()
				cs.hand[0].chip = shot.chip
				cs.hand[0].rem = 0.0
				cs.use_slot(0)
				var tt := 0.0
				while tt < shot.get("t", 0.2):
					cs.update(1.0 / 60.0)
					tt += 1.0 / 60.0
				cs.events.clear()
			if shot.has("anim"):
				# Kampf-Animationen prüfen: --anim=mat|dissolve|win|cutin --t=Sekunden seit Beginn
				var at: float = shot.get("t", 0.3)
				current.st.warns.clear()
				current.st.e.atk_t = 99.0
				match shot.anim:
					"mat":
						current.mat_t = maxf(0.001, current.MAT_TIME - at)
					"dissolve", "win":
						current.st.over = true
						current.st.outcome = "won"
						current.end_timer = current.END_WIN - at
					"cutin":
						current.cutin_t = maxf(0.001, current.CUTIN - at)
					"hurt":
						current.p_hurt = 0.3 - at
						current.st.p.flash = 0.0
			if shot.has("counter"):
				# Konter-Fenster: Gegner holt in deiner Reihe aus, Fadenkreuz über ihm (08.10.2026)
				var cs3: BattleState = current.st
				cs3.e.r = cs3.p.r
				cs3.e.atk_t = 99.0
				cs3.e.move_t = 99.0
				cs3.warns.clear()
				cs3.warns.append({"cells": [Vector2i(0, cs3.p.r), Vector2i(1, cs3.p.r), Vector2i(2, cs3.p.r)], "t": 0.25, "max": 0.7, "dmg": 10, "lava": false, "atk": true, "shot": true})
			if shot.has("atkpose"):
				# Angriffsanimation prüfen: Spieler und Gegner beim gleichen Fortschritt (0–1)
				var ak: float = shot.atkpose
				current.p_atk = current.ATK_TIME * (1.0 - ak)
				current.st.e.atk_t = 99.0
				current.st.warns.clear()
				current.st.warns.append({"cells": [Vector2i(current.st.p.c, current.st.p.r)], "t": maxf(0.01, 1.0 - ak / current.ATK_HIT), "max": 1.0, "dmg": 0})
				if ak > current.ATK_HIT:
					current.st.warns.clear()
					current.e_atk_post = current.E_ATK_POST * (1.0 - (ak - current.ATK_HIT) / (1.0 - current.ATK_HIT))
			if shot.has("area"):
				# Flächeneffekte prüfen: Warnungen in drei Stadien, frische und abkühlende Fläche, Ausbruch, Zustand am Gegner
				var cs2: BattleState = current.st
				cs2.warns.clear()
				cs2.hazards.clear()
				cs2.vfx.clear()
				cs2.parts.clear()
				cs2.e.atk_t = 99.0
				cs2.e.move_t = 99.0
				var sl: bool = run.map.zone == "sumpf"
				var hk: String = {"sumpf": "slime", "see": "current", "steppe": "spark"}.get(run.map.zone, "lava")
				for wi in 3:
					cs2.warns.append({"cells": [Vector2i(wi, 0)], "t": [0.72, 0.45, 0.08][wi], "max": 0.9, "dmg": 0, "lava": true, "kind": hk, "dir": 1})
				cs2.hazards.append({"c": 0, "r": 2, "t": 2.5, "tick": 0.3, "kind": hk, "seed": 5, "dir": -1})
				cs2.hazards.append({"c": 2, "r": 2, "t": 0.35, "tick": 0.3, "kind": hk, "seed": 9})
				cs2.vfx_add("erupt", 1, 2, 0.45, {"slime": sl, "kind": hk})
				cs2.vfx[-1].t = 0.3
				match run.map.zone:
					"vulkan":
						cs2.e.burn = 3
					"sumpf":
						cs2.e.poison = 3
						cs2.e.slow = 2.0
					_:
						cs2.e.frozen = 2.0
			if shot.has("pops"):
				var pk: String = {"sumpf": "spore", "see": "bubble"}.get(run.map.zone, "milbe")
				current.st.pops.append({"c": 0, "r": 0, "t": 2.5, "max": 3.0, "kind": pk})
				current.st.pops.append({"c": 2, "r": 1, "t": 0.8, "max": 3.0, "kind": pk})
			if shot.has("lava"):
				var hk: String = "slime" if run.map.zone == "sumpf" else "lava"
				current.st.hazards.append({"c": 0, "r": 0, "t": 2.5, "tick": 0.3, "kind": hk})
				current.st.hazards.append({"c": 2, "r": 2, "t": 2.0, "tick": 0.3, "kind": hk})
				current.st.warns.append({"cells": [Vector2i(1, 0)], "t": 0.4, "max": 0.8, "dmg": 0, "lava": true})
			if mode == "pick":
				current.show_pick_for_screenshot()
				current.new_module = shot.get("newmod", "")
				if shot.has("choices"):
					current.choices = Array(shot.choices)
				run.add_module(current.new_module)
			elif mode == "pause":
				current.show_pause_for_screenshot()
			elif mode == "evolve":
				current.show_evolve_for_screenshot(shot.get("t", 2.6))
		"route":
			# Weggabelung nach dem Boss der aktuellen Zone (--zone, --form)
			run.act = GameData.act_of(run.map.zone)
			run.bosses = [run.map.zone]
			run.hp = roundi(run.max_hp * 0.5)
			show_route()
			SaveGame.data.erase("run")
		"result":
			run.route = ["wiesen", "see"]
			run.act = 1
			run.bosses = ["wiesen"]
			run.praeg = {"Neutral": 14, "Feuer": 9, "Elektro": 4}
			run.chips_used = 27
			run.fights_won = 3
			run.form = "Prismiez"
			run.stage = 2
			run.monster_id = 1
			show_result(false)
	current.set_process(false)
	current.queue_redraw()
	await Shot.save(self, shot.path)
