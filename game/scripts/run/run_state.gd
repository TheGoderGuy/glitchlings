class_name RunState
extends RefCounted
## Zustand eines Runs durch eine Zone: HP, Deck, Fragmente, Prägung, Position auf der Karte.

const ELITE_WEIGHT := {"Gewöhnlich": 2, "Selten": 4, "Episch": 2}

var species: String      # Linie (Baby-Name)
var mon: Dictionary       # Baby-Werte der Linie
var form: String          # aktuelle Form (nach Evolution z. B. Firewallo)
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
var training := false     # Trainingskampf (nach der Starterwahl / Titel > Training): nicht speichern, keine Belohnung
var last_foe := ""        # für das Spieltest-Log (woran ist der Run gescheitert?)
var start_ms := 0
var chips_used := 0
var fights_won := 0
var sp_bonus := false     # Signatur-Leiste startet im nächsten Kampf halb voll
var foe_weak := false     # nächster Gegner startet mit 25 % weniger HP (Ereignis „Riss in der Firewall“)
var seen_events: Array = []
var modules: Array = []   # Module (GameData.MODULES) für diesen Run
var backup_used := false  # Backup-Kern schon verbraucht?
var map: ZoneMap          # Karte der aktuellen Ebene (map.level)
var floor_idx := -1       # -1 = noch vor der ersten Etage der Ebene
var pos := -1
var path: Array = []      # besuchte Knoten als Vector2i(etage, index)
var rng := RandomNumberGenerator.new()
var loot_mult := 1.0      # Fragmentfilter (Station-Ausbau)
var difficulty := 1       # 0 Entspannt, 1 Normal, 2 Knackig, 3 Korrumpiert (nach dem Ende, aus den Optionen)

const DIFF_HP := [0.8, 1.0, 1.25, 1.5]
const DIFF_DMG := [0.7, 1.0, 1.25, 1.4]
const DIFF_WARN := [0.25, 0.0, -0.1, -0.15]   # Sekunden mehr/weniger Vorwarnung
const DIFF_LOOT := [1.0, 1.0, 1.0, 1.5]      # Korrumpiert lohnt sich: mehr Fragmente
var protocol := 0         # Glitch-Protokoll (0 = aus, 1–10), siehe GameData.PROTOCOLS
## Legendäre (07.10.2026): Werte für die geheimen Bedingungen
var pushed := 0           # wie oft eine Strömung den Spieler mitgerissen hat
var boss_heal := false    # im Bosskampf einen Heilpatch benutzt
var boss_spark_t := 0.0   # Sekunden auf Spannungsfeldern im Bosskampf
var final_sig := false    # Ur-Glitch mit der Signatur-Attacke besiegt
## Reise (08.10.2026): ein Run führt durch mehrere Zonen (GameData.ACTS)
var act := 0              # 0 Cache-Wiesen … 3 NEST-Kern
var route: Array = []     # besuchte Zonen in Reihenfolge
var bosses: Array = []    # Zonen, deren Boss in diesem Run besiegt wurde
var legends_won: Array = []  # in diesem Run erfüllte Legenden-Bedingungen (leuchtende Eier)
var route_pending := false   # Boss besiegt, die nächste Zone ist noch nicht gewählt (Weggabelung)
## Herausforderungen (09.10.2026): Bestwerte und Taten dieser Reise, Schlüssel wie in GameData.CHALLENGES
## (z. B. konter10 = meiste Konter in einem Kampf). SaveGame.record_run überträgt sie in den Spielstand.
var ch := {}


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
	route = [map.zone]


## Herausforderungen: Bestwert merken bzw. Zähler erhöhen
func ch_max(k: String, v: int) -> void:
	ch[k] = maxi(int(ch.get(k, 0)), v)


func ch_add(k: String, n := 1) -> void:
	ch[k] = int(ch.get(k, 0)) + n


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
		r.act = GameData.act_of(zone)
		r.route = [zone]
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


## Gespielte Element-Chips (alles außer Neutral) über alle Runs – nur sie prägen und zählen für die Schwelle.
func element_chips() -> int:
	var n := 0
	var t := total_praeg()
	for el in t:
		if el != "Neutral":
			n += t[el]
	return n


## Prägung, die für die nächste Stufe nötig ist (Element-Chips; 0 = Endstufe).
func evo_need() -> int:
	if stage == 1 or (stage in [2, 3] and GameData.FORMS[form].up != ""):
		return GameData.EVO_AT[stage + 1]
	return 0


