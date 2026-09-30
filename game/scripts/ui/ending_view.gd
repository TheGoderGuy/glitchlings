extends PixelCanvas
## Ende nach dem Sieg über den Ur-Glitch: der NEST startet neu, die Glitchlings kehren heim, dein Team, Abspann.
## Spiegelt das Opening. Bestätigen = Text sofort zeigen bzw. weiter, Esc/Start = überspringen.

signal finished

const PANELS := [
	{"id": "reboot", "dur": 6.0, "text": ""},
	{"id": "return", "dur": 8.5, "text": "Der Ur-Glitch war besiegt. Einer nach dem anderen kehrten die Glitchlings nach Hause zurück."},
	{"id": "team", "dur": 7.5, "text": "Und mittendrin: dein Team. Der NEST ist wieder online. Danke, Operator."},
	{"id": "credits", "dur": 26.0, "text": ""},
	{"id": "end", "dur": 7.0, "text": ""},
]
const REBOOT_LINES := ["Ur-Glitch ... defragmentiert", "Korruption: 0 %", "NEST-Server v3.1 ... Neustart", "Bewohner: 4.096 Glitchlings ... zurück", "Status: alles friedlich"]
## Name im Abspann (an einer Stelle änderbar)
const CREATOR := "TheGoderGuy"
## Abspann: [Text, Größe, Farbe] – "" = Leerzeile
const CREDITS := [
	["GLITCHLINGS", 24, "ink"], ["", 8, ""],
	["Ein Spiel von", 8, "muted"], [CREATOR, 24, "sun"], ["", 8, ""],
	["Idee und Produktion", 8, "muted"], [CREATOR, 16, "sun"], ["", 8, ""],
	["Game Design", 8, "muted"], [CREATOR, 16, "sun"], ["", 8, ""],
	["Programmierung", 8, "muted"], [CREATOR, 16, "sun"], ["", 8, ""],
	["Pixel-Art-Regie", 8, "muted"], [CREATOR, 16, "sun"], ["", 8, ""],
	["Musik und Sound", 8, "muted"], [CREATOR, 16, "sun"], ["", 8, ""],
	["Monster und Gegner", 8, "muted"], ["erstellt mit PixelLab", 8, "ink"], ["", 8, ""],
	["Schrift", 8, "muted"], ["Pixeloid Sans von GGBotNet (SIL Open Font License)", 8, "ink"], ["Silkscreen von Jason Kottke (SIL Open Font License)", 8, "ink"], ["", 8, ""],
	["Engine", 8, "muted"], ["Godot 4", 8, "ink"], ["", 8, ""],
	["Besonderer Dank", 8, "muted"], ["an alle Spieltester", 8, "ink"], ["und an dich, Operator", 8, "ink"],
]
const TYPE_SPEED := 38.0
const FADE := 0.5

var idx := 0
var t := 0.0
var done := false
var played := {}
var team_forms: Array = []   # Formen für das Team-Bild (vom Aufrufer gesetzt, sonst Starter)


func _ready() -> void:
	Music.stop()
	if team_forms.is_empty():
		for m in SaveGame.team().slice(0, 5):
			team_forms.append(m.form)
	if team_forms.is_empty():
		team_forms = ["Pixmiez", "Funkling", "Tröpfel"]


func seek(total: float) -> void:
	idx = 0
	while idx < PANELS.size() - 1 and total >= PANELS[idx].dur:
		total -= PANELS[idx].dur
		idx += 1
	t = total
	anim_t = total


func _process(delta: float) -> void:
	anim_t += delta
	t += delta
	if done:
		return
	var p: Dictionary = PANELS[idx]
	_sounds(p.id)
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("back"):
		Sfx.play("back")
		_finish()
		return
	if Input.is_action_just_pressed("confirm") and t > 0.3:
		var full := _text_time(p) + 0.1
		if t < full and p.id != "credits":
			t = full
		else:
			_next()
	elif t >= p.dur:
		_next()
	queue_redraw()


func _text_time(p: Dictionary) -> float:
	var n: int = p.text.length()
	if p.id == "reboot":
		n = 0
		for l in REBOOT_LINES:
			n += l.length()
	return 0.4 + n / TYPE_SPEED


func _next() -> void:
	idx += 1
	t = 0.0
	played.clear()
	if idx >= PANELS.size():
		_finish()
	elif PANELS[idx].id == "return":
		Music.play("ending")


func _finish() -> void:
	done = true
	set_process(false)
	finished.emit()


