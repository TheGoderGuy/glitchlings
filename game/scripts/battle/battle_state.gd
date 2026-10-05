class_name BattleState
extends RefCounted
## Reine Kampflogik ohne Grafik (Port aus prototype/index.html).
## Raster: Spalten 0–2 = Spielerseite, 3–5 = Gegnerseite. Der Gegner speichert c = 0–2 (gezeichnet bei 3 + c).
## Effektlisten (fx, parts, marks …) liegen ebenfalls hier, damit die Ansicht sie nur noch zeichnen muss.

const WARN_TIME := 0.7
const SPECIAL_JUMP := 0.35

var run: RunState
var mon: Dictionary
var def: Dictionary
var rng: RandomNumberGenerator

var t := 0.0
var p := {}
var e := {}
## Rollen-Slots: Stapel 0 = Angriff (Slots 0 und 1), Stapel 1 = Support (Slot 2), siehe GameData.SLOT_ROLE
var piles: Array = [[], []]
var discs: Array = [[], []]
var hand: Array = []
const RESHUFFLE := 3.0     # Ist der Support-Stapel leer, kostet das Neumischen zusätzliche Ladezeit (Heilung nicht zu oft)
var _reshuffled := false
var proj: Array = []
const SIM_STEP := 1.0 / 120.0    # längster Rechenschritt des Kampfes
const MAX_FRAME_DT := 0.05        # mehr zählt ein einzelnes Bild nie
var warns: Array = []
var mines: Array = []
var pops: Array = []
const SHIFT_TIME := 7.0   # Ur-Glitch: Sekunden bis zum nächsten Elementwechsel
var shift_t := SHIFT_TIME
var delayed: Array = []
var bots: Array = []
var marks: Array = []
var fx: Array = []     # schwebende Texte {x, y, text, color, t, max}
var parts: Array = []  # Partikel / Ringe / Feld-Blitze
var vfx: Array = []    # Chip-Effekte passend zur Karte (04.10.2026), rein optisch: {kind, c, r, t, max, …}
var shield_kind := ""  # welcher Schild steht: firewall / lock (Kopierschutz) / konter
var events: Array = [] # Sound-/Ereignisnamen für die Ansicht (wird dort geleert)

var shield := 0.0
var bubble := 0
var bubble_t := 0.0
var oc := 0.0
var heat := 0.0        # Hitzeschild
var mist := 0.0        # Nebel: 50 % Ausweichen
var scan := 0          # Portscan: nächste Treffer +50 %
var shake := 0.0
var freeze := 0.0      # Hitstop, wird von der Ansicht abgebaut
var hurt := 0.0
var sp := 0.0          # Signatur-Leiste 0–100
var since_hit := 0.0
var reflex := 0
var in_special := false
var jump_t := 0.0
var special_anim := ""
var special_t := 0.0
var combo := 0
var last_chip := ""
var decoy := 0
var min_e_hp := 0        # Tutorial: Gegner kann nicht unter diesen Wert fallen
var min_p_hp := 0        # Tutorial: Spieler kann nicht unter diesen Wert fallen
var last_slot := -1      # zuletzt gespielter Slot (Tutorial)
var last_mult := 1.0     # Element-Faktor des letzten Chip-Treffers (Tutorial: „Effektiv!“ erkennen)
var hazards: Array = []  # Lavafelder auf der Spielerseite {c, r, t, tick}
var decoy_t := 0.0
var regen_t := 1.0
var banner := {}
var status := ""
var over := false
var outcome := ""      # "won" / "lost"
var pend_move = null   # vorgemerkter Schritt (Vector2i), wenn noch Bewegungs-Cooldown läuft
var loot_gained := 0   # tatsächlich erhaltene Fragmente (Sammler-Modul)
var echo_count := 0    # Echochip: jeder 4. Chip doppelt
var leech := 0         # Saugbit: gesammelter Schaden
var steal_count := 0   # Langfinger (Waschbär): jeder 4. Treffer lädt einen Chip
var parrot_count := 0  # Nachplappern (Ara): jeder 4. Angriffs-Chip kommt nach 0,5 s noch einmal
var dmg_scale := 1.0   # Schadensfaktor für den gerade ausgelösten Chip (Nachplappern: 0,5)
var counter := 0       # Konter/Kopierschutz: Schaden, der beim Blocken zurückgeht
var counter_el := "Neutral"
var dodge_t := 0.0     # Sprungantrieb: nächster Treffer wird ausgewichen
# Großangriffe von Wächtern und Bossen: goldene Warnfelder mit langer Vorwarnung.
# Wer allen Feldern eines Großangriffs ausweicht, überlastet den Gegner (kurz betäubt, Signatur-Leiste +15).
const SPECIAL_WARN := 1.4
const SPECIAL_EVERY := 11.0
var sp_left := 0       # ausstehende Warnfelder des laufenden Großangriffs
var sp_fail := false   # Spieler wurde vom laufenden Großangriff getroffen
var sp_dodged := 0     # komplett ausgewichene Großangriffe (Statistik/Tests)


## foe: Gegnerwerte wie in GameData.FOES (für Karten-Knoten per RunState.foe_for skaliert).
func _init(run_state: RunState, foe: Dictionary) -> void:
	run = run_state
	mon = run.mon
	rng = run.rng
	def = foe.duplicate() if foe.is_read_only() else foe   # Ur-Glitch ändert def.el während des Kampfs
	p = {"c": 1, "r": 1, "cd": 0.0, "flash": 0.0}
	e = {"c": 1, "r": 1, "hp": def.hp, "max": def.hp, "move_t": def.move, "atk_t": def.atk * 0.8,
		"pi": 0, "frozen": 0.0, "slow": 0.0, "flash": 0.0, "burn": 0, "poison": 0, "dot_t": 1.0, "pop_t": 1.5,
		"phase": 1, "sp_t": def.get("sp_first", 5.0), "sp_i": 0}
	for c in run.deck:
		piles[GameData.role(c)].append(c)
	for k in 2:
		piles[k] = _shuffle(piles[k])
	for i in 3:
		hand.append({"chip": _draw_one(i), "rem": 0.0, "max": 1.0, "deny": 0.0, "shuf": false})
	if mon.passive == "Katzenreflex":
		reflex = 2 if run.stage >= 3 else 1
	if mon.passive == "Wolkendecke":
		bubble = 30
		bubble_t = 6.0
	if run.sp_bonus:
		run.sp_bonus = false
		sp = 50.0
	if run.has_mod("startsignal"):
		sp = maxf(sp, 25.0)
	if run.has_mod("notschild"):
		bubble = maxi(bubble, 20)
		bubble_t = 999.0
	if run.foe_weak:
		run.foe_weak = false
		e.hp = roundi(e.hp * 0.75)
		float_at(3 + e.c, e.r, "Geschwächt!", GameData.COL.sun)
	if def.get("guard", false):
		status = "Wächter! Goldene Felder kündigen einen Großangriff an. Weichst du ganz aus, ist er kurz überlastet."
	elif def.boss:
		if def.get("minion", "pop") == "lava":
			status = "Boss! Ab der Hälfte seiner HP setzt er Felder in Brand. Runter von der Lava!"
		elif def.get("minion", "pop") == "shift":
			status = "Endboss! Der Ur-Glitch wechselt ständig sein Element. Achte oben rechts darauf!"
		elif def.get("minion", "pop") == "mix":
			status = "Boss! Sie verschleimt Felder und streut Glitch-Sporen. Und jeder Treffer heilt sie!"
		else:
			status = "Boss! Ab der Hälfte seiner HP schickt er Bitmilben. Tritt drauf, bevor sie platzen!"
	elif def.get("glitch", false):
		status = "Glitch-Elite! Korrumpiert und gefährlich – dafür wartet eine epische Belohnung."
	elif def.get("elite", false):
		status = "Elite-Gegner: mehr HP, trifft härter."
	elif run.fights_won == 0:
		status = "Rote Felder warnen vor Angriffen. Weiche aus!"


# ---------- Deck ----------

