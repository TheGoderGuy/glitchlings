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
	"captcha": "captcha_64", "wespe": "wespe_64", "raupe": "raupe_64",
	"milbe": "milbe_64", "assel": "assel_64", "falter": "falter_64", "skarab": "skarab_96",
	"muecke": "muecke_64", "schnecke": "schnecke_64", "bluete": "bluete_64", "koenigin": "koenigin_96"}
static var _sprites := {}


## Alle Sprites beim Spielstart laden: Texturen, die erst in _draw() zum ersten Mal geladen werden, bleiben in dem Bild weiß.
static func preload_all() -> void:
	for k in SPRITE_FILES:
		sprite(k)
	for f in GameData.FORMS:
		sprite(f)


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


## Evolutionsstand: je mögliche Richtung ein Balken (Form nur, wenn schon im Dex), Elemente ohne Wirkung, Status.
## Gibt die benutzte Höhe zurück.
func _draw_evo(s: Dictionary, x: float, y: float, w: float) -> float:
	var y0 := y
	if int(s.need) == 0:
		_text(Vector2(x, y + 8), "Höchste Stufe erreicht", 8, GameData.COL.muted)
		return 12.0
	_text(Vector2(x, y + 8), "Element-Chips", 8, GameData.COL.muted)
	_text(Vector2(x, y + 8), "%d/%d" % [mini(int(s.total), int(s.need)), int(s.need)], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, w)
	_bar(Rect2(x, y + 11, w, 4), float(s.total) / maxf(1.0, s.need), GameData.COL.mint)
	y += 20
	var maxn := 1
	for d in s.dirs:
		maxn = maxi(maxn, int(d.n))
	for d in s.dirs:
		var lead: bool = d.el == s.leader
		var col: Color = GameData.EL[d.el]
		var known: bool = SaveGame.data.get("dex", {}).has(d.form)
		var label := "%s > %s" % [d.el, d.form if known else "???"]
		_text(Vector2(x, y + 8), label, 8, col if lead else col.darkened(0.25), HORIZONTAL_ALIGNMENT_LEFT, -1, lead, lead)
		_text(Vector2(x, y + 8), str(d.n), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, w)
		_bar(Rect2(x, y + 10, w, 3), float(d.n) / maxn, col if lead else col.darkened(0.45))
		y += 16
	if s.dirs.is_empty() and s.target != "":
		_text(Vector2(x, y + 8), "> " + s.target, 8, GameData.COL.ink)
		y += 14
	if not s.other.is_empty():
		var parts: Array = []
		for el in s.other:
			parts.append("%s %d" % [el, s.other[el]])
		draw_multiline_string(font(), Vector2(x, y + 8), "Ohne Wirkung: " + ", ".join(parts), HORIZONTAL_ALIGNMENT_LEFT, w, 8, 2, GameData.COL.muted, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
		y += 12 * (1 if text_width("Ohne Wirkung: " + ", ".join(parts)) <= w else 2)
	var msg: String = "Bereit zur Entwicklung!" if s.ready else s.reason
	_text(Vector2(x, y + 8), msg, 8, GameData.COL.mint if s.ready else GameData.COL.sun)
	return y + 12 - y0


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


# ---------- Zonen-Hintergrund ----------

static var _zone_bg := {}

const ZONE_PAL := {
	"wiesen": {"sky0": "#161230", "sky1": "#243152", "far": "#1C3444", "near": "#1F4A47", "edge": "#2F6E5D",
		"ground": "#193B38", "grass": "#2C6A55", "flower": ["#6EE7C5", "#FFD84D", "#C9B8FF"]},
	"wiesen_boss": {"sky0": "#1A0C24", "sky1": "#3A1636", "far": "#2A1733", "near": "#3A1E3B", "edge": "#6B2C55",
		"ground": "#2A1430", "grass": "#5A2A4E", "flower": ["#FF5470", "#FF9DB3", "#C77DFF"]},
	"vulkan": {"sky0": "#1A0A14", "sky1": "#4A1A1E", "far": "#2A1418", "near": "#361A1A", "edge": "#FF6A2A",
		"ground": "#24100F", "grass": "#5E2416", "flower": ["#FF8A4C", "#FFC83D", "#FF5470"]},
	"sumpf": {"sky0": "#120F1C", "sky1": "#2A3A2E", "far": "#1C2A22", "near": "#233826", "edge": "#7BD35A",
		"ground": "#1A2A1C", "grass": "#3E6A34", "flower": ["#C77DFF", "#FF5470", "#7BD35A"]},
	"sumpf_boss": {"sky0": "#140A1E", "sky1": "#3A2446", "far": "#241A2E", "near": "#2E2238", "edge": "#C77DFF",
		"ground": "#1E1428", "grass": "#4E2E5E", "flower": ["#FF5470", "#7BD35A", "#FFD84D"]},
	"vulkan_boss": {"sky0": "#200606", "sky1": "#6A1A10", "far": "#3A1010", "near": "#4A1612", "edge": "#FFB347",
		"ground": "#2E0C0A", "grass": "#7A2A12", "flower": ["#FFD84D", "#FF8A4C", "#FF5470"]},
}


## Einmal gerenderter Zonen-Hintergrund (Himmel, zwei Hügelketten, Wiese mit Daten-Blumen).
static func zone_texture(zone: String) -> ImageTexture:
	if _zone_bg.has(zone):
		return _zone_bg[zone]
	var P: Dictionary = ZONE_PAL[zone]
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var s0 := Color(P.sky0)
	var s1 := Color(P.sky1)
	# Himmel in 8 Bändern, an den Übergängen geordnet gedithert
	var bands := 8
	var sky_h := 230
	for y in sky_h:
		var k := float(y) / sky_h * bands
		var band := floori(k)
		var frac := k - band
		for x in W:
			var b := band + (1 if frac > 0.75 and (x + y) % 2 == 0 else 0)
			img.set_pixel(x, y, s0.lerp(s1, clampf(float(b) / bands, 0.0, 1.0)))
	# Bits am Himmel
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 60:
		img.set_pixel(rng.randi_range(0, W - 1), rng.randi_range(0, 150), Color(1, 1, 1, rng.randf_range(0.15, 0.5)).blend(s0))
	# Hügel
	for x in W:
		var yf := roundi(172 + 12 * sin(x * 0.013) + 7 * sin(x * 0.031 + 1.0))
		img.fill_rect(Rect2i(x, yf, 1, H - yf), Color(P.far))
	for x in W:
		var yn := roundi(214 + 10 * sin(x * 0.02 + 2.0) + 6 * sin(x * 0.047))
		img.fill_rect(Rect2i(x, yn, 1, H - yn), Color(P.near))
		img.set_pixel(x, yn, Color(P.edge))
	# Wiese unten mit Grasbüscheln
	img.fill_rect(Rect2i(0, 286, W, H - 286), Color(P.ground))
	for i in 140:
		var gx := rng.randi_range(0, W - 1)
		var gy := rng.randi_range(240, H - 4)
		var h := rng.randi_range(2, 4)
		for j in h:
			img.set_pixel(gx, gy - j, Color(P.grass))
		if rng.randf() < 0.5:
			img.set_pixel(gx + 1, gy - 1, Color(P.grass))
	# Daten-Blumen auf den Hügeln
	for i in 26:
		var fx := rng.randi_range(4, W - 5)
		var fy := roundi(214 + 10 * sin(fx * 0.02 + 2.0) + 6 * sin(fx * 0.047)) + rng.randi_range(4, 60)
		var col := Color(P.flower[i % P.flower.size()])
		img.set_pixel(fx, fy + 1, Color(P.grass))
		img.set_pixel(fx, fy + 2, Color(P.grass))
		for d in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			img.set_pixel(fx + d.x, fy + d.y - 1, col.darkened(0.25))
		img.set_pixel(fx, fy - 1, col.lightened(0.5))
	var tex := ImageTexture.create_from_image(img)
	_zone_bg[zone] = tex
	return tex


## Zonen-Hintergrund plus aufsteigende Datenpartikel
func _draw_zone(zone: String) -> void:
	draw_texture(zone_texture(zone), Vector2.ZERO)
	var dust := Color("#FF5470", 0.5) if zone.ends_with("boss") else Color("#B8FFE9", 0.45)
	for i in 22:
		var x := fmod(i * 97.3 + 13.0 + sin(anim_t * 0.7 + i) * 6.0, W)
		var y := H - fmod(anim_t * (10.0 + i % 5 * 3.0) + i * 53.0, H)
		draw_rect(Rect2(roundi(x), roundi(y), 1 if i % 3 else 2, 1 if i % 3 else 2), dust)