## Vollständiger Evolutionsstand für Anzeige und Entscheidung:
## dirs = mögliche Richtungen [{el, form, n}], other = Element-Chips ohne Richtung,
## leader = führende Richtung (leer bei Gleichstand), margin = Vorsprung vor der zweitbesten Richtung,
## target = Form, zu der es gerade gehen würde, ready = Evolution jetzt möglich, reason = Hinweistext.
func evo_status() -> Dictionary:
	var t := total_praeg()
	var total := element_chips()
	var need := evo_need()
	var s := {"dirs": [], "other": {}, "total": total, "need": need, "leader": "", "margin": 0, "target": "", "ready": false, "reason": ""}
	if need == 0:
		s.reason = "Höchste Stufe"
		return s
	if stage >= 2:
		s.target = GameData.FORMS[form].up
		s.ready = total >= need
		s.reason = "" if s.ready else T.t("Noch %d Element-Chips") % (need - total)
		return s
	for el in mon.evo:
		s.dirs.append({"el": el, "form": mon.evo[el], "n": int(t.get(el, 0))})
	for el in t:
		if el != "Neutral" and not mon.evo.has(el):
			s.other[el] = int(t[el])
	# Sonderweg: Tröpfel mit 4× Eisfeld wird zu Frostbyte
	if mon.has("ice") and eis >= 4:
		s.leader = "Wasser"
		s.target = mon.ice
		s.margin = 99
	else:
		# Führende Richtung und Abstand zur zweitbesten (Elemente ohne Richtung zählen hier nicht)
		var best := -1
		var second := 0
		for d in s.dirs:
			if d.n > best:
				second = maxi(best, 0)
				best = d.n
				s.leader = d.el
			elif d.n > second:
				second = d.n
		s.margin = best - second
		if best <= 0 or s.margin == 0:
			s.leader = ""
		else:
			s.target = mon.evo[s.leader]
	if total < need:
		s.reason = T.t("Noch %d Element-Chips") % (need - total)
	elif s.leader == "":
		s.reason = "Gleichstand – spiel mehr von einem Element"
	elif s.margin < GameData.EVO_LEAD:
		s.reason = T.t("Führung zu knapp – %s braucht %d Vorsprung") % [T.t(s.leader), GameData.EVO_LEAD]
	else:
		s.ready = true
	return s


func evo_target() -> String:
	return evo_status().target


## Entwickelt sich, wenn genug Element-Chips gespielt sind und eine Richtung klar führt. Gibt {from, to} zurück oder {}.
func try_evolve() -> Dictionary:
	var s := evo_status()
	if not s.ready or s.target == "":
		return {}
	var target: String = s.target
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


## Etage über die ganze Zone gezählt (0-basiert; Wächter/Boss zählen als eigene Etage)
func zone_floor() -> int:
	return map.level * map.boss_floor() + maxi(floor_idx, 0)


## Anzahl Etagen der ganzen Zone (ohne Wächter und Boss)
func zone_floors() -> int:
	return map.levels * map.boss_floor()


## Zonen, die nach dem Boss der aktuellen Zone zur Wahl stehen (leer = Reise zu Ende)
func act_choices() -> Array:
	if act + 1 >= GameData.ACTS.size():
		return []
	return GameData.ACTS[act + 1].filter(func(z): return SaveGame.zone_in_build(z))


## Ist die aktuelle Zone die letzte der Reise (NEST-Kern, in der Testfassung die letzte freie Zone)?
func final_act() -> bool:
	return act_choices().is_empty()


## Nach dem Zonen-Boss: weiter in die gewählte Zone (Akt + 1). Deck, Module, HP und Form bleiben.
## Die Werte für die Legenden-Bedingungen gelten je Zone und starten neu. Gibt die Erholung in HP zurück.
func next_act(zone: String) -> int:
	act += 1
	route_pending = false
	route.append(zone)
	map = ZoneMap.generate(rng, zone, 0)
	floor_idx = -1
	pos = -1
	path = []
	pushed = 0
	boss_heal = false
	boss_spark_t = 0.0
	return heal(roundi(max_hp * GameData.ACT_HEAL))


## Nach dem Sieg über einen Wächter: Karte der nächsten Ebene
func next_level() -> void:
	map = ZoneMap.generate(rng, map.zone, map.level + 1)
	floor_idx = -1
	pos = -1
	path = []


## Gegnerwerte für einen Kampfknoten; wird mit jeder Etage etwas zäher.
func foe_for(node: Dictionary) -> Dictionary:
	return _apply_difficulty(_base_foe(node))


