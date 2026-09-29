extends Node
## Kampflogik-Tests ohne Grafik.
## Aufruf: godot --headless --path game res://tests/test_battle.tscn  (als Szene, damit die Autoloads da sind)

var count := 0
var fails := 0
var seen_events := {}


func _ready() -> void:
	# Schutz: Tests schreiben NIE in den echten Spielstand oder das echte Spieltest-Log,
	# auch wenn einzelne Tests persist einschalten (29.09.2026: ein Test hatte den echten Stand verändert)
	SaveGame.path = "user://test_savegame.json"
	SaveGame.log_path = "user://test_spieltest_log.csv"
	test_scripts_compile()
	test_data()
	test_hand()
	test_projectile()
	test_reflex_and_firewall()
	test_enemy_warning()
	test_queue()
	test_glutball()
	test_special()
	test_pop_close()
	test_choices()
	test_new_chips()
	test_all_chips_run()
	test_new_events()
	test_new_foes()
	test_difficulty()
	test_evolution()
	test_meta()
	test_fusion()
	test_zone2()
	test_zone3()
	test_tutorial()
	test_all_specials()
	test_passives()
	test_new_lines()
	test_map()
	test_rooms()
	test_elite_scaling()
	test_simulated_runs()
	test_sounds()
	await test_music()
	await test_opening()
	await test_boss_intro()
	await test_finale()
	test_modules()
	test_combo_chips()
	test_chip_texts()
	test_form_migration()
	check(SaveGame.path == "user://test_savegame.json" and SaveGame.log_path == "user://test_spieltest_log.csv", "Tests nutzen bis zum Schluss eigene Dateien (echter Spielstand bleibt unberührt)")
	print("\n%d Prüfungen, %d Fehler" % [count, fails])
	get_tree().quit(1 if fails > 0 else 0)


## Jedes Skript muss fehlerfrei kompilieren (ein Fehler in main.gd lässt das Spiel leer hängen)
func test_scripts_compile() -> void:
	var bad: Array = []
	var dirs := ["res://scripts"]
	var files: Array = []
	while not dirs.is_empty():
		var d: String = dirs.pop_back()
		for sub in DirAccess.get_directories_at(d):
			dirs.append(d + "/" + sub)
		for f in DirAccess.get_files_at(d):
			if f.ends_with(".gd"):
				files.append(d + "/" + f)
	for f in files:
		var sc: Script = load(f)
		if sc == null or not sc.can_instantiate():
			bad.append(f)
	check(bad.is_empty() and files.size() >= 15, "Alle %d Skripte kompilieren %s" % [files.size(), bad])


func check(cond: bool, what: String) -> void:
	count += 1
	if cond:
		print("  ok      ", what)
	else:
		fails += 1
		printerr("  FEHLER  ", what)


func fresh(room := 0) -> BattleState:
	var run := RunState.new("Pixmiez", 1)
	var st := BattleState.new(run, GameData.FOES[room])
	st.e.frozen = 999.0  # Gegner steht still, solange ein Test nichts anderes will
	return st


func step(st: BattleState, seconds: float) -> void:
	var dt := 1.0 / 60.0
	var n := int(seconds / dt)
	for i in n:
		st.update(dt)


func test_data() -> void:
	check(GameData.mult("Feuer", "Code") == 1.5, "Feuer schlägt Code")
	check(GameData.mult("Code", "Feuer") == 0.75, "Code gegen Feuer schwach")
	check(GameData.mult("Elektro", "Virus") == 1.5, "Elektro schlägt Virus")
	var run := RunState.new("Pixmiez", 1)
	check(run.hp == 100 and run.deck.size() == 8, "Pixmiez startet mit 100 HP und 8 Chips")


func test_hand() -> void:
	var st := fresh()
	check(st.hand.size() == 3 and st.draw_pile.size() == 5, "3 Chips auf der Hand, 5 im Stapel")
	check(st.hand.all(func(s): return s.rem == 0.0), "Starthand ist sofort bereit")


func test_projectile() -> void:
	var st := fresh()
	st.hand[0].chip = "Pixelstrahl"
	st.use_slot(0)
	step(st, 0.6)
	check(st.e.hp == 50, "Pixelstrahl trifft Bugsy in derselben Reihe (70 → 50), ist %d" % st.e.hp)
	var st2 := fresh()
	st2.e.r = 0
	st2.hand[0].chip = "Pixelstrahl"
	st2.use_slot(0)
	step(st2, 0.8)
	check(st2.e.hp == 70, "Pixelstrahl verfehlt andere Reihe")


func test_reflex_and_firewall() -> void:
	var st := fresh()
	st.hurt_player(10)
	check(st.run.hp == 100 and st.reflex == 0, "Katzenreflex weicht dem ersten Treffer aus")
	st.hurt_player(10)
	check(st.run.hp == 90, "Zweiter Treffer kostet HP")
	st.hand[0].chip = "Firewall"
	st.use_slot(0)
	st.hurt_player(10)
	check(st.run.hp == 90, "Firewall blockt")


func test_enemy_warning() -> void:
	var st := fresh()
	st.reflex = 0
	st.e.frozen = 0.0
	st.e.move_t = 99.0
	st.e.atk_t = 0.01
	step(st, 0.05)
	check(st.warns.size() == 1, "Gegner legt eine Warnung")
	var cells: Array = st.warns[0].cells
	check(cells.has(Vector2i(st.p.c, st.p.r)), "Warnung liegt auf der Spielerreihe")
	step(st, 0.75)
	check(st.run.hp == 90, "Stehenbleiben kostet 10 HP, ist %d" % st.run.hp)
	var st2 := fresh()
	st2.reflex = 0
	st2.e.frozen = 0.0
	st2.e.move_t = 99.0
	st2.e.atk_t = 0.01
	step(st2, 0.05)
	st2.move_player(0, -1)
	step(st2, 0.75)
	check(st2.run.hp == 100, "Ausweichen verhindert Schaden")


func test_queue() -> void:
	var st := fresh()
	st.hand[0].chip = "Pixelstrahl"
	st.use_slot(0)
	check(st.hand[0].rem > 0, "Nachgezogener Chip muss laden")
	st.use_slot(0)
	check(st.hand[0].queued, "Ladenden Chip vormerken")
	var before: int = st.run.chips_used
	step(st, 5.0)
	check(st.run.chips_used == before + 1, "Vorgemerkter Chip feuert automatisch")


func test_glutball() -> void:
	var st := fresh()
	st.e.c = st.p.c
	st.e.r = st.p.r
	st.hand[0].chip = "Glutball"
	st.use_slot(0)
	step(st, 0.4)
	check(st.e.hp == 25 and st.e.burn == 3, "Glutball: 45 im Zentrum + Brand, HP %d" % st.e.hp)


func test_special() -> void:
	var st := fresh()
	st.sp = 100.0
	st.use_special()
	step(st, 0.3)
	check(st.e.hp == 30 and st.sp == 0.0, "Pixelsprung: 40 Schaden, Leiste leer, HP %d" % st.e.hp)


func test_pop_close() -> void:
	var st := fresh(3)
	st.pops.append({"c": 0, "r": 1, "t": 3.0, "max": 3.0})
	st.move_player(-1, 0)
	check(st.pops.is_empty(), "Bitmilbe wird beim Draufsteigen zertreten")


func test_choices() -> void:
	var run := RunState.new("Pixmiez", 3)
	var ch := run.roll_choices()
	check(ch.size() == 3 and ch[0] != ch[1] and ch[1] != ch[2] and ch[0] != ch[2], "Chipwahl: 3 verschiedene Chips")


## Chip auf Slot 0 legen und spielen
func play(st: BattleState, chip: String) -> void:
	st.hand[0].chip = chip
	st.hand[0].rem = 0.0
	st.use_slot(0)


func test_new_chips() -> void:
	var st := fresh()
	play(st, "Doppelklick")
	step(st, 0.8)
	check(st.e.hp == 70 - 24, "Doppelklick: zwei Treffer à 12 (HP %d)" % st.e.hp)
	st = fresh()
	st.e.r = 0
	play(st, "Wurmloch")
	check(st.e.r == st.p.r and st.e.hp == 60, "Wurmloch zieht den Gegner in deine Reihe, 10 Schaden")
	st = fresh()
	st.e.r = 0
	play(st, "Laserschuss")
	check(st.e.hp == 70, "Laserschuss verfehlt andere Reihe")
	st.e.r = st.p.r
	play(st, "Laserschuss")
	check(st.e.hp == 45, "Laserschuss trifft sofort in deiner Reihe (70 → %d)" % st.e.hp)
	st = fresh()
	st.e.c = 0
	st.p.c = 2
	play(st, "Blitzlanze")
	check(st.e.hp == 70, "Blitzlanze verfehlt, wenn die Spalten nicht passen")
	st.p.c = 0
	play(st, "Blitzlanze")
	check(st.e.hp == 70 - 45, "Blitzlanze trifft passende Spalte, Elektro schlägt Virus (70 → %d)" % st.e.hp)
	st = fresh()
	play(st, "Portscan")
	play(st, "Laserschuss")
	check(st.e.hp == 70 - 38, "Portscan: +50 %% auf den nächsten Treffer (70 → %d)" % st.e.hp)
	st = fresh()
	st.e.poison = 5
	play(st, "Datenfresser")
	step(st, 0.4)
	check(st.e.hp <= 70 - 30, "Datenfresser doppelt gegen Gift (70 → %d)" % st.e.hp)
	st = fresh()
	st.reflex = 0
	play(st, "Hitzeschild")
	st.hurt_player(10)
	check(st.run.hp == 100 and st.e.burn == 3, "Hitzeschild blockt und setzt den Angreifer in Brand")
	st = fresh()
	st.e.frozen = 0.0
	st.e.move_t = 99.0
	st.e.atk_t = 0.01
	step(st, 0.05)
	play(st, "Blendgranate")
	check(st.warns.is_empty() and st.e.atk_t > 1.0, "Blendgranate bricht den laufenden Angriff ab")
	st = fresh()
	st.e.frozen = 0.0
	st.e.atk_t = 1.0
	play(st, "Strudel")
	step(st, 1.0)
	check(absf(st.e.atk_t - 0.5) < 0.05, "Strudel: Gegner halb so schnell (Timer %.2f)" % st.e.atk_t)
	st = fresh()
	st.reflex = 0
	play(st, "Nebel")
	var dodged := 0
	for i in 40:
		st.mist = 3.0
		var hp0: int = st.run.hp
		st.hurt_player(1)
		if st.run.hp == hp0:
			dodged += 1
	check(dodged > 8 and dodged < 32, "Nebel: etwa die Hälfte der Treffer verfehlt (%d/40)" % dodged)
	st = fresh()
	st.run.hp = 50
	play(st, "Neustart")
	check(st.run.hp == 65 and st.hand.all(func(h): return h.rem == 0.0), "Neustart: +15 HP und eine sofort bereite Hand")
	st = fresh()
	play(st, "Funkenregen")
	step(st, 0.5)
	check(st.e.hp == 45 and st.e.burn >= 2, "Funkenregen: 25 + Brand (70 → %d)" % st.e.hp)


