class_name Tutorial
extends RefCounted
## Geführter Trainingskampf (04.10.2026, Tester-Feedback: „Das Handbuch liest keiner, wir wollen in einen Kampf“).
## Läuft direkt nach der Starterwahl und jederzeit über Titel > Training. Zwölf Lernschritte zum Selbermachen:
## Bewegen > Angriff 1 > Angriff 2 > Ausweichen > Konter (08.10.2026) > Schützen > Element-Vorteil > Kette > Großangriff >
## Zertreten > Dornenranken (09.10.2026, Spieltest) > Signatur > frei kämpfen.
## Steuert nur, wann der Gegner angreifen darf, legt passende Chips auf die Hand und prüft die Fortschritte;
## die Ansicht zeigt die Texte. Der Spieler kann in diesem Kampf nicht verlieren.

enum Step { MOVE, CHIP, CHIP2, DODGE, COUNTER, SHIELD, ELEMENT, CHAIN, BIG, STOMP, THORN, SPECIAL, FREE, DONE }
const LEARN_STEPS := 12    # Fortschrittspunkte (MOVE … SPECIAL)
## Jeder Lernschritt bleibt mindestens so lange stehen (08.10.2026, Produzent: Training war „kurz ein Kampf, dann Station“ –
## wer schnell drückt, erledigte die ersten Schritte in unter einer Sekunde und sah die Texte nie).
## Was in dieser Zeit passiert, zählt trotzdem (Treffer, gespielter Slot, Element-Vorteil, Signatur).
const MIN_STEP := 1.5

var step := Step.MOVE
var moves := 0
var dodges := 0
var last_pos := Vector2i(1, 1)
var last_hits := 0
var last_warns := 0
var hp_at_warn := 0
var step_t := 0.0          # Zeit im aktuellen Schritt
var big_started := false
var done_t := 0.0          # Zeit für die Abschlussmeldung
var just_finished := false
var foe_name := ""
var foe_el := ""
var chain := 0             # Kette im Schritt CHAIN (Anzeige)
var stomps0 := 0           # Zertreten-Zähler zu Beginn des Schritts STOMP
var goal := Vector2i(-1, -1)   # Ziel-Feld im Dornen-Parcours (die Ansicht hebt es hervor)


func _go(s: Step) -> void:
	step = s
	step_t = 0.0


