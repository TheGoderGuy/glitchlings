extends "res://scripts/ui/cinema_canvas.gd"
## Kino-Ende nach dem Sieg über den Ur-Glitch (30.09.2026, vorher 5 schlichte Bilder). Spiegelt das Opening:
## der Ur-Glitch zerspringt, der NEST startet neu, eine Heilungswelle läuft über die Welt, die Glitchlings kehren
## als Lichtspuren heim, dein Team, das Zimmer am Morgen, Title Drop, kurzer Abspann, ENDE.
## Musik "ending" läuft ab der Heilung taktgenau (96 BPM, 1 Takt = 2,5 s).
## Bestätigen = Text sofort zeigen bzw. weiter, Esc/Start = überspringen.

signal finished

const PANELS := [
	{"id": "shatter", "dur": 3.0, "text": "", "fade_in": false, "fade_out": true},
	{"id": "reboot", "dur": 6.0, "text": "", "fade_in": false, "fade_out": false},
	{"id": "heal", "dur": 10.0, "text": "Der Fehler war gelöscht. Welle um Welle wurde der NEST wieder heil.", "fade_in": true, "fade_out": false},
	{"id": "return", "dur": 7.5, "text": "Aus allen Geräten kehrten die Glitchlings nach Hause zurück.", "fade_in": true, "fade_out": true},
	{"id": "team", "dur": 7.5, "text": "Und mittendrin: dein Team. Ohne euch gäbe es den NEST nicht mehr. Danke, Operator.", "fade_in": true, "fade_out": true},
	{"id": "room", "dur": 7.5, "text": "Der Sturm ist vorbei. Aber auf deinem Desktop wird es nie wieder ganz still sein.", "fade_in": true, "fade_out": true},
	{"id": "title", "dur": 5.0, "text": "", "fade_in": false, "fade_out": true},
	{"id": "credits", "dur": 15.0, "text": "", "fade_in": true, "fade_out": true},
	{"id": "end", "dur": 7.5, "text": "", "fade_in": true, "fade_out": true},
]
const MUSIC_FROM := 2   # ab der Heilung läuft "ending"
const REBOOT_LINES := ["Ur-Glitch ... defragmentiert", "Korruption: 0 %", "NEST-Server v3.1 ... Neustart", "Bewohner: 4.096 Glitchlings ... kehren zurück", "Status: alles friedlich"]
const REBOOT_TYPE_START := 0.8
## Die acht Babys, die im Opening geflohen sind, kommen zurück (gleiche Richtungen, umgekehrt)
const HOME := ["Pixmiez", "Funkling", "Tröpfel", "Kekso", "Lumi", "Quakli", "Molchi", "Brummbit"]
## Name im Abspann (an einer Stelle änderbar)
const CREATOR := "TheGoderGuy"
const ROLES := ["Idee · Produktion · Game Design · Programmierung", "Pixel-Art-Regie · Musik und Sound"]
## Zweite Abspann-Karte: [Überschrift, Zeile]
const THANKS := [
	["Monster und Gegner", "erstellt mit PixelLab"],
	["Schriften", "Pixeloid Sans von GGBotNet · Silkscreen von Jason Kottke (SIL Open Font License)"],
	["Engine", "Godot 4"],
	["Besonderer Dank", "an alle Spieltester und an dich, Operator"],
]
const PARADE := ["Aurorlynx", "Leviamander", "Myzelgrizz", "Orbitkauz", "Lunaflut", "Hydradrak"]

var idx := 0
var t := 0.0
var done := false
var played := {}
var team_forms: Array = []   # Formen für das Team-Bild (vom Aufrufer gesetzt, sonst Team aus dem Spielstand)
var shards: Array = []       # Splitter des Ur-Glitch: [Position im Sprite, Farbe]
var cracks: Array = []       # Risslinien über dem Ur-Glitch (Punktlisten relativ zur Mitte)