## Jeder Chip lässt sich in jeder Lage spielen, ohne dass etwas abstürzt
func test_all_chips_run() -> void:
	var n := 0
	for chip in GameData.CHIPS:
		var st := fresh()
		st.e.frozen = 0.0
		play(st, chip)
		step(st, 2.0)
		n += 1
	check(n == GameData.CHIPS.size() and n >= 27, "Alle %d Chips laufen fehlerfrei" % n)
	var per_el := {}
	for chip in GameData.CHIPS:
		per_el[GameData.CHIPS[chip].el] = per_el.get(GameData.CHIPS[chip].el, 0) + 1
	check(per_el.values().all(func(v): return v >= 4), "Jedes Element hat mindestens 4 Chips %s" % [per_el])


func test_new_events() -> void:
	var run := RunState.new("Pixmiez", 3)
	var before := run.deck.size()
	check(Rooms.event_apply(run, "backup", "copy") == "copy", "Backup-Station lässt einen Chip kopieren")
	Rooms.event_apply(run, "minibot", "home")
	check(run.deck.size() == before + 1 and run.deck.has("Mini-Bot"), "Verirrter Mini-Bot kommt ins Deck")
	var commons := run.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich").size()
	Rooms.event_apply(run, "update", "install")
	var commons2 := run.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich").size()
	check(commons2 == commons - 1, "Update macht einen gewöhnlichen Chip selten")
	var f0 := run.frag
	Rooms.event_apply(run, "beeren", "collect")
	check(run.frag == f0 + 25, "Bit-Beeren: +25 Fragmente")
	var all_ok := true
	for key in Rooms.EVENTS:
		for o in Rooms.event_options(run, key):
			if o.label == "" or o.desc == "":
				all_ok = false
	check(all_ok and Rooms.EVENTS.size() == 17, "17 Ereignisse, alle Optionen beschriftet")
	# Zonen-Ereignisse
	var zv := Rooms.events_for_zone("vulkan")
	var zs := Rooms.events_for_zone("sumpf")
	var zw := Rooms.events_for_zone("wiesen")
	check(zv.has("schmiede") and not zv.has("irrlicht") and not zv.has("beeren") and zv.has("backup") and zv.size() == 10 and zs.size() == 10 and zw.size() == 9,
		"Ereignisse je Zone: Wiesen %d, Vulkan %d, Sümpfe %d (6 überall + eigene)" % [zw.size(), zv.size(), zs.size()])
	var rz := RunState.new("Pixmiez", 5)
	rz.map = ZoneMap.generate(rz.rng, "sumpf")
	var picked := {}
	for i in 12:
		picked[Rooms.pick_event(rz)] = true
	check(picked.keys().all(func(k): return zs.has(k)) and picked.size() >= 9, "Im Sumpf kommen nur Sumpf- und allgemeine Ereignisse vor, keine Wiederholung")
	var r3 := RunState.new("Pixmiez", 4)
	var fe := int(r3.total_praeg().get("Feuer", 0))
	Rooms.event_apply(r3, "lavaquelle", "absorb")
	check(int(r3.total_praeg().get("Feuer", 0)) == fe + Rooms.EVENT_PRAEG, "Heiße Quelle: Glut aufnehmen gibt Feuer-Prägung")
	Rooms.event_apply(r3, "irrlicht", "charge")
	check(int(r3.praeg.get("Elektro", 0)) == Rooms.EVENT_PRAEG and r3.evo_status().dirs.any(func(d): return d.el == "Elektro" and d.n >= Rooms.EVENT_PRAEG), "Irrlicht: Elektro-Prägung zählt für Pixmiez’ Elektro-Richtung")
	var commons3 := r3.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich").size()
	var hp3 := r3.hp
	Rooms.event_apply(r3, "schmiede", "forge")
	check(r3.deck.filter(func(c): return GameData.CHIPS[c].rar == "Gewöhnlich").size() == commons3 - 1 and r3.hp == hp3 - 10 and r3.deck.any(func(c): return GameData.CHIPS[c].rar == "Episch"), "Glut-Schmiede: gewöhnlicher Chip wird episch, kostet 10 HP")
	check(Rooms.event_apply(r3, "datenleitung", "clean") == "remove", "Datenleitung: Ausmisten lässt einen Chip entfernen")
	Rooms.event_apply(r3, "firewallriss", "sneak")
	var r3foe := r3.foe_for({"type": "fight"})
	var stw := BattleState.new(r3, r3foe)
	check(not r3.foe_weak and stw.e.hp == roundi(r3foe.hp * 0.75), "Riss in der Firewall: nächster Gegner startet mit 75 %% HP (%d/%d)" % [stw.e.hp, r3foe.hp])
	var hurt_ok := true
	for i in 20:
		var rr := RunState.new("Tröpfel", 100 + i)
		for pair in [["ascheregen", "dig"], ["irrlicht", "follow"], ["giftmoor", "dive"], ["datenleitung", "read"]]:
			if Rooms.event_options(rr, pair[0]).filter(func(o): return o.id == pair[1])[0].enabled:
				Rooms.event_apply(rr, pair[0], pair[1])
		if rr.hp <= 0:
			hurt_ok = false
	check(hurt_ok, "Riskante Ereignisse können nie auf 0 HP bringen")


func test_difficulty() -> void:
	var node := {"type": "boss"}
	var hp := []
	var dmg := []
	for d in 3:
		var run := RunState.new("Pixmiez", 1)
		run.difficulty = d
		var f := run.foe_for(node)
		hp.append(f.hp)
		dmg.append(f.dmg)
	check(hp[0] < hp[1] and hp[1] < hp[2] and hp[1] == 320, "Schwierigkeit skaliert Boss-HP %s" % [hp])
	check(dmg[0] < dmg[1] and dmg[1] < dmg[2], "Schwierigkeit skaliert Schaden %s" % [dmg])
	var run2 := RunState.new("Pixmiez", 1)
	run2.difficulty = 0
	var st := BattleState.new(run2, run2.foe_for({"type": "fight"}))
	st.e.move_t = 99.0
	st.e.atk_t = 0.01
	step(st, 0.02)
	check(st.warns[0].max > BattleState.WARN_TIME, "Entspannt: längere Vorwarnung (%.2f s)" % st.warns[0].max)


func test_new_foes() -> void:
	# Kreuz-Muster
	var run := RunState.new("Pixmiez", 4)
	var st := BattleState.new(run, GameData.FOES[4])
	st.p.c = 0
	st.p.r = 0
	st.e.move_t = 99.0
	st.e.atk_t = 0.01
	step(st, 0.05)
	var cells: Array = st.warns[0].cells
	check(cells.size() == 3 and cells.has(Vector2i(0, 0)) and cells.has(Vector2i(1, 0)) and cells.has(Vector2i(0, 1)), "Chiffrekäfer: Kreuz um den Spieler (in der Ecke 3 Felder)")
	# Wand-Muster: nie die Reihe des Spielers frei
	var ok := true
	for i in 30:
		var st2 := BattleState.new(RunState.new("Pixmiez", i), GameData.FOES[6])
		st2.p.r = i % 3
		st2.e.move_t = 99.0
		st2.e.atk_t = 0.01
		step(st2, 0.05)
		var c2: Array = st2.warns[0].cells
		if c2.size() != 6 or not c2.has(Vector2i(0, st2.p.r)):
			ok = false
	check(ok, "Glutraupe: Wand über zwei Reihen, die Spielerreihe ist nie sicher")
	var sprites_ok := true
	for f in GameData.FOES:
		if not ResourceLoader.exists("res://assets/sprites/%s.png" % PixelCanvas.SPRITE_FILES[f.spr]):
			sprites_ok = false
	check(sprites_ok and GameData.FOES.size() == 18, "Alle %d Gegner haben ein Sprite" % GameData.FOES.size())
	# Jeder Gegner lässt sich mit dem Autopilot besiegen
	var all_end := true
	for i in GameData.FOES.size():
		seed(i)
		var r := RunState.new("Pixmiez", i)
		var s := BattleState.new(r, GameData.FOES[i])
		var bot := BattleBot.new(0.25)
		var t := 0.0
		while not s.over and t < 180.0:
			bot.act(s)
			s.update(1.0 / 30.0)
			t += 1.0 / 30.0
		if not s.over:
			all_end = false
	check(all_end, "Jeder Gegner-Kampf endet")