func update(st: BattleState, dt: float) -> void:
	just_finished = false
	step_t += dt
	foe_name = st.def.name
	foe_el = st.def.el
	var pos := Vector2i(st.p.c, st.p.r)
	# Gegner greift nur in den Schritten an, in denen es darum geht
	var hold := step in [Step.MOVE, Step.CHIP, Step.CHIP2, Step.ELEMENT, Step.CHAIN, Step.STOMP, Step.THORN, Step.SPECIAL] or (step == Step.SHIELD and st.shield <= 0) or step == Step.BIG
	chain = st.chain_n
	if hold:
		st.e.atk_t = maxf(st.e.atk_t, 1.0)
		st.e.move_t = maxf(st.e.move_t, 1.0)
	# Der Gegner hält bis zum freien Kampf durch, verlieren kann man im Training nie
	st.min_e_hp = roundi(st.e.max * 0.35) if step < Step.FREE else 0
	st.min_p_hp = 1
	if step_t < MIN_STEP and step < Step.FREE:
		last_pos = pos
		return
	match step:
		Step.MOVE:
			if pos != last_pos:
				moves += 1
			if moves >= 3:
				_go(Step.CHIP)
				# Gegner in die Reihe des Spielers holen, damit der erste Schuss trifft
				st.e.r = st.p.r
				last_hits = st.e.max - st.e.hp
		Step.CHIP:
			if st.e.max - st.e.hp > last_hits:
				_go(Step.CHIP2)
				st.hand[1].rem = 0.0
		Step.CHIP2:
			if st.last_slot == 1:
				_go(Step.DODGE)
				st.e.atk_t = 0.6
				last_warns = 0
		Step.DODGE:
			# Der Gegner schießt entlang seiner Reihe: vor jedem Schuss stellt er sich in deine
			if st.warns.is_empty() and st.e.atk_t < 0.4:
				st.e.r = st.p.r
			# Eine Warnung ist abgelaufen, ohne dass der Spieler getroffen wurde > ausgewichen
			if st.warns.size() > 0 and last_warns == 0:
				hp_at_warn = st.run.hp
			if st.warns.size() == 0 and last_warns > 0:
				if st.run.hp >= hp_at_warn:
					dodges += 1
				hp_at_warn = st.run.hp
			last_warns = st.warns.size()
			if dodges >= 2:
				_go(Step.COUNTER)
				_give(st, 0, "Laserschuss")
				st.e.atk_t = 2.0
		Step.COUNTER:
			# Der Gegner stellt sich in deine Reihe und holt langsamer aus als sonst; der Laserschuss trifft sofort
			st.e.move_t = maxf(st.e.move_t, 1.0)
			if st.warns.is_empty():
				st.e.r = st.p.r
				st.e.atk_t = minf(st.e.atk_t, 1.5)
			for w in st.warns:
				if w.get("atk", false) and w.max < 1.3:
					w.t += 0.6
					w.max += 0.6
			if st.events.has("counter"):
				_go(Step.SHIELD)
				_give(st, 2, "Firewall")
			elif st.hand[0].chip != "Laserschuss" and st.hand[0].rem <= 0:
				_give(st, 0, "Laserschuss")
		Step.SHIELD:
			# Sobald die Firewall steht, greift der Gegner genau die Reihe des Spielers an
			if st.shield > 0 and step_t > 0.2 and st.warns.is_empty() and st.e.atk_t > 0.5:
				st.e.r = st.p.r
				st.e.atk_t = 0.3
			if st.events.has("block"):
				_go(Step.ELEMENT)
				_give(st, 0, "Blitzcursor")
				st.last_mult = 1.0
			elif st.shield <= 0 and st.hand[2].chip != "Firewall" and st.hand[2].rem <= 0:
				# Firewall verpufft, ohne zu blocken: noch einmal
				_give(st, 2, "Firewall")
		Step.ELEMENT:
			if st.last_mult > 1.0:
				_go(Step.CHAIN)
				_give(st, 0, "Blitzcursor")
				_give(st, 1, "Blitzcursor")
			elif st.hand[0].chip != "Blitzcursor" and st.hand[0].rem <= 0 and st.last_mult <= 1.0 and step_t > 1.5:
				_give(st, 0, "Blitzcursor")
		Step.CHAIN:
			# Kette: drei Elektro-Angriffe hintereinander (Blitzcursor trifft immer), nachgelegte Karten laden normal
			for i in 2:
				if st.hand[i].chip != "Blitzcursor":
					st.hand[i].chip = "Blitzcursor"
			if st.chain_n >= 3:
				_go(Step.BIG)
		Step.BIG:
			if not big_started and step_t > 0.8:
				big_started = true
				st.start_special()
			if st.events.has("overload"):
				_go(Step.STOMP)
				_spawn_mite(st)
			elif big_started and st.sp_left <= 0 and st.warns.is_empty() and step_t > 1.0:
				# getroffen: gleich noch einmal
				big_started = false
				step_t = 0.0
		Step.STOMP:
			# Bitmilbe zertreten (lädt die Signatur); platzt sie, kommt eine neue
			if st.stomps > stomps0:
				_go(Step.THORN)
				_thorn_course(st)
			elif st.pops.is_empty():
				_spawn_mite(st)
		Step.THORN:
			# Dornen-Parcours: außen herum zum Ziel, Hineinlaufen tut weh (verlieren kann man nicht)
			if pos == goal:
				goal = Vector2i(-1, -1)
				st.hazards = st.hazards.filter(func(h): return h.get("kind", "") != "thorn")
				_go(Step.SPECIAL)
				st.sp = 100.0
		Step.SPECIAL:
			if st.sp < 100.0:
				_go(Step.FREE)
				done_t = 3.5
				just_finished = true
				# Bugsy rappelt sich auf: der freie Kampf soll ein richtiger kleiner Kampf sein, nicht ein einzelner Treffer
				st.e.hp = maxi(st.e.hp, roundi(st.e.max * 0.6))
				st.banner = {"text": T.t("Frei kämpfen!"), "color": GameData.COL.mint, "t": 1.3, "max": 1.3}
		Step.FREE:
			done_t -= dt
			if done_t <= 0:
				_go(Step.DONE)
	last_pos = pos


## Eine Bitmilbe auf ein freies Feld setzen, mit mehr Zeit als im Kampf
func _spawn_mite(st: BattleState) -> void:
	stomps0 = st.stomps
	st._spawn_pop()
	if not st.pops.is_empty():
		st.pops[-1].t = 6.0
		st.pops[-1].max = 6.0


