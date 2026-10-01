extends PixelCanvas
## Zonenkarte: nächsten Knoten wählen (links/rechts), betreten (bestätigen), Pause mit Deck.

signal node_chosen
signal gave_up
signal save_quit

const MAP_X0 := 180.0
const MAP_W := 280.0
const FLOOR0_Y := 330.0
const BOSS_Y := 62.0

## 9×9-Symbole je Knotentyp
const ICONS := {
	"fight": ["......##.", ".....###.", "....###..", "#..###...", ".####....", "..##.....", ".####....", "##..#....", "#........"],
	"elite": ["#.......#", "##.....##", ".#######.", "##.###.##", "#..#.#..#", "#########", ".#.#.#.#.", "..#####..", "........."],
	"glitch": ["#.......#", "##..#..##", ".###.###.", "##.###.##", "#..#.#..#", "###.####.", ".#.#.#.#.", "..###.##.", "........."],
	"rest": [".##...##.", "####.####", "#########", "#########", ".#######.", "..#####..", "...###...", "....#....", "........."],
	"event": ["..#####..", ".##...##.", ".......##", "......##.", "....##...", "....##...", ".........", "....##...", "....##..."],
	"shop": ["..#####..", ".#..#..#.", "#..###..#", "#.#.#...#", "#..###..#", "#...#.#.#", "#..###..#", ".#..#..#.", "..#####.."],
	"guard": ["#########", "#.......#", "#.#####.#", "#.#...#.#", "#.#.#.#.#", "#...#...#", ".#.....#.", "..#...#..", "...###..."],
	"boss": ["#...#...#", "##.###.##", "#########", "#########", "#.#.#.#.#", "#########", ".........", ".........", "........."],
}
const ICON_COL := {
	"fight": Color("#FF7A93"), "elite": Color("#FFC83D"), "glitch": Color("#FF4FD8"), "rest": Color("#6EE7C5"),
	"event": Color("#C77DFF"), "shop": Color("#58D68D"), "guard": Color("#FF9A3D"), "boss": Color("#FF5470"),
}

var run: RunState
var sel := 0
var paused := false
var pause_idx := 0
var level_t := 0.0    # Einblendung „Ebene X“ beim Betreten einer neuen Ebene
var tip := false      # Erklärung der Zonenkarte beim allerersten Run
## Kurze Namen für die Legende (die Pixelschrift ist breit)
const LEGEND := {"fight": "Kampf", "elite": "Elite", "glitch": "Glitch", "event": "Ereignis", "rest": "Rast", "shop": "Händler", "guard": "Wächter", "boss": "Boss"}
const PAUSE_ITEMS := ["Weiter", "Handbuch", "Speichern und beenden", "Aufgeben"]