func test_meta() -> void:
	var real_path := SaveGame.path
	var real_data := SaveGame.data.duplicate(true)
	SaveGame.path = "user://test_savegame.json"
	SaveGame.persist = true
	var m := SaveGame.new_game("Funkling")
	check(SaveGame.has_save() and SaveGame.team().size() == 1 and SaveGame.data.dex.has("Funkling"), "Neues Spiel: Starter im Team und im Dex")
	# Run 1: Feuer-Prägung, 3 Siege, Rookie erreicht
	var run := RunState.from_monster(m, 1)
	run.chips_used = GameData.EVO_AT[2]
	run.praeg = {"Feuer": GameData.EVO_AT[2], "Neutral": 5}
	run.try_evolve()
	run.fights_won = 3
	var sum := SaveGame.record_run(run, false)
	var m2 := SaveGame.monster(int(m.id))
	check(m2.form == "Glutbyte" and int(m2.stage) == 2 and int(m2.chips) == GameData.EVO_AT[2], "Evolution bleibt nach dem Run erhalten (auch bei Niederlage)")
	check(not sum.egg.is_empty() and SaveGame.nest().size() == 1, "Ei nach Run mit mindestens 2 Siegen")
	check(sum.new_dex.has("Glutbyte"), "Neue Form landet im Monsterdex")
	# Laden/Speichern
	SaveGame.load_game()
	check(SaveGame.monster(int(m.id)).form == "Glutbyte" and SaveGame.nest().size() == 1, "Spielstand übersteht Speichern und Laden")
	# Run 2: startet als Rookie mit Lebenszeit-Prägung, Champion-Schwelle zählt gesamt
	var run2 := RunState.from_monster(SaveGame.monster(int(m.id)), 2)
	check(run2.stage == 2 and run2.form == "Glutbyte" and run2.max_hp == 90, "Nächster Run startet als Rookie mit +10 HP")
	run2.chips_used = GameData.EVO_AT[3] - GameData.EVO_AT[2]
	run2.praeg = {"Feuer": 30}
	check(run2.try_evolve().get("to", "") == "Magmawulf", "Champion-Schwelle zählt Lebenszeit-Prägung")
	# Eier reifen: gewöhnliches Ei schlüpft nach 1 Run
	SaveGame.data.nest = [{"rarity": "Gewöhnlich", "species": "Tröpfel", "runs_left": 1}, {"rarity": "Episch", "species": "Pixmiez", "runs_left": 3}]
	run2.fights_won = 0
	SaveGame.record_run(run2, false)
	check(SaveGame.ready_eggs().size() == 1 and int(SaveGame.nest()[1].runs_left) == 2, "Eier reifen pro Run (gewöhnlich 1, episch 3)")
	var h := SaveGame.hatch_next()
	check(h.get("species", "") == "Tröpfel" and SaveGame.team().size() == 2 and h.new_in_dex, "Ei schlüpft: neues Monster im Team und im Dex")
	var ok_rar := true
	for r in SaveGame.EGG_RUNS:
		if SaveGame.egg_pool(r).is_empty():
			ok_rar = false
	check(ok_rar and SaveGame.EGG_RUNS.Legendär == 5 and SaveGame.EGG_RUNS.Gewöhnlich == 1, "Ei-Seltenheiten: Gewöhnlich 1 … Legendär 5 Runs")
	var full_egg := {"rarity": "Episch", "species": "Pixmiez", "runs_left": 3}
	SaveGame.data.nest = [full_egg.duplicate(), full_egg.duplicate(), full_egg.duplicate()]
	var run3 := RunState.new("Pixmiez", 3)
	run3.fights_won = 4
	check(SaveGame.record_run(run3, true).nest_full, "Volles Brutnest: kein weiteres Ei")
	SaveGame.reset()
	check(not FileAccess.file_exists("user://test_savegame.json"), "Spielstand löschen entfernt die Datei")
	SaveGame.path = real_path
	SaveGame.data = real_data


func test_fusion() -> void:
	var real_path := SaveGame.path
	var real_data := SaveGame.data.duplicate(true)
	SaveGame.persist = false
	SaveGame.new_game("Brummbit")
	var a: Dictionary = SaveGame.team()[0]
	var b := SaveGame.add_monster("Kekso")
	var c := SaveGame.add_monster("Lumi")
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	# Fehlversuch: kostet nichts, gibt ein Gerücht
	SaveGame.data.frag = 50
	var r1 := SaveGame.try_fuse(int(a.id), int(c.id), rng)
	check(not r1.ok and SaveGame.frag() == 50 and SaveGame.data.hints.size() == 1, "Fehlversuch kostet nichts und gibt ein Gerücht")
	# Rezept passt, aber zu wenig Fragmente
	var r2 := SaveGame.try_fuse(int(a.id), int(b.id), rng)
	check(not r2.ok and SaveGame.team().size() == 3, "Richtiges Rezept, aber zu wenig Fragmente: nichts passiert")
	# Erfolg
	SaveGame.data.frag = 130
	var r3 := SaveGame.try_fuse(int(b.id), int(a.id), rng)
	var team_forms: Array = SaveGame.team().map(func(m): return m.form)
	check(r3.ok and r3.result == "Schlummerbit" and SaveGame.frag() == 30 and team_forms == ["Lumi", "Schlummerbit"], "Kekso + Brummbit = Schlummerbit (100 Fragmente, beide Eltern gehen auf)")
	check(SaveGame.data.recipes.has("Schlummerbit") and SaveGame.data.dex.has("Schlummerbit"), "Rezept und Dex-Eintrag gespeichert")
	var fused := SaveGame.monster(int(r3.id))
	var run := RunState.from_monster(fused, 1)
	check(run.stage == 3 and run.max_hp == GameData.MONS["Schlummerbit"].hp + 20 and run.evo_need() == 0, "Fusion kämpft auf Champion-Niveau (%d HP), keine weitere Evolution" % run.max_hp)
	# Spukatz braucht eine Virus-Katze
	var q := SaveGame.add_monster("Quakli")
	var px := SaveGame.add_monster("Pixmiez")
	SaveGame.data.frag = 200
	var r4 := SaveGame.try_fuse(int(q.id), int(px.id), rng)
	check(not r4.ok and SaveGame.frag() == 200, "Spukatz klappt nicht mit einer normalen Pixmiez")
	px.form = "Virulina"
	px.stage = 2
	var r5 := SaveGame.try_fuse(int(q.id), int(px.id), rng)
	check(r5.ok and r5.result == "Spukatz", "Quakli + Virulina = Spukatz")
	# Passive der Fusionen
	var st := BattleState.new(RunState.new("Wolkerich", 1), GameData.FOES[0])
	check(st.bubble == 30, "Wolkendecke: Kampf beginnt mit Schutzblase")
	var st2 := BattleState.new(RunState.new("Schlummerbit", 1), GameData.FOES[0])
	var hp_s: int = st2.run.hp
	st2.hurt_player(20)
	check(hp_s - st2.run.hp == 15, "Winterschlaf: dickes Fell, 25 % weniger Schaden")
	var st2b := BattleState.new(RunState.new("Pustebacke", 1), GameData.FOES[0])
	var dodged := 0
	for i in 200:
		st2b.run.hp = 90
		var got := st2b.hurt_player(5)
		if got == 0:
			dodged += 1
	check(dodged > 10 and dodged < 60 and st2b.e.poison > 0, "Schwebegas: weicht etwa 15 %% aus (%d/200) und vergiftet Angreifer" % dodged)
	var stw := BattleState.new(RunState.new("Wolperling", 1), GameData.FOES[0])
	stw.move_player(1, 0)
	check(is_equal_approx(stw.p.cd, GameData.MONS.Wolperling.move * 0.5), "Mischwesen: Wolperling bewegt sich doppelt so schnell")
	var dodges := 0
	for i in 200:
		var st3 := BattleState.new(RunState.new("Spukatz", i), GameData.FOES[0])
		st3.hurt_player(5)
		if st3.run.hp == st3.run.max_hp:
			dodges += 1
	check(dodges > 20 and dodges < 60, "Spuk: etwa 20 %% Ausweichen (%d/200)" % dodges)
	# Fragmente werden am Run-Ende gerettet
	var before := SaveGame.frag()
	var run6 := RunState.new("Pixmiez", 6)
	run6.frag = 42
	SaveGame.record_run(run6, false)
	check(SaveGame.frag() == before + 42, "Übrige Fragmente landen auf der Station")
	SaveGame.path = real_path
	SaveGame.data = real_data
	SaveGame.persist = true


func test_zone2() -> void:
	var real_data := SaveGame.data.duplicate(true)
	SaveGame.persist = false
	SaveGame.new_game("Tröpfel")
	check(SaveGame.unlocked_zones() == ["wiesen"], "Zu Beginn nur die Cache-Wiesen frei")
	var run := RunState.from_monster(SaveGame.team()[0], 1)
	var sum := SaveGame.record_run(run, true)
	check(sum.get("unlocked", "") == "vulkan" and SaveGame.unlocked_zones() == ["wiesen", "vulkan"], "Boss der Cache-Wiesen besiegt: Firewall-Vulkan frei")
	SaveGame.data.cleared = []
	SaveGame.unlock_all_zones()
	check(SaveGame.unlocked_zones() == GameData.ZONE_ORDER, "Testfunktion schaltet alle Zonen frei")
	var r2 := RunState.from_monster(SaveGame.team()[0], 2, "vulkan")
	check(r2.map.zone == "vulkan" and r2.map.zone_name == "Firewall-Vulkan", "Run im Firewall-Vulkan")
	var boss := r2.foe_for({"type": "boss"})
	check(boss.name == "Glutkernskarabäus" and boss.hp == 420, "Boss im Vulkan: Glutkernskarabäus")
	r2.enter(r2.next_choices()[0])
	var f := r2.foe_for({"type": "fight"})
	var base: Dictionary = GameData.FOES.filter(func(x): return x.name == f.name)[0]
	check([7, 9, 5].has(GameData.FOES.find(base)) and f.hp == roundi(base.hp * 1.25), "Vulkan-Gegner aus eigenem Pool, 25 %% zäher (%s %d)" % [f.name, f.hp])
	SaveGame.data = real_data
	SaveGame.persist = true
	# Lava: Feld des Spielers brennt, bis man es verlässt
	var st := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[9])
	st.reflex = 0
	st.def = st.def.duplicate()
	st.def.pat = ["lava"]
	st.def.tele = false
	st.e.move_t = 99.0
	st.e.atk_t = 0.01
	step(st, 0.05)
	check(st.warns.size() == 1 and st.warns[0].lava and st.warns[0].cells.has(Vector2i(st.p.c, st.p.r)), "Aschefalter: Lava-Warnung auf dem Spielerfeld")
	st.e.atk_t = 99.0
	step(st, 0.8)
	check(not st.hazards.is_empty(), "Lava liegt nach der Warnung")
	var hp0: int = st.run.hp
	step(st, 1.3)
	check(st.run.hp < hp0, "Auf Lava stehen kostet HP (%d → %d)" % [hp0, st.run.hp])
	st.move_player(0, -1 if st.p.r > 0 else 1)
	var hp1: int = st.run.hp
	step(st, 1.0)
	var still_on := st.hazards.any(func(hz): return hz.c == st.p.c and hz.r == st.p.r)
	check(still_on or st.run.hp == hp1, "Runter von der Lava: kein weiterer Schaden")
	step(st, 3.0)
	check(st.hazards.is_empty(), "Lava verschwindet nach 3 s")
	# Zwei Spalten
	var st2 := BattleState.new(RunState.new("Pixmiez", 2), GameData.FOES[8])
	st2.p.c = 0
	st2.e.move_t = 99.0
	st2.e.atk_t = 0.01
	step(st2, 0.05)
	var cells: Array = st2.warns[0].cells
	check(cells.size() == 6 and cells.has(Vector2i(0, 0)) and cells.has(Vector2i(1, 2)), "Brandmauerassel: zwei Spalten inkl. der des Spielers")
	# Boss setzt ab halber HP Felder in Brand statt Bitmilben
	var st3 := BattleState.new(RunState.new("Pixmiez", 3), GameData.FOES[10])
	st3.e.hp = 200
	st3.e.move_t = 99.0
	st3.e.atk_t = 99.0
	st3.e.pop_t = 0.01
	step(st3, 0.05)
	check(st3.pops.is_empty() and st3.warns.any(func(w): return w.lava), "Glutkernskarabäus: Lava statt Bitmilben")
	# Komplette Vulkan-Runs laufen durch
	var stuck := 0
	var wins := 0
	for sv in 12:
		seed(sv)
		var run3 := RunState.new(["Tröpfel", "Kaskadi", "Pixmiez"][sv % 3] if sv % 3 == 0 else "Tröpfel", sv)
		run3.map = ZoneMap.generate(run3.rng, "vulkan")
		var bot := BattleBot.new(0.25)
		while true:
			var ch := run3.next_choices()
			if ch.is_empty():
				break
			var node := run3.enter(ch[0])
			if node.type in ["fight", "elite", "boss"]:
				var s := BattleState.new(run3, run3.foe_for(node))
				var t := 0.0
				while not s.over and t < 180.0:
					bot.act(s)
					s.update(1.0 / 30.0)
					t += 1.0 / 30.0
				if not s.over:
					stuck += 1
					break
				if s.outcome == "lost":
					break
				if node.type == "boss":
					wins += 1
					break
				run3.heal(10)
	check(stuck == 0, "Vulkan-Runs: kein Kampf hängt")
	print("  info    Vulkan-Autopilot: %d/12 Runs gewonnen" % wins)