func _shuffle(a: Array) -> Array:
	var b := a.duplicate()
	for i in range(b.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = b[i]
		b[i] = b[j]
		b[j] = tmp
	return b


## Nächsten Chip für Slot i ziehen; ist sein Stapel leer, wird die Ablage neu gemischt (merkt sich _reshuffled)
func _draw_one(i: int) -> String:
	var k: int = GameData.SLOT_ROLE[i]
	_reshuffled = false
	if piles[k].is_empty() and not discs[k].is_empty():
		piles[k] = _shuffle(discs[k])
		discs[k] = []
		_reshuffled = k == 1   # nur der Support-Stapel kostet Zeit beim Mischen
	if piles[k].is_empty():
		return ""
	return piles[k].pop_back()


func next_chip(i: int) -> String:
	var k: int = GameData.SLOT_ROLE[i]
	return piles[k].back() if not piles[k].is_empty() else ""


func pile_count() -> int:
	return piles[0].size() + piles[1].size()


func disc_count() -> int:
	return discs[0].size() + discs[1].size()


# ---------- Eingaben ----------

func move_player(dc: int, dr: int) -> void:
	if over:
		return
	if p.cd > 0:
		pend_move = Vector2i(dc, dr)
		return
	var c: int = p.c + dc
	var r: int = p.r + dr
	if c < 0 or c > 2 or r < 0 or r > 2:
		return
	p.c = c
	p.r = r
	p.cd = mon.move * (0.5 if mon.passive in ["Hasenhaken", "Mischwesen"] else 1.0)
	if run.has_mod("reflexbooster"):
		p.cd *= 0.75
	if not run.has_mod("schleimschuhe") and (on_slime(p.c, p.r) or on_slime(p.c - dc, p.r - dr)):
		p.cd *= 3.0
		float_at(p.c, p.r, "Klebrig!", Color("#7BD35A"))
	events.append("move")
	for i in range(pops.size() - 1, -1, -1):
		var q: Dictionary = pops[i]
		if q.c == c and q.r == r:
			pops.remove_at(i)
			events.append("pop_close")
			burst(c + 0.5, r + 0.5, GameData.COL.mint, 10)
			float_at(c, r, "Zertreten!", GameData.COL.mint)


func use_slot(i: int) -> void:
	if over:
		return
	var s: Dictionary = hand[i]
	if s.chip == "":
		return
	# Noch am Laden: nichts passiert (kein Vormerken mehr, 30.09.2026), die Karte blinkt nur kurz rot
	if s.rem > 0:
		s.deny = 0.25
		return
	var id: String = s.chip
	last_slot = i
	var ch: Dictionary = GameData.chip(id)
	run.praeg[ch.el] = run.praeg.get(ch.el, 0) + (2 if run.has_mod("prisma") and ch.el != "Neutral" else 1)
	run.chips_used += 1
	if GameData.base_chip(id) == "Eisfeld":
		run.eis += 1
	# Hamstern (Kekso-Linie): Chip kommt gleich wieder statt auf den Ablagestapel
	var ro := GameData.role(id)
	if mon.passive in ["Hamstern", "Winterschlaf"] and rng.randf() < 0.25:
		piles[ro].append(id)
		float_at(p.c, p.r, "Gehamstert!", GameData.EL.Neutral)
	else:
		discs[ro].append(id)
	last_chip = id
	var nx := _draw_one(i)
	s.chip = nx
	s.shuf = _reshuffled
	s.max = (GameData.chip(nx).cd if nx != "" else 1.0) * (0.85 if run.has_mod("schnelllader") else 1.0) + (RESHUFFLE if _reshuffled else 0.0)
	s.rem = s.max
	_apply_chip(id)
	_chip_vfx(GameData.base_chip(id), GameData.chip(id).el)
	# Echochip: jeder 4. Chip wird ein zweites Mal ausgelöst
	if run.has_mod("echochip"):
		echo_count += 1
		if echo_count % 4 == 0 and not over:
			float_at(p.c, p.r, "Echo!", Color("#FF8FD8"))
			_apply_chip(id)
	# Nachplappern (Ara): jeder 4. Angriffs-Chip wird nach 0,5 s mit halbem Schaden wiederholt
	if mon.passive == "Nachplappern" and ro == 0:
		parrot_count += 1
		if parrot_count % 4 == 0:
			delayed.append({"t": 0.5, "fn": _parrot.bind(id), "mark": false})
	# Übermut: jeder 3. Chip halbiert die Ladezeit der anderen
	if mon.passive == "Übermut":
		combo += 1
		if combo % 3 == 0:
			for j in hand.size():
				if j != i and hand[j].chip != "":
					hand[j].rem *= 0.5
			float_at(p.c, p.r, "Übermut!", GameData.EL.Feuer)


func use_special() -> void:
	if over or sp < 100:
		return
	var S: Dictionary = run.special()
	sp = 0.0
	events.append("special")
	banner = {"text": S.name + "!", "color": GameData.EL[S.el], "t": 1.1, "max": 1.1}
	shake = maxf(shake, 9.0)
	special_anim = S.anim
	special_t = SPECIAL_JUMP
	if S.anim == "jump":
		jump_t = SPECIAL_JUMP
	burst(p.c + 0.5, p.r + 0.5, GameData.EL[S.el].lightened(0.3), 16)
	# Selbst-Effekte sofort
	if S.has("recharge"):
		for s in hand:
			if s.chip != "":
				s.rem = 0.0
	if S.has("oc"):
		oc = maxf(oc, S.oc)
	if S.has("shield"):
		shield = maxf(shield, S.shield)
	if S.has("bubble"):
		bubble = maxi(bubble, S.bubble)
		bubble_t = maxf(bubble_t, S.bubble_t)
	if S.has("heal"):
		var h := run.heal(S.heal)
		float_at(p.c, p.r, "+%d" % h, GameData.COL.mint)
	if S.has("decoy"):
		decoy = S.decoy
		decoy_t = S.decoy_t
		float_at(p.c, p.r, "Abbild!", GameData.EL.Code)
	if S.has("scan"):
		scan = maxi(scan, S.scan)
		float_at(p.c, p.r, T.t("Scan x%d") % scan, GameData.EL.Code)
	if S.has("mines"):
		var spots: Array = []
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n := Vector2i(e.c + d.x, e.r + d.y)
			if n.x >= 0 and n.x < 3 and n.y >= 0 and n.y < 3:
				spots.append(n)
		for k in mini(S.mines, spots.size()):
			var sp: Vector2i = spots[rng.randi_range(0, spots.size() - 1)]
			spots.erase(sp)
			mines.append({"c": sp.x, "r": sp.y, "arm": 0.3, "t": 8.0})
	if S.has("replay"):
		if last_chip != "":
			float_at(p.c, p.r, T.t("Backentasche:") + " " + T.chip(last_chip), GameData.EL.Neutral)
			_apply_chip(last_chip)
		else:
			delayed.append({"t": 0.05, "fn": _special_hit.bind(S, true, 30), "mark": false})
	if S.has("pull") and not over:
		e.c = 0
		e.r = p.r
	# Treffer: beim Sprung auf dem Höhepunkt, sonst sofort, mehrere im Abstand von 0,15 s
	var t0 := SPECIAL_JUMP * 0.5 if S.anim == "jump" else 0.05
	for k in S.hits.size():
		delayed.append({"t": t0 + k * 0.15, "fn": _special_hit.bind(S, k == S.hits.size() - 1, S.hits[k]), "mark": false})


func _special_hit(S: Dictionary, last: bool, d: int) -> void:
	match S.anim:
		"row":
			for c in 3:
				fx_cell(3 + c, e.r, GameData.EL[S.el], 0.35)
		"field":
			for c in 3:
				for r in 3:
					fx_cell(3 + c, r, GameData.EL[S.el], 0.35)
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL[S.el], 18)
	in_special = true
	hit_enemy(d, S.el)
	in_special = false
	if over or not last:
		return
	if S.has("burn"):
		e.burn = maxi(e.burn, S.burn)
	if S.has("poison"):
		e.poison = maxi(e.poison, S.poison)
	if S.has("stun"):
		e.frozen = maxf(e.frozen, S.stun)
		float_at(3 + e.c, e.r, "Betäubt", GameData.EL[S.el])
	if S.has("knock") and e.c < 2:
		e.c += 1


