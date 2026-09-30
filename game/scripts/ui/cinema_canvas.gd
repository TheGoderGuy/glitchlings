extends PixelCanvas
## Gemeinsame Kino-Werkzeuge für Opening und Ende (30.09.2026): Kinobalken, Vignette, die Welt des NEST
## mit Kamerafahrt, Kern-Turm, Ur-Glitch-Silhouette, Korruption, Zimmer mit Monitor, Ei.

const EGG := preload("res://assets/sprites/egg_s.png")

const TYPE_SPEED := 38.0   # Zeichen pro Sekunde
const FADE := 0.5
const LB := 40.0           # Höhe der Kinobalken
## Kamerafahrt: die vier Zonen nebeneinander, der Kern-Turm ganz rechts
const WORLD := [["wiesen", 0.0], ["vulkan", 640.0], ["sumpf", 1280.0], ["kern", 1920.0]]
const WORLD_CAM_END := 1920.0
const TOWER_X := 2240.0
const GROUND := 268.0
## Bewohner der Welt: [Form, Weltposition x, Skalierung, schwebt]
const RESIDENTS := [
	["Pixmiez", 140.0, 2, false], ["Lumi", 260.0, 2, false], ["Kekso", 380.0, 2, false], ["Funkling", 500.0, 2, false],
	["Buddli", 780.0, 2, false], ["Molchi", 910.0, 2, false], ["Glutbyte", 1070.0, 1, false],
	["Quakli", 1400.0, 2, false], ["Tröpfel", 1520.0, 2, false], ["Maskli", 1650.0, 2, false], ["Pufferling", 1790.0, 1, false],
	["Kauzbit", 2010.0, 2, true], ["Brummbit", 2110.0, 2, false],
]

var shake := 0.0
var eye_px: Array = []  # leuchtende Augenpixel des Ur-Glitch (für die Silhouette)


## Augen des Ur-Glitch aus dem Sprite lesen: helle Pixel im Augenbereich (Blinzel-Box 83,36–91,41)
func _read_eyes() -> void:
	var img: Image = sprite("urglitch").tex.get_image()
	if img.is_compressed():
		img.decompress()
	for y in range(34, 44):
		for x in range(80, 94):
			var c := img.get_pixel(x, y)
			if c.a > 0.5 and c.v > 0.55 and c.s > 0.25:
				eye_px.append(Vector2i(x, y))


