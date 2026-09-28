extends PixelCanvas
## Titelbildschirm mit Hauptmenü und Optionen.

signal start_run

enum Page { MAIN, OPTIONS }

var page := Page.MAIN
var sel := 0
var glitch_t := 0.0
var glitch_off := Vector2i.ZERO


func _main_items() -> Array:
	return ["Run starten", "Optionen", "Beenden"]


func _option_items() -> Array:
	var vol := ""
	for i in 10:
		vol += "|" if i < Settings.volume else "."
	return [
		"Vollbild: " + ("An" if Settings.fullscreen else "Aus"),
		"Lautstärke: " + vol,
		"Bildschirmwackeln: " + ("An" if Settings.screen_shake else "Aus"),
		"Zurück",
	]


func _process(delta: float) -> void:
	anim_t += delta
	# gelegentliches Glitch-Zucken im Logo
	glitch_t -= delta
	if glitch_t <= 0:
		glitch_t = randf_range(1.2, 3.0)
		glitch_off = Vector2i(randi_range(-2, 2), 0)
	var items := _main_items() if page == Page.MAIN else _option_items()
	if Input.is_action_just_pressed("move_up"):
		sel = (sel + items.size() - 1) % items.size()
		Sfx.play("select")
	if Input.is_action_just_pressed("move_down"):
		sel = (sel + 1) % items.size()
		Sfx.play("select")
	if page == Page.MAIN:
		if Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			match sel:
				0:
					start_run.emit()
				1:
					page = Page.OPTIONS
					sel = 0
				2:
					get_tree().quit()
	else:
		var dir := 0
		if Input.is_action_just_pressed("move_left"):
			dir = -1
		elif Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("confirm"):
			dir = 1
		if Input.is_action_just_pressed("back") or (sel == 3 and Input.is_action_just_pressed("confirm")):
			Sfx.play("back")
			page = Page.MAIN
			sel = 1
			Settings.save_settings()
		elif dir != 0 and sel < 3:
			match sel:
				0:
					Settings.fullscreen = not Settings.fullscreen
				1:
					Settings.volume = clampi(Settings.volume + dir, 0, 10)
				2:
					Settings.screen_shake = not Settings.screen_shake
			Settings.apply()
			Sfx.play("select")
	queue_redraw()


func _draw() -> void:
	_draw_background()
	# Logo: Glitch-Versatz in Cyan/Magenta, darüber die Schrift
	var logo := "GLITCHLINGS"
	var y := 92.0
	var jitter := Vector2(glitch_off) if glitch_t < 0.15 else Vector2.ZERO
	draw_set_transform(Vector2(0, 0), 0, Vector2(2, 2))
	var f := font(true)
	var lp := Vector2(0, y / 2)
	draw_string(f, lp + Vector2(-1, 0) + jitter, logo, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, Color("#4CC3F0", 0.8))
	draw_string(f, lp + Vector2(1, 0) - jitter, logo, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, Color("#FF5470", 0.8))
	draw_string_outline(f, lp, logo, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, 4, GameData.COL.dark)
	draw_string(f, lp, logo, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, GameData.COL.ink)
	draw_set_transform(Vector2.ZERO)
	_text(Vector2(0, 114), "Brüten. Fusionieren. Prägen.", 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W)

	# Monster-Bühne
	var bob := 1 if sin(anim_t * 4.0) > 0 else 0
	var blink := fmod(anim_t, 3.4) < 0.13
	_shadow(W / 2.0, 238, 40)
	_draw_sprite("pixi", W / 2.0, 238, false, {"scale": 3, "bob": bob, "blink": blink})
	_draw_sprite("bug", 110, 250, true, {"bob": 1 - bob, "mod": Color(1, 1, 1, 0.55)})
	_draw_sprite("moth", 530, 250, true, {"bob": bob, "mod": Color(1, 1, 1, 0.55)})

	if page == Page.MAIN:
		_menu(_main_items(), sel, W / 2.0, 258, 180)
	else:
		_dim()
		var r := Rect2(170, 110, 300, 150)
		_box(r, GameData.COL.panel, GameData.COL.line)
		_text(r.position + Vector2(0, 26), "Optionen", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
		_menu(_option_items(), sel, r.get_center().x, r.position.y + 40, 250)
	var pad: bool = InputSetup.pad
	var hint := ("Steuerkreuz wählen · A bestätigen · B zurück" if pad else "Pfeile wählen · Enter bestätigen · Esc zurück")
	_text(Vector2(0, H - 10), hint, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	_text(Vector2(0, H - 10), "v0.1 ", 8, Color(GameData.COL.muted, 0.6), HORIZONTAL_ALIGNMENT_RIGHT, W)


func _shadow(cx: float, y: float, w: int) -> void:
	var c := Color(0.05, 0.02, 0.12, 0.35)
	draw_rect(Rect2(roundi(cx - w / 2.0), roundi(y - 2), w, 4), c)
	draw_rect(Rect2(roundi(cx - w / 2.0 + 3), roundi(y - 3), w - 6, 6), c)
