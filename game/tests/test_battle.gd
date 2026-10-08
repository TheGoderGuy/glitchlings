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
	Settings.path = "user://test_settings.cfg"   # Einstellungen nie in die echte Datei (Zurücksetzen löscht sie)
	Settings.lang = "de"   # Tests prüfen deutsche Texte; Englisch prüft test_english
	test_scripts_compile()
	test_english()
	test_testbuild()
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
	test_badger_raccoon()
	test_otter_macaw()
	test_frame_pacing()
	test_key_rebind()
	test_reset_game()
	test_chip_vfx()
	test_guards()
	test_run_save()
	test_progression()
	test_shop_cancel()
	test_ps_buttons()
	test_sprite_colors()
	test_station_guide()
	test_new_zones()
	test_protocols()
	test_legends()
	test_design_review()
	test_arena_tiles()
	test_room_cards_and_home()
	await test_handbook()
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
	check(st.hand.size() == 3 and st.pile_count() == 5, "3 Chips auf der Hand, 5 im Stapel")
	# Rollen-Slots: jeder Slot hält einen Chip seiner Rolle (Pixmiez: Angriff, Firewall, Heilpatch)
	check(GameData.role(st.hand[0].chip) == 0 and GameData.role(st.hand[1].chip) == 0 and st.hand[2].chip in ["Firewall", "Heilpatch"], "Slots: Angriff, Angriff, Support")
	# Der einzige Schutz-Chip kommt nach dem Neumischen zurück, mit Strafzeit
	var stx := fresh()
	stx.use_slot(2)
	var no_wait: bool = not stx.hand[2].shuf
	stx.hand[2].rem = 0.0
	stx.use_slot(2)
	check(no_wait and stx.hand[2].shuf and is_equal_approx(stx.hand[2].max, GameData.chip(stx.hand[2].chip).cd + BattleState.RESHUFFLE), "Leerer Support-Stapel: neu mischen kostet %.0f s extra" % BattleState.RESHUFFLE)
	var sta := fresh()
	for n in 8:
		sta.hand[n % 2].rem = 0.0
		sta.use_slot(n % 2)
	check(sta.hand.slice(0, 2).all(func(h): return GameData.role(h.chip) == 0 and not h.shuf), "Angriffs-Slots teilen sich den Stapel, Mischen ohne Wartezeit")
	# Startdecks: alle Linien haben jede Rolle mindestens einmal
	var roles_ok := true
	for m in GameData.MONS:
		var rs := [0, 0]
		for c in GameData.MONS[m].deck:
			rs[GameData.role(c)] += 1
		if rs.has(0):
			roles_ok = false
	check(roles_ok, "Jedes Startdeck hat Angriffs- und Support-Chips")
	check(GameData.chip_short("Pixelstrahl") == "20" and GameData.chip_short("Firewall") == "Schild 4 s" and GameData.chip_short("Konter") == "Konter 35" and GameData.chip_short("Heilpatch+").begins_with("Heilt"), "Kurzwirkung auf den Karten")
	var all_cards := true
	for c in GameData.CHIPS:
		if not GameData.CHIP_CARD.has(c):
			all_cards = false
	check(all_cards, "Jeder Chip hat ein Kartenbild (Trefferbild oder Symbol)")
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
	var before: int = st.run.chips_used
	st.use_slot(0)
	check(st.hand[0].deny > 0, "Ladender Chip: Drücken wird nur angezeigt (blinkt)")
	step(st, 5.0)
	check(st.run.chips_used == before, "Ladender Chip wird nicht vorgemerkt und feuert nicht von selbst")


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
		per_el[GameData.chip(chip).el] = per_el.get(GameData.chip(chip).el, 0) + 1
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
	check(all_ok and Rooms.EVENTS.size() == 34, "34 Ereignisse, alle Optionen beschriftet")
	# Zonen-Ereignisse
	var zv := Rooms.events_for_zone("vulkan")
	var zs := Rooms.events_for_zone("sumpf")
	var zw := Rooms.events_for_zone("wiesen")
	check(zv.has("schmiede") and not zv.has("irrlicht") and not zv.has("beeren") and zv.has("backup") and zv.size() == 12 and zs.size() == 12 and zw.size() == 11,
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
	check(hp[0] < hp[1] and hp[1] < hp[2] and hp[1] == roundi(GameData.FOES[3].hp * GameData.FOE_HP * GameData.BOSS_HP), "Schwierigkeit skaliert Boss-HP %s" % [hp])
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
	check(sprites_ok and GameData.FOES.size() == 44, "Alle %d Gegner haben ein Sprite" % GameData.FOES.size())
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
	run2.praeg = {"Feuer": GameData.EVO_AT[3] - GameData.EVO_AT[2]}
	check(run2.try_evolve().get("to", "") == "Magmawulf", "Champion-Schwelle zählt Lebenszeit-Prägung")
	# Eier reifen: ein Ei schlüpft, wenn seine Runs abgelaufen sind
	SaveGame.data.nest = [{"species": "Tröpfel", "runs_left": 1}, {"species": "Pixmiez", "runs_left": 3}]
	run2.fights_won = 0
	SaveGame.record_run(run2, false)
	check(SaveGame.ready_eggs().size() == 1 and int(SaveGame.nest()[1].runs_left) == 2, "Eier reifen pro Run")
	var h := SaveGame.hatch_next()
	check(h.get("species", "") == "Tröpfel" and SaveGame.team().size() == 2 and h.new_in_dex, "Ei schlüpft: neues Monster im Team und im Dex")
	# Eine Ei-Sorte (03.10.2026): schlüpft nach dem nächsten Run (seit der Reise 08.10.2026), alle Babys möglich, fehlende Arten dreifach gewichtet
	SaveGame.data.nest = []
	var ew := SaveGame.egg_weights()
	var all_babies := ew.size() == 13 and SaveGame.EGG_RUNS == 1
	var dex_has_tr: bool = SaveGame.data.dex.has("Tröpfel")
	check(all_babies and ew["Tröpfel"] == (1 if dex_has_tr else 3) and ew.values().has(3), "Eier: eine Sorte (1 Run), alle 13 Babys, fehlende Arten 3-fach")
	var rng_e := RandomNumberGenerator.new()
	rng_e.seed = 5
	var new_hits := 0
	var known: Array = []
	for s in ew:
		if ew[s] == 1:
			known.append(s)
	for n in 400:
		if not known.has(SaveGame._roll_species(rng_e)):
			new_hits += 1
	var exp_new := 400.0 * (3 * (ew.size() - known.size())) / (3 * (ew.size() - known.size()) + known.size())
	check(absf(new_hits - exp_new) < 40, "Fehlende Arten schlüpfen häufiger (%d von 400, erwartet ~%.0f)" % [new_hits, exp_new])
	var old := {"version": SaveGame.VERSION, "nest": [{"rarity": "Episch", "species": "Pixmiez", "runs_left": 3}]}
	var keep: Dictionary = SaveGame.data
	SaveGame.data = old
	SaveGame._upgrade()
	var mig: Dictionary = SaveGame.data.nest[0]
	SaveGame.data = keep
	check(not mig.has("rarity") and int(mig.runs_left) == SaveGame.EGG_RUNS, "Alte Eier: Seltenheit entfernt, spätestens nach dem nächsten Run")
	var full_egg := {"species": "Pixmiez", "runs_left": 2}
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
	# Reise (08.10.2026): alle Zonen über die Route erreichbar, besiegte Bosse werden gemerkt
	check(SaveGame.unlocked_zones() == GameData.ZONE_ORDER, "Reise: alle Zonen über die Route erreichbar")
	var run := RunState.from_monster(SaveGame.team()[0], 1)
	run.bosses = ["wiesen"]
	var sum := SaveGame.record_run(run, false)
	check(sum.first_bosses == ["wiesen"] and SaveGame.data.cleared == ["wiesen"] and SaveGame.zone_seen("wiesen") and not SaveGame.zone_seen("see"), "Boss der Cache-Wiesen besiegt: gemerkt, Zone gesehen")
	SaveGame.data.cleared = []
	SaveGame.unlock_all_zones()
	check(SaveGame.data.cleared.size() == GameData.ZONE_ORDER.size(), "Testfunktion markiert alle Zonen-Bosse als besiegt")
	var r2 := RunState.from_monster(SaveGame.team()[0], 2, "vulkan")
	check(r2.map.zone == "vulkan" and r2.map.zone_name == "Firewall-Vulkan" and r2.act == 1, "Run im Firewall-Vulkan (Akt 2)")
	var boss := r2.foe_for({"type": "boss"})
	check(boss.name == "Glutkernskarabäus" and boss.hp == roundi(GameData.FOES[10].hp * GameData.FOE_HP * GameData.BOSS_HP), "Boss im Vulkan: Glutkernskarabäus")
	r2.enter(r2.next_choices()[0])
	var f := r2.foe_for({"type": "fight"})
	var base: Dictionary = GameData.FOES.filter(func(x): return x.name == f.name)[0]
	check(GameData.ZONES.vulkan.early.has(GameData.FOES.find(base)) and f.hp == roundi(roundi(base.hp * GameData.ACT_HP[1]) * GameData.FOE_HP), "Vulkan-Gegner aus eigenem Pool, zäher im zweiten Akt (%s %d)" % [f.name, f.hp])
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
			if node.type in ["fight", "elite", "glitch", "guard", "boss"]:
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
				if node.type == "guard":
					run3.next_level()
					run3.heal(roundi(run3.max_hp * 0.3))
					run3.add_module(run3.roll_module())
				run3.heal(10)
	check(stuck == 0, "Vulkan-Runs: kein Kampf hängt")
	print("  info    Vulkan-Autopilot: %d/12 Runs gewonnen" % wins)


func test_zone3() -> void:
	# Freischaltung nach dem Vulkan
	var real_data := SaveGame.data.duplicate(true)
	SaveGame.persist = false
	SaveGame.new_game("Lumi")
	# Reise: nach dem Boss der Wiesen geht es in Vulkan oder See weiter, Deck und HP bleiben, es gibt eine Verschnaufpause
	var rv := RunState.from_monster(SaveGame.team()[0], 1)
	check(rv.act == 0 and rv.route == ["wiesen"] and rv.act_choices() == ["vulkan", "see"] and not rv.final_act(), "Reise: Akt 1 Wiesen, danach Vulkan oder See")
	rv.deck.append("Tsunami")
	rv.hp = 20
	rv.enter(rv.next_choices()[0])
	var healed := rv.next_act("see")
	check(rv.act == 1 and rv.map.zone == "see" and rv.map.level == 0 and rv.floor_idx == -1 and rv.route == ["wiesen", "see"] and rv.deck.has("Tsunami")
		and healed == roundi(rv.max_hp * GameData.ACT_HEAL) and rv.hp == 20 + healed, "Reise: weiter in den See, Deck bleibt, +%d HP Verschnaufpause" % healed)
	check(rv.act_choices() == ["sumpf", "steppe"], "Reise: Akt 3 Sümpfe oder Steppe")
	rv.next_act("sumpf")
	check(rv.act_choices() == ["kern"] and rv.map.zone == "sumpf", "Reise: danach der NEST-Kern")
	rv.next_act("kern")
	check(rv.final_act() and rv.act == 3, "Reise: der NEST-Kern ist das Finale")
	var rd := RunState.from_dict(JSON.parse_string(JSON.stringify(rv.to_dict())))
	check(rd.act == 3 and rd.route == ["wiesen", "see", "sumpf", "kern"], "Reise: Akt und Route werden gespeichert")
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
			if node.type in ["fight", "elite", "glitch", "guard", "boss"]:
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
				if node.type == "guard":
					run3.next_level()
					run3.heal(roundi(run3.max_hp * 0.3))
					run3.add_module(run3.roll_module())
				run3.heal(10)
	check(stuck == 0, "Sumpf-Runs: kein Kampf hängt")
	print("  info    Sumpf-Autopilot: %d/9 Runs gewonnen" % wins)


## Trainingskampf (04.10.2026): alle acht Lernschritte mit einem gesteuerten Spieler
func _tut_tick(st: BattleState, tut: Tutorial, frames: int, until := -1) -> void:
	for k in frames:
		st.update(1.0 / 60.0)
		tut.update(st, 1.0 / 60.0)
		st.events.clear()
		if until >= 0 and tut.step == until:
			return


func test_tutorial() -> void:
	var run := RunState.new("Pixmiez", 1)
	var foe: Dictionary = GameData.FOES[0].duplicate(true)
	foe.specials = [{"shape": "x", "name": "Glitchkreuz"}]
	var st := BattleState.new(run, foe)
	var tut := Tutorial.new()
	st.e.atk_t = 0.5
	for i in 3:
		st.move_player(0, -1 if st.p.r > 0 else 1)
		_tut_tick(st, tut, 20)
	check(st.warns.is_empty() and tut.step == Tutorial.Step.CHIP and st.e.r == st.p.r, "Training: kein Angriff beim Bewegen, nach 3 Schritten Gegner in deiner Reihe")
	st.e.frozen = 5.0
	st.hand[0].chip = "Pixelstrahl"
	st.hand[0].rem = 0.0
	st.use_slot(0)
	_tut_tick(st, tut, 40, Tutorial.Step.CHIP2)
	check(tut.step == Tutorial.Step.CHIP2 and st.hand[1].rem == 0.0, "Training: Treffer mit Angriff 1 > zweiter Angriffs-Slot")
	st.use_slot(1)
	_tut_tick(st, tut, 2)
	check(tut.step == Tutorial.Step.DODGE, "Training: Angriff 2 gespielt > Ausweichen üben")
	st.e.frozen = 0.0
	var bot := BattleBot.new(0.0)
	var t := 0.0
	while tut.step == Tutorial.Step.DODGE and t < 25.0:
		bot.act(st)
		st.sp = minf(st.sp, 50.0)
		_tut_tick(st, tut, 1)
		t += 1.0 / 60.0
	check(tut.step == Tutorial.Step.COUNTER and st.hand[0].chip == "Laserschuss" and st.hand[0].rem == 0.0, "Training: 2× ausgewichen > Konter üben, Laserschuss liegt bereit")
	# Konter: im Fenster (Fadenkreuz) zuschlagen bricht den Angriff ab
	t = 0.0
	while tut.step == Tutorial.Step.COUNTER and t < 15.0:
		if st.counter_open() and st.hand[0].rem <= 0:
			st.use_slot(0)
		_tut_tick(st, tut, 1)
		t += 1.0 / 60.0
	check(tut.step == Tutorial.Step.SHIELD and st.counters >= 1 and st.hand[2].chip == "Firewall" and st.hand[2].rem == 0.0, "Training: Konter gelandet > Firewall liegt bereit")
	st.use_slot(2)
	_tut_tick(st, tut, 360, Tutorial.Step.ELEMENT)
	check(tut.step == Tutorial.Step.ELEMENT and st.hand[0].chip == "Blitzcursor", "Training: Firewall blockt einen Treffer > Blitzcursor für den Element-Vorteil")
	st.use_slot(0)
	_tut_tick(st, tut, 90, Tutorial.Step.BIG)
	check(tut.step == Tutorial.Step.BIG, "Training: Elektro gegen Virus trifft effektiv > Großangriff")
	st.p.c = 1
	st.p.r = 0     # außerhalb des Glitchkreuzes (X-Form)
	_tut_tick(st, tut, 360, Tutorial.Step.SPECIAL)
	check(tut.step == Tutorial.Step.SPECIAL and st.sp == 100.0, "Training: goldenen Feldern ausgewichen > Signatur-Leiste voll")
	st.use_special()
	tut.update(st, 1.0 / 60.0)
	check(tut.just_finished and st.e.hp > 0 and st.run.hp > 0, "Training: Signatur gespielt > frei kämpfen (Gegner lebt, Spieler nie besiegt)")


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
	r2.praeg = {"Virus": ceili(need / 2.0), "Code": ceili(need / 2.0)}
	check(r2.try_evolve().is_empty() and r2.evo_status().reason.begins_with("Gleichstand"), "Gleichstand: Evolution wartet (keine Zufallsentscheidung)")
	# Führung zu knapp (nur 1 Chip Vorsprung) wartet – Elemente ohne Richtung verwässern nicht
	var r3 := RunState.new("Kekso", 1)
	r3.praeg = {"Virus": need / 2 + 1, "Elektro": need / 2, "Code": 3, "Feuer": 3}
	check(r3.try_evolve().is_empty() and r3.evo_status().reason.begins_with("Führung zu knapp"), "1 Chip Vorsprung: Evolution wartet")
	var r3b := RunState.new("Kekso", 1)
	r3b.praeg = {"Virus": need / 2 + 2, "Elektro": need / 2, "Code": 20}
	check(r3b.try_evolve().get("to", "") == "Tracko", "2 Vorsprung reicht, viele Code-Chips (ohne Wirkung) verwässern nicht")
	# Elemente ohne Richtung werden angezeigt, lenken aber nicht
	var s3 := r3.evo_status()
	check(s3.other.has("Code") and s3.other.has("Feuer") and s3.dirs.size() == 2, "Kekso: Code/Feuer ohne Wirkung, zwei Richtungen")
	var r4 := RunState.new("Tröpfel", 1)
	r4.praeg = {"Wasser": need}
	r4.eis = 4
	check(r4.try_evolve().get("to", "") == "Frostbyte", "Tröpfel mit 4× Eisfeld → Frostbyte")
	var r5 := RunState.new("Funkling", 1)
	r5.praeg = {"Feuer": need / 3, "Code": need}
	check(r5.try_evolve().get("to", "") == "Overclocko", "Funkling mit mehr Code als Feuer → Overclocko")
	# Startdecks: überwiegend neutral, genau ein Chip je Richtung
	var fair := true
	for sp in GameData.MONS:
		var M: Dictionary = GameData.MONS[sp]
		if M.get("fusion", false) or M.get("legend", false):
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
		var dealt: int = st.e.max - st.e.hp
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
	var lines: int = GameData.MONS.keys().filter(func(k): return not GameData.MONS[k].get("fusion", false) and not GameData.MONS[k].get("legend", false)).size()
	check(ok and lines == 13, "13 Linien + Fusionen + Legendäre, alle Evolutionsrichtungen gültig (%d Formen)" % GameData.FORMS.size())
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
	check(st5.e.hp == GameData.FOES[3].hp - 6, "Giftdrüsen: Gift wirkt 50 %% stärker (HP %d)" % st5.e.hp)
	var hamster := 0
	for i in 40:
		var st6 := BattleState.new(RunState.new("Kekso", i), GameData.FOES[0])
		st6.e.frozen = 99.0
		play(st6, "Pixelstrahl")
		if st6.piles[0].has("Pixelstrahl") and st6.discs[0].is_empty():
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
	check(SaveGame.EGG_SPECIES.has("Lumi") and SaveGame.EGG_SPECIES.has("Kauzbit") and SaveGame.EGG_SPECIES.has("Brummbit"), "Alle Linien schlüpfen aus Eiern")


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
		var m := ZoneMap.generate(rng, "wiesen", seed_value % 2)
		var top: String = "boss" if seed_value % 2 == 1 else "guard"
		if m.floors.size() != ZoneMap.FLOORS + 1 or m.floors[-1][0].type != top:
			ok_types = false
		for n in m.floors[0]:
			if n.type != "fight" and m.level == 0:
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
	check(ok_types, "Karte: 4 Etagen je Ebene, Ebene 1 beginnt mit Kämpfen, letzte Etage Rast, oben Wächter bzw. Boss")
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
	check(normal.hp == roundi(roundi(base.hp * 1.10) * GameData.FOE_HP), "Normale Gegner: +5 %% HP pro Etage (%s %d → %d)" % [base.name, base.hp, normal.hp])
	var boss := run.foe_for({"type": "boss"})
	check(boss.boss and boss.hp == roundi(GameData.FOES[3].hp * GameData.FOE_HP * GameData.BOSS_HP), "Boss hat seine festen Werte (mal Zähigkeit)")


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
			if node.type in ["fight", "elite", "glitch", "guard", "boss"]:
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
				if node.type == "guard":
					run.next_level()
					run.heal(roundi(run.max_hp * 0.3))
					run.add_module(run.roll_module())
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
		elif res == "upgrade":
			run.upgrade_chip(run.upgradable()[0])
		elif res == "copy":
			run.deck.append(run.deck[0])
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


## Englisch (01.10.2026): alle Daten und alle T.t-Texte übersetzt, Platzhalter passen, keine Umlaute
func test_english() -> void:
	var EN := LangEN.all()
	var need: Array = []
	for c in GameData.CHIPS:
		need.append_array([c, GameData.CHIPS[c].desc, GameData.CHIPS[c].cat, GameData.CHIPS[c].rar])
	for f in GameData.FORMS:
		need.append(f)
	for m in GameData.MONS:
		var M: Dictionary = GameData.MONS[m]
		need.append_array([M.passive, M.passive_desc, M.trait, M.animal])
	for k in GameData.SPECIALS:
		need.append_array([GameData.SPECIALS[k].name, GameData.SPECIALS[k].desc])
	for k in GameData.MODULES:
		need.append_array([GameData.MODULES[k].name, GameData.MODULES[k].desc])
	for u in GameData.STATION_UPGRADES:
		need.append_array([u.name, u.desc])
	for z in GameData.ZONES:
		need.append_array([GameData.ZONES[z].name, GameData.ZONES[z].desc])
	for fo in GameData.FOES:
		need.append(fo.name)
		if fo.has("title"):
			need.append(fo.title)
		for sp in fo.get("specials", []):
			need.append(sp.name)
	for r in GameData.RECIPES:
		need.append(r.hint)
	for e in Rooms.EVENTS:
		need.append_array([Rooms.EVENTS[e].title, Rooms.EVENTS[e].text])
	for k in ZoneMap.TYPE_NAMES:
		need.append_array([ZoneMap.TYPE_NAMES[k], ZoneMap.TYPE_DESC[k]])
	for p in load("res://scripts/ui/handbook_view.gd").PAGES:
		need.append_array([p.title, p.text])
	for v in ["res://scripts/ui/opening_view.gd", "res://scripts/ui/ending_view.gd"]:
		for p in load(v).PANELS:
			if p.text != "":
				need.append(p.text)
	need.append_array(GameData.STAGE_NAMES.slice(1))
	# alle T.t("…")-Texte im Code
	var re := RegEx.new()
	re.compile("T\\.t\\(\"((?:[^\"\\\\]|\\\\.)*)\"\\)")
	var dirs := ["res://scripts/ui", "res://scripts/battle", "res://scripts/run", "res://scripts/meta", "res://scripts/data"]
	for d in dirs:
		for fn in DirAccess.get_files_at(d):
			if fn.ends_with(".gd"):
				for m in re.search_all(FileAccess.get_file_as_string(d + "/" + fn)):
					need.append(m.get_string(1).c_unescape())
	var missing: Array = []
	for k in need:
		if not EN.has(k) and not missing.has(k):
			missing.append(k)
	check(missing.is_empty(), "Englisch: alle Namen, Beschreibungen und Texte übersetzt (%d Schlüssel, fehlend: %s)" % [EN.size(), missing.slice(0, 5)])
	# Platzhalter gleich, keine Umlaute im Englischen
	var bad: Array = []
	for k in EN:
		var v: String = EN[k]
		if k.count("%s") != v.count("%s") or k.count("%d") != v.count("%d") or k.count("{") != v.count("{"):
			bad.append(k)
		elif v.contains("ä") or v.contains("ö") or v.contains("ü") or v.contains("ß") or v.contains("Ä") or v.contains("Ö") or v.contains("Ü"):
			bad.append(k)
	check(bad.is_empty(), "Englisch: Platzhalter passen, keine Umlaute (%s)" % [bad.slice(0, 3)])
	Settings.lang = "en"
	var ok := T.t("Weiter") == "Continue" and T.chip("Glutball+") == "Ember Ball+" and T.t("Glutball+") == "Ember Ball+" 		and T.t("Elite-Bugsy") == "Elite Bugsy" and T.t("Glitch-Bytewurm") == "Glitch Byteworm" and T.dec(2.5) == "2.5" 		and GameData.upgrade_text("Glutball") == "45 > 60 damage, 3.0 > 2.4 s"
	var syn := GameData.synergy("Feuersbrunst", ["Glutball"], [], "")
	Settings.lang = "de"
	check(ok and syn == "Combo with Ember Ball" and T.t("Weiter") == "Weiter" and T.dec(2.5) == "2,5", "Sprache umschaltbar: Chips+, Elite-Namen, Kommazahlen, Kombo-Hinweis")


## Web-Testfassung: nur Cache-Wiesen und Firewall-Vulkan spielbar
func test_testbuild() -> void:
	var saved: Dictionary = SaveGame.data.duplicate(true)
	SaveGame.data = {"cleared": ["wiesen", "vulkan", "see", "sumpf", "steppe"]}
	SaveGame.force_test = true
	var r := RunState.new("Pixmiez", 1)
	var tb: bool = SaveGame.zone_unlocked("vulkan") and not SaveGame.zone_unlocked("sumpf") and not SaveGame.zone_unlocked("kern") 		and SaveGame.unlocked_zones() == ["wiesen", "vulkan"] and r.act_choices() == ["vulkan"]
	r.next_act("vulkan")
	tb = tb and r.final_act()
	SaveGame.force_test = false
	var full: bool = SaveGame.zone_unlocked("kern") and not r.final_act()
	SaveGame.data = saved
	check(tb and full, "Testfassung: Reise endet nach dem Vulkan; normale Fassung geht weiter")


func test_music() -> void:
	var ok := true
	for key in ["title", "map", "battle", "boss", "victory", "map_vulkan", "battle_vulkan", "map_sumpf", "battle_sumpf", "intro", "map_kern", "finale", "ending",
			"title_epic", "station", "battle_epic", "boss_epic"]:
		var path := "res://assets/music/%s.wav" % key
		if not ResourceLoader.exists(path):
			ok = false
			continue
		var st: AudioStreamWAV = load(path)
		var frames := roundi(st.get_length() * st.mix_rate)
		var lb := MusicSynth.intro_frames(key) if st.stereo else 0
		if st.get_length() < 8.0 or lb >= frames:
			ok = false
	check(ok, "Alle 17 Musikstücke vorhanden (inkl. Zonen, Intro, Finale, Ende, epische Fassungen), Schleifenpunkte gültig")
	# Epische Fassungen (08.10.2026) ersetzen im Spiel Titel, Kampf und Boss; die alten Dateien bleiben
	var all_there := true
	for k in Music.USE:
		all_there = all_there and ResourceLoader.exists("res://assets/music/%s.wav" % k) and ResourceLoader.exists("res://assets/music/%s.wav" % Music.USE[k])
	Music.play("title")
	var cur_title: String = Music.current
	Music.play("battle")
	check(all_there and cur_title == "title_epic" and Music.current == "battle_epic", "Epische Musik: Titel und Kampf spielen die neuen Fassungen, die alten Dateien bleiben erhalten")
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
	# ohne sichtbare Augen: Glitchblüte, Schlackwurm, Magmaskorp, Schnappkelch, Datenegel (nur Saugmaul); Moorlibelle hat Facettenaugen;
	# See/Steppe (06.10.2026): Frostkrill (winzige Facettenaugen), Frostanemone, Spulenwurm, Blitzfarn (ohne Augen), Schraubenrochen und Frostnarwal (Linsen)
	check(foe_no_blink == ["bluete", "schlackwurm", "magmaskorp", "schnappkelch", "datenegel", "moorlibelle", "frostkrill", "frostanemone", "schraubenrochen", "frostnarwal", "spulenwurm", "blitzfarn"], "Alle Gegner mit Augen blinzeln (ohne: %s)" % ", ".join(foe_no_blink))
	# Zonentypische Gegner (04.10.2026): jeder Pool enthält nur Gegner der eigenen Zone
	var own := {"wiesen": [0, 1, 2, 4, 5], "vulkan": [6, 7, 8, 9, 25], "see": [30, 31, 32, 33], "sumpf": [11, 12, 13, 26, 27], "steppe": [37, 38, 39, 40], "kern": [15, 16, 28, 29]}
	var zone_ok := true
	for z in own:
		for key in ["early", "late", "elite"]:
			for i in GameData.ZONES[z][key]:
				if not own[z].has(i):
					zone_ok = false
					printerr("    %s/%s: %s gehört nicht in diese Zone" % [z, key, GameData.FOES[i].name])
	check(zone_ok, "Jede Zone hat nur ihre eigenen Gegner (Wiesen 5, Vulkan 5, See 4, Sümpfe 5, Steppe 4, Kern 4)")
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
	check(ap.playing and ap.volume_db > -1.0 and Music.current == Music.USE.get("battle", "battle"), "Kampfmusik läuft nach schnellem Wechsel weiter (nicht stumm)")
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
	check(o.PANELS.size() == 8 and total >= 45.0 and total <= 65.0, "Opening: 8 Bilder (Kino-Intro), %.0f s lang" % total)
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
	SaveGame.data["seen_chips"] = []   # unbekannte Chips: Bereit-Pause kommt
	bv.setup(run, run.foe_for({"type": "boss"}), "boss")
	check(bv.mode == bv.Mode.INTRO, "Bosskampf beginnt mit dem Intro")
	var hp0: int = run.hp
	await get_tree().create_timer(1.0).timeout
	check(bv.mode == bv.Mode.INTRO and run.hp == hp0 and bv.st.warns.is_empty(), "Während des Intros greift der Boss nicht an")
	await get_tree().create_timer(bv.INTRO_END).timeout
	check(bv.mode == bv.Mode.READY and Music.current == Music.USE.get("boss", "boss"), "Nach dem Intro: Bereit-Pause mit Bossmusik")
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
	check(bv2.mode == bv2.Mode.READY, "Boss-Intro lässt sich überspringen")
	bv2.queue_free()
	# normale Kämpfe haben kein Intro
	var bv3 = load("res://scenes/battle.tscn").instantiate()
	add_child(bv3)
	var r3 := RunState.new("Pixmiez", 5)
	bv3.setup(r3, r3.foe_for({"type": "fight"}), "fight")
	check(bv3.mode == bv3.Mode.READY, "Normale Kämpfe starten ohne Intro, mit Bereit-Pause")
	var hp3: int = bv3.st.e.hp
	var t3: float = bv3.st.t
	await get_tree().create_timer(0.5).timeout
	check(bv3.st.t == t3 and bv3.st.e.hp == hp3, "Während der Bereit-Pause steht der Kampf")
	await get_tree().process_frame
	Input.action_press("confirm")
	await get_tree().process_frame
	Input.action_release("confirm")
	await get_tree().process_frame
	check(bv3.mode == bv3.Mode.FIGHT, "Bestätigen startet den Kampf")
	bv3.queue_free()
	# Bekannte Chips: keine Bereit-Pause, der Kampf startet sofort
	var bv4 = load("res://scenes/battle.tscn").instantiate()
	add_child(bv4)
	SaveGame.data["seen_chips"] = GameData.CHIPS.keys()
	var r4 := RunState.new("Pixmiez", 6)
	bv4.setup(r4, r4.foe_for({"type": "fight"}), "fight")
	check(bv4.mode == bv4.Mode.FIGHT, "Nur bekannte Chips auf der Hand: Kampf startet ohne Bereit-Pause")
	bv4.queue_free()
	SaveGame.data["seen_chips"] = []
	Music.stop()


## Finale: NEST-Kern, Ur-Glitch, Ende, Schwierigkeit „Korrumpiert“
func test_finale() -> void:
	var Z: Dictionary = GameData.ZONES.kern
	var rk := RunState.new("Pixmiez", 21)
	rk.map = ZoneMap.generate(rk.rng, "kern")
	check(rk.map.levels == 2 and rk.map.floors.size() == ZoneMap.FLOORS + 1 and rk.map.floors[-1][0].type == "guard", "NEST-Kern: 2 Ebenen, erst der Wächter")
	rk.next_level()
	rk.heal(roundi(rk.max_hp * 0.3))
	rk.add_module(rk.roll_module())
	check(rk.map.level == 1 and rk.map.floors[-1][0].type == "boss" and rk.map.floors[ZoneMap.FLOORS - 1].all(func(n): return n.type == "rest"), "NEST-Kern Ebene 2: Rast vor dem Ur-Glitch")
	check(GameData.ZONE_ORDER[-1] == "kern" and Z.unlock == "steppe", "NEST-Kern wird nach der Hochspannungs-Steppe frei")
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
	SaveGame.data.cleared = ["wiesen", "vulkan", "see", "sumpf", "steppe"]
	SaveGame.data.erase("game_cleared")
	check(SaveGame.zone_unlocked("kern") and not SaveGame.game_cleared(), "Nach der Steppe ist der Kern offen, das Spiel aber noch nicht durch")
	var rw := RunState.new("Pixmiez", 22)
	rw.map = ZoneMap.generate(rw.rng, "kern")
	rw.bosses = ["wiesen", "see", "steppe", "kern"]
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
			if node.type in ["fight", "elite", "glitch", "guard", "boss"]:
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
				if node.type == "guard":
					rr.next_level()
					rr.heal(roundi(rr.max_hp * 0.3))
					rr.add_module(rr.roll_module())
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
	check(ended[0] and total > 40.0 and total < 80.0, "Ende-Szene mit Abspann (%.0f s) läuft durch" % total)
	# Kino-Ende: Musik "ending" ist taktgenau so lang wie die Bilder ab der Heilung
	var bars := 0
	for sec in MusicSynth.TRACKS["ending"].sections:
		bars += sec.chords.size()
	var from_heal := 0.0
	for i in range(ev.MUSIC_FROM, ev.PANELS.size()):
		from_heal += ev.PANELS[i].dur
	check(absf(bars * 4 * 60.0 / MusicSynth.TRACKS["ending"].bpm - from_heal) < 0.01 and ev.PANELS[ev.MUSIC_FROM].id == "heal",
		"Ende-Musik passt taktgenau zu den Bildern (%d Takte = %.1f s)" % [bars, from_heal])
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
	k.piles[0] = ["Glutball"]
	k.use_slot(0)
	check(int(k.run.praeg.get("Feuer", 0)) == 2 and is_equal_approx(k.hand[0].max, GameData.CHIPS.Glutball.cd * 0.85), "Prisma (doppelte Prägung) und Schnelllader (−15 % Ladezeit)")
	var l := _mod_battle(["echochip"])
	l.e.hp = 99999
	l.e.max = 99999
	var effects: Array = []
	for n in 4:
		l.hand = [{"chip": "Byteschlag", "rem": 0.0, "max": 1.0, "queued": false}]
		l.piles[0] = ["Byteschlag"]
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
		if ch.all(func(x): return GameData.chip(x).rar == "Gewöhnlich"):
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
	st.piles = [[], []]
	st.discs = [[], []]
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


## Dachs (Buddli) und Waschbär (Maskli): Passive
func test_badger_raccoon() -> void:
	var rb := RunState.new("Buddli", 1)
	var sb := BattleState.new(rb, GameData.FOES[0])
	sb.def.el = "Neutral"
	sb.e.hp = 999
	sb.hit_enemy(20, "Neutral")
	var normal: int = 999 - sb.e.hp
	rb.hp = roundi(rb.max_hp * 0.2)
	sb.e.hp = 999
	sb.hit_enemy(20, "Neutral")
	check(normal == 20 and 999 - sb.e.hp == 30, "Furchtlos: unter 30 %% HP +50 %% Schaden (%d → %d)" % [normal, 999 - sb.e.hp])
	var rm := RunState.new("Maskli", 1)
	var sm := BattleState.new(rm, GameData.FOES[0])
	sm.e.hp = 999
	for s in sm.hand:
		s.rem = 5.0
	for i in 4:
		sm.hit_enemy(5, "Neutral")
	check(sm.hand.any(func(s): return s.rem == 0.0), "Langfinger: der 4. Treffer lädt einen Chip sofort")
	check(SaveGame.EGG_SPECIES.has("Maskli") and SaveGame.EGG_SPECIES.has("Buddli"), "Dachs und Waschbär schlüpfen aus Eiern")


## Otter (Bachli) und Ara (Plapperli), 03.10.2026
func test_otter_macaw() -> void:
	# Teamgeist: Support-Slot lädt 25 % schneller, Angriffs-Slots normal
	var so := BattleState.new(RunState.new("Bachli", 1), GameData.FOES[0])
	so.e.frozen = 999.0
	for s in so.hand:
		s.rem = 5.0
	so.update(1.0)
	check(absf(so.hand[0].rem - 4.0) < 0.01 and absf(so.hand[2].rem - 3.75) < 0.01, "Teamgeist: Support-Slot lädt 25 %% schneller (%.2f / %.2f)" % [so.hand[0].rem, so.hand[2].rem])
	# Nachplappern: der 4. Angriffs-Chip kommt nach 0,5 s mit halbem Schaden noch einmal
	var sa := BattleState.new(RunState.new("Plapperli", 1), GameData.FOES[3])
	sa.e.frozen = 999.0
	sa.def.el = "Neutral"
	sa.e.r = sa.p.r
	var hp0: int = sa.e.hp
	var pd: int = GameData.chip("Pixelstrahl").dmg
	for n in 4:
		sa.hand[0].chip = "Pixelstrahl"
		sa.hand[0].rem = 0.0
		sa.use_slot(0)
		step(sa, 0.1)
	step(sa, 1.5)
	var dealt: int = hp0 - sa.e.hp
	check(sa.parrot_count == 4 and dealt == 4 * pd + roundi(pd * 0.5), "Nachplappern: 4 × Pixelstrahl + ein halber Nachplapperer (%d)" % dealt)
	var ok := true
	for f in ["Bachli", "Strudli", "Wogotter", "Hydrolutra", "Knisterli", "Lutrion", "Fulgurlutra", "Plapperli", "Surrfeder", "Sturmschwinge", "Fulgopsitta", "Glutfeder", "Flammschwinge", "Heliopsitta"]:
		if not GameData.FORMS.has(f) or not GameData.SPECIALS.has(f) or not ResourceLoader.exists("res://assets/sprites/%s.png" % GameData.FORMS[f].spr):
			ok = false
			printerr("    fehlt: " + f)
	check(ok and SaveGame.EGG_SPECIES.has("Bachli") and SaveGame.EGG_SPECIES.has("Plapperli"), "Otter und Ara: 14 Formen mit Sprite und Signatur, schlüpfen aus Eiern")


## Ebenen-Wächter, Boss-Phasen und Großangriffe (30.09.2026)
func test_guards() -> void:
	# Jede Zone: Wächter je Ebene außer der letzten, oben der Boss
	var ok := true
	for z in GameData.ZONE_ORDER:
		var r := RunState.new("Pixmiez", 3)
		r.map = ZoneMap.generate(r.rng, z)
		for lv in r.map.levels:
			var top: Dictionary = r.map.floors[-1][0]
			var foe := r.foe_for(top)
			if lv < r.map.levels - 1:
				# welcher der Wächter der Zone kommt, entscheidet der Zufall (08.10.2026)
				var names: Array = GameData.ZONES[z].guards.map(func(i): return GameData.FOES[i].name)
				if top.type != "guard" or not foe.get("guard", false) or not names.has(foe.name):
					ok = false
				r.next_level()
			elif top.type != "boss" or foe.get("guard", false):
				ok = false
		if r.map.level != r.map.levels - 1 or r.floor_idx != -1:
			ok = false
	check(ok, "Jede Zone: Wächter am Ende von Ebene 1, Boss am Ende von Ebene 2")
	var rs := RunState.new("Pixmiez", 4)
	rs.next_level()
	rs.enter(rs.next_choices()[0])
	rs.enter(rs.next_choices()[0])
	check(rs.zone_floor() == ZoneMap.FLOORS + 1, "Etagen werden über die Ebenen weitergezählt (%d)" % rs.zone_floor())
	# Großangriff: komplett ausweichen überlastet den Wächter
	var run := RunState.new("Pixmiez", 5)
	var st := BattleState.new(run, run.foe_for({"type": "guard"}))
	st.reflex = 0
	check(st.def.name == "Sprungschreck" and st.special_ready(1), "Wächter der Wiesen: Sprungschreck, Großangriff ab Phase 1")
	var bot := BattleBot.new(0.0)
	st.e.atk_t = 99.0
	st.start_special()
	var hp0: int = run.hp
	for i in 240:
		bot.act(st)
		st.update(1.0 / 60.0)
		st.e.atk_t = 99.0
	check(st.sp_dodged == 1 and run.hp == hp0 and st.e.frozen > 0, "Hüpfjagd ausgewichen: Wächter überlastet (betäubt)")
	# Getroffen: keine Überlastung
	var st2 := BattleState.new(RunState.new("Pixmiez", 6), GameData.FOES[18])
	st2.reflex = 0
	st2.e.atk_t = 99.0
	st2.start_special()
	step(st2, 3.0)
	check(st2.sp_dodged == 0 and st2.run.hp < st2.run.max_hp, "Stehenbleiben: Großangriff trifft, keine Überlastung")
	# Alle Großangriffe lassen sich ausweichen (perfekter Bot), keiner bleibt hängen
	var shapes_ok := true
	var names: Array = []
	for fi in GameData.FOES.size():
		var F: Dictionary = GameData.FOES[fi]
		if not F.has("specials"):
			continue
		for k in F.specials.size():
			var r3 := RunState.new("Pixmiez", 10 + k)
			var s3 := BattleState.new(r3, F)
			s3.reflex = 0
			s3.e.hp = s3.e.max / 10   # Phase 3: alle Großangriffe im Wechsel
			s3.min_e_hp = 1           # der Bot darf ihn währenddessen nicht besiegen
			s3.e.phase = 3
			s3.e.sp_i = k
			s3.e.atk_t = 99.0
			s3.pops.clear()
			s3.start_special()
			var b := BattleBot.new(0.0)
			var h0: int = r3.hp
			for i in 300:
				b.act(s3)
				s3.update(1.0 / 60.0)
				s3.e.atk_t = 99.0
				s3.e.sp_t = 99.0
				s3.e.pop_t = 99.0
				s3.hazards.clear()
			if s3.sp_dodged != 1 or r3.hp != h0 or s3.sp_left != 0:
				shapes_ok = false
				names.append("%s/%s" % [F.name, F.specials[k].name])
	check(shapes_ok, "Alle Großangriffe sind ausweichbar %s" % [names])
	# Phasen: neues Muster ab Phase 2, Bosse starten dann ihre Großangriffe
	var r4 := RunState.new("Pixmiez", 7)
	var s4 := BattleState.new(r4, GameData.FOES[3])
	check(not s4.special_ready(1) and s4.special_ready(2), "Boss: Großangriffe erst ab Phase 2")
	s4.e.hp = s4.e.max / 2 - 1
	s4.e.atk_t = 0.01
	step(s4, 0.05)
	check(s4.e.phase == 2 and s4.banner.text == "Phase 2!" and s4.e.sp_t <= 2.5, "Boss unter 50 %: Phase 2 mit Banner")
	var kinds := {}
	for i in 3:
		s4.warns.clear()
		s4.e.atk_t = 0.01
		s4.e.sp_t = 99.0
		step(s4, 0.05)
		kinds[s4.warns.size()] = true
	check(s4.def.phase2 == ["row", "cross", "col"] and s4.e.pi >= 3, "Kernelmantis greift in Phase 2 mit neuem Muster an")
	# Wächter-Sieg: nächste Ebene
	var r5 := RunState.new("Pixmiez", 8)
	var lv0: int = r5.map.level
	r5.next_level()
	check(r5.map.level == lv0 + 1 and r5.floor_idx == -1 and r5.path.is_empty() and r5.next_choices().size() == r5.map.floors[0].size(), "Nach dem Wächter: neue Karte, Start unten")


## Run speichern und fortsetzen
func test_run_save() -> void:
	SaveGame.persist = false
	SaveGame.new_game("Funkling")
	var run := RunState.from_monster(SaveGame.team()[0], 9, "vulkan")
	run.enter(run.next_choices()[0])
	run.enter(run.next_choices()[0])
	run.deck.append("Glutball")
	run.praeg = {"Feuer": 7, "Neutral": 3}
	run.add_module("verstaerker")
	run.hp = 42
	run.frag = 77
	SaveGame.save_run(run)
	check(SaveGame.has_run(), "Run wird auf der Karte gespeichert")
	var json := JSON.stringify(SaveGame.data)
	SaveGame.data = JSON.parse_string(json)   # wie nach einem Neustart: Zahlen kommen als Gleitkomma zurück
	var r2 := SaveGame.load_run()
	check(r2.map.zone == "vulkan" and r2.floor_idx == 1 and r2.path == run.path and r2.hp == 42 and r2.frag == 77
		and r2.deck == run.deck and r2.praeg == {"Feuer": 7, "Neutral": 3} and r2.has_mod("verstaerker"), "Run fortsetzen: Karte, Position, HP, Deck, Prägung und Module")
	check(r2.next_choices() == run.next_choices() and r2.current_node().type == run.current_node().type, "Run fortsetzen: gleiche Wege auf der Karte")
	check(r2.rng.randi() == run.rng.randi(), "Run fortsetzen: Zufall läuft gleich weiter")
	SaveGame.record_run(r2, false)
	check(not SaveGame.has_run(), "Nach dem Run ist nichts mehr fortzusetzen")


## Chips verbessern, Synergien, Glitch-Elite, neue Ereignisse, Station-Ausbau (30.09.2026)
func test_progression() -> void:
	# Verbesserte Chips
	var g := GameData.chip("Glutball+")
	check(g.dmg == 60 and absf(g.cd - 2.4) < 0.01 and g.up and GameData.chip("Pixelstrahl+").dmg == 25, "Glutball+: 60 Schaden, 2,4 s · Pixelstrahl+: 25")
	check(GameData.upgrade_text("Glutball") == "45 > 60 Schaden, 3,0 > 2,4 s", "Verbesserung wird verständlich beschrieben (%s)" % GameData.upgrade_text("Glutball"))
	var ok := true
	for c in GameData.CHIPS:
		var run := RunState.new("Pixmiez", 3)
		var st := BattleState.new(run, GameData.FOES[3])
		st.e.hp = 9999
		st.e.max = 9999
		st.hand[0].chip = c + "+"
		st.hand[0].rem = 0.0
		st.use_slot(0)
		step(st, 1.5)
		if GameData.chip(c + "+").cd > GameData.CHIPS[c].cd * 0.85 or not (st.discs[GameData.role(c)].has(c + "+") or st.piles[GameData.role(c)].has(c + "+") or st.hand.any(func(h): return h.chip == c + "+")):
			ok = false
	check(ok, "Alle %d verbesserten Chips laufen fehlerfrei und laden schneller" % GameData.CHIPS.size())
	var rh := RunState.new("Pixmiez", 4)
	rh.hp = 10
	var sh := BattleState.new(rh, GameData.FOES[0])
	sh.hand[0].chip = "Heilpatch+"
	sh.hand[0].rem = 0.0
	sh.use_slot(0)
	check(rh.hp == 10 + 33, "Heilpatch+ heilt 33 statt 25 (HP %d)" % rh.hp)
	var ru := RunState.new("Pixmiez", 5)
	var n0 := ru.deck.count("Pixelstrahl")
	check(Rooms.rest_apply(ru, "upgrade") == "upgrade" and ru.upgrade_chip("Pixelstrahl") == "Pixelstrahl+" and ru.deck.count("Pixelstrahl") == n0 - 1 and ru.deck.has("Pixelstrahl+"), "Rastplatz: Chip verbessern ersetzt eine Kopie durch Pixelstrahl+")
	check(not ru.upgradable().has("Pixelstrahl+") and ru.upgradable().has("Pixelstrahl") == (n0 > 1), "Verbesserte Chips lassen sich nicht noch einmal verbessern")
	var node := {"type": "shop"}
	ru.frag = 100
	Rooms.shop_init(ru, node)
	var up_opt: Array = Rooms.shop_options(ru, node).filter(func(o): return o.id == "upgrade")
	check(up_opt.size() == 1 and up_opt[0].enabled and Rooms.shop_apply(ru, node, "upgrade") == "upgrade" and ru.frag == 100 - Rooms.PRICE_UPGRADE, "Händler: Chip verbessern für %d Fragmente" % Rooms.PRICE_UPGRADE)
	check(not Rooms.shop_options(ru, node).filter(func(o): return o.id == "upgrade")[0].enabled, "Händler: Verbessern nur einmal pro Besuch")
	# Synergien
	check(GameData.synergy("Glutball", ["Pixelstrahl", "Feuersbrunst"], [], "Katzenreflex") == "Kombo mit Feuersbrunst", "Synergie: Glutball passt zu Feuersbrunst im Deck")
	check(GameData.synergy("Datenfresser", ["Virusspritzer+"], [], "") == "Kombo mit Virusspritzer", "Synergie: Datenfresser passt zu Gift (auch verbessert)")
	check(GameData.synergy("Eisfeld", [], ["kaeltekern"], "").contains("Kältekern") and GameData.synergy("Sporenfalle", [], [], "Giftdrüsen") == "Kombo mit Giftdrüsen", "Synergie: Module und Passive")
	check(GameData.synergy("Pixelstrahl", ["Feuersbrunst", "Seuche"], ["ueberhitzer"], "Giftdrüsen") == "", "Keine Synergie ohne Grund")
	# Glitch-Elite
	var glitch_n := 0
	var early_glitch := false
	for sv in 60:
		var rng := RandomNumberGenerator.new()
		rng.seed = sv
		for lv in 3:
			var m := ZoneMap.generate(rng, "wiesen", lv)
			for f in m.floors.size():
				for n in m.floors[f]:
					if n.type == "glitch":
						glitch_n += 1
						if lv * ZoneMap.FLOORS + f < 4:
							early_glitch = true
	check(glitch_n > 10 and not early_glitch, "Glitch-Elite erscheint (%d×), aber nie in den ersten Etagen" % glitch_n)
	var rg := RunState.new("Pixmiez", 6)
	var ge := rg.foe_for({"type": "glitch"})
	var el := rg.foe_for({"type": "elite"})
	var gbase: Dictionary = GameData.FOES.filter(func(x): return ge.name.ends_with(x.name))[0]
	check(ge.name.begins_with("Glitch-") and ge.glitch and ge.hp > roundi(gbase.hp * 1.6) and ge.loot > el.loot, "Glitch-Elite: stärker als Elite, mehr Fragmente (%s %d HP)" % [ge.name, ge.hp])
	# Neue Ereignisse: alle Optionen funktionieren
	var ev_ok := true
	var keys := ["werkbank", "pusteblumen", "obsidian", "glutkaefer", "wrack", "gluehwuermer", "logbuch", "nestbewohner", "kernspeicher"]
	for key in keys:
		for o in Rooms.event_options(RunState.new("Pixmiez", 7), key):
			var re := RunState.new("Pixmiez", 7)
			re.hp = 60
			re.frag = 50
			var res := Rooms.event_apply(re, key, o.id)
			if res == "" or res == "Du gehst weiter." or re.hp <= 0:
				ev_ok = false
				printerr("    %s/%s: %s" % [key, o.id, res])
	check(ev_ok, "9 neue Ereignisse: alle Optionen haben eine Wirkung")
	var zones_ok := true
	for z in GameData.ZONE_ORDER:
		var own: Array = Rooms.EVENTS.keys().filter(func(k): return Rooms.EVENTS[k].get("zone", "") == z)
		if own.size() < 3:
			zones_ok = false
	check(zones_ok and Rooms.events_for_zone("kern").has("logbuch"), "Jede Zone hat eigene Ereignisse, der NEST-Kern jetzt auch (Lore)")
	var rw := RunState.new("Pixmiez", 8)
	check(Rooms.event_apply(rw, "wrack", "dive").contains("+") and rw.deck.filter(func(c): return GameData.is_upgraded(c)).size() == 2, "Versunkenes Wrack verbessert zwei Chips")
	# Station-Ausbau
	SaveGame.persist = false
	SaveGame.new_game("Pixmiez")
	SaveGame.data.frag = 300
	check(SaveGame.upgrade_cost("vorrat") == 100 and SaveGame.buy_upgrade("vorrat") and SaveGame.frag() == 200 and SaveGame.upgrade_level("vorrat") == 1, "Ausbau kaufen kostet Fragmente und hebt die Stufe")
	SaveGame.data.frag = 10
	check(not SaveGame.buy_upgrade("werkbank") and SaveGame.upgrade_level("werkbank") == 0, "Ohne genug Fragmente kein Ausbau")
	SaveGame.data.upgrades = {"vorrat": 2, "werkbank": 2, "modulschacht": 1, "filter": 1, "nestplatz": 1, "brutwaermer": 1}
	var rs := RunState.from_monster(SaveGame.team()[0], 9)
	var hp0: int = rs.max_hp
	rs.apply_station(SaveGame.data.upgrades)
	var ups: int = rs.deck.filter(func(c): return GameData.is_upgraded(c)).size()
	check(rs.max_hp == hp0 + 20 and rs.hp == rs.max_hp and ups == 2 and rs.modules.size() == 1 and absf(rs.loot_mult - 1.15) < 0.001, "Station-Ausbau wirkt im Run: +20 HP, 2 verbesserte Chips, 1 Modul, +15 %% Fragmente")
	check(SaveGame.upgrade_cost("nestplatz") == -1 and SaveGame.nest_slots() == 4, "Nest-Erweiterung: 4 Plätze")
	SaveGame.data.nest = []
	var rng2 := RandomNumberGenerator.new()
	var egg := SaveGame.add_egg(rng2)
	var egg2 := SaveGame.add_egg(rng2)
	check(int(egg.runs_left) == 1 and int(egg2.runs_left) == 1, "Eier schlüpfen nach dem nächsten Run")
	# Brutwärmer (seit der Reise 08.10.2026): ein zusätzliches Ei nach jedem Run mit mindestens 2 Siegen
	SaveGame.data.nest = []
	var rb := RunState.from_monster(SaveGame.team()[0], 10)
	rb.fights_won = 3
	check(SaveGame.record_run(rb, false).eggs.size() == 2, "Brutwärmer: zwei Eier statt einem nach einem Run ohne Boss-Sieg")
	# Ei kaufen: 200 Fragmente, nur mit freiem Platz
	SaveGame.data.nest = []
	SaveGame.data.frag = 250
	var bought := SaveGame.buy_egg(rng2)
	var poor := SaveGame.buy_egg(rng2)   # nur noch 50 Fragmente
	SaveGame.data.frag = 900
	SaveGame.data.nest = [{"species": "Lumi", "runs_left": 2}, {"species": "Lumi", "runs_left": 2}, {"species": "Lumi", "runs_left": 2}, {"species": "Lumi", "runs_left": 2}]
	var full := SaveGame.buy_egg(rng2)
	check(not bought.is_empty() and poor.is_empty() and full.is_empty() and SaveGame.frag() == 900 and SaveGame.EGG_PRICE == 200, "Ei kaufen: 200 Fragmente, nicht ohne Fragmente oder bei vollem Nest")


## Händler: Chip-Auswahl abbrechen gibt die Fragmente zurück (30.09.2026)
func test_shop_cancel() -> void:
	var run := RunState.new("Pixmiez", 11)
	run.enter(run.next_choices()[0])
	run.current_node().type = "shop"
	run.frag = 100
	var rv = load("res://scripts/ui/room_view.gd").new()
	rv.setup(run)
	rv._choose("upgrade")
	var charged: bool = run.frag == 100 - Rooms.PRICE_UPGRADE
	rv._cancel_choose()
	check(charged and run.frag == 100 and not rv.node.shop.upgrade and rv.state == rv.State.MENU, "Händler: Verbessern abbrechen gibt die Fragmente zurück")
	check(InputMap.action_get_events("chip_2").any(func(e): return e is InputEventJoypadButton and e.button_index == JOY_BUTTON_A)
		and InputMap.action_get_events("special").any(func(e): return e is InputEventJoypadButton and e.button_index == JOY_BUTTON_Y), "Controller: Chip 2 auf A (PS ✕), Signatur auf Y (PS △)")
	rv.free()


## PlayStation-Tastensymbole (30.09.2026)
func test_ps_buttons() -> void:
	var old: String = InputSetup.pad_style
	InputSetup.pad_style = "ps"
	var ok_ps: bool = InputSetup.btn("A") == "" and InputSetup.btn("Y") == "" and InputSetup.btn("LB") == "L1" and InputSetup.btn("Start") == "Options"
	InputSetup.pad_style = "xbox"
	var ok_x: bool = InputSetup.btn("A") == "A" and InputSetup.btn("LB") == "LB"
	InputSetup.pad_style = old
	var ff := PixelCanvas._ps_font()
	check(ok_ps and ok_x and ff.has_char(0xE000) and ff.has_char(0xE003) and PixelCanvas.font().fallbacks.has(ff), "PS-Controller: ✕ ○ □ △ als eigene Pixel-Symbole, L1/R1/Options")


## Kühlwasser-See und Hochspannungs-Steppe (06.10.2026)
func test_new_zones() -> void:
	check(GameData.ZONE_ORDER == ["wiesen", "vulkan", "see", "sumpf", "steppe", "kern"], "Zonen: Wiesen > Vulkan > See > Sümpfe > Steppe > Kern")
	var bosses_ok: bool = GameData.FOES[GameData.ZONES.see.boss].name == "Tiefenschlange" and GameData.FOES[GameData.ZONES.steppe.boss].name == "Donnerkondor" 		and GameData.ZONES.see.guards.all(func(g): return GameData.FOES[g].get("guard", false)) and GameData.ZONES.steppe.guards.all(func(g): return GameData.FOES[g].get("guard", false))
	check(bosses_ok, "See: Tiefenschlange + 2 Wächter, Steppe: Donnerkondor + 2 Wächter")
	# Strömung: reißt den Spieler in Strömungsrichtung bis an den Rand, ohne Schaden
	var cs := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[30])
	cs.e.atk_t = 99.0
	cs.e.move_t = 99.0
	cs.p.c = 0
	cs.p.r = 1
	var hp0: int = cs.run.hp
	cs.warns.append({"cells": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], "t": 0.05, "max": 0.9, "dmg": 0, "lava": true, "kind": "current", "dir": 1})
	step(cs, 2.2)
	check(cs.p.c == 2 and cs.run.hp == hp0 and cs.hazards.all(func(h): return h.kind == "current"), "Strömung reißt den Spieler bis an den Rand (ohne Schaden)")
	# Spannungsfeld: kostet HP, Chips laden doppelt so schnell
	var sp := BattleState.new(RunState.new("Funkling", 1), GameData.FOES[38])
	sp.e.atk_t = 99.0
	sp.e.move_t = 99.0
	var ref := BattleState.new(RunState.new("Funkling", 1), GameData.FOES[38])
	ref.e.atk_t = 99.0
	ref.e.move_t = 99.0
	sp.hazards.append({"c": sp.p.c, "r": sp.p.r, "t": 4.0, "tick": 0.0, "kind": "spark", "seed": 1})
	sp.hand[0].rem = 2.0
	ref.hand[0].rem = 2.0
	var hp1: int = sp.run.hp
	step(sp, 0.5)
	step(ref, 0.5)
	check(sp.run.hp < hp1 and absf((2.0 - sp.hand[0].rem) - 2.0 * (2.0 - ref.hand[0].rem)) < 0.05, "Spannungsfeld: kostet HP, Chips laden doppelt so schnell")
	# Großangriff Welle (Tiefenschlange): Spalte für Spalte
	var ws := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[34])
	ws.def = GameData.FOES[34].duplicate(true)
	ws.def.specials = [{"shape": "wave", "name": "Sturzflut"}]
	ws.start_special()
	var first: Array = ws.warns[-1].cells
	check(first.size() == 3 and first.all(func(c): return c.x == 2) and ws.delayed.size() == 2, "Großangriff Sturzflut: Welle Spalte für Spalte")
	# Alte Spielstände: freie Zonen bleiben frei
	var saved: Dictionary = SaveGame.data.duplicate(true)
	SaveGame.data = {"version": SaveGame.VERSION, "team": [], "nest": [], "dex": {}, "cleared": ["wiesen", "vulkan", "sumpf"]}
	SaveGame._upgrade()
	var keep := SaveGame.zone_unlocked("sumpf") and SaveGame.zone_unlocked("kern") and SaveGame.zone_unlocked("see") and SaveGame.zone_unlocked("steppe")
	SaveGame.data = saved
	check(keep, "Alter Spielstand: Sümpfe und Kern bleiben frei, See und Steppe kommen dazu")
	# Komplette Runs durch See und Steppe (Autopilot, 0,25 s Reaktion)
	for zone in ["see", "steppe"]:
		var stuck := 0
		var wins := 0
		for sv in 6:
			seed(sv)
			var rz := RunState.new(["Lumi", "Pixmiez", "Brummbit"][sv % 3], sv)
			rz.map = ZoneMap.generate(rz.rng, zone)
			var bot := BattleBot.new(0.25)
			while true:
				var ch := rz.next_choices()
				if ch.is_empty():
					break
				var node := rz.enter(ch[0])
				if node.type in ["fight", "elite", "glitch", "guard", "boss"]:
					var s := BattleState.new(rz, rz.foe_for(node))
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
					if node.type == "guard":
						rz.next_level()
						rz.heal(roundi(rz.max_hp * 0.3))
						rz.add_module(rz.roll_module())
					rz.heal(10)
		check(stuck == 0, "%s-Runs: kein Kampf hängt" % GameData.ZONES[zone].name)
		print("  info    %s-Autopilot: %d/6 Runs gewonnen" % [GameData.ZONES[zone].name, wins])