func _sounds(id: String) -> void:
	var cues := {
		"reboot": [[0.6, "tick"], [1.3, "tick"], [2.0, "tick"], [2.8, "tick"], [3.6, "confirm"]],
		"team": [[0.6, "win"]],
	}
	for c in cues.get(id, []):
		if t >= c[0] and not played.has(c[1] + str(c[0])):
			played[c[1] + str(c[0])] = true
			Sfx.play(c[1], 0.0)


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#05030C"))
	if done:
		return
	var p: Dictionary = PANELS[idx]
	match p.id:
		"reboot":
			_draw_reboot()
		"return":
			_draw_return()
		"team":
			_draw_team()
		"credits":
			_draw_credits()
		"end":
			_draw_end()
	if p.text != "":
		var shown: String = p.text.substr(0, clampi(int((t - 0.4) * TYPE_SPEED), 0, p.text.length()))
		draw_rect(Rect2(0, H - 64, W, 64), Color(GameData.COL.dark, 0.82))
		draw_rect(Rect2(0, H - 64, W, 1), Color(GameData.COL.line, 0.8))
		draw_multiline_string(font(), Vector2(40, H - 40), shown, HORIZONTAL_ALIGNMENT_CENTER, W - 80, tsz(8), 3, GameData.COL.ink, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	var a := 0.0
	if t < FADE:
		a = 1.0 - t / FADE
	elif t > p.dur - FADE:
		a = (t - (p.dur - FADE)) / FADE
	if a > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, clampf(a, 0.0, 1.0)))
	var hint := "%s: weiter · %s: überspringen" % (["A", "Start"] if InputSetup.pad else ["Enter", "Esc"])
	_text(Vector2(0, 14), hint, 8, Color(GameData.COL.muted, 0.7), HORIZONTAL_ALIGNMENT_RIGHT, W - 10)


# ---------- Bilder ----------

## Terminal wie im Opening, aber diesmal startet alles wieder
func _draw_reboot() -> void:
	var green := Color("#6EE7C5")
	var budget := int(maxf(0.0, t - 0.4) * TYPE_SPEED)
	var y := 110.0
	for i in REBOOT_LINES.size():
		var l: String = REBOOT_LINES[i]
		var s: String = l.substr(0, clampi(budget, 0, l.length()))
		budget -= l.length()
		_text(Vector2(150, y), "> " + s, 8, Color("#FFD84D") if i == 0 else green, HORIZONTAL_ALIGNMENT_LEFT, -1, false)
		y += 18
		if budget < 0:
			break
	if fmod(anim_t, 0.8) < 0.4:
		draw_rect(Rect2(150, y - 8, 6, 9), green)
	for sy in range(0, H, 3):
		draw_rect(Rect2(0, sy, W, 1), Color(0, 0, 0, 0.18))


## Rückkehr: Pixelspuren fliegen von oben rechts herein und werden wieder zu Glitchlings (umgekehrte Flucht)
func _draw_return() -> void:
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	var babies := ["Pixmiez", "Funkling", "Tröpfel", "Kekso", "Lumi", "Quakli"]
	for i in babies.size():
		var start := 0.8 + i * 0.45
		var k := clampf((t - start) / 1.6, 0.0, 1.0)
		var bx := 70.0 + i * 100.0
		var by := 262.0
		if k < 1.0 and k > 0.0:
			for j in 12:
				var pk := clampf(1.0 - k * 1.3 + j * 0.04, 0.0, 1.0)
				var px := bx + pk * (180.0 + j * 9.0) + sin(j * 2.3) * 10.0
				var py := by - 20.0 - pk * (190.0 + j * 7.0)
				var col: Color = [Color("#6EE7C5"), Color("#4CC3F0"), Color("#FFD84D"), Color("#FF8FD8")][(i + j) % 4]
				if pk > 0.02 and pk < 0.98:
					draw_rect(Rect2(roundi(px), roundi(py), 2, 2), Color(col, 1.0 - pk * 0.5))
		if k > 0.6:
			var a := clampf((k - 0.6) / 0.4, 0.0, 1.0)
			var hop := roundi(absf(sin((t - start) * 5.0)) * 4.0) if t - start > 1.6 and t - start < 2.6 else 0
			_draw_sprite(babies[i], bx, by - hop, false, {"scale": 2, "mod": Color(1, 1, 1, a), "blink": fmod(anim_t + i, 3.1) < 0.13})
			if k < 0.8:
				draw_circle(Vector2(bx, by - 30), 26.0 * (1.0 - (k - 0.6) / 0.2), Color(1, 1, 1, 0.5))


