extends "res://scripts/ui/cinema_canvas.gd"
## Trailer (09.10.2026): Kino-Bilder zwischen den echten Spielszenen und die Einblendungen darüber.
## Eine Instanz zeigt ein Bild (scene = world | corrupt | egg | chain | tree | legend | title), eine zweite liegt als
## Überlagerung über allem (scene = overlay: Texttafeln und Weißblitze nach der Gesamtzeit gt).

const LOGO_EGG := preload("res://assets/logo/digiei_64.png")
const BEAT := 0.5

var scene := ""
var lt := 0.0            # Zeit im Bild
var gt := 0.0            # Gesamtzeit (nur Überlagerung)
var text := ""           # Bildunterschrift im Kinobalken (world, corrupt, egg)
var form := ""           # legend: der Legendäre, der als Umriss schlüpft
var chains: Array = []   # chain: zwei Entwicklungsreihen [{el, forms: [Baby, Rookie, Champion, Ultra]}]
var tree := {}           # tree: {baby, rows: [[Rookie, Champion, Ultra], …]}
var lineup: Array = []   # title: Glitchlinge vor dem Logo
var cards: Array = []    # overlay: {at, dur, kind: word | line | caption, text, text2}
var flashes: Array = []  # overlay: {at, dur}


func _ready() -> void:
	if scene == "corrupt":
		_read_eyes()


func _process(delta: float) -> void:
	anim_t += delta
	lt += delta
	gt += delta
	shake = maxf(0.0, shake - delta * 12.0)
	queue_redraw()


func _draw() -> void:
	if scene == "overlay":
		_draw_overlay()
		return
	off = Vector2(randf_range(-shake, shake), randf_range(-shake, shake)).round() if Settings.screen_shake else Vector2.ZERO
	draw_set_transform(off)
	draw_rect(Rect2(-8, -8, W + 16, H + 16), Color("#05030C"))
	match scene:
		"world":
			_draw_world(_smooth(lt / 4.4) * 1450.0 + 60.0, 0.0)
		"corrupt":
			var k := clampf((lt - 0.3) / 3.2, 0.0, 1.0)
			shake = maxf(shake, k * 1.6)
			_draw_world(WORLD_CAM_END, k, _smooth((lt - 0.4) / 2.4))
		"egg":
			_draw_hatch_egg()
		"chain":
			_draw_chain()
		"tree":
			_draw_tree()
		"legend":
			_draw_legend()
		"title":
			_draw_title_card()
	draw_set_transform(Vector2.ZERO)
	if scene in ["world", "corrupt", "egg"]:
		_vignette()
		_letterbox(1.0, text, lt)
		if scene == "world" and lt < 0.8:
			draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 1.0 - lt / 0.8))


# ---------- Ei: Herzschlag, Risse, Schlüpfen (taktgenau zum Abschnitt „egg“, Herzschläge auf 0 / 0,375 s je Takthälfte) ----------

const HATCH_AT := 4.0
const HEART := [0.0, 0.375, 1.0, 1.375, 2.0, 2.375, 3.0, 3.375]
const CRACKS := [[2.0, [Vector2(-6, -70), Vector2(-2, -62), Vector2(-8, -54), Vector2(-3, -46)]],
	[3.0, [Vector2(4, -80), Vector2(10, -70), Vector2(5, -62), Vector2(12, -52)]],
	[3.5, [Vector2(-3, -46), Vector2(4, -40), Vector2(-2, -32), Vector2(6, -26)]]]
var baby := "Pixmiez"