func _apply_difficulty(d: Dictionary) -> Dictionary:
	d.hp = roundi(d.hp * DIFF_HP[difficulty] * GameData.FOE_HP * (GameData.BOSS_HP if d.get("boss", false) else 1.0))
	d.dmg = maxi(1, roundi(d.dmg * DIFF_DMG[difficulty] * GameData.FOE_DMG))
	d.atk = float(d.atk) * GameData.FOE_TEMPO
	d.warn_bonus = DIFF_WARN[difficulty]
	d.loot = roundi(d.loot * DIFF_LOOT[difficulty])
	if protocol > 0:
		var big: bool = d.get("boss", false)   # Bosse und Wächter
		d.hp = roundi(d.hp * 1.15 * (1.2 if protocol >= 5 and big else 1.0))
		if protocol >= 3:
			d.atk = float(d.atk) * 0.9
		if protocol >= 6:
			d.warn_bonus = float(d.warn_bonus) - 0.1
		if protocol >= 8:
			d.dmg = maxi(1, roundi(d.dmg * 1.15))
		if protocol >= 10 and big:
			d.sp_every = BattleState.SPECIAL_EVERY * 0.7
		d.loot = roundi(d.loot * (1.0 + 0.05 * protocol))
	return d


## Rastplatz-Heilung (Anteil der max. HP); Protokoll 2 halbiert sie
func rest_heal() -> int:
	return roundi(max_hp * Rooms.REST_HEAL * (0.5 if protocol >= 2 else 1.0))


## Protokoll 7: weniger max. HP zum Start (nach dem Station-Ausbau anwenden)
func apply_protocol() -> void:
	if protocol >= 7:
		max_hp = roundi(max_hp * 0.85)
		hp = mini(hp, max_hp)


func _base_foe(node: Dictionary) -> Dictionary:
	var Z: Dictionary = GameData.ZONES[map.zone]
	if node.type == "boss":
		return GameData.FOES[Z.boss].duplicate(true)
	if node.type == "guard":
		var guards: Array = Z.guards
		return GameData.FOES[guards[clampi(int(node.get("guard_i", mini(map.level, guards.size() - 1))), 0, guards.size() - 1)]].duplicate(true)
	var g := zone_floor()
	var pool: Array = Z.elite if node.type in ["elite", "glitch"] else (Z.early if g < 2 else Z.late)
	var base: Dictionary = GameData.FOES[pool[rng.randi_range(0, pool.size() - 1)]]
	var d := base.duplicate()
	var A := clampi(act, 0, GameData.ACTS.size() - 1)
	d.hp = roundi(base.hp * (1.0 + 0.05 * g) * GameData.ACT_HP[A])
	d.dmg = roundi(base.dmg * GameData.ACT_DMG[A])
	d.elite = node.type in ["elite", "glitch"]
	if d.elite:
		d.name = "Elite-" + base.name
		d.hp = roundi(d.hp * 1.6)
		d.dmg += 4
		d.atk = base.atk * 0.85
		d.move = base.move * 0.85
		d.loot = base.loot * 2 + 5
	# Glitch-Elite: riskante Route mit epischer Belohnung
	if node.type == "glitch":
		d.name = "Glitch-" + base.name
		d.hp = roundi(d.hp * 1.35)
		d.dmg += 3
		d.loot = roundi(d.loot * 1.5)
		d.glitch = true
	return d


# ---------- Deck ----------

## 3 verschiedene Chips, gewichtet nach Seltenheit.
# ---------- Module ----------

func has_mod(id: String) -> bool:
	return modules.has(id)


## Zufälliges, noch nicht vorhandenes Modul ("" wenn alle da sind)
func roll_module(weights: Dictionary = GameData.RARITY_WEIGHT) -> String:
	var pool: Array = []
	for k in GameData.MODULES:
		if not modules.has(k):
			for i in weights[GameData.MODULES[k].rar]:
				pool.append(k)
	return "" if pool.is_empty() else pool[rng.randi_range(0, pool.size() - 1)]


func add_module(id: String) -> void:
	if id != "" and not modules.has(id):
		modules.append(id)


## Elemente, die das Monster gerade weiterbringen (08.10.2026): Baby = seine Entwicklungsrichtungen,
## danach das Element der Form (Resonanz). Neutrale Formen: keine.
func growth_elements() -> Array:
	if stage == 1:
		return mon.evo.keys()
	var el := form_el()
	return [] if el == "Neutral" else [el]


