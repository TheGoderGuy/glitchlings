class_name BalanceSim
extends RefCounted
## Spielt komplette Runs ohne Grafik (Balancing, Tests). Räume nimmt sie wie der Test-Autopilot:
## erste freie Option, Chipwahl immer die erste Karte. Ergebnis: Kennzahlen als Dictionary.

const LINES := ["Pixmiez", "Funkling", "Tröpfel", "Kekso", "Lumi", "Quakli", "Molchi", "Brummbit", "Kauzbit", "Buddli", "Maskli", "Bachli", "Plapperli"]


static func make_bot(kind: String) -> BattleBot:
	match kind:
		"perfect":
			return BattleBot.new(0.25)
		"counter":
			var b := BattleBot.human()
			b.counter_wait = true
			return b
	return BattleBot.human()


## Form einer Linie auf einer Stufe (erste Rookie-Richtung je nach Zufall, dann geradeaus)
static func form_for(species: String, stage: int, rng: RandomNumberGenerator) -> String:
	var f := species
	var M: Dictionary = GameData.MONS[species]
	if stage >= 2 and not M.evo.is_empty():
		var ks: Array = M.evo.keys()
		f = M.evo[ks[rng.randi_range(0, ks.size() - 1)]]
	var s := 2
	while s < stage and GameData.FORMS[f].up != "":
		f = GameData.FORMS[f].up
		s += 1
	return f


static func new_stats() -> Dictionary:
	return {"runs": 0, "wins": 0, "fights": 0, "nfights": 0, "ntime": 0.0, "natk": 0, "nloss": 0.0,
		"bfights": 0, "btime": 0.0, "counters": 0, "end_hp": 0.0, "deaths": {}, "chips": 0, "stuck": 0,
		"acts": [0, 0, 0, 0], "time": 0.0, "el_chips": 0, "stage_end": {}, "evo_act": {}, "ch_runs": []}


## Ganze Reisen (alle Akte, Zonenwahl zufällig) mit Monstern der angegebenen Stufe und Lebenszeit-Prägung
static func run_journey(stage: int, runs: int, bot_kind := "human", diff := 1, protocol := 0, chips := 0) -> Dictionary:
	var S := new_stats()
	for sv in runs:
		seed(2000 + sv)
		var sp: String = LINES[sv % LINES.size()]
		var rng := RandomNumberGenerator.new()
		rng.seed = 177 + sv
		var form := form_for(sp, stage, rng)
		var el: String = GameData.FORMS[form].el
		var md := {"id": -1, "species": sp, "form": form, "stage": GameData.FORMS[form].stage, "chips": chips, "praeg": {el: chips} if el != "Neutral" else {}}
		var run := RunState.from_monster(md, 900 + sv)
		run.difficulty = diff
		run.protocol = protocol
		run.apply_protocol()
		play_run(run, make_bot(bot_kind), S)
	return S


## Runs durch eine Zone mit Monstern der angegebenen Stufe
static func run_zone(zone: String, stage: int, runs: int, bot_kind := "human", diff := 1, protocol := 0) -> Dictionary:
	var S := new_stats()
	for sv in runs:
		seed(1000 + sv)
		var sp: String = LINES[sv % LINES.size()]
		var rng := RandomNumberGenerator.new()
		rng.seed = 77 + sv
		var form := form_for(sp, stage, rng)
		var md := {"id": -1, "species": sp, "form": form, "stage": GameData.FORMS[form].stage, "chips": 0, "praeg": {}}
		var run := RunState.from_monster(md, 500 + sv, zone)
		run.difficulty = diff
		run.protocol = protocol
		run.apply_protocol()
		play_run(run, make_bot(bot_kind), S)
	return S


