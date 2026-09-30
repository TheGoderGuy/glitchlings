extends PixelCanvas
## Opening-Szene beim neuen Spiel: Der NEST stürzt ab, die Glitchlings fliehen, ein Ei landet auf deinem Desktop.
## Läuft von selbst; Bestätigen = Text sofort zeigen bzw. weiter, Esc/Start = überspringen.

signal finished

const EGG := preload("res://assets/sprites/egg_s.png")

## Bilder der Szene: Dauer in Sekunden und Bildunterschrift
const PANELS := [
	{"id": "boot", "dur": 5.5, "text": ""},
	{"id": "crash", "dur": 4.0, "text": "Eines Tages stürzte der NEST ab."},
	{"id": "flight", "dur": 8.0, "text": "Seine Bewohner, die Glitchlings, flohen in alle Geräte, die sie finden konnten. Zurück blieben wilde, korrupte Daten."},
	{"id": "room", "dur": 8.0, "text": "Eines Nachts landet etwas auf deinem Desktop ..."},
	{"id": "egg", "dur": 9.0, "text": "Du bist jetzt Operator. Zieh die Glitchlings auf, trainiere sie und bring den NEST zurück ins Netz."},
]
const BOOT_LINES := ["NEST-Server v3.1 ... online", "Zonen: Cache-Wiesen, Firewall-Vulkan, Viren-Sümpfe", "Bewohner: 4.096 Glitchlings", "Status: alles friedlich"]
const TYPE_SPEED := 38.0   # Zeichen pro Sekunde
const FADE := 0.5

var idx := 0
var t := 0.0            # Zeit im aktuellen Bild
var shake := 0.0
var done := false
var played := {}        # Sounds, die in diesem Bild schon gespielt wurden


func _ready() -> void:
	Music.stop()


func _process(delta: float) -> void:
	anim_t += delta
	t += delta
	shake = maxf(0.0, shake - delta * 12.0)
	if done:
		return
	var p: Dictionary = PANELS[idx]
	_sounds(p.id)
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("back"):
		Sfx.play("back")
		_finish()
		return
	if Input.is_action_just_pressed("confirm"):
		var full := _text_time(p) + 0.1
		if t < full:
			t = full   # Text sofort vollständig
		else:
			_next()
	elif t >= p.dur:
		_next()
	queue_redraw()


## Für Screenshots/Tests: an eine Stelle der Gesamtzeit springen
func seek(total: float) -> void:
	idx = 0
	while idx < PANELS.size() - 1 and total >= PANELS[idx].dur:
		total -= PANELS[idx].dur
		idx += 1
	t = total
	anim_t = total


func _text_time(p: Dictionary) -> float:
	var n: int = p.text.length()
	if p.id == "boot":
		n = 0
		for l in BOOT_LINES:
			n += l.length()
	return 0.4 + n / TYPE_SPEED


func _next() -> void:
	idx += 1
	t = 0.0
	played.clear()
	if idx >= PANELS.size():
		_finish()
	elif PANELS[idx].id == "flight":
		Music.play("intro")


func _finish() -> void:
	done = true
	set_process(false)
	finished.emit()


## Einmalige Geräusche an bestimmten Stellen
func _sounds(id: String) -> void:
	var cues := {
		"boot": [[0.6, "tick"], [1.4, "tick"], [2.3, "tick"], [3.2, "confirm"]],
		"crash": [[0.1, "warn"], [0.7, "warn"], [1.3, "hit_big"], [1.5, "lose"]],
		"room": [[2.9, "pop"]],
		"egg": [[2.5, "tick"], [4.0, "tick"], [5.5, "charge"]],
	}
	for c in cues.get(id, []):
		if t >= c[0] and not played.has(c[1] + str(c[0])):
			played[c[1] + str(c[0])] = true
			Sfx.play(c[1], 0.0)
			if id == "crash" and c[1] == "hit_big":
				shake = 6.0


