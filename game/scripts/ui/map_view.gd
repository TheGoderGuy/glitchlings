extends PixelCanvas
## Zonenkarte: nächsten Knoten wählen (links/rechts), betreten (bestätigen), Pause mit Deck.

signal node_chosen
signal gave_up

const MAP_X0 := 180.0
const MAP_W := 280.0
const FLOOR0_Y := 330.0
const BOSS_Y := 62.0

## 9×9-Symbole je Knotentyp
const ICONS := {
	"fight": ["......##.", ".....###.", "....###..", "#..###...", ".####....", "..##.....", ".####....", "##..#....", "#........"],
	"elite": ["#.......#", "##.....##", ".#######.", "##.###.##", "#..#.#..#", "#########", ".#.#.#.#.", "..#####..", "........."],
	"rest": [".##...##.", "####.####", "#########", "#########", ".#######.", "..#####..", "...###...", "....#....", "........."],
	"event": ["..#####..", ".##...##.", ".......##", "......##.", "....##...", "....##...", ".........", "....##...", "....##..."],
	"shop": ["..#####..", ".#..#..#.", "#..###..#", "#.#.#...#", "#..###..#", "#...#.#.#", "#..###..#", ".#..#..#.", "..#####.."],
	"boss": ["#...#...#", "##.###.##", "#########", "#########", "#.#.#.#.#", "#########", ".........", ".........", "........."],
}
const ICON_COL := {
	"fight": Color("#FF7A93"), "elite": Color("#FFC83D"), "rest": Color("#6EE7C5"),
	"event": Color("#C77DFF"), "shop": Color("#58D68D"), "boss": Color("#FF5470"),
}

var run: RunState
var sel := 0
var paused := false
var pause_idx := 0


func setup(run_state: RunState) -> void:
	run = run_state
	var ch := run.next_choices()
	# Standardauswahl: der Knoten, der am nächsten an der aktuellen Position liegt
	sel = 0
	if run.floor_idx >= 0 and ch.size() > 1:
		var cx: float = run.current_node().x
		var best := 99.0
		for i in ch.size():
			var d := absf(run.map.node(run.floor_idx + 1, ch[i]).x - cx)
			if d < best:
				best = d
				sel = i


func _process(delta: float) -> void:
	anim_t += delta
	if paused:
		if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("back"):
			paused = false
			Sfx.play("back")
		elif Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
			pause_idx = 1 - pause_idx
			Sfx.play("select")
		elif Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			if pause_idx == 0:
				paused = false
			else:
				set_process(false)
				gave_up.emit()
		queue_redraw()
		return
	var ch := run.next_choices()
	if Input.is_action_just_pressed("pause"):
		paused = true
		pause_idx = 0
		Sfx.play("select")
	elif Input.is_action_just_pressed("move_left") and ch.size() > 1:
		sel = (sel + ch.size() - 1) % ch.size()
		Sfx.play("select")
	elif Input.is_action_just_pressed("move_right") and ch.size() > 1:
		sel = (sel + 1) % ch.size()
		Sfx.play("select")
	elif Input.is_action_just_pressed("confirm") and not ch.is_empty():
		Sfx.play("confirm")
		run.enter(ch[sel])
		set_process(false)
		node_chosen.emit()
	queue_redraw()


func node_pos(f: int, i: int) -> Vector2:
	var n: Dictionary = run.map.node(f, i)
	var y := lerpf(FLOOR0_Y, BOSS_Y, float(f) / run.map.boss_floor())
	return Vector2(roundi(MAP_X0 + n.x * MAP_W), roundi(y))