func test_zone3() -> void:
	# Freischaltung nach dem Vulkan
	var real_data := SaveGame.data.duplicate(true)
	SaveGame.persist = false
	SaveGame.new_game("Lumi")
	SaveGame.data.cleared = ["wiesen"]
	check(not SaveGame.zone_unlocked("sumpf"), "Viren-Sümpfe erst nach dem Vulkan")
	var rv := RunState.from_monster(SaveGame.team()[0], 1, "vulkan")
	var sum := SaveGame.record_run(rv, true)
	check(sum.get("unlocked", "") == "sumpf" and SaveGame.zone_unlocked("sumpf"), "Vulkan-Boss besiegt: Viren-Sümpfe frei")
	var rs := RunState.from_monster(SaveGame.team()[0], 2, "sumpf")
	check(rs.foe_for({"type": "boss"}).name == "Schwarmkönigin", "Boss der Sümpfe: Schwarmkönigin")
	SaveGame.data = real_data
	SaveGame.persist = true
	# Schleim macht langsam, schadet aber nicht
	var st := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[12])
	st.reflex = 0
	st.e.frozen = 99.0
	st.hazards.append({"c": st.p.c, "r": st.p.r, "t": 4.0, "tick": 0.0, "kind": "slime"})
	var hp0: int = st.run.hp
	step(st, 1.0)
	check(st.run.hp == hp0, "Schleim macht keinen Schaden")
	st.move_player(0, -1 if st.p.r > 0 else 1)
	check(st.p.cd > st.mon.move * 2.5, "Schleim: Bewegung dreimal so langsam (%.2f s)" % st.p.cd)
	# Lebensraub
	var st2 := BattleState.new(RunState.new("Pixmiez", 2), GameData.FOES[11])
	st2.reflex = 0
	st2.e.hp = 30
	st2.e.move_t = 99.0
	st2.e.atk_t = 0.01
	step(st2, 0.05)
	step(st2, 0.8)
	check(st2.run.hp < 100 and st2.e.hp > 30, "Saugmücke heilt sich bei Treffern (HP %d)" % st2.e.hp)
	# Glitchblüte bewegt sich nicht und streut Glitch-Sporen
	var st3 := BattleState.new(RunState.new("Pixmiez", 3), GameData.FOES[13])
	var pos := Vector2i(st3.e.c, st3.e.r)
	var got_pop := false
	for i in 400:
		st3.update(1.0 / 60.0)
		if not st3.pops.is_empty():
			got_pop = true
		if st3.over:
			break
	check(Vector2i(st3.e.c, st3.e.r) == pos and got_pop, "Glitchblüte bleibt stehen und streut Glitch-Sporen")
	# Komplette Sumpf-Runs laufen durch
	var stuck := 0
	var wins := 0
	for sv in 9:
		seed(sv)
		var run3 := RunState.new(["Lumi", "Pixmiez", "Brummbit"][sv % 3], sv)
		run3.map = ZoneMap.generate(run3.rng, "sumpf")
		var bot := BattleBot.new(0.25)
		while true:
			var ch := run3.next_choices()
			if ch.is_empty():
				break
			var node := run3.enter(ch[0])
			if node.type in ["fight", "elite", "boss"]:
				var s := BattleState.new(run3, run3.foe_for(node))
				var t := 0.0
				while not s.over and t < 180.0:
					bot.act(s)
					s.update(1.0 / 30.0)
					t += 1.0 / 30.0
				if not s.over:
					stuck += 1
					break
				if s.outcome == "lost":
					break
				if node.type == "boss":
					wins += 1
					break
				run3.heal(10)
	check(stuck == 0, "Sumpf-Runs: kein Kampf hängt")
	print("  info    Sumpf-Autopilot: %d/9 Runs gewonnen" % wins)


func test_tutorial() -> void:
	var run := RunState.new("Pixmiez", 1)
	var st := BattleState.new(run, GameData.FOES[0])
	var tut := Tutorial.new()
	st.e.atk_t = 0.5
	for i in 3:
		st.move_player(0, -1 if st.p.r > 0 else 1)
		for k in 20:
			st.update(1.0 / 60.0)
			tut.update(st, 1.0 / 60.0)
	check(st.warns.is_empty() and tut.step == Tutorial.Step.CHIP, "Tutorial: Gegner greift beim Bewegen-Üben nicht an, nach 3 Schritten weiter")
	check(st.e.r == st.p.r, "Tutorial: Gegner steht für den ersten Schuss in deiner Reihe")
	st.e.frozen = 5.0
	st.hand[0].chip = "Pixelstrahl"
	st.hand[0].rem = 0.0
	st.use_slot(0)
	for k in 40:
		st.update(1.0 / 60.0)
		tut.update(st, 1.0 / 60.0)
	check(tut.step == Tutorial.Step.DODGE, "Tutorial: Treffer mit dem Chip → Ausweichen üben")
	st.e.frozen = 0.0
	var bot := BattleBot.new(0.0)
	var t := 0.0
	while tut.step == Tutorial.Step.DODGE and t < 20.0:
		bot.act(st)
		st.sp = minf(st.sp, 50.0)
		st.update(1.0 / 60.0)
		tut.update(st, 1.0 / 60.0)
		t += 1.0 / 60.0
	check(tut.step == Tutorial.Step.SPECIAL and st.sp == 100.0, "Tutorial: 2× ausgewichen → Signatur-Leiste voll")
	st.use_special()
	tut.update(st, 1.0 / 60.0)
	check(tut.just_finished and st.e.hp > 0, "Tutorial abgeschlossen, Gegner lebt noch für den freien Kampf")


func test_evolution() -> void:
	var need: int = GameData.EVO_AT[2]
	# Fall des Produzenten: viel Elektro, kaum Code → früher Firewallo, jetzt Prismiez
	var r := RunState.new("Pixmiez", 1)
	r.praeg = {"Neutral": 20, "Elektro": need - 1, "Code": 1}
	check(r.try_evolve().get("to", "") == "Prismiez", "Viel Elektro, kaum Code: Pixmiez → Prismiez (nicht mehr Firewallo)")
	# Neutral zählt nicht zur Schwelle
	var r1 := RunState.new("Pixmiez", 1)
	r1.praeg = {"Neutral": 40, "Code": need - 1}
	check(r1.try_evolve().is_empty() and r1.evo_status().reason.begins_with("Noch 1"), "Neutrale Chips zählen nicht: unter der Schwelle keine Evolution")
	r1.praeg.Code = need
	var ev := r1.try_evolve()
	check(ev.get("to", "") == "Firewallo" and r1.stage == 2 and r1.max_hp == 110, "Code-Prägung: Pixmiez → Firewallo, +10 max. HP")
	r1.praeg.Code = GameData.EVO_AT[3]
	check(r1.try_evolve().get("to", "") == "Bollwerkatz" and r1.stage == 3, "Champion-Schwelle: Firewallo → Bollwerkatz")
	check(r1.try_evolve().is_empty(), "Champion ohne weitere Stufe bleibt")
	# Gleichstand wartet
	var r2 := RunState.new("Pixmiez", 1)
	r2.praeg = {"Virus": 6, "Code": 6}
	check(r2.try_evolve().is_empty() and r2.evo_status().reason.begins_with("Gleichstand"), "Gleichstand: Evolution wartet (keine Zufallsentscheidung)")
	# Führung zu knapp (nur 1 Chip Vorsprung) wartet – Elemente ohne Richtung verwässern nicht
	var r3 := RunState.new("Kekso", 1)
	r3.praeg = {"Virus": 4, "Elektro": 3, "Code": 3, "Feuer": 3}
	check(r3.try_evolve().is_empty() and r3.evo_status().reason.begins_with("Führung zu knapp"), "1 Chip Vorsprung: Evolution wartet")
	var r3b := RunState.new("Kekso", 1)
	r3b.praeg = {"Virus": 7, "Elektro": 5, "Code": 20}
	check(r3b.try_evolve().get("to", "") == "Tracko", "2 Vorsprung reicht, viele Code-Chips (ohne Wirkung) verwässern nicht")
	# Elemente ohne Richtung werden angezeigt, lenken aber nicht
	var s3 := r3.evo_status()
	check(s3.other.has("Code") and s3.other.has("Feuer") and s3.dirs.size() == 2, "Kekso: Code/Feuer ohne Wirkung, zwei Richtungen")
	var r4 := RunState.new("Tröpfel", 1)
	r4.praeg = {"Wasser": need}
	r4.eis = 4
	check(r4.try_evolve().get("to", "") == "Frostbyte", "Tröpfel mit 4× Eisfeld → Frostbyte")
	var r5 := RunState.new("Funkling", 1)
	r5.praeg = {"Feuer": 5, "Code": 9}
	check(r5.try_evolve().get("to", "") == "Overclocko", "Funkling mit mehr Code als Feuer → Overclocko")
	# Startdecks: überwiegend neutral, genau ein Chip je Richtung
	var fair := true
	for sp in GameData.MONS:
		var M: Dictionary = GameData.MONS[sp]
		if M.get("fusion", false):
			continue
		for el in M.evo:
			var n: int = M.deck.filter(func(c): return GameData.CHIPS[c].el == el).size()
			if n != 1:
				fair = false
				printerr("    %s: %d× %s im Startdeck" % [sp, n, el])
		var off: Array = M.deck.filter(func(c): return GameData.CHIPS[c].el != "Neutral" and not M.evo.has(GameData.CHIPS[c].el))
		if not off.is_empty():
			fair = false
			printerr("    %s: Chips ohne Richtung im Startdeck %s" % [sp, off])
	check(fair, "Startdecks: je Richtung genau ein Chip, sonst neutral")
	check(GameData.MONS.Pixmiez.evo.get("Elektro", "") == "Prismiez" and not GameData.EL.has("Licht"), "Element Licht heißt jetzt Elektro, Pixmiez hat Elektro-Richtung")
	# Ultras: jede Stufe-3-Form (außer Fusionen) führt zu einer gültigen Ultra-Form
	var chain_ok := true
	for f in GameData.FORMS:
		var F: Dictionary = GameData.FORMS[f]
		if F.up != "" and (not GameData.FORMS.has(F.up) or GameData.FORMS[F.up].stage != F.stage + 1):
			chain_ok = false
			printerr("    Kette kaputt: %s -> %s" % [f, F.up])
		if F.stage == 3 and not GameData.MONS.get(f, {}).get("fusion", false) and F.up == "":
			chain_ok = false
			printerr("    Champion ohne Ultra: ", f)
	check(chain_ok, "Evolutionsketten gültig, jeder Champion hat ein Ultra")
	var ru := RunState.new("Pixmiez", 1)
	ru.form = "Bollwerkatz"
	ru.stage = 3
	ru.praeg = {"Code": GameData.EVO_AT[4]}
	check(ru.try_evolve().get("to", "") == "Bastionkatz" and ru.stage == 4, "Ab 80 Element-Chips: Bollwerkatz → Bastionkatz (Ultra)")
	var ok := true
	for f in GameData.FORMS:
		if not GameData.SPECIALS.has(f) or not ResourceLoader.exists("res://assets/sprites/%s.png" % GameData.FORMS[f].spr):
			ok = false
			printerr("    fehlt: ", f)
	check(ok, "Jede Form hat Sprite und Signatur-Attacke (%d Formen)" % GameData.FORMS.size())


