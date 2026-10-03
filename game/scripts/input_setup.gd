extends Node
## Legt alle Eingabe-Aktionen im Code an (Tastatur + Controller).
## Tastaturbelegung (03.10.2026): die Aktionen in REBIND lassen sich in den Optionen umbelegen; die Wahl steht in
## overrides (Aktion -> physische Taste) und wird von Settings gespeichert. Pfeiltasten, Enter, Esc, Rücktaste und
## Tab bleiben immer belegt, damit man sich nicht aussperren kann.

## true, wenn zuletzt ein Controller benutzt wurde (für Tastensymbole)
var pad := false
## "xbox" oder "ps" – bestimmt die Tastennamen in den Hinweisen (btn)
var pad_style := "xbox"

## PlayStation-Namen der Xbox-Tasten (✕ ○ □ △ zeichnet PixelCanvas als eigene Pixel-Symbole)
## Die Symbole liegen auf eigenen Zeichencodes (Private Use Area U+E000–E003), damit immer unsere Pixel-Symbole erscheinen
const PS_NAMES := {"A": "", "B": "", "X": "", "Y": "", "LB": "L1", "RB": "R1", "RT": "R2", "Start": "Options", "Back": "Share"}
const SONY_VENDOR := 1356   # 0x054C

## Frei belegbare Tastatur-Aktionen: [Aktion, Name in den Optionen, Standardtaste]
const REBIND := [
	["move_up", "Hoch", KEY_W], ["move_down", "Runter", KEY_S], ["move_left", "Links", KEY_A], ["move_right", "Rechts", KEY_D],
	["chip_1", "Angriff 1", KEY_J], ["chip_2", "Angriff 2", KEY_K], ["chip_3", "Support", KEY_L],
	["special", "Signatur", KEY_SPACE], ["handbook", "Handbuch", KEY_H],
	["tab_prev", "Reiter zurück", KEY_Q], ["tab_next", "Reiter vor", KEY_E],
]
## Immer fest belegt (Menüs müssen immer bedienbar bleiben)
const FIXED_KEYS := [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE, KEY_BACKSPACE, KEY_TAB]
## Deutsche Namen für Sondertasten (Godot liefert englische)
const KEY_DE := {"Space": "Leertaste", "Shift": "Umschalt", "Ctrl": "Strg", "CapsLock": "Feststell", "Delete": "Entf",
	"Insert": "Einfg", "Home": "Pos1", "End": "Ende", "PageUp": "Bild auf", "PageDown": "Bild ab"}

var overrides := {}   # Aktion -> physischer Tastencode

func _ready() -> void:
	setup()


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5):
		pad = true
		pad_style = style_for(event.device)
	elif event is InputEventKey or event is InputEventMouseButton:
		pad = false


## Tastenname für Hinweise: „A“ am Xbox-Controller, „✕“ am PlayStation-Controller
func btn(xbox_name: String) -> String:
	return PS_NAMES.get(xbox_name, xbox_name) if pad_style == "ps" else xbox_name


## Erkennt PlayStation-Controller am Namen oder an der Sony-Hersteller-ID
static func style_for(device: int) -> String:
	var name := Input.get_joy_name(device).to_lower()
	for k in ["ps3", "ps4", "ps5", "dualsense", "dualshock", "playstation", "sony"]:
		if name.contains(k):
			return "ps"
	if name == "wireless controller":   # so meldet Windows den DualShock 4 und den DualSense oft
		return "ps"
	var info := Input.get_joy_info(device)
	if int(info.get("vendor_id", 0)) == SONY_VENDOR:
		return "ps"
	return "xbox"


func setup() -> void:
	_add("move_left", [key_of("move_left"), KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_add("move_right", [key_of("move_right"), KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	_add("move_up", [key_of("move_up"), KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_add("move_down", [key_of("move_down"), KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	# Chips auf X / A / B (PS: □ / ✕ / ○), Signatur-Attacke auf Y (PS: △) und RT/R2.
	# 30.09.2026 getauscht (vorher Chip 2 = Y, Signatur = A): Der Produzent drückte im Kampf ständig
	# versehentlich die Signatur, weil ✕ die natürlichste Taste ist.
	_add("chip_1", [key_of("chip_1")], [JOY_BUTTON_X], [])
	_add("chip_2", [key_of("chip_2")], [JOY_BUTTON_A], [])
	_add("chip_3", [key_of("chip_3")], [JOY_BUTTON_B], [])
	_add("special", [key_of("special")], [JOY_BUTTON_Y], [[JOY_AXIS_TRIGGER_RIGHT, 1.0]])
	# Bestätigen auch mit der Signatur- und der ersten Chip-Taste (wie vorher Leertaste und J)
	_add("confirm", [KEY_ENTER, KEY_KP_ENTER, key_of("special"), key_of("chip_1")], [JOY_BUTTON_A], [])
	_add("pause", [KEY_ESCAPE, KEY_TAB], [JOY_BUTTON_START], [])
	_add("handbook", [key_of("handbook")], [JOY_BUTTON_BACK], [])   # Kampf-Handbuch (Xbox: Ansicht/Back, PS: Share)
	_add("back", [KEY_ESCAPE, KEY_BACKSPACE], [JOY_BUTTON_B], [])
	_add("tab_prev", [key_of("tab_prev")], [JOY_BUTTON_LEFT_SHOULDER], [])
	_add("tab_next", [key_of("tab_next")], [JOY_BUTTON_RIGHT_SHOULDER], [])


## Aktuelle Taste einer frei belegbaren Aktion
func key_of(action: String) -> int:
	if overrides.has(action):
		return int(overrides[action])
	for e in REBIND:
		if e[0] == action:
			return e[2]
	return KEY_NONE


## Neu belegen. Ergebnis: "" (ok), "fest" (Taste ist fest belegt) oder die Aktion, mit der getauscht wurde
func rebind(action: String, key: int) -> String:
	if key == KEY_NONE or FIXED_KEYS.has(key):
		return "fest"
	var old := key_of(action)
	var swapped := ""
	for e in REBIND:
		if e[0] != action and key_of(e[0]) == key:
			overrides[e[0]] = old
			swapped = e[0]
	overrides[action] = key
	setup()
	return swapped


func reset_keys() -> void:
	overrides.clear()
	setup()


## Anzeigename der Taste einer Aktion (Tastaturlayout des Systems, deutsche Namen für Sondertasten)
func key_label(action: String) -> String:
	var k := key_of(action)
	var name := OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(k) if DisplayServer.get_name() != "headless" else k)
	if name == "":
		name = OS.get_keycode_string(k)
	if T.en():
		return name
	return KEY_DE.get(name, name)


## Taste im Satz: bei der Leertaste mit Artikel („Drück die Leertaste“), sonst nur der Name („Drück U“)
func key_text(action: String, case := "") -> String:
	if key_of(action) == KEY_SPACE:
		return T.t({"": "Leertaste", "acc": "die Leertaste", "dat": "der Leertaste"}[case])
	return key_label(action)


## Bewegungstasten kurz: „WASD“ bei Einzelbuchstaben, sonst mit Schrägstrichen
func move_keys() -> String:
	var parts: Array = []
	for a in ["move_up", "move_left", "move_down", "move_right"]:
		parts.append(key_label(a))
	if parts.all(func(p): return p.length() == 1):
		return "".join(parts)
	return "/".join(parts)


static func _add(action: String, keys: Array, buttons: Array, axes: Array) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action, 0.5)
	for k in keys:
		if k == KEY_NONE:
			continue
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
