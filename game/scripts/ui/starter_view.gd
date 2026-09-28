extends PixelCanvas
## Starter-Wahl vor dem Run: welches Baby-Monster geht mit?

signal chosen(species: String)
signal back

const STARTERS := ["Pixmiez", "Funkling", "Tröpfel"]

var sel := 0
var t_in := 0.0


func _process(delta: float) -> void:
	anim_t += delta
	t_in += delta
	if t_in > 0.25:
		if Input.is_action_just_pressed("move_left"):
			sel = (sel + STARTERS.size() - 1) % STARTERS.size()
			Sfx.play("select")
		elif Input.is_action_just_pressed("move_right"):
			sel = (sel + 1) % STARTERS.size()
			Sfx.play("select")
		elif Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			set_process(false)
			chosen.emit(STARTERS[sel])
		elif Input.is_action_just_pressed("back"):
			Sfx.play("back")
			set_process(false)
			back.emit()
	queue_redraw()


func _draw() -> void:
	_draw_background()
	_text(Vector2(0, 30), "Wer begleitet dich?", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	_text(Vector2(0, 46), "Die Chips, die du spielst, bestimmen, wozu es sich entwickelt.", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	for i in STARTERS.size():
		var sp: String = STARTERS[i]
		var m: Dictionary = GameData.MONS[sp]
		var active := i == sel
		var el: Color = GameData.EL[m.el]
		var r := Rect2(24 + i * 202, 62 - (4 if active else 0), 188, 262)
		_box(r, GameData.COL.panel.lightened(0.06) if active else GameData.COL.bg2, GameData.COL.sun if active else el.darkened(0.35))
		draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(r.size.x - 2, 4)), el)
		# Monster (Baby doppelt groß) auf kleiner Plattform
		var bob := 1 if active and sin(anim_t * 4.0) > 0 else 0
		draw_rect(Rect2(r.get_center().x - 30, r.position.y + 86, 60, 4), Color(0.05, 0.02, 0.12, 0.35))
		_draw_sprite(sp, r.get_center().x, r.position.y + 88, false, {"bob": bob, "blink": fmod(anim_t + i, 3.1) < 0.13})
		_text(Vector2(r.position.x, r.position.y + 108), sp, 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
		_text(Vector2(r.position.x, r.position.y + 122), "%s · %s · %d HP" % [m.animal, m.el, m.hp], 8, el, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
		draw_multiline_string(font(), Vector2(r.position.x + 10, r.position.y + 140), m.trait, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 20, 8, 2, GameData.COL.muted, wrap)
		_text(Vector2(r.position.x + 10, r.position.y + 172), "Passiv: " + m.passive, 8, GameData.COL.mint)
		draw_multiline_string(font(), Vector2(r.position.x + 10, r.position.y + 186), m.passive_desc, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 20, 8, 3, GameData.COL.ink, wrap)
		var S: Dictionary = GameData.SPECIALS[sp]
		_text(Vector2(r.position.x + 10, r.position.y + 228), "Signatur: " + S.name, 8, GameData.COL.sun)
		var dirs: Array = m.evo.keys()
		_text(Vector2(r.position.x + 10, r.position.y + 248), "Wird: " + " / ".join(dirs), 8, GameData.COL.muted)
	var pad: bool = InputSetup.pad
	_text(Vector2(0, H - 12), "< > wählen    %s los geht's    %s zurück" % ["A" if pad else "Enter", "B" if pad else "Esc"], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
