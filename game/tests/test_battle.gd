extends SceneTree
## Kampflogik-Tests ohne Grafik.
## Aufruf: godot --headless --path game --script res://tests/test_battle.gd

var count := 0
var fails := 0
var seen_events := {}


func _init() -> void:
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
	test_simulated_runs()
	test_sounds()
	print("\n%d Prüfungen, %d Fehler" % [count, fails])
	quit(1 if fails > 0 else 0)


func check(cond: bool, what: String) -> void:
	count += 1
	if cond:
		print("  ok      ", what)
	else:
		fails += 1
		printerr("  FEHLER  ", what)


func fresh(room := 0) -> BattleState:
	var run := RunState.new("Pixmiez", 1)
	run.room = room
	var st := BattleState.new(run, room)
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
	check(GameData.mult("Licht", "Virus") == 1.5, "Licht schlägt Virus")
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
	check(st.pops.is_empty(), "Pop-up schließt sich beim Draufsteigen")


func test_choices() -> void:
	var run := RunState.new("Pixmiez", 3)
	var ch := run.roll_choices()
	check(ch.size() == 3 and ch[0] != ch[1] and ch[1] != ch[2] and ch[0] != ch[2], "Chipwahl: 3 verschiedene Chips")


## Komplette Runs mit Autopilot: jeder Kampf muss enden, Siegquote als Balancing-Hinweis.
func test_simulated_runs() -> void:
	var wins := 0
	var stuck := 0
	var total_time := 0.0
	var runs := 40
	for seed_value in runs:
		seed(seed_value)
		var run := RunState.new("Pixmiez", seed_value)
		var bot := BattleBot.new(0.25)
		var won := true
		while true:
			var st := BattleState.new(run, run.room)
			var t := 0.0
			while not st.over and t < 180.0:
				bot.act(st)
				st.update(1.0 / 30.0)
				for ev in st.events:
					seen_events[ev] = true
				st.events.clear()
				t += 1.0 / 30.0
			total_time += t
			if not st.over:
				stuck += 1
				won = false
				break
			if st.outcome == "lost":
				won = false
				break
			if run.is_last_room():
				break
			run.hp = mini(run.max_hp, run.hp + 15)
			run.deck.append(run.roll_choices()[0])
			run.room += 1
		if won:
			wins += 1
	check(stuck == 0, "Kein Kampf hängt (180 s Limit)")
	print("  info    Autopilot (0,25 s Reaktion): %d/%d Runs gewonnen, Ø %.0f s Kampfzeit pro Run" % [wins, runs, total_time / runs])


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
