extends "res://scripts/ui/cinema_canvas.gd"
## Kino-Intro beim neuen Spiel (30.09.2026, vorher 5 Bilder): Kaltstart, Kamerafahrt über den NEST,
## der Ur-Glitch erwacht als Silhouette, Absturz, Flucht der Glitchlings, Title Drop, Gewitternacht, das Ei.
## Kinobalken, Kamerafahrt mit Parallax, Bildrisse; Musik "opening" läuft taktgenau zu den Bildern (96 BPM).
## Bestätigen = Text sofort zeigen bzw. weiter, Esc/Start = überspringen.

signal finished

## Bilder: Dauer, Bildunterschrift, weiches Ein-/Ausblenden
const PANELS := [
	{"id": "boot", "dur": 6.0, "text": "", "fade_in": false, "fade_out": false},
	{"id": "world", "dur": 10.0, "text": "Tief im Netz lag der NEST: eine Welt voller kleiner digitaler Wesen, der Glitchlings.", "fade_in": true, "fade_out": false},
	{"id": "corrupt", "dur": 7.5, "text": "Doch im Kern erwachte ein Fehler. Er kopierte sich wieder und wieder ...", "fade_in": false, "fade_out": false},
	{"id": "crash", "dur": 2.5, "text": "", "fade_in": false, "fade_out": false},
	{"id": "flight", "dur": 7.5, "text": "Die Glitchlings flohen in alle Geräte, die sie finden konnten. Zurück blieben wilde, korrupte Daten.", "fade_in": true, "fade_out": true},
	{"id": "title", "dur": 5.0, "text": "", "fade_in": false, "fade_out": true},
	{"id": "room", "dur": 8.5, "text": "In einer stürmischen Nacht landet etwas auf deinem Desktop ...", "fade_in": true, "fade_out": true},
	{"id": "egg", "dur": 9.0, "text": "Du bist jetzt Operator. Zieh die Glitchlings auf, trainiere sie und bring den NEST zurück ins Netz.", "fade_in": true, "fade_out": false},
]
const BOOT_LINES := ["NEST-Server v3.1 ... online", "Zonen: Cache-Wiesen, Firewall-Vulkan, Viren-Sümpfe, NEST-Kern", "Bewohner: 4.096 Glitchlings", "Status: alles friedlich"]
const BOOT_TYPE_START := 1.5
const FLEE := ["Pixmiez", "Funkling", "Tröpfel", "Kekso", "Lumi", "Quakli", "Molchi", "Brummbit"]

var idx := 0
var t := 0.0            # Zeit im aktuellen Bild
var done := false
var played := {}        # Sounds, die in diesem Bild schon gespielt wurden


func _ready() -> void:
	Music.stop()
	_read_eyes()


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
		if p.text != "" and t < full:
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
	if p.id == "boot":
		var n := 0
		for l in BOOT_LINES:
			n += T.t(l).length()
		return BOOT_TYPE_START + n / TYPE_SPEED
	return 0.4 + T.t(p.text).length() / TYPE_SPEED


## Position eines Bildes im Stück "opening" (Welt beginnt bei 0 s)
func _music_pos(i: int) -> float:
	var pos := 0.0
	for j in range(1, i):
		pos += PANELS[j].dur
	return pos


func _next() -> void:
	idx += 1
	t = 0.0
	played.clear()
	if idx >= PANELS.size():
		_finish()
		return
	match PANELS[idx].id:
		"world":
			Music.play("opening")
		"corrupt", "crash", "flight", "title":
			# weitergeblättert: Musik an die passende Stelle setzen
			if Music.current == "opening":
				Music.seek(_music_pos(idx))
		"room":
			Music.play("intro")


func _finish() -> void:
	done = true
	set_process(false)
	if Music.current != "intro":
		Music.play("intro")   # läuft in der Starterwahl weiter
	finished.emit()