func test_all_specials() -> void:
	var ok := true
	for f in GameData.SPECIALS:
		var run := RunState.new("Pixmiez", 1)
		run.form = f
		var st := BattleState.new(run, GameData.FOES[3])  # Boss: genug HP, um alle Treffer zu zählen
		st.e.frozen = 999.0
		st.sp = 100.0
		st.use_special()
		step(st, 1.2)
		var S: Dictionary = GameData.SPECIALS[f]
		var expected := 0
		for d in S.hits:
			expected += roundi(d * GameData.mult(S.el, "Virus"))
		if S.has("replay"):
			expected += roundi(30 * GameData.mult(S.el, "Virus"))  # ohne letzten Chip: 30 Schaden
		var dealt: int = 320 - st.e.hp
		# Brand/Gift ticken in 1,2 s höchstens einmal mit
		if dealt < expected or dealt > expected + 9:
			ok = false
			printerr("    %s: erwartet %d, verursacht %d" % [f, expected, dealt])
	check(ok, "Alle %d Signatur-Attacken treffen mit ihrem vollen Schaden" % GameData.SPECIALS.size())


func test_new_lines() -> void:
	# Jede Linie: Baby hat Form, Signatur, Sprite; jede Evolutionsrichtung zeigt auf eine Form
	var ok := true
	for sp in GameData.MONS:
		var M: Dictionary = GameData.MONS[sp]
		if not GameData.FORMS.has(sp) or not GameData.SPECIALS.has(sp):
			ok = false
		for el in M.evo:
			if not GameData.FORMS.has(M.evo[el]) or GameData.FORMS[M.evo[el]].el != el:
				ok = false
				printerr("    Richtung passt nicht: %s %s → %s" % [sp, el, M.evo[el]])
	var lines: int = GameData.MONS.keys().filter(func(k): return not GameData.MONS[k].get("fusion", false)).size()
	check(ok and lines == 9, "9 Linien + Fusionen, alle Evolutionsrichtungen gültig (%d Formen)" % GameData.FORMS.size())
	# Passive
	var st := BattleState.new(RunState.new("Brummbit", 1), GameData.FOES[0])
	st.reflex = 0
	st.hurt_player(20)
	check(st.run.hp == 125, "Dickes Fell: 20 Schaden → 15 (HP %d)" % st.run.hp)
	var st2 := BattleState.new(RunState.new("Lumi", 1), GameData.FOES[0])
	st2.move_player(0, -1)
	check(absf(st2.p.cd - 0.05) < 0.001, "Hasenhaken: halbe Bewegungspause")
	var st3 := BattleState.new(RunState.new("Quakli", 1), GameData.FOES[0])
	st3.hurt_player(5)
	check(st3.e.poison == 3, "Giftbaut: Angreifer wird vergiftet")
	var st4 := BattleState.new(RunState.new("Kauzbit", 1), GameData.FOES[0])
	st4.e.move_t = 99.0
	st4.e.atk_t = 0.01
	step(st4, 0.02)
	check(absf(st4.warns[0].max - 1.0) < 0.01, "Eulenblick: Warnung 0,3 s länger")
	var st5 := BattleState.new(RunState.new("Molchi", 1), GameData.FOES[3])
	st5.e.frozen = 99.0
	st5.e.poison = 1
	step(st5, 1.05)
	check(st5.e.hp == 320 - 6, "Giftdrüsen: Gift wirkt 50 %% stärker (HP %d)" % st5.e.hp)
	var hamster := 0
	for i in 40:
		var st6 := BattleState.new(RunState.new("Kekso", i), GameData.FOES[0])
		st6.e.frozen = 99.0
		play(st6, "Pixelstrahl")
		if st6.draw_pile.has("Pixelstrahl") and st6.disc.is_empty():
			hamster += 1
	check(hamster > 3 and hamster < 20, "Hamstern: etwa jeder 4. Chip kommt zurück (%d/40)" % hamster)
	# Abbild fängt Treffer ab
	var r7 := RunState.new("Kekso", 1)
	r7.form = "Phantomnager"
	var st7 := BattleState.new(r7, GameData.FOES[0])
	st7.e.frozen = 99.0
	st7.reflex = 0
	st7.sp = 100.0
	st7.use_special()
	st7.hurt_player(10)
	st7.hurt_player(10)
	st7.hurt_player(10)
	check(st7.run.hp == st7.run.max_hp - 10, "Abbild fängt 2 Treffer ab, der dritte trifft (HP %d)" % st7.run.hp)
	# Zungenschlag zieht den Gegner vor den Spieler
	var st8 := BattleState.new(RunState.new("Quakli", 1), GameData.FOES[0])
	st8.e.c = 2
	st8.e.r = 0
	st8.sp = 100.0
	st8.use_special()
	check(st8.e.c == 0 and st8.e.r == st8.p.r, "Zungenschlag zieht den Gegner vor dich")
	# Eier enthalten jetzt seltenere Linien
	check(SaveGame.egg_pool("Selten").has("Lumi") and SaveGame.egg_pool("Episch").has("Kauzbit") and not SaveGame.egg_pool("Gewöhnlich").has("Brummbit"), "Seltene Eier enthalten seltenere Linien")


func test_passives() -> void:
	var run := RunState.new("Tröpfel", 1)
	var st := BattleState.new(run, GameData.FOES[0])
	st.e.frozen = 999.0
	run.hp = 100
	step(st, 5.2)
	check(run.hp == 102 or run.hp == 103, "Regeneration: nach 3 s ohne Treffer ~1 HP/s (100 → %d)" % run.hp)
	var run2 := RunState.new("Funkling", 1)
	var st2 := BattleState.new(run2, GameData.FOES[0])
	st2.e.frozen = 999.0
	st2.hand[0].chip = "Firewall"
	st2.hand[1].chip = "Firewall"
	st2.hand[2].chip = "Firewall"
	st2.use_slot(0)
	st2.use_slot(1)
	var before: float = st2.hand[0].rem
	st2.use_slot(2)
	check(absf(st2.hand[0].rem - before * 0.5) < 0.01, "Übermut: 3. Chip halbiert die Ladezeit der anderen")
	var run3 := RunState.new("Pixmiez", 1)
	run3.form = "Bollwerkatz"
	run3.stage = 3
	var st3 := BattleState.new(run3, GameData.FOES[0])
	check(st3.reflex == 2, "Katzenreflex ab Champion: zwei Ausweicher")


func test_map() -> void:
	var ok_reach := true
	var ok_edges := true
	var ok_cross := true
	var ok_types := true
	for seed_value in 50:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var m := ZoneMap.generate(rng)
		if m.floors.size() != ZoneMap.FLOORS + 1 or m.floors[-1][0].type != "boss":
			ok_types = false
		for n in m.floors[0]:
			if n.type != "fight":
				ok_types = false
		for n in m.floors[ZoneMap.FLOORS - 1]:
			if n.type != "rest":
				ok_types = false
		for f in m.floors.size() - 1:
			var incoming := {}
			for i in m.floors[f].size():
				var nx: Array = m.floors[f][i].next
				if nx.is_empty():
					ok_edges = false
				for j in nx:
					incoming[j] = true
					# keine Kreuzung: ein linker Nachbar darf nicht weiter rechts landen
					for i2 in i:
						for j2 in m.floors[f][i2].next:
							if j2 > j:
								ok_cross = false
			if incoming.size() != m.floors[f + 1].size():
				ok_reach = false
	check(ok_types, "Karte: Etage 1 nur Kämpfe, letzte Etage Rast, oben Boss")
	check(ok_edges, "Karte: jeder Knoten hat einen Weg nach oben")
	check(ok_reach, "Karte: jeder Knoten ist erreichbar")
	check(ok_cross, "Karte: Wege kreuzen sich nicht")