## Glitch-Protokolle (07.10.2026): Endgame-Stufen nach dem Abspann
func test_protocols() -> void:
	check(GameData.PROTOCOLS.size() == 10, "Glitch-Protokolle: 10 Stufen")
	var r0 := RunState.new("Pixmiez", 4)
	var r9 := RunState.new("Pixmiez", 4)
	r9.protocol = 10
	var f0 := r0.foe_for({"type": "fight"})
	var f9 := r9.foe_for({"type": "fight"})
	var b0 := r0.foe_for({"type": "boss"})
	var b9 := r9.foe_for({"type": "boss"})
	var foe_ok: bool = f9.hp == roundi(f0.hp * 1.15) and is_equal_approx(f9.atk, f0.atk * 0.9) and f9.dmg == maxi(1, roundi(f0.dmg * 1.15)) 		and is_equal_approx(f9.warn_bonus, f0.warn_bonus - 0.1) and f9.loot == roundi(f0.loot * 1.5) and not f9.has("sp_every") 		and b9.hp == roundi(b0.hp * 1.15 * 1.2) and is_equal_approx(b9.sp_every, BattleState.SPECIAL_EVERY * 0.7)
	check(foe_ok, "Protokoll 10: Gegner zäher, schneller, härter, kürzere Warnungen, Bosse +20 % HP und öfter Großangriffe, +50 % Fragmente")
	var hp_before := r9.max_hp
	r9.apply_protocol()
	check(r9.rest_heal() == roundi(r9.max_hp * Rooms.REST_HEAL * 0.5) and Rooms.price(r9, 40) == 50 and r9.max_hp == roundi(hp_before * 0.85), "Protokoll: Rast halb, Preise +25 %, Start mit weniger max. HP")
	var hz := BattleState.new(r9, GameData.FOES[7])
	hz.e.atk_t = 99.0
	hz.warns.append({"cells": [Vector2i(0, 0)], "t": 0.02, "max": 0.9, "dmg": 0, "lava": true, "kind": "lava"})
	step(hz, 0.05)
	check(not hz.hazards.is_empty() and hz.hazards[0].t > 4.0, "Protokoll 9: Flächen halten 50 % länger")
	# Freischalten: erst nach dem Abspann, jede auf der höchsten Stufe geschaffte Zone öffnet die nächste
	var saved: Dictionary = SaveGame.data.duplicate(true)
	SaveGame.persist = false
	SaveGame.new_game("Lumi")
	var locked := SaveGame.protocol_unlocked() == 0 and SaveGame.protocol_choice() == 0
	SaveGame.data.game_cleared = true
	SaveGame.data.protocol_sel = 5
	var first := SaveGame.protocol_unlocked() == 1 and SaveGame.protocol_choice() == 1
	var rp := RunState.from_monster(SaveGame.team()[0], 2, "wiesen")
	rp.protocol = 1
	var sum := SaveGame.record_run(rp, true)
	var up := SaveGame.protocol_unlocked() == 2 and int(sum.get("protocol_up", 0)) == 2 and int(SaveGame.team()[0].protocol_best) == 1
	SaveGame.data = saved
	check(locked and first and up, "Protokoll: gesperrt bis zum Abspann, dann Stufe 1; geschaffte Stufe schaltet die nächste frei und gibt ein Abzeichen")