## Einmalige Geräusche an bestimmten Stellen
func _sounds(id: String) -> void:
	var cues := {
		"boot": [[1.9, "tick"], [2.6, "tick"], [3.5, "tick"], [4.3, "tick"], [4.9, "confirm"]],
		"corrupt": [[1.6, "warn"], [2.2, "warn"], [3.0, "shift"], [3.4, "charge"], [5.8, "shift"]],
		"crash": [[0.02, "hit_big"], [0.9, "lose"]],
		"title": [[0.0, "hit_big"], [0.05, "special"]],
		"room": [[1.0, "hit_big"], [3.9, "pop"]],
		"egg": [[0.6, "tick"], [0.8, "tick"], [1.8, "tick"], [2.0, "tick"], [2.5, "hit"], [4.0, "hit"], [5.5, "charge"]],
	}
	var list: Array = cues.get(id, [])
	if id == "flight":
		for i in FLEE.size():
			list.append([0.9 + i * 0.22, "dodge"])
	for c in list:
		if t >= c[0] and not played.has(c[1] + str(c[0])):
			played[c[1] + str(c[0])] = true
			Sfx.play(c[1], 0.0)
			if (id == "crash" or id == "title") and c[1] == "hit_big":
				shake = 8.0


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
		"world":
			_draw_world(_smooth(t / p.dur) * WORLD_CAM_END, 0.0)
		"corrupt":
			_draw_corrupt()
		"crash":
			_draw_crash()
		"flight":
			_draw_flight()
		"title":
			_draw_title()
		"room":
			_draw_room()
		"egg":
			_draw_egg()
	draw_set_transform(Vector2.ZERO)
	if p.id in ["world", "corrupt", "flight", "room"]:
		_vignette()
	# Ein- und Ausblenden
	var a := 0.0
	if p.fade_in and t < FADE:
		a = 1.0 - t / FADE
	elif p.fade_out and t > p.dur - FADE:
		a = (t - (p.dur - FADE)) / FADE
	if a > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, clampf(a, 0.0, 1.0)))
	_letterbox(_smooth(t / 1.2) if p.id == "boot" else 1.0, p.text, t)
	# Weißblende am Ende: das Ei bricht auf, die Starterwahl blendet aus dem Weiß ein
	if p.id == "egg" and t > p.dur - 1.2:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, clampf((t - (p.dur - 1.2)) / 1.0, 0.0, 1.0)))



# ---------- 1. Kaltstart: Cursor im Dunkeln, der NEST fährt hoch ----------

func _draw_boot() -> void:
	var green := Color("#6EE7C5")
	var x := 120.0
	var y := 132.0
	var budget := int(maxf(0.0, t - BOOT_TYPE_START) * TYPE_SPEED)
	if t >= BOOT_TYPE_START:
		for l0 in BOOT_LINES:
			var l := T.t(l0)
			var s: String = l.substr(0, clampi(budget, 0, l.length()))
			budget -= l.length()
			_text(Vector2(x, y), "> " + s, 8, green, HORIZONTAL_ALIGNMENT_LEFT, -1, false)
			if budget < 0:
				break
			y += 18
	if fmod(anim_t, 0.8) < 0.4 and t > 0.4:
		draw_rect(Rect2(x + (0 if t < BOOT_TYPE_START else 2), y - 8 + (0 if budget < 0 else 18), 6, 9), green)
	# ruhige Scanlines
	for sy in range(0, H, 3):
		draw_rect(Rect2(0, sy, W, 1), Color(0, 0, 0, 0.2))


# ---------- 3. Der Fehler erwacht ----------

func _draw_corrupt() -> void:
	var k := clampf((t - 1.2) / 4.5, 0.0, 1.0)
	var rise := _smooth((t - 2.2) / 2.6)
	shake = maxf(shake, k * 1.5)
	_draw_world(WORLD_CAM_END, k, rise)


# ---------- 4. Absturz: Weißblitz, Risse, der Bildschirm geht aus ----------

func _draw_crash() -> void:
	if t < 0.14:
		draw_rect(Rect2(-8, -8, W + 16, H + 16), Color.WHITE)
		return
	if t < 1.3:
		var rng := RandomNumberGenerator.new()
		rng.seed = int(anim_t * 20.0)
		for i in 22:
			draw_rect(Rect2(rng.randi_range(-40, 40), rng.randi_range(0, H), W, rng.randi_range(1, 7)), Color("#4CC3F0", 0.35) if i % 2 else Color("#FF5470", 0.4))
		for i in 70:
			draw_rect(Rect2(rng.randi_range(0, W), rng.randi_range(0, H), rng.randi_range(2, 12), rng.randi_range(2, 6)), Color(1, 1, 1, rng.randf_range(0.1, 0.5)))
		var big := "SYSTEMABSTURZ"
		var jit := Vector2(rng.randi_range(-4, 4), 0)
		draw_set_transform(off, 0, Vector2(2, 2))
		var lp := Vector2(0, 150 / 2.0)
		draw_string(font(true, 16), lp + jit * 0.5 + Vector2(-1, 0), big, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 16, Color("#4CC3F0", 0.8))
		draw_string(font(true, 16), lp - jit * 0.5 + Vector2(1, 0), big, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 16, Color("#FF5470", 0.8))
		draw_string(font(true, 16), lp, big, HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 16, Color.WHITE)
		draw_set_transform(off)
		return
	# Röhrenmonitor geht aus: Bild schrumpft zu einer Linie, dann zu einem Punkt
	var k := (t - 1.3) / 0.7
	if k < 1.0:
		var hgt := maxf(1.0, 60.0 * (1.0 - clampf(k * 2.0, 0.0, 1.0)))
		var wid := W * (1.0 - clampf((k - 0.5) * 2.0, 0.0, 1.0))
		draw_rect(Rect2(W / 2.0 - wid / 2.0, H / 2.0 - hgt / 2.0, wid, hgt), Color(0.9, 0.95, 1.0, 0.95))
	elif t < 2.2:
		draw_circle(Vector2(W / 2.0, H / 2.0), 2.0, Color(1, 1, 1, 1.0 - (t - 2.0) / 0.2))


