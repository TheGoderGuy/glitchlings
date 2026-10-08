extends PixelCanvas
## Titelbildschirm mit Hauptmenü und Optionen.

signal start_run
signal show_intro
signal training

enum Page { MAIN, OPTIONS, KEYS }

var page := Page.MAIN
var sel := 0
var glitch_t := 0.0
var glitch_off := Vector2i.ZERO
var reset_armed := false
var key_wait := ""      # Aktion, die gerade eine neue Taste bekommt (Tastenbelegung)
var key_msg := ""       # Rückmeldung auf der Tastenbelegungs-Seite
var key_block := 0.0    # kurz keine Menü-Eingaben nach dem Belegen (die Taste selbst soll nichts auslösen)
var title_msg := ""     # kurze Meldung im Hauptmenü (z. B. nach dem Zurücksetzen)
var title_msg_t := 0.0
## Bildmarke „Digi-Ei“ (03.10.2026), links neben dem Schriftzug
const LOGO_EGG := preload("res://assets/logo/digiei_64.png")


## Hauptmenü als Kennungen: Training nur mit Spielstand, Beenden nicht im Browser (Tab schließen)
func _main_ids() -> Array:
	var ids := ["play"]
	if SaveGame.has_save():
		ids.append("training")
	ids.append_array(["handbook", "options"])
	if not OS.has_feature("web"):
		ids.append("quit")
	return ids


func _main_items() -> Array:
	var play := "Neues Spiel"
	if SaveGame.has_run():
		play = "Run fortsetzen"
	elif SaveGame.has_save():
		play = "Spielen"
	var names := {"play": play, "training": "Training", "handbook": "Kampf-Handbuch", "options": "Optionen", "quit": "Beenden"}
	return _main_ids().map(func(id): return names[id])


## Optionen als Kennungen (Reihenfolge = Anzeige); Sprache steht oben und ist zweisprachig beschriftet
const OPTIONS := ["lang", "fullscreen", "vsync", "volume", "music", "difficulty", "shake", "keys", "reset", "zones", "dex", "intro", "log", "back"]


func _option_label(id: String) -> String:
	var on := T.t("An")
	var off_ := T.t("Aus")
	match id:
		"lang":
			return ("Language (Sprache): " if T.en() else "Sprache (Language): ") + T.LANGS[Settings.lang]
		"fullscreen":
			return T.t("Vollbild:") + " " + (on if Settings.fullscreen else off_)
		"vsync":
			return "VSync: " + (on if Settings.vsync else off_)
		"volume":
			return T.t("Lautstärke:") + " " + _bar_text(Settings.volume)
		"music":
			return T.t("Musik:") + " " + _bar_text(Settings.music)
		"difficulty":
			return T.t("Schwierigkeit:") + " " + T.t(["Entspannt", "Normal", "Knackig", "Korrumpiert"][Settings.difficulty])
		"shake":
			return T.t("Bildschirmwackeln:") + " " + (on if Settings.screen_shake else off_)
		"keys":
			return "Tastenbelegung"
		"reset":
			return "Wirklich alles zurücksetzen? Nochmal drücken" if reset_armed else "Spiel zurücksetzen"
		"zones":
			return ("Test: Alle Zonen-Bosse besiegt (erledigt)" if SaveGame.data.get("cleared", []).size() == GameData.ZONE_ORDER.size() else "Test: Alle Zonen-Bosse als besiegt markieren") if SaveGame.has_save() else "Test: erst Spiel starten"
		"dex":
			return ("Test: Monsterdex komplett (erledigt)" if SaveGame.dex_count() >= GameData.FORMS.size() else "Test: Monsterdex komplett") if SaveGame.has_save() else "Test: erst Spiel starten"
		"intro":
			return "Intro ansehen"
		"log":
			return "Spieltest-Log herunterladen" if OS.has_feature("web") else "Spieltest-Log öffnen"
	return "Zurück"


func _option_items() -> Array:
	return OPTIONS.map(_option_label)


## Zeilen der Tastenbelegung: je frei belegbare Aktion eine, dazu „Standard“ und „Zurück“
func _key_count() -> int:
	return InputSetup.REBIND.size() + 2


func _bar_text(v: int) -> String:
	var s := ""
	for i in 10:
		s += "|" if i < v else "."
	return s


func _ready() -> void:
	Music.play("title")


