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
var choose_mode := "remove"   # remove | copy
var state_t := 0.0


func setup(run_state: RunState) -> void:
	run = run_state
	Music.play(Music.zone_key("map", run.map.zone))
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
	match run.map.zone:
		"vulkan":
			return "Eine kühle Nische im Vulkangestein. Das Knistern der Glut klingt fast gemütlich."
		"kern":
			return "Eine stille Wartungsnische im Kern. Die Lüfter laufen noch. Ein letztes Durchatmen."
		"sumpf":
			return "Ein trockener Baumstumpf mitten im Moor. Glühwürmchen summen, kein Virus weit und breit."
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
				if choose_mode == "copy":
					run.deck.append(chip)
					_show_message("Kopie erstellt: %s ist jetzt noch einmal in deinem Deck." % chip, true)
				else:
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
	if result == "remove" or result == "copy":
		choose_mode = result
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
	_draw_scene()
	# Monster links
	var bob := 1 if sin(anim_t * 4.0) > 0 else 0
	var blink := fmod(anim_t, 3.4) < 0.13
	draw_rect(Rect2(MON_X - 30, FEET_Y - 2, 60, 4), Color(0.05, 0.02, 0.12, 0.35))
	_draw_sprite(run.form, MON_X, FEET_Y, false, {"bob": bob, "blink": blink})
	_text(Vector2(8, 290), "HP %d/%d" % [run.hp, run.max_hp], 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, 144)
	_text(Vector2(8, 304), "Fragmente %d" % run.frag, 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, 144)
	_text(Vector2(8, 318), "Deck %d Chips" % run.deck.size(), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, 144)
	if not run.modules.is_empty():
		var mw := minf(run.modules.size(), 9) * 15.0
		_draw_module_row(run.modules, 80 - mw / 2.0, 326, 9)

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
			_text(r.position + Vector2(0, 54), "Welchen Chip kopieren?" if choose_mode == "copy" else "Welchen Chip entfernen?", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
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


# ---------- Szene hinter dem Menü ----------

## Zonenlandschaft, Stimmung der Zone und ein kleines Bild zum Ereignis neben dem Monster
func _draw_scene() -> void:
	var zone: String = run.map.zone
	_draw_zone(GameData.ZONES[zone].bg)
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.3))
	match zone:
		"vulkan":
			# aufsteigende Glut
			for i in 16:
				var x := fmod(i * 71.3 + 20.0 + sin(anim_t * 1.3 + i) * 8.0, W)
				var y := H - fmod(anim_t * (18.0 + i % 4 * 6.0) + i * 41.0, H)
				draw_rect(Rect2(roundi(x), roundi(y), 2, 2), Color(Color("#FFD84D") if i % 3 == 0 else Color("#FF8A4C"), 0.7))
		"kern":
			# aufsteigende Datenbits in Cyan/Magenta
			for i in 18:
				var x := fmod(i * 67.3 + 11.0, W)
				var y := H - fmod(anim_t * (22.0 + i % 4 * 7.0) + i * 37.0, H)
				draw_rect(Rect2(roundi(x), roundi(y), 1, 3), Color(Color("#4CC3F0") if i % 3 else Color("#FF5470"), 0.6))
		"sumpf":
			# Glühwürmchen
			for i in 9:
				var x := 20.0 + fmod(i * 67.0, 600.0) + sin(anim_t * 0.9 + i * 1.7) * 14.0
				var y := 150.0 + fmod(i * 37.0, 90.0) + cos(anim_t * 1.1 + i) * 8.0
				draw_rect(Rect2(roundi(x), roundi(y), 2, 2), Color("#D8FF6A", 0.35 + 0.35 * sin(anim_t * 3.0 + i * 2.1)))
	_draw_prop(event_key if type == "event" else type, PROP_X, FEET_Y)


const MON_X := 60.0
const PROP_X := 132.0
const FEET_Y := 264.0