# ---------- Chips ----------

func _parrot(id: String) -> void:
	if over:
		return
	float_at(p.c, p.r, "Nachgeplappert!", GameData.EL.Elektro)
	dmg_scale = 0.5
	_apply_chip(id)
	_chip_vfx(GameData.base_chip(id), GameData.chip(id).el)
	dmg_scale = 1.0


func _apply_chip(id: String) -> void:
	var ch: Dictionary = GameData.chip(id)
	if dmg_scale != 1.0 and ch.has("dmg"):
		ch = ch.duplicate()
		ch.dmg = maxi(1, roundi(ch.dmg * dmg_scale))
	var el: String = ch.el
	var base := GameData.base_chip(id)
	var k: float = ch.get("k", 1.0)   # verbesserte Chips: auch feste Werte (Heilung, Nebentreffer) stärker
	events.append(_chip_sound(base))
	match base:
		"Pixelstrahl", "Wasserstrahl", "Virusspritzer", "Datenfresser", "Kurzschluss", "Frostsplitter", "Parasit":
			proj.append({"lob": false, "row": p.r, "x": p.c + 0.5, "v": 11.0, "el": el, "dmg": ch.dmg, "id": base})
		"Doppelklick":
			proj.append({"lob": false, "row": p.r, "x": p.c + 0.5, "v": 12.0, "el": el, "dmg": ch.dmg, "id": base})
			delayed.append({"t": 0.15, "fn": _second_click.bind(int(ch.dmg)), "mark": false})
		"Neustart":
			var h2 := run.heal(roundi(15 * k))
			float_at(p.c, p.r, T.t("Neustart! +%d") % h2, GameData.COL.mint)
			for j in hand.size():
				var s: Dictionary = hand[j]
				if s.chip != "":
					discs[GameData.role(s.chip)].append(s.chip)
				s.chip = _draw_one(j)
				s.max = GameData.chip(s.chip).cd if s.chip != "" else 1.0
				s.rem = 0.0
				s.shuf = false
		"Funkenregen":
			for i in 3:
				var fc := rng.randi_range(0, 2)
				var fr := rng.randi_range(0, 2)
				delayed.append({"t": 0.1 * i, "fn": fx_cell.bind(3 + fc, fr, GameData.EL.Feuer, 0.3), "mark": false})
			delayed.append({"t": 0.3, "fn": _funkenregen.bind(k), "mark": false})
		"Hitzeschild":
			heat = 4.0
			float_at(p.c, p.r, "Hitzeschild", GameData.EL.Feuer)
		"Laserschuss":
			for c in 3:
				fx_cell(3 + c, p.r, GameData.EL.Code, 0.2)
			if e.r == p.r:
				hit_enemy(ch.dmg, el)
			else:
				_miss()
		"Portscan":
			scan = 2
			float_at(p.c, p.r, "Scan aktiv", GameData.EL.Code)
		"Strudel":
			e.slow = 3.0
			fx_cell(3 + e.c, e.r, GameData.EL.Wasser, 0.4)
			float_at(3 + e.c, e.r, "Langsam", GameData.EL.Wasser)
		"Nebel":
			mist = 3.0
			float_at(p.c, p.r, "Nebel", GameData.EL.Wasser)
		"Blitzlanze":
			for r in 3:
				fx_cell(3 + p.c, r, GameData.EL.Elektro, 0.3)
			if e.c == p.c:
				hit_enemy(ch.dmg, el)
			else:
				_miss()
		"Blendgranate":
			warns.clear()
			e.atk_t = def.atk
			burst(3 + e.c + 0.5, e.r + 0.5, Color.WHITE, 16)
			float_at(3 + e.c, e.r, "Geblendet", GameData.EL.Elektro)
		"Wurmloch":
			fx_cell(3 + e.c, e.r, GameData.EL.Virus, 0.3)
			e.r = p.r
			fx_cell(3 + e.c, e.r, GameData.EL.Virus, 0.4)
			hit_enemy(ch.dmg, el)
		"Byteschlag", "Glutklinge":
			for c in [0, 1]:
				fx_cell(3 + c, p.r, GameData.EL[el], 0.25)
			if e.r == p.r and e.c <= 1:
				hit_enemy(ch.dmg, el)
				if base == "Glutklinge":
					e.burn = maxi(e.burn, 2)
			else:
				_miss()
		"Feuersbrunst", "Tsunami":
			for c in 3:
				for r in 3:
					fx_cell(3 + c, r, GameData.EL[el], 0.4)
			burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL[el], 24)
			var fire_bonus: bool = base == "Feuersbrunst" and e.burn > 0
			hit_enemy(ch.dmg * (2 if fire_bonus else 1), el)
			if base == "Feuersbrunst":
				e.burn = maxi(e.burn, 4)
			else:
				e.frozen = maxf(e.frozen, 1.5)
				float_at(3 + e.c, e.r, "Eingefroren", GameData.EL.Wasser)
		"Flutwelle":
			for c in 3:
				fx_cell(3 + c, p.r, GameData.EL.Wasser, 0.3)
			if e.r == p.r:
				hit_enemy(ch.dmg, el)
				if e.c < 2:
					e.c += 1
			else:
				_miss()
		"Kopierschutz", "Konter":
			shield = 6.0 if base == "Kopierschutz" else 1.5
			shield_kind = "lock" if base == "Kopierschutz" else "konter"
			counter = ch.dmg
			counter_el = el
			float_at(p.c, p.r, base, GameData.EL[el])
		"Geschützturm":
			bots.append({"t": 8.0, "tick": 1.5, "kind": "turret"})
			float_at(p.c, p.r, "Geschützturm", GameData.EL.Code)
		"Debugger":
			for c in 3:
				fx_cell(3 + c, p.r, GameData.EL.Code, 0.2)
			if not hazards.is_empty() or not pops.is_empty():
				hazards.clear()
				pops.clear()
				float_at(p.c, p.r, "Aufgeräumt!", GameData.EL.Code)
			if e.r == p.r:
				hit_enemy(ch.dmg, el)
			else:
				_miss()
		"Kettenblitz":
			burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL.Elektro, 10)
			hit_enemy(ch.dmg, el)
			for i in 2:
				delayed.append({"t": 0.25 * (i + 1), "fn": _chain_hit.bind(k), "mark": false})
		"Ladungsfeld":
			sp = minf(100.0, sp + 25.0)
			float_at(p.c, p.r, "Signatur +25 %", GameData.EL.Elektro)
		"Magnetfeld":
			fx_cell(3 + e.c, e.r, GameData.EL.Elektro, 0.3)
			e.c = p.c
			e.frozen = maxf(e.frozen, 0.5)
			fx_cell(3 + e.c, e.r, GameData.EL.Elektro, 0.4)
			float_at(3 + e.c, e.r, "Angezogen", GameData.EL.Elektro)
		"Blackout":
			warns.clear()
			e.atk_t = def.atk
			e.frozen = maxf(e.frozen, 3.0)
			burst(3 + e.c + 0.5, e.r + 0.5, Color.WHITE, 20)
			float_at(3 + e.c, e.r, "Blackout!", GameData.EL.Elektro)
		"Seuche":
			e.poison = maxi(4, e.poison * 2)
			fx_cell(3 + e.c, e.r, GameData.EL.Virus, 0.4)
			float_at(3 + e.c, e.r, T.t("Seuche: Gift %d s") % e.poison, GameData.EL.Virus)
		"Sporenfalle":
			mines.append({"c": e.c, "r": e.r, "arm": 0.8, "t": 6.0, "dmg": ch.dmg, "poison": 6})
		"Sprungantrieb":
			dodge_t = 2.0
			float_at(p.c, p.r, "Sprungbereit", GameData.COL.mint)
		"Glutball":
			proj.append({"lob": true, "fx": p.c + 0.5, "fr": p.r, "tx": 3 + p.c + 0.5, "tr": p.r, "t": 0.0, "dur": 0.3,
				"el": "Feuer", "land": _land_glutball.bind(p.c, p.r, k)})
		"Flammenwelle":
			var col: int = e.c
			marks.append({"col": col, "t": 0.4, "max": 0.4, "color": GameData.EL.Feuer})
			delayed.append({"t": 0.4, "fn": _flammenwelle.bind(col, k), "mark": false})
		"Firewall":
			shield = 4.0
			shield_kind = "firewall"
			float_at(p.c, p.r, "Firewall", GameData.EL.Code)
		"Blubberschild":
			bubble = roundi(30 * k)
			bubble_t = 5.0
			float_at(p.c, p.r, "Blase", GameData.EL.Wasser)
		"Bug-Mine":
			mines.append({"c": e.c, "r": e.r, "arm": 0.8, "t": 6.0})
		"Übertakten":
			oc = 5.0
			float_at(p.c, p.r, "Übertaktet!", GameData.EL.Feuer)
		"Eisfeld":
			e.frozen = 2.0
			fx_cell(3 + e.c, e.r, GameData.EL.Wasser, 0.4)
			float_at(3 + e.c, e.r, "Eingefroren", GameData.EL.Wasser)
		"Heilpatch":
			var h: int = mini(roundi(25 * k), run.max_hp - run.hp)
			run.hp += h
			float_at(p.c, p.r, "+%d" % h, GameData.COL.mint)
			burst(p.c + 0.5, p.r + 0.5, GameData.COL.mint, 10)
		"Blitzcursor":
			delayed.append({"t": 0.5, "fn": _blitz.bind(k), "mark": true})
		"Mini-Bot":
			bots.append({"t": 6.0, "tick": 1.0})
			float_at(p.c, p.r, "Mini-Bot", GameData.EL.Code)
		"Defrag":
			for s in hand:
				if s.chip != "":
					s.rem = 0.0
			float_at(p.c, p.r, "Defrag!", GameData.EL.Neutral)


