class_name ArenaTiles
extends RefCounted
## Kampffeld-Platten je Zone (08.10.2026, Game-Design-Analyse „Kampffeld“): Vorher waren alle 18 Felder in jeder Zone
## gleich (Rechtecke mit Datenraster auf einem dunklen Sockel) und verdeckten die Kulisse. Jetzt trägt jede Platte das
## Material ihrer Zone, ist nach Seite getönt (Spieler blaugrün, Gegner magenta) und hat eine Vorderkante wie in
## Battle Network. Pixel-Regeln: Licht von oben links, dunkle Kontur, ganzzahlig.
## Je Zone, Seite und Variante wird die Platte einmal erzeugt (Grundfläche + Leuchtebene, die im Kampf pulsiert).

const TW := 84      # = BattleView.CW - 4 (cell_rect)
const TH := 46      # = BattleView.CH - 4
const EDGE := 6     # Vorderkante unten
const VARIANTS := 3
const SIDE_TINT := [Color("#1E9AB4"), Color("#B42C8E")]   # Spieler, Gegner
const SIDE_RIM := [Color("#8FF0DA"), Color("#FF9DE8")]
const OUTLINE := Color("#120D24")

## Vorderkante je Material: Grundfarbe
const FRONT := {"wiesen": "#3A2A2E", "vulkan": "#22120F", "see": "#1A2C40", "sumpf": "#33251A", "steppe": "#4A3E1E", "kern": "#0E1A2C"}

static var _cache := {}


## Material einer Kulisse („wiesen_boss“ > „wiesen“)
static func material(bg: String) -> String:
	var m := bg.trim_suffix("_boss")
	return m if FRONT.has(m) else "wiesen"


## [Grundfläche, Leuchtebene] für Kulisse, Seite (0 Spieler, 1 Gegner) und Variante
static func tile(bg: String, side: int, variant: int) -> Array:
	var key := "%s/%d/%d" % [material(bg), side, variant]
	if not _cache.has(key):
		_cache[key] = _make(material(bg), side, variant)
	return _cache[key]


## Alle Platten einer Kulisse vorab erzeugen (nicht erst im ersten Bild des Kampfes)
static func preload_bg(bg: String) -> void:
	for side in 2:
		for v in VARIANTS:
			tile(bg, side, v)