func _ready() -> void:
	Music.stop()
	if team_forms.is_empty():
		for m in SaveGame.team().slice(0, 5):
			team_forms.append(m.form)
	if team_forms.is_empty():
		team_forms = ["Pixmiez", "Funkling", "Tröpfel"]
	# Splitter: jedes 3×3-Feld des Sprites wird ein Block
	var img: Image = sprite("urglitch").tex.get_image()
	if img.is_compressed():
		img.decompress()
	for y in range(1, img.get_height(), 3):
		for x in range(1, img.get_width(), 3):
			var c := img.get_pixel(x, y)
			if c.a > 0.5:
				shards.append([Vector2i(x, y), c])
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 7:
		var a := i * TAU / 7.0 + rng.randf_range(-0.3, 0.3)
		var pts: Array = [Vector2.ZERO]
		var p := Vector2.ZERO
		for j in 5:
			var d := Vector2(cos(a), sin(a)).rotated(rng.randf_range(-0.6, 0.6))
			p += d * rng.randf_range(12.0, 20.0)
			pts.append(p)
		cracks.append(pts)


## Für Screenshots/Tests: an eine Stelle der Gesamtzeit springen
func seek(total: float) -> void:
	idx = 0
	while idx < PANELS.size() - 1 and total >= PANELS[idx].dur:
		total -= PANELS[idx].dur
		idx += 1
	t = total
	anim_t = total


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
	if Input.is_action_just_pressed("confirm") and t > 0.3:
		var full := _text_time(p) + 0.1
		if (p.text != "" or p.id == "reboot") and t < full:
			t = full   # Text sofort vollständig
		else:
			_next()
	elif t >= p.dur:
		_next()
	queue_redraw()


func _text_time(p: Dictionary) -> float:
	if p.id == "reboot":
		var n := 0
		for l in REBOOT_LINES:
			n += T.t(l).length()
		return REBOOT_TYPE_START + n / TYPE_SPEED
	return 0.4 + T.t(p.text).length() / TYPE_SPEED


## Position eines Bildes im Stück "ending" (Heilung beginnt bei 0 s)
func _music_pos(i: int) -> float:
	var pos := 0.0
	for j in range(MUSIC_FROM, i):
		pos += PANELS[j].dur
	return pos


func _next() -> void:
	idx += 1
	t = 0.0
	played.clear()
	if idx >= PANELS.size():
		_finish()
		return
	if idx == MUSIC_FROM:
		Music.play("ending")
	elif idx > MUSIC_FROM and Music.current == "ending":
		Music.seek(_music_pos(idx))   # weitergeblättert: Musik bleibt synchron


func _finish() -> void:
	done = true
	set_process(false)
	finished.emit()


## Einmalige Geräusche an bestimmten Stellen
func _sounds(id: String) -> void:
	var cues := {
		"shatter": [[0.0, "hit_big"], [0.35, "overload"], [0.7, "shift"], [1.0, "hit_big"], [1.02, "special"]],
		"reboot": [[1.2, "tick"], [1.8, "tick"], [2.6, "tick"], [3.5, "tick"], [4.4, "confirm"]],
		"heal": [[0.3, "heal"]],
		"team": [[0.4, "win"]],
		"room": [[4.2, "pop"]],
		"title": [[0.0, "hit_big"], [0.05, "special"]],
		"end": [[4.6, "tick"], [5.4, "tick"]],
	}
	var list: Array = cues.get(id, [])
	if id == "return":
		for i in HOME.size():
			list.append([_return_start(i), "dodge"])
			list.append([_return_start(i) + 0.8, "pop"])
		list.append([5.3, "confirm"])
	for c in list:
		if t >= c[0] and not played.has(c[1] + str(c[0])):
			played[c[1] + str(c[0])] = true
			Sfx.play(c[1], 0.0)
			if c[1] == "hit_big" and id in ["shatter", "title"]:
				shake = 8.0


func _draw() -> void:
	off = Vector2(randf_range(-shake, shake), randf_range(-shake, shake)).round() if Settings.screen_shake else Vector2.ZERO
	draw_set_transform(off)
	draw_rect(Rect2(-8, -8, W + 16, H + 16), Color("#05030C"))
	if done:
		return
	var p: Dictionary = PANELS[idx]
	match p.id:
		"shatter":
			_draw_shatter()
		"reboot":
			_draw_reboot()
		"heal":
			_draw_heal()
		"return":
			_draw_return()
		"team":
			_draw_team()
		"room":
			_draw_room()
		"title":
			_draw_title()
		"credits":
			_draw_credits()
		"end":
			_draw_end()
	draw_set_transform(Vector2.ZERO)
	if p.id in ["heal", "return", "team", "room"]:
		_vignette()
	var a := 0.0
	if p.fade_in and t < FADE:
		a = 1.0 - t / FADE
	elif p.fade_out and t > p.dur - FADE:
		a = (t - (p.dur - FADE)) / FADE
	if a > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, clampf(a, 0.0, 1.0)))
	_letterbox(1.0, p.text, t)


