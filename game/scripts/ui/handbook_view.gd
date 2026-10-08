extends PixelCanvas
## Kampf-Handbuch: 8 Seiten zum Nachschlagen (Konter, Resonanz und Reise seit 08.10.2026). Legt sich über jeden Bildschirm (Pause im Kampf, Karte,
## Station, Titel) – geöffnet mit PixelCanvas.open_handbook(). < > blättern, Esc/H schließt.

signal closed

const MapView := preload("res://scripts/ui/map_view.gd")

const PAGES := [
	{"title": "Das Spielfeld", "text": "Jede Seite hat 3 × 3 Felder: links deine, rechts die des Gegners. Du bewegst dich nur auf deinen Feldern, der Gegner nur auf seinen.\n\nDie meisten Angriffe fliegen über deine Reihe. Stell dich in die Reihe des Gegners! Aber Vorsicht: Viele Gegner schießen genauso entlang ihrer Reihe. Wer trifft, steht auch in der Schusslinie.\n\nBewegen: {move}."},
	{"title": "Chips", "text": "Du hast drei Slots ({chips}): zwei für Angriffe und einen Support-Slot für Schutz und Heilung. Die Angriffs-Slots ziehen aus deinem Angriffsstapel, der Support-Slot aus Schilden, Heilung und Hilfen. Nach dem Einsatz kommt der nächste Chip und lädt auf – drückst du zu früh, passiert nichts.\n\nÜber den Karten steht, welcher Chip als Nächstes kommt. Ist der Support-Stapel leer, wird er neu gemischt, das dauert etwas länger.\n\nDas Bild oben rechts auf der Karte zeigt, wo ein Angriff trifft. Verbesserte Chips (z. B. Glutball+) machen mehr Schaden und laden schneller."},
	{"title": "Ausweichen", "text": "Rote Felder mit „!“ werden gleich getroffen – geh rechtzeitig runter!\n\nKonter: Holt der Gegner aus, erscheint ein Fadenkreuz über ihm. Triffst du ihn genau dann, fällt sein Angriff aus, er ist kurz betäubt und dein Treffer macht 50 % mehr Schaden.\n\nGoldene Felder „!!“ sind Großangriffe von Wächtern und Bossen. Weichst du allen aus, ist der Gegner kurz überlastet. Lava brennt, Schleim macht langsam, Bitmilben und Sporen musst du zertreten."},
	{"title": "Elemente", "text": "Feuer schlägt Code, Code schlägt Wasser, Wasser schlägt Feuer. Elektro und Virus schlagen sich gegenseitig. Neutral ist weder stark noch schwach.\n\nEin Treffer mit Element-Vorteil macht 1,5-fachen Schaden, mit Nachteil nur 0,75-fachen.\n\nDas Element des Gegners steht oben rechts im Kampf. An jeder Weggabelung siehst du, ob dein Element gegen den nächsten Boss im Vorteil ist."},
	{"title": "Zustände und Kombos", "text": "Brand und Gift verursachen Schaden über Zeit. Eingefroren oder betäubt kann der Gegner kurz nichts tun, langsam bewegt und greift er halb so schnell an.\n\nKombos machen Chips richtig stark: Feuersbrunst trifft brennende Gegner doppelt, Datenfresser vergiftete, Frostsplitter eingefrorene sogar dreifach.\n\nIn der Chipwahl zeigt „Kombo mit …“, welcher Chip zu deinem Deck, deinen Modulen oder deinem Passiv passt."},
	{"title": "Signatur und Passiv", "text": "Jeder Treffer lädt deine Signatur-Leiste unten rechts. Ist sie voll, löst {special} die Signatur-Attacke aus. Jede Form hat ihre eigene – oft mit Zusatzwirkung wie Einfrieren oder Heilen.\n\nDazu hat jede Linie eine passive Fähigkeit, die immer wirkt, zum Beispiel Katzenreflex (weicht dem ersten Treffer aus) oder Regeneration.\n\nBeides steht in der Station im Team-Reiter."},
	{"title": "Entwicklung", "text": "Dein Glitchling entwickelt sich je nachdem, welche Element-Chips du spielst (Neutral zählt nicht). Rookie ab {evo2}, Champion ab {evo3}, Ultra ab {evo4} – gezählt über alle Runs. Die Richtung bestimmt das meistgespielte Element.\n\nAb Rookie wirkt die Resonanz: Chips im Element deiner Form machen mehr Schaden. Dazu kommt eine Gabe, z. B. Zündeln: Feuer-Treffer setzen Brand. Beides wird mit jeder Stufe stärker."},
	{"title": "Nach dem Kampf", "text": "Nach jedem Sieg wählst du einen neuen Chip für dein Deck oder überspringst für Fragmente. Fragmente brauchst du im Run beim Händler, danach für Labor und Ausbau.\n\nElite-Gegner sind stärker und geben ein Modul – einen Bonus für den ganzen Run. Glitch-Elite ist noch härter, belohnt aber mit epischen Chips.\n\nJede Zone hat 2 Ebenen: oben erst ein Wächter, dann der Boss. Danach wählst du die nächste Zone – bis zum NEST-Kern."},
]