# ---------- 5. Flucht: Lichtspuren in alle Richtungen, korrupte Daten bleiben ----------

func _draw_flight() -> void:
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	_corruption(0.55)
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.35))
	var center := Vector2(W / 2.0, 200.0)
	var cols := [Color("#6EE7C5"), Color("#FF8A4C"), Color("#4CC3F0"), Color("#FFD84D"), Color("#C9B8FF"), Color("#FF8FD8"), Color("#7BD35A"), Color("#D8A060")]
	for i in FLEE.size():
		var ang := -PI * 0.95 + i * (PI * 1.9 / (FLEE.size() - 1))
		var dir := Vector2(cos(ang), sin(ang) * 0.6)
		var home := center + dir * 70.0 + Vector2(0, 30)
		var appear := clampf((t - 0.2) / 0.5, 0.0, 1.0)
		var start := 0.9 + i * 0.22
		var k := clampf((t - start) / 0.7, 0.0, 1.0)
		var pos := home + dir * 620.0 * k * k
		if k < 0.25:
			_draw_sprite(FLEE[i], pos.x, pos.y, dir.x < 0, {"scale": 2, "phase": i * 1.7, "mod": Color(1, 1, 1, appear * (1.0 - k * 4.0))})
		if k > 0.0 and k < 1.0:
			# Lichtspur: Kopf hell, Schweif verblasst
			var col: Color = cols[i]
			var tail := minf(1.0, k * 4.0)
			for j in 40:
				var tp := pos - dir * (j * 3.0) * tail - Vector2(0, 14)
				var fade := 1.0 - j / 40.0
				draw_rect(Rect2(roundi(tp.x) - 2, roundi(tp.y) - 2, 5, 5), Color(col, fade * 0.25))
				draw_rect(Rect2(roundi(tp.x) - 1, roundi(tp.y) - 1, 3, 3), Color(col, fade * 0.9))
			draw_circle(pos - Vector2(0, 14), 9.0, Color(col, 0.3))
			draw_circle(pos - Vector2(0, 14), 5.0, Color(col, 0.6))
			draw_rect(Rect2(roundi(pos.x) - 2, roundi(pos.y) - 16, 5, 5), Color.WHITE)
	# korrupte Daten tauchen auf, sobald die Glitchlings weg sind
	var foes := [["bug", 150.0], ["wurm", 300.0], ["moth", 450.0], ["spinne", 560.0]]
	for i in foes.size():
		var fa := clampf((t - 3.4 - i * 0.35) / 0.8, 0.0, 1.0)
		if fa <= 0.0:
			continue
		var glitch := fmod(anim_t * 1.7 + i * 0.6, 2.0) < 0.12 or (fa < 1.0 and fmod(anim_t * 20.0, 1.0) < 0.5)
		_draw_sprite(foes[i][0], foes[i][1] + (4.0 if glitch else 0.0), GROUND + i % 2 * 8, true, {"mod": Color(1.0, 0.72, 0.8, fa * (0.95 if not glitch else 0.5))})


# ---------- 6. Title Drop ----------

