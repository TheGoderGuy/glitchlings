class_name PixelCanvas
extends Node2D
## Basis für alle Bildschirme: zeichnet direkt in 640×360.
## Im Code gibt es nur die Schriftgrößen 8 / 16 / 24. Größe 8 (Fließtext) nutzt die gewählte Pixelschrift
## in ihrer Rastergröße (tsz), 16 und 24 (Überschriften, Logo) bleiben in Silkscreen.

const W := 640
const H := 360

## Pixelschriften nur in ihrer Rastergröße zeichnen, sonst verzerren sie
const FONT_SETS := {
	"silkscreen": {"r": "Silkscreen-Regular.ttf", "b": "Silkscreen-Bold.ttf", "px": 8},
	"pixeloid": {"r": "PixeloidSans.ttf", "b": "PixeloidSans-Bold.ttf", "px": 9},
}
static var font_set := "pixeloid"   # Fließtext: Pixeloid Sans (seit 30.09.2026, vorher Silkscreen)
static var _fonts := {}

var anim_t := 0.0
var off := Vector2.ZERO
var handbook: Node = null   # offenes Kampf-Handbuch (Überlagerung), solange es offen ist, pausiert der Bildschirm


## Kampf-Handbuch über diesem Bildschirm öffnen (Pause-Menüs, H / Select)
func open_handbook() -> void:
	if handbook != null:
		return
	var hb: Node = load("res://scripts/ui/handbook_view.gd").new()
	handbook = hb
	hb.closed.connect(func():
		hb.queue_free()
		handbook = null)
	add_child(hb)


## Schrift für eine Code-Größe: unter 16 die Fließtext-Schrift, ab 16 Silkscreen
static func font(bold := false, size := 8) -> FontFile:
	var set_name: String = font_set if size < 16 else "silkscreen"
	var key := set_name + ("_b" if bold else "_r")
	if not _fonts.has(key):
		_fonts[key] = _load_font("res://assets/fonts/" + FONT_SETS[set_name]["b" if bold else "r"])
	return _fonts[key]


## Code-Größe (8 / 16 / 24) → tatsächliche Zeichengröße der Schrift
static func tsz(size: int) -> int:
	return int(FONT_SETS[font_set].px) if size < 16 else size


static func _load_font(path: String) -> FontFile:
	var f: FontFile = load(path).duplicate()
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.multichannel_signed_distance_field = false
	if not path.contains("Silkscreen"):
		f.fallbacks = [_ps_font()]
	return f


## PlayStation-Symbole ✕ ○ □ △ als kleine Bitmap-Schrift im 9-px-Raster (kräftige 2-px-Linien, damit ○ nicht wie „O“ aussieht).
## Zeichencodes U+E000–E003 (Private Use Area), siehe InputSetup.PS_NAMES.
const PS_GLYPHS := {
	0xE000: ["##...##", "###.###", ".#####.", "..###..", ".#####.", "###.###", "##...##"],
	0xE001: ["..###..", ".##.##.", "##...##", "##...##", "##...##", ".##.##.", "..###.."],
	0xE002: ["#######", "#######", "##...##", "##...##", "##...##", "#######", "#######"],
	0xE003: ["...#...", "..###..", "..#.#..", ".##.##.", ".#...#.", "##...##", "#######"],
}
static var _ps_font_cache: FontFile


static func _ps_font() -> FontFile:
	if _ps_font_cache != null:
		return _ps_font_cache
	var px := 9
	var ff := FontFile.new()
	ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	ff.fixed_size = px
	ff.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	var img := Image.create(8 * PS_GLYPHS.size(), 8, false, Image.FORMAT_RGBA8)
	var sz := Vector2i(px, 0)
	var i := 0
	for cp in PS_GLYPHS:
		var rows: Array = PS_GLYPHS[cp]
		for y in rows.size():
			for x in rows[y].length():
				if rows[y][x] == "#":
					img.set_pixel(i * 8 + x, y, Color.WHITE)
		ff.set_glyph_advance(0, px, cp, Vector2(9, 0))
		ff.set_glyph_offset(0, sz, cp, Vector2(1, -7))
		ff.set_glyph_size(0, sz, cp, Vector2(7, 7))
		ff.set_glyph_uv_rect(0, sz, cp, Rect2(i * 8, 0, 7, 7))
		ff.set_glyph_texture_idx(0, sz, cp, 0)
		i += 1
	ff.set_texture_image(0, sz, 0, img)
	ff.set_cache_ascent(0, px, 8)
	ff.set_cache_descent(0, px, 2)
	_ps_font_cache = ff
	return ff


