extends PixelCanvas
## Nicht-Kampf-Knoten: Rastplatz, Ereignis, Datenhändler. Logik steckt in Rooms.

signal finished

enum State { MENU, REMOVE, MESSAGE }

var run: RunState
var node: Dictionary
var type := "rest"
var event_key := ""
var state := State.MENU
var sel := 0
var message := ""
var done_after_message := false
var remove_list: Array = []
var state_t := 0.0


func setup(run_state: RunState) -> void:
	run = run_state
	node = run.current_node()
	type = node.type
	if type == "event":
		if not node.has("event"):
			node.event = Rooms.pick_event(run)
		event_key = node.event
	elif type == "shop":
		Rooms.shop_init(run, node)
	sel = _first_enabled()


func _type_col() -> Color:
	return {"event": Color("#C77DFF"), "shop": Color("#58D68D")}.get(type, Color("#6EE7C5"))


func _title() -> String:
	match type:
		"event":
			return Rooms.EVENTS[event_key].title
		"shop":
			return "Datenhändler"
	return "Rastplatz"


func _intro() -> String:
	match type:
		"event":
			return Rooms.EVENTS[event_key].text
		"shop":
			return "Ein freundlicher Händler-Bot piept: Frische Chips, fast ohne Bugs!"
	return "Ein ruhiger Cache-Winkel. Die Lüfter summen leise. Zeit zum Durchatmen."


## Optionen inkl. „Weitergehen“ für Rastplatz und Händler.
func _options() -> Array:
	var out: Array = []
	match type:
		"event":
			out = Rooms.event_options(run, event_key)
		"shop":
			out = Rooms.shop_options(run, node)
			out.append({"id": "leave", "label": "Weitergehen", "desc": "Zurück zur Karte.", "enabled": true})
		_:
			out = Rooms.rest_options(run)
			out.append({"id": "leave", "label": "Weitergehen", "desc": "Zurück zur Karte.", "enabled": true})
	return out


func _first_enabled() -> int:
	var o := _options()
	for i in o.size():
		if o[i].enabled:
			return i
	return 0


func _process(delta: float) -> void:
	anim_t += delta
	state_t += delta
	if state_t < 0.25:
		queue_redraw()
		return
	match state:
		State.MENU:
			var o := _options()
			_nav(o.size())
			if Input.is_action_just_pressed("confirm"):
				var opt: Dictionary = o[sel]
				if not opt.enabled:
					Sfx.play("back")
				else:
					Sfx.play("confirm")
					_choose(opt.id)
		State.REMOVE:
			_nav(remove_list.size())
			if Input.is_action_just_pressed("confirm"):
				Sfx.play("confirm")
				var chip: String = remove_list[sel]
				run.remove_chip(chip)
				_show_message("%s wurde aus deinem Deck entfernt." % chip, type != "shop")
		State.MESSAGE:
			if Input.is_action_just_pressed("confirm"):
				Sfx.play("confirm")
				if done_after_message:
					set_process(false)
					finished.emit()
				else:
					_set_state(State.MENU)
					sel = _first_enabled()
	queue_redraw()


func _nav(n: int) -> void:
	if n == 0:
		return
	if Input.is_action_just_pressed("move_up"):
		sel = (sel + n - 1) % n
		Sfx.play("select")
	if Input.is_action_just_pressed("move_down"):
		sel = (sel + 1) % n
		Sfx.play("select")


func _set_state(s: State) -> void:
	state = s
	state_t = 0.0


func _choose(id: String) -> void:
	if id == "leave":
		set_process(false)
		finished.emit()
		return
	var result := ""
	match type:
		"event":
			result = Rooms.event_apply(run, event_key, id)
		"shop":
			result = Rooms.shop_apply(run, node, id)
		_:
			result = Rooms.rest_apply(run, id)
	if result == "remove":
		var seen := {}
		remove_list = []
		for c in run.deck:
			if not seen.has(c):
				seen[c] = true
				remove_list.append(c)
		sel = 0
		_set_state(State.REMOVE)
		return
	if id in ["heal", "repair", "drink", "feed"]:
		Sfx.play("heal")
	_show_message(result, type != "shop")