func _draw_title() -> void:
	var f := font(true, 24)
	var logo := "GLITCHLINGS"
	var sc := 3 if t < 0.07 else 2
	var jit := maxf(0.0, 6.0 * (1.0 - t / 0.6))
	if fmod(anim_t * 0.7, 1.0) < 0.05 and t > 1.0:
		jit = 3.0
	# Schockwelle und Funken
	if t < 1.2:
		var r := 20.0 + t * 520.0
		draw_arc(Vector2(W / 2.0, 176.0), r, 0, TAU, 64, Color(1, 1, 1, 0.5 * (1.0 - t / 1.2)), 2.0)
		draw_arc(Vector2(W / 2.0, 176.0), r * 0.7, 0, TAU, 64, Color("#FF5470", 0.35 * (1.0 - t / 1.2)), 1.0)
		for i in 40:
			var a := i * 2.399
			var d := t * (180.0 + (i * 37) % 160)
			var sp := Vector2(W / 2.0, 170.0) + Vector2(cos(a), sin(a) * 0.6) * d
			draw_rect(Rect2(roundi(sp.x), roundi(sp.y), 2, 2), Color([Color("#6EE7C5"), Color("#FFD84D"), Color("#FF5470")][i % 3], 1.0 - t / 1.2))
	var base_y := 196.0
	draw_set_transform(off, 0, Vector2(sc, sc))
	var lp := Vector2(0, base_y / sc)
	var j := Vector2(roundf(jit / sc), 0)
	draw_string(f, lp - j, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, Color("#4CC3F0", 0.8))
	draw_string(f, lp + j, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, Color("#FF5470", 0.8))
	draw_string_outline(f, lp, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, 4, GameData.COL.dark)
	draw_string(f, lp, logo, HORIZONTAL_ALIGNMENT_CENTER, W / float(sc), 24, GameData.COL.ink)
	draw_set_transform(off)
	if t > 1.0:
		_text(Vector2(0, 226), "Brüten. Fusionieren. Prägen.", 8, Color(GameData.COL.mint, clampf((t - 1.0) / 0.6, 0.0, 1.0)), HORIZONTAL_ALIGNMENT_CENTER, W)
	# ein roter Riss läuft einmal über das Logo: der Fehler ist noch da
	if t > 3.4 and t < 3.9:
		var ry := 150.0 + (t - 3.4) * 120.0
		draw_rect(Rect2(0, ry, W, 2), Color("#FF5470", 0.7))
		draw_rect(Rect2(0, ry + 3, W, 1), Color("#4CC3F0", 0.5))
	# Weißblitz beim Aufschlag
	if t < 0.25:
		draw_rect(Rect2(-8, -8, W + 16, H + 16), Color(1, 1, 1, 1.0 - t / 0.25))


# ---------- 7. Gewitternacht: ein Ei fällt auf deinen Desktop ----------

func _draw_room() -> void:
	# langsame Kamerafahrt von rechts nach links
	var drift := roundf(lerpf(10.0, -10.0, t / PANELS[idx].dur))
	draw_set_transform(off + Vector2(drift, 0))
	var lightning := 0.0
	if t > 0.9 and t < 1.05:
		lightning = 1.0
	elif t > 1.15 and t < 1.25:
		lightning = 0.6
	draw_rect(Rect2(-20, 0, W + 40, H), Color("#0E0A1E"))
	# Fenster mit Regen und Blitz
	draw_rect(Rect2(60, 50, 120, 90), Color("#2A2446"))
	draw_rect(Rect2(64, 54, 112, 82), Color("#141030").lerp(Color("#C9D4FF"), lightning * 0.8))
	if lightning > 0.5:
		var bolt := [Vector2(140, 54), Vector2(132, 78), Vector2(142, 84), Vector2(128, 112), Vector2(136, 116), Vector2(124, 136)]
		for i in bolt.size() - 1:
			draw_line(bolt[i], bolt[i + 1], Color.WHITE, 2.0)
	for i in 34:
		var rx := 64.0 + fmod(i * 29.0 + anim_t * 40.0, 112.0)
		var ry := 54.0 + fmod(i * 17.0 + anim_t * 260.0, 78.0)
		# schräge Regenstriche als Pixel (1-px-Linien verschwinden bei der pixelgenauen Darstellung)
		draw_rect(Rect2(roundi(rx), roundi(ry), 1, 2), Color("#8FB8FF", 0.55))
		draw_rect(Rect2(roundi(rx) - 1, roundi(ry) + 2, 1, 2), Color("#8FB8FF", 0.35))
	draw_rect(Rect2(119, 54, 2, 82), Color("#2A2446"))
	draw_rect(Rect2(64, 94, 112, 2), Color("#2A2446"))
	# Tisch
	draw_rect(Rect2(-20, 262, W + 40, 98), Color("#1A1430"))
	draw_rect(Rect2(-20, 262, W + 40, 3), Color("#3A2F5E"))
	draw_rect(Rect2(250, 265, 260, 10), Color("#4CC3F0", 0.08))
	# Monitor
	var M := Rect2(260, 70, 240, 160)
	draw_rect(M.grow(8), Color("#2C2352"))
	draw_rect(M.grow(8).grow(-1), Color("#3A2F66"))
	draw_rect(Rect2(362, 238, 36, 16), Color("#2C2352"))
	draw_rect(Rect2(336, 254, 88, 8), Color("#3A2F66"))
	_draw_desktop(M)
	# Ei fällt aus einem Datenspalt oben auf den Desktop
	var land := 3.9
	var ex := M.get_center().x + 30
	var floor_y := M.end.y - 22
	if t > 2.6:
		var k := clampf((t - 2.6) / (land - 2.6), 0.0, 1.0)
		var ey := M.position.y + 10 + (floor_y - M.position.y - 10) * k * k
		if t < land + 0.2:
			draw_rect(Rect2(ex - 14, M.position.y + 4, 28, 3), Color("#FF5470", 0.8))
			for j in 5:
				draw_rect(Rect2(ex - 10 + j * 5, M.position.y + 8 + fmod(anim_t * 60.0 + j * 13.0, 30.0), 2, 2), Color("#6EE7C5", 0.6))
		var bounce := 0.0
		if t > land:
			bounce = absf(sin((t - land) * 9.0)) * 6.0 * maxf(0.0, 1.0 - (t - land) * 1.5)
		var wob := sin(anim_t * 6.0) * 0.12 if t > land + 1.0 else 0.0
		_draw_egg_tex(Vector2(ex, ey - bounce), 1, wob, off + Vector2(drift, 0))
	# Mauszeiger wandert hin
	var ck := clampf((t - 5.0) / 2.0, 0.0, 1.0)
	var cp := Vector2(M.position.x + 40, M.end.y - 40).lerp(Vector2(ex + 10, floor_y - 12), ck * ck * (3.0 - 2.0 * ck))
	_cursor(cp)
	# Blitz erhellt das ganze Zimmer
	if lightning > 0.0:
		draw_rect(Rect2(-20, 0, W + 40, H), Color(0.8, 0.85, 1.0, 0.3 * lightning))
	draw_set_transform(off)