## Warmes Morgenlicht von oben links (schräge Lichtbahnen)
func _sunlight(k: float) -> void:
	for i in 5:
		var x0 := -40.0 + i * 70.0
		var w := 26.0 + i * 6.0
		var pts := PackedVector2Array([Vector2(x0, 0), Vector2(x0 + w, 0), Vector2(x0 + w + 260, H), Vector2(x0 + 260, H)])
		draw_colored_polygon(pts, Color("#FFE6A8", (0.05 + 0.02 * sin(anim_t * 0.8 + i)) * k))
	draw_rect(Rect2(-8, -8, W + 16, H + 16), Color("#FFB070", 0.06 * k))


# ---------- 1. Der Ur-Glitch zerspringt ----------

func _draw_shatter() -> void:
	var cx := W / 2.0
	var feet := 262.0
	var sc := 2
	var s := sprite("urglitch")
	var size: float = s.n * sc
	var left := cx - size / 2.0
	var top_y: float = feet - size + s.foot * sc
	var center := Vector2(cx, top_y + size * 0.45)
	# roter Grund, der mit dem Zerspringen verblasst
	var fade := clampf((t - 1.0) / 1.2, 0.0, 1.0)
	draw_rect(Rect2(-8, -8, W + 16, H + 16), Color("#2A0616").lerp(Color("#05030C"), fade))
	_corruption(0.7 * (1.0 - fade))
	if t < 1.0:
		# zittert immer stärker, Risse wachsen, blitzt weiß auf
		var k := clampf(t / 1.0, 0.0, 1.0)
		var jit := roundf(sin(anim_t * 70.0) * (1.0 + k * 4.0))
		_draw_sprite("urglitch", cx + jit, feet, true, {"scale": sc})
		if fmod(t, 0.24) < 0.08 or t < 0.12:
			_draw_sprite("urglitch", cx + jit, feet, true, {"scale": sc, "flash": true, "mod": Color(1, 1, 1, 0.75)})
		var grow := clampf((t - 0.15) / 0.8, 0.0, 1.0)
		for cr in cracks:
			var n := int(grow * (cr.size() - 1))
			for j in n:
				draw_line(center + cr[j] * 2.0 + Vector2(jit, 0), center + cr[j + 1] * 2.0 + Vector2(jit, 0), GameData.COL.dark, 4.0)
				draw_line(center + cr[j] * 2.0 + Vector2(jit, 0), center + cr[j + 1] * 2.0 + Vector2(jit, 0), Color("#FFF6C8"), 2.0)
		return
	# Splitter fliegen auseinander und verglühen zu Licht
	var e := t - 1.0
	for i in shards.size():
		var sp: Vector2i = shards[i][0]
		var col: Color = shards[i][1]
		var home := Vector2(left + (s.n - 1 - sp.x) * sc, top_y + sp.y * sc)   # gespiegelt, er schaut nach links
		var dir := (home - center).normalized()
		var speed := 90.0 + float((i * 53) % 170)
		var pos := home + dir * speed * e + Vector2(0, -30.0 * e + 50.0 * e * e)
		var life := clampf(1.0 - e / (1.2 + (i % 5) * 0.12), 0.0, 1.0)
		if life <= 0.0:
			continue
		var c := col.lerp([Color("#6EE7C5"), Color("#FFFFFF"), Color("#4CC3F0")][i % 3], clampf(e * 2.0, 0.0, 1.0))
		var bs := 6.0 * (0.4 + 0.6 * life)
		draw_rect(Rect2(roundi(pos.x - bs / 2.0), roundi(pos.y - bs / 2.0), roundi(bs), roundi(bs)), Color(c, life))
	# Schockwelle und Weißblitz
	if e < 1.0:
		draw_arc(center, 20.0 + e * 460.0, 0, TAU, 64, Color(1, 1, 1, 0.6 * (1.0 - e)), 3.0)
		draw_arc(center, (20.0 + e * 460.0) * 0.72, 0, TAU, 64, Color("#6EE7C5", 0.4 * (1.0 - e)), 2.0)
	if e < 0.2:
		draw_rect(Rect2(-8, -8, W + 16, H + 16), Color(1, 1, 1, 1.0 - e / 0.2))