## Dein Team steht zusammen, Konfetti aus Pixeln
func _draw_team() -> void:
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	var n := team_forms.size()
	for i in n:
		var f: String = team_forms[i]
		var cx := W / 2.0 + (i - (n - 1) / 2.0) * 110.0
		var st: int = GameData.FORMS.get(f, {}).get("stage", 1)
		var bob := 1 if sin(anim_t * 4.0 + i) > 0 else 0
		draw_rect(Rect2(cx - 28, 266, 56, 4), Color(0.05, 0.02, 0.12, 0.35))
		_draw_sprite(f, cx, 268, false, {"scale": 2 if st == 1 else 1, "bob": bob, "blink": fmod(anim_t + i * 0.7, 3.2) < 0.13})
	for i in 50:
		var x := fmod(i * 73.1 + sin(anim_t + i) * 12.0, W)
		var y := fmod(anim_t * (30.0 + i % 5 * 8.0) + i * 41.0, H - 64)
		var col: Color = [Color("#6EE7C5"), Color("#FFD84D"), Color("#FF8FD8"), Color("#4CC3F0"), Color("#FF8A4C")][i % 5]
		draw_rect(Rect2(roundi(x), roundi(y), 2 if i % 3 else 3, 2), col)


## Abspann: Namen laufen von unten nach oben
func _draw_credits() -> void:
	for i in 40:
		var x := fmod(i * 97.3 + 13.0, W)
		var y := H - fmod(anim_t * (10.0 + i % 5 * 3.0) + i * 53.0, H)
		draw_rect(Rect2(roundi(x), roundi(y), 1 if i % 3 else 2, 1 if i % 3 else 2), Color("#B8FFE9", 0.35))
	var band := H - 104.0   # darunter läuft die Parade
	var y0 := band + 16.0 - t * 24.0
	var y := y0
	for c in CREDITS:
		var size: int = c[1]
		y += {24: 20.0, 16: 6.0}.get(size, 0.0)   # große Zeilen brauchen Platz nach oben
		if c[0] != "":
			var col: Color = GameData.COL.get(c[2], GameData.COL.ink)
			_text(Vector2(0, y), c[0], size, col, HORIZONTAL_ALIGNMENT_CENTER, W, true, size > 8)
		y += 12 if size == 8 else (16 if size == 16 else 14)
	# kleine Parade am unteren Rand, in einem eigenen Band (die Namen steigen darüber auf)
	draw_rect(Rect2(0, band, W, H - band), Color("#05030C"))
	draw_rect(Rect2(0, band, W, 1), Color(GameData.COL.line, 0.8))
	var forms := ["Aurorlynx", "Leviamander", "Myzelgrizz", "Orbitkauz", "Lunaflut", "Hydradrak"]
	for i in forms.size():
		var x := fmod(t * 30.0 + i * 120.0, W + 120.0) - 60.0
		_draw_sprite(forms[i], x, H - 2, false, {"bob": 1 if sin(anim_t * 5.0 + i) > 0 else 0, "mod": Color(1, 1, 1, 0.9)})


func _draw_end() -> void:
	draw_texture(zone_texture("wiesen"), Vector2.ZERO)
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.55))
	draw_set_transform(Vector2.ZERO, 0, Vector2(2, 2))
	draw_string_outline(font(true, 24), Vector2(0, 46), "ENDE", HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, 4, GameData.COL.dark)
	draw_string(font(true, 24), Vector2(0, 46), "ENDE", HORIZONTAL_ALIGNMENT_CENTER, W / 2.0, 24, GameData.COL.sun)
	draw_set_transform(Vector2.ZERO)
	_text(Vector2(0, 124), "Der NEST ist gerettet. Aber noch sind nicht alle Glitchlings gefunden ...", 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
	if t > 1.5:
		_text(Vector2(0, 150), "Neu freigeschaltet: Schwierigkeit KORRUMPIERT", 8, GameData.COL.coral, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
		_text(Vector2(0, 164), "(in den Optionen: stärkere Gegner, 50 % mehr Fragmente)", 8, GameData.COL.muted, HORIZONTAL_ALIGNMENT_CENTER, W)
	_draw_sprite(team_forms[0], W / 2.0, 290, false, {"bob": 1 if sin(anim_t * 4.0) > 0 else 0, "blink": fmod(anim_t, 3.0) < 0.13,
		"scale": 2 if GameData.FORMS.get(team_forms[0], {}).get("stage", 1) == 1 else 1})