## Rein optischer Effekt; zufällige Formen (Blitz-Zacken) werden einmal festgelegt, damit nichts flackert
func vfx_add(kind: String, c: float, r: float, dur: float, extra := {}) -> void:
	var v := {"kind": kind, "c": c, "r": r, "t": dur, "max": dur, "seed": randi() % 1000}
	v.merge(extra)
	vfx.append(v)


## Zu jeder Karte ein passender Effekt (Tester-Feedback 04.10.2026: „Effekte sollen zu den Karten passen“)
func _chip_vfx(base: String, el: String) -> void:
	var ec: int = 3 + int(e.c)
	match base:
		"Byteschlag", "Glutklinge":
			vfx_add("slash", 3, p.r, 0.25, {"el": el})
		"Laserschuss":
			vfx_add("beam", p.c, p.r, 0.25, {"el": "Code"})
		"Debugger":
			vfx_add("beam", p.c, p.r, 0.35, {"el": "Code", "debug": true})
		"Blitzlanze":
			vfx_add("bolt_col", 3 + p.c, 0, 0.3)
		"Flutwelle":
			vfx_add("wave_row", p.c, p.r, 0.45)
		"Feuersbrunst":
			vfx_add("inferno", 3, 0, 0.7)
		"Tsunami":
			vfx_add("tsunami", 3, 0, 0.6)
			vfx_add("ice", ec, e.r, 1.0)
		"Eisfeld":
			vfx_add("ice", ec, e.r, 1.0)
		"Strudel":
			vfx_add("swirl", ec, e.r, 0.9)
		"Wurmloch":
			vfx_add("portal", ec, e.r, 0.7)
		"Blendgranate":
			vfx_add("flash", ec, e.r, 0.45)
		"Blackout":
			vfx_add("blackout", ec, e.r, 0.8)
		"Magnetfeld":
			vfx_add("magnet", ec, e.r, 0.6, {"pc": p.c, "pr": p.r})
		"Seuche":
			vfx_add("toxic", ec, e.r, 1.0)
		"Kettenblitz":
			vfx_add("chain", ec, e.r, 0.3, {"pc": p.c, "pr": p.r})
		"Funkenregen":
			for i in 3:
				vfx_add("sparkfall", 3 + randi() % 3, randi() % 3, 0.45 + 0.1 * i, {"delay": 0.1 * i})
		"Heilpatch":
			vfx_add("patch", p.c, p.r, 1.0)
		"Neustart":
			vfx_add("reboot", p.c, p.r, 0.8)
		"Übertakten":
			vfx_add("overclock", p.c, p.r, 0.9)
		"Defrag":
			vfx_add("defrag", p.c, p.r, 0.8)
		"Portscan":
			vfx_add("scan", p.c, p.r, 0.7)
		"Ladungsfeld":
			vfx_add("charge", p.c, p.r, 0.8)
		"Sprungantrieb":
			vfx_add("jump", p.c, p.r, 0.5)
		"Firewall", "Kopierschutz", "Konter", "Blubberschild", "Hitzeschild", "Nebel":
			vfx_add("shieldup", p.c, p.r, 0.35, {"el": el})
		"Mini-Bot", "Geschützturm":
			vfx_add("spawn", p.c, p.r, 0.4)
		"Bug-Mine", "Sporenfalle":
			vfx_add("drop", ec, e.r, 0.4)


func _chip_sound(id: String) -> String:
	match id:
		"Pixelstrahl", "Wasserstrahl", "Virusspritzer", "Glutball", "Datenfresser", "Doppelklick", "Laserschuss", "Kurzschluss", "Frostsplitter", "Parasit", "Debugger":
			return "shoot"
		"Byteschlag", "Glutklinge":
			return "slash"
		"Firewall", "Blubberschild", "Hitzeschild", "Nebel", "Kopierschutz", "Konter":
			return "shield"
		"Feuersbrunst", "Tsunami", "Blackout":
			return "special"
		"Sprungantrieb":
			return "dodge"
		"Heilpatch", "Neustart":
			return "heal"
	return "chip"


func _chain_hit(k := 1.0) -> void:
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL.Elektro, 8)
	vfx_add("strike", 3 + e.c, e.r, 0.2, {"small": true})
	hit_enemy(roundi(10 * k), "Elektro")


func _second_click(d := 12) -> void:
	proj.append({"lob": false, "row": p.r, "x": p.c + 0.5, "v": 12.0, "el": "Neutral", "dmg": d, "id": "Doppelklick"})


func _funkenregen(k := 1.0) -> void:
	fx_cell(3 + e.c, e.r, GameData.EL.Feuer, 0.4)
	vfx_add("sparkfall", 3 + e.c, e.r, 0.4)
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL.Feuer, 12)
	hit_enemy(roundi(25 * k), "Feuer")
	if not over:
		e.burn = maxi(e.burn, 3)


func _miss() -> void:
	float_at(3 + e.c, e.r, "verfehlt", GameData.COL.muted)


func _land_glutball(col: int, row: int, k := 1.0) -> void:
	fx_cell(3 + col, row, GameData.EL.Feuer, 0.4)
	vfx_add("explode", 3 + col, row, 0.45)
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var c: int = col + d.x
		var r: int = row + d.y
		if c >= 0 and c < 3 and r >= 0 and r < 3:
			fx_cell(3 + c, r, GameData.EL.Feuer, 0.25)
	burst(3 + col + 0.5, row + 0.5, GameData.EL.Feuer, 16)
	var dist: int = absi(e.c - col) + absi(e.r - row)
	if dist == 0:
		hit_enemy(roundi(45 * k), "Feuer")
		e.burn = 3
	elif dist == 1:
		hit_enemy(roundi(20 * k), "Feuer")
		e.burn = 3
	else:
		_miss()


