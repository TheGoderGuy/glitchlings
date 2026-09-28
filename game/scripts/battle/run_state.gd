class_name RunState
extends RefCounted
## Zustand eines Runs (3 Kämpfe + Boss): HP, Deck, Prägung.

var species: String
var mon: Dictionary
var max_hp: int
var hp: int
var deck: Array = []
var room := 0
var frag := 0
var praeg := {}
var chips_used := 0
var rng := RandomNumberGenerator.new()


func _init(sp: String = "Pixmiez", seed_value: int = -1) -> void:
	species = sp
	mon = GameData.MONS[sp]
	max_hp = mon.hp
	hp = max_hp
	deck = mon.deck.duplicate()
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


func is_last_room() -> bool:
	return room >= GameData.FOES.size() - 1


## 3 verschiedene Chips, gewichtet nach Seltenheit (wie rollChoices im Prototyp).
func roll_choices() -> Array:
	var pool: Array = []
	for k in GameData.CHIPS:
		for i in GameData.RARITY_WEIGHT[GameData.CHIPS[k].rar]:
			pool.append(k)
	var out: Array = []
	var guard := 0
	while out.size() < 3 and guard < 200:
		guard += 1
		var k: String = pool[rng.randi_range(0, pool.size() - 1)]
		if not out.has(k):
			out.append(k)
	return out
