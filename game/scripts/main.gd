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
const BattleScene := preload("res://scenes/battle.tscn")

var current: Node
var run: RunState
var foe_override := -1   # nur für Screenshots


func _ready() -> void:
	PixelCanvas.preload_all()
	var shot := Shot.args()
	if shot.is_empty():
		show_title()
	else:
		_screenshot(shot)


func _swap(node: Node) -> void:
	if current:
		current.queue_free()
	current = node
	add_child(node)


func show_title() -> void:
	var t := TitleScreen.new()
	t.start_run.connect(_from_title)
	t.show_intro.connect(show_opening.bind(show_title))
	_swap(t)


## Erster Start: Opening-Szene, dann Starter wählen; sonst direkt in die Station (oder in den gespeicherten Run)
func _from_title() -> void:
	if SaveGame.has_run():
		run = SaveGame.load_run()
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


func _first_monster(species: String) -> void:
	SaveGame.new_game(species)
	show_station()


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
	elif run.current_node().type == "boss" and GameData.ZONES[run.map.zone].get("final", false):
		# Ur-Glitch besiegt: Ende und Abspann, danach die Auswertung
		show_ending([run.form], show_result.bind(true))
	elif run.current_node().type == "boss":
		show_result(true)
	elif run.current_node().type == "guard":
		# Wächter besiegt: weiter auf die nächste Ebene
		run.next_level()
		show_map()
	else:
		show_map()


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
	SaveGame.add_egg("Gewöhnlich", rng)
	SaveGame.add_egg("Selten", rng)
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
	if shot.has("form"):
		run.form = shot.form
		run.stage = GameData.FORMS[run.form].stage
	match mode:
		"title", "options":
			show_title()
			if mode == "options":
				current.page = TitleScreen.Page.OPTIONS
		"starter":
			show_starters()
		"opening":
			show_opening(show_title)
			current.seek(shot.get("t", 0.0))
		"ending":
			show_ending([shot.get("form", "Aurorlynx")], show_title)
			current.seek(shot.get("t", 0.0))
		"station", "nest", "dex", "hatch", "lab", "fusion", "upgrade":
			if mode == "upgrade":
				SaveGame.data.frag = 240
				SaveGame.data.upgrades = {"vorrat": 1, "werkbank": 1}
			if mode == "hatch":
				SaveGame.data.nest[0].runs_left = 0
			show_station()
			current.tab = {"station": 0, "nest": 1, "lab": 2, "dex": 3, "hatch": 0, "fusion": 2, "upgrade": 4}[mode]
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
		"fight", "pick", "pause", "evolve", "tutorial", "bossintro":
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
			current.simulate(shot.get("sim", 2.0))
			if shot.has("special"):
				# Großangriff auslösen und bis kurz vor dem Einschlag vorspulen
				current.st.start_special()
				current.st.update(shot.special)
				current.st.events.clear()
			if shot.has("pops"):
				var pk: String = "spore" if run.map.zone == "sumpf" else "milbe"
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
		"result":
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
