class_name Tutorial
extends RefCounted
## Geführter Trainingskampf (04.10.2026, Tester-Feedback: „Das Handbuch liest keiner, wir wollen in einen Kampf“).
## Läuft direkt nach der Starterwahl und jederzeit über Titel > Training. Neun Lernschritte zum Selbermachen:
## Bewegen > Angriff 1 > Angriff 2 > Ausweichen > Konter (08.10.2026) > Schützen > Element-Vorteil > Großangriff > Signatur > frei kämpfen.
## Steuert nur, wann der Gegner angreifen darf, legt passende Chips auf die Hand und prüft die Fortschritte;
## die Ansicht zeigt die Texte. Der Spieler kann in diesem Kampf nicht verlieren.

enum Step { MOVE, CHIP, CHIP2, DODGE, COUNTER, SHIELD, ELEMENT, BIG, SPECIAL, FREE, DONE }
const LEARN_STEPS := 9     # Fortschrittspunkte (MOVE … SPECIAL)

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
	var hold := step in [Step.MOVE, Step.CHIP, Step.CHIP2, Step.ELEMENT, Step.SPECIAL] or (step == Step.SHIELD and st.shield <= 0) or step == Step.BIG
	if hold:
		st.e.atk_t = maxf(st.e.atk_t, 1.0)
		st.e.move_t = maxf(st.e.move_t, 1.0)
	# Der Gegner hält bis zum freien Kampf durch, verlieren kann man im Training nie
	st.min_e_hp = roundi(st.e.max * 0.35) if step < Step.FREE else 0
	st.min_p_hp = 1
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
				st.e.atk_t = 1.5
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
				_go(Step.BIG)
			elif st.hand[0].chip != "Blitzcursor" and st.hand[0].rem <= 0 and st.last_mult <= 1.0 and step_t > 1.5:
				_give(st, 0, "Blitzcursor")
		Step.BIG:
			if not big_started and step_t > 0.8:
				big_started = true
				st.start_special()
			if st.events.has("overload"):
				_go(Step.SPECIAL)
				st.sp = 100.0
			elif big_started and st.sp_left <= 0 and st.warns.is_empty() and step_t > 1.0:
				# getroffen: gleich noch einmal
				big_started = false
				step_t = 0.0
		Step.SPECIAL:
			if st.sp < 100.0:
				_go(Step.FREE)
				done_t = 3.5
				just_finished = true
		Step.FREE:
			done_t -= dt
			if done_t <= 0:
				_go(Step.DONE)
	last_pos = pos


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
		Step.BIG:
			return ["Großangriff", "Goldene Felder: ein Großangriff! Weich allen aus, dann ist der Gegner kurz überlastet."]
		Step.SPECIAL:
			return ["Signatur-Attacke", T.t("Deine Leiste ist voll! Drück %s für die Signatur-Attacke.") % (InputSetup.btn("Y") if pad else InputSetup.key_text("special", "acc"))]
		Step.FREE:
			return ["Super gemacht!", T.t("Jetzt besiege %s! Im Run warten stärkere Gegner, du schaffst das.") % T.t(foe_name)]
	return []
