extends Node
## Ablauf des Spiels: Titel → Karte → Knoten (Kampf/Raum) → Karte … → Boss → Ergebnis.
##
## Screenshot-Modus (Argumente nach „--“):
##   --shot=<pfad.png> --mode=title|options|map|event|rest|shop|fight|pick|pause|result [--floor=N] [--sim=S] [--pad]

const TitleScreen := preload("res://scripts/ui/title.gd")
const MapScreen := preload("res://scripts/ui/map_view.gd")
const RoomScreen := preload("res://scripts/ui/room_view.gd")
const ResultScreen := preload("res://scripts/ui/result_view.gd")
const BattleScene := preload("res://scenes/battle.tscn")

var current: Node
var run: RunState


func _ready() -> void:
	var shot := Shot.args()
	if shot.is_empty():
		show_title()
	else:
		_screenshot(shot)


func _swap(node: Node) -> void:
	if current:
		current.queue_free()
	current = node
	add_child(node)


func show_title() -> void:
	var t := TitleScreen.new()
	t.start_run.connect(start_run)
	_swap(t)


func start_run(seed_value := -1) -> void:
	run = RunState.new("Pixmiez", seed_value)
	show_map()


func show_map() -> void:
	var m := MapScreen.new()
	m.setup(run)
	m.node_chosen.connect(_enter_node)
	m.gave_up.connect(show_result.bind(false))
	_swap(m)


func _enter_node() -> void:
	var node := run.current_node()
	if node.type in ["fight", "elite", "boss"]:
		var b := BattleScene.instantiate()
		b.setup(run, run.foe_for(node), node.type)
		b.finished.connect(_battle_finished)
		b.gave_up.connect(show_result.bind(false))
		_swap(b)
	else:
		var r := RoomScreen.new()
		r.setup(run)
		r.finished.connect(show_map)
		_swap(r)


func _battle_finished(won: bool) -> void:
	if not won:
		show_result(false)
	elif run.current_node().type == "boss":
		show_result(true)
	else:
		show_map()


func show_result(won: bool) -> void:
	var r := ResultScreen.new()
	r.setup(run, won)
	r.new_run.connect(start_run)
	r.to_title.connect(show_title)
	_swap(r)


# ---------- Screenshots ----------

func _screenshot(shot: Dictionary) -> void:
	InputSetup.pad = shot.get("pad", false)
	seed(7)
	var mode: String = shot.get("mode", "title")
	run = RunState.new("Pixmiez", 7)
	# auf der Karte bis zur gewünschten Etage vorlaufen (immer erster Weg)
	var floors: int = shot.get("floor", 0)
	for f in floors:
		run.enter(run.next_choices()[0])
	run.frag = 55
	match mode:
		"title", "options":
			show_title()
			if mode == "options":
				current.page = TitleScreen.Page.OPTIONS
		"map":
			show_map()
		"event", "rest", "shop":
			run.enter(run.next_choices()[0])
			run.current_node().type = mode
			_enter_node()
		"fight", "pick", "pause":
			run.enter(run.next_choices()[0])
			if floors >= run.map.boss_floor() - 1:
				run.current_node().type = "boss"
			elif run.current_node().type != "elite":
				run.current_node().type = "fight"
			_enter_node()
			current.simulate(shot.get("sim", 2.0))
			if mode == "pick":
				current.show_pick_for_screenshot()
			elif mode == "pause":
				current.show_pause_for_screenshot()
		"result":
			run.praeg = {"Neutral": 14, "Code": 3, "Licht": 4}
			show_result(false)
	current.set_process(false)
	current.queue_redraw()
	await Shot.save(self, shot.path)