## Neue Taste abfangen, solange eine Aktion auf ihre Taste wartet (nur Tastatur)
func _input(event: InputEvent) -> void:
	if page != Page.KEYS or key_wait == "":
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	get_viewport().set_input_as_handled()
	var k: int = event.physical_keycode
	key_block = 0.2
	if k == KEY_ESCAPE:
		key_wait = ""
		key_msg = ""
		Sfx.play("back")
		return
	var res := InputSetup.rebind(key_wait, k)
	if res == "fest":
		key_msg = T.t("Diese Taste ist fest belegt.")
		Sfx.play("back")
		return
	key_msg = (T.t("Getauscht mit %s.") % T.t(_rebind_name(res))) if res != "" else ""
	key_wait = ""
	Settings.save_settings()
	Sfx.play("confirm")


func _rebind_name(action: String) -> String:
	for e in InputSetup.REBIND:
		if e[0] == action:
			return e[1]
	return action


func _process(delta: float) -> void:
	anim_t += delta
	if handbook != null:
		queue_redraw()
		return
	if title_msg_t > 0:
		title_msg_t -= delta
	# gelegentliches Glitch-Zucken im Logo
	glitch_t -= delta
	if glitch_t <= 0:
		glitch_t = randf_range(1.2, 3.0)
		glitch_off = Vector2i(randi_range(-2, 2), 0)
	# Nach dem Belegen kurz nichts auswerten, und während auf eine Taste gewartet wird gar nichts
	if key_block > 0:
		key_block -= delta
		queue_redraw()
		return
	if page == Page.KEYS and key_wait != "":
		queue_redraw()
		return
	var n_items: int = _main_items().size() if page == Page.MAIN else (_key_count() if page == Page.KEYS else OPTIONS.size())
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
		reset_armed = false
	if Input.is_action_just_pressed("move_up"):
		sel = (sel + n_items - 1) % n_items
		Sfx.play("select")
	if Input.is_action_just_pressed("move_down"):
		sel = (sel + 1) % n_items
		Sfx.play("select")
	if page == Page.MAIN:
		if Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			match _main_ids()[sel]:
				"play":
					start_run.emit()
				"training":
					training.emit()
				"handbook":
					open_handbook()
				"options":
					page = Page.OPTIONS
					sel = 0
				"quit":
					get_tree().quit()
	elif page == Page.KEYS:
		_process_keys()
	else:
		_process_options()
	queue_redraw()


func _process_options() -> void:
	var id: String = OPTIONS[sel]
	var ok := Input.is_action_just_pressed("confirm")
	var dir := 0
	if Input.is_action_just_pressed("move_left"):
		dir = -1
	elif Input.is_action_just_pressed("move_right") or ok:
		dir = 1
	if Input.is_action_just_pressed("back") or (id == "back" and ok):
		Sfx.play("back")
		page = Page.MAIN
		sel = _main_ids().find("options")
		Settings.save_settings()
		reset_armed = false
		return
	match id:
		"keys":
			if ok:
				Sfx.play("confirm")
				page = Page.KEYS
				sel = 0
				key_msg = ""
		"intro":
			if ok:
				Sfx.play("confirm")
				Settings.save_settings()
				show_intro.emit()
		"dex":
			# Testfunktion für den Produzenten: alle Glitchlinge im Dex mit Namen
			if ok:
				if SaveGame.has_save():
					SaveGame.unlock_full_dex()
					Sfx.play("confirm")
				else:
					Sfx.play("back")
		"log":
			# Ordner mit spieltest_log.csv öffnen (für Tester), im Browser als Datei herunterladen
			if ok:
				if OS.has_feature("web"):
					SaveGame.download_log()
				else:
					OS.shell_open(SaveGame.log_folder())
				Sfx.play("confirm")
		"zones":
			# Testfunktion für den Produzenten: alle Zonen sofort spielbar
			if ok:
				if SaveGame.has_save():
					SaveGame.unlock_all_zones()
					Sfx.play("confirm")
				else:
					Sfx.play("back")
		"reset":
			# zweimal bestätigen, damit nichts aus Versehen verloren geht
			if ok:
				if reset_armed:
					reset_game()
				else:
					reset_armed = true
					Sfx.play("warn")
		_:
			if dir == 0:
				return
			match id:
				"lang":
					var langs: Array = T.LANGS.keys()
					Settings.lang = langs[(langs.find(Settings.lang) + dir + langs.size()) % langs.size()]
				"fullscreen":
					Settings.fullscreen = not Settings.fullscreen
				"vsync":
					Settings.vsync = not Settings.vsync
				"volume":
					Settings.volume = clampi(Settings.volume + dir, 0, 10)
				"music":
					Settings.music = clampi(Settings.music + dir, 0, 10)
				"difficulty":
					var nd := 4 if SaveGame.game_cleared() else 3   # „Korrumpiert“ erst nach dem Ende
					Settings.difficulty = (Settings.difficulty + dir + nd) % nd
				"shake":
					Settings.screen_shake = not Settings.screen_shake
			Settings.apply()
			Sfx.play("select")