func _draw() -> void:
	_draw_background()
	var m := run.map
	var ch := run.next_choices()
	var target := Vector2i(run.floor_idx + 1, ch[sel]) if not ch.is_empty() else Vector2i(-9, -9)
	_text(Vector2(0, 22), m.zone_name.to_upper(), 16, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)

	# Wege
	for f in m.floors.size() - 1:
		for i in m.floors[f].size():
			var a := node_pos(f, i)
			for j in m.floors[f][i].next:
				var b := node_pos(f + 1, j)
				var walked: bool = run.path.has(Vector2i(f, i)) and run.path.has(Vector2i(f + 1, j))
				var next: bool = f == run.floor_idx and i == run.pos and Vector2i(f + 1, j) == target
				var col: Color = GameData.COL.mint if walked else (GameData.COL.sun if next else Color(GameData.COL.line, 0.9))
				_dotted(a, b, col, 2 if walked or next else 1)
	# Startlinie zu Etage 0
	if run.floor_idx < 0:
		for i in ch:
			var b := node_pos(0, i)
			_dotted(Vector2(b.x, H - 8), b, GameData.COL.sun if i == target.y else Color(GameData.COL.line, 0.9), 1)

	# Knoten
	for f in m.floors.size():
		for i in m.floors[f].size():
			var n: Dictionary = m.node(f, i)
			var p := node_pos(f, i)
			var visited: bool = run.path.has(Vector2i(f, i))
			var here: bool = f == run.floor_idx and i == run.pos
			var selectable: bool = f == run.floor_idx + 1 and ch.has(i)
			var chosen: bool = Vector2i(f, i) == target
			var col: Color = ICON_COL[n.type]
			var past: bool = f <= run.floor_idx and not visited
			var size := 26 if n.type == "boss" else 18
			var r := Rect2(p - Vector2(size, size) / 2, Vector2(size, size))
			if chosen:
				r = r.grow(2 if sin(anim_t * 8.0) > 0 else 1)
			var border: Color = GameData.COL.sun if chosen else (GameData.COL.mint if here else (col.darkened(0.3) if selectable else GameData.COL.line))
			var fill: Color = GameData.COL.panel if (visited or selectable) else GameData.COL.bg2
			_box(r, fill, border)
			var ic := Color(col, 0.35 if past else (1.0 if (visited or selectable or n.type == "boss") else 0.6))
			_icon(ICONS[n.type], r.get_center(), 2 if n.type == "boss" else 1, ic)
			if here:
				_marker(p + Vector2(0, -size / 2.0 - 5))
	if run.floor_idx < 0:
		_marker(Vector2(node_pos(0, ch[sel]).x, H - 16))

	_draw_side_panels(target)
	if paused:
		_dim()
		var pr := Rect2(170, 40, 300, 280)
		_box(pr, GameData.COL.panel, GameData.COL.line)
		_text(pr.position + Vector2(0, 28), "Pause", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, pr.size.x, true, true)
		_text(pr.position + Vector2(0, 46), "Dein Deck (%d)" % run.deck.size(), 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, pr.size.x)
		_draw_deck_list(run.deck, pr.position.x + 24, pr.position.y + 66, pr.size.x - 48, 10)
		_menu(["Weiter", "Aufgeben"], pause_idx, pr.get_center().x, pr.end.y - 50, 160)