func test_rooms() -> void:
	var run := RunState.new("Pixmiez", 5)
	run.hp = 50
	var msg := Rooms.rest_apply(run, "heal")
	check(run.hp == 85, "Rastplatz heilt 35 %% (50 → %d)" % run.hp)
	check(msg != "", "Rastplatz meldet Ergebnis")
	check(Rooms.rest_apply(run, "remove") == "remove", "Rastplatz kann Chip entfernen lassen")
	run.frag = 100
	var node := {"type": "shop"}
	Rooms.shop_init(run, node)
	var o: Dictionary = node.shop.offers[0]
	var deck_before := run.deck.size()
	Rooms.shop_apply(run, node, "buy_0")
	check(run.frag == 100 - o.price and run.deck.size() == deck_before + 1 and o.sold, "Händler: Kauf kostet Fragmente und füllt das Deck")
	var opts := Rooms.shop_options(run, node)
	check(not opts[0].enabled, "Händler: verkaufter Chip ist nicht mehr kaufbar")
	run.frag = 0
	var poor := Rooms.event_options(run, "brunnen")
	check(not poor[1].enabled, "Ereignis: Option mit Kosten gesperrt ohne Fragmente")
	var hp0 := run.max_hp
	Rooms.event_apply(run, "korrupt", "take")
	check(run.deck.has("Defrag") and run.max_hp == hp0 - 10, "Ereignis: Flackernder Chip gibt Defrag, kostet 10 max. HP")
	Rooms.event_apply(run, "glitchling", "wave")
	var st := BattleState.new(run, GameData.FOES[0])
	check(st.sp == 50.0 and not run.sp_bonus, "Winken: Signatur-Leiste startet halb voll (einmalig)")
	var keys := {}
	for i in 4:
		keys[Rooms.pick_event(run)] = true
	check(keys.size() == 4, "Ereignisse wiederholen sich nicht, solange neue übrig sind")


func test_elite_scaling() -> void:
	var run := RunState.new("Pixmiez", 2)
	run.enter(run.next_choices()[0])
	run.enter(run.next_choices()[0])
	run.enter(run.next_choices()[0])
	var normal := run.foe_for({"type": "fight"})
	var elite := run.foe_for({"type": "elite"})
	check(elite.elite and elite.name.begins_with("Elite-"), "Elite-Gegner ist markiert")
	var base: Dictionary = GameData.FOES.filter(func(f): return f.name == normal.name)[0]
	check(normal.hp == roundi(base.hp * 1.14), "Normale Gegner: +7 %% HP pro Etage (%s %d → %d)" % [base.name, base.hp, normal.hp])
	var boss := run.foe_for({"type": "boss"})
	check(boss.boss and boss.hp == 320, "Boss hat seine festen Werte")


## Komplette Runs über die Karte mit Autopilot: jeder Kampf muss enden, Siegquote als Balancing-Hinweis.
func test_simulated_runs() -> void:
	var wins := 0
	var stuck := 0
	var total_time := 0.0
	var fights := 0
	var runs := 45
	var stages := {}
	var chips_total := 0
	var forms := {}
	for seed_value in runs:
		seed(seed_value)
		var run := RunState.new(GameData.MONS.keys()[seed_value % GameData.MONS.size()], seed_value)
		var bot := BattleBot.new(0.25)
		var won := false
		while true:
			var ch := run.next_choices()
			if ch.is_empty():
				break
			var node := run.enter(ch[run.rng.randi_range(0, ch.size() - 1)])
			if node.type in ["fight", "elite", "boss"]:
				var st := BattleState.new(run, run.foe_for(node))
				var t := 0.0
				while not st.over and t < 180.0:
					bot.act(st)
					st.update(1.0 / 30.0)
					t += 1.0 / 30.0
					for ev in st.events:
						seen_events[ev] = true
					st.events.clear()
				total_time += t
				fights += 1
				if not st.over:
					stuck += 1
					break
				if st.outcome == "lost":
					break
				if node.type == "boss":
					won = true
					break
				run.try_evolve()
				run.heal(10)
				run.deck.append(run.roll_choices()[0])
			else:
				_auto_room(run, node)
		if won:
			wins += 1
		stages[run.stage] = stages.get(run.stage, 0) + 1
		chips_total += run.chips_used
		forms[run.form] = true
	check(stuck == 0, "Kein Kampf hängt (180 s Limit)")
	print("  info    Autopilot (0,25 s Reaktion): %d/%d Runs gewonnen, Ø %.1f Kämpfe und %.0f s Kampfzeit pro Run" % [wins, runs, float(fights) / runs, total_time / runs])
	print("  info    Endstufen: %s · Ø %.0f Chips pro Run · Formen: %s" % [stages, float(chips_total) / runs, forms.keys()])


## Autopilot für Räume: erste freigeschaltete Option, beim Entfernen den ersten Chip.
func _auto_room(run: RunState, node: Dictionary) -> void:
	var opts: Array
	match node.type:
		"event":
			node.event = Rooms.pick_event(run)
			opts = Rooms.event_options(run, node.event)
		"shop":
			Rooms.shop_init(run, node)
			opts = Rooms.shop_options(run, node)
		_:
			opts = Rooms.rest_options(run)
	for o in opts:
		if not o.enabled:
			continue
		var res := ""
		match node.type:
			"event":
				res = Rooms.event_apply(run, node.event, o.id)
			"shop":
				res = Rooms.shop_apply(run, node, o.id)
			_:
				res = Rooms.rest_apply(run, o.id)
		if res == "remove":
			run.remove_chip(run.deck[0])
		return


## Jedes Ereignis aus der Kampflogik braucht einen Sound; alle Sounds müssen hörbar lang sein.
func test_sounds() -> void:
	var sfx: Node = load("res://scripts/audio/sfx.gd").new()
	sfx._ready()
	var missing: Array = seen_events.keys().filter(func(k): return not sfx.streams.has(k))
	check(missing.is_empty(), "Alle Kampf-Ereignisse haben einen Sound (fehlend: %s)" % [missing])
	check(seen_events.size() >= 8, "Simulation erzeugt verschiedene Ereignisse (%d)" % seen_events.size())
	var empty: Array = sfx.streams.keys().filter(func(k): return sfx.streams[k].data.size() < 400)
	check(empty.is_empty(), "Alle Sounds enthalten Daten")
	sfx.free()


func test_music() -> void:
	var ok := true
	for key in ["title", "map", "battle", "boss", "victory", "map_vulkan", "battle_vulkan", "map_sumpf", "battle_sumpf", "intro", "map_kern", "finale", "ending"]:
		var path := "res://assets/music/%s.wav" % key
		if not ResourceLoader.exists(path):
			ok = false
			continue
		var st: AudioStreamWAV = load(path)
		var frames := roundi(st.get_length() * st.mix_rate)
		var lb := MusicSynth.intro_frames(key) if st.stereo else 0
		if st.get_length() < 8.0 or lb >= frames:
			ok = false
	check(ok, "Alle 13 Musikstücke vorhanden (inkl. Zonen, Intro, Finale, Ende), Schleifenpunkte gültig")
	check(Music.zone_key("map", "vulkan") == "map_vulkan" and Music.zone_key("battle", "sumpf") == "battle_sumpf" and Music.zone_key("map", "wiesen") == "map" and Music.zone_key("battle", "wiesen") == "battle", "Zonen 2 und 3 haben eigene Karten- und Kampfmusik, Wiesen behalten die alte")
	# Blinzel-Frames: jede Form außer den bekannten Ausnahmen
	var no_blink: Array = []
	for f in GameData.FORMS:
		var spr: String = GameData.FORMS[f].spr
		if not ResourceLoader.exists("res://assets/sprites/%s_blink.png" % spr):
			no_blink.append(f)
	check(no_blink.is_empty(), "Alle Formen blinzeln (ohne Blinzel-Frame: %s)" % ", ".join(no_blink))
	var foe_no_blink: Array = []
	for k in PixelCanvas.SPRITE_FILES:
		if not ResourceLoader.exists("res://assets/sprites/%s_blink.png" % PixelCanvas.SPRITE_FILES[k]):
			foe_no_blink.append(k)
	check(foe_no_blink == ["bluete"], "Alle Gegner mit Augen blinzeln (ohne: %s)" % ", ".join(foe_no_blink))
	# Karte spielt nach einem Kampf weiter statt neu zu beginnen
	Music.play("map")
	await get_tree().create_timer(0.6).timeout
	Music.play("battle")
	var saved: float = Music.positions.get("map", -1.0)
	Music.play("map")
	check(saved > 0.05 and Music.players[Music.active].get_playback_position() >= saved - 0.05, "Kartenmusik läuft nach dem Kampf an derselben Stelle weiter (%.2f s)" % saved)
	# Fehlerfall vom Produzenten: Sieg → Karte → sofort nächster Kampf (schneller als die Blende)
	Music.play("battle")
	await get_tree().create_timer(0.2).timeout
	Music.play("victory")
	await get_tree().create_timer(0.1).timeout
	Music.play("map")
	await get_tree().create_timer(0.1).timeout
	Music.play("battle")
	await get_tree().create_timer(1.0).timeout
	var ap: AudioStreamPlayer = Music.players[Music.active]
	check(ap.playing and ap.volume_db > -1.0 and Music.current == "battle", "Kampfmusik läuft nach schnellem Wechsel weiter (nicht stumm)")
	# auch nach stop() und sofortigem Neustart
	Music.stop()
	await get_tree().create_timer(0.1).timeout
	Music.play("map")
	await get_tree().create_timer(1.5).timeout
	ap = Music.players[Music.active]
	check(ap.playing and ap.volume_db > -1.0, "Musik läuft nach Stopp + sofortigem Neustart")
	Music.stop()
	var old: AudioStreamWAV = load("res://assets/music/battle.wav")
	check(not old.stereo and old.mix_rate == 22050, "Kampfmusik ist die alte, epische Fassung (bleibt unverändert)")


## Opening-Szene: läuft durch, lässt sich überspringen, Starterwahl danach
func test_opening() -> void:
	var Op: GDScript = load("res://scripts/ui/opening_view.gd")
	var o = Op.new()
	var total := 0.0
	for p in o.PANELS:
		total += p.dur
	check(o.PANELS.size() == 5 and total >= 25.0 and total <= 45.0, "Opening: 5 Bilder, %.0f s lang" % total)
	var ended := [false]
	o.finished.connect(func(): ended[0] = true)
	add_child(o)
	o.seek(total - 0.5)
	check(o.idx == o.PANELS.size() - 1, "Opening: seek springt ins letzte Bild")
	for i in 40:
		await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	check(ended[0], "Opening endet von selbst und meldet sich fertig")
	o.queue_free()
	# Überspringen per Esc
	var o2 = Op.new()
	var ended2 := [false]
	o2.finished.connect(func(): ended2[0] = true)
	add_child(o2)
	await get_tree().process_frame
	Input.action_press("pause")
	await get_tree().process_frame
	Input.action_release("pause")
	await get_tree().process_frame
	check(ended2[0] and o2.idx == 0, "Opening lässt sich sofort überspringen")
	o2.queue_free()
	Music.stop()