func setup(run_state: RunState) -> void:
	run = run_state
	Music.play(Music.zone_key("map", run.map.zone))
	if run.floor_idx < 0:
		level_t = 2.2
	tip = run.floor_idx < 0 and run.map.level == 0 and not SaveGame.data.get("map_tip_done", false)
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
	if handbook != null:
		queue_redraw()
		return
	level_t = maxf(0.0, level_t - delta)
	if tip:
		if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("back"):
			tip = false
			Sfx.play("confirm")
			SaveGame.data["map_tip_done"] = true
			SaveGame.save_game()
		queue_redraw()
		return
	if paused:
		if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("back"):
			paused = false
			Sfx.play("back")
		elif Input.is_action_just_pressed("move_up"):
			pause_idx = (pause_idx + PAUSE_ITEMS.size() - 1) % PAUSE_ITEMS.size()
			Sfx.play("select")
		elif Input.is_action_just_pressed("move_down"):
			pause_idx = (pause_idx + 1) % PAUSE_ITEMS.size()
			Sfx.play("select")
		elif Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			if pause_idx == 0:
				paused = false
			elif pause_idx == 1:
				open_handbook()
			elif pause_idx == 2:
				# Der Run ist beim Betreten der Karte schon gespeichert
				set_process(false)
				save_quit.emit()
			else:
				set_process(false)
				gave_up.emit()
		queue_redraw()
		return
	var ch := run.next_choices()
	if Input.is_action_just_pressed("handbook"):
		open_handbook()
	elif Input.is_action_just_pressed("pause"):
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
	_draw_zone(GameData.ZONES[run.map.zone].bg)
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.35))
	var m := run.map
	var ch := run.next_choices()
	var target := Vector2i(run.floor_idx + 1, ch[sel]) if not ch.is_empty() else Vector2i(-9, -9)
	_text(Vector2(0, 22), T.t(m.zone_name).to_upper(), 16, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	_text(Vector2(0, 34), T.t("Ebene %d von %d") % [m.level + 1, m.levels], 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)

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
			var size := 26 if n.type in ["boss", "guard"] else 18
			var r := Rect2(p - Vector2(size, size) / 2, Vector2(size, size))
			if chosen:
				r = r.grow(2 if sin(anim_t * 8.0) > 0 else 1)
			var border: Color = GameData.COL.sun if chosen else (GameData.COL.mint if here else (col.darkened(0.3) if selectable else GameData.COL.line))
			var fill: Color = GameData.COL.panel if (visited or selectable) else GameData.COL.bg2
			_box(r, fill, border)
			var ic := Color(col, 0.35 if past else (1.0 if (visited or selectable or n.type in ["boss", "guard"]) else 0.6))
			var jit := Vector2(1, 0) if n.type == "glitch" and fmod(anim_t + f * 0.37, 1.1) < 0.1 else Vector2.ZERO
			_icon(ICONS[n.type], r.get_center() + jit, 2 if n.type in ["boss", "guard"] else 1, ic)
			if here:
				_marker(p + Vector2(0, -size / 2.0 - 5))
	if run.floor_idx < 0:
		_marker(Vector2(node_pos(0, ch[sel]).x, H - 16))

	_draw_side_panels(target)
	if level_t > 0 and m.level > 0:
		# Neue Ebene: kurzes Einblenden in der Mitte
		var a := minf(1.0, level_t / 0.5)
		draw_rect(Rect2(0, 150, W, 50), Color(GameData.COL.dark, 0.75 * a))
		_text(Vector2(0, 180), T.t("EBENE %d") % (m.level + 1), 24, Color(GameData.COL.sun, a), HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		_text(Vector2(0, 194), "Der Wächter ist besiegt. Der Weg führt tiefer hinein.", 8, Color(GameData.COL.ink, a), HORIZONTAL_ALIGNMENT_CENTER, W)
	if tip:
		_draw_tip()
	if paused:
		_dim()
		var pr := Rect2(60, 30, 520, 300)
		_box(pr, GameData.COL.panel, GameData.COL.line)
		_text(pr.position + Vector2(0, 28), "Pause", 16, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, pr.size.x, true, true)
		_text(Vector2(pr.position.x + 20, pr.position.y + 46), T.t("Dein Deck (%d)") % run.deck.size(), 8, GameData.COL.muted)
		_draw_deck_list(run.deck, pr.position.x + 20, pr.position.y + 66, 220, 10)
		_text(Vector2(pr.position.x + 270, pr.position.y + 46), T.t("Module (%d)") % run.modules.size(), 8, GameData.COL.muted)
		_draw_module_list(run.modules, pr.position.x + 270, pr.position.y + 58, 230, 4)
		_menu(PAUSE_ITEMS, pause_idx, pr.get_center().x, pr.end.y - 88, 200)


func _draw_side_panels(target: Vector2i) -> void:
	# Links: Monster + Run-Status
	var L := Rect2(8, 36, 150, 300)
	_box(L, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	var bob := 1 if sin(anim_t * 4.0) > 0 else 0
	draw_rect(Rect2(L.position.x + 45, L.position.y + 88, 60, 3), Color(0.05, 0.02, 0.12, 0.35))
	_draw_sprite(run.form, L.get_center().x, L.position.y + 90, false, {"bob": bob, "blink": fmod(anim_t, 3.3) < 0.13})
	var y := L.position.y + 106
	_text(Vector2(L.position.x + 8, y), run.form, 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_text(Vector2(L.position.x + 8, y), GameData.STAGE_NAMES[run.stage], 8, GameData.EL[run.form_el()], HORIZONTAL_ALIGNMENT_RIGHT, L.size.x - 16)
	_bar(Rect2(L.position.x + 8, y + 6, L.size.x - 16, 9), float(run.hp) / run.max_hp, GameData.COL.mint)
	var rows := [["HP", "%d/%d" % [run.hp, run.max_hp], GameData.COL.ink], ["Fragmente", str(run.frag), GameData.COL.sun],
		["Deck", "%d Chips" % run.deck.size(), GameData.COL.ink], ["Ebene · Etage", "%d/%d · %d/%d" % [run.map.level + 1, run.map.levels, maxi(0, run.floor_idx + 1), run.map.floors.size()], GameData.COL.ink]]
	y += 27
	for row in rows:
		_text(Vector2(L.position.x + 8, y), row[0], 8, GameData.COL.muted)
		_text(Vector2(L.position.x + 8, y), row[1], 8, row[2], HORIZONTAL_ALIGNMENT_RIGHT, L.size.x - 16)
		y += 12
	# Evolution: mögliche Richtungen und Stand
	y += 4
	y += _draw_evo(run.evo_status(), L.position.x + 8, y, L.size.x - 16) + 10
	# Vorteile für den nächsten Kampf: unter der Evolution, sonst (wenn der Platz fehlt) unter dem Kasten
	var flags: Array = []
	if run.sp_bonus:
		flags.append(T.t("Signatur-Bonus!"))
	if run.foe_weak:
		flags.append(T.t("Gegner geschwächt!"))
	if not flags.is_empty():
		if y + 12 * (flags.size() - 1) <= L.end.y - 6:
			for fl in flags:
				_text(Vector2(L.position.x + 8, y), fl, 8, GameData.COL.sun)
				y += 12
		else:
			_text(Vector2(L.position.x + 2, L.end.y + 14), " · ".join(flags), 8, GameData.COL.sun)
	# Rechts: Auswahl
	var R := Rect2(W - 158, 44, 150, 150)
	_box(R, Color(GameData.COL.panel, 0.92), GameData.COL.line)
	if target.x >= 0:
		var n: Dictionary = run.map.node(target.x, target.y)
		_icon(ICONS[n.type], R.position + Vector2(16, 14), 1, ICON_COL[n.type])
		_text(R.position + Vector2(30, 18), ZoneMap.TYPE_NAMES[n.type], 8, ICON_COL[n.type], HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		draw_multiline_string(font(), R.position + Vector2(8, 40), T.t(ZoneMap.TYPE_DESC[n.type]), HORIZONTAL_ALIGNMENT_LEFT, R.size.x - 16, tsz(8), 8, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	var pad: bool = InputSetup.pad
	var hint := T.t("< > Weg wählen\n%s betreten\n%s Pause, Deck, Module\n%s Handbuch") % [InputSetup.btn("A") if pad else "Enter", InputSetup.btn("Start") if pad else "Esc", InputSetup.btn("Back") if pad else "H"]
	draw_multiline_string(font(), Vector2(W - 150, 214), hint, HORIZONTAL_ALIGNMENT_LEFT, 140, tsz(8), 4, GameData.COL.muted)
	# Module dieses Runs (Details in der Pause)
	if not run.modules.is_empty():
		_draw_module_row(run.modules, W - 154, 248, 9)
	# Legende zweispaltig
	var G := Rect2(W - 158, 262, 150, 74)
	_box(G, Color(GameData.COL.bg2, 0.9), GameData.COL.line)
	var types := ["fight", "elite", "glitch", "event", "rest", "shop", "guard", "boss"]
	for i in types.size():
		var gx := G.position.x + 12 + (i % 2) * 72
		var gy := G.position.y + 15 + (i / 2) * 16
		_icon(ICONS[types[i]], Vector2(gx, gy - 3), 1, ICON_COL[types[i]])
		_text(Vector2(gx + 10, gy), LEGEND[types[i]], 8, GameData.COL.muted)


## Erklärung beim ersten Run: Wege, Knoten, Ebenen, Wächter
func _draw_tip() -> void:
	var B := Rect2(150, 62, 340, 222)
	_box(B, Color(GameData.COL.panel, 0.97), GameData.COL.sun)
	_text(Vector2(B.position.x, B.position.y + 22), "Die Zonenkarte", 16, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, B.size.x, true, true)
	var pad: bool = InputSetup.pad
	var lines := [
		T.t("Wähle mit < > deinen Weg und betritt den nächsten Knoten mit %s. Es geht immer nach oben.") % (InputSetup.btn("A") if pad else "Enter"),
		T.t("Kampf, Elite, Ereignis, Rast, Händler: Was die Symbole bedeuten, steht rechts unten in der Legende."),
		T.t("Oben wartet ein Wächter. Besiegst du ihn, geht es auf die nächste Ebene. Nach der letzten Ebene kommt der Boss der Zone."),
		T.t("Mit %s siehst du jederzeit dein Deck und deine Module.") % (InputSetup.btn("Start") if pad else "Esc"),
	]
	var y := B.position.y + 44
	for l in lines:
		draw_rect(Rect2(B.position.x + 16, y - 7, 4, 4), GameData.COL.mint)
		var wrap := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
		draw_multiline_string(font(), Vector2(B.position.x + 26, y), l, HORIZONTAL_ALIGNMENT_LEFT, B.size.x - 42, tsz(8), 3, GameData.COL.ink, wrap)
		y += font().get_multiline_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, B.size.x - 42, tsz(8), 3, wrap).y + 10
	_text(Vector2(B.position.x, B.end.y - 10), T.t("%s los geht's") % (InputSetup.btn("A") if pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, B.size.x, true, true)


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
