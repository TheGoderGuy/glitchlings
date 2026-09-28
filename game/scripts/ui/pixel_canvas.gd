class_name PixelCanvas
extends Node2D
## Basis für alle Bildschirme: zeichnet direkt in 640×360 mit der Pixel-Schrift Silkscreen.
## Schriftgrößen nur 8 / 16 / 24 (Silkscreen ist auf ein 8-px-Raster gebaut).

const W := 640
const H := 360

static var _font_r: FontFile
static var _font_b: FontFile

var anim_t := 0.0
var off := Vector2.ZERO


static func font(bold := false) -> FontFile:
	if _font_r == null:
		_font_r = _load_font("res://assets/fonts/Silkscreen-Regular.ttf")
		_font_b = _load_font("res://assets/fonts/Silkscreen-Bold.ttf")
	return _font_b if bold else _font_r


static func _load_font(path: String) -> FontFile:
	var f: FontFile = load(path).duplicate()
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.multichannel_signed_distance_field = false
	return f


static func text_width(s: String, size := 8, bold := false) -> float:
	return font(bold).get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


func _text(pos: Vector2, s: String, size := 8, color: Color = GameData.COL.ink, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0, outline := true, bold := false) -> void:
	var f := font(bold)
	pos = pos.round()
	if outline:
		draw_string_outline(f, pos, s, align, width, size, maxi(2, size / 4), Color(GameData.COL.dark, color.a))
	draw_string(f, pos, s, align, width, size, color)


func _box(r: Rect2, fill: Color, border: Color) -> void:
	draw_rect(r, border)
	draw_rect(r.grow(-1), fill)


func _bar(r: Rect2, k: float, color: Color, back: Color = GameData.COL.dark) -> void:
	draw_rect(r, back)
	var w := floorf((r.size.x - 2) * clampf(k, 0.0, 1.0))
	if w > 0:
		draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(w, r.size.y - 2)), color)


func _draw_background(boss := false) -> void:
	draw_rect(Rect2(0, 0, W, H), GameData.COL.bg2 if boss else GameData.COL.bg)
	var grid := Color(GameData.COL.line, 0.22)
	for x in range(0, W, 32):
		draw_rect(Rect2(x, 0, 1, H), grid)
	for y in range(0, H, 32):
		draw_rect(Rect2(0, y, W, 1), grid)
	# aufsteigende Datenpartikel
	var dust := Color("#FF5470", 0.45) if boss else Color(1, 1, 1, 0.35)
	for i in 18:
		var x := fmod(i * 97.3 + 13.0, W)
		var y := H - fmod(anim_t * 14.0 + i * 53.0, H)
		draw_rect(Rect2(roundi(x), roundi(y), 2, 2), dust)


func _dim() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.72))


## Menüliste; gibt nichts zurück, zeichnet nur. sel = gewählter Eintrag.
func _menu(items: Array, sel: int, center_x: float, y: float, width := 200.0) -> void:
	for i in items.size():
		var r := Rect2(center_x - width / 2, y + i * 22, width, 18)
		var active := i == sel
		_box(r, GameData.COL.panel if active else Color(GameData.COL.bg2, 0.85), GameData.COL.sun if active else GameData.COL.line)
		if active:
			var bx := r.position.x + 6 + (1 if sin(anim_t * 10.0) > 0 else 0)
			_text(Vector2(bx, r.position.y + 13), ">", 8, GameData.COL.sun)
		_text(Vector2(r.position.x, r.position.y + 13), str(items[i]), 8, GameData.COL.ink if active else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


# ---------- Sprites ----------

## Gegner-Sprites; Monster-Formen stehen in GameData.FORMS
const SPRITE_FILES := {"bug": "bug_64", "moth": "moth_64", "spam": "spam_64", "boss": "boss_96",
	"captcha": "captcha_64", "wespe": "wespe_64", "raupe": "raupe_64"}
static var _sprites := {}


## Lädt ein Sprite samt Blinzel-Frame und weißer Treffer-Silhouette (einmalig, dann aus dem Cache).
static func sprite(key: String) -> Dictionary:
	if _sprites.has(key):
		return _sprites[key]
	var file: String = SPRITE_FILES[key] if SPRITE_FILES.has(key) else GameData.FORMS[key].spr
	var tex: Texture2D = load("res://assets/sprites/%s.png" % file)
	var blink_path := "res://assets/sprites/%s_blink.png" % file
	var blink: Texture2D = load(blink_path) if ResourceLoader.exists(blink_path) else tex
	var img := tex.get_image()
	if img.is_compressed():
		img.decompress()
	# Transparente Zeilen unter den Füßen zählen, damit das Monster auf der Plattform steht
	var foot := 0
	for y in range(img.get_height() - 1, -1, -1):
		var empty := true
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.1:
				empty = false
				break
		if not empty:
			break
		foot += 1
	var white: Image = img.duplicate()
	for y in white.get_height():
		for x in white.get_width():
			var a := white.get_pixel(x, y).a
			if a > 0.0:
				white.set_pixel(x, y, Color(1, 1, 1, a))
	var s := {"tex": tex, "blink": blink, "flash": ImageTexture.create_from_image(white), "n": img.get_width(), "foot": foot}
	_sprites[key] = s
	return s


## Spieler-Babys (32 px) werden verdoppelt, ab Rookie 1 Kunstpixel = 1 Pixel.
func _draw_sprite(key: String, cx: float, feet_y: float, flip: bool, opts := {}) -> void:
	var s := sprite(key)
	var sc: int = opts.get("scale", 2 if s.n <= 32 else 1)
	var size: int = s.n * sc
	var top := roundi(feet_y - size + s.foot * sc - opts.get("bob", 0))
	var left := roundi(cx - size / 2.0)
	var tex: Texture2D = s.flash if opts.get("flash", false) else (s.blink if opts.get("blink", false) else s.tex)
	var mod: Color = opts.get("mod", Color.WHITE)
	if flip:
		draw_set_transform(off + Vector2(left + size, top), 0, Vector2(-sc, sc))
	else:
		draw_set_transform(off + Vector2(left, top), 0, Vector2(sc, sc))
	draw_texture(tex, Vector2.ZERO, mod)
	draw_set_transform(off)


## Deckliste, gruppiert: „3× Pixelstrahl … Angriff“
func _draw_deck_list(deck: Array, x: float, y: float, w: float, max_rows := 14) -> void:
	var counts := {}
	for k in deck:
		counts[k] = counts.get(k, 0) + 1
	var row := 0
	for k in counts:
		if row >= max_rows:
			_text(Vector2(x + 14, y), "…", 8, GameData.COL.muted)
			return
		var el: Color = GameData.EL[GameData.CHIPS[k].el]
		draw_rect(Rect2(x, y - 7, 7, 7), el)
		_text(Vector2(x + 14, y), "%d× %s" % [counts[k], k], 8)
		_text(Vector2(x + 14, y), GameData.CHIPS[k].cat, 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_RIGHT, w - 14)
		y += 14
		row += 1