static func text_width(s: String, size := 8, bold := false) -> float:
	return font(bold, size).get_string_size(T.t(s), HORIZONTAL_ALIGNMENT_LEFT, -1, tsz(size)).x


## Text zeichnen; ist der ganze Text ein Übersetzungsschlüssel, erscheint er in der gewählten Sprache
func _text(pos: Vector2, s: String, size := 8, color: Color = GameData.COL.ink, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0, outline := true, bold := false) -> void:
	s = T.t(s)
	var f := font(bold, size)
	pos = pos.round()
	if outline:
		draw_string_outline(f, pos, s, align, width, tsz(size), maxi(2, size / 4), Color(GameData.COL.dark, color.a))
	draw_string(f, pos, s, align, width, tsz(size), color)


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
func _menu(items: Array, sel: int, center_x: float, y: float, width := 200.0, step := 22.0) -> void:
	for i in items.size():
		var r := Rect2(center_x - width / 2, y + i * step, width, 18)
		var active := i == sel
		_box(r, GameData.COL.panel if active else Color(GameData.COL.bg2, 0.85), GameData.COL.sun if active else GameData.COL.line)
		if active:
			var bx := r.position.x + 6 + (1 if sin(anim_t * 10.0) > 0 else 0)
			_text(Vector2(bx, r.position.y + 13), ">", 8, GameData.COL.sun)
		_text(Vector2(r.position.x, r.position.y + 13), str(items[i]), 8, GameData.COL.ink if active else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


# ---------- Sprites ----------

## Gegner-Sprites; Monster-Formen stehen in GameData.FORMS
const SPRITE_FILES := {"bug": "bug_64", "moth": "moth_64", "wurm": "bytewurm_64", "mantis": "kernelmantis_96",
	"kaefer": "chiffrekaefer_64", "wespe": "datenwespe_64", "raupe": "raupe_64",
	"milbe": "milbe_64", "assel": "assel_64", "falter": "falter_64", "skarab": "skarab_96",
	"muecke": "muecke_64", "schnecke": "panzerschnecke_64", "bluete": "glitchbluete_64", "koenigin": "schwarmkoenigin_96",
	"drohne": "kerndrohne_64", "spinne": "glitchspinne_64", "urglitch": "urglitch_96",
	"sprungschreck": "sprungschreck_80", "dornwurz": "dornwurz_80", "schlackwurm": "schlackwurm_80", "magmaskorp": "magmaskorp_80",
	"schnappkelch": "schnappkelch_80", "schlickkrake": "schlickkrake_80", "skolopendrox": "skolopendrox_80",
	"funkenkaefer": "funkenkaefer_64", "datenegel": "datenegel_64", "moorlibelle": "moorlibelle_64", "sentinelkrabbe": "sentinelkrabbe_64", "fehlerqualle": "fehlerqualle_64"}
static var _sprites := {}
const IDLE_FPS := 10.0  # Bilder pro Sekunde der Idle-Animationen (Produzent: 10 sieht am besten aus)


## Alle Sprites beim Spielstart laden: Texturen, die erst in _draw() zum ersten Mal geladen werden, bleiben in dem Bild weiß.
static func preload_all() -> void:
	# Zonen-Kulissen vorberechnen (03.10.2026): pro Kulisse ~20 ms Pixelarbeit – beim ersten Besuch einer Zone,
	# der Station oder der Zonenwahl ruckelte es sonst genau beim Kampfbeginn bzw. Bildschirmwechsel
	for z in ZONE_PAL:
		zone_texture(z)
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
	# Idle-Animation (optional): assets/sprites/anim/<datei>_idle_0.png, _1, … (Frame 0 = Grundbild)
	var idle: Array = []
	while ResourceLoader.exists("res://assets/sprites/anim/%s_idle_%d.png" % [file, idle.size()]):
		idle.append(load("res://assets/sprites/anim/%s_idle_%d.png" % [file, idle.size()]))
	# Angriffsanimation (optional, 05.10.2026): assets/sprites/anim/<datei>_atk_0, _1, …
	var atk: Array = []
	while ResourceLoader.exists("res://assets/sprites/anim/%s_atk_%d.png" % [file, atk.size()]):
		atk.append(load("res://assets/sprites/anim/%s_atk_%d.png" % [file, atk.size()]))
	var s := {"tex": tex, "blink": blink, "flash": ImageTexture.create_from_image(white), "n": img.get_width(), "foot": foot, "idle": idle, "atk": atk}
	_sprites[key] = s
	return s


## Hat das Sprite eine Angriffsanimation?
static func has_attack(key: String) -> bool:
	return not sprite(key).atk.is_empty()


## Spieler-Babys (32 px) werden verdoppelt, ab Rookie 1 Kunstpixel = 1 Pixel.
## opts: scale, bob, flash, blink, mod, clip_top, anim (false = Idle-Animation aus), phase (fester Animationsversatz)
## Hat ein Sprite Idle-Frames, laufen sie statt Wippen und Blinzeln (Phase je Position versetzt).
func _draw_sprite(key: String, cx: float, feet_y: float, flip: bool, opts := {}) -> void:
	var s := sprite(key)
	var sc: int = opts.get("scale", 2 if s.n <= 32 else 1)
	var size: int = s.n * sc
	var animated: bool = not s.idle.is_empty() and opts.get("anim", true)
	var bob: int = 0 if animated else opts.get("bob", 0)
	var top := roundi(feet_y - size + s.foot * sc - bob)
	var left := roundi(cx - size / 2.0)
	var tex: Texture2D = s.flash if opts.get("flash", false) else (s.blink if opts.get("blink", false) else s.tex)
	if animated and not opts.get("flash", false):
		# Versatz je Figur, damit nicht alle im Gleichtakt atmen – unabhängig von der Position, sonst springt die
		# Animation beim Bewegen (Kampf) oder bei Kameraschwenks (Intro); "phase" setzt ihn ausdrücklich
		var fi: int = int(anim_t * IDLE_FPS + opts.get("phase", float(absi(key.hash()) % 60) * 0.1)) % s.idle.size()
		tex = s.idle[fi]
	# Angriff: "atk" = Fortschritt 0–1 (überdeckt Idle und Blinzeln, nicht den weißen Treffer-Blitz)
	var atk_k: float = opts.get("atk", -1.0)
	if atk_k >= 0.0 and not s.atk.is_empty() and not opts.get("flash", false):
		tex = s.atk[clampi(int(atk_k * s.atk.size()), 0, s.atk.size() - 1)]
	var mod: Color = opts.get("mod", Color.WHITE)
	if flip:
		draw_set_transform(off + Vector2(left + size, top), 0, Vector2(-sc, sc))
	else:
		draw_set_transform(off + Vector2(left, top), 0, Vector2(sc, sc))
	# clip_top: alles oberhalb dieser Linie weglassen (z. B. 96er-Sprites in kleinen Kacheln)
	var cut: int = ceili((float(opts.get("clip_top", -INF)) - top) / sc)
	if cut > 0:
		draw_texture_rect_region(tex, Rect2(0, cut, s.n, s.n - cut), Rect2(0, cut, s.n, s.n - cut), mod)
	else:
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
		var label := "%s > %s" % [T.t(d.el), T.t(d.form) if known else "???"]
		_text(Vector2(x, y + 8), label, 8, col if lead else col.darkened(0.25), HORIZONTAL_ALIGNMENT_LEFT, -1, lead, lead)
		_text(Vector2(x, y + 8), str(d.n), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, w)
		_bar(Rect2(x, y + 10, w, 3), float(d.n) / maxn, col if lead else col.darkened(0.45))
		y += 16
	if s.dirs.is_empty() and s.target != "":
		_text(Vector2(x, y + 8), "> " + T.t(s.target), 8, GameData.COL.ink)
		y += 14
	if not s.other.is_empty():
		var parts: Array = []
		for el in s.other:
			parts.append("%s %d" % [T.t(el), s.other[el]])
		var ow := T.t("Ohne Wirkung:") + " " + ", ".join(parts)
		draw_multiline_string(font(), Vector2(x, y + 8), ow, HORIZONTAL_ALIGNMENT_LEFT, w, tsz(8), 2, GameData.COL.muted, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
		y += 12 * (1 if text_width(ow) <= w else 2)
	var msg: String = "Bereit zur Entwicklung!" if s.ready else s.reason
	for line in wrap_lines(msg, w):
		_text(Vector2(x, y + 8), line, 8, GameData.COL.mint if s.ready else GameData.COL.sun)
		y += 12
	return y - y0


## Text in Zeilen aufteilen, die höchstens w Pixel breit sind (Umbruch an Leerzeichen)
static func wrap_lines(s: String, w: float, size := 8) -> Array:
	s = T.t(s)
	var lines: Array = []
	var cur := ""
	for word in s.split(" ", false):
		var test := word if cur == "" else cur + " " + word
		if cur != "" and text_width(test, size) > w:
			lines.append(cur)
			cur = word
		else:
			cur = test
	if cur != "":
		lines.append(cur)
	return lines


## Modul-Symbol (14×14): Rahmen in Seltenheitsfarbe, Piktogramm in Modulfarbe
## Trefferbild (3×3 Gegnerfeld, deine Reihe = Mitte) oder Symbol für Schutz/Hilfe, 12×12 Pixel (× s)
func _draw_chip_icon(id: String, pos: Vector2, bright: bool, s := 1) -> void:
	var info: Array = GameData.CHIP_CARD.get(GameData.base_chip(id), ["row", ""])
	var col: Color = GameData.EL[GameData.chip(id).el]
	if not bright:
		col = col.darkened(0.35)
	var pat: String = info[0]
	if GameData.PICTOS.has(pat):
		var pic: Array = GameData.PICTOS[pat]
		for y in 6:
			for x in 6:
				if pic[y][x] == "#":
					draw_rect(Rect2(pos + Vector2(x * 2, y * 2) * s, Vector2(2, 2) * s), col)
		return
	var hit := {}
	match pat:
		"row": hit = {Vector2i(0, 1): 1, Vector2i(1, 1): 1, Vector2i(2, 1): 1}
		"front": hit = {Vector2i(0, 1): 1, Vector2i(1, 1): 1}
		"col", "mycol": hit = {Vector2i(1, 0): 1, Vector2i(1, 1): 1, Vector2i(1, 2): 1}
		"field": for yy in 3:
			for xx in 3:
				hit[Vector2i(xx, yy)] = 1
		"aim", "mine": hit = {Vector2i(1, 1): 1}
		"blast": hit = {Vector2i(1, 1): 1, Vector2i(0, 1): 2, Vector2i(2, 1): 2, Vector2i(1, 0): 2, Vector2i(1, 2): 2}
		"pull": hit = {Vector2i(0, 1): 1, Vector2i(2, 1): 2}
	for y in 3:
		for x in 3:
			var c: Color = GameData.COL.dark.lightened(0.15)
			if hit.has(Vector2i(x, y)):
				c = col if hit[Vector2i(x, y)] == 1 else col.darkened(0.45)
			draw_rect(Rect2(pos + Vector2(x * 4, y * 4) * s, Vector2(3, 3) * s), c)
	if pat == "mine":
		draw_rect(Rect2(pos + Vector2(5, 5) * s, Vector2(1, 1) * s), GameData.COL.dark)


func _draw_module_icon(id: String, pos: Vector2) -> void:
	var M: Dictionary = GameData.MODULES[id]
	var rc: Color = {"Gewöhnlich": GameData.COL.line.lightened(0.3), "Selten": Color("#58B7FF"), "Episch": Color("#FFC83D")}[M.rar]
	pos = pos.round()
	draw_rect(Rect2(pos, Vector2(14, 14)), GameData.COL.dark)
	draw_rect(Rect2(pos + Vector2(1, 1), Vector2(12, 12)), rc)
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(10, 10)), GameData.COL.dark)
	var pic: Array = GameData.PICTOS[M.pic]
	var col := Color(M.col)
	for y in 6:
		for x in 6:
			if pic[y][x] == "#":
				draw_rect(Rect2(pos + Vector2(4 + x, 4 + y), Vector2(1, 1)), col)