func _draw() -> void:
	off = Vector2(randf_range(-shake, shake), randf_range(-shake, shake)).round() if Settings.screen_shake else Vector2.ZERO
	draw_set_transform(off)
	draw_rect(Rect2(-8, -8, W + 16, H + 16), Color("#05030C"))
	if done:
		return
	var p: Dictionary = PANELS[idx]
	match p.id:
		"boot":
			_draw_boot()
		"crash":
			_draw_crash()
		"flight":
			_draw_flight()
		"room":
			_draw_room()
		"egg":
			_draw_egg()
	draw_set_transform(Vector2.ZERO)
	# Bildunterschrift, Schreibmaschine
	if p.text != "":
		var shown: String = p.text.substr(0, clampi(int((t - 0.4) * TYPE_SPEED), 0, p.text.length()))
		draw_rect(Rect2(0, H - 64, W, 64), Color(GameData.COL.dark, 0.82))
		draw_rect(Rect2(0, H - 64, W, 1), Color(GameData.COL.line, 0.8))
		draw_multiline_string(font(), Vector2(40, H - 40), shown, HORIZONTAL_ALIGNMENT_CENTER, W - 80, tsz(8), 3, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	# Ein- und Ausblenden
	var a := 0.0
	if t < FADE:
		a = 1.0 - t / FADE
	elif t > p.dur - FADE:
		a = (t - (p.dur - FADE)) / FADE
	if p.id == "egg" and t > p.dur - 1.2:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, clampf((t - (p.dur - 1.2)) / 1.0, 0.0, 1.0)))
	elif a > 0.0 and not (p.id == "crash" and t < FADE):
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, clampf(a, 0.0, 1.0)))
	var hint := "%s: weiter · %s: überspringen" % ([InputSetup.btn("A"), InputSetup.btn("Start")] if InputSetup.pad else ["Enter", "Esc"])
	_text(Vector2(0, 14), hint, 8, Color(GameData.COL.muted, 0.7), HORIZONTAL_ALIGNMENT_RIGHT, W - 10)


# ---------- Bilder ----------

## Terminal: der NEST fährt friedlich hoch
func _draw_boot() -> void:
	var green := Color("#6EE7C5")
	var budget := int(maxf(0.0, t - 0.4) * TYPE_SPEED)
	var y := 120.0
	for l in BOOT_LINES:
		var s: String = l.substr(0, clampi(budget, 0, l.length()))
		budget -= l.length()
		_text(Vector2(150, y), "> " + s, 8, green, HORIZONTAL_ALIGNMENT_LEFT, -1, false)
		y += 18
		if budget < 0:
			break
	if fmod(anim_t, 0.8) < 0.4:
		draw_rect(Rect2(150, y - 8, 6, 9), green)
	# ruhige Scanlines
	for sy in range(0, H, 3):
		draw_rect(Rect2(0, sy, W, 1), Color(0, 0, 0, 0.18))


## Absturz: Warnung, Störstreifen, alles zerfällt
func _draw_crash() -> void:
	var red := Color("#FF5470")
	var flash := fmod(anim_t, 0.5) < 0.25
	if t < 1.3:
		_text(Vector2(150, 120), "> Status: alles friedlich", 8, Color("#6EE7C5"), HORIZONTAL_ALIGNMENT_LEFT, -1, false)
		if flash:
			_text(Vector2(150, 150), "> WARNUNG: Datenkorruption!", 8, red, HORIZONTAL_ALIGNMENT_LEFT, -1, false)
		return
	# Störstreifen in Cyan/Magenta
	var rng := RandomNumberGenerator.new()
	rng.seed = int(anim_t * 20.0)
	for i in 18:
		var ry := rng.randi_range(0, H)
		var rh := rng.randi_range(1, 6)
		var rx := rng.randi_range(-40, 40)
		draw_rect(Rect2(rx, ry, W, rh), Color("#4CC3F0", 0.35) if i % 2 else Color("#FF5470", 0.35))
	for i in 60:
		draw_rect(Rect2(rng.randi_range(0, W), rng.randi_range(0, H), rng.randi_range(2, 10), rng.randi_range(2, 6)), Color(1, 1, 1, rng.randf_range(0.1, 0.5)))
	var big := "SYSTEMABSTURZ"
	var jit := Vector2(rng.randi_range(-3, 3), 0)
	draw_set_transform(off + Vector2(0, 0), 0, Vector2(2, 2))
	var lp := Vector2(0, 150 / 2.0)
	draw_string(font(true, 16), lp + jit * 0.5 + Vector2(-1, 0), big, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 16, Color("#4CC3F0", 0.8))
	draw_string(font(true, 16), lp - jit * 0.5 + Vector2(1, 0), big, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 16, Color("#FF5470", 0.8))
	draw_string(font(true, 16), lp, big, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 16, Color.WHITE)
	draw_set_transform(off)