## Spiel zurücksetzen (04.10.2026): Spielstand mit laufendem Run, Einstellungen und Tastenbelegung wie bei einer
## Neuinstallation. Das Spieltest-Log bleibt (Testerdaten). Danach Hauptmenü, „Neues Spiel“ startet mit dem Intro.
func reset_game() -> void:
	SaveGame.reset()
	Settings.reset_defaults()
	reset_armed = false
	page = Page.MAIN
	sel = 0
	title_msg = "Spiel zurückgesetzt. Mit „Neues Spiel“ geht es ganz von vorn los."
	title_msg_t = 4.0
	Sfx.play("back")


func _process_keys() -> void:
	var n := InputSetup.REBIND.size()
	var ok := Input.is_action_just_pressed("confirm")
	if Input.is_action_just_pressed("back") or (sel == n + 1 and ok):
		Sfx.play("back")
		page = Page.OPTIONS
		sel = OPTIONS.find("keys")
		key_msg = ""
	elif ok and sel == n:
		InputSetup.reset_keys()
		Settings.save_settings()
		key_msg = T.t("Standard wiederhergestellt.")
		Sfx.play("confirm")
	elif ok:
		key_wait = InputSetup.REBIND[sel][0]
		key_msg = ""
		Sfx.play("confirm")