# ---------- 8. Das Ei: Herzschlag, Risse, Licht ----------

func _draw_egg() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#1E3A5A"))
	for y in range(0, H, 2):
		draw_rect(Rect2(0, y, W, 1), Color(1, 1, 1, 0.03))
	var c := Vector2(W / 2.0, 214.0)
	var glow := clampf((t - 2.0) / 5.0, 0.0, 1.0)
	# Herzschlag: doppelter Puls, wird schneller
	var beat := 0.0
	for b in [0.6, 0.8, 1.8, 2.0, 3.0, 3.2, 3.9, 4.1, 4.8, 5.0, 5.6, 5.8]:
		if t > b:
			beat = maxf(beat, 1.0 - (t - b) / 0.25)
	for i in 10:
		var a := i * TAU / 10.0 + anim_t * 0.25
		var d := Vector2(cos(a), sin(a))
		var n := Vector2(-d.y, d.x)
		var pts := PackedVector2Array([c - Vector2(0, 40), c - Vector2(0, 40) + d * 400.0 + n * 30.0, c - Vector2(0, 40) + d * 400.0 - n * 30.0])
		draw_colored_polygon(pts, Color("#FFF6C8", 0.04 + 0.1 * glow))
	draw_circle(c - Vector2(0, 40), 58.0 + 14.0 * beat + 6.0 * sin(anim_t * 3.0), Color("#FFF6C8", 0.06 + 0.12 * glow + 0.1 * beat))
	var shake_amt := 0.0
	for s in [2.5, 4.0, 5.5]:
		if t > s and t < s + 0.5:
			shake_amt = 0.25 * (1.0 - (t - s) / 0.5)
	var wob := sin(anim_t * 30.0) * shake_amt
	_draw_egg_tex(c, 4, wob, off)
	var cracks := [[2.5, [Vector2(-6, -70), Vector2(-2, -62), Vector2(-8, -54), Vector2(-3, -46)]],
		[4.0, [Vector2(4, -80), Vector2(10, -70), Vector2(5, -62), Vector2(12, -52)]],
		[5.5, [Vector2(-3, -46), Vector2(4, -40), Vector2(-2, -32), Vector2(6, -26)]]]
	for cr in cracks:
		if t > cr[0]:
			var pts: Array = cr[1]
			for i in pts.size() - 1:
				draw_line(c + pts[i], c + pts[i + 1], GameData.COL.dark, 3.0)
				draw_line(c + pts[i], c + pts[i + 1], Color("#FFF6C8", maxf(glow, beat)), 1.0)

