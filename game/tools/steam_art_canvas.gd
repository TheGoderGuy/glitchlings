extends PixelCanvas
## Zeichenfläche für die Steam-Bilder (siehe steam_art.gd). Alles in Basis-Pixeln, ohne Kantenglättung.

const EGG128 := preload("res://assets/logo/digiei_128.png")
const EGG64 := preload("res://assets/logo/digiei_64.png")
const EGG32 := preload("res://assets/logo/digiei_32.png")
const TEAL := Color("#26E0F3")
const SKY_TOP := Color("#08071a")
const SKY_LOW := Color("#241c52")
const FLOOR := Color("#110d29")

var kind := "header"
var aw := 460
var ah := 215


func _ready() -> void:
	# Texturen vorher laden (erst in _draw geladen bleiben sie im ersten Bild weiß)
	PixelCanvas.preload_all()
	queue_redraw()


func _process(_d: float) -> void:
	pass   # Standbild: keine Animation


func _draw() -> void:
	match kind:
		"header": _header()
		"small": _small()
		"main": _main()
		"vertical": _vertical()
		"libcap": _libcap()
		"hero": _hero()
		"logo": _logo()
		"icon": _icon()


# --- Layouts ---------------------------------------------------------------

func _header() -> void:
	_bg(160)
	_glow(Vector2(230, 150), 120)
	_mon("Hydrolutra", 128, 172, false, 1, 0.62)
	_mon("Fulgurlutra", 332, 172, true, 1, 0.62)
	_mon("Pyromeles", 50, 190, false, 1, 0.85)
	_mon("Heliopsitta", 410, 190, true, 1, 0.85)
	_egg(EGG128, 230, 208)
	_mon("Pixmiez", 150, 212, false, 2)
	_mon("Bachli", 312, 212, true, 2)
	_word(230, 14, 24, 2)


func _small() -> void:
	# Schriftzug füllt fast die ganze Breite (207 von 231), das Ei steht darüber
	_bg(87, false)
	_glow(Vector2(115, 34), 44)
	draw_texture(EGG32, Vector2(100, 17))
	_word(115.5, 42, 24, 1, false)


func _main() -> void:
	_bg(262)
	_glow(Vector2(308, 236), 175)
	_mon("Pyromeles", 140, 270, false, 2, 0.55)
	_mon("Hydrolutra", 476, 270, true, 2, 0.55)
	_egg(EGG128, 308, 336)
	_mon("Tröpfel", 118, 346, false, 2)
	_mon("Pixmiez", 206, 344, false, 2)
	_mon("Bachli", 410, 344, true, 2)
	_mon("Plapperli", 498, 346, true, 2)
	_word(308, 22, 24, 2)


func _vertical() -> void:
	_bg(332)
	_glow(Vector2(187, 300), 160)
	_mon("Pyromeles", 104, 340, false, 2, 0.55)
	_mon("Hydrolutra", 270, 340, true, 2, 0.55)
	_egg(EGG128, 187, 404)
	_mon("Pixmiez", 82, 436, false, 2)
	_mon("Plapperli", 292, 436, true, 2)
	_word(187, 62, 16, 2)


func _libcap() -> void:
	_bg(332)
	_glow(Vector2(150, 300), 140)
	_mon("Fulgurlutra", 84, 340, false, 2, 0.55)
	_mon("Heliopsitta", 216, 340, true, 2, 0.55)
	_egg(EGG128, 150, 404)
	_mon("Bachli", 62, 438, false, 2)
	_mon("Pixmiez", 238, 438, true, 2)
	_word(150, 30, 16, 2)


func _hero() -> void:
	# Ohne Text. Sicherer Bereich: 215 × 95 Basis-Pixel in der Mitte (das Ei steht darin)
	_bg(196)
	_glow(Vector2(480, 175), 190)
	var back := [["Hydrocyon", 300, false], ["Fulgopsitta", 660, true], ["Virocyon", 150, false], ["Voltameles", 810, true]]
	for m in back:
		_mon(m[0], m[1], 214, m[2], 1, 0.5)
	_mon("Pyromeles", 230, 246, false, 1, 0.8)
	_mon("Hydrolutra", 370, 238, false, 1, 0.8)
	_mon("Fulgurlutra", 590, 238, true, 1, 0.8)
	_mon("Heliopsitta", 730, 246, true, 1, 0.8)
	_mon("Hyperwulf", 70, 262, false, 1, 0.9)
	_mon("Aurorlynx", 890, 262, true, 1, 0.9)
	_egg(EGG128, 480, 204)
	_mon("Tröpfel", 330, 300, false, 2)
	_mon("Pixmiez", 410, 300, false, 2)
	_mon("Bachli", 550, 300, true, 2)
	_mon("Plapperli", 630, 300, true, 2)