func _flammenwelle(col: int, k := 1.0) -> void:
	vfx_add("flames_col", 3 + col, 0, 0.55)
	for r in 3:
		fx_cell(3 + col, r, GameData.EL.Feuer, 0.3)
	if e.c == col:
		hit_enemy(roundi(25 * k), "Feuer")
	else:
		_miss()


func _blitz(k := 1.0) -> void:
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL.Elektro, 12)
	vfx_add("strike", 3 + e.c, e.r, 0.3)
	hit_enemy(roundi(20 * k), "Elektro")


# ---------- Treffer ----------

func hit_enemy(d: int, el: String, dot := false) -> void:
	if over:
		return
	var m := 1.0 if dot else GameData.mult(el, def.el)
	if not dot:
		last_mult = m
	if m > 1.0 and run.has_mod("elementlinse"):
		m = 2.0
	if not dot and not in_special and run.has_mod("verstaerker"):
		d += 3
	# Furchtlos (Dachs): unter 30 % HP härter
	if not dot and mon.passive == "Furchtlos" and run.hp * 10 < run.max_hp * 3:
		d = roundi(d * 1.5)
	d = roundi(d * m)
	if not dot and run.has_mod("kritbit") and rng.randf() < 0.2:
		d *= 2
		float_at(3 + e.c, e.r - 0.3, "Krit!", GameData.COL.coral)
	if not dot and scan > 0 and not in_special:
		scan -= 1
		d = roundi(d * 1.5)
	e.hp = maxi(min_e_hp, e.hp - d)
	e.flash = 0.09
	if not dot and not in_special:
		sp = minf(100.0, sp + d * 1.2 * (1.3 if run.has_mod("kondensator") else 1.0))
	# Langfinger (Waschbär): jeder 4. Chip-Treffer lädt einen Chip sofort
	if not dot and not in_special and mon.passive == "Langfinger":
		steal_count += 1
		if steal_count % 4 == 0:
			for s in hand:
				if s.chip != "" and s.rem > 0:
					s.rem = 0.0
					float_at(p.c, p.r, "Geklaut!", GameData.COL.sun)
					break
	if not dot and run.has_mod("saugbit"):
		leech += d
		if leech >= 10:
			var hh := run.heal(leech / 10)
			leech %= 10
			if hh > 0:
				float_at(p.c, p.r, "+%d" % hh, GameData.COL.mint)
	events.append("tick" if dot else ("hit_big" if d >= 30 or m > 1 else "hit"))
	var col: Color = GameData.COL.sun if m > 1 else (GameData.EL[el] if dot else GameData.COL.ink)
	float_at(3 + e.c, e.r, (T.t("Effektiv!") + " " if m > 1 else "") + str(d), col)
	if not dot:
		parts.append({"ring": true, "x": 3 + e.c + 0.5, "y": e.r + 0.45, "color": GameData.COL.sun if m > 1 else Color.WHITE, "t": 0.3, "max": 0.3})
		shake = maxf(shake, 7.0 if d >= 30 else 4.0)
		if d >= 30:
			freeze = 0.06
		burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL.get(el, Color.WHITE), 8)
	if e.hp <= 0:
		_win()


func hurt_player(d: int) -> int:
	if over:
		return 0
	if reflex > 0:
		reflex -= 1
		events.append("dodge")
		float_at(p.c, p.r, "Katzenreflex!", GameData.COL.mint)
		burst(p.c + 0.5, p.r + 0.5, Color("#C9B8FF"), 14)
		return 0
	if (mon.passive == "Spuk" and rng.randf() < 0.2) or (mon.passive == "Schwebegas" and rng.randf() < 0.15):
		events.append("dodge")
		float_at(p.c, p.r, "Spuk!", GameData.EL.Virus)
		return 0
	if decoy > 0 and decoy_t > 0:
		decoy -= 1
		events.append("block")
		float_at(p.c, p.r, "Abbild fängt ab!", GameData.EL.Code)
		burst(p.c + 0.3, p.r + 0.5, GameData.EL.Code, 10)
		return 0
	if dodge_t > 0:
		dodge_t = 0.0
		events.append("dodge")
		float_at(p.c, p.r, "Ausgewichen!", GameData.COL.mint)
		return 0
	if mist > 0 and rng.randf() < 0.5:
		events.append("dodge")
		float_at(p.c, p.r, "Verfehlt!", GameData.EL.Wasser)
		return 0
	if heat > 0:
		heat = 0.0
		events.append("block")
		e.burn = maxi(e.burn, 3)
		float_at(p.c, p.r, "Hitzeschild!", GameData.EL.Feuer)
		return 0
	if shield > 0:
		shield = 0.0
		events.append("block")
		float_at(p.c, p.r, "Geblockt", GameData.EL.Code)
		if counter > 0:
			var cd := counter
			counter = 0
			float_at(3 + e.c, e.r - 0.3, "Konter!", GameData.EL[counter_el])
			hit_enemy(cd, counter_el)
		return 0
	if bubble > 0 and bubble_t > 0:
		var a := mini(bubble, d)
		bubble -= a
		d -= a
		if bubble <= 0:
			float_at(p.c, p.r, "Blase platzt", GameData.EL.Wasser)
		if d <= 0:
			return 0
	if mon.passive in ["Dickes Fell", "Winterschlaf"]:
		d = maxi(1, roundi(d * 0.75))
	if run.has_mod("panzerplatte"):
		d = maxi(1, d - 2)
	if mon.passive in ["Giftbaut", "Schwebegas"]:
		e.poison = maxi(e.poison, 3)
		float_at(3 + e.c, e.r, "Giftbaut", GameData.EL.Virus)
	run.hp = maxi(min_p_hp, run.hp - d)
	# Backup-Kern: einmal pro Run weiterkämpfen statt verlieren
	if run.hp <= 0 and run.has_mod("backupkern") and not run.backup_used:
		run.backup_used = true
		run.hp = maxi(1, roundi(run.max_hp * 0.3))
		events.append("heal")
		float_at(p.c, p.r - 0.4, "Backup-Kern!", GameData.COL.sun)
		burst(p.c + 0.5, p.r + 0.5, GameData.COL.sun, 24)
	events.append("hurt")
	since_hit = 0.0
	sp = minf(100.0, sp + d * 1.5 * (1.3 if run.has_mod("kondensator") else 1.0))
	p.flash = 0.12
	hurt = 0.3
	parts.append({"ring": true, "x": p.c + 0.5, "y": p.r + 0.45, "color": GameData.COL.coral, "t": 0.3, "max": 0.3})
	shake = maxf(shake, 8.0)
	float_at(p.c, p.r, "-%d" % d, GameData.COL.coral)
	if run.hp <= 0:
		_lose()
		return d
	# Dornenpanzer: Angreifer bekommt Schaden zurück
	if run.has_mod("dornenpanzer"):
		hit_enemy(6, "Neutral", true)
	return d


func _win() -> void:
	if over:
		return
	over = true
	outcome = "won"
	events.append("win")
	loot_gained = roundi(def.loot * (1.3 if run.has_mod("sammler") else 1.0) * run.loot_mult)
	run.frag += loot_gained
	run.fights_won += 1
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL[def.el], 24)


func _lose() -> void:
	if over:
		return
	over = true
	outcome = "lost"
	events.append("lose")


# ---------- Effekte ----------

func float_at(c: float, r: float, text: String, color: Color) -> void:
	fx.append({"x": c + 0.5, "y": r + 0.35, "text": text, "color": color, "t": 0.9, "max": 0.9})


func fx_cell(c: int, r: int, color: Color, dur: float) -> void:
	parts.append({"cell": true, "c": c, "r": r, "color": color, "t": dur, "max": dur})


## Rein optische Zufallswerte laufen über randf(), damit die Kampflogik (rng) reproduzierbar bleibt.
func burst(x: float, y: float, color: Color, n: int) -> void:
	for i in n:
		var a := randf() * TAU
		var s := 1.2 + randf() * 2.5
		parts.append({"x": x, "y": y, "vx": cos(a) * s, "vy": sin(a) * s, "color": color, "t": 0.45, "max": 0.45})


