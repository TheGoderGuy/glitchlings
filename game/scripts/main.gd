extends Node
## Wechselt zwischen den Bildschirmen (Titel ↔ Kampf).

const TitleScreen := preload("res://scripts/ui/title.gd")
const BattleScene := preload("res://scenes/battle.tscn")

var current: Node


func _ready() -> void:
	var shot := Shot.args()
	if shot.is_empty() or shot.get("mode", "") in ["title", "options"]:
		show_title()
	else:
		_start_battle()


func _swap(node: Node) -> void:
	if current:
		current.queue_free()
	current = node
	add_child(node)


func show_title() -> void:
	var t := TitleScreen.new()
	t.start_run.connect(_start_battle)
	_swap(t)


func _start_battle() -> void:
	var b := BattleScene.instantiate()
	b.quit_to_title.connect(show_title)
	_swap(b)