## Flucht: die Wiese, Glitchlings lösen sich in Pixel auf und schießen davon, korrupte Daten bleiben
func _draw_flight() -> void:
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.35))
	# korrupte Daten flackern auf, sobald die Glitchlings weg sind
	var foes := [["bug", 400.0], ["wurm", 540.0], ["moth", 470.0]]
	for i in foes.size():
		var fa := clampf((t - 4.6 - i * 0.4) / 0.8, 0.0, 1.0)
		if fa <= 0.0:
			continue
		var fk: String = foes[i][0]
		var glitch := fmod(anim_t * 1.7 + i * 0.6, 2.0) < 0.12 or (fa < 1.0 and fmod(anim_t * 20.0, 1.0) < 0.5)
		_draw_sprite(fk, foes[i][1] + (3.0 if glitch else 0.0), 262.0 + i % 2 * 12, true, {"mod": Color(0.75, 0.65, 0.95, fa * (0.9 if not glitch else 0.5))})
	# fliehende Glitchlings: steigen auf, zerfallen in Pixel, die nach oben rechts davonfliegen
	var babies := ["Pixmiez", "Funkling", "Tröpfel", "Kekso", "Lumi", "Quakli"]
	for i in babies.size():
		var start := 1.6 + i * 0.4
		var k := clampf((t - start) / 1.8, 0.0, 1.0)
		var bx := 70.0 + i * 100.0
		var by := 262.0 - k * 150.0
		if k < 0.55:
			_draw_sprite(babies[i], bx, by, false, {"scale": 2, "bob": 1 if sin(anim_t * 8.0 + i) > 0 else 0,
				"mod": Color(1, 1, 1, 1.0 - k)})
		# Pixelspur
		if k > 0.0:
			for j in 12:
				var pk := clampf(k * 1.3 - j * 0.04, 0.0, 1.0)
				var px := bx + pk * (180.0 + j * 9.0) + sin(j * 2.3) * 10.0
				var py := by - 20.0 - pk * (60.0 + j * 7.0)
				var col: Color = [Color("#6EE7C5"), Color("#4CC3F0"), Color("#FFD84D"), Color("#FF8FD8")][(i + j) % 4]
				if pk > 0.02 and pk < 0.98:
					draw_rect(Rect2(roundi(px), roundi(py), 2, 2), Color(col, 1.0 - pk))


## Nacht, dein Zimmer: Monitor leuchtet, ein Ei fällt auf den Desktop
func _draw_room() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#0E0A1E"))
	# Fenster mit Mond und Sternen
	draw_rect(Rect2(60, 50, 120, 90), Color("#2A2446"))
	draw_rect(Rect2(64, 54, 112, 82), Color("#141030"))
	for i in 12:
		var sx := 70 + (i * 37) % 100
		var sy := 60 + (i * 23) % 70
		if fmod(anim_t + i * 0.37, 2.0) > 0.3:
			draw_rect(Rect2(sx, sy, 1, 1), Color(1, 1, 1, 0.7))
	draw_circle(Vector2(150, 78), 10.0, Color("#F4EBC8"))
	draw_circle(Vector2(146, 75), 9.0, Color("#141030"))
	draw_rect(Rect2(119, 54, 2, 82), Color("#2A2446"))
	draw_rect(Rect2(64, 94, 112, 2), Color("#2A2446"))
	# Tisch
	draw_rect(Rect2(0, 262, W, 98), Color("#1A1430"))
	draw_rect(Rect2(0, 262, W, 3), Color("#3A2F5E"))
	# Monitorschein auf dem Tisch
	draw_rect(Rect2(250, 265, 260, 10), Color("#4CC3F0", 0.08))
	# Monitor
	var M := Rect2(260, 70, 240, 160)
	draw_rect(M.grow(8), Color("#2C2352"))
	draw_rect(M.grow(8).grow(-1), Color("#3A2F66"))
	draw_rect(Rect2(362, 238, 36, 16), Color("#2C2352"))
	draw_rect(Rect2(336, 254, 88, 8), Color("#3A2F66"))
	_draw_desktop(M)
	# Ei fällt aus einer Datenspalte oben auf den Desktop
	var land := 2.9
	var ex := M.get_center().x + 30
	var floor_y := M.end.y - 22
	if t > 1.6:
		var k := clampf((t - 1.6) / (land - 1.6), 0.0, 1.0)
		var ey := M.position.y + 10 + (floor_y - M.position.y - 10) * k * k
		if t < land + 0.2:
			# Spalt im Bildschirm, aus dem es kommt
			draw_rect(Rect2(ex - 14, M.position.y + 4, 28, 3), Color("#FF5470", 0.8))
			for j in 5:
				draw_rect(Rect2(ex - 10 + j * 5, M.position.y + 8 + fmod(anim_t * 60.0 + j * 13.0, 30.0), 2, 2), Color("#6EE7C5", 0.6))
		var bounce := 0.0
		if t > land:
			bounce = absf(sin((t - land) * 9.0)) * 6.0 * maxf(0.0, 1.0 - (t - land) * 1.5)
		var wob := sin(anim_t * 6.0) * 0.12 if t > land + 1.0 else 0.0
		_draw_egg_tex(Vector2(ex, ey - bounce), 1, wob)
	# Cursor wandert hin
	var ck := clampf((t - 4.0) / 2.0, 0.0, 1.0)
	var cp := Vector2(M.position.x + 40, M.end.y - 40).lerp(Vector2(ex + 10, floor_y - 12), ck * ck * (3.0 - 2.0 * ck))
	_cursor(cp)