func _draw() -> void:
	_draw_background()
	# Logo: Glitch-Versatz in Cyan/Magenta, darüber die Schrift
	var logo := "GLITCHLINGS"
	var y := 92.0
	var jitter := Vector2(glitch_off) if glitch_t < 0.15 else Vector2.ZERO
	var f := font(true, 24)
	# Ei + Schriftzug zusammen mittig: Ei 64 px, 4 px Abstand, Schrift doppelt groß
	var tw := roundi(f.get_string_size(logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x) * 2
	var lx := roundi((W - 64 - 4 - tw) / 2.0)
	draw_texture(LOGO_EGG, Vector2(lx, y - 52))
	draw_set_transform(Vector2(lx + 68, 0), 0, Vector2(2, 2))
	var lp := Vector2(0, y / 2)
	draw_string(f, lp + Vector2(-1, 0) + jitter, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#4CC3F0", 0.8))
	draw_string(f, lp + Vector2(1, 0) - jitter, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#FF5470", 0.8))
	draw_string_outline(f, lp, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 4, GameData.COL.dark)
	draw_string(f, lp, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, GameData.COL.ink)
	draw_set_transform(Vector2.ZERO)
	_text(Vector2(0, 114), "Brüten. Fusionieren. Prägen.", 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W)
	if SaveGame.game_cleared():
		_text(Vector2(0, 128), "* NEST gerettet *", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	# Urheberhinweis, in der Testfassung mit Bitte um Vertraulichkeit
	_text(Vector2(8, H - 10), "© 2026 TheGoderGuy", 8, Color(GameData.COL.muted, 0.6))
	if SaveGame.test_build():
		_text(Vector2(8, 16), "TESTVERSION · bitte nicht weitergeben", 8, GameData.COL.coral, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)

	# Monster-Bühne
	var bob := 1 if sin(anim_t * 4.0) > 0 else 0
	var blink := fmod(anim_t, 3.4) < 0.13
	_shadow(W / 2.0, 238, 40)
	_draw_sprite("Pixmiez", W / 2.0, 238, false, {"scale": 3, "bob": bob, "blink": blink})
	_draw_sprite("bug", 110, 250, true, {"bob": 1 - bob, "mod": Color(1, 1, 1, 0.55)})
	_draw_sprite("moth", 530, 250, true, {"bob": bob, "mod": Color(1, 1, 1, 0.55)})

	if page == Page.MAIN:
		_menu(_main_items(), sel, W / 2.0, 246, 180, 20.0)
		if title_msg_t > 0:
			_text(Vector2(0, 130), title_msg, 8, Color(GameData.COL.sun, minf(1.0, title_msg_t)), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	else:
		_dim()
		var r := Rect2(150, 10, 340, 316)
		_box(r, GameData.COL.panel, GameData.COL.line)
		if page == Page.KEYS:
			_draw_keys(r)
		else:
			_draw_options(r)
	var pad: bool = InputSetup.pad
	var hint := (T.t("Steuerkreuz wählen · %s bestätigen · %s zurück") % [InputSetup.btn("A"), InputSetup.btn("B")] if pad else T.t("Pfeile wählen · Enter bestätigen · Esc zurück"))
	_text(Vector2(0, H - 10), hint, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	_text(Vector2(0, H - 10), "v%s " % ProjectSettings.get_setting("application/config/version", "0.2"), 8, Color(GameData.COL.muted, 0.6), HORIZONTAL_ALIGNMENT_RIGHT, W)


func _draw_options(r: Rect2) -> void:
	_text(r.position + Vector2(0, 26), "Optionen", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	_menu(_option_items(), sel, r.get_center().x, r.position.y + 38, 280, 19.0)
	if OPTIONS[sel] == "reset":
		_text(Vector2(0, r.end.y + 12), "Löscht Spielstand, laufenden Run und alle Einstellungen (auch die Tastenbelegung). Das Spieltest-Log bleibt.", 8, GameData.COL.coral, HORIZONTAL_ALIGNMENT_CENTER, W)
	if OPTIONS[sel] == "difficulty":
		var dd: String = T.t(["Mehr Zeit zum Ausweichen, Gegner treffen schwächer.", "So wie gedacht.", "Zähere Gegner, härtere Treffer, kürzere Warnungen.", "Nach dem Ende: stärkste Gegner, knappe Warnungen, 50 % mehr Fragmente."][Settings.difficulty])
		if not SaveGame.game_cleared():
			dd += "  " + T.t("(Nach dem Ende gibt es eine vierte Stufe.)")
		_text(Vector2(0, r.end.y + 12), dd, 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W)


func _shadow(cx: float, y: float, w: int) -> void:
	var c := Color(0.05, 0.02, 0.12, 0.35)
	draw_rect(Rect2(roundi(cx - w / 2.0), roundi(y - 2), w, 4), c)
	draw_rect(Rect2(roundi(cx - w / 2.0 + 3), roundi(y - 3), w - 6, 6), c)


## Tastenbelegung: Aktion links, Taste rechts; die gewählte Zeile blinkt, solange sie auf eine Taste wartet
func _draw_keys(r: Rect2) -> void:
	_text(r.position + Vector2(0, 26), "Tastenbelegung", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true, true)
	var n := InputSetup.REBIND.size()
	var w := 280.0
	var x := r.get_center().x - w / 2
	for i in n + 2:
		var row := Rect2(x, r.position.y + 38 + i * 20, w, 18)
		var active := i == sel
		_box(row, GameData.COL.panel if active else Color(GameData.COL.bg2, 0.85), GameData.COL.sun if active else GameData.COL.line)
		if active:
			_text(Vector2(row.position.x + 6 + (1 if sin(anim_t * 10.0) > 0 else 0), row.position.y + 13), ">", 8, GameData.COL.sun)
		var col: Color = GameData.COL.ink if active else GameData.COL.muted
		if i < n:
			var e: Array = InputSetup.REBIND[i]
			_text(Vector2(row.position.x + 18, row.position.y + 13), e[1], 8, col)
			var waiting: bool = key_wait == e[0]
			var label: String = InputSetup.key_label(e[0])
			if waiting:
				label = T.t("Taste drücken …") if fmod(anim_t, 0.8) < 0.55 else ""
			_text(Vector2(row.position.x, row.position.y + 13), label, 8, GameData.COL.sun if waiting else col, HORIZONTAL_ALIGNMENT_RIGHT, w - 10, true, active)
		else:
			_text(Vector2(row.position.x, row.position.y + 13), "Standard wiederherstellen" if i == n else "Zurück", 8, col, HORIZONTAL_ALIGNMENT_CENTER, w)
	var info := key_msg
	if key_wait != "":
		info = T.t("Neue Taste drücken · Esc bricht ab")
	elif info == "":
		info = T.t("Pfeiltasten, Enter, Esc, Rücktaste und Tab bleiben immer belegt.")
	_text(Vector2(0, r.end.y + 12), info, 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W)
