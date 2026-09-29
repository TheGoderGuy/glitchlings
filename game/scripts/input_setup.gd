extends Node
## Legt alle Eingabe-Aktionen im Code an (Tastatur + Controller).
## Später kann ein Optionsmenü die InputMap zur Laufzeit umbelegen.

## true, wenn zuletzt ein Controller benutzt wurde (für Tastensymbole)
var pad := false


func _ready() -> void:
	setup()


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5):
		pad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		pad = false


static func setup() -> void:
	_add("move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_add("move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	_add("move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_add("move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	# Xbox-Belegung: X / Y / B = Chips, A = Signatur-Attacke
	_add("chip_1", [KEY_J], [JOY_BUTTON_X], [])
	_add("chip_2", [KEY_K], [JOY_BUTTON_Y], [])
	_add("chip_3", [KEY_L], [JOY_BUTTON_B], [])
	_add("special", [KEY_SPACE], [JOY_BUTTON_A], [[JOY_AXIS_TRIGGER_RIGHT, 1.0]])
	_add("confirm", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_J], [JOY_BUTTON_A], [])
	_add("pause", [KEY_ESCAPE, KEY_TAB], [JOY_BUTTON_START, JOY_BUTTON_BACK], [])
	_add("back", [KEY_ESCAPE, KEY_BACKSPACE], [JOY_BUTTON_B], [])
	_add("tab_prev", [KEY_Q], [JOY_BUTTON_LEFT_SHOULDER], [])
	_add("tab_next", [KEY_E], [JOY_BUTTON_RIGHT_SHOULDER], [])


static func _add(action: String, keys: Array, buttons: Array, axes: Array) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action, 0.5)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
	for b in buttons:
		var ev := InputEventJoypadButton.new()
		ev.button_index = b
		InputMap.action_add_event(action, ev)
	for a in axes:
		var ev := InputEventJoypadMotion.new()
		ev.axis = a[0]
		ev.axis_value = a[1]
		InputMap.action_add_event(action, ev)