# ---------- 2. Neustart: Terminal wie im Opening ----------

func _draw_reboot() -> void:
	var green := Color("#6EE7C5")
	var budget := int(maxf(0.0, t - REBOOT_TYPE_START) * TYPE_SPEED)
	var x := 120.0
	var y := 122.0
	for i in REBOOT_LINES.size():
		var l: String = T.t(REBOOT_LINES[i])
		var s: String = l.substr(0, clampi(budget, 0, l.length()))
		budget -= l.length()
		_text(Vector2(x, y), "> " + s, 8, Color("#FFD84D") if i == 0 else green, HORIZONTAL_ALIGNMENT_LEFT, -1, false)
		if budget < 0:
			break
		y += 18
	if fmod(anim_t, 0.8) < 0.4:
		draw_rect(Rect2(x + 2, y - 8 + (0 if budget < 0 else 18), 6, 9), green)
	for sy in range(0, H, 3):
		draw_rect(Rect2(0, sy, W, 1), Color(0, 0, 0, 0.2))


# ---------- 3. Heilung: Kamerafahrt zurück, eine Welle heilt den NEST ----------

func _draw_heal() -> void:
	var dur: float = PANELS[idx].dur
	var cam := WORLD_CAM_END * (1.0 - _smooth(t / dur))
	_draw_world(cam, 0.0, 0.0, false)
	# Wellenfront auf dem Bildschirm: startet am Turm, bleibt vor der Kamera und läuft am Schluss links hinaus
	var front := lerpf(TOWER_X - WORLD_CAM_END, 110.0, clampf(t / (dur - 2.5), 0.0, 1.0))
	if t > dur - 2.5:
		front = lerpf(110.0, -140.0, _smooth((t - (dur - 2.5)) / 1.6))
	# rechts der Welle ist alles heil: Datenblumen sprießen
	for i in 90:
		var wx := 30.0 + i * 41.0 + float((i * 17) % 23)
		var sx := wx - roundf(cam)
		if sx < front + 4.0 or sx > W + 4:
			continue
		var g := clampf((sx - front) / 70.0, 0.0, 1.0)
		var gy := GROUND + 6.0 + float(i % 3) * 5.0
		var stem := roundf(2.0 + 6.0 * g)
		draw_rect(Rect2(roundi(sx), roundi(gy - stem), 1, stem), Color("#7BD35A"))
		if g > 0.5:
			var bc: Color = [Color("#FFD84D"), Color("#FF8FD8"), Color("#6EE7C5"), Color("#C9B8FF")][i % 4]
			draw_rect(Rect2(roundi(sx) - 1, roundi(gy - stem) - 2, 3, 3), bc)
	# links der Welle: noch korrupt und dunkel
	if front > -8.0:
		draw_rect(Rect2(-8, -8, front + 8, H + 16), Color(0.05, 0.0, 0.08, 0.45))
		_corruption(0.85, front)
	# die Welle selbst: helle Kante, Nachleuchten nach rechts, aufsteigende Funken
	for i in 10:
		draw_rect(Rect2(roundi(front) + i * 5, -8, 5, H + 16), Color("#6EE7C5", 0.22 * (1.0 - i / 10.0)))
	draw_rect(Rect2(roundi(front) - 1, -8, 3, H + 16), Color(1, 1, 1, 0.8))
	for i in 28:
		var px := front + fmod(i * 37.0, 110.0)
		var rise := fmod(anim_t * 55.0 + i * 29.0, 170.0)
		draw_rect(Rect2(roundi(px), roundi(GROUND - rise), 2, 2), Color([Color("#6EE7C5"), Color("#FFD84D"), Color.WHITE][i % 3], 1.0 - rise / 170.0))
	# Lichtblitz am Turm, von dem die Heilung ausgeht
	if t < 1.2:
		var tx := TOWER_X - cam
		draw_circle(Vector2(tx, 64), 20.0 + t * 160.0, Color("#6EE7C5", 0.35 * (1.0 - t / 1.2)))


