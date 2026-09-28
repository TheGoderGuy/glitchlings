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
	test_evolution()
	test_all_specials()
	test_passives()
	test_map()
	test_rooms()
	test_elite_scaling()
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


func test_evolution() -> void:
	var run := RunState.new("Pixmiez", 1)
	run.chips_used = GameData.EVO_AT[2] - 1
	run.praeg = {"Neutral": 20, "Feuer": 4}
	check(run.try_evolve().is_empty(), "Unter der Schwelle keine Evolution")
	run.chips_used = GameData.EVO_AT[2]
	var ev := run.try_evolve()
	check(ev.get("to", "") == "Blazebit" and run.stage == 2 and run.max_hp == 110, "Feuer-Prägung: Pixmiez → Blazebit, +10 max. HP")
	run.chips_used = GameData.EVO_AT[3]
	check(run.try_evolve().get("to", "") == "Glutluchs" and run.stage == 3, "Champion-Schwelle: Blazebit → Glutluchs")
	check(run.try_evolve().is_empty(), "Champion ohne weitere Stufe bleibt")
	var run2 := RunState.new("Pixmiez", 1)
	run2.chips_used = 30
	run2.praeg = {"Neutral": 30}
	check(run2.try_evolve().is_empty(), "Nur neutrale Chips: noch keine Richtung, keine Evolution")
	var run3 := RunState.new("Pixmiez", 1)
	run3.chips_used = 30
	run3.praeg = {"Feuer": 3, "Code": 3, "Wasser": 3, "Virus": 3}
	check(run3.try_evolve().get("to", "") == "Prismiez", "Bunt gemischt (je ≤ 30 %): geheime Evolution Prismiez")
	var run4 := RunState.new("Tröpfel", 1)
	run4.chips_used = GameData.EVO_AT[2]
	run4.praeg = {"Wasser": 10}
	run4.eis = 4
	check(run4.try_evolve().get("to", "") == "Frostbyte", "Tröpfel mit 4× Eisfeld → Frostbyte")
	var run5 := RunState.new("Funkling", 1)
	run5.chips_used = GameData.EVO_AT[2]
	run5.praeg = {"Feuer": 5, "Code": 9}
	check(run5.try_evolve().get("to", "") == "Overclocko", "Funkling mit mehr Code als Feuer → Overclocko")
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
		var dealt: int = 320 - st.e.hp
		# Brand/Gift ticken in 1,2 s höchstens einmal mit
		if dealt < expected or dealt > expected + 9:
			ok = false
			printerr("    %s: erwartet %d, verursacht %d" % [f, expected, dealt])
	check(ok, "Alle %d Signatur-Attacken treffen mit ihrem vollen Schaden" % GameData.SPECIALS.size())


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
	run3.form = "Glutluchs"
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
		var run := RunState.new(["Pixmiez", "Funkling", "Tröpfel"][seed_value % 3], seed_value)
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