func _show_message(text: String, done: bool) -> void:
	message = text
	done_after_message = done
	_set_state(State.MESSAGE)


func _draw() -> void:
	_draw_background()
	# Monster links
	var bob := 1 if sin(anim_t * 4.0) > 0 else 0
	var blink := fmod(anim_t, 3.4) < 0.13
	draw_rect(Rect2(40, 262, 80, 4), Color(0.05, 0.02, 0.12, 0.35))
	_draw_sprite("pixi", 80, 264, false, {"bob": bob, "blink": blink})
	_text(Vector2(8, 290), "HP %d/%d" % [run.hp, run.max_hp], 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, 144)
	_text(Vector2(8, 304), "Fragmente %d" % run.frag, 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, 144)
	_text(Vector2(8, 318), "Deck %d Chips" % run.deck.size(), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, 144)

	var r := Rect2(160, 24, 460, 312)
	_box(r, Color(GameData.COL.panel, 0.95), _type_col())
	_text(r.position + Vector2(0, 28), _title().to_upper(), 16, _type_col(), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	match state:
		State.MENU:
			draw_multiline_string(font(), r.position + Vector2(24, 54), _intro(), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 48, 8, 4, GameData.COL.ink, wrap)
			var o := _options()
			var y := r.position.y + 96
			for i in o.size():
				_option_row(Rect2(r.position.x + 60, y + i * 24, r.size.x - 120, 18), o[i].label, i == sel, o[i].enabled)
			if sel < o.size():
				draw_multiline_string(font(), Vector2(r.position.x + 24, r.end.y - 40), o[sel].desc, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 48, 8, 3, GameData.COL.muted, wrap)
		State.REMOVE:
			_text(r.position + Vector2(0, 54), "Welchen Chip entfernen?", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
			# bis 10 Einträge einspaltig, sonst zweispaltig
			var cols := 1 if remove_list.size() <= 10 else 2
			var cw := 280.0 if cols == 1 else 200.0
			var x0 := r.get_center().x - (cw * cols + 10 * (cols - 1)) / 2.0
			var per_col := ceili(remove_list.size() / float(cols))
			for i in remove_list.size():
				var c: String = remove_list[i]
				var cx := x0 + (i / per_col) * (cw + 10)
				var cy := r.position.y + 68 + (i % per_col) * 20
				_option_row(Rect2(cx, cy, cw, 16), "%d× %s" % [run.deck.count(c), c], i == sel, true, GameData.EL[GameData.CHIPS[c].el])
		State.MESSAGE:
			draw_multiline_string(font(), r.position + Vector2(24, 120), message, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 48, 8, 5, GameData.COL.ink, wrap)
			_text(Vector2(r.position.x, r.end.y - 20), "%s weiter" % ("A" if InputSetup.pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)


func _option_row(r: Rect2, label: String, active: bool, enabled: bool, mark := Color.TRANSPARENT) -> void:
	_box(r, GameData.COL.bg2 if not active else GameData.COL.panel.lightened(0.08), GameData.COL.sun if active else GameData.COL.line)
	if mark.a > 0:
		draw_rect(Rect2(r.position + Vector2(6, r.size.y / 2 - 3), Vector2(6, 6)), mark)
	if active:
		_text(Vector2(r.position.x + 6 + (1 if sin(anim_t * 10.0) > 0 else 0), r.position.y + r.size.y - 5), ">", 8, GameData.COL.sun)
	var col: Color = GameData.COL.ink if (active and enabled) else (GameData.COL.muted if enabled else Color(GameData.COL.muted, 0.4))
	_text(Vector2(r.position.x, r.position.y + r.size.y - 5), label, 8, col, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
