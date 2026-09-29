extends Node
## Dauerhafter Spielstand (Autoload „SaveGame“): Team, Brutnest, Monsterdex, Statistik.
## Datei: user://savegame.json. Tests/Screenshots schalten `persist` ab oder nutzen einen eigenen Pfad.

const VERSION := 1
const NEST_SLOTS := 3
## Schlüpfdauer in abgeschlossenen Runs (Entscheidung 28.09.2026: Gewöhnlich 1 … Legendär 4–5)
const EGG_RUNS := {"Gewöhnlich": 1, "Selten": 2, "Episch": 3, "Legendär": 5}
const EGG_SPRITE := {"Gewöhnlich": "egg_g", "Selten": "egg_s", "Episch": "egg_e", "Legendär": "egg_e"}
## Mindestzahl gewonnener Kämpfe für ein Ei
const EGG_MIN_WINS := 2

var path := "user://savegame.json"
var persist := true
var data := {}


func _ready() -> void:
	load_game()


func has_save() -> bool:
	return not data.is_empty() and not data.get("team", []).is_empty()


func load_game() -> void:
	data = {}
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary and parsed.get("version", 0) == VERSION:
		data = parsed
		_upgrade()


## Ältere Spielstände um neue Felder ergänzen
func _upgrade() -> void:
	for k in ["frag", "recipes", "hints", "cleared"]:
		if not data.has(k):
			data[k] = 0 if k == "frag" else []


func save_game() -> void:
	if not persist:
		return
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


func reset() -> void:
	data = {}
	if persist and FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## Neues Spiel mit dem gewählten Starter
func new_game(starter: String) -> Dictionary:
	data = {"version": VERSION, "team": [], "nest": [], "dex": {}, "next_id": 1, "stats": {"runs": 0, "wins": 0}, "frag": 0, "recipes": [], "hints": [], "cleared": []}
	var m := add_monster(starter)
	save_game()
	return m


# ---------- Team ----------

func team() -> Array:
	return data.get("team", [])


func monster(id: int) -> Dictionary:
	for m in team():
		if int(m.id) == id:
			return m
	return {}


func add_monster(species: String) -> Dictionary:
	var stage: int = GameData.FORMS[species].stage
	var m := {"id": int(data.next_id), "species": species, "form": species, "stage": stage, "praeg": {}, "chips": 0, "runs": 0, "wins": 0}
	data.next_id = int(data.next_id) + 1
	data.team.append(m)
	see(species)
	return m


func see(form: String) -> bool:
	if data.dex.has(form):
		return false
	data.dex[form] = true
	return true


func dex_count() -> int:
	return data.get("dex", {}).size()


# ---------- Brutnest ----------

func nest() -> Array:
	return data.get("nest", [])


