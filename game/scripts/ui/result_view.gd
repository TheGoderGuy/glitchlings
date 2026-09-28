extends PixelCanvas
## Run-Ende: Sieg oder Niederlage, Statistik und Prägung.

signal new_run
signal to_title

var run: RunState
var won := false
var t_in := 0.0


func setup(run_state: RunState, run_won: bool) -> void:
	run = run_state
	won = run_won


func _process(delta: float) -> void:
	anim_t += delta
	t_in += delta
	if t_in > 0.6:
		if Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			set_process(false)
			new_run.emit()
		elif Input.is_action_just_pressed("back") or Input.is_action_just_pressed("pause"):
			Sfx.play("back")
			set_process(false)
			to_title.emit()
	queue_redraw()


func _draw() -> void:
	_draw_background(not won)
	var r := Rect2(120, 30, 400, 300)
	_box(r, GameData.COL.panel, GameData.COL.sun if won else GameData.COL.coral)
	_text(r.position + Vector2(0, 32), "Zone gesäubert!" if won else "Run verloren", 16, GameData.COL.sun if won else GameData.COL.coral, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	var sub := "Der Pop-Up-Tyrann ist defragmentiert. Die %s atmen auf." % run.map.zone_name if won else "%s braucht eine Pause. Beim nächsten Mal klappt es!" % run.species
	_text(r.position + Vector2(0, 50), sub, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(r.position + Vector2(0, 68), "Etage %d/%d · Kämpfe %d · Chips %d · Fragmente %d" % [maxi(0, run.floor_idx + 1), run.map.floors.size(), run.fights_won, run.chips_used, run.frag], 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	_text(r.position + Vector2(24, 96), "Prägung in diesem Run", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	var total := 0
	for k in run.praeg:
		total += run.praeg[k]
	var y := r.position.y + 110
	for el in GameData.EL:
		var n: int = run.praeg.get(el, 0)
		_text(Vector2(r.position.x + 24, y + 8), el, 8, GameData.EL[el])
		_bar(Rect2(r.position.x + 96, y, 236, 9), float(n) / maxi(1, total), GameData.EL[el])
		_text(Vector2(r.position.x + 340, y + 8), str(n), 8)
		y += 16
	var bob := 1 if sin(anim_t * 4.0) > 0 else 0
	_draw_sprite("pixi", r.get_center().x, r.end.y - 44, false, {"bob": bob if won else 0, "blink": fmod(anim_t, 3.0) < 0.13})
	var pad: bool = InputSetup.pad
	_text(Vector2(r.position.x, r.end.y - 22), "%s Neuer Run    %s Titel" % ["A" if pad else "Enter", "B" if pad else "Esc"], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