## Einen Run bis zum Sieg oder zur Niederlage spielen und die Kennzahlen in S sammeln
static func play_run(run: RunState, bot: BattleBot, S: Dictionary) -> bool:
	S.runs += 1
	var won := false
	var el0 := run.element_chips()
	var tmin := 999.0
	var tguard := 999.0
	while true:
		var ch := run.next_choices()
		if ch.is_empty():
			break
		var node := run.enter(ch[run.rng.randi_range(0, ch.size() - 1)])
		if node.type in ["fight", "elite", "glitch", "guard", "boss"]:
			var st := BattleState.new(run, run.foe_for(node))
			var hp0 := run.hp
			var t := 0.0
			var atks := 0
			while not st.over and t < 240.0:
				bot.act(st)
				st.update(1.0 / 30.0)
				t += 1.0 / 30.0
				if st.events.has("strike"):
					atks += 1
				st.events.clear()
			S.fights += 1
			S.time += t + 6.0   # Materialisieren, Siegerpose, Chipwahl, Karte
			S.counters += st.counters
			if node.type == "fight":
				S.nfights += 1
				S.ntime += t
				S.natk += atks
				S.nloss += float(hp0 - run.hp) / run.max_hp
			if node.type in ["guard", "boss"]:
				S.bfights += 1
				S.btime += t
			if not st.over:
				S.stuck += 1
			if not st.over or st.outcome == "lost":
				S.deaths[node.type] = S.deaths.get(node.type, 0) + 1
				break
			tmin = minf(tmin, t)
			if node.type == "guard":
				tguard = minf(tguard, t)
			if node.type == "boss":
				if run.act == 0:
					S["baby_boss"] = S.get("baby_boss", 0) + (1 if run.stage == 1 else 0)
				run.bosses.append(run.map.zone)
				if run.final_act():
					won = true
					break
				run.try_evolve()
				run.heal(10)
				run.deck.append(run.roll_pick({"Gewöhnlich": 0, "Selten": 1, "Episch": 3})[0])
				run.add_module(run.roll_module())
				var opts := run.act_choices()
				run.next_act(opts[run.rng.randi_range(0, opts.size() - 1)])
				S.acts[run.act] += 1
				continue
			if node.type == "guard":
				run.next_level()
				run.heal(roundi(run.max_hp * 0.3))
				run.add_module(run.roll_module())
			var st0 := run.stage
			run.try_evolve()
			if run.stage > st0 and not S.evo_act.has("%d" % run.stage):
				S.evo_act["%d" % run.stage] = []
			if run.stage > st0:
				S.evo_act["%d" % run.stage].append(run.act + 1)
			run.heal(10)
			run.deck.append(run.roll_pick(GameData.RARITY_WEIGHT)[0])
		else:
			auto_room(run, node)
	S.chips += run.chips_used
	S.el_chips += run.element_chips() - el0
	S.stage_end["%d" % run.stage] = S.stage_end.get("%d" % run.stage, 0) + 1
	# Herausforderungen: Bestwerte dieser Reise (wie RunState.ch, dazu Element-Chips und schnellster Sieg)
	var vals := run.ch.duplicate()
	for el in run.praeg:
		vals["el_" + el.to_lower()] = int(run.praeg[el])
	vals["tmin"] = tmin
	vals["tguard"] = tguard
	vals["won"] = 1 if won else 0
	S.ch_runs.append(vals)
	if won:
		S.wins += 1
		S.end_hp += float(run.hp) / run.max_hp
	return won


## Räume wie der Test-Autopilot: erste freie Option, beim Entfernen/Verbessern der erste Chip
static func auto_room(run: RunState, node: Dictionary) -> void:
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


static func journey_line(label: String, S: Dictionary) -> String:
	var n := maxi(1, S.nfights)
	var r := maxi(1, S.runs)
	return ("Baby beim Wiesen-Boss: %d  " % S.get("baby_boss", 0)) + "%-14s Sieg %2d/%-2d  erreicht Akt 2/3/4: %d/%d/%d  normal Ø %4.1f s · HP-Verlust %2.0f %%  Wächter/Boss Ø %4.1f s  Run Ø %4.1f min  Element-Chips/Run %3.0f  Endstufen %s  Entwicklung in Akt %s  Tode %s" % [
		label, S.wins, S.runs, S.acts[1], S.acts[2], S.acts[3], S.ntime / n, 100.0 * S.nloss / n, S.btime / maxf(1, S.bfights),
		S.time / r / 60.0, float(S.el_chips) / r, S.stage_end, _avg_dict(S.evo_act), S.deaths]


## Herausforderungen: je Reise-Bestwert Durchschnitt, Höchstwert und wie viele Reisen das Ziel erreicht hätten
static func challenge_line(S: Dictionary) -> String:
	var out: PackedStringArray = []
	var keys := ["konter10", "felsenfest", "blitz", "gold", "glitch2", "waechter", "final_ohne", "minimal", "baby2", "heal",
		"el_feuer", "el_wasser", "el_code", "el_elektro", "el_virus", "tmin", "tguard"]
	for k in keys:
		var sum := 0.0
		var mx := 0.0
		var hit := 0
		var goal: int = int(GameData.challenge(k).get("goal", 0))
		for v in S.ch_runs:
			var x := float(v.get(k, 0))
			sum += x
			mx = maxf(mx, x)
			if goal > 0 and x >= goal:
				hit += 1
		var n := maxi(1, S.ch_runs.size())
		out.append("%s Ø%.1f max %.0f%s" % [k, sum / n, mx, (" Ziel %d: %d/%d" % [goal, hit, n]) if goal > 0 else ""])
	return "  Herausforderungen: " + " · ".join(out)


static func _avg_dict(d: Dictionary) -> String:
	var out: PackedStringArray = []
	for k in d:
		var a: Array = d[k]
		var sum := 0.0
		for v in a:
			sum += v
		out.append("%s:%.1f" % [k, sum / maxf(1, a.size())])
	return " ".join(out)


static func zone_line(z: String, S: Dictionary) -> String:
	var n := maxi(1, S.nfights)
	return "%-7s Sieg %2d/%-2d  normal Ø %4.1f s · %.1f Gegnerangriffe · HP-Verlust %2.0f %%  Wächter/Boss Ø %4.1f s  Konter/Kampf %.1f  HP am Ende %3.0f %%  Tode %s" % [
		z, S.wins, S.runs, S.ntime / n, float(S.natk) / n, 100.0 * S.nloss / n, S.btime / maxf(1, S.bfights),
		float(S.counters) / maxf(1, S.fights), 100.0 * S.end_hp / maxf(1, S.wins), S.deaths]