## Boss-Intro: läuft vor jedem Bosskampf, pausiert den Kampf, startet ihn danach (auch per Überspringen)
func test_boss_intro() -> void:
	var ok_titles := true
	for i in GameData.FOES.size():
		var f: Dictionary = GameData.FOES[i]
		if f.boss and f.get("title", "") == "":
			ok_titles = false
	check(ok_titles, "Jeder Boss hat einen Titel fürs Intro")
	var run := RunState.new("Pixmiez", 3)
	var bv = load("res://scenes/battle.tscn").instantiate()
	add_child(bv)
	bv.setup(run, run.foe_for({"type": "boss"}), "boss")
	check(bv.mode == bv.Mode.INTRO, "Bosskampf beginnt mit dem Intro")
	var hp0: int = run.hp
	await get_tree().create_timer(1.0).timeout
	check(bv.mode == bv.Mode.INTRO and run.hp == hp0 and bv.st.warns.is_empty(), "Während des Intros greift der Boss nicht an")
	await get_tree().create_timer(bv.INTRO_END).timeout
	check(bv.mode == bv.Mode.FIGHT and Music.current == "boss", "Nach dem Intro startet der Kampf mit Bossmusik")
	bv.queue_free()
	# Überspringen
	var bv2 = load("res://scenes/battle.tscn").instantiate()
	add_child(bv2)
	bv2.setup(RunState.new("Pixmiez", 4), run.foe_for({"type": "boss"}), "boss")
	await get_tree().create_timer(0.5).timeout
	await get_tree().process_frame   # Tastendruck zu Frame-Beginn, sonst verpasst _process ihn
	Input.action_press("confirm")
	await get_tree().process_frame
	Input.action_release("confirm")
	await get_tree().process_frame
	check(bv2.mode == bv2.Mode.FIGHT, "Boss-Intro lässt sich überspringen")
	bv2.queue_free()
	# normale Kämpfe haben kein Intro
	var bv3 = load("res://scenes/battle.tscn").instantiate()
	add_child(bv3)
	var r3 := RunState.new("Pixmiez", 5)
	bv3.setup(r3, r3.foe_for({"type": "fight"}), "fight")
	check(bv3.mode == bv3.Mode.FIGHT, "Normale Kämpfe starten ohne Intro")
	bv3.queue_free()
	Music.stop()


## Finale: NEST-Kern, Ur-Glitch, Ende, Schwierigkeit „Korrumpiert“
func test_finale() -> void:
	var Z: Dictionary = GameData.ZONES.kern
	var rk := RunState.new("Pixmiez", 21)
	rk.map = ZoneMap.generate(rk.rng, "kern")
	check(rk.map.floors.size() == 5 and rk.map.floors[-1][0].type == "boss" and rk.map.floors[3].all(func(n): return n.type == "rest"), "NEST-Kern: 4 Etagen + Boss, Rast vor dem Ur-Glitch")
	check(GameData.ZONE_ORDER[-1] == "kern" and Z.unlock == "sumpf", "NEST-Kern wird nach den Viren-Sümpfen frei")
	var boss := rk.foe_for({"type": "boss"})
	check(boss.name == "Ur-Glitch" and boss.get("final", false), "Endboss: Ur-Glitch (%d HP)" % boss.hp)
	# Elementwechsel
	var st := BattleState.new(rk, boss)
	st.e.move_t = 99.0
	st.e.atk_t = 99.0
	var seen := {st.def.el: true}
	for i in 5:
		step(st, BattleState.SHIFT_TIME + 0.05)
		st.e.atk_t = 99.0
		st.e.move_t = 99.0
		st.warns.clear()
		seen[st.def.el] = true
	check(seen.size() >= 3, "Ur-Glitch wechselt das Element: %s" % [seen.keys()])
	var strong := GameData.strong_against(st.def.el)
	check(strong != "" and GameData.mult(strong, st.def.el) > 1.0 and st.status.contains(strong), "Hinweis nennt das starke Element (%s gegen %s)" % [strong, st.def.el])
	# Diener passend zum Element
	st.e.hp = roundi(st.e.max * 0.4)
	st.def.el = "Feuer"
	st.e.pop_t = 0.01
	st.shift_t = 99.0
	step(st, 0.05)
	var lava_ok: bool = st.warns.any(func(w): return w.get("lava", false) and w.get("kind", "lava") == "lava")
	st.warns.clear()
	st.def.el = "Code"
	st.e.pop_t = 0.01
	step(st, 0.05)
	check(lava_ok and st.pops.any(func(q): return q.kind == "milbe"), "Ur-Glitch-Diener passen zum Element (Feuer: Lava, Code: Bitmilben)")
	# Spielstand: Ende erreicht → Korrumpiert frei
	var saved: Dictionary = SaveGame.data.duplicate(true)
	SaveGame.data.cleared = ["wiesen", "vulkan", "sumpf"]
	SaveGame.data.erase("game_cleared")
	check(SaveGame.zone_unlocked("kern") and not SaveGame.game_cleared(), "Nach den Sümpfen ist der Kern offen, das Spiel aber noch nicht durch")
	var rw := RunState.new("Pixmiez", 22)
	rw.map = ZoneMap.generate(rw.rng, "kern")
	var sum := SaveGame.record_run(rw, true)
	check(SaveGame.game_cleared() and sum.get("game_cleared", false), "Ur-Glitch besiegt: Spiel durchgespielt")
	SaveGame.data = saved
	# Korrumpiert: härter, aber mehr Fragmente
	var r3 := RunState.new("Pixmiez", 23)
	r3.difficulty = 2
	var f2 := r3.foe_for({"type": "fight"})
	var r4 := RunState.new("Pixmiez", 23)
	r4.difficulty = 3
	var f3 := r4.foe_for({"type": "fight"})
	check(f3.hp > f2.hp and f3.dmg > f2.dmg and f3.loot > f2.loot, "Korrumpiert: mehr HP/Schaden als Knackig, dafür mehr Fragmente")
	# Autopilot durch den Kern (Babys wären hier zu schwach: mit Champion-Form wie in einem späten Spielstand)
	var kwins := 0
	var kstuck := 0
	for sv in 9:
		var rr := RunState.new(["Pixmiez", "Funkling", "Tröpfel"][sv % 3], 300 + sv)
		rr.form = ["Bollwerkatz", "Magmawulf", "Tsunamander"][sv % 3]
		rr.stage = 3
		rr.max_hp += 20
		rr.hp = rr.max_hp
		rr.map = ZoneMap.generate(rr.rng, "kern")
		var bot := BattleBot.new(0.25)
		while true:
			var ch := rr.next_choices()
			if ch.is_empty():
				break
			var node := rr.enter(ch[0])
			if node.type in ["fight", "elite", "boss"]:
				var s := BattleState.new(rr, rr.foe_for(node))
				var tt := 0.0
				while not s.over and tt < 240.0:
					bot.act(s)
					s.update(1.0 / 30.0)
					tt += 1.0 / 30.0
				if not s.over:
					kstuck += 1
					break
				if s.outcome == "lost":
					break
				if node.type == "boss":
					kwins += 1
					break
				rr.heal(10)
	check(kstuck == 0, "Kern-Runs: kein Kampf hängt")
	print("  info    Kern-Autopilot (Champions): %d/9 Runs gewonnen" % kwins)
	# Ende-Szene läuft durch
	var En: GDScript = load("res://scripts/ui/ending_view.gd")
	var ev = En.new()
	var total := 0.0
	for pnl in ev.PANELS:
		total += pnl.dur
	var ended := [false]
	ev.finished.connect(func(): ended[0] = true)
	add_child(ev)
	ev.seek(total - 0.3)
	await get_tree().create_timer(0.6).timeout
	check(ended[0] and total > 40.0 and total < 70.0, "Ende-Szene mit Abspann (%.0f s) läuft durch" % total)
	ev.queue_free()
	Music.stop()


## Module: jede Wirkung einmal prüfen
func _mod_battle(mods: Array, seed_v := 1) -> BattleState:
	var r := RunState.new("Pixmiez", seed_v)
	for m in mods:
		r.add_module(m)
	var st := BattleState.new(r, r.foe_for({"type": "fight"}))
	st.e.move_t = 99.0
	st.e.atk_t = 99.0
	st.reflex = 0   # Katzenreflex aus, sonst weicht Pixmiez dem ersten Treffer aus
	st.def.el = "Neutral"   # kein Element-Vorteil, damit Schadenszahlen exakt sind
	return st