## Chipwahl nach einem Kampf. Mindestens ein Chip passt zu growth_elements() (Evolution lenken, Resonanz);
## Suchalgorithmus: mindestens ein seltener oder epischer Chip.
func roll_pick(weights: Dictionary) -> Array:
	var out := roll_choices(weights)
	var grow := growth_elements()
	if not grow.is_empty() and not out.any(func(k): return grow.has(GameData.CHIPS[k].el)):
		var slot := rng.randi_range(0, 2)
		var keep: Array = out.filter(func(k): return k != out[slot])
		var fit: Array = roll_choices(weights, keep, grow)
		if not fit.is_empty():
			out[slot] = fit[0]
	if has_mod("suchalgorithmus") and out.all(func(k): return GameData.CHIPS[k].rar == "Gewöhnlich"):
		var better: Array = roll_choices({"Gewöhnlich": 0, "Selten": 3, "Episch": 1}, out.slice(0, 2))
		out[2] = better[0]
	return out


## Bis zu 3 verschiedene Chips nach Seltenheit; exclude: nicht anbieten; els: nur diese Elemente
func roll_choices(weights: Dictionary = GameData.RARITY_WEIGHT, exclude: Array = [], els: Array = []) -> Array:
	var pool: Array = []
	for k in GameData.CHIPS:
		if exclude.has(k) or GameData.CHIPS[k].has("line") or (not els.is_empty() and not els.has(GameData.CHIPS[k].el)):
			continue
		for i in weights[GameData.CHIPS[k].rar]:
			pool.append(k)
	var out: Array = []
	if pool.is_empty():
		return out
	var guard := 0
	while out.size() < 3 and guard < 300:
		guard += 1
		var k: String = pool[rng.randi_range(0, pool.size() - 1)]
		if not out.has(k):
			out.append(k)
	return out


func random_chip(rarity := "") -> String:
	var keys: Array = GameData.CHIPS.keys().filter(func(k): return not GameData.CHIPS[k].has("line") and (rarity == "" or GameData.CHIPS[k].rar == rarity))
	return keys[rng.randi_range(0, keys.size() - 1)]


func heal(n: int) -> int:
	var h := mini(n, max_hp - hp)
	hp += h
	return h


## Station-Ausbau zu Beginn des Runs anwenden ({id: Stufe}, siehe GameData.STATION_UPGRADES)
func apply_station(levels: Dictionary) -> void:
	var hp_bonus := 10 * int(levels.get("vorrat", 0))
	max_hp += hp_bonus
	hp += hp_bonus
	# Werkbank: verbesserte Start-Chips, bevorzugt Angriffe
	for i in int(levels.get("werkbank", 0)):
		var pool: Array = upgradable().filter(func(c): return int(GameData.chip(c).dmg) > 0)
		if pool.is_empty():
			pool = upgradable()
		if pool.is_empty():
			break
		upgrade_chip(pool[rng.randi_range(0, pool.size() - 1)])
	var ms := int(levels.get("modulschacht", 0))
	if ms > 0:
		add_module(roll_module({"Gewöhnlich": 1, "Selten": 0, "Episch": 0} if ms == 1 else {"Gewöhnlich": 3, "Selten": 3, "Episch": 1}))
	loot_mult = 1.0 + 0.15 * int(levels.get("filter", 0))


## Chips im Deck, die sich noch verbessern lassen (jeder Name einmal)
func upgradable() -> Array:
	var out: Array = []
	for c in deck:
		if not GameData.is_upgraded(c) and not out.has(c):
			out.append(c)
	return out


## Eine Kopie des Chips wird zur verbesserten Fassung („Glutball“ → „Glutball+“)
func upgrade_chip(chip: String) -> String:
	var i := deck.find(chip)
	if i < 0 or GameData.is_upgraded(chip):
		return ""
	deck[i] = chip + "+"
	return deck[i]


## n zufällige verschiedene Chips verbessern; gibt die neuen Namen zurück
func upgrade_random(n: int) -> Array:
	var out: Array = []
	for j in n:
		var pool := upgradable()
		if pool.is_empty():
			break
		out.append(upgrade_chip(pool[rng.randi_range(0, pool.size() - 1)]))
	return out


func remove_chip(chip: String) -> void:
	deck.erase(chip)


# ---------- Speichern (Run fortsetzen) ----------

