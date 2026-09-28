class_name RunState
extends RefCounted
## Zustand eines Runs durch eine Zone: HP, Deck, Fragmente, Prägung, Position auf der Karte.

const ELITE_WEIGHT := {"Gewöhnlich": 2, "Selten": 4, "Episch": 2}

var species: String
var mon: Dictionary
var max_hp: int
var hp: int
var deck: Array = []
var frag := 0
var praeg := {}
var chips_used := 0
var fights_won := 0
var sp_bonus := false     # Signatur-Leiste startet im nächsten Kampf halb voll
var seen_events: Array = []
var map: ZoneMap
var floor_idx := -1       # -1 = noch vor der ersten Etage
var pos := -1
var path: Array = []      # besuchte Knoten als Vector2i(etage, index)
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
	map = ZoneMap.generate(rng)


# ---------- Karte ----------

## Indizes der Knoten, die als Nächstes betreten werden können.
func next_choices() -> Array:
	if floor_idx < 0:
		return range(map.floors[0].size())
	if floor_idx >= map.boss_floor():
		return []
	return map.node(floor_idx, pos).next


func enter(i: int) -> Dictionary:
	floor_idx += 1
	pos = i
	path.append(Vector2i(floor_idx, i))
	return current_node()


func current_node() -> Dictionary:
	return map.node(floor_idx, pos) if floor_idx >= 0 else {}


## Gegnerwerte für einen Kampfknoten; wird mit jeder Etage etwas zäher.
func foe_for(node: Dictionary) -> Dictionary:
	if node.type == "boss":
		return GameData.FOES[3].duplicate()
	var pool: Array = [0, 1] if floor_idx < 2 else [0, 1, 2]
	var base: Dictionary = GameData.FOES[pool[rng.randi_range(0, pool.size() - 1)]]
	var d := base.duplicate()
	d.hp = roundi(base.hp * (1.0 + 0.07 * floor_idx))
	d.elite = node.type == "elite"
	if d.elite:
		d.name = "Elite-" + base.name
		d.hp = roundi(d.hp * 1.6)
		d.dmg = base.dmg + 4
		d.atk = base.atk * 0.85
		d.move = base.move * 0.85
		d.loot = base.loot * 2 + 5
	return d


# ---------- Deck ----------

## 3 verschiedene Chips, gewichtet nach Seltenheit.
func roll_choices(weights: Dictionary = GameData.RARITY_WEIGHT, exclude: Array = []) -> Array:
	var pool: Array = []
	for k in GameData.CHIPS:
		if exclude.has(k):
			continue
		for i in weights[GameData.CHIPS[k].rar]:
			pool.append(k)
	var out: Array = []
	var guard := 0
	while out.size() < 3 and guard < 300:
		guard += 1
		var k: String = pool[rng.randi_range(0, pool.size() - 1)]
		if not out.has(k):
			out.append(k)
	return out


func random_chip(rarity := "") -> String:
	var keys: Array = GameData.CHIPS.keys().filter(func(k): return rarity == "" or GameData.CHIPS[k].rar == rarity)
	return keys[rng.randi_range(0, keys.size() - 1)]


func heal(n: int) -> int:
	var h := mini(n, max_hp - hp)
	hp += h
	return h


func remove_chip(chip: String) -> void:
	deck.erase(chip)