func _draw_prop(kind: String, x: float, g: float) -> void:
	var t := anim_t
	match kind:
		"rest":
			# Lagerfeuer
			draw_rect(Rect2(x - 16, g - 1, 32, 1), Color("#FF8A4C", 0.35 + 0.15 * sin(t * 7.0)))
			draw_rect(Rect2(x - 10, g - 3, 20, 3), Color("#5A3A2A"))
			draw_rect(Rect2(x - 7, g - 5, 14, 2), Color("#7A5038"))
			for i in 5:
				var h := roundf(8.0 + 5.0 * sin(t * 9.0 + i * 1.9) + (3.0 if i == 2 else 0.0))
				draw_rect(Rect2(x - 7 + i * 3, g - 5 - h, 2, h), Color("#FF8A4C"))
				draw_rect(Rect2(x - 7 + i * 3, g - 5 - roundf(h * 0.5), 2, roundf(h * 0.5)), Color("#FFD84D"))
		"schmiede":
			# Amboss mit glühendem Stahl, Funken im Takt der Hammerschläge
			draw_rect(Rect2(x - 12, g - 16, 24, 5), Color("#4A4458"))
			draw_rect(Rect2(x - 17, g - 16, 5, 3), Color("#4A4458"))
			draw_rect(Rect2(x - 12, g - 16, 24, 1), Color("#6A6478"))
			draw_rect(Rect2(x - 5, g - 11, 10, 7), Color("#2E2840"))
			draw_rect(Rect2(x - 10, g - 4, 20, 4), Color("#2E2840"))
			var glow := 0.6 + 0.4 * sin(t * 4.0)
			draw_rect(Rect2(x - 7, g - 18, 13, 2), Color("#FF8A4C").lerp(Color("#FFD84D"), glow))
			var ph := fmod(t, 1.1)
			if ph < 0.45:
				for i in 9:
					var a := 0.35 + i * 0.3
					var d := ph * 55.0
					var sp := Vector2(x, g - 19) + Vector2(cos(a) * d, -sin(a) * d + ph * ph * 90.0)
					draw_rect(Rect2(roundi(sp.x), roundi(sp.y), 1, 1), Color("#FFD84D", 1.0 - ph * 2.0))
		"lavaquelle":
			_pool(x, g, Color("#C8431E"), Color("#FF8A4C"), Color("#FFD84D"), Color(1, 1, 1, 0.22))
		"giftmoor":
			_pool(x, g, Color("#4A2466"), Color("#7A3AA0"), Color("#C77DFF"), Color("#B8FF6A", 0.18))
		"firewallriss":
			# Mauerstück mit glühenden Fugen und einem Riss
			var wx := x - 16
			var wy := g - 46
			draw_rect(Rect2(wx, wy, 32, 46), Color("#3A1A1E"))
			var fuge := Color("#FF8A4C", 0.55 + 0.25 * sin(t * 2.0))
			for row in 6:
				draw_rect(Rect2(wx, wy + row * 8, 32, 1), fuge)
				var off := 0 if row % 2 == 0 else 8
				for cx in range(off, 32, 16):
					draw_rect(Rect2(wx + cx, wy + row * 8, 1, 8), fuge)
			var crack := [Vector2(16, 0), Vector2(13, 9), Vector2(18, 17), Vector2(14, 26), Vector2(19, 35), Vector2(16, 46)]
			for i in crack.size() - 1:
				draw_line(Vector2(wx, wy) + crack[i], Vector2(wx, wy) + crack[i + 1], Color("#120D24"), 3.0)
			draw_rect(Rect2(wx - 1, wy - 2, 34, 2), Color("#FF8A4C"))
		"ascheregen":
			# Asche fällt über den ganzen Bildschirm, unten glitzert etwas
			for i in 40:
				var ax := fmod(i * 53.7 + sin(anim_t * 0.8 + i) * 10.0, W)
				var ay := fmod(anim_t * (12.0 + i % 5 * 4.0) + i * 29.0, H)
				draw_rect(Rect2(roundi(ax), roundi(ay), 2 if i % 4 == 0 else 1, 1), Color("#B8B0C8", 0.55))
			draw_rect(Rect2(x - 12, g - 3, 24, 3), Color("#5A5468"))
			draw_rect(Rect2(x - 7, g - 5, 14, 2), Color("#6A6478"))
			if fmod(t, 1.6) < 0.25:
				draw_rect(Rect2(x + 2, g - 7, 1, 3), Color.WHITE)
				draw_rect(Rect2(x + 1, g - 6, 3, 1), Color.WHITE)
		"irrlicht":
			# Tanzendes Licht mit Halo, knistert elektrisch
			var p := Vector2(x + sin(t * 1.3) * 16.0, g - 44 + sin(t * 2.1) * 8.0)
			draw_circle(p, 13.0, Color("#FFE98A", 0.08))
			draw_circle(p, 8.0, Color("#FFE98A", 0.18))
			draw_circle(p, 4.0, Color("#FFF6C8", 0.8))
			draw_rect(Rect2(roundi(p.x) - 1, roundi(p.y) - 1, 2, 2), Color.WHITE)
			if fmod(t, 0.7) < 0.1:
				draw_line(p + Vector2(3, -2), p + Vector2(9, -7), Color("#FFE98A"), 1.0)
				draw_line(p + Vector2(-3, 2), p + Vector2(-8, 6), Color("#FFE98A"), 1.0)
		"modulkapsel":
			# halb vergrabene Kapsel, die im Takt leuchtet
			draw_rect(Rect2(x - 12, g - 16, 24, 14), Color("#1E1428"))
			draw_rect(Rect2(x - 11, g - 15, 22, 12), Color("#6A6478"))
			draw_rect(Rect2(x - 11, g - 15, 22, 3), Color("#8A84A0"))
			draw_rect(Rect2(x - 3, g - 12, 6, 6), Color("#FFC83D", 0.5 + 0.5 * sin(t * 4.0)))
			draw_rect(Rect2(x - 16, g - 3, 32, 3), Color("#2E2840"))
			if fmod(t, 1.5) < 0.2:
				draw_rect(Rect2(x + 8, g - 22, 1, 3), Color.WHITE)
				draw_rect(Rect2(x + 7, g - 21, 3, 1), Color.WHITE)
		"datenleitung":
			# Rohr aus dem Moor, verstopft mit glühendem Datenschlamm, knistert
			draw_rect(Rect2(x - 5, g - 34, 10, 34), Color("#1E1428"))
			draw_rect(Rect2(x - 4, g - 34, 8, 34), Color("#4A4458"))
			draw_rect(Rect2(x - 4, g - 34, 2, 34), Color("#6A6478"))
			draw_rect(Rect2(x - 7, g - 38, 14, 5), Color("#1E1428"))
			draw_rect(Rect2(x - 6, g - 37, 12, 3), Color("#6A6478"))
			draw_rect(Rect2(x - 4, g - 36, 8, 2), Color("#7BD35A", 0.6 + 0.3 * sin(t * 3.0)))
			for i in 3:
				var ph := fmod(t * 0.8 + i * 0.33, 1.0)
				draw_rect(Rect2(x - 3 + i * 3, roundi(g - 38 - ph * 10.0), 2, 2), Color("#7BD35A", 1.0 - ph))
			for i in 2:
				draw_rect(Rect2(x - 5, g - 26 + i * 12, 10, 2), Color("#2E2840"))
			if fmod(t, 1.3) < 0.1:
				draw_line(Vector2(x + 5, g - 20), Vector2(x + 11, g - 25), Color("#FFE98A"), 1.0)
				draw_line(Vector2(x + 11, g - 25), Vector2(x + 9, g - 29), Color("#FFE98A"), 1.0)
		"orakel":
			# Uralte Kröte auf einem Seerosenblatt, Wellenringe
			# Wasser mit Wellen, die nach außen laufen
			for dy in range(-2, 1):
				var ww := roundf(26.0 * sqrt(1.0 - pow(dy / 3.0, 2.0)))
				draw_rect(Rect2(x - ww, g - 1 + dy, ww * 2, 1), Color("#1E3A5A"))
			for k in 2:
				var rr := fmod(t * 6.0 + k * 7.0, 14.0)
				var wc := Color("#8FD8FF", 0.6 * (1.0 - rr / 14.0))
				draw_rect(Rect2(roundi(x - 17 - rr), g - 2, 4, 1), wc)
				draw_rect(Rect2(roundi(x + 13 + rr), g - 2, 4, 1), wc)
			draw_rect(Rect2(x - 15, g - 3, 30, 3), Color("#2E7A3A"))
			draw_rect(Rect2(x - 12, g - 4, 24, 1), Color("#4FA85A"))
			draw_rect(Rect2(x - 1, g - 3, 2, 3), Color("#1E4A26"))
			# Kröte
			draw_rect(Rect2(x - 9, g - 11, 18, 7), Color("#5A6A3A"))
			draw_rect(Rect2(x - 10, g - 8, 20, 4), Color("#4A5A2E"))
			draw_rect(Rect2(x - 8, g - 14, 5, 4), Color("#5A6A3A"))
			draw_rect(Rect2(x + 3, g - 14, 5, 4), Color("#5A6A3A"))
			var shut := fmod(t, 4.0) < 0.15
			draw_rect(Rect2(x - 7, g - 13, 3, 2 if not shut else 1), Color("#FFD84D") if not shut else Color("#2E3A1E"))
			draw_rect(Rect2(x + 4, g - 13, 3, 2 if not shut else 1), Color("#FFD84D") if not shut else Color("#2E3A1E"))
			draw_rect(Rect2(x - 6, g - 7, 12, 1), Color("#2E3A1E"))
			draw_rect(Rect2(x - 11, g - 12, 1, 1), Color("#C8D8A0"))  # Barthaar