## Run als JSON-taugliches Dictionary (wird auf der Karte in den Spielstand geschrieben)
func to_dict() -> Dictionary:
	var p: Array = []
	for v in path:
		p.append([v.x, v.y])
	return {
		"species": species, "form": form, "stage": stage, "eis": eis, "max_hp": max_hp, "hp": hp,
		"deck": deck.duplicate(), "frag": frag, "praeg": praeg.duplicate(), "monster_id": monster_id,
		"start_form": start_form, "base_chips": base_chips, "base_praeg": base_praeg.duplicate(),
		"forms_seen": forms_seen.duplicate(), "tutorial": tutorial, "last_foe": last_foe,
		"elapsed_ms": Time.get_ticks_msec() - start_ms, "chips_used": chips_used, "fights_won": fights_won,
		"sp_bonus": sp_bonus, "foe_weak": foe_weak, "seen_events": seen_events.duplicate(),
		"modules": modules.duplicate(), "backup_used": backup_used, "difficulty": difficulty, "protocol": protocol,
		"pushed": pushed, "boss_heal": boss_heal, "boss_spark_t": boss_spark_t, "final_sig": final_sig, "loot_mult": loot_mult,
		"act": act, "route": route.duplicate(), "bosses": bosses.duplicate(), "legends_won": legends_won.duplicate(), "route_pending": route_pending, "ch": ch.duplicate(),
		"zone": map.zone, "level": map.level, "floors": map.floors.duplicate(true),
		"floor_idx": floor_idx, "pos": pos, "path": p,
		# 64-Bit-Werte als Text, JSON-Zahlen sind nur Gleitkomma
		"rng_seed": str(rng.seed), "rng_state": str(rng.state),
	}


static func from_dict(d: Dictionary) -> RunState:
	var r := RunState.new(String(d.species))
	r.form = d.form
	r.stage = int(d.stage)
	r.eis = int(d.eis)
	r.max_hp = int(d.max_hp)
	r.hp = int(d.hp)
	r.deck = Array(d.deck)
	r.frag = int(d.frag)
	r.praeg = _int_dict(d.praeg)
	r.monster_id = int(d.monster_id)
	r.start_form = d.start_form
	r.base_chips = int(d.base_chips)
	r.base_praeg = _int_dict(d.base_praeg)
	r.forms_seen = Array(d.forms_seen)
	r.tutorial = bool(d.tutorial)
	r.last_foe = d.last_foe
	r.start_ms = Time.get_ticks_msec() - int(d.elapsed_ms)
	r.chips_used = int(d.chips_used)
	r.fights_won = int(d.fights_won)
	r.sp_bonus = bool(d.sp_bonus)
	r.foe_weak = bool(d.foe_weak)
	r.seen_events = Array(d.seen_events)
	r.modules = Array(d.modules)
	r.backup_used = bool(d.backup_used)
	r.difficulty = int(d.difficulty)
	r.protocol = int(d.get("protocol", 0))
	r.pushed = int(d.get("pushed", 0))
	r.boss_heal = bool(d.get("boss_heal", false))
	r.boss_spark_t = float(d.get("boss_spark_t", 0.0))
	r.final_sig = bool(d.get("final_sig", false))
	r.loot_mult = float(d.get("loot_mult", 1.0))
	# Reise: alte Spielstände (eine Zone = ein Run) bekommen den Akt ihrer Zone
	r.act = int(d.get("act", GameData.act_of(d.zone)))
	r.route = Array(d.get("route", [d.zone]))
	r.bosses = Array(d.get("bosses", []))
	r.legends_won = Array(d.get("legends_won", []))
	r.route_pending = bool(d.get("route_pending", false))
	r.ch = _int_dict(d.get("ch", {}))
	var m := ZoneMap.new()
	m.zone = d.zone
	m.zone_name = GameData.ZONES[m.zone].name
	m.level = int(d.level)
	m.levels = GameData.ZONES[m.zone].get("levels", ZoneMap.LEVELS)
	for row in d.floors:
		var out: Array = []
		for n in row:
			var node: Dictionary = n.duplicate(true)
			node.x = float(n.x)
			node.next = Array(n.next).map(func(v): return int(v))
			out.append(node)
		m.floors.append(out)
	r.map = m
	r.floor_idx = int(d.floor_idx)
	r.pos = int(d.pos)
	r.path = []
	for v in d.path:
		r.path.append(Vector2i(int(v[0]), int(v[1])))
	r.rng.seed = String(d.rng_seed).to_int()
	r.rng.state = String(d.rng_state).to_int()
	return r


static func _int_dict(src: Dictionary) -> Dictionary:
	var out := {}
	for k in src:
		out[k] = int(src[k])
	return out