func add_egg(rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	if nest().size() >= NEST_SLOTS:
		return {}
	var pool: Array = egg_pool(rarity)
	var egg := {"rarity": rarity, "species": pool[rng.randi_range(0, pool.size() - 1)], "runs_left": EGG_RUNS[rarity]}
	data.nest.append(egg)
	return egg


## Welche Babys in welcher Ei-Seltenheit stecken (wächst mit neuen Linien)
func egg_pool(rarity: String) -> Array:
	var pools := {"Gewöhnlich": ["Pixmiez", "Funkling", "Tröpfel", "Kekso"], "Selten": ["Lumi", "Quakli", "Molchi"],
		"Episch": ["Brummbit", "Kauzbit"], "Legendär": ["Brummbit", "Kauzbit"]}
	var out: Array = pools[rarity].filter(func(s): return GameData.MONS.has(s))
	return out


func ready_eggs() -> Array:
	return nest().filter(func(e): return int(e.runs_left) <= 0)


## Schlüpft das erste bereite Ei: {species, new_in_dex, rarity} oder {}
func hatch_next() -> Dictionary:
	for i in nest().size():
		var e: Dictionary = nest()[i]
		if int(e.runs_left) <= 0:
			data.nest.remove_at(i)
			var is_new: bool = not data.dex.has(e.species)
			var m := add_monster(e.species)
			save_game()
			return {"species": e.species, "new_in_dex": is_new, "rarity": e.rarity, "id": m.id}
	return {}


# ---------- Run-Ende ----------

## Überträgt das Ergebnis eines Runs auf den Spielstand und gibt eine Zusammenfassung zurück.
func record_run(run: RunState, won: bool) -> Dictionary:
	var sum := {"evolved": run.form != run.start_form, "form": run.form, "egg": {}, "nest_full": false, "hatch_ready": 0, "new_dex": []}
	var m := monster(run.monster_id)
	if not m.is_empty():
		m.form = run.form
		m.stage = run.stage
		m.chips = int(m.chips) + run.chips_used
		for el in run.praeg:
			m.praeg[el] = int(m.praeg.get(el, 0)) + int(run.praeg[el])
		m.runs = int(m.runs) + 1
		if won:
			m.wins = int(m.wins) + 1
	for f in run.forms_seen:
		if see(f):
			sum.new_dex.append(f)
	data.stats.runs = int(data.stats.runs) + 1
	if won:
		data.stats.wins = int(data.stats.wins) + 1
		var z: String = run.map.zone
		if not data.cleared.has(z):
			data.cleared.append(z)
			sum.unlocked = _newly_unlocked(z)
	# Eier im Nest reifen mit jedem abgeschlossenen Run (auch bei Niederlage)
	for e in nest():
		e.runs_left = maxi(0, int(e.runs_left) - 1)
	# Neues Ei als Belohnung
	if run.fights_won >= EGG_MIN_WINS:
		var roll := run.rng.randi_range(1, 100)
		var rarity := "Gewöhnlich"
		if won:
			rarity = "Episch" if roll <= 20 else ("Selten" if roll <= 60 else "Gewöhnlich")
		else:
			rarity = "Episch" if roll <= 3 else ("Selten" if roll <= 25 else "Gewöhnlich")
		var egg := add_egg(rarity, run.rng)
		if egg.is_empty():
			sum.nest_full = true
		else:
			sum.egg = egg
	sum.hatch_ready = ready_eggs().size()
	# Übrige Fragmente werden auf die Station gerettet (für das Labor)
	sum.frag_banked = run.frag
	data.frag = int(data.get("frag", 0)) + run.frag
	save_game()
	return sum


# ---------- Zonen ----------

func zone_unlocked(z: String) -> bool:
	var need: String = GameData.ZONES[z].unlock
	return need == "" or data.get("cleared", []).has(need)


func unlocked_zones() -> Array:
	return GameData.ZONE_ORDER.filter(func(z): return zone_unlocked(z))


## Testfunktion: alle Zonen freischalten (Titel → Optionen)
func unlock_all_zones() -> void:
	for z in GameData.ZONE_ORDER:
		if not data.cleared.has(z):
			data.cleared.append(z)
	save_game()


func _newly_unlocked(cleared_zone: String) -> String:
	for z in GameData.ZONE_ORDER:
		if GameData.ZONES[z].unlock == cleared_zone:
			return z
	return ""


# ---------- Labor ----------

func frag() -> int:
	return int(data.get("frag", 0))


## Rezept für zwei Team-Monster (unabhängig von der Reihenfolge) oder -1
func find_recipe(a: Dictionary, b: Dictionary) -> int:
	for i in GameData.RECIPES.size():
		var r: Dictionary = GameData.RECIPES[i]
		if (a.species == r.a and b.species == r.b) or (a.species == r.b and b.species == r.a):
			return i
	return -1


## Versucht eine Fusion. Fehlversuche kosten nichts und geben ein Gerücht fürs Rezeptbuch.
## Ergebnis: {"ok": bool, "msg": String, "result": Form, "new_in_dex": bool, "id": int}
func try_fuse(id_a: int, id_b: int, rng: RandomNumberGenerator) -> Dictionary:
	var a := monster(id_a)
	var b := monster(id_b)
	if a.is_empty() or b.is_empty() or id_a == id_b:
		return {"ok": false, "msg": "Wähle zwei verschiedene Monster."}
	var i := find_recipe(a, b)
	if i < 0:
		var hidden: Array = []
		for k in GameData.RECIPES.size():
			if not data.recipes.has(GameData.RECIPES[k].r) and not data.hints.has(k):
				hidden.append(k)
		var msg := "Die Daten stoßen sich ab. Nichts passiert, und es kostet dich nichts."
		if not hidden.is_empty():
			data.hints.append(hidden[rng.randi_range(0, hidden.size() - 1)])
			msg += " Dafür steht ein neues Gerücht im Rezeptbuch."
		save_game()
		return {"ok": false, "msg": msg}
	var R: Dictionary = GameData.RECIPES[i]
	if R.has("need_form") and a.form != R.need_form and b.form != R.need_form:
		if not data.hints.has(i):
			data.hints.append(i)
		save_game()
		return {"ok": false, "msg": "Die Daten flackern kurz … aber etwas fehlt noch. Das Rezeptbuch hat einen Hinweis."}
	if frag() < GameData.FUSION_COST:
		return {"ok": false, "msg": "Das passt zusammen! Dir fehlen aber noch %d Fragmente." % (GameData.FUSION_COST - frag())}
	data.frag = frag() - GameData.FUSION_COST
	data.team = team().filter(func(m): return int(m.id) != id_a and int(m.id) != id_b)
	var is_new: bool = not data.dex.has(R.r)
	var m := add_monster(R.r)
	if not data.recipes.has(R.r):
		data.recipes.append(R.r)
	save_game()
	return {"ok": true, "msg": "", "result": R.r, "new_in_dex": is_new, "id": m.id, "a": a.form, "b": b.form}