## Legendäre (07.10.2026): je Zone ein Fabelwesen mit geheimer Bedingung
func test_legends() -> void:
	var data_ok := GameData.LEGENDS.size() == 6
	for L in GameData.LEGENDS:
		var U: String = GameData.FORMS[L].up
		data_ok = data_ok and GameData.FORMS[L].stage == 3 and U != "" and GameData.FORMS[U].stage == 4 and GameData.SPECIALS.has(L) and GameData.SPECIALS.has(U) 			and GameData.MONS[L].get("legend", false) and GameData.legend_of(U) == L and not SaveGame.EGG_SPECIES.has(L)
	check(data_ok, "Legendäre: 6 Fabelwesen, je Champion + Ultra mit Signatur, nicht aus normalen Eiern")
	var saved: Dictionary = SaveGame.data.duplicate(true)
	SaveGame.persist = false
	SaveGame.new_game("Lumi")
	var got := {}
	var conds := {"wiesen": func(r): pass, "vulkan": func(r): r.deck = ["Glutball", "Glutball", "Flammenwelle", "Glutklinge", "Funkenregen", "Feuersbrunst", "Heilpatch", "Firewall"],
		"see": func(r): r.pushed = 0, "sumpf": func(r): r.boss_heal = false, "steppe": func(r): r.boss_spark_t = 12.0, "kern": func(r): r.final_sig = true}
	for z in conds:
		var r := RunState.from_monster(SaveGame.team()[0], 3, z)
		r.stage = 1 if z == "wiesen" else 2
		conds[z].call(r)
		got[z] = SaveGame.legend_check(r)   # direkt nach dem Boss-Sieg (Reise, 08.10.2026)
	var all6: bool = got.wiesen == "Glimmhirsch" and got.vulkan == "Glutkirin" and got.see == "Sternwal" and got.sumpf == "Toxilisk" and got.steppe == "Funkengreif" and got.kern == "Chiffrasphinx"
	check(all6, "Legendäre: alle 6 Bedingungen geben ihr leuchtendes Ei (%s)" % str(got))
	var eggs: Array = SaveGame.nest().filter(func(e): return e.get("legend", false))
	check(eggs.size() == 6 and SaveGame.nest().size() > SaveGame.nest_slots(), "Leuchtende Eier liegen auch über den Nestplätzen hinaus im Brutnest")
	# jeder Legendäre nur einmal; Bedingung nicht erfüllt = kein Ei
	var r2 := RunState.from_monster(SaveGame.team()[0], 4, "wiesen")
	r2.stage = 1
	var r3 := RunState.from_monster(SaveGame.team()[0], 5, "see")
	r3.pushed = 2
	SaveGame.data.legends.erase("Sternwal")
	check(SaveGame.legend_check(r2) == "" and SaveGame.legend_check(r3) == "", "Legendäre: nur einmal, und nur wenn die Bedingung erfüllt ist")
	r2.legends_won = ["Glimmhirsch"]
	check(SaveGame.record_run(r2, true).get("legend", "") == "Glimmhirsch", "Run-Ende meldet das leuchtende Ei")
	# Schlüpfen: Champion-Stufe, Ultra ab 80 Element-Chips
	for e in SaveGame.nest():
		e.runs_left = 0
	var h := SaveGame.hatch_next()
	var hm := SaveGame.monster(int(h.get("id", -1)))
	var rl := RunState.from_monster(hm, 6)
	check(hm.get("stage", 0) == 3 and GameData.LEGENDS.has(hm.form) and rl.evo_need() == GameData.EVO_AT[4], "Legendäre schlüpfen als Champion und entwickeln sich ab %d Element-Chips zur Ultra-Form" % GameData.EVO_AT[4])
	SaveGame.data = saved
	# Passive
	var sw := BattleState.new(RunState.new("Sternwal", 1), GameData.FOES[7])
	sw.e.atk_t = 99.0
	sw.hazards.append({"c": sw.p.c, "r": sw.p.r, "t": 3.0, "tick": 0.0, "kind": "lava", "seed": 1})
	var hp0: int = sw.run.hp
	step(sw, 1.0)
	var rw := BattleState.new(RunState.new("Chiffrasphinx", 1), GameData.FOES[0])
	var dealt: Array = []
	for k in 3:
		dealt.append(rw.hurt_player(5))
	var gk := BattleState.new(RunState.new("Glutkirin", 1), GameData.FOES[0])
	gk.hurt_player(5)
	check(sw.run.hp == hp0 and dealt[2] == 0 and dealt[0] > 0 and gk.e.burn > 0, "Passive: Sternenmeer ignoriert Lava, Rätselwächter wehrt jeden 3. Treffer ab, Glutmähne setzt den Angreifer in Brand")