# ---------- 4. Heimkehr: Lichtspuren kommen zurück und werden wieder Glitchlings ----------

func _return_start(i: int) -> float:
	return 0.6 + i * 0.3


func _draw_return() -> void:
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	_sunlight(0.7)
	var cols := [Color("#6EE7C5"), Color("#FF8A4C"), Color("#4CC3F0"), Color("#FFD84D"), Color("#C9B8FF"), Color("#FF8FD8"), Color("#7BD35A"), Color("#D8A060")]
	for i in HOME.size():
		var home := Vector2(84.0 + i * 67.0, GROUND + 4.0)
		# gleiche Richtungen wie bei der Flucht im Opening, nur umgekehrt
		var ang := -PI * 0.95 + i * (PI * 1.9 / (HOME.size() - 1))
		var dir := Vector2(cos(ang), sin(ang) * 0.6)
		var start := _return_start(i)
		var k := clampf((t - start) / 0.8, 0.0, 1.0)
		var pos := home + dir * 620.0 * (1.0 - k) * (1.0 - k)
		if k > 0.0 and k < 1.0:
			var col: Color = cols[i]
			for j in 40:
				var tp := pos + dir * (j * 3.0) - Vector2(0, 14)
				var fd := 1.0 - j / 40.0
				draw_rect(Rect2(roundi(tp.x) - 2, roundi(tp.y) - 2, 5, 5), Color(col, fd * 0.25))
				draw_rect(Rect2(roundi(tp.x) - 1, roundi(tp.y) - 1, 3, 3), Color(col, fd * 0.9))
			draw_circle(pos - Vector2(0, 14), 9.0, Color(col, 0.3))
			draw_rect(Rect2(roundi(pos.x) - 2, roundi(pos.y) - 16, 5, 5), Color.WHITE)
		if k >= 1.0:
			var since := t - start - 0.8
			var hop := 0.0
			if since < 0.5:
				hop = absf(sin(since * TAU)) * 5.0
			if t > 5.3 and t < 6.3:
				hop = absf(sin((t - 5.3) * 3.0 * PI)) * 8.0   # alle freuen sich zusammen
			# zur Mitte schauen
			_draw_sprite(HOME[i], home.x, home.y - roundf(hop), i >= HOME.size() / 2, {"scale": 2, "phase": i * 1.7})
			if since < 0.25:
				draw_circle(home - Vector2(0, 28), 30.0 * (1.0 - since / 0.25), Color(1, 1, 1, 0.6))


# ---------- 5. Dein Team, Kamera fährt hoch ----------

func _draw_team() -> void:
	off += Vector2(0, roundf(34.0 * (1.0 - _smooth(t / 3.0))))
	draw_set_transform(off)
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	_sunlight(1.0)
	var n := team_forms.size()
	for i in n:
		var f: String = team_forms[i]
		var cx := W / 2.0 + (i - (n - 1) / 2.0) * 110.0
		var st: int = GameData.FORMS.get(f, {}).get("stage", 1)
		draw_rect(Rect2(cx - 28, GROUND + 10, 56, 4), Color(0.05, 0.02, 0.12, 0.35))
		_draw_sprite(f, cx, GROUND + 12, false, {"scale": 2 if st == 1 else 1, "phase": i * 0.9})
	# Konfetti: erst ein Ausbruch aus der Mitte, dann rieselt es
	var cols := [Color("#6EE7C5"), Color("#FFD84D"), Color("#FF8FD8"), Color("#4CC3F0"), Color("#FF8A4C")]
	var e := t - 0.4
	if e > 0.0 and e < 2.0:
		for i in 70:
			var a := i * 2.399
			var sp := 120.0 + float((i * 41) % 160)
			var p := Vector2(W / 2.0, 170.0) + Vector2(cos(a), sin(a) * 0.7) * sp * e + Vector2(0, 60.0 * e * e)
			draw_rect(Rect2(roundi(p.x), roundi(p.y), 3 if i % 3 == 0 else 2, 2), Color(cols[i % 5], 1.0 - e / 2.0))
	if t > 1.2:
		for i in 50:
			var x := fmod(i * 73.1 + sin(anim_t + i) * 12.0, W)
			var y := fmod(anim_t * (30.0 + i % 5 * 8.0) + i * 41.0, H)
			draw_rect(Rect2(roundi(x), roundi(y), 2 if i % 3 else 3, 2), Color(cols[i % 5], clampf((t - 1.2) / 0.8, 0.0, 1.0)))


