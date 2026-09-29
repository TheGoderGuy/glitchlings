class_name RunState
extends RefCounted
## Zustand eines Runs durch eine Zone: HP, Deck, Fragmente, Prägung, Position auf der Karte.

const ELITE_WEIGHT := {"Gewöhnlich": 2, "Selten": 4, "Episch": 2}

var species: String      # Linie (Baby-Name)
var mon: Dictionary       # Baby-Werte der Linie
var form: String          # aktuelle Form (nach Evolution z. B. Blazebit)
var stage := 1            # 1 Baby, 2 Rookie, 3 Champion
var eis := 0              # gespielte Eisfeld-Chips (Tröpfel → Frostbyte)
var max_hp: int
var hp: int
var deck: Array = []
var frag := 0
var praeg := {}           # Prägung in diesem Run
var monster_id := -1      # Team-Monster aus dem Spielstand (-1 = ohne Spielstand)
var start_form := ""
var base_chips := 0       # Lebenszeit-Prägung des Monsters vor diesem Run
var base_praeg := {}
var forms_seen: Array = []
var tutorial := false     # erster Run: der erste Kampf ist ein geführtes Tutorial
var last_foe := ""        # für das Spieltest-Log (woran ist der Run gescheitert?)
var start_ms := 0
var chips_used := 0
var fights_won := 0
var sp_bonus := false     # Signatur-Leiste startet im nächsten Kampf halb voll
var seen_events: Array = []
var map: ZoneMap
var floor_idx := -1       # -1 = noch vor der ersten Etage
var pos := -1
var path: Array = []      # besuchte Knoten als Vector2i(etage, index)
var rng := RandomNumberGenerator.new()
var difficulty := 1       # 0 Entspannt, 1 Normal, 2 Knackig (aus den Optionen)

const DIFF_HP := [0.8, 1.0, 1.25]
const DIFF_DMG := [0.7, 1.0, 1.25]
const DIFF_WARN := [0.25, 0.0, -0.1]   # Sekunden mehr/weniger Vorwarnung


func _init(sp: String = "Pixmiez", seed_value: int = -1) -> void:
	species = sp
	mon = GameData.MONS[sp]
	form = sp
	start_form = sp
	forms_seen = [sp]
	start_ms = Time.get_ticks_msec()
	max_hp = mon.hp
	hp = max_hp
	deck = mon.deck.duplicate()
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	map = ZoneMap.generate(rng)


# ---------- Form & Evolution ----------

func special() -> Dictionary:
	return GameData.SPECIALS[form]


func form_el() -> String:
	return GameData.FORMS[form].el


## Ziel der nächsten Evolution nach aktueller Prägung (leer = noch keine Richtung).
## Run mit einem Team-Monster aus dem Spielstand starten (Form, Stufe und Lebenszeit-Prägung übernehmen)
static func from_monster(m: Dictionary, seed_value: int = -1, zone := "wiesen") -> RunState:
	var r := RunState.new(m.species, seed_value)
	if zone != "wiesen":
		r.map = ZoneMap.generate(r.rng, zone)
	r.monster_id = int(m.id)
	r.form = m.form
	r.start_form = m.form
	r.stage = int(m.stage)
	r.base_chips = int(m.chips)
	for el in m.praeg:
		r.base_praeg[el] = int(m.praeg[el])
	r.max_hp += 10 * (r.stage - 1)
	r.hp = r.max_hp
	r.forms_seen = [m.form]
	return r


## Gesamte Prägung (Lebenszeit + dieser Run)
func total_chips() -> int:
	return base_chips + chips_used


func total_praeg() -> Dictionary:
	var t := base_praeg.duplicate()
	for el in praeg:
		t[el] = t.get(el, 0) + praeg[el]
	return t


func evo_target() -> String:
	var praeg := total_praeg()
	if stage == 1:
		if mon.has("ice") and eis >= 4:
			return mon.ice
		var non_neutral := 0
		var kinds := 0
		var top := 0
		for el in praeg:
			if el != "Neutral":
				non_neutral += praeg[el]
				kinds += 1
				top = maxi(top, praeg[el])
		# Geheim-Evolution: bunt gemischt, kein Element über 30 %
		if mon.has("secret") and non_neutral >= 12 and kinds >= 4 and top <= non_neutral * 0.3:
			return mon.secret
		var best := ""
		for el in mon.evo:
			if praeg.get(el, 0) > 0 and (best == "" or praeg[el] > praeg[best]):
				best = el
		return mon.evo[best] if best != "" else ""
	return GameData.FORMS[form].up


## Prägung, die für die nächste Stufe nötig ist (0 = Endstufe).
func evo_need() -> int:
	if stage == 1 or (stage == 2 and GameData.FORMS[form].up != ""):
		return GameData.EVO_AT[stage + 1]
	return 0


## Entwickelt sich, wenn genug Prägung da ist. Gibt {from, to} zurück oder {}.
func try_evolve() -> Dictionary:
	var need := evo_need()
	if need == 0 or total_chips() < need:
		return {}
	var target := evo_target()
	if target == "":
		return {}
	var old := form
	form = target
	stage += 1
	max_hp += 10
	hp += 10
	if not forms_seen.has(target):
		forms_seen.append(target)
	return {"from": old, "to": target}


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
	return _apply_difficulty(_base_foe(node))


func _apply_difficulty(d: Dictionary) -> Dictionary:
	d.hp = roundi(d.hp * DIFF_HP[difficulty])
	d.dmg = maxi(1, roundi(d.dmg * DIFF_DMG[difficulty]))
	d.warn_bonus = DIFF_WARN[difficulty]
	return d


func _base_foe(node: Dictionary) -> Dictionary:
	var Z: Dictionary = GameData.ZONES[map.zone]
	if node.type == "boss":
		return GameData.FOES[Z.boss].duplicate()
	var pool: Array = Z.elite if node.type == "elite" else (Z.early if floor_idx < 2 else Z.late)
	var base: Dictionary = GameData.FOES[pool[rng.randi_range(0, pool.size() - 1)]]
	var d := base.duplicate()
	d.hp = roundi(base.hp * (1.0 + 0.07 * floor_idx) * Z.hp_mult)
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