static func _make(mat: String, side: int, variant: int) -> Array:
	var img := Image.create(TW, TH, false, Image.FORMAT_RGBA8)
	var gl := Image.create(TW, TH, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(mat) + variant * 7919 + side * 104729
	var fh := TH - EDGE   # Höhe der Fläche
	match mat:
		"vulkan":
			_vulkan(img, gl, rng, fh)
		"see":
			_see(img, gl, rng, fh, variant)
		"sumpf":
			_sumpf(img, gl, rng, fh)
		"steppe":
			_steppe(img, gl, rng, fh, variant)
		"kern":
			_kern(img, gl, rng, fh)
		_:
			_wiesen(img, gl, rng, fh)
	_front(img, gl, rng, mat, fh)
	# Seitenfarbe: Fläche leicht, Vorderkante kräftig (die Seite soll auf einen Blick klar sein).
	# Gegnerseite: Farbton Richtung Magenta drehen statt mischen – Mischen mit der Gegenfarbe (Grün + Magenta) wird grau.
	var tint: Color = SIDE_TINT[side]
	for y in TH:
		var k := 0.27 if y < fh else 0.5
		for x in TW:
			var c := img.get_pixel(x, y)
			if c.a == 0:
				continue
			if side == 1 and y < fh:
				var h := lerp_angle(c.h * TAU, tint.h * TAU, 0.55) / TAU
				c = Color.from_hsv(fposmod(h, 1.0), maxf(c.s, 0.32), c.v).lerp(tint, 0.1)
			else:
				c = c.lerp(tint, k)
			img.set_pixel(x, y, c)
	# Licht von oben links: obere Kante in Seitenfarbe, linke Kante hell, rechte/untere Kante der Fläche dunkel
	var rim: Color = SIDE_RIM[side]
	for x in TW:
		img.set_pixel(x, 1, img.get_pixel(x, 1).lerp(rim, 0.65))
		img.set_pixel(x, 2, img.get_pixel(x, 2).lerp(rim, 0.2))
		img.set_pixel(x, fh - 1, img.get_pixel(x, fh - 1).darkened(0.25))
	for y in range(1, fh):
		img.set_pixel(1, y, img.get_pixel(1, y).lightened(0.18))
		img.set_pixel(TW - 2, y, img.get_pixel(TW - 2, y).darkened(0.2))
	# Kontur
	for x in TW:
		img.set_pixel(x, 0, OUTLINE)
		img.set_pixel(x, TH - 1, OUTLINE)
	for y in TH:
		img.set_pixel(0, y, OUTLINE)
		img.set_pixel(TW - 1, y, OUTLINE)
	# Ecken abrunden
	for p in [Vector2i(0, 0), Vector2i(TW - 1, 0), Vector2i(0, TH - 1), Vector2i(TW - 1, TH - 1)]:
		img.set_pixel(p.x, p.y, Color(0, 0, 0, 0))
	return [ImageTexture.create_from_image(img), ImageTexture.create_from_image(gl)]


## Ruhige Grundfläche aus Farbinseln (je cw × ch Pixel ein Ton, an den Rändern leicht verzahnt) statt Einzelpixel-Rauschen
static func _noise(img: Image, rng: RandomNumberGenerator, fh: int, cols: Array, cw := 5, ch := 3) -> void:
	var gw := TW / cw + 2
	var grid: Array = []
	for k in gw * (fh / ch + 2):
		var r := rng.randf()
		grid.append(0 if r < 0.7 else (1 if r < 0.92 else 2))
	for y in fh:
		for x in TW:
			var gx := x / cw
			var gy := y / ch
			# Verzahnung: an Zellrändern manchmal die Nachbarzelle nehmen
			if x % cw == 0 and rng.randf() < 0.5:
				gx = maxi(0, gx - 1)
			if y % ch == 0 and rng.randf() < 0.5:
				gy = maxi(0, gy - 1)
			img.set_pixel(x, y, Color(cols[grid[gy * gw + gx]]))


## Unregelmäßige Platten (Voronoi): Nummer der Platte je Pixel; Fugen dort, wo sich die Nummer ändert
static func _plates(rng: RandomNumberGenerator, fh: int, n: int) -> PackedInt32Array:
	var seeds: Array = []
	for k in n:
		seeds.append(Vector2(rng.randf_range(0, TW), rng.randf_range(0, fh)))
	var out := PackedInt32Array()
	out.resize(TW * fh)
	for y in fh:
		for x in TW:
			var best := 1e9
			var id := 0
			for k in n:
				var d := Vector2((x - seeds[k].x) * 0.8, (y - seeds[k].y) * 1.4).length_squared()
				if d < best:
					best = d
					id = k
			out[y * TW + x] = id
	return out


static func _is_seam(pl: PackedInt32Array, x: int, y: int, fh: int) -> bool:
	var id := pl[y * TW + x]
	return (x + 1 < TW and pl[y * TW + x + 1] != id) or (y + 1 < fh and pl[(y + 1) * TW + x] != id)


static func _wiesen(img: Image, gl: Image, rng: RandomNumberGenerator, fh: int) -> void:
	_noise(img, rng, fh, ["#2C6A55", "#2A6550", "#317359"])
	# Grasbüschel: kleines helles „v“ mit Schattenpixel darunter
	for i in 34:
		var x := rng.randi_range(3, TW - 4)
		var y := rng.randi_range(4, fh - 3)
		var hi := Color("#4A9070") if rng.randf() < 0.7 else Color("#5AA07E")
		img.set_pixel(x, y, hi)
		img.set_pixel(x - 1, y - 1, hi)
		img.set_pixel(x + 1, y - 1, hi)
		img.set_pixel(x, y + 1, Color("#1F4A40"))
	# dunklere Grasflecken
	for i in 6:
		var x := rng.randi_range(4, TW - 6)
		var y := rng.randi_range(4, fh - 4)
		for d in 3:
			img.set_pixel(x + d, y, Color("#24584A"))
			img.set_pixel(x + d + 1, y + 1, Color("#24584A"))
	# Daten-Blüten (leuchten sanft)
	for i in rng.randi_range(2, 4):
		var x := rng.randi_range(5, TW - 6)
		var y := rng.randi_range(5, fh - 5)
		var col: Color = [Color("#FFD84D"), Color("#C9B8FF"), Color("#6EE7C5")][rng.randi_range(0, 2)]
		img.set_pixel(x, y, col.darkened(0.3))
		img.set_pixel(x, y + 1, Color("#1F4A40"))
		gl.set_pixel(x, y, col)
		gl.set_pixel(x, y - 1, Color(col, 0.5))


static func _vulkan(img: Image, gl: Image, rng: RandomNumberGenerator, fh: int) -> void:
	# Basaltplatten mit dunklen Fugen, jede Platte etwas anders getönt; in manchen Fugen glimmt Glut
	var pl := _plates(rng, fh, 5)
	var tones := [Color("#2E1C1E"), Color("#352022"), Color("#2A191A"), Color("#3A2426"), Color("#301E1F")]
	var hot := [rng.randf() < 0.5, rng.randf() < 0.5, true, rng.randf() < 0.3, rng.randf() < 0.3]
	for y in fh:
		for x in TW:
			var id := pl[y * TW + x]
			if _is_seam(pl, x, y, fh):
				img.set_pixel(x, y, Color("#140A0A"))
				if hot[id]:
					img.set_pixel(x, y, Color("#5E2416"))
					gl.set_pixel(x, y, Color("#FF7A2A"))
			else:
				var c: Color = tones[id]
				img.set_pixel(x, y, c.lightened(0.06) if (x + y * 3) % 17 == 0 else c)
	# Lichtkante oben links an jeder Platte
	for y in range(1, fh):
		for x in range(1, TW):
			var id := pl[y * TW + x]
			if pl[(y - 1) * TW + x] != id or pl[y * TW + x - 1] != id:
				if not _is_seam(pl, x, y, fh):
					img.set_pixel(x, y, Color(tones[id]).lightened(0.18))


static func _see(img: Image, gl: Image, rng: RandomNumberGenerator, fh: int, variant: int) -> void:
	_noise(img, rng, fh, ["#2C4864", "#2A4560", "#30506E"], 7, 4)
	# Gitterrost: Rahmen und Schlitzreihen (gut lesbar auch bei Originalgröße)
	for y in range(4, fh - 3):
		for x in [3, TW - 4]:
			img.set_pixel(x, y, Color("#3E6484"))
	var row := 0
	for y in range(6, fh - 5, 5):
		var shift := 3 if (row + variant) % 2 else 0
		for x in range(6 + shift, TW - 9, 9):
			for d in 6:
				img.set_pixel(x + d, y, Color("#0E1C30"))
				img.set_pixel(x + d, y + 1, Color("#14263A"))
				img.set_pixel(x + d, y + 2, Color("#4A7294"))
		row += 1
	# Nieten in den Ecken
	for p in [Vector2i(5, 3), Vector2i(TW - 6, 3), Vector2i(5, fh - 4), Vector2i(TW - 6, fh - 4)]:
		img.set_pixel(p.x, p.y, Color("#A8CCE8"))
		img.set_pixel(p.x + 1, p.y + 1, Color("#14263A"))
	# Nässe: kurze Glanzstriche
	for i in rng.randi_range(3, 5):
		var x := rng.randi_range(6, TW - 10)
		var y := rng.randi_range(4, fh - 5)
		for d in rng.randi_range(2, 4):
			gl.set_pixel(x + d, y, Color("#BFF4FF", 0.85 - d * 0.15))


static func _sumpf(img: Image, gl: Image, rng: RandomNumberGenerator, fh: int) -> void:
	# Holzplanken quer, mit Fugen, Maserung und Nägeln
	var y := 1
	while y < fh:
		var ph := mini(rng.randi_range(6, 8), fh - y)
		var wood := Color("#4A3826") if rng.randf() < 0.5 else Color("#523E2A")
		for yy in range(y, y + ph):
			for x in TW:
				img.set_pixel(x, yy, wood.darkened(0.08) if rng.randf() < 0.25 else wood)
		for i in 5:
			var gx := rng.randi_range(2, TW - 12)
			var gy := rng.randi_range(y + 1, maxi(y + 1, y + ph - 2))
			for d in rng.randi_range(4, 9):
				img.set_pixel(gx + d, gy, wood.darkened(0.25))
		for x in TW:
			img.set_pixel(x, mini(y + ph - 1, fh - 1), Color("#2A1E14"))
		for nx in [4, TW - 5]:
			img.set_pixel(nx, y + ph / 2, Color("#8A7A6A"))
		y += ph
	# Moos von den Rändern
	for i in rng.randi_range(5, 8):
		var cx := rng.randi_range(0, TW - 1)
		var cy := rng.randi_range(0, fh - 1) if rng.randf() < 0.4 else (2 if rng.randf() < 0.5 else fh - 3)
		var rad := rng.randi_range(2, 4)
		for dy in range(-rad, rad + 1):
			for dx in range(-rad, rad + 1):
				var px := cx + dx
				var py := cy + dy
				if dx * dx + dy * dy <= rad * rad and px >= 1 and px < TW - 1 and py >= 1 and py < fh:
					img.set_pixel(px, py, Color("#3E6A34") if (px + py) % 3 else Color("#4E7A3A"))
	# Leuchtpilze
	for i in rng.randi_range(1, 3):
		var mx := rng.randi_range(5, TW - 6)
		var my := rng.randi_range(6, fh - 4)
		img.set_pixel(mx, my, Color("#B8A890"))
		gl.set_pixel(mx, my - 1, Color("#C77DFF"))
		gl.set_pixel(mx - 1, my - 1, Color("#C77DFF", 0.6))
		gl.set_pixel(mx + 1, my - 1, Color("#C77DFF", 0.6))


static func _steppe(img: Image, gl: Image, rng: RandomNumberGenerator, fh: int, variant: int) -> void:
	# Ausgetrocknete Erde: Schollen mit Trockenrissen, ein paar Grasbüschel
	var pl := _plates(rng, fh, 7)
	var tones := [Color("#6A5E2A"), Color("#625627"), Color("#706430"), Color("#665A28"), Color("#6E6230"), Color("#5E5224"), Color("#726632")]
	for y in fh:
		for x in TW:
			var id := pl[y * TW + x]
			img.set_pixel(x, y, Color("#463E1C") if _is_seam(pl, x, y, fh) else tones[id])
	for i in 12:
		var x := rng.randi_range(3, TW - 4)
		var y := rng.randi_range(4, fh - 3)
		img.set_pixel(x, y, Color("#8A7E3A"))
		img.set_pixel(x - 1, y - 1, Color("#9A8E44"))
		img.set_pixel(x + 1, y - 1, Color("#9A8E44"))
	# Erdkabel mit Funken (nicht auf jeder Platte)
	if variant == 0:
		var cy := rng.randi_range(12, fh - 12)
		for x in range(2, TW - 2):
			var yy := cy + roundi(2.0 * sin(x * 0.12))
			img.set_pixel(x, yy, Color("#2A2A34"))
			img.set_pixel(x, yy - 1, Color("#4A4A58"))
		for i in 2:
			var sx := rng.randi_range(10, TW - 10)
			gl.set_pixel(sx, cy + roundi(2.0 * sin(sx * 0.12)) - 1, Color("#FFE45C"))
			gl.set_pixel(sx + 1, cy + roundi(2.0 * sin((sx + 1) * 0.12)) - 2, Color("#FFF6A8", 0.7))


static func _kern(img: Image, gl: Image, rng: RandomNumberGenerator, fh: int) -> void:
	_noise(img, rng, fh, ["#14263E", "#172A44", "#12223A"], 6, 4)
	# Plattenfugen
	var sx := TW / 2 + rng.randi_range(-8, 8)
	for y in fh:
		img.set_pixel(sx, y, Color("#0A1424"))
		img.set_pixel(sx + 1, y, Color("#22385A"))
	# Leiterbahnen mit Knoten (die Knoten pulsieren)
	for k in rng.randi_range(3, 5):
		var x := rng.randi_range(4, TW - 20)
		var y := rng.randi_range(5, fh - 6)
		var len1 := rng.randi_range(6, 16)
		var len2 := rng.randi_range(3, 8) * (1 if rng.randf() < 0.5 else -1)
		for d in len1:
			img.set_pixel(x + d, y, Color("#1E4A6A"))
		var ex := x + len1
		for d in absi(len2):
			var yy := clampi(y + d * signi(len2), 3, fh - 3)
			img.set_pixel(ex, yy, Color("#1E4A6A"))
		var ey := clampi(y + len2, 3, fh - 3)
		for p in [Vector2i(x, y), Vector2i(ex, ey)]:
			img.set_pixel(p.x, p.y, Color("#2E6A8A"))
			gl.set_pixel(p.x, p.y, Color("#4CC3F0"))
			gl.set_pixel(mini(p.x + 1, TW - 2), p.y, Color("#4CC3F0", 0.6))


## Vorderkante (Dicke der Platte): Materialfarbe, oben Lichtkante, unten dunkel
static func _front(img: Image, gl: Image, rng: RandomNumberGenerator, mat: String, fh: int) -> void:
	var base := Color(FRONT[mat])
	for y in range(fh, TH):
		var k := float(y - fh) / EDGE
		for x in TW:
			var c := base.darkened(0.3 * k)
			if mat == "sumpf" and x % 12 == 0:
				c = c.darkened(0.3)          # Plankenenden
			elif mat == "see" and x % 14 == 7 and y == fh + 2:
				c = Color("#8FB8D8")         # Nieten
			elif rng.randf() < 0.08:
				c = c.lightened(0.12)
			img.set_pixel(x, y, c)
	for x in TW:
		img.set_pixel(x, fh, base.lightened(0.3))
	# Wiesen: Gras hängt über die Kante, Vulkan: glimmende Fuge, Kern: Lichtleiste
	match mat:
		"wiesen":
			for x in range(1, TW - 1):
				if rng.randf() < 0.35:
					img.set_pixel(x, fh + 1, Color("#2C6A55"))
		"vulkan":
			for x in range(2, TW - 2):
				if x % 9 < 6:
					gl.set_pixel(x, fh + 3, Color("#FF6A2A", 0.8))
		"kern":
			for x in range(6, TW - 6):
				if x % 4 != 0:
					gl.set_pixel(x, fh + 2, Color("#4CC3F0", 0.7))
