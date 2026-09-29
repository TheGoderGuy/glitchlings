extends PixelCanvas
## Run-Ende: Sieg oder Niederlage, was dauerhaft bleibt (Prägung, Evolution, Eier), dann zurück zur Station.

signal to_station

var run: RunState
var won := false
var summary := {}
var t_in := 0.0


func setup(run_state: RunState, run_won: bool, sum: Dictionary) -> void:
	run = run_state
	won = run_won
	summary = sum
	Music.play("title" if run_won else "map")


func _process(delta: float) -> void:
	anim_t += delta
	t_in += delta
	if t_in > 0.6 and (Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("back") or Input.is_action_just_pressed("pause")):
		Sfx.play("confirm")
		set_process(false)
		to_station.emit()
	queue_redraw()


func _draw() -> void:
	_draw_background(not won)
	var r := Rect2(90, 24, 460, 312)
	_box(r, GameData.COL.panel, GameData.COL.sun if won else GameData.COL.coral)
	_text(r.position + Vector2(0, 30), "Zone gesäubert!" if won else "Run beendet", 16, GameData.COL.sun if won else GameData.COL.coral, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	var sub := "%s ist defragmentiert. %s ist wieder sicher." % [GameData.FOES[GameData.ZONES[run.map.zone].boss].name, run.map.zone_name] if won else "%s braucht eine Pause. Alles Gelernte bleibt!" % run.form
	_text(r.position + Vector2(0, 48), sub, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(r.position + Vector2(0, 64), "Etage %d/%d · Kämpfe %d · Chips %d · Fragmente %d" % [maxi(0, run.floor_idx + 1), run.map.floors.size(), run.fights_won, run.chips_used, run.frag], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	# Monster links
	var cx := r.position.x + 84
	draw_rect(Rect2(cx - 40, r.position.y + 176, 80, 5), Color(0.05, 0.02, 0.12, 0.4))
	_draw_sprite(run.form, cx, r.position.y + 178, false, {"scale": 2 if run.stage == 1 else 1, "bob": 1 if won and sin(anim_t * 4.0) > 0 else 0, "blink": fmod(anim_t, 3.0) < 0.13})
	_text(Vector2(r.position.x, r.position.y + 196), run.form, 8, GameData.EL[run.form_el()], HORIZONTAL_ALIGNMENT_CENTER, 168, true, true)
	# Was bleibt
	var x := r.position.x + 180
	var y := r.position.y + 92
	_text(Vector2(x, y), "Was bleibt", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	y += 18
	var lines: Array = []
	lines.append(["+%d Prägung für %s" % [run.chips_used, run.form], GameData.COL.mint])
	if summary.get("evolved", false):
		lines.append(["Entwicklung gespeichert: %s → %s" % [run.start_form, run.form], GameData.EL[run.form_el()]])
	for f in summary.get("new_dex", []):
		lines.append(["Neu im Monsterdex: %s" % f, GameData.COL.sun])
	if summary.get("unlocked", "") != "":
		lines.append(["Neue Zone frei: %s!" % GameData.ZONES[summary.unlocked].name, GameData.COL.coral])
	if int(summary.get("frag_banked", 0)) > 0:
		lines.append(["+%d Fragmente auf die Station gerettet" % int(summary.frag_banked), GameData.COL.sun])
	var egg: Dictionary = summary.get("egg", {})
	if not egg.is_empty():
		lines.append(["Neues Ei: %s (schlüpft nach %d Run%s)" % [egg.rarity, int(egg.runs_left), "" if int(egg.runs_left) == 1 else "s"], GameData.COL.sun])
	elif summary.get("nest_full", false):
		lines.append(["Brutnest voll – kein neues Ei", GameData.COL.muted])
	elif run.fights_won < SaveGame.EGG_MIN_WINS:
		lines.append(["Ab %d gewonnenen Kämpfen gibt es ein Ei" % SaveGame.EGG_MIN_WINS, GameData.COL.muted])
	var ready: int = summary.get("hatch_ready", 0)
	if ready > 0:
		lines.append(["%d Ei%s bereit zum Schlüpfen!" % [ready, "" if ready == 1 else "er"], GameData.COL.coral])
	for ln in lines:
		draw_rect(Rect2(x, y - 6, 4, 4), ln[1])
		_text(Vector2(x + 10, y), ln[0], 8, ln[1])
		y += 16
	# Prägung dieses Runs
	var total := 0
	for k in run.praeg:
		total += run.praeg[k]
	y = maxf(y + 8, r.position.y + 206)
	_text(Vector2(r.position.x + 24, y), "Prägung in diesem Run", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	y += 8
	var col := 0
	for el in GameData.EL:
		var n: int = run.praeg.get(el, 0)
		var bx := r.position.x + 24 + (col % 2) * 214
		var by := y + (col / 2) * 14
		_text(Vector2(bx, by + 8), el, 8, GameData.EL[el])
		_bar(Rect2(bx + 58, by + 1, 120, 7), float(n) / maxi(1, total), GameData.EL[el])
		_text(Vector2(bx, by + 8), str(n), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, 200)
		col += 1
	var pad: bool = InputSetup.pad
	_text(Vector2(r.position.x, r.end.y - 12), "%s Zur Station" % ("A" if pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