# ---------- 6. Das Zimmer am Morgen ----------

func _draw_room() -> void:
	var drift := roundf(lerpf(-10.0, 10.0, t / PANELS[idx].dur))
	off += Vector2(drift, 0)
	draw_set_transform(off)
	draw_rect(Rect2(-20, 0, W + 40, H), Color("#1C1836"))
	# Sonnenfleck an der Wand
	draw_colored_polygon(PackedVector2Array([Vector2(64, 136), Vector2(176, 136), Vector2(250, 262), Vector2(130, 262)]), Color("#FFD9A0", 0.08))
	# Fenster: Morgenhimmel, Regenbogen, letzte Tropfen
	draw_rect(Rect2(60, 50, 120, 90), Color("#2A2446"))
	var sky := [Color("#6C7FD8"), Color("#9C8FE0"), Color("#E7A3C2"), Color("#FFC98F"), Color("#FFE3A8")]
	for i in sky.size():
		draw_rect(Rect2(64, 54 + i * 16.4, 112, 17), sky[i])
	draw_circle(Vector2(96, 128), 12.0, Color("#FFF1C4"))
	var rb := [Color("#FF8A8A"), Color("#FFD84D"), Color("#7BD35A"), Color("#4CC3F0"), Color("#C9B8FF")]
	for i in rb.size():
		draw_arc(Vector2(128, 136), 46.0 - i * 2.0, PI, TAU, 32, Color(rb[i], 0.45), 2.0)
	for i in 9:
		var dx := 68.0 + fmod(i * 23.0, 104.0)
		var dy := 56.0 + fmod(i * 31.0 + anim_t * (4.0 + i % 3), 76.0)
		draw_rect(Rect2(roundi(dx), roundi(dy), 1, 2), Color("#DDEBFF", 0.6))
	draw_rect(Rect2(119, 54, 2, 82), Color("#2A2446"))
	draw_rect(Rect2(64, 94, 112, 2), Color("#2A2446"))
	# Tisch und Monitor wie im Opening
	draw_rect(Rect2(-20, 262, W + 40, 98), Color("#221A3A"))
	draw_rect(Rect2(-20, 262, W + 40, 3), Color("#4A3D72"))
	var M := Rect2(260, 70, 240, 160)
	draw_rect(M.grow(8), Color("#2C2352"))
	draw_rect(M.grow(8).grow(-1), Color("#3A2F66"))
	draw_rect(Rect2(362, 238, 36, 16), Color("#2C2352"))
	draw_rect(Rect2(336, 254, 88, 8), Color("#3A2F66"))
	_draw_desktop(M)
	# Auf dem Desktop: die Eierschale und dein Glitchling
	var floor_y := M.end.y - 10
	var shell_x := M.position.x + 110
	var eh := EGG.get_height()
	var ew := EGG.get_width()
	draw_texture_rect_region(EGG, Rect2(shell_x - ew / 2.0, floor_y - eh / 2.0, ew, eh / 2.0), Rect2(0, eh / 2.0, ew, eh / 2.0))
	var mon: String = team_forms[0]
	var ms := sprite(mon)
	var msc := 2 if ms.n <= 32 else 1
	var msize: float = ms.n * msc - ms.foot * msc
	var mx := M.position.x + 170
	var hop := 0.0
	if t > 4.2 and t < 4.9:
		hop = absf(sin((t - 4.2) * PI / 0.35)) * 6.0
	_draw_sprite(mon, mx, floor_y - roundf(hop), false, {"scale": msc})
	# Mauszeiger kommt von rechts und streichelt den Kopf, ein Herz steigt auf
	var ck := _smooth((t - 1.5) / 2.2)
	var head := Vector2(mx + msize * 0.5, floor_y - msize * 0.7)   # knapp rechts neben dem Kopf, damit der Zeiger sichtbar bleibt
	var pat := Vector2(0, roundf(absf(sin(t * 7.0)) * 3.0)) if t > 3.7 and t < 4.4 else Vector2.ZERO
	_cursor(Vector2(M.end.x - 16, M.position.y + 24).lerp(head, ck) + pat)
	if t > 4.2:
		var hk := clampf((t - 4.2) / 1.6, 0.0, 1.0)
		_heart(Vector2(mx, floor_y - msize - 6 - hk * 26.0), 1.0 - hk)