func test_modules() -> void:
	var ok := true
	for k in GameData.MODULES:
		var M: Dictionary = GameData.MODULES[k]
		if not GameData.PICTOS.has(M.pic) or not GameData.MODULE_PRICE.has(M.rar) or M.desc == "":
			ok = false
	check(ok and GameData.MODULES.size() >= 20, "%d Module mit Symbol, Preis und Beschreibung" % GameData.MODULES.size())
	# Verstärker / Elementlinse / Kritbit
	var a := _mod_battle([])
	var b := _mod_battle(["verstaerker"])
	var h0: int = a.e.hp
	a.hit_enemy(10, "Neutral")
	b.hit_enemy(10, "Neutral")
	check(h0 - a.e.hp == 10 and h0 - b.e.hp == 13, "Verstärker: +3 Schaden pro Chip-Treffer")
	var c := _mod_battle(["elementlinse"])
	c.def.el = "Code"
	var h1: int = c.e.hp
	c.hit_enemy(10, "Feuer")
	check(h1 - c.e.hp == 20, "Elementlinse: Vorteil doppelt statt 1,5-fach")
	# Panzerplatte, Dornenpanzer
	var d := _mod_battle(["panzerplatte", "dornenpanzer"])
	var hp0: int = d.run.hp
	var eh: int = d.e.hp
	d.hurt_player(10)
	check(hp0 - d.run.hp == 8 and eh - d.e.hp == 6, "Panzerplatte (−2) und Dornenpanzer (6 zurück)")
	# Backup-Kern
	var f := _mod_battle(["backupkern"])
	f.hurt_player(999)
	var first_ok: bool = not f.over and f.run.hp == roundi(f.run.max_hp * 0.3)
	f.hurt_player(999)
	check(first_ok and f.over and f.outcome == "lost", "Backup-Kern rettet genau einmal pro Run")
	# Startsignal, Notschild
	var g := _mod_battle(["startsignal", "notschild"])
	var hp1: int = g.run.hp
	g.hurt_player(15)
	check(g.sp >= 25.0 and g.run.hp == hp1, "Startsignal (Leiste 25 %) und Notschild (Blase fängt 15 ab)")
	# Überhitzer, Giftkapsel
	var i := _mod_battle(["ueberhitzer", "giftkapsel"])
	i.e.burn = 1
	i.e.poison = 1
	i.e.dot_t = 0.01
	var h2: int = i.e.hp
	step(i, 0.05)
	check(h2 - i.e.hp == 10 + 6, "Überhitzer (Brand 10) und Giftkapsel (Gift 6)")
	# Reflexbooster, Schleimschuhe
	var j := _mod_battle(["reflexbooster", "schleimschuhe"])
	j.hazards.append({"c": 2, "r": 1, "t": 5.0, "tick": 0.6, "kind": "slime"})
	j.move_player(1, 0)
	check(is_equal_approx(j.p.cd, j.mon.move * 0.75), "Reflexbooster schneller, Schleimschuhe: Schleim bremst nicht")
	# Prisma, Schnelllader, Echochip
	var k := _mod_battle(["prisma", "schnelllader"])
	k.run.deck = ["Glutball", "Glutball", "Glutball", "Glutball", "Glutball"]
	k.hand = [{"chip": "Glutball", "rem": 0.0, "max": 1.0, "queued": false}]
	k.draw_pile = ["Glutball"]
	k.use_slot(0)
	check(int(k.run.praeg.get("Feuer", 0)) == 2 and is_equal_approx(k.hand[0].max, GameData.CHIPS.Glutball.cd * 0.85), "Prisma (doppelte Prägung) und Schnelllader (−15 % Ladezeit)")
	var l := _mod_battle(["echochip"])
	l.e.hp = 99999
	l.e.max = 99999
	var effects: Array = []
	for n in 4:
		l.hand = [{"chip": "Byteschlag", "rem": 0.0, "max": 1.0, "queued": false}]
		l.draw_pile = ["Byteschlag"]
		var before: int = l.e.hp
		var pb: int = l.proj.size()
		l.use_slot(0)
		effects.append((before - l.e.hp) + (l.proj.size() - pb) * 1000)
		l.proj.clear()
	check(l.echo_count == 4 and effects[3] == effects[0] * 2 and effects[0] > 0, "Echochip: der 4. Chip wirkt doppelt %s" % [effects])
	# Sammler, Saugbit
	var m := _mod_battle(["sammler", "saugbit"])
	m.run.hp = 50
	m.hit_enemy(30, "Neutral")
	var healed: bool = m.run.hp == 53
	m.hit_enemy(9999, "Neutral")
	check(healed and m.loot_gained == roundi(m.def.loot * 1.3), "Saugbit (+3 HP bei 30 Schaden) und Sammler (+30 % Fragmente)")
	# Suchalgorithmus
	var rs := RunState.new("Pixmiez", 9)
	rs.add_module("suchalgorithmus")
	var always := true
	for n in 40:
		var ch := rs.roll_pick({"Gewöhnlich": 1, "Selten": 0, "Episch": 0})
		if ch.all(func(x): return GameData.CHIPS[x].rar == "Gewöhnlich"):
			always = false
	check(always, "Suchalgorithmus: immer mindestens ein seltener/epischer Chip")
	# Händler: Modul im Angebot, Rabattchip
	var rh := RunState.new("Pixmiez", 10)
	rh.frag = 500
	var node := {}
	Rooms.shop_init(rh, node)
	var mod_offer: Array = node.shop.offers.filter(func(o): return o.has("module"))
	var idx: int = node.shop.offers.find(mod_offer[0])
	Rooms.shop_apply(rh, node, "buy_%d" % idx)
	var full: int = mod_offer[0].price
	check(rh.modules.size() == 1 and rh.frag == 500 - full, "Händler verkauft ein Modul (%d Fragmente)" % full)
	rh.add_module("rabattchip")
	check(Rooms.price(rh, 40) == 30, "Rabattchip: 25 % billiger")
	# Modulkapsel und Elite-Belohnung
	var re := RunState.new("Pixmiez", 11)
	Rooms.event_apply(re, "modulkapsel", "open")
	var n_before := re.modules.size()
	var em := re.roll_module(GameData.MODULE_WEIGHT_ELITE)
	check(n_before == 1 and em != "" and not re.modules.has(em), "Modulkapsel gibt ein Modul, keine Doppelten")
	for key in GameData.MODULES:
		re.add_module(key)
	check(re.roll_module() == "", "Sind alle Module da, gibt es keins mehr")


## Neue Chips (29.09.2026): Kombos prüfen
func _chip(st: BattleState, id: String) -> void:
	st.hand = [{"chip": id, "rem": 0.0, "max": 1.0, "queued": false}, {"chip": "", "rem": 0.0, "max": 1.0, "queued": false}, {"chip": "", "rem": 0.0, "max": 1.0, "queued": false}]
	st.draw_pile = [""]
	st.use_slot(0)


func test_combo_chips() -> void:
	# Frostsplitter: dreifach gegen eingefrorene Gegner
	var a := _mod_battle([])
	a.e.hp = 999
	a.e.frozen = 5.0
	a.e.r = a.p.r
	_chip(a, "Frostsplitter")
	var h0: int = a.e.hp
	step(a, 1.0)
	check(h0 - a.e.hp == 42, "Frostsplitter: 3 × 14 gegen eingefrorene Gegner (%d)" % (h0 - a.e.hp))
	# Konter: Block + 35 zurück
	var b := _mod_battle([])
	b.e.hp = 999
	_chip(b, "Konter")
	var hp0: int = b.run.hp
	b.hurt_player(20)
	check(b.run.hp == hp0 and b.e.hp == 999 - 35, "Konter blockt und schlägt mit 35 zurück")
	# Debugger räumt Lava, Schleim und Diener weg
	var c := _mod_battle([])
	c.hazards.append({"c": 0, "r": 0, "t": 3.0, "tick": 0.6, "kind": "lava"})
	c.pops.append({"c": 2, "r": 2, "t": 3.0, "max": 3.0, "kind": "milbe"})
	_chip(c, "Debugger")
	check(c.hazards.is_empty() and c.pops.is_empty(), "Debugger entfernt Lava und Diener")
	# Seuche verdoppelt Gift
	var d := _mod_battle([])
	d.e.poison = 5
	_chip(d, "Seuche")
	check(d.e.poison == 10, "Seuche verdoppelt das Gift")
	# Magnetfeld zieht in die eigene Spalte
	var f := _mod_battle([])
	f.p.c = 0
	f.e.c = 2
	_chip(f, "Magnetfeld")
	check(f.e.c == 0 and f.e.frozen > 0, "Magnetfeld zieht den Gegner in deine Spalte")
	# Parasit heilt
	var g := _mod_battle([])
	g.run.hp = 50
	g.e.hp = 999
	g.e.r = g.p.r
	_chip(g, "Parasit")
	step(g, 1.0)
	check(g.run.hp == 62, "Parasit heilt um den Schaden (HP %d)" % g.run.hp)
	# Sprungantrieb: nächster Treffer ausgewichen
	var i := _mod_battle([])
	_chip(i, "Sprungantrieb")
	var hp1: int = i.run.hp
	i.hurt_player(20)
	var dodged: bool = i.run.hp == hp1
	i.hurt_player(20)
	check(dodged and i.run.hp == hp1 - 20, "Sprungantrieb: genau ein Treffer ausgewichen")
	# Feuersbrunst: doppelt gegen brennende Gegner
	var j := _mod_battle([])
	j.e.hp = 999
	j.e.burn = 2
	_chip(j, "Feuersbrunst")
	check(j.e.hp == 999 - 60 and j.e.burn >= 4, "Feuersbrunst: 60 gegen brennende Gegner, langer Brand")
	# Geschützturm feuert
	var k := _mod_battle([])
	k.e.hp = 999
	k.e.r = k.p.r
	_chip(k, "Geschützturm")
	step(k, 1.6)
	check(k.e.hp <= 999 - 12, "Geschützturm trifft in deiner Reihe (HP %d)" % k.e.hp)
	# Kettenblitz: 15 + 2 × 10
	var l := _mod_battle([])
	l.e.hp = 999
	_chip(l, "Kettenblitz")
	step(l, 0.6)
	check(l.e.hp == 999 - 35, "Kettenblitz: 15 + 10 + 10 (HP %d)" % l.e.hp)
	# Sporenfalle: Gift nach dem Auslösen
	var m := _mod_battle([])
	m.e.hp = 999
	_chip(m, "Sporenfalle")
	step(m, 1.0)
	check(m.e.poison > 0 and m.e.hp < 999, "Sporenfalle: Schaden und Gift")


## Jede Chip-Beschreibung passt in 3 Zeilen der Chipwahl-Karte (144 px bei Schriftgröße 8)
func test_chip_texts() -> void:
	var too_long: Array = []
	for k in GameData.CHIPS:
		var words: PackedStringArray = GameData.CHIPS[k].desc.split(" ")
		var lines := 1
		var cur := ""
		for w in words:
			var probe := w if cur == "" else cur + " " + w
			if PixelCanvas.text_width(probe) > 144:
				lines += 1
				cur = w
			else:
				cur = probe
		if lines > 3:
			too_long.append(k)
	check(too_long.is_empty(), "Alle Chip-Beschreibungen passen auf die Karte (zu lang: %s)" % [too_long])


## Alte Spielstände: gestrichene Formen und Fusionen werden auf den Ersatz übertragen (29.09.2026)
func test_form_migration() -> void:
	var saved: Dictionary = SaveGame.data.duplicate(true)
	SaveGame.data = {"team": [
		{"id": 1, "species": "Pixmiez", "form": "Glutluchs", "stage": 3, "praeg": {}, "chips": 0, "runs": 0, "wins": 0},
		{"id": 2, "species": "Brummbit", "form": "Supernovabär", "stage": 4, "praeg": {}, "chips": 0, "runs": 0, "wins": 0},
		{"id": 3, "species": "Dampfbyte", "form": "Dampfbyte", "stage": 3, "praeg": {}, "chips": 0, "runs": 0, "wins": 0}],
		"dex": {"Pyrolynx": true, "Lumi": true}, "recipes": ["Glyphel"]}
	SaveGame._upgrade()
	var t: Array = SaveGame.data.team
	var ok: bool = t[0].form == "Prismalynx" and t[1].form == "Myzelgrizz" and t[2].species == "Schlummerbit" and t[2].form == "Schlummerbit"
	ok = ok and SaveGame.data.dex.has("Aurorlynx") and not SaveGame.data.dex.has("Pyrolynx") and SaveGame.data.recipes == ["Wolperling"]
	for m in t:
		if not GameData.FORMS.has(m.form) or not GameData.MONS.has(m.species):
			ok = false
	check(ok, "Alte Spielstände: gestrichene Formen werden übertragen (Glutluchs → Prismalynx, Dampfbyte → Schlummerbit)")
	SaveGame.data = saved
