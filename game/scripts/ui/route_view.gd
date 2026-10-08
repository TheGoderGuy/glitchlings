extends PixelCanvas
## Weggabelung (08.10.2026, Reise): Nach dem Boss einer Zone wählt man die nächste Zone des Runs.
## Deck, Module, HP und Form bleiben, dazu gibt es eine Verschnaufpause (GameData.ACT_HEAL).

signal chosen(zone: String)

var run: RunState
var options: Array = []
var sel := 0
var t_in := 0.0


func setup(run_state: RunState) -> void:
	run = run_state
	options = run.act_choices()
	sel = 0


func _process(delta: float) -> void:
	anim_t += delta
	t_in += delta
	if handbook != null:
		queue_redraw()
		return
	if t_in > 0.4 and not options.is_empty():
		if Input.is_action_just_pressed("move_left"):
			sel = (sel + options.size() - 1) % options.size()
			Sfx.play("select")
		elif Input.is_action_just_pressed("move_right"):
			sel = (sel + 1) % options.size()
			Sfx.play("select")
		elif Input.is_action_just_pressed("handbook"):
			open_handbook()
		elif Input.is_action_just_pressed("confirm"):
			Sfx.play("confirm")
			set_process(false)
			chosen.emit(options[sel])
	queue_redraw()


func _draw() -> void:
	_draw_zone(run.map.zone)
	draw_rect(Rect2(0, 0, W, H), Color(GameData.COL.dark, 0.82))
	var next_act := run.act + 2
	_text(Vector2(0, 30), T.t("Akt %d von %d: Wohin geht die Reise?") % [next_act, GameData.ACTS.size()], 16, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)
	_text(Vector2(0, 46), T.t("%s ist besiegt. Dein Deck, deine Module und %s kommen mit.") % [T.t(GameData.FOES[GameData.ZONES[run.map.zone].boss].name), T.t(run.form)], 8, GameData.COL.ink, HORIZONTAL_ALIGNMENT_CENTER, W)
	var heal := mini(roundi(run.max_hp * GameData.ACT_HEAL), run.max_hp - run.hp)
	var hp_line := T.t("HP %d/%d") % [run.hp, run.max_hp]
	if heal > 0:
		hp_line += "  ·  " + T.t("Verschnaufpause: +%d HP") % heal
	_text(Vector2(0, 60), hp_line, 8, GameData.COL.mint, HORIZONTAL_ALIGNMENT_CENTER, W)
	var cw := 200.0
	var gap := 24.0
	var n := options.size()
	var x0 := (W - n * cw - (n - 1) * gap) / 2.0
	for i in n:
		var z: String = options[i]
		var active := i == sel
		var r := Rect2(x0 + i * (cw + gap), 76 - (4 if active else 0), cw, 228)
		var tip := _advantage(z)
		_zone_card(r, z, active, T.t("Akt %d") % next_act, tip[0], tip[1])
	# Monster unten links
	_draw_sprite(run.form, 44, H - 14, false, {"scale": 2 if run.stage == 1 else 1, "bob": 1 if sin(anim_t * 4.0) > 0 else 0})
	var pad: bool = InputSetup.pad
	_text(Vector2(0, H - 14), T.t("< > Zone wählen   %s losziehen") % (InputSetup.btn("A") if pad else "Enter"), 8, GameData.COL.sun, HORIZONTAL_ALIGNMENT_CENTER, W, true, true)


## Passt die Zone zum Element der eigenen Form (gemessen am Element des Zonen-Bosses)? [Text, Farbe] für die Kartenecke
func _advantage(z: String) -> Array:
	var el := run.form_el()
	var boss_el: String = GameData.FOES[GameData.ZONES[z].boss].el
	if el != "Neutral" and GameData.mult(el, boss_el) > 1.0:
		return [T.t("%s im Vorteil") % T.t(el), GameData.EL[el]]
	if el != "Neutral" and GameData.mult(el, boss_el) < 1.0:
		return [T.t("%s im Nachteil") % T.t(el), GameData.COL.coral]
	return ["", GameData.COL.muted]