## Reihe von Modul-Symbolen; gibt die Breite zurück
func _draw_module_row(mods: Array, x: float, y: float, max_n := 10) -> float:
	var n := mini(mods.size(), max_n)
	for i in n:
		_draw_module_icon(mods[i], Vector2(x + i * 15, y))
	if mods.size() > max_n:
		_text(Vector2(x + n * 15 + 2, y + 11), "+%d" % (mods.size() - max_n), 8, GameData.COL.muted)
	return n * 15.0


## Liste mit Symbol, Name und Beschreibung (max_rows Einträge, danach nur Symbole)
func _draw_module_list(mods: Array, x: float, y: float, w: float, max_rows := 5) -> void:
	if mods.is_empty():
		draw_multiline_string(font(), Vector2(x, y + 8), T.t("Noch keine. Module gibt es bei Elite-Gegnern, beim Händler und in Modulkapseln."), HORIZONTAL_ALIGNMENT_LEFT, w, tsz(8), 3, GameData.COL.muted, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
		return
	for i in mini(mods.size(), max_rows):
		var M: Dictionary = GameData.MODULES[mods[i]]
		_draw_module_icon(mods[i], Vector2(x, y))
		_text(Vector2(x + 20, y + 10), M.name, 8, Color(M.col), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		draw_multiline_string(font(), Vector2(x + 20, y + 22), T.t(M.desc), HORIZONTAL_ALIGNMENT_LEFT, w - 20, tsz(8), 2, GameData.COL.muted, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
		y += 38
	if mods.size() > max_rows:
		_draw_module_row(mods.slice(max_rows), x, y, 14)


## Deckliste, nach Slot-Rolle sortiert: „3× Pixelstrahl … Angriff“
func _draw_deck_list(deck: Array, x: float, y: float, w: float, max_rows := 14) -> void:
	var counts := {}
	var sorted := deck.duplicate()
	sorted.sort_custom(func(a, b): return GameData.role(a) < GameData.role(b) or (GameData.role(a) == GameData.role(b) and a < b))
	for k in sorted:
		counts[k] = counts.get(k, 0) + 1
	var row := 0
	for k in counts:
		if row >= max_rows:
			_text(Vector2(x + 14, y), "…", 8, GameData.COL.muted)
			return
		var el: Color = GameData.EL[GameData.chip(k).el]
		draw_rect(Rect2(x, y - 7, 7, 7), el)
		_text(Vector2(x + 14, y), "%d× %s" % [counts[k], T.chip(k)], 8, GameData.COL.sun if GameData.is_upgraded(k) else GameData.COL.ink)
		var ro := GameData.role(k)
		_text(Vector2(x + 14, y), GameData.ROLE_NAMES[ro], 8, Color(GameData.ROLE_COL[ro]), HORIZONTAL_ALIGNMENT_RIGHT, w - 14)
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
	"kern": {"sky0": "#05060F", "sky1": "#10213A", "far": "#0E1A2E", "near": "#132640", "edge": "#4CC3F0",
		"ground": "#0A1424", "grass": "#1E4A6A", "flower": ["#4CC3F0", "#FF5470", "#FFD84D"]},
	"kern_boss": {"sky0": "#0A0210", "sky1": "#2A0A30", "far": "#1E0A28", "near": "#2A1038", "edge": "#FF5470",
		"ground": "#140818", "grass": "#3A1A4A", "flower": ["#4CC3F0", "#FF5470", "#FFD84D"]},
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