func _draw_hatch_egg() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#0B0718"))
	for y in range(0, H, 2):
		draw_rect(Rect2(0, y, W, 1), Color(1, 1, 1, 0.025))
	var c := Vector2(W / 2.0, 236.0)
	if lt < HATCH_AT:
		var beat := 0.0
		for b in HEART:
			if lt >= b:
				beat = maxf(beat, 1.0 - (lt - b) / 0.22)
		var glow := clampf(lt / HATCH_AT, 0.0, 1.0)
		for i in 12:
			var a := i * TAU / 12.0 + anim_t * 0.3
			var d := Vector2(cos(a), sin(a))
			var n := Vector2(-d.y, d.x)
			var o := c - Vector2(0, 50)
			draw_colored_polygon(PackedVector2Array([o, o + d * 420.0 + n * 26.0, o + d * 420.0 - n * 26.0]), Color("#FFF6C8", 0.02 + 0.12 * glow * glow))
		draw_circle(c - Vector2(0, 50), 56.0 + 18.0 * beat, Color("#FFF6C8", 0.05 + 0.12 * beat + 0.1 * glow))
		# wackelt stärker, je näher das Schlüpfen kommt (letzte halbe Sekunde: Trommelwirbel)
		var amp := 0.04 * beat + (0.18 * (lt - 3.5) / 0.5 if lt > 3.5 else 0.0)
		var wob := sin(anim_t * 38.0) * amp
		_draw_egg_tex(c, 4, wob, off)
		for cr in CRACKS:
			if lt > cr[0]:
				var pts: Array = cr[1]
				for i in pts.size() - 1:
					draw_line(c + pts[i], c + pts[i + 1], GameData.COL.dark, 3.0)
					draw_line(c + pts[i], c + pts[i + 1], Color("#FFF6C8", maxf(glow, beat)), 1.0)
		return
	# geschlüpft: Lichtkranz in Elementfarbe, das Baby springt heraus
	var k := lt - HATCH_AT
	var el: Color = GameData.EL[GameData.FORMS[baby].el].lightened(0.2)
	for i in 14:
		var a := i * TAU / 14.0 + k * 0.4
		var d1 := Vector2(cos(a - 0.08), sin(a - 0.08)) * 460.0
		var d2 := Vector2(cos(a + 0.08), sin(a + 0.08)) * 460.0
		var o := c - Vector2(0, 60)
		draw_colored_polygon(PackedVector2Array([o, o + d1, o + d2]), Color(el, 0.12))
	draw_circle(c - Vector2(0, 60), 80.0, Color(el, 0.10))
	# Eierschalen fliegen weg
	for i in 6:
		var dir := Vector2(cos(i * 1.1 - 2.6), sin(i * 1.1 - 2.6) - 0.4)
		var p := c - Vector2(0, 40) + dir * k * 260.0 + Vector2(0, 300.0 * k * k)
		draw_rect(Rect2(p.round(), Vector2(8, 6)), Color("#F4ECD8", clampf(1.0 - k, 0.0, 1.0)))
	var hop := roundi(maxf(0.0, sin(minf(k, 0.5) / 0.5 * PI)) * 22.0)
	draw_rect(Rect2(c.x - 54, c.y - 2, 108, 6), Color(0.05, 0.02, 0.12, 0.5))
	_draw_sprite(baby, c.x, c.y - hop, false, {"scale": 4, "blink": fmod(anim_t, 2.6) < 0.12})
	_sparkles(c - Vector2(0, 70), el, k)


func _sparkles(c: Vector2, col: Color, k: float) -> void:
	for i in 18:
		var a := i * 2.399 + k * 0.6
		var r := 40.0 + fmod(i * 37.0 + k * 90.0, 170.0)
		var p := c + Vector2(cos(a), sin(a) * 0.7) * r
		var tw := 0.5 + 0.5 * sin(anim_t * 9.0 + i)
		draw_rect(Rect2(p.round(), Vector2(2, 2)), Color(col.lightened(0.5), 0.8 * tw))


# ---------- Entwicklungsreihen: je Schlag eine Stufe, das Monster wächst (Baby > Rookie > Champion > Ultra) ----------

const STAGE_SCALE := {1: 3, 2: 2, 3: 2, 4: 2}