var page := 0
var t_in := 0.0


func _ready() -> void:
	z_index = 50


func _process(delta: float) -> void:
	anim_t += delta
	t_in += delta
	if t_in < 0.15:
		queue_redraw()
		return
	if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("handbook"):
		close()
		return
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("confirm"):
		if page < PAGES.size() - 1:
			page += 1
			Sfx.play("select")
		elif Input.is_action_just_pressed("confirm"):
			close()
			return
	elif Input.is_action_just_pressed("move_left") and page > 0:
		page -= 1
		Sfx.play("select")
	queue_redraw()


func close() -> void:
	Sfx.play("back")
	set_process(false)
	closed.emit()


## Seitentext mit den passenden Tasten (Tastatur oder Controller)
func page_text(i: int) -> String:
	var pad: bool = InputSetup.pad
	var chips := "%s / %s / %s" % [InputSetup.btn("X"), InputSetup.btn("A"), InputSetup.btn("B")] if pad else "J / K / L"
	return T.t(PAGES[i].text).format({
		"move": T.t("Steuerkreuz oder linker Stick") if pad else T.t("%s oder Pfeiltasten") % InputSetup.move_keys(),
		"chips": chips,
		"special": InputSetup.btn("Y") if pad else InputSetup.key_text("special", "acc"),
		"evo2": GameData.EVO_AT[2], "evo3": GameData.EVO_AT[3], "evo4": GameData.EVO_AT[4],
	})