## Stilregel: jedes Sprite höchstens 32 Farben – Grundbild, Blinzel-Bild, Idle- und Angriffs-Frames zusammen (30.09./05.10.2026)
func test_sprite_colors() -> void:
	var files := {}
	for f in GameData.FORMS:
		files[GameData.FORMS[f].spr] = true
	for k in PixelCanvas.SPRITE_FILES:
		files[PixelCanvas.SPRITE_FILES[k]] = true
	var bad: Array = []
	var no_atk: Array = []
	for spr in files:
		var paths: Array = ["res://assets/sprites/%s.png" % spr, "res://assets/sprites/%s_blink.png" % spr]
		for i in 6:
			paths.append("res://assets/sprites/anim/%s_idle_%d.png" % [spr, i])
			paths.append("res://assets/sprites/anim/%s_atk_%d.png" % [spr, i])
		if not ResourceLoader.exists("res://assets/sprites/anim/%s_atk_0.png" % spr):
			no_atk.append(spr)
		var cols := {}
		for p in paths:
			if not ResourceLoader.exists(p):
				continue
			var tex: Texture2D = load(p)
			var img := tex.get_image()
			if img.is_compressed():
				img.decompress()
			img.convert(Image.FORMAT_RGBA8)
			var d := img.get_data()
			for i in range(0, d.size(), 4):
				if d[i + 3] > 0:
					cols[(d[i] << 16) | (d[i + 1] << 8) | d[i + 2]] = true
		if cols.size() > 32:
			bad.append("%s:%d" % [spr, cols.size()])
	check(bad.is_empty(), "Alle %d Sprites höchstens 32 Farben (inkl. Blinzeln, Idle und Angriff) %s" % [files.size(), bad])
	check(no_atk.is_empty(), "Alle %d Figuren haben eine Angriffsanimation %s" % [files.size(), no_atk])