func _draw_chain() -> void:
	var li := clampi(int(lt / 2.0), 0, chains.size() - 1)
	var ch: Dictionary = chains[li]
	var k := lt - li * 2.0
	var si := clampi(int(k / BEAT), 0, 3)
	var form: String = ch.forms[si]
	var el: Color = GameData.EL[ch.el]
	# Hintergrund: Raster in Elementfarbe, Lichtsäule, Strahlenkranz
	draw_rect(Rect2(0, 0, W, H), Color("#07040F"))
	for x in range(0, W, 32):
		draw_rect(Rect2(x, 0, 1, H), Color(el, 0.08))
	for y in range(0, H, 32):
		draw_rect(Rect2(0, y, W, 1), Color(el, 0.08))
	var c := Vector2(W / 2.0, 292.0)
	var body := c - Vector2(0, 90)
	var bk := k - si * BEAT
	for i in 12:
		var a := i * TAU / 12.0 + lt * 0.5
		var d1 := Vector2(cos(a - 0.07), sin(a - 0.07)) * 460.0
		var d2 := Vector2(cos(a + 0.07), sin(a + 0.07)) * 460.0
		draw_colored_polygon(PackedVector2Array([body, body + d1, body + d2]), Color(el, 0.08 + 0.05 * si))
	draw_rect(Rect2(c.x - 50 - si * 10, 0, 100 + si * 20, H), Color(el, 0.06 + 0.03 * si))
	# frühere Stufen klein am Rand (der Weg bis hierher)
	for j in si:
		var sx := 64.0 + j * 64.0
		_draw_sprite(ch.forms[j], sx, 330.0, false, {"scale": 1, "mod": Color(1, 1, 1, 0.55)})
	draw_rect(Rect2(c.x - 70, c.y - 2, 140, 6), Color(0.05, 0.02, 0.12, 0.5))
	# Neue Stufe: kurz weiß, dann farbig
	_draw_sprite(form, c.x, c.y, false, {"scale": STAGE_SCALE[GameData.FORMS[form].stage], "flash": bk < 0.06})
	_sparkles(body, el, lt)
	# Beschriftung: Element oben, Form und Stufe unten rechts
	_text(Vector2(0, 46), T.t("%s-Chips") % T.t(ch.el), 16, el, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	_text(Vector2(0, 330), T.t(form), 16, el.lightened(0.25), HORIZONTAL_ALIGNMENT_RIGHT, W - 40, true, true)
	_text(Vector2(0, 346), T.t(GameData.STAGE_NAMES[GameData.FORMS[form].stage]), 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, W - 40)
	if bk < 0.1:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 0.35 * (1.0 - bk / 0.1)))


# ---------- Stammbaum: ein Baby, drei Wege (Spalte für Spalte auf den Schlag) ----------

const TREE_X := [86.0, 222.0, 372.0, 528.0]
const TREE_Y := [134.0, 224.0, 314.0]