## Ziel in der gegenüberliegenden Ecke, zwei Dornenfelder liegen im Weg: der Weg bleibt offen, wird möglichst lang,
## und die Dornen liegen so nah wie möglich am Ziel (von der Mitte aus ist auf 3 × 3 kein Umweg möglich, dann blockieren sie den naheliegenden Weg)
func _thorn_course(st: BattleState) -> void:
	var p := Vector2i(st.p.c, st.p.r)
	goal = Vector2i(2 if p.x <= 1 else 0, 0 if p.y >= 1 else 2)
	var cells: Array = []
	for c in 3:
		for r in 3:
			var v := Vector2i(c, r)
			if v != p and v != goal:
				cells.append(v)
	var best: Array = []
	var best_score := -999
	for i in cells.size():
		for j in range(i + 1, cells.size()):
			var n := _path_len(p, goal, [cells[i], cells[j]])
			if n < 0:
				continue
			var near: int = absi(cells[i].x - goal.x) + absi(cells[i].y - goal.y) + absi(cells[j].x - goal.x) + absi(cells[j].y - goal.y)
			var score := n * 10 - near
			if score > best_score:
				best_score = score
				best = [cells[i], cells[j]]
	for k in best.size():
		st.hazards.append({"c": best[k].x, "r": best[k].y, "t": 60.0, "max": 60.0, "tick": 0.0, "kind": "thorn", "seed": 7 + k})


## Schritte von a nach b auf der eigenen 3 × 3-Seite, ohne die gesperrten Felder (-1 = kein Weg)
static func _path_len(a: Vector2i, b: Vector2i, blocked: Array) -> int:
	var dist := {a: 0}
	var queue: Array = [a]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if c == b:
			return dist[c]
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x < 0 or n.x > 2 or n.y < 0 or n.y > 2 or dist.has(n) or blocked.has(n):
				continue
			dist[n] = dist[c] + 1
			queue.append(n)
	return -1


## Einen bestimmten Chip sofort spielbereit in einen Slot legen
func _give(st: BattleState, slot: int, chip: String) -> void:
	st.hand[slot].chip = chip
	st.hand[slot].rem = 0.0
	st.hand[slot].max = GameData.chip(chip).cd


func active() -> bool:
	return step != Step.DONE


## Überschrift und Anleitung für den aktuellen Schritt
func texts(pad: bool) -> Array:
	var k1: String = InputSetup.btn("X") if pad else InputSetup.key_label("chip_1")
	var k2: String = InputSetup.btn("A") if pad else InputSetup.key_label("chip_2")
	var k3: String = InputSetup.btn("B") if pad else InputSetup.key_label("chip_3")
	match step:
		Step.MOVE:
			return [T.t("Bewegen (%d/3)") % mini(moves, 3), T.t("Beweg dich mit %s über deine blauen Felder.") % (T.t("dem Steuerkreuz oder dem linken Stick") if pad else T.t("%s oder den Pfeiltasten") % InputSetup.move_keys())]
		Step.CHIP:
			return ["Angreifen", T.t("Stell dich in die Reihe des Gegners und drück %s. Danach lädt die Karte kurz nach.") % k1]
		Step.CHIP2:
			return ["Zweiter Angriff", T.t("Mit %s spielst du die zweite Angriffskarte. Beide ziehen aus demselben Stapel.") % k2]
		Step.DODGE:
			return [T.t("Ausweichen (%d/2)") % dodges, "Rote Felder mit „!“ werden gleich getroffen. Geh rechtzeitig runter!"]
		Step.COUNTER:
			return ["Konter", T.t("Holt der Gegner aus, erscheint ein Fadenkreuz über ihm. Triff ihn genau dann mit %s: Sein Angriff fällt aus!") % k1]
		Step.SHIELD:
			return ["Schützen", T.t("Drück %s: Die Firewall blockt den nächsten Treffer. Danach ruhig stehen bleiben!") % k3]
		Step.ELEMENT:
			return ["Element-Vorteil", T.t("%s ist ein %s-Gegner. Elektro ist dagegen stark: Spiel den Blitzcursor mit %s, er trifft immer.") % [T.t(foe_name), T.t(foe_el), k1]]
		Step.CHAIN:
			return [T.t("Kette (%d/3)") % mini(chain, 3), T.t("Spiel Angriffe desselben Elements hintereinander: Sie werden immer stärker, bis x4! Ein Treffer gegen dich beendet die Kette.")]
		Step.BIG:
			return ["Großangriff", "Goldene Felder: ein Großangriff! Weich allen aus, dann ist der Gegner überlastet. Betäubte Bosse nehmen doppelten Schaden!"]
		Step.STOMP:
			return ["Zertreten", "Eine Bitmilbe! Lauf auf ihr Feld, bevor sie platzt. Zertretene Milben und Sporen laden deine Signatur-Leiste."]
		Step.THORN:
			return ["Dornenranken", "In Dornen tut jeder Schritt hinein weh, Stehenbleiben und Herausgehen nicht. Lauf außen herum zum Ziel!"]
		Step.SPECIAL:
			return ["Signatur-Attacke", T.t("Deine Leiste ist voll! Drück %s für die Signatur-Attacke.") % (InputSetup.btn("Y") if pad else InputSetup.key_text("special", "acc"))]
		Step.FREE:
			return ["Super gemacht!", T.t("Jetzt besiege %s! Im Run warten stärkere Gegner, du schaffst das.") % T.t(foe_name)]
	return []