## Kleines Pixelherz
func _heart(p: Vector2, a: float) -> void:
	var rows := [".xx.xx.", "xxxxxxx", "xxxxxxx", ".xxxxx.", "..xxx..", "...x..."]
	for y in rows.size():
		for x in rows[y].length():
			if rows[y][x] == "x":
				draw_rect(Rect2(roundi(p.x) + x * 2 - 7, roundi(p.y) + y * 2, 2, 2), Color("#FF6F9E", a))


# ---------- 7. Title Drop, diesmal ohne Riss ----------

func _draw_title() -> void:
	# Morgendämmerung
	for i in 14:
		draw_rect(Rect2(-8, 40 + i * 20, W + 16, 21), Color("#0C0A24").lerp(Color("#5A2E58"), pow(i / 13.0, 1.6)))
	for i in 40:
		var sx := fmod(i * 131.0, W)
		var sy := 44.0 + fmod(i * 67.0, 200.0)
		draw_rect(Rect2(sx, sy, 1, 1), Color(1, 1, 1, 0.3 + 0.3 * sin(anim_t * 2.0 + i)))
	# goldenes Feuerwerk statt roter Funken
	if t < 1.6:
		for i in 48:
			var a := i * 2.399
			var d := t * (150.0 + (i * 37) % 150)
			var sp := Vector2(W / 2.0, 170.0) + Vector2(cos(a), sin(a) * 0.6) * d + Vector2(0, 30.0 * t * t)
			draw_rect(Rect2(roundi(sp.x), roundi(sp.y), 2, 2), Color([Color("#6EE7C5"), Color("#FFD84D"), Color.WHITE][i % 3], 1.0 - t / 1.6))
	var f := font(true, 24)
	var logo := "GLITCHLINGS"
	var sc := 2
	var jit := maxf(0.0, 5.0 * (1.0 - t / 0.5))
	var base_y := 196.0
	draw_set_transform(off, 0, Vector2(sc, sc))
	var lp := Vector2(0, base_y / sc)
	var j := Vector2(roundf(jit / sc), 0)
	if jit > 0.0:
		draw_string(f, lp - j, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, Color("#4CC3F0", 0.8))
		draw_string(f, lp + j, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, Color("#FF8FD8", 0.8))
	draw_string_outline(f, lp, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, 4, GameData.COL.dark)
	draw_string(f, lp, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, GameData.COL.ink)
	# goldener Glanz läuft einmal durch die Buchstaben
	if t > 1.3 and t < 2.6:
		var lw := f.get_string_size(logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		var x0 := (W / float(sc) - lw) / 2.0
		var sweep := lerpf(x0 - 40.0, x0 + lw + 40.0, (t - 1.3) / 1.3)
		for i in logo.length():
			var cx := x0 + f.get_string_size(logo.substr(0, i), HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
			var hl := clampf(1.0 - absf(cx + 6.0 - sweep) / 22.0, 0.0, 1.0)
			if hl > 0.05:
				draw_string(f, Vector2(cx, lp.y), logo[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(GameData.COL.sun, hl))
	draw_set_transform(off)
	if t > 1.0:
		_text(Vector2(0, 226), "Der NEST ist wieder online.", 8, Color(GameData.COL.mint, clampf((t - 1.0) / 0.6, 0.0, 1.0)), HORIZONTAL_ALIGNMENT_CENTER, W)
	if t < 0.25:
		draw_rect(Rect2(-8, -8, W + 16, H + 16), Color(1, 1, 1, 1.0 - t / 0.25))


# ---------- 8. Abspann: zwei Karten, unten die Ultra-Parade ----------

func _draw_credits() -> void:
	for i in 40:
		var x := fmod(i * 97.3 + 13.0, W)
		var y := H - fmod(anim_t * (10.0 + i % 5 * 3.0) + i * 53.0, H)
		draw_rect(Rect2(roundi(x), roundi(y), 1 if i % 3 else 2, 1 if i % 3 else 2), Color("#B8FFE9", 0.35))
	var half: float = PANELS[idx].dur / 2.0
	var card := 0 if t < half else 1
	var lt := t - card * half
	var a := clampf(minf(lt / 0.6, (half - lt) / 0.6), 0.0, 1.0)
	if card == 0:
		# „Ein Spiel von“ und der Name, der sich aus dem Glitch schärft
		_text(Vector2(0, 76), "Ein Spiel von", 8, Color(GameData.COL.muted, a), HORIZONTAL_ALIGNMENT_CENTER, W)
		var f := font(true, 24)
		var jit := maxf(0.0, 6.0 * (1.0 - lt / 0.8))
		draw_set_transform(off, 0, Vector2(2, 2))
		var lp := Vector2(0, 124 / 2.0)
		if jit > 0.0:
			draw_string(f, lp - Vector2(jit / 2.0, 0), CREATOR, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, Color("#4CC3F0", 0.7 * a))
			draw_string(f, lp + Vector2(jit / 2.0, 0), CREATOR, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, Color("#FF8FD8", 0.7 * a))
		draw_string_outline(f, lp, CREATOR, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, 4, Color(GameData.COL.dark, a))
		draw_string(f, lp, CREATOR, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, Color(GameData.COL.sun, a))
		draw_set_transform(off)
		for i in ROLES.size():
			_text(Vector2(0, 156 + i * 14), ROLES[i], 8, Color(GameData.COL.ink, a), HORIZONTAL_ALIGNMENT_CENTER, W)
	else:
		for i in THANKS.size():
			var y := 66.0 + i * 36.0
			_text(Vector2(0, y), THANKS[i][0], 8, Color(GameData.COL.muted, a), HORIZONTAL_ALIGNMENT_CENTER, W)
			_text(Vector2(0, y + 14), THANKS[i][1], 8, Color(GameData.COL.ink, a), HORIZONTAL_ALIGNMENT_CENTER, W)
	# Parade der Ultras am unteren Rand
	var band := 216.0
	draw_rect(Rect2(0, band, W, 1), Color(GameData.COL.line, 0.6))
	for i in PARADE.size():
		var x := fmod(t * 30.0 + i * 120.0, W + 120.0) - 60.0
		_draw_sprite(PARADE[i], x, H - LB - 2, false, {"phase": i * 1.1})


# ---------- 9. ENDE ----------

func _draw_end() -> void:
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	_sunlight(0.8)
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.55))
	draw_set_transform(off, 0, Vector2(2, 2))
	draw_string_outline(font(true, 24), Vector2(0, 50), "ENDE", HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, 4, GameData.COL.dark)
	draw_string(font(true, 24), Vector2(0, 50), "ENDE", HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, GameData.COL.sun)
	draw_set_transform(off)
	_text(Vector2(0, 128), "Der NEST ist gerettet. Aber noch sind nicht alle Glitchlings gefunden ...", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
	if t > 1.5:
		_text(Vector2(0, 152), "Neu freigeschaltet: Schwierigkeit KORRUMPIERT", 8, GameData.COL.coral, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		_text(Vector2(0, 166), "(in den Optionen: stärkere Gegner, 50 % mehr Fragmente)", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	var mon: String = team_forms[0]
	var st: int = GameData.FORMS.get(mon, {}).get("stage", 1)
	var mx := W / 2.0 - 30.0
	_draw_sprite(mon, mx, 300, false, {"scale": 2 if st == 1 else 1})
	# Ausblick: ein neues Ei taucht auf und wackelt
	if t > 3.6:
		var ea := clampf((t - 3.6) / 0.6, 0.0, 1.0)
		var wob := 0.0
		for w in [4.6, 5.4]:
			if t > w and t < w + 0.4:
				wob = sin((t - w) * 40.0) * 0.2 * (1.0 - (t - w) / 0.4)
		var ep := Vector2(W / 2.0 + 60.0, 300.0)
		draw_circle(ep - Vector2(0, 14), 20.0, Color("#FFF6C8", 0.12 * ea))
		draw_set_transform(off + ep, wob, Vector2.ONE)
		draw_texture(EGG, Vector2(-EGG.get_width() / 2.0, -EGG.get_height()), Color(1, 1, 1, ea))
		draw_set_transform(off)