func _draw_tree() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#07040F"))
	for x in range(0, W, 32):
		draw_rect(Rect2(x, 0, 1, H), Color(GameData.COL.line, 0.15))
	var shown := clampi(int(lt / BEAT) + 1, 1, 4)
	var bc := Vector2(TREE_X[0], 244.0)
	var rows: Array = tree.rows
	# Verbindungen mit wandernden Lichtpunkten
	for ri in rows.size():
		var row: Array = rows[ri]
		var el: Color = GameData.EL[GameData.FORMS[row[0]].el]
		var prev := bc - Vector2(0, 30)
		for si in row.size():
			var col := si + 1
			if col >= shown:
				break
			var p := Vector2(TREE_X[col] + (16.0 if col == 3 and ri == 1 else 0.0), TREE_Y[ri] - 30.0)
			var grow := clampf((lt - (col - 1) * BEAT) / 0.25, 0.0, 1.0)
			var q := prev.lerp(p, grow)
			draw_line(prev, q, Color(el, 0.35), 4.0)
			draw_line(prev, q, el.lightened(0.3), 2.0)
			var m := prev.lerp(q, fmod(anim_t * 0.8 + ri * 0.3 + si * 0.2, 1.0))
			draw_rect(Rect2(m.round() - Vector2(2, 2), Vector2(4, 4)), Color.WHITE)
			prev = p
	_draw_sprite(tree.baby, bc.x, bc.y, false, {"scale": 2})
	for ri in rows.size():
		var row: Array = rows[ri]
		for si in row.size():
			var col := si + 1
			if col >= shown:
				break
			var bk := lt - (col - 1) * BEAT - 0.25
			var x: float = TREE_X[col] + (16.0 if col == 3 and ri == 1 else 0.0)
			_draw_sprite(row[si], x, TREE_Y[ri], false, {"scale": 1, "flash": bk < 0.08 and bk > -0.25})
	# Kinobalken, unten die große Zeile (erst „Ein Ei. Viele Wege.“, dann die Zahl der Formen)
	draw_rect(Rect2(0, 0, W, LB - 8), Color.BLACK)
	draw_rect(Rect2(0, H - LB + 4, W, LB - 4), Color.BLACK)
	if lt >= 0.6 and lt < 2.0:
		_big_line(T.t("EIN EI. VIELE WEGE."), H - 11.0, lt - 0.6)
	elif lt >= 2.0:
		_big_line(T.t("%d FORMEN ZU ENTDECKEN") % int(tree.get("count", 114)), H - 11.0, lt - 2.0)


## Eine Zeile Silkscreen 24 mit Farbversatz, kurz flackernd beim Erscheinen
func _big_line(s: String, y: float, k: float) -> void:
	var f := font(true, 24)
	var jit := Vector2(roundi(sin(anim_t * 120.0) * 4.0), 0) if k < 0.14 else Vector2.ZERO
	var a := clampf(k / 0.08, 0.0, 1.0)
	draw_string(f, Vector2(0, y) + Vector2(-1, 0) + jit, s, HORIZONTAL_ALIGNMENT_CENTER, W, 24, Color("#4CC3F0", 0.75 * a))
	draw_string(f, Vector2(0, y) + Vector2(1, 0) - jit, s, HORIZONTAL_ALIGNMENT_CENTER, W, 24, Color("#FF5470", 0.75 * a))
	draw_string(f, Vector2(0, y), s, HORIZONTAL_ALIGNMENT_CENTER, W, 24, Color(GameData.COL.ink, a))


# ---------- Legendär: goldenes Ei, daraus schlüpft ein Umriss (Geheimnis, 09.10.2026) ----------

const LEGEND_AT := 1.0
const GOLD := Color("#FFD84D")


func _draw_legend() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#0B0718"))
	var c := Vector2(W / 2.0, 272.0)
	var glow := clampf(lt / LEGEND_AT, 0.0, 1.0)
	var o := c - Vector2(0, 70)
	for i in 14:
		var a := i * TAU / 14.0 + anim_t * 0.35
		var d1 := Vector2(cos(a - 0.08), sin(a - 0.08)) * 460.0
		var d2 := Vector2(cos(a + 0.08), sin(a + 0.08)) * 460.0
		draw_colored_polygon(PackedVector2Array([o, o + d1, o + d2]), Color(GOLD, 0.05 + 0.08 * (glow if lt < LEGEND_AT else 1.0)))
	_sparkles(o, GOLD, lt)
	if lt < LEGEND_AT:
		draw_circle(o, 50.0 + 20.0 * glow, Color(GOLD, 0.08 + 0.1 * glow))
		var wob := sin(anim_t * 40.0) * 0.12 * glow
		draw_set_transform(off, 0, Vector2.ONE)
		_draw_gold_egg(c, wob)
		return
	var k := lt - LEGEND_AT
	draw_circle(o, 90.0, Color(GOLD, 0.08))
	_draw_sprite(form, c.x, c.y, false, {"scale": 2, "mystery": true, "rim": GOLD})
	_text(Vector2(0, H - 20), "???", 24, Color(GOLD, clampf(k / 0.3, 0.0, 1.0)), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	if k < 0.3:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k / 0.3))