func on_slime(c: int, r: int) -> bool:
	return hazards.any(func(hz): return hz.c == c and hz.r == r and hz.get("kind", "lava") == "slime")


## Ur-Glitch: nächstes Element (nie dasselbe), mit Hinweis, was jetzt stark ist
func _shift_element() -> void:
	var opts: Array = GameData.SHIFT_ELEMENTS.filter(func(x): return x != def.el)
	def.el = opts[rng.randi_range(0, opts.size() - 1)]
	var strong := GameData.strong_against(def.el)
	events.append("shift")
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL[def.el], 30)
	float_at(3 + e.c, e.r, T.t("Jetzt %s!") % T.t(def.el), GameData.EL[def.el])
	status = T.t("Der Ur-Glitch ist jetzt %s. %s-Chips treffen ihn besonders hart!") % [T.t(def.el), T.t(strong)]
	shake = maxf(shake, 4.0)


func boss_phase() -> int:
	if not def.boss:
		return 1
	var k: float = float(e.hp) / e.max
	return 1 if k > 0.5 else (2 if k > 0.2 else 3)


# ---------- Hauptschleife ----------

## Ein Bild weiterrechnen (03.10.2026): in Schritten von höchstens SIM_STEP, damit Kampf und Trefferprüfung bei
## 60 und 165 Hz gleich ablaufen. Ein Hänger zählt höchstens MAX_FRAME_DT – das Spiel bremst kurz, statt
## vorzuspulen (sonst könnten Geschosse den Gegner überspringen oder Angriffe ohne Vorwarnung einschlagen).
func advance(delta: float) -> void:
	var dt := minf(delta, MAX_FRAME_DT)
	var steps := maxi(1, ceili(dt / SIM_STEP - 0.001))
	var h := dt / steps
	for k in steps:
		if freeze > 0:
			freeze -= h
		else:
			update(h)
		if over:
			return


func update(dt: float) -> void:
	if not over:
		_update_logic(dt)
	_update_fx(dt)


func _update_logic(dt: float) -> void:
	t += dt
	p.cd = maxf(0.0, p.cd - dt)
	if shield > 0:
		shield -= dt
		if shield <= 0:
			counter = 0
	if dodge_t > 0:
		dodge_t -= dt
	if bubble_t > 0:
		bubble_t -= dt
		if bubble_t <= 0:
			bubble = 0
	if oc > 0:
		oc -= dt
	if heat > 0:
		heat -= dt
	if mist > 0:
		mist -= dt
	if decoy_t > 0:
		decoy_t -= dt
		if decoy_t <= 0:
			decoy = 0
	since_hit += dt
	if mon.passive == "Regeneration" and since_hit >= 3.0 and run.hp < run.max_hp:
		regen_t -= dt
		if regen_t <= 0:
			regen_t = 1.0
			var h := run.heal(2 if run.stage >= 3 else 1)
			float_at(p.c, p.r, "+%d" % h, GameData.COL.mint)

	var rate: float = mon.rech * (2.0 if oc > 0 else 1.0)
	for i in hand.size():
		var s: Dictionary = hand[i]
		if s.rem > 0:
			# Teamgeist (Otter): Support-Slot lädt 25 % schneller
			var r2 := rate * (1.25 if mon.passive == "Teamgeist" and GameData.SLOT_ROLE[i] == 1 else 1.0)
			s.rem = maxf(0.0, s.rem - dt * r2)
	if pend_move != null and p.cd <= 0:
		var m: Vector2i = pend_move
		pend_move = null
		move_player(m.x, m.y)

	for i in range(delayed.size() - 1, -1, -1):
		var d: Dictionary = delayed[i]
		d.t -= dt
		if d.t <= 0:
			delayed.remove_at(i)
			d.fn.call()
			if over:
				return
	for i in range(marks.size() - 1, -1, -1):
		marks[i].t -= dt
		if marks[i].t <= 0:
			marks.remove_at(i)

	for i in range(proj.size() - 1, -1, -1):
		var pr: Dictionary = proj[i]
		if pr.lob:
			pr.t += dt
			if pr.t >= pr.dur:
				proj.remove_at(i)
				pr.land.call()
				if over:
					return
			continue
		pr.x += pr.v * dt
		if e.r == pr.row and absf(pr.x - (3 + e.c + 0.5)) < 0.4:
			proj.remove_at(i)
			var pm := 1
			if pr.id == "Datenfresser" and e.poison > 0:
				pm = 2
			if pr.id == "Frostsplitter" and (e.frozen > 0 or e.slow > 0):
				pm = 3
				float_at(3 + e.c, e.r - 0.3, "Splitter!", GameData.EL.Wasser)
			hit_enemy(pr.dmg * pm, pr.el)
			if pr.id == "Parasit":
				var ph := run.heal(pr.dmg)
				if ph > 0:
					float_at(p.c, p.r, "+%d" % ph, GameData.COL.mint)
			if over:
				return
			if pr.id == "Wasserstrahl" and e.c < 2:
				e.c += 1
			if pr.id == "Virusspritzer":
				e.poison = 4
			if pr.id == "Kurzschluss":
				e.frozen = maxf(e.frozen, 0.5)
				float_at(3 + e.c, e.r, "Kurzschluss!", GameData.EL.Elektro)
			continue
		if pr.x > 6.3:
			proj.remove_at(i)

	# Schaden über Zeit
	if e.burn > 0 or e.poison > 0:
		e.dot_t -= dt
		if e.dot_t <= 0:
			e.dot_t = 1.0
			if e.burn > 0:
				e.burn -= 1
				hit_enemy((8 if mon.passive == "Giftdrüsen" else 5) * (2 if run.has_mod("ueberhitzer") else 1), "Feuer", true)
				if over:
					return
			if e.poison > 0:
				e.poison -= 1
				hit_enemy(roundi((6 if mon.passive == "Giftdrüsen" else 4) * (1.5 if run.has_mod("giftkapsel") else 1.0)), "Virus", true)
				if over:
					return
	for i in range(bots.size() - 1, -1, -1):
		var b: Dictionary = bots[i]
		b.t -= dt
		b.tick -= dt
		if b.tick <= 0:
			if b.get("kind", "bot") == "turret":
				b.tick = 1.5
				for c in 3:
					fx_cell(3 + c, p.r, GameData.EL.Code, 0.15)
				if e.r == p.r:
					hit_enemy(12, "Code")
				events.append("shoot")
			else:
				b.tick = 1.0
				hit_enemy(5, "Code", true)
			if over:
				return
		if b.t <= 0:
			bots.remove_at(i)
	for i in range(mines.size() - 1, -1, -1):
		var mn: Dictionary = mines[i]
		mn.t -= dt
		mn.arm -= dt
		if mn.arm <= 0 and e.c == mn.c and e.r == mn.r:
			mines.remove_at(i)
			burst(3 + mn.c + 0.5, mn.r + 0.5, GameData.EL.Virus, 16)
			hit_enemy(mn.get("dmg", 35), "Virus")
			if mn.has("poison"):
				e.poison = maxi(e.poison, mn.poison)
			if over:
				return
			continue
		if mn.t <= 0:
			mines.remove_at(i)

	# Gegner-KI (Strudel: halbe Geschwindigkeit)
	var phase := boss_phase()
	if phase > e.phase:
		e.phase = phase
		_phase_change(phase)
	var edt := dt
	if e.slow > 0:
		e.slow -= dt
		edt = dt * 0.5
	if e.frozen > 0:
		e.frozen -= dt * (0.67 if run.has_mod("kaeltekern") else 1.0)
	else:
		e.move_t -= edt
		if e.move_t <= 0:
			e.move_t = def.move * (0.8 if phase == 3 else 1.0)
			_move_enemy()
		if def.get("shift", false):
			shift_t -= dt
			if shift_t <= 0:
				shift_t = SHIFT_TIME * (0.7 if phase == 3 else 1.0)
				_shift_element()
		if special_ready(phase):
			e.sp_t -= edt
			if e.sp_t <= 0:
				e.sp_t = def.get("sp_every", SPECIAL_EVERY) * (0.7 if phase == 3 else 1.0)
				start_special()
		e.atk_t -= edt
		if e.atk_t <= 0:
			e.atk_t = 1.5 if phase == 3 else def.atk
			_enemy_attack()
		if phase >= 2 and def.get("minion", "pop") != "none":
			e.pop_t -= dt
			if e.pop_t <= 0:
				e.pop_t = 4.0
				var minion: String = def.get("minion", "pop")
				if minion == "shift":
					# Ur-Glitch: Diener passend zum aktuellen Element
					minion = {"Feuer": "lava", "Virus": "slime"}.get(def.el, "pop")
				if minion == "mix":
					minion = "slime" if rng.randf() < 0.5 else "pop"
				if minion == "slime":
					var sc: Array = [Vector2i(rng.randi_range(0, 2), rng.randi_range(0, 2)), Vector2i(rng.randi_range(0, 2), rng.randi_range(0, 2))]
					events.append("warn")
					warns.append({"cells": sc, "t": 0.9, "max": 0.9, "dmg": 0, "lava": true, "kind": "slime"})
				elif minion == "lava":
					var cells: Array = []
					for k in 2:
						cells.append(Vector2i(rng.randi_range(0, 2), rng.randi_range(0, 2)))
					events.append("warn")
					warns.append({"cells": cells, "t": 0.9, "max": 0.9, "dmg": 0, "lava": true})
				else:
					_spawn_pop()

	for i in range(warns.size() - 1, -1, -1):
		var w: Dictionary = warns[i]
		w.t -= dt
		if w.t <= 0:
			warns.remove_at(i)
			events.append("strike")
			if w.get("lava", false):
				var slime: bool = w.get("kind", "lava") == "slime"
				for cell in w.cells:
					hazards.append({"c": cell.x, "r": cell.y, "t": 4.0 if slime else 3.0, "tick": 0.0, "kind": "slime" if slime else "lava", "seed": randi() % 1000})
					fx_cell(cell.x, cell.y, Color("#7BD35A") if slime else GameData.EL.Feuer, 0.3)
					vfx_add("erupt", cell.x, cell.y, 0.45, {"slime": slime})
				events.append("hit")
				continue
			var hit := false
			for cell in w.cells:
				fx_cell(cell.x, cell.y, Color("#FFB23D") if w.get("big", false) else GameData.COL.coral, 0.25)
				if cell.x == p.c and cell.y == p.r:
					hit = true
			if w.get("big", false):
				shake = maxf(shake, 4.0)
				sp_left -= 1
				if hit:
					sp_fail = true
				elif sp_left <= 0 and not sp_fail:
					_special_dodged()
			if hit:
				var dealt := hurt_player(w.dmg)
				if over:
					return
				# Lebensraub (Saugmücke, Schwarmkönigin)
				if dealt > 0 and def.get("drain", false):
					var heal_e := mini(roundi(dealt * 0.6), e.max - e.hp)
					if heal_e > 0:
						e.hp += heal_e
						float_at(3 + e.c, e.r, "+%d" % heal_e, Color("#7BD35A"))
	for i in range(hazards.size() - 1, -1, -1):
		var hz: Dictionary = hazards[i]
		hz.t -= dt
		if hz.c == p.c and hz.r == p.r and hz.get("kind", "lava") == "lava":
			hz.tick -= dt
			if hz.tick <= 0:
				hz.tick = 0.6
				hurt_player(maxi(2, roundi(def.dmg * (0.2 if run.has_mod("schleimschuhe") else 0.4))))
				if over:
					return
		if hz.t <= 0:
			hazards.remove_at(i)
	for i in range(pops.size() - 1, -1, -1):
		var q: Dictionary = pops[i]
		q.t -= dt
		if q.t <= 0:
			pops.remove_at(i)
			burst(q.c + 0.5, q.r + 0.5, Color("#FF5470"), 14)
			hurt_player(15)
			if over:
				return