## Station-Führung und Zonenwahl (30.09.2026)
func test_station_guide() -> void:
	SaveGame.persist = false
	SaveGame.new_game("Pixmiez")
	var SV: GDScript = load("res://scripts/ui/station_view.gd")
	var sv = SV.new()
	add_child(sv)
	check(sv.guide == 0 and sv.GUIDE.size() == 8, "Station: beim ersten Besuch startet die Führung (8 Schritte)")
	sv._end_guide()
	check(sv.guide == -1 and SaveGame.data.get("station_guide_done", false), "Station: Führung merkt sich, dass sie gezeigt wurde")
	sv.queue_free()
	var sv2 = SV.new()
	add_child(sv2)
	check(sv2.guide == -1 and sv2.tab == sv2.Tab.HOME and sv2.TAB_ORDER[0] == sv2.Tab.HOME, "Station: beim zweiten Besuch keine Führung mehr, sie öffnet im Reiter Zuhause")
	var started := []
	sv2.start_run.connect(func(id, z): started.append(z))
	sv2.zone_pick = true
	Input.action_press("confirm")
	sv2._process_zone_pick()
	Input.action_release("confirm")
	check(started == ["wiesen"], "Reiseplan: jede Reise beginnt in den Cache-Wiesen")
	sv2.queue_free()
	# Zuhause (06.10.2026): Bewohner bleiben im Laufbereich, tun verschiedene Dinge, Streicheln gibt Herzchen und einen Text
	var team: Array = []
	for sp in ["Pixmiez", "Funkling", "Tröpfel", "Kekso", "Lumi", "Quakli", "Molchi", "Brummbit", "Kauzbit", "Buddli", "Maskli", "Bachli", "Plapperli", "Wolkerich"]:
		var m := SaveGame.add_monster(sp)
		team.append(m)
	var hs := HomeSim.new()
	hs.setup(team, 3)
	var states := {}
	var inside := true
	for k in 60 * 60:
		hs.update(1.0 / 60.0)
		for r in hs.residents:
			states[r.state] = true
			if not HomeSim.AREA.grow(1.0).has_point(Vector2(r.x, r.y)):
				inside = false
	check(hs.residents.size() == HomeSim.MAX and inside, "Zuhause: höchstens %d Bewohner, alle bleiben im Laufbereich" % HomeSim.MAX)
	check(states.has("walk") and states.has("sleep") and states.has("spot") and states.has("play"), "Zuhause: Bewohner laufen, schlafen, spielen und besuchen ihren Lieblingsplatz (%s)" % ", ".join(states.keys()))
	var before := hs.fx.size()
	var msg := hs.pet(0)
	check(hs.residents[0].state == "pet" and hs.fx.size() >= before + 4 and msg.contains(T.t(hs.residents[0].form)), "Zuhause: Streicheln gibt Herzchen und eine Reaktion (%s)" % msg)
	check(hs.order().size() == hs.residents.size(), "Zuhause: Auswahl von links nach rechts")
	# Tageszeiten wechseln mit jedem Run, nachts wird mehr geschlafen als tagsüber
	check(HomeSim.daytime_for(0) == "morgen" and HomeSim.daytime_for(1) == "tag" and HomeSim.daytime_for(3) == "nacht" and HomeSim.daytime_for(4) == "morgen", "Zuhause: Tageszeit wechselt mit jedem Run (Morgen, Tag, Abend, Nacht)")
	var sleep_t := {}
	for dt in ["tag", "nacht"]:
		var hd := HomeSim.new()
		hd.setup(team, 5)
		hd.daytime = dt
		var n := 0
		for k in 60 * 90:
			hd.update(1.0 / 60.0)
			n += hd.residents.filter(func(r): return r.state == "sleep").size()
		sleep_t[dt] = n
	check(sleep_t.nacht > sleep_t.tag * 2, "Zuhause: nachts schlafen deutlich mehr Bewohner (%d gegen %d)" % [sleep_t.nacht, sleep_t.tag])
	# Einzug: der Neue kommt von links herein, die anderen begrüßen ihn, am Ziel gibt es Herzchen
	var hw := HomeSim.new()
	hw.setup(team, 9)
	var nid: int = hw.residents[-1].id
	hw.welcome(nid)
	var greet: bool = hw.residents.slice(0, -1).all(func(r): return r.state == "greet") and hw.residents[-1].x < HomeSim.AREA.position.x
	for k in 60 * 8:
		hw.update(1.0 / 60.0)
		if hw.residents[-1].state == "pet":
			break
	check(greet and hw.residents[-1].state == "pet" and hw.fx.any(func(f): return f.kind == "heart"), "Zuhause: Einzug von links, alle begrüßen den Neuen, Herzchen bei der Ankunft")