## Blubbernde Quelle/Moorloch: flache Ellipse, Blasen, Dampfschwaden
func _pool(x: float, g: float, deep: Color, mid: Color, hi: Color, steam: Color) -> void:
	for dy in range(-4, 1):
		var w := roundf(22.0 * sqrt(1.0 - pow(dy / 5.0, 2.0)))
		draw_rect(Rect2(x - w, g - 1 + dy, w * 2, 1), deep if dy < -1 else mid)
	draw_rect(Rect2(x - 14, g - 4, 10, 1), hi)
	for i in 3:
		var ph := fmod(anim_t * 0.9 + i * 0.37, 1.0)
		var bx := x - 10 + i * 9
		var bs := 1 if ph < 0.8 else 2
		draw_rect(Rect2(bx, roundi(g - 5 - ph * 6.0), bs, bs), Color(hi, 1.0 - ph))
	for i in 3:
		var ph := fmod(anim_t * 0.35 + i * 0.33, 1.0)
		var sx := x - 12 + i * 12 + sin(anim_t + i) * 4.0
		var sz := 2 if ph < 0.5 else 3
		draw_rect(Rect2(roundi(sx), roundi(g - 8 - ph * 40.0), sz, sz), Color(steam, minf(1.0, steam.a * 2.5) * (1.0 - ph)))