func _update_fx(dt: float) -> void:
	hurt = maxf(0.0, hurt - dt)
	for s in hand:
		if s.get("deny", 0.0) > 0:
			s.deny = maxf(0.0, s.deny - dt)
	p.flash = maxf(0.0, p.flash - dt)
	e.flash = maxf(0.0, e.flash - dt)
	shake = maxf(0.0, shake - dt * 30.0)
	jump_t = maxf(0.0, jump_t - dt)
	special_t = maxf(0.0, special_t - dt)
	if not banner.is_empty():
		banner.t -= dt
		if banner.t <= 0:
			banner = {}
	for i in range(fx.size() - 1, -1, -1):
		var f: Dictionary = fx[i]
		f.t -= dt
		f.y -= dt * 0.8
		if f.t <= 0:
			fx.remove_at(i)
	for i in range(vfx.size() - 1, -1, -1):
		vfx[i].t -= dt
		if vfx[i].t <= 0:
			vfx.remove_at(i)
	for i in range(parts.size() - 1, -1, -1):
		var q: Dictionary = parts[i]
		q.t -= dt
		if not q.has("cell") and not q.has("ring"):
			q.x += q.vx * dt
			q.y += q.vy * dt
		if q.t <= 0:
			parts.remove_at(i)


func _move_enemy() -> void:
	if def.get("stationary", false):
		return
	if def.tele:
		var c: int = e.c
		var r: int = e.r
		while c == e.c and r == e.r:
			c = rng.randi_range(0, 2)
			r = rng.randi_range(0, 2)
		e.c = c
		e.r = r
		return
	var opts: Array = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n := Vector2i(e.c + d.x, e.r + d.y)
		if n.x >= 0 and n.x < 3 and n.y >= 0 and n.y < 3:
			opts.append(n)
	# Tendenz zur Spielerreihe, damit Kämpfe nicht verschleppen
	var pref: Array = opts.filter(func(n): return absi(n.y - p.r) < absi(e.r - p.r))
	var pool: Array = pref if (not pref.is_empty() and rng.randf() < 0.4) else opts
	var pick: Vector2i = pool[rng.randi_range(0, pool.size() - 1)]
	e.c = pick.x
	e.r = pick.y


func _enemy_attack() -> void:
	var pat: Array = def.pat
	var phase := boss_phase()
	if phase >= 3 and def.has("phase3"):
		pat = def.phase3
	elif phase >= 2 and def.has("phase2"):
		pat = def.phase2
	var kind: String = pat[e.pi % pat.size()]
	e.pi += 1
	var cells: Array = []
	var warn := WARN_TIME
	match kind:
		"row":
			for c in 3:
				cells.append(Vector2i(c, p.r))
		"col":
			for r in 3:
				cells.append(Vector2i(p.c, r))
		"cross":
			# Plus-Form um den Spieler
			for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n := Vector2i(p.c + d.x, p.r + d.y)
				if n.x >= 0 and n.x < 3 and n.y >= 0 and n.y < 3:
					cells.append(n)
		"col2":
			# zwei benachbarte Spalten, eine davon die des Spielers
			var other: int = p.c + (1 if p.c == 0 else (-1 if p.c == 2 else (1 if rng.randf() < 0.5 else -1)))
			for c in [p.c, other]:
				for r in 3:
					cells.append(Vector2i(c, r))
		"slime", "pop":
			# Schleim: Feld des Spielers + Nachbar werden klebrig (langsamer) · Sporen: sofort eine Glitch-Spore
			if kind == "pop":
				_spawn_pop()
				return
			cells.append(Vector2i(p.c, p.r))
			var nb := Vector2i(clampi(p.c + (1 if rng.randf() < 0.5 else -1), 0, 2), p.r)
			if nb != Vector2i(p.c, p.r):
				cells.append(nb)
			warn = 0.8
		"lava":
			# Feld des Spielers + ein weiteres wird zu Lava
			cells.append(Vector2i(p.c, p.r))
			var n := Vector2i(rng.randi_range(0, 2), rng.randi_range(0, 2))
			if n != Vector2i(p.c, p.r):
				cells.append(n)
			warn = 0.8
		"wall":
			# Zwei Reihen, eine bleibt frei – nie die, in der der Spieler steht
			var safe_rows: Array = [0, 1, 2].filter(func(r): return r != p.r)
			var safe: int = safe_rows[rng.randi_range(0, safe_rows.size() - 1)]
			for r in 3:
				if r != safe:
					for c in 3:
						cells.append(Vector2i(c, r))
			warn = 1.0
		_:
			cells.append(Vector2i(p.c, p.r))
	warn += def.get("warn_bonus", 0.0)
	if mon.passive in ["Eulenblick", "Mischwesen"]:
		warn += 0.3
	events.append("warn")
	warns.append({"cells": cells, "t": warn, "max": warn, "dmg": def.dmg, "lava": kind == "lava" or kind == "slime", "kind": "slime" if kind == "slime" else "lava"})