## Kinobalken oben und unten (k = 0–1 eingefahren); unten steht die Bildunterschrift, oben der Hinweis zum Überspringen
func _letterbox(k: float, text: String, tt: float) -> void:
	var h := roundf(LB * k)
	draw_rect(Rect2(0, 0, W, h), Color.BLACK)
	draw_rect(Rect2(0, H - h, W, h), Color.BLACK)
	if text != "":
		var shown: String = text.substr(0, clampi(int((tt - 0.4) * TYPE_SPEED), 0, text.length()))
		draw_multiline_string(font(), Vector2(40, H - LB + 16), shown, HORIZONTAL_ALIGNMENT_CENTER, W - 80, tsz(8), 2, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	var hint := "%s: weiter · %s: überspringen" % ([InputSetup.btn("A"), InputSetup.btn("Start")] if InputSetup.pad else ["Enter", "Esc"])
	_text(Vector2(0, 16), hint, 8, Color(GameData.COL.muted, 0.55 * k), HORIZONTAL_ALIGNMENT_RIGHT, W - 10)


## Dunkle Ränder links und rechts (Kino-Look)
func _vignette() -> void:
	for i in 5:
		var w := 10.0 + i * 14.0
		draw_rect(Rect2(0, 0, w, H), Color(0, 0, 0, 0.06))
		draw_rect(Rect2(W - w, 0, w, H), Color(0, 0, 0, 0.06))


static func _smooth(k: float) -> float:
	k = clampf(k, 0.0, 1.0)
	return k * k * (3.0 - 2.0 * k)


# ---------- Die Welt des NEST ----------

## Zeichnet die Welt ab Kameraposition cam; corrupt 0–1 färbt sie rot und zerreißt sie
func _draw_world(cam: float, corrupt: float, silhouette := 0.0, residents := true) -> void:
	cam = roundf(cam)
	for z in WORLD:
		var x: float = z[1] - cam
		if x > -W and x < W:
			draw_texture(zone_texture(z[0]), Vector2(x, 0))
	# weiche Datennebel an den Zonengrenzen
	for s in [640.0, 1280.0, 1920.0]:
		var sx: float = s - cam
		if sx < -60 or sx > W + 60:
			continue
		for i in 12:
			var a := 0.1 * (1.0 - absf(i - 5.5) / 6.0)
			draw_rect(Rect2(sx - 48 + i * 8, 0, 8, H), Color(GameData.COL.dark, a))
		for j in 6:
			var yy := fmod(anim_t * 30.0 + j * 47.0, H)
			draw_rect(Rect2(sx - 1, yy, 2, 6), Color("#6EE7C5", 0.25))
	# Ferne Silhouette des Ur-Glitch hinter dem Turm
	if silhouette > 0.0:
		_draw_urglitch(TOWER_X - cam + 40.0, silhouette, corrupt)
	_draw_tower(TOWER_X - cam, corrupt)
	# Bewohner mit ihren Idle-Animationen
	for r in (RESIDENTS if residents else []):
		var rx: float = r[1] - cam
		if rx < -60 or rx > W + 60:
			continue
		# Schweben und Animation an der Weltposition festmachen, nicht an der Bildschirmposition (sonst zappelt es beim Kameraschwenk)
		var wx: float = r[1]
		var fy := GROUND - (40.0 + roundf(sin(anim_t * 2.0 + wx) * 4.0) if r[3] else 0.0)
		var jit := Vector2.ZERO
		if corrupt > 0.3:
			jit.x = roundf(sin(anim_t * 40.0 + wx) * corrupt * 2.0)   # zittern vor Angst
		_draw_sprite(r[0], rx + jit.x, fy, false, {"scale": r[2], "phase": wx * 0.037})
	# Vordergrund-Parallax: Datenfunken, die schneller vorbeiziehen
	for i in 26:
		var px := fmod(i * 97.0 - cam * 1.35, W + 40.0)
		if px < 0:
			px += W + 40.0
		var py := 80.0 + fmod(i * 53.0, 180.0) + sin(anim_t * 1.5 + i) * 6.0
		var col: Color = [Color("#6EE7C5"), Color("#FFD84D"), Color("#C9B8FF")][i % 3].lerp(Color("#FF5470"), corrupt)
		draw_rect(Rect2(roundi(px - 20), roundi(py), 2, 2), Color(col, 0.55))
	if corrupt > 0.0:
		_corruption(corrupt)


## Der Kern-Turm am Horizont: Leuchtlinien, Leuchtfeuer oben; wird bei Korruption rot und flackert
func _draw_tower(x: float, corrupt: float) -> void:
	if x < -120 or x > W + 120:
		return
	var top := 70.0
	var base := GROUND + 4.0
	var body := Color("#1C1838")
	var edge := Color("#3A2F66")
	var flick := corrupt > 0.2 and fmod(anim_t * 7.0, 1.0) < corrupt * 0.6
	var line_col := Color("#4CC3F0").lerp(Color("#FF5470"), clampf(corrupt * 1.6, 0.0, 1.0))
	if flick:
		line_col = Color("#FFFFFF")
	var pts := PackedVector2Array([Vector2(x - 46, base), Vector2(x - 16, top + 30), Vector2(x - 8, top), Vector2(x + 8, top), Vector2(x + 16, top + 30), Vector2(x + 46, base)])
	draw_colored_polygon(pts, body)
	draw_polyline(pts, edge, 2.0)
	for i in 3:
		var yy := top + 60.0 + i * 50.0
		var hw := 16.0 + (yy - top) * 0.17
		draw_rect(Rect2(roundi(x - hw), roundi(yy), roundi(hw * 2), 3), edge)
		draw_rect(Rect2(roundi(x - hw + 2), roundi(yy + 1), roundi(hw * 2 - 4), 1), Color(line_col, 0.7))
	for lx in [-6.0, 0.0, 6.0]:
		var ly := top + 10.0 + fmod(anim_t * (60.0 + corrupt * 120.0) + lx * 7.0, base - top - 20.0)
		draw_rect(Rect2(roundi(x + lx), roundi(ly), 1, 8), line_col)
		draw_rect(Rect2(roundi(x + lx), top + 10, 1, base - top - 14), Color(line_col, 0.25))
	# Leuchtfeuer
	var pulse := 0.6 + 0.4 * sin(anim_t * (3.0 + corrupt * 12.0))
	draw_circle(Vector2(x, top - 6), 14.0 + 4.0 * pulse, Color(line_col, 0.15))
	draw_circle(Vector2(x, top - 6), 5.0, Color(line_col, 0.9))
	draw_rect(Rect2(x - 1, top - 30, 2, 24), edge)


## Silhouette des Ur-Glitch: steigt hinter dem Turm auf, nur Umriss und glühende Augen
func _draw_urglitch(cx: float, rise: float, corrupt: float) -> void:
	var sc := 3
	var s := sprite("urglitch")
	var feet := H + 16.0 + (1.0 - rise) * 320.0
	var jit := 0.0
	if fmod(anim_t * 3.0, 1.0) < 0.08:
		jit = 4.0
	# roter Umriss (leicht versetzt), darauf der schwarze Körper
	for o in [Vector2(-2, 0), Vector2(2, 0), Vector2(0, -2)]:
		_draw_sprite("urglitch", cx + o.x + jit, feet + o.y, true, {"scale": sc, "flash": true, "mod": Color(1.0, 0.2, 0.35, 0.35 * rise)})
	_draw_sprite("urglitch", cx + jit, feet, true, {"scale": sc, "flash": true, "mod": Color(0.03, 0.01, 0.05, 0.97)})
	# glühende Augen (gespiegelt, da er nach links schaut)
	var size: float = s.n * sc
	var left := roundf(cx + jit - size / 2.0)
	var top_y := roundf(feet - size + s.foot * sc)
	var eye_a := clampf((rise - 0.6) / 0.4, 0.0, 1.0) * (0.75 + 0.25 * sin(anim_t * 6.0))
	for e in eye_px:
		var ex: float = left + (s.n - 1 - e.x) * sc
		var ey: float = top_y + e.y * sc
		draw_rect(Rect2(ex - 2, ey - 2, sc + 4, sc + 4), Color(1.0, 0.2, 0.3, 0.25 * eye_a))
		draw_rect(Rect2(ex, ey, sc, sc), Color(1.0, 0.35, 0.4, eye_a))


## Rote Korruption: Tönung, Glitch-Blöcke, Risslinien
func _corruption(k: float, right := W + 8.0) -> void:
	if right <= -8.0:
		return
	draw_rect(Rect2(-8, -8, right + 8, H + 16), Color(0.55, 0.0, 0.15, 0.28 * k))
	var rng := RandomNumberGenerator.new()
	rng.seed = int(anim_t * 14.0)
	for i in int(k * 34.0):
		var bw := rng.randi_range(4, 40)
		draw_rect(Rect2(rng.randi_range(0, int(minf(right, W)) - bw / 2), rng.randi_range(0, H), bw, rng.randi_range(2, 8)),
			Color("#FF5470", rng.randf_range(0.15, 0.5)) if i % 3 else Color("#4CC3F0", rng.randf_range(0.1, 0.3)))
	for i in int(k * 6.0):
		draw_rect(Rect2(0, rng.randi_range(0, H), minf(right, W), 1), Color(1, 1, 1, 0.25))


# ---------- Zimmer mit Monitor ----------

func _draw_desktop(M: Rect2) -> void:
	draw_rect(M, Color("#1E3A5A"))
	for y in range(int(M.position.y), int(M.end.y), 2):
		draw_rect(Rect2(M.position.x, y, M.size.x, 1), Color(1, 1, 1, 0.03))
	var icons := [Color("#FFD84D"), Color("#58B7FF"), Color("#7BD35A"), Color("#FF8FD8")]
	for i in icons.size():
		var ip := M.position + Vector2(10, 10 + i * 28)
		draw_rect(Rect2(ip, Vector2(14, 12)), icons[i])
		draw_rect(Rect2(ip + Vector2(-2, 15), Vector2(18, 2)), Color(1, 1, 1, 0.35))
	draw_rect(Rect2(M.position.x, M.end.y - 10, M.size.x, 10), Color("#16263E"))
	draw_rect(Rect2(M.position.x + 3, M.end.y - 8, 12, 6), Color("#6EE7C5"))
	draw_rect(Rect2(M.end.x - 30, M.end.y - 7, 26, 4), Color(1, 1, 1, 0.3))


func _cursor(p: Vector2) -> void:
	var rows := [1, 2, 3, 4, 5, 6, 7, 4, 2]
	for i in rows.size():
		draw_rect(Rect2(roundi(p.x) - 1, roundi(p.y) + i - 1, rows[i] + 2, 1), GameData.COL.dark)
	for i in rows.size():
		draw_rect(Rect2(roundi(p.x), roundi(p.y) + i, rows[i], 1), Color.WHITE)


## Ei-Sprite (32 px) skaliert, unten mittig an p, leicht gekippt
func _draw_egg_tex(p: Vector2, sc: int, tilt: float, base: Vector2) -> void:
	draw_set_transform(base + p, tilt, Vector2(sc, sc))
	draw_texture(EGG, Vector2(-EGG.get_width() / 2.0, -EGG.get_height()))
	draw_set_transform(base)