func _logo() -> void:
	# Ei (sichtbar 90 px breit) + 8 px + Schriftzug (2 × 207), zusammen mittig in 640 × 96
	draw_texture(EGG128, Vector2(47, -18))
	_word(369, 13, 24, 2, false)


func _icon() -> void:
	draw_rect(Rect2(0, 0, aw, ah), SKY_TOP)
	_glow(Vector2(46, 48), 46)
	draw_texture(EGG64, Vector2(14, 15))


# --- Bausteine -------------------------------------------------------------

## Himmel in Stufen mit Dither-Kanten, Datenpartikel, Boden mit Fluchtpunkt-Raster
func _bg(hz: int, with_floor := true) -> void:
	var bands := 7
	var bh := float(hz) / bands
	for b in bands:
		var col := SKY_TOP.lerp(SKY_LOW, float(b) / (bands - 1))
		var y0 := roundi(b * bh)
		draw_rect(Rect2(0, y0, aw, roundi((b + 1) * bh) - y0 + 1), col)
		if b > 0:
			var prev := SKY_TOP.lerp(SKY_LOW, float(b - 1) / (bands - 1))
			for x in range(0, aw, 2):
				draw_rect(Rect2(x, y0, 1, 1), prev)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in int(aw * hz / 700.0):
		var p := Vector2(rng.randi_range(0, aw - 1), rng.randi_range(0, hz - 4))
		var c: Color = [Color(1, 1, 1, 0.55), Color(TEAL, 0.7), Color("#FF5470", 0.6), Color("#FDE07B", 0.6)][rng.randi_range(0, 3)]
		var s := 2 if rng.randf() < 0.25 else 1
		draw_rect(Rect2(p, Vector2(s, s)), c)
	if not with_floor:
		return
	draw_rect(Rect2(0, hz, aw, ah - hz), FLOOR)
	var grid := Color(TEAL, 0.22)
	var d := 2.0
	var y := float(hz)
	while y < ah:
		draw_rect(Rect2(0, roundi(y), aw, 1), grid)
		y += d
		d *= 1.45
	var vx := aw / 2.0
	for i in range(-24, 25):
		draw_line(Vector2(vx + i * aw / 48.0, hz), Vector2(vx + i * aw / 7.0, ah), grid)
	draw_rect(Rect2(0, hz, aw, 1), Color(TEAL, 0.55))


## Weiches Leuchten aus gestuften Kreisen
func _glow(c: Vector2, r: float) -> void:
	for i in 7:
		draw_circle(c, r * (1.0 - i / 7.0), Color(TEAL, 0.045))


## Monster mit Schatten; dim < 1 dunkelt ab (weiter hinten)
func _mon(form: String, x: float, feet: float, flip: bool, sc := 1, dim := 1.0) -> void:
	var n: int = sprite(form).n * sc
	draw_set_transform(Vector2(x, feet), 0, Vector2(1, 0.28))
	draw_circle(Vector2.ZERO, n * 0.34, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO)
	_draw_sprite(form, x, feet, flip, {"anim": false, "scale": sc, "mod": Color(dim, dim, dim * 1.08 if dim < 1 else 1.0)})


## Logo-Ei: Unterkante des Eis (Zeile 110 im 128er-Bild) auf bottom, mit Leuchtring am Boden
func _egg(tex: Texture2D, cx: float, bottom: float) -> void:
	draw_set_transform(Vector2(cx, bottom), 0, Vector2(1, 0.28))
	draw_circle(Vector2.ZERO, 54, Color(TEAL, 0.18))
	draw_circle(Vector2.ZERO, 40, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO)
	draw_texture(tex, Vector2(roundi(cx - 64), roundi(bottom - 111)))


## Schriftzug GLITCHLINGS: dunkle Kontur, Cyan links, Magenta rechts, helle Schrift; gibt die Breite zurück
func _word(cx: float, top: float, size: int, sc: int, shadow := true) -> float:
	var f := font(true, size)
	var s := "GLITCHLINGS"
	var tw := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_set_transform(Vector2(roundi(cx - tw * sc / 2.0), top), 0, Vector2(sc, sc))
	var p := Vector2(0, roundi(f.get_ascent(size)))
	if shadow:
		draw_string_outline(f, p + Vector2(0, 2), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, Color(0, 0, 0, 0.55))
	draw_string_outline(f, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, GameData.COL.dark)
	draw_string(f, p + Vector2(-1, 0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("#4CC3F0"))
	draw_string(f, p + Vector2(1, 0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("#FF5470"))
	draw_string(f, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, GameData.COL.ink)
	draw_set_transform(Vector2.ZERO)
	return tw * sc