## Leuchtendes Ei der Legendären (wie im Brutnest: golden getönt), 4-fach, leicht wackelnd
func _draw_gold_egg(feet: Vector2, tilt: float) -> void:
	var sc := 4
	draw_set_transform(off + Vector2(roundi(feet.x), roundi(feet.y)), tilt, Vector2(sc, sc))
	draw_texture(EGG, Vector2(-EGG.get_width() / 2.0, -EGG.get_height()), Color(1.25, 1.1, 0.55))
	draw_set_transform(off)


# ---------- Logo ----------

func _draw_title_card() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#07040F"))
	for i in 40:
		var x := fmod(i * 83.0, W)
		var y := fmod(i * 47.0 - anim_t * (10.0 + i % 5 * 6.0), H)
		if y < 0:
			y += H
		draw_rect(Rect2(x, y, 2, 2), Color([Color("#6EE7C5"), Color("#FFD84D"), Color("#C9B8FF")][i % 3], 0.4))
	# Glitchlinge stehen unten auf einem leuchtenden Boden
	var gk := clampf((lt - 0.4) / 0.6, 0.0, 1.0)
	draw_rect(Rect2(0, 318, W, 42), Color("#6EE7C5", 0.08 * gk))
	draw_rect(Rect2(0, 318, W, 1), Color("#6EE7C5", 0.5 * gk))
	for i in lineup.size():
		var x := W / 2.0 + (i - (lineup.size() - 1) / 2.0) * 118.0
		var appear := lt - 0.4 - i * 0.12
		if appear > 0:
			_draw_sprite(lineup[i], x, 322.0, false, {"scale": 1, "flash": appear < 0.08, "mod": Color(1, 1, 1, 0.92)})
	# Logo: Ei + Schriftzug wie auf dem Titelbildschirm, mit Glitch beim Erscheinen
	var logo := "GLITCHLINGS"
	var y := 104.0
	var f := font(true, 24)
	var jit := Vector2(roundi(sin(anim_t * 90.0) * 3.0), 0) if lt < 0.35 or fmod(lt, 2.7) < 0.06 else Vector2.ZERO
	var tw := roundi(f.get_string_size(logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x) * 2
	var lx := roundi((W - 64 - 4 - tw) / 2.0)
	draw_texture(LOGO_EGG, Vector2(lx, y - 52) + jit)
	draw_set_transform(Vector2(lx + 68, 0), 0, Vector2(2, 2))
	var lp := Vector2(0, y / 2)
	draw_string(f, lp + Vector2(-1, 0) + jit, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#4CC3F0", 0.8))
	draw_string(f, lp + Vector2(1, 0) - jit, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#FF5470", 0.8))
	draw_string_outline(f, lp, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 4, GameData.COL.dark)
	draw_string(f, lp, logo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, GameData.COL.ink)
	draw_set_transform(Vector2.ZERO)
	var a1 := clampf((lt - 1.0) / 0.4, 0.0, 1.0)
	_text(Vector2(0, 140), "Brüten. Kämpfen. Entwickeln.", 16, Color(GameData.COL.mint, a1), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	var a2 := clampf((lt - 2.2) / 0.4, 0.0, 1.0)
	_text(Vector2(0, 176), "Bald auf Steam", 24, Color(GameData.COL.sun, a2), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	_text(Vector2(0, 194), "PC · Steam Deck", 8, Color(GameData.COL.ink, a2), HORIZONTAL_ALIGNMENT_CENTER, W)
	_text(Vector2(0, H - 8), "© 2026 TheGoderGuy", 8, Color(GameData.COL.muted, 0.7 * a2), HORIZONTAL_ALIGNMENT_RIGHT, W - 8)
	# Ausblenden in die Schwärze
	if lt > 7.6:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, clampf((lt - 7.6) / 1.2, 0.0, 1.0)))


# ---------- Überlagerung: Texttafeln und Blitze ----------

func _draw_overlay() -> void:
	for c in cards:
		var k: float = gt - c.at
		if k < 0.0 or k > c.dur:
			continue
		match c.kind:
			"word":
				_card_text([c.text], k, c.dur, 2, c.get("y", 180.0))
			"line":
				_card_text([c.text] if c.get("text2", "") == "" else [c.text, c.text2], k, c.dur, 1, c.get("y", 180.0))
			"caption":
				_caption(c.text, k, c.dur)
	for fl in flashes:
		var k: float = gt - fl.at
		if k >= 0.0 and k < fl.dur:
			draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, 1.0 - k / fl.dur))


## Große Tafel (Silkscreen 24, sc = Vergrößerung): dunkles Band, Farbversatz Cyan/Magenta, Glitch beim Ein- und Ausblenden
func _card_text(lines: Array, k: float, dur: float, sc: int, cy: float) -> void:
	var a := clampf(k / 0.08, 0.0, 1.0) * clampf((dur - k) / 0.15, 0.0, 1.0)
	var glitch := k < 0.14 or dur - k < 0.12
	var lh := 30.0 * sc
	var band_h := lh * lines.size() + 18.0
	draw_rect(Rect2(0, cy - band_h / 2.0, W, band_h), Color(0.02, 0.01, 0.06, 0.62 * a))
	draw_rect(Rect2(0, cy - band_h / 2.0, W, 1), Color("#6EE7C5", 0.5 * a))
	draw_rect(Rect2(0, cy + band_h / 2.0 - 1, W, 1), Color("#6EE7C5", 0.5 * a))
	var f := font(true, 24)
	for li in lines.size():
		var s: String = T.t(lines[li])
		var base_y := cy - band_h / 2.0 + 9.0 + lh * (li + 0.78)
		var jit := Vector2(roundi(sin(anim_t * 120.0 + li) * 4.0), 0) if glitch else Vector2.ZERO
		draw_set_transform(Vector2.ZERO, 0, Vector2(sc, sc))
		var p := Vector2(0, base_y / sc)
		var w := W / float(sc)
		draw_string(f, p + Vector2(-1, 0) + jit / sc, s, HORIZONTAL_ALIGNMENT_CENTER, w, 24, Color("#4CC3F0", 0.75 * a))
		draw_string(f, p + Vector2(1, 0) - jit / sc, s, HORIZONTAL_ALIGNMENT_CENTER, w, 24, Color("#FF5470", 0.75 * a))
		draw_string_outline(f, p, s, HORIZONTAL_ALIGNMENT_CENTER, w, 24, 4, Color(GameData.COL.dark, a))
		draw_string(f, p, s, HORIZONTAL_ALIGNMENT_CENTER, w, 24, Color(GameData.COL.ink, a))
		draw_set_transform(Vector2.ZERO)
	# Glitch-Streifen beim Erscheinen
	if glitch:
		var rng := RandomNumberGenerator.new()
		rng.seed = int(anim_t * 30.0)
		for i in 6:
			draw_rect(Rect2(rng.randi_range(-20, W), cy + rng.randi_range(-int(band_h / 2.0), int(band_h / 2.0)), rng.randi_range(40, 220), rng.randi_range(1, 4)), Color("#4CC3F0", 0.45) if i % 2 else Color("#FF5470", 0.45))


## Bildunterschrift über dem Spielfeld (oben, unter der HUD-Zeile), gleitet kurz herein
func _caption(s: String, k: float, dur: float) -> void:
	var a := clampf(k / 0.12, 0.0, 1.0) * clampf((dur - k) / 0.2, 0.0, 1.0)
	var slide := roundf((1.0 - clampf(k / 0.18, 0.0, 1.0)) * 24.0)
	var y := 62.0
	draw_rect(Rect2(0, y - 15, W, 22), Color(0.02, 0.01, 0.06, 0.7 * a))
	draw_rect(Rect2(0, y - 15, W, 1), Color("#FFD84D", 0.6 * a))
	_text(Vector2(slide, y), s, 16, Color(GameData.COL.ink, a), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