func _spawn_pop() -> void:
	var free: Array = []
	for c in 3:
		for r in 3:
			if c == p.c and r == p.r:
				continue
			if pops.any(func(q): return q.c == c and q.r == r):
				continue
			free.append(Vector2i(c, r))
	if free.is_empty():
		return
	var cell: Vector2i = free[rng.randi_range(0, free.size() - 1)]
	events.append("pop")
	# Aussehen: Glitch-Spore im Sumpf, sonst Bitmilbe (kleiner Krabbel-Bot)
	var kind := "spore" if run.map.zone == "sumpf" else "milbe"
	if def.get("shift", false):
		kind = "milbe" if def.el == "Code" else "spore"
	kind = def.get("pop_kind", kind)
	pops.append({"c": cell.x, "r": cell.y, "t": 3.0, "max": 3.0, "kind": kind})


# ---------- Phasen und Großangriffe (Wächter & Bosse) ----------

## Phase 2 (unter 50 % HP): neue Angriffsmuster, Bosse beginnen mit Großangriffen.
## Phase 3 (unter 20 %): schneller, Großangriffe öfter und im Wechsel.
func _phase_change(phase: int) -> void:
	e.pi = 0
	shake = maxf(shake, 7.0)
	events.append("phase")
	burst(3 + e.c + 0.5, e.r + 0.5, GameData.EL[def.el], 26)
	var col := Color("#FF5470")
	if phase == 2:
		banner = {"text": "Phase 2!", "color": col, "t": 1.1, "max": 1.1}
		status = T.t("%s wird wütend: neue Angriffe!") % T.t(def.name)
		if not def.get("guard", false) and special_ready(phase):
			e.sp_t = 2.5
	else:
		banner = {"text": "Letzte Phase!", "color": col, "t": 1.1, "max": 1.1}
		status = T.t("%s ist fast besiegt – und wird rasend schnell!") % T.t(def.name)
		e.sp_t = minf(e.sp_t, 3.0)


func special_ready(phase: int) -> bool:
	if not def.has("specials") or def.specials.is_empty():
		return false
	return def.get("guard", false) or phase >= 2


## Löst den nächsten Großangriff aus (Bosse: in Phase 2 nur der erste, ab Phase 3 alle im Wechsel).
func start_special() -> void:
	if not def.has("specials"):
		return
	var list: Array = def.specials
	var n := list.size() if (def.get("guard", false) or boss_phase() >= 3) else 1
	var spec: Dictionary = list[e.sp_i % n]
	e.sp_i += 1
	sp_fail = false
	sp_left = 0
	var dmg := roundi(def.dmg * 1.6)
	var warn: float = SPECIAL_WARN + def.get("warn_bonus", 0.0)
	if mon.passive in ["Eulenblick", "Mischwesen"]:
		warn += 0.3
	banner = {"text": spec.name + "!", "color": Color("#FFB23D"), "t": 1.3, "max": 1.3}
	status = T.t("Großangriff: %s! Weich allen goldenen Feldern aus.") % T.t(spec.name)
	events.append("alarm")
	shake = maxf(shake, 3.0)
	var total := warn
	match spec.shape:
		"x":
			_sp_warn(_cells_where(func(c, r): return c == r or c + r == 2), warn, dmg)
		"ring":
			_sp_warn(_cells_where(func(c, r): return not (c == 1 and r == 1)), warn, dmg)
		"checker":
			var par := (int(p.c) + int(p.r)) % 2
			_sp_warn(_cells_where(func(c, r): return (c + r) % 2 == par), warn, dmg)
		"safe1":
			# nur ein sicheres Feld (nie das, auf dem der Spieler gerade steht)
			var here := Vector2i(p.c, p.r)
			var opts := _cells_where(func(c, r): return Vector2i(c, r) != here)
			var safe: Vector2i = opts[rng.randi_range(0, opts.size() - 1)]
			total = warn + 0.3
			_sp_warn(_cells_where(func(c, r): return Vector2i(c, r) != safe), total, dmg)
		"pull":
			# Fangschlund: zieht den Spieler in die vordere Spalte und schnappt dort zu
			p.c = 2
			pend_move = null
			float_at(p.c, p.r, "Gezogen!", GameData.EL[def.el])
			events.append("move")
			_sp_warn(_cells_where(func(c, r): return c == 2), warn, dmg)
		"pincer":
			# Scherenzange: erst die äußeren Reihen, dann die Mitte
			_sp_warn(_cells_where(func(c, r): return r != 1), warn, dmg)
			_sp_later(warn, func(): return _cells_where(func(c, r): return r == 1), 0.8, dmg)
			total = warn + 0.8
		"tentacle":
			# Tentakelwirbel: erst die äußeren Spalten, dann die Mitte
			_sp_warn(_cells_where(func(c, r): return c != 1), warn, dmg)
			_sp_later(warn, func(): return _cells_where(func(c, r): return c == 1), 0.8, dmg)
			total = warn + 0.8
		"sweep":
			# Reihe für Reihe von oben nach unten (oder umgekehrt)
			var down := rng.randf() < 0.5
			for i in 3:
				var row := i if down else 2 - i
				if i == 0:
					_sp_warn(_cells_where(func(c, r): return r == row), warn, dmg)
				else:
					_sp_later(0.55 * i, func(): return _cells_where(func(c, r): return r == row), warn, dmg)
			total = warn + 1.1
		"chase":
			# Hatz: drei Einschläge, die dem Spieler folgen
			var d2 := roundi(def.dmg * 1.2)
			_sp_warn([Vector2i(p.c, p.r)], 0.8, d2)
			for i in range(1, 3):
				_sp_later(0.65 * i, func(): return [Vector2i(p.c, p.r)], 0.8, d2)
			total = 0.65 * 2 + 0.8
	# Normale Angriffe pausieren, solange der Großangriff läuft
	e.atk_t = maxf(e.atk_t, total + 0.8)


func _cells_where(f: Callable) -> Array:
	var out: Array = []
	for r in 3:
		for c in 3:
			if f.call(c, r):
				out.append(Vector2i(c, r))
	return out


func _sp_warn(cells: Array, warn: float, dmg: int, count := true) -> void:
	if count:
		sp_left += 1
	events.append("warn")
	warns.append({"cells": cells, "t": warn, "max": warn, "dmg": dmg, "lava": false, "big": true})


## Warnfeld mit Verzögerung; die Felder werden erst dann bestimmt (z. B. dort, wo der Spieler gerade steht)
func _sp_later(delay: float, cells_fn: Callable, warn: float, dmg: int) -> void:
	sp_left += 1
	delayed.append({"t": delay, "fn": func(): _sp_warn(cells_fn.call(), warn, dmg, false)})


func _special_dodged() -> void:
	sp_dodged += 1
	e.frozen = maxf(e.frozen, 2.0)
	e.flash = 0.3
	sp = minf(100.0, sp + 15.0)
	events.append("overload")
	float_at(3 + e.c, e.r, "Überlastet!", GameData.COL.sun)
	banner = {"text": "Ausgewichen!", "color": GameData.COL.mint, "t": 0.9, "max": 0.9}
	status = T.t("Perfekt ausgewichen! %s ist kurz überlastet – jetzt angreifen!") % T.t(def.name)