func _draw_side_panels(target: Vector2i) -> void:
	# Links: Monster + Run-Status
	var L := Rect2(8, 44, 150, 290)
	_box(L, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	var bob := 1 if sin(anim_t * 4.0) > 0 else 0
	draw_rect(Rect2(L.position.x + 45, L.position.y + 96, 60, 3), Color(0.05, 0.02, 0.12, 0.35))
	_draw_sprite(run.form, L.get_center().x, L.position.y + 98, false, {"bob": bob, "blink": fmod(anim_t, 3.3) < 0.13})
	var y := L.position.y + 116
	_text(Vector2(L.position.x + 8, y), run.form, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(Vector2(L.position.x + 8, y), GameData.STAGE_NAMES[run.stage], 8, GameData.EL[run.form_el()], HORIZONTAL_ALIGNMENT_RIGHT, L.size.x - 16)
	_bar(Rect2(L.position.x + 8, y + 6, L.size.x - 16, 9), float(run.hp) / run.max_hp, GameData.COL.mint)
	var rows := [["HP", "%d/%d" % [run.hp, run.max_hp], GameData.COL.ink], ["Fragmente", str(run.frag), GameData.COL.sun],
		["Deck", "%d Chips" % run.deck.size(), GameData.COL.ink], ["Etage", "%d/%d" % [maxi(0, run.floor_idx + 1), run.map.floors.size()], GameData.COL.ink]]
	y += 30
	for row in rows:
		_text(Vector2(L.position.x + 8, y), row[0], 8, GameData.COL.muted)
		_text(Vector2(L.position.x + 8, y), row[1], 8, row[2], HORIZONTAL_ALIGNMENT_RIGHT, L.size.x - 16)
		y += 15
	# Evolution
	y += 6
	var need := run.evo_need()
	if need > 0:
		var tgt := run.evo_target()
		_text(Vector2(L.position.x + 8, y), "Prägung", 8, GameData.COL.muted)
		_text(Vector2(L.position.x + 8, y), "%d/%d" % [mini(run.chips_used, need), need], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_RIGHT, L.size.x - 16)
		var ec: Color = GameData.EL[GameData.FORMS[tgt].el] if tgt != "" else GameData.COL.muted
		_bar(Rect2(L.position.x + 8, y + 5, L.size.x - 16, 7), float(run.chips_used) / need, ec)
		var dir: String = ("Richtung " + GameData.FORMS[tgt].el) if tgt != "" else "Richtung offen"
		_text(Vector2(L.position.x + 8, y + 26), dir, 8, ec)
	else:
		_text(Vector2(L.position.x + 8, y), "Höchste Stufe im Run", 8, GameData.COL.muted)
	if run.sp_bonus:
		_text(Vector2(L.position.x + 8, L.end.y - 8), "Signatur-Bonus!", 8, GameData.COL.sun)
	# Rechts: Auswahl
	var R := Rect2(W - 158, 44, 150, 150)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	if target.x >= 0:
		var n: Dictionary = run.map.node(target.x, target.y)
		_icon(ICONS[n.type], R.position + Vector2(16, 14), 1, ICON_COL[n.type])
		_text(R.position + Vector2(30, 18), ZoneMap.TYPE_NAMES[n.type], 8, ICON_COL[n.type], HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		draw_multiline_string(font(), R.position + Vector2(8, 40), ZoneMap.TYPE_DESC[n.type], HORIZONTAL_ALIGNMENT_LEFT, R.size.x - 16, 8, 8, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	var pad: bool = InputSetup.pad
	var hint := "< > Weg wählen\n%s betreten\n%s Pause + Deck" % ["A" if pad else "Enter", "Start" if pad else "Esc"]
	draw_multiline_string(font(), Vector2(W - 150, 214), hint, HORIZONTAL_ALIGNMENT_LEFT, 140, 8, 4, GameData.COL.muted)
	# Legende zweispaltig
	var G := Rect2(W - 158, 268, 150, 66)
	_box(G, Color(GameData.COL.bg2, 0.9), GameData.COL.line)
	var types := ["fight", "elite", "event", "rest", "shop", "boss"]
	for i in types.size():
		var gx := G.position.x + 12 + (i % 2) * 72
		var gy := G.position.y + 16 + (i / 2) * 19
		_icon(ICONS[types[i]], Vector2(gx, gy - 3), 1, ICON_COL[types[i]])
		_text(Vector2(gx + 10, gy), ZoneMap.TYPE_NAMES[types[i]].substr(0, 8), 8, GameData.COL.muted)


## Positionsmarker: kleiner hüpfender Pfeil in Mint
func _marker(p: Vector2) -> void:
	var b := 1 if sin(anim_t * 5.0) > 0 else 0
	for i in 4:
		draw_rect(Rect2(p.x - 4 + i, p.y - 6 + i + b, 9 - i * 2, 1), GameData.COL.mint)


func _icon(rows: Array, center: Vector2, scale: int, col: Color) -> void:
	var o := (center - Vector2(4.5, 4.5) * scale).round()
	for y in rows.size():
		var line: String = rows[y]
		for x in line.length():
			if line[x] == "#":
				draw_rect(Rect2(o + Vector2(x, y) * scale, Vector2(scale, scale)), col)


func _dotted(a: Vector2, b: Vector2, col: Color, size: int) -> void:
	var d := a.distance_to(b)
	var steps := int(d / 5.0)
	for s in range(1, steps):
		var p := a.lerp(b, float(s) / steps).round()
		draw_rect(Rect2(p - Vector2(size, size) / 2.0, Vector2(size, size)), col)
