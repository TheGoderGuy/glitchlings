class_name Tutorial
extends RefCounted
## Geführter erster Kampf: Bewegen → Chip spielen → Schutz/Hilfe → Ausweichen → Signatur-Attacke → frei kämpfen.
## Steuert nur, wann der Gegner angreifen darf, und prüft die Fortschritte; die Ansicht zeigt die Texte.

enum Step { MOVE, CHIP, SLOTS, DODGE, SPECIAL, FREE, DONE }

var step := Step.MOVE
var moves := 0
var dodges := 0
var last_pos := Vector2i(1, 1)
var last_hits := 0
var last_warns := 0
var hp_at_warn := 0
var done_t := 0.0          # Zeit für die Abschlussmeldung
var just_finished := false


func update(st: BattleState, dt: float) -> void:
	just_finished = false
	var pos := Vector2i(st.p.c, st.p.r)
	# Gegner darf erst beim Ausweichen-Schritt angreifen, stirbt nicht vor dem Ende
	if step in [Step.MOVE, Step.CHIP, Step.SLOTS, Step.SPECIAL]:
		st.e.atk_t = maxf(st.e.atk_t, 1.0)
		st.e.move_t = maxf(st.e.move_t, 1.0)
	# Schutz während der Lernschritte (greift direkt in der Kampflogik)
	st.min_e_hp = roundi(st.e.max * 0.35) if step < Step.FREE else 0
	st.min_p_hp = 20 if step < Step.FREE else 0
	match step:
		Step.MOVE:
			if pos != last_pos:
				moves += 1
			if moves >= 3:
				step = Step.CHIP
				# Gegner in die Reihe des Spielers holen, damit der erste Schuss trifft
				st.e.r = st.p.r
				last_hits = st.e.max - st.e.hp
		Step.CHIP:
			if st.e.max - st.e.hp > last_hits:
				step = Step.SLOTS
				# Schutz- und Hilfe-Slot sofort bereit machen
				st.hand[2].rem = 0.0
		Step.SLOTS:
			if st.last_chip != "" and GameData.role(st.last_chip) > 0:
				step = Step.DODGE
				st.e.atk_t = 0.6
				last_warns = 0
		Step.DODGE:
			# Eine Warnung ist abgelaufen, ohne dass der Spieler getroffen wurde → ausgewichen
			if st.warns.size() > 0 and last_warns == 0:
				hp_at_warn = st.run.hp
			if st.warns.size() == 0 and last_warns > 0:
				if st.run.hp >= hp_at_warn:
					dodges += 1
				hp_at_warn = st.run.hp
			last_warns = st.warns.size()
			if dodges >= 2:
				step = Step.SPECIAL
				st.sp = 100.0
		Step.SPECIAL:
			if st.sp < 100.0:
				step = Step.FREE
				done_t = 3.0
				just_finished = true
		Step.FREE:
			done_t -= dt
			if done_t <= 0:
				step = Step.DONE
	last_pos = pos


func active() -> bool:
	return step != Step.DONE


## Überschrift und Anleitung für den aktuellen Schritt
func texts(pad: bool) -> Array:
	match step:
		Step.MOVE:
			return [T.t("Bewegen (%d/3)") % mini(moves, 3), T.t("Beweg dich mit %s über deine blauen Felder.") % (T.t("dem Steuerkreuz oder dem linken Stick") if pad else T.t("%s oder den Pfeiltasten") % InputSetup.move_keys())]
		Step.CHIP:
			return ["Chip spielen", T.t("Drück %s für deinen Angriffs-Chip. Die meisten treffen deine Reihe: Stell dich in die Reihe des Gegners!") % (InputSetup.btn("X") if pad else InputSetup.key_label("chip_1"))]
		Step.SLOTS:
			return ["Support", T.t("Zwei Angriffs-Slots (%s, %s) und ein Support-Slot (%s) für Schutz und Heilung. Probier jetzt %s!") % [InputSetup.btn("X") if pad else InputSetup.key_label("chip_1"), InputSetup.btn("A") if pad else InputSetup.key_label("chip_2"), InputSetup.btn("B") if pad else InputSetup.key_label("chip_3"), InputSetup.btn("B") if pad else InputSetup.key_label("chip_3")]]
		Step.DODGE:
			return [T.t("Ausweichen (%d/2)") % dodges, "Rote Felder mit „!“ werden gleich getroffen. Geh rechtzeitig runter!"]
		Step.SPECIAL:
			return ["Signatur-Attacke", T.t("Deine Leiste ist voll! Drück %s für die Signatur-Attacke.") % (InputSetup.btn("Y") if pad else InputSetup.key_text("special", "acc"))]
		Step.FREE:
			return ["Super gemacht!", T.t("Chips laden nach dem Einsatz nach. Jetzt besiege den Gegner! Alles Weitere erklärt das Handbuch (Pause oder %s).") % (InputSetup.btn("Back") if pad else InputSetup.key_label("handbook"))]
	return []