## Kampf-Handbuch (30.09.2026)
func test_handbook() -> void:
	var HB: GDScript = load("res://scripts/ui/handbook_view.gd")
	var hb = HB.new()
	check(hb.PAGES.size() == 8, "Handbuch: 8 Seiten")
	# Alle Seitentexte passen in den Textbereich (306 px breit, ~250 px hoch)
	var ok := true
	var f := PixelCanvas.font()
	for i in hb.PAGES.size():
		var hgt: float = f.get_multiline_string_size(hb.page_text(i), HORIZONTAL_ALIGNMENT_LEFT, 306, PixelCanvas.tsz(8), -1, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND).y
		if hgt > 250.0 or hb.page_text(i).contains("{"):
			ok = false
			printerr("    Seite %d: %.0f px" % [i + 1, hgt])
	check(ok, "Handbuch: alle Texte passen und alle Tasten-Platzhalter sind ersetzt")
	check(InputMap.has_action("handbook") and not InputMap.action_get_events("pause").any(func(e): return e is InputEventJoypadButton and e.button_index == JOY_BUTTON_BACK), "Handbuch-Taste H / Select, Select pausiert nicht mehr doppelt")
	# Öffnen und Schließen über einen Bildschirm
	var TS: GDScript = load("res://scripts/ui/title.gd")
	var ts = TS.new()
	add_child(ts)
	ts.open_handbook()
	var opened: bool = ts.handbook != null
	ts.handbook.close()
	await get_tree().process_frame
	check(opened and ts.handbook == null, "Handbuch öffnet sich über dem Titel und schließt wieder")
	ts.queue_free()
	hb.free()