func _draw() -> void:
	draw_rect(Rect2(-8, -8, W + 16, H + 16), Color(GameData.COL.dark, 0.97))
	_text(Vector2(0, 24), "KAMPF-HANDBUCH", 16, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	# Seitenreiter 1–8
	var n := PAGES.size()
	for i in n:
		var r := Rect2(W / 2.0 - n * 13 + i * 26, 32, 22, 12)
		var active := i == page
		_box(r, GameData.COL.panel if active else GameData.COL.bg2, GameData.COL.sun if active else GameData.COL.line)
		_text(Vector2(r.position.x, r.position.y + 10), str(i + 1), 8, GameData.COL.sun if active else GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var P := Rect2(20, 50, 600, 278)
	_box(P, Color(GameData.COL.panel, 0.98), GameData.COL.line)
	var A := Rect2(P.position.x + 12, P.position.y + 12, 262, P.size.y - 24)
	draw_rect(A, Color(GameData.COL.bg2, 0.9))
	_illustration(page, A)
	var tx := A.end.x + 16
	var tw := P.end.x - tx - 14
	_text(Vector2(tx, P.position.y + 26), "%d. %s" % [page + 1, T.t(PAGES[page].title)], 16, GameData.COL.sun, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	draw_multiline_string(font(), Vector2(tx, P.position.y + 50), page_text(page), HORIZONTAL_ALIGNMENT_LEFT, tw, tsz(8), -1, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	var pad: bool = InputSetup.pad
	var foot := T.t("< > blättern   %s weiter   %s schließen") % [InputSetup.btn("A") if pad else "Enter", InputSetup.btn("B") if pad else "Esc"]
	_text(Vector2(0, H - 14), foot, 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


# ---------- Bilder zu den Seiten ----------

func _illustration(i: int, A: Rect2) -> void:
	match i:
		0:
			_illu_field(A)
		1:
			_illu_chips(A)
		2:
			_illu_dodge(A)
		3:
			_illu_elements(A)
		4:
			_illu_status(A)
		5:
			_illu_signature(A)
		6:
			_illu_evolution(A)
		7:
			_illu_after(A)


## Mini-Raster: 3 Spalten je Seite, Zellgröße cs, Lücke zwischen den Seiten
func _cell(o: Vector2, c: int, r: int, cs := 34.0) -> Rect2:
	return Rect2(o.x + c * cs + (8.0 if c >= 3 else 0.0), o.y + r * cs, cs - 3, cs - 3)


func _grid(o: Vector2, sides := 2, cs := 34.0) -> void:
	for c in 3 * sides:
		for r in 3:
			var cr := _cell(o, c, r, cs)
			draw_rect(cr, Color("#1F4A5A") if c < 3 else Color("#5A2440"))
			draw_rect(Rect2(cr.position, Vector2(cr.size.x, 2)), Color("#2E6E7E") if c < 3 else Color("#7E3458"))


func _enemy_blob(p: Vector2) -> void:
	draw_circle(p, 11.0, GameData.COL.dark)
	draw_circle(p, 10.0, Color("#B0306A"))
	draw_rect(Rect2(p.x - 6, p.y - 3, 3, 3), Color.WHITE)
	draw_rect(Rect2(p.x + 2, p.y - 3, 3, 3), Color.WHITE)
	for k in 3:
		draw_rect(Rect2(p.x - 8 + k * 6, p.y + 9, 2, 4), GameData.COL.dark)


func _illu_field(A: Rect2) -> void:
	var o := Vector2(A.position.x + 12, A.position.y + 60)
	_grid(o)
	var pc := _cell(o, 0, 1)
	var ec := _cell(o, 4, 1)
	_draw_sprite("Pixmiez", pc.get_center().x, pc.end.y - 1, false, {"scale": 1})
	_enemy_blob(ec.get_center())
	# Schuss fliegt über die Reihe
	var k := fmod(anim_t * 0.8, 1.0)
	var sx := lerpf(pc.end.x, ec.position.x + 6, k)
	draw_rect(Rect2(roundi(sx), roundi(pc.get_center().y - 2), 8, 4), Color("#FFD84D"))
	draw_rect(Rect2(o.x - 4, pc.position.y - 2, 6 * 34 + 14, pc.size.y + 4), Color(GameData.COL.sun, 0.5), false, 1.0)
	_text(Vector2(o.x, o.y + 3 * 34 + 14), "du", 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, 3 * 34)
	_text(Vector2(o.x + 3 * 34 + 8, o.y + 3 * 34 + 14), "Gegner", 8, GameData.COL.coral, HORIZONTAL_ALIGNMENT_CENTER, 3 * 34)
	_text(Vector2(A.position.x, A.end.y - 14), "Gleiche Reihe = Treffer", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, A.size.x)


func _illu_chips(A: Rect2) -> void:
	var names := ["Glutball+", "Pixelstrahl", "Heilpatch"]
	var pad: bool = InputSetup.pad
	var keys := [InputSetup.btn("X"), InputSetup.btn("A"), InputSetup.btn("B")] if pad else [InputSetup.key_label("chip_1"), InputSetup.key_label("chip_2"), InputSetup.key_label("chip_3")]
	for i in 3:
		var r := Rect2(A.position.x + 14, A.position.y + 30 + i * 52, A.size.x - 28, 44)
		var ch: Dictionary = GameData.chip(names[i])
		var el: Color = GameData.EL[ch.el]
		var charge := 1.0 if i != 1 else fmod(anim_t * 0.4, 1.0)
		var ready := charge >= 1.0
		var rc := Color(GameData.ROLE_COL[GameData.SLOT_ROLE[i]])
		_box(r, GameData.COL.panel if ready else GameData.COL.bg2, rc if ready else GameData.COL.line)
		_text(r.position + Vector2(0, -2), T.t(GameData.ROLE_NAMES[GameData.SLOT_ROLE[i]]), 8, rc, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 4, true, true)
		draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(3, r.size.y - 2)), el)
		var g := Rect2(r.position + Vector2(8, 6), Vector2(15, 14))
		_box(g, GameData.COL.dark, el)
		_text(g.position + Vector2(1, 11), keys[i], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, g.size.x, false, true)
		_text(r.position + Vector2(30, 17), names[i], 8, GameData.COL.sun if names[i].ends_with("+") else GameData.COL.ink, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		_text(r.position + Vector2(8, 34), GameData.chip_short(names[i]), 8, GameData.COL.muted)
		if ready:
			_text(r.position + Vector2(8, 34), "bereit", 8, rc, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 16)
		else:
			_bar(Rect2(r.position + Vector2(6, r.size.y - 8), Vector2(r.size.x - 12, 5)), charge, el.darkened(0.2))
	_text(Vector2(A.position.x + 14, A.position.y + 204), "Angriff | Angriff | Support", 8, GameData.COL.muted)


func _illu_dodge(A: Rect2) -> void:
	var o := Vector2(A.position.x + 80, A.position.y + 34)
	_grid(o, 1)
	var blink := 0.5 + 0.4 * sin(anim_t * 10.0)
	for c in 3:
		var cr := _cell(o, c, 0)
		draw_rect(cr, Color(GameData.COL.coral, blink))
		_text(cr.position + Vector2(0, 22), "!", 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, cr.size.x, true, true)
	for c in [0, 1]:
		var cr := _cell(o, c, 2)
		var gold := Color("#FFB23D")
		draw_rect(cr, Color(gold, 0.45 + 0.3 * blink))
		draw_rect(cr, gold, false, 2.0)
		_text(cr.position + Vector2(0, 22), "!!", 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, cr.size.x, true, true)
	var lava := _cell(o, 2, 1)
	draw_rect(lava, Color("#7A1F0E"))
	for k in 4:
		draw_rect(Rect2(lava.position.x + 4 + (k * 9) % 22, lava.position.y + 6 + (k * 7) % 18, 3, 3), Color("#FFB347", 0.6 + 0.4 * sin(anim_t * 8.0 + k)))
	var safe := _cell(o, 0, 1)
	_draw_sprite("Pixmiez", safe.get_center().x, safe.end.y - 1, false, {"scale": 1})
	var y := o.y + 3 * 34 + 20
	var legend := [[GameData.COL.coral, "Angriff: runter da!"], [Color("#FFB23D"), "Großangriff: ganz ausweichen"], [Color("#FF8A4C"), "Lava: brennt"]]
	for l in legend:
		draw_rect(Rect2(A.position.x + 30, y - 7, 8, 8), l[0])
		_text(Vector2(A.position.x + 44, y), l[1], 8, GameData.COL.ink)
		y += 16


func _illu_elements(A: Rect2) -> void:
	var c := Vector2(A.get_center().x, A.position.y + 96)
	var pts := {"Feuer": c + Vector2(0, -58), "Code": c + Vector2(62, 44), "Wasser": c + Vector2(-62, 44)}
	var order := [["Feuer", "Code"], ["Code", "Wasser"], ["Wasser", "Feuer"]]
	for pr in order:
		_arrow(pts[pr[0]], pts[pr[1]], GameData.EL[pr[0]])
	for k in pts:
		draw_circle(pts[k], 17.0, GameData.COL.dark)
		draw_circle(pts[k], 15.0, GameData.EL[k].darkened(0.2))
		_text(Vector2(pts[k].x - 40, pts[k].y + 30), k, 8, GameData.EL[k], HORIZONTAL_ALIGNMENT_CENTER, 80, true, true)
	_text(Vector2(c.x - 30, c.y + 12), "1,5×", 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, 60, true, true)
	# Elektro und Virus: gegenseitig
	var e := Vector2(A.position.x + 70, A.end.y - 34)
	var v := Vector2(A.end.x - 70, A.end.y - 34)
	_arrow(e, v, GameData.EL.Elektro, 12.0)
	_arrow(v, e, GameData.EL.Virus, 12.0)
	for p in [[e, "Elektro"], [v, "Virus"]]:
		draw_circle(p[0], 11.0, GameData.COL.dark)
		draw_circle(p[0], 9.0, GameData.EL[p[1]].darkened(0.2))
		_text(Vector2(p[0].x - 40, p[0].y + 24), p[1], 8, GameData.EL[p[1]], HORIZONTAL_ALIGNMENT_CENTER, 80, true, true)


## Pfeil von a nach b, am Kreisrand gekürzt
func _arrow(a: Vector2, b: Vector2, col: Color, trim := 20.0) -> void:
	var d := (b - a).normalized()
	var s := a + d * trim
	var e := b - d * trim
	draw_line(s, e, col, 2.0)
	var n := Vector2(-d.y, d.x)
	draw_colored_polygon(PackedVector2Array([e + d * 2.0, e - d * 7.0 + n * 5.0, e - d * 7.0 - n * 5.0]), col)


func _illu_status(A: Rect2) -> void:
	var rows := [["flame", "#FF8A4C", "Brand"], ["skull", "#C77DFF", "Gift"], ["snow", "#8FD8FF", "Eingefroren"], ["bolt", "#FFE45C", "Betäubt"], ["boot", "#7BD35A", "Langsam"]]
	for i in rows.size():
		var y := A.position.y + 22 + i * 40
		var p := Vector2(A.position.x + 30, y)
		draw_rect(Rect2(p - Vector2(3, 3), Vector2(24, 24)), GameData.COL.dark)
		var pic: Array = GameData.PICTOS[rows[i][0]]
		for py in 6:
			for px in 6:
				if pic[py][px] == "#":
					draw_rect(Rect2(p + Vector2(px * 3, py * 3), Vector2(3, 3)), Color(rows[i][1]))
		_text(Vector2(A.position.x + 70, y + 14), rows[i][2], 8, Color(rows[i][1]), HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)


func _illu_signature(A: Rect2) -> void:
	var cx := A.get_center().x
	draw_rect(Rect2(cx - 34, A.position.y + 112, 68, 5), Color(0.05, 0.02, 0.12, 0.4))
	_draw_sprite("Pixmiez", cx, A.position.y + 114, false, {"scale": 2})
	var sp := clampf(fmod(anim_t * 35.0, 130.0), 0.0, 100.0)
	var full := sp >= 100.0
	var R := Rect2(A.position.x + 40, A.position.y + 140, A.size.x - 80, 40)
	var pulse := full and sin(anim_t * 8.0) > 0
	_box(R, GameData.COL.panel if full else GameData.COL.bg2, GameData.COL.sun if full else GameData.COL.line)
	_text(R.position + Vector2(8, 16), "Signatur: Pixelsprung", 8, GameData.COL.sun if pulse or full else GameData.COL.muted, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
	_bar(Rect2(R.position + Vector2(6, R.size.y - 12), Vector2(R.size.x - 12, 6)), sp / 100.0, GameData.COL.sun if full else Color("#8A84A0"))
	_text(Vector2(A.position.x, A.end.y - 18), "Passiv: Katzenreflex", 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, A.size.x, true, true)


func _illu_evolution(A: Rect2) -> void:
	var bx := A.position.x + 46
	var by := A.position.y + A.size.y / 2.0 + 18
	_draw_sprite("Pixmiez", bx, by, false, {"scale": 2})
	var rooks := [["Firewallo", "Code"], ["Virulina", "Virus"], ["Prismiez", "Elektro"]]
	for i in rooks.size():
		var ry := A.position.y + 68 + i * 70
		var rx := A.end.x - 52
		_arrow(Vector2(bx + 30, by - 30), Vector2(rx - 24, ry - 30), GameData.EL[rooks[i][1]], 4.0)
		_draw_sprite(rooks[i][0], rx, ry, false, {"scale": 1})
		_text(Vector2(rx - 60, ry + 12), rooks[i][1], 8, GameData.EL[rooks[i][1]], HORIZONTAL_ALIGNMENT_CENTER, 120)


func _illu_after(A: Rect2) -> void:
	var rows := [["fight", "Kampf", "Chip + Fragmente"], ["elite", "Elite", "+ Modul"], ["glitch", "Glitch-Elite", "epische Chips"], ["guard", "Wächter", "nächste Ebene"], ["boss", "Boss", "Zone geschafft!"]]
	for i in rows.size():
		var y := A.position.y + 22 + i * 40
		var r := Rect2(A.position.x + 20, y - 4, 22, 22)
		var col: Color = MapView.ICON_COL[rows[i][0]]
		_box(r, GameData.COL.panel, col.darkened(0.3))
		var icon: Array = MapView.ICONS[rows[i][0]]
		var o := (r.get_center() - Vector2(9, 9)).round()
		for iy in icon.size():
			for ix in icon[iy].length():
				if icon[iy][ix] == "#":
					draw_rect(Rect2(o + Vector2(ix * 2, iy * 2), Vector2(2, 2)), col)
		_text(Vector2(A.position.x + 52, y + 6), rows[i][1], 8, col, HORIZONTAL_ALIGNMENT_LEFT, -1, true, true)
		_text(Vector2(A.position.x + 52, y + 18), rows[i][2], 8, GameData.COL.muted)