func _draw_desktop(M: Rect2) -> void:
	draw_rect(M, Color("#1E3A5A"))
	for y in range(int(M.position.y), int(M.end.y), 2):
		draw_rect(Rect2(M.position.x, y, M.size.x, 1), Color(1, 1, 1, 0.03))
	# Symbole links
	var icons := [Color("#FFD84D"), Color("#58B7FF"), Color("#7BD35A"), Color("#FF8FD8")]
	for i in icons.size():
		var ip := M.position + Vector2(10, 10 + i * 28)
		draw_rect(Rect2(ip, Vector2(14, 12)), icons[i])
		draw_rect(Rect2(ip + Vector2(-2, 15), Vector2(18, 2)), Color(1, 1, 1, 0.35))
	# Taskleiste
	draw_rect(Rect2(M.position.x, M.end.y - 10, M.size.x, 10), Color("#16263E"))
	draw_rect(Rect2(M.position.x + 3, M.end.y - 8, 12, 6), Color("#6EE7C5"))
	draw_rect(Rect2(M.end.x - 30, M.end.y - 7, 26, 4), Color(1, 1, 1, 0.3))


func _cursor(p: Vector2) -> void:
	var rows := [1, 2, 3, 4, 5, 6, 7, 4, 2]
	for i in rows.size():
		draw_rect(Rect2(roundi(p.x) - 1, roundi(p.y) + i - 1, rows[i] + 2, 1), GameData.COL.dark)
	for i in rows.size():
		draw_rect(Rect2(roundi(p.x), roundi(p.y) + i, rows[i], 1), Color.WHITE)


## Nahaufnahme: das Ei wackelt, bekommt Risse, Licht bricht heraus
func _draw_egg() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#1E3A5A"))
	for y in range(0, H, 2):
		draw_rect(Rect2(0, y, W, 1), Color(1, 1, 1, 0.03))
	var c := Vector2(W / 2.0, 200.0)
	# Lichtstrahlen, immer stärker
	var glow := clampf((t - 2.0) / 5.0, 0.0, 1.0)
	for i in 10:
		var a := i * TAU / 10.0 + anim_t * 0.25
		var d := Vector2(cos(a), sin(a))
		var n := Vector2(-d.y, d.x)
		var pts := PackedVector2Array([c - Vector2(0, 40), c - Vector2(0, 40) + d * 400.0 + n * 30.0, c - Vector2(0, 40) + d * 400.0 - n * 30.0])
		draw_colored_polygon(pts, Color("#FFF6C8", 0.05 + 0.1 * glow))
	draw_circle(c - Vector2(0, 40), 60.0 + 10.0 * sin(anim_t * 3.0), Color("#FFF6C8", 0.06 + 0.12 * glow))
	var shake_amt := 0.0
	for s in [2.5, 4.0, 5.5]:
		if t > s and t < s + 0.5:
			shake_amt = 0.25 * (1.0 - (t - s) / 0.5)
	var wob := sin(anim_t * 30.0) * shake_amt
	_draw_egg_tex(c, 4, wob)
	# Risse
	var cracks := [[2.5, [Vector2(-6, -70), Vector2(-2, -62), Vector2(-8, -54), Vector2(-3, -46)]],
		[4.0, [Vector2(4, -80), Vector2(10, -70), Vector2(5, -62), Vector2(12, -52)]],
		[5.5, [Vector2(-3, -46), Vector2(4, -40), Vector2(-2, -32), Vector2(6, -26)]]]
	for cr in cracks:
		if t > cr[0]:
			var pts: Array = cr[1]
			for i in pts.size() - 1:
				draw_line(c + pts[i], c + pts[i + 1], GameData.COL.dark, 3.0)
				draw_line(c + pts[i], c + pts[i + 1], Color("#FFF6C8", glow), 1.0)


## Ei-Sprite (32 px) skaliert, unten mittig an p, leicht gekippt
func _draw_egg_tex(p: Vector2, sc: int, tilt: float) -> void:
	draw_set_transform(off + p, tilt, Vector2(sc, sc))
	draw_texture(EGG, Vector2(-EGG.get_width() / 2.0, -EGG.get_height()))
	draw_set_transform(off)