## Gleichmäßiger Kampf (03.10.2026): feste Rechenschritte, Hänger bremsen statt vorzuspulen
func test_frame_pacing() -> void:
	# Ein Geschoss trifft auch dann, wenn ein Bild 250 ms dauert (ohne Begrenzung spränge es 3 Felder weit)
	var sa := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[3])
	sa.e.frozen = 999.0
	sa.def.el = "Neutral"
	sa.e.r = sa.p.r
	sa.e.c = 1
	var hp0: int = sa.e.hp
	sa.proj.append({"lob": false, "row": sa.p.r, "x": sa.p.c + 0.5, "v": 12.0, "el": "Neutral", "dmg": 20, "id": "Pixelstrahl"})
	for i in 20:
		sa.advance(0.25)
	check(sa.e.hp == hp0 - 20, "Hänger von 250 ms: Geschoss überspringt den Gegner nicht (%d Schaden)" % (hp0 - sa.e.hp))
	# Gleicher Kampfverlauf bei 60 Hz und 165 Hz (ohne Eingaben, gleicher Zufall)
	var res: Array = []
	for hz in [60.0, 165.0]:
		var run := RunState.new("Pixmiez", 1)
		run.rng.seed = 11
		var st := BattleState.new(run, GameData.FOES[0])
		st.rng.seed = 11
		var t := 0.0
		while t < 6.0:
			st.advance(1.0 / hz)
			t += 1.0 / hz
		res.append([run.hp, st.e.c, st.e.r])
	check(res[0] == res[1], "60 Hz und 165 Hz: gleicher Kampfverlauf nach 6 s (%s / %s)" % [str(res[0]), str(res[1])])


## Tastaturbelegung (03.10.2026) – ändert nur die InputMap, speichert nichts
func test_key_rebind() -> void:
	var has_key := func(action: String, key: int) -> bool:
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey and ev.physical_keycode == key:
				return true
		return false
	InputSetup.reset_keys()
	check(has_key.call("chip_1", KEY_J) and has_key.call("move_up", KEY_W) and has_key.call("move_up", KEY_UP), "Standardbelegung: J, W (+ Pfeiltaste)")
	var r1 := InputSetup.rebind("chip_1", KEY_U)
	check(r1 == "" and has_key.call("chip_1", KEY_U) and not has_key.call("chip_1", KEY_J) and has_key.call("confirm", KEY_U) and InputSetup.key_label("chip_1") == "U", "Umbelegen: Angriff 1 auf U (auch Bestätigen, Anzeige „U“)")
	var r2 := InputSetup.rebind("chip_2", KEY_U)
	check(r2 == "chip_1" and has_key.call("chip_2", KEY_U) and has_key.call("chip_1", KEY_K), "Doppelt belegt: Tasten werden getauscht")
	var r3 := InputSetup.rebind("special", KEY_ENTER)
	check(r3 == "fest" and has_key.call("special", KEY_SPACE), "Feste Tasten (Enter, Esc, Pfeile …) lassen sich nicht vergeben")
	InputSetup.rebind("move_up", KEY_I)
	check(has_key.call("move_up", KEY_UP) and InputSetup.move_keys() == "IASD", "Pfeiltasten bleiben beim Umbelegen erhalten")
	InputSetup.reset_keys()
	check(has_key.call("chip_1", KEY_J) and has_key.call("chip_2", KEY_K) and InputSetup.overrides.is_empty() and InputSetup.key_text("special", "acc") == T.t("die Leertaste"), "Standard wiederherstellen")


## Spiel zurücksetzen (04.10.2026): Spielstand, Einstellungen und Tastenbelegung wie neu, Log bleibt
func test_reset_game() -> void:
	var keep: Dictionary = SaveGame.data.duplicate(true)
	var keep_vol: int = Settings.volume
	var keep_lang: String = Settings.lang
	SaveGame.new_game("Pixmiez")
	var lf := FileAccess.open(SaveGame.log_path, FileAccess.WRITE)
	lf.store_line("test")
	lf.close()
	Settings.volume = 3
	Settings.vsync = false
	Settings.save_settings()
	InputSetup.rebind("chip_1", KEY_U)
	const TS := preload("res://scripts/ui/title.gd")
	var t: Node = TS.new()
	t.page = TS.Page.OPTIONS
	t.reset_game()
	var log_kept := FileAccess.file_exists(SaveGame.log_path)
	check(not SaveGame.has_save() and not FileAccess.file_exists(Settings.path) and Settings.volume == 8 and Settings.vsync and InputSetup.overrides.is_empty() and t.page == TS.Page.MAIN, "Spiel zurücksetzen: Spielstand, Einstellungen und Tasten wie neu, zurück ins Hauptmenü")
	check(log_kept and Settings.path == "user://test_settings.cfg", "Spiel zurücksetzen: Spieltest-Log bleibt, Tests nutzen eigene Einstellungsdatei")
	t.free()
	SaveGame.data = keep
	Settings.volume = keep_vol
	Settings.lang = keep_lang
	Settings.apply()


## Jeder Chip hat einen eigenen sichtbaren Effekt oder ein eigenes Geschoss (04.10.2026, Tester-Feedback)
func test_chip_vfx() -> void:
	var missing: Array = []
	for id in GameData.CHIPS:
		var st := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[3])
		st.e.r = st.p.r
		st.e.atk_t = 99.0
		st.hand[0].chip = id
		st.hand[0].rem = 0.0
		st.use_slot(0)
		var seen := false
		for i in 60:
			if not st.vfx.is_empty() or not st.proj.is_empty() or st.delayed.any(func(d): return d.mark):
				seen = true
				break
			st.update(1.0 / 60.0)
		if not seen:
			missing.append(id)
	check(missing.is_empty(), "Alle %d Chips haben einen passenden Effekt (ohne: %s)" % [GameData.CHIPS.size(), ", ".join(missing)])
	var sh := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[0])
	sh.hand[2].chip = "Heilpatch"
	sh.hand[2].rem = 0.0
	sh.run.hp = 50
	sh.use_slot(2)
	# Flächeneffekte (05.10.2026): Lava und Schleim brechen beim Entstehen sichtbar aus
	var lv := BattleState.new(RunState.new("Pixmiez", 1), GameData.FOES[7])
	lv.e.atk_t = 99.0
	lv.warns.append({"cells": [Vector2i(0, 0)], "t": 0.05, "max": 0.9, "dmg": 0, "lava": true, "kind": "lava"})
	lv.warns.append({"cells": [Vector2i(2, 2)], "t": 0.05, "max": 0.9, "dmg": 0, "lava": true, "kind": "slime"})
	step(lv, 0.1)
	var er: Array = lv.vfx.filter(func(v): return v.kind == "erupt")
	check(lv.hazards.size() == 2 and er.size() == 2 and er.any(func(v): return v.slime) and lv.hazards.all(func(h): return h.has("seed")), "Lava und Schleim: Ausbruch beim Entstehen, Pfützen mit fester Form")
	check(sh.vfx.any(func(v): return v.kind == "patch") and not sh.parts.any(func(q): return q.color == GameData.EL.Elektro), "Heilpatch: Pflaster und Heil-Partikel statt Elektro-Funken")


## Game-Design-Analyse 08.10.2026: Herkunft der Gegnerangriffe, Konter, Resonanz, Gaben, gelenkte Chipwahl, Neu prägen, Reise
func test_design_review() -> void:
	# Schützen: „row“ trifft die Reihe des Gegners, nicht die des Spielers
	var st := fresh()
	st.e.frozen = 0.0
	st.e.move_t = 99.0
	st.e.r = 0
	st.p.r = 2
	st.e.atk_t = 0.01
	step(st, 0.05)
	var cells: Array = st.warns[0].cells
	check(cells.all(func(c): return c.y == 0) and st.warns[0].atk and st.warns[0].shot, "Schütze schießt entlang seiner eigenen Reihe (nicht auf dein Feld)")
	# Beim Ausholen bleibt er stehen
	st.e.move_t = 0.0
	step(st, 0.1)
	check(st.e.r == 0 and st.winding_up(), "Beim Ausholen bleibt der Gegner stehen")
	# Konter: zu früh zählt nicht, im Fenster bricht der Angriff ab
	var sc := fresh()
	sc.reflex = 0
	sc.e.frozen = 0.0
	sc.e.move_t = 99.0
	sc.e.atk_t = 0.01
	step(sc, 0.05)
	sc.hit_enemy(20, "Neutral")
	check(sc.counters == 0 and sc.winding_up(), "Treffer vor dem Konter-Fenster ist kein Konter")
	step(sc, BattleState.WARN_TIME * BattleState.COUNTER_OPEN)
	var hp0: int = sc.e.hp
	var sp0: float = sc.sp
	sc.hit_enemy(20, "Neutral")
	check(sc.counters == 1 and not sc.winding_up() and hp0 - sc.e.hp == 30 and sc.e.frozen >= BattleState.COUNTER_STUN - 0.01 and sc.sp > sp0 + 20,
		"Konter: Angriff fällt aus, Gegner betäubt, 50 %% mehr Schaden (%d), Signatur lädt" % (hp0 - sc.e.hp))
	step(sc, 1.0)
	check(sc.run.hp == sc.run.max_hp, "Nach dem Konter trifft der abgebrochene Angriff nicht mehr")
	# Resonanz und Gaben
	var rf := RunState.new("Funkling", 1)
	rf.form = "Glutbyte"
	rf.stage = 2
	var sf := BattleState.new(rf, GameData.FOES[0])
	sf.e.frozen = 999.0
	var e0: int = sf.e.hp
	sf.hit_enemy(20, "Feuer")
	check(e0 - sf.e.hp == 24 and sf.e.burn >= 2 and GameData.gift("Glutbyte").name == "Zündeln", "Resonanz: Feuer-Chip bei Glutbyte +20 %% (%d), Gabe Zündeln setzt Brand" % (e0 - sf.e.hp))
	var e1: int = sf.e.hp
	sf.hit_enemy(20, "Wasser")
	check(e1 - sf.e.hp == 20 and GameData.resonance("Glutbyte", "Wasser") == 0.0 and GameData.resonance("Pixmiez", "Neutral") == 0.0, "Keine Resonanz für fremde Elemente und Babys")
	check(GameData.resonance("Magmawulf", "Feuer") == GameData.RESONANCE[3] and GameData.resonance("Glutfenrir", "Feuer") == GameData.RESONANCE[4], "Resonanz wächst mit der Stufe")
	var rc := RunState.new("Pixmiez", 1)
	rc.form = "Firewallo"
	rc.stage = 2
	var scd := BattleState.new(rc, GameData.FOES[0])
	scd.reflex = 0
	scd.shield = 4.0
	scd.hurt_player(10)
	check(scd.sp == float(GameData.gift("Firewallo").v), "Code-Gabe Schutzroutine: Blocken lädt die Signatur")
	var re := RunState.new("Pixmiez", 1)
	re.form = "Prismiez"
	re.stage = 2
	var se := BattleState.new(re, GameData.FOES[0])
	se.hit_enemy(10, "Elektro")
	check(se.e.frozen > 0.0, "Elektro-Gabe Funkenflug betäubt kurz")
	# Chipwahl lenkt: immer mindestens ein Chip für eine Entwicklungsrichtung bzw. die Resonanz
	var ok_baby := true
	var ok_rookie := true
	var rp := RunState.new("Pixmiez", 7)
	var rg := RunState.new("Funkling", 8)
	rg.form = "Glutbyte"
	rg.stage = 2
	for i in 60:
		if not rp.roll_pick(GameData.RARITY_WEIGHT).any(func(k): return ["Code", "Virus", "Elektro"].has(GameData.CHIPS[k].el)):
			ok_baby = false
		if not rg.roll_pick(GameData.RARITY_WEIGHT).any(func(k): return GameData.CHIPS[k].el == "Feuer"):
			ok_rookie = false
	check(ok_baby and ok_rookie, "Chipwahl: immer ein Chip für die Entwicklung (Baby) bzw. die Resonanz (Rookie)")
	# Neu prägen im Labor
	var saved: Dictionary = SaveGame.data.duplicate(true)
	SaveGame.persist = false
	var m := SaveGame.new_game("Pixmiez")
	m.form = "Bollwerkatz"
	m.stage = 3
	m.chips = 999
	m.praeg = {"Code": 950}
	SaveGame.see("Bollwerkatz")
	SaveGame.data.frag = SaveGame.REIMPRINT_COST + 5
	var res := SaveGame.reimprint(int(m.id))
	var mm := SaveGame.monster(int(m.id))
	check(res.ok and mm.form == "Pixmiez" and int(mm.stage) == 1 and int(mm.chips) == 0 and mm.praeg.is_empty() and SaveGame.frag() == 5 and SaveGame.data.dex.has("Bollwerkatz"),
		"Neu prägen: zurück zum Baby, Prägung bei 0, Dex bleibt, kostet %d Fragmente" % SaveGame.REIMPRINT_COST)
	var fu := SaveGame.add_monster("Wolkerich")
	fu.stage = 3
	SaveGame.data.frag = 999
	check(not SaveGame.reimprint(int(fu.id)).ok and not SaveGame.reimprint(int(m.id)).ok, "Neu prägen: nicht für Fusionen und nicht für Babys")
	# Run-Ende: Eier je besiegtem Zonen-Boss
	SaveGame.data.nest = []
	var rj := RunState.from_monster(m, 3)
	rj.fights_won = 5
	rj.bosses = ["wiesen", "vulkan"]
	var sum := SaveGame.record_run(rj, false)
	check(sum.eggs.size() == 3 and sum.first_bosses == ["wiesen", "vulkan"], "Run-Ende: ein Ei für die Siege und eins je Zonen-Boss (%d)" % sum.eggs.size())
	SaveGame.data = saved
	SaveGame.persist = true
	# Ganze Reisen mit dem Autopiloten: jeder Kampf endet, die Reise führt durch alle vier Akte
	var S := BalanceSim.run_journey(4, 3, "perfect")
	check(S.stuck == 0 and S.acts[3] >= 1, "Reise mit Autopilot: kein Kampf hängt, Akt 4 wird erreicht (%d/%d Siege)" % [S.wins, S.runs])
	print("  info    Reise-Autopilot (Ultra, perfekt): %d/%d Siege, Ø %.1f s je normalem Kampf, %d Konter" % [S.wins, S.runs, S.ntime / maxf(1, S.nfights), S.counters])


## Kampffeld (08.10.2026): Platten je Zone im Material der Zone, Seiten unterscheidbar, Größe passt zum Raster
func test_arena_tiles() -> void:
	var BV: GDScript = load("res://scripts/battle/battle_view.gd")
	var t0 := Time.get_ticks_usec()
	var ok: bool = ArenaTiles.TW == BV.CW - 4 and ArenaTiles.TH == BV.CH - 4
	var mats := {}
	for z in GameData.ZONE_ORDER:
		var bg: String = GameData.ZONES[z].bg
		ArenaTiles.preload_bg(bg)
		var p: Image = ArenaTiles.tile(bg, 0, 0)[0].get_image()
		var e: Image = ArenaTiles.tile(bg + "_boss", 1, 0)[0].get_image()
		ok = ok and p.get_width() == ArenaTiles.TW and p.get_height() == ArenaTiles.TH
		# Seiten unterscheidbar: mittlere Farbe der Fläche deutlich verschieden
		var cp := _avg_color(p)
		var ce := _avg_color(e)
		if Vector3(cp.r - ce.r, cp.g - ce.g, cp.b - ce.b).length() < 0.08:
			ok = false
			printerr("    Seiten zu ähnlich: ", z)
		mats[str(_avg_color(p))] = true
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	check(ok and mats.size() == GameData.ZONE_ORDER.size(), "Kampffeld: eigene Platten je Zone (%d Materialien), Spieler- und Gegnerseite unterscheidbar, passend zum Raster" % mats.size())
	print("  info    Kampffeld-Platten erzeugt in %.0f ms" % ms)


func _avg_color(img: Image) -> Color:
	var r := 0.0
	var g := 0.0
	var b := 0.0
	var n := 0
	for y in range(2, img.get_height() - ArenaTiles.EDGE - 1):
		for x in range(2, img.get_width() - 2):
			var c := img.get_pixel(x, y)
			r += c.r
			g += c.g
			b += c.b
			n += 1
	return Color(r / n, g / n, b / n)


## Händler, Rast und Ereignisse als Karten; Zuhause mit Abstand (08.10.2026)
func test_room_cards_and_home() -> void:
	var RV: GDScript = load("res://scripts/ui/room_view.gd")
	var ok := true
	for t in ["shop", "rest", "event"]:
		var run := RunState.new("Pixmiez", 3)
		run.frag = 80
		run.enter(run.next_choices()[0])
		run.current_node().type = t
		var rv = RV.new()
		rv.setup(run)
		var o: Array = rv._options()
		var rects: Array = rv._layout(o)
		for i in rects.size():
			if not RV.PANEL.encloses(rects[i]):
				ok = false
			for j in range(i + 1, rects.size()):
				if rects[i].intersects(rects[j]):
					ok = false
		rv.free()
	check(ok, "Händler, Rast, Ereignis: Karten liegen im Fenster und überlappen sich nicht")
	# Navigation: rechts geht zur Karte daneben, runter vom Angebot zu den Diensten
	var rs := RunState.new("Pixmiez", 4)
	rs.frag = 80
	rs.enter(rs.next_choices()[0])
	rs.current_node().type = "shop"
	var sv = RV.new()
	sv.setup(rs)
	var so: Array = sv._options()
	var sr: Array = sv._layout(so)
	var right: int = RV.nav_dir(sr, 0, Vector2.RIGHT)
	var down: int = RV.nav_dir(sr, right, Vector2.DOWN)
	var up: int = RV.nav_dir(sr, down, Vector2.UP)
	check(right == 1 and not String(so[down].id).begins_with("buy_") and String(so[up].id).begins_with("buy_") and RV.nav_dir(sr, 0, Vector2.LEFT) == 0,
		"Händler: Pfeile springen zur Nachbarkarte, zu den Diensten und zurück")
	sv.free()
	# Zuhause: nach einer Minute steht niemand mehr direkt auf einem anderen
	var team: Array = []
	var forms := ["Prismiez", "Glutbyte", "Bollwerkatz", "Aurorlynx", "Magmawulf", "Tsunamander", "Kaskadi", "Optikauz", "Glutfenrir", "Titanbrumm", "Firewallo"]
	var species := ["Pixmiez", "Funkling", "Pixmiez", "Pixmiez", "Funkling", "Tröpfel", "Tröpfel", "Kauzbit", "Funkling", "Brummbit", "Pixmiez"]
	for i in forms.size():
		team.append({"id": i + 1, "form": forms[i], "species": species[i], "stage": GameData.FORMS[forms[i]].stage})
	var home := HomeSim.new()
	home.setup(team, 11)
	for k in 60 * 60:
		home.update(1.0 / 60.0)
	var stacked := 0
	for i in home.residents.size():
		for j in range(i + 1, home.residents.size()):
			var a: Dictionary = home.residents[i]
			var b: Dictionary = home.residents[j]
			if a.partner == j:
				continue
			var d := Vector2(b.x - a.x, (b.y - a.y) * HomeSim.DEPTH).length()
			if d < (HomeSim.width(a) + HomeSim.width(b)) * 0.2:
				stacked += 1
	check(stacked <= 1, "Zuhause: Bewohner halten Abstand (%d Paare direkt übereinander)" % stacked)
