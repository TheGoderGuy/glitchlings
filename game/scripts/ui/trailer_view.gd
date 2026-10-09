extends Node
## Trailer (09.10.2026): ca. 73 s, taktgenau zum Stück „trailer“ (120 BPM, 1 Takt = 2 s). Schneidet echte Spielszenen
## (Kämpfe mit Autopilot, Boss-Intros, Evolution, Zuhause, Labor, Karte) zwischen Kino-Bilder (trailer_canvas.gd).
## Aufnahme: godot --path game --write-movie build/trailer/Glitchlings_Trailer.avi --fixed-fps 60 --resolution 1920x1080 -- --play=trailer [--lang=en]
## Notiz: vault/05 Produktion/Trailer.md

signal finished

const BattleScene := preload("res://scenes/battle.tscn")
const StationScreen := preload("res://scripts/ui/station_view.gd")
const MapScreen := preload("res://scripts/ui/map_view.gd")
const RouteScreen := preload("res://scripts/ui/route_view.gd")
const TrailerCanvas := preload("res://scripts/ui/trailer_canvas.gd")

const BAR := 2.0
const END := 73.0

## Schnittliste: [Takt, Art, Werte]. Kämpfe: zone, form, foe (Index in GameData.FOES) oder type guard/boss,
## pre = Sekunden vorspulen, do = besondere Momente (counter, special, gold).
const CUTS := [
	[0, "world", {"text": "Tief im Netz liegt der NEST."}],
	[2, "corrupt", {"text": "Doch ein Fehler zerreißt ihn ..."}],
	[4, "egg", {"text": "Etwas regt sich."}],
	[7, "fight", {"zone": "wiesen", "form": "Pixmiez", "foe": 0, "pre": 0.0}],
	[8, "fight", {"zone": "vulkan", "form": "Glutbyte", "foe": 7, "pre": 2.5}],
	[9, "fight", {"zone": "see", "form": "Kaskadi", "foe": 31, "pre": 2.0, "do": "counter"}],
	[10, "fight", {"zone": "sumpf", "form": "Sporenpranke", "foe": 26, "pre": 3.0}],
	[11, "fight", {"zone": "steppe", "form": "Sturmschwinge", "foe": 38, "pre": 3.0}],
	[12, "fight", {"zone": "kern", "form": "Aurorlynx", "foe": 28, "pre": 2.0, "do": "special"}],
	[13, "fight", {"zone": "vulkan", "form": "Leviamander", "type": "guard", "pre": 1.0, "do": "gold"}],
	[14, "evolve", {"zone": "vulkan", "form": "Glutbyte"}],
	[16, "chain", {}],
	[18, "tree", {}],
	[20, "home", {}],
	[22, "fusion", {}],
	[23, "legend", {"form": "Sternwal"}],
	[24, "map", {"zone": "steppe"}],
	[25, "route", {}],
	[26, "intro", {"zone": "wiesen"}],
	[27, "intro", {"zone": "see"}],
	[28, "intro", {"zone": "sumpf"}],
	[29, "intro", {"zone": "steppe"}],
	[30, "intro", {"zone": "kern", "mystery": true}],
	[31, "fight", {"zone": "kern", "form": "Glutfenrir", "type": "boss", "pre": 1.0, "do": "special", "at": 0.7, "mystery": true}],
	[32, "title", {}],
]

## Einblendungen (Sekunden): [Zeit, Dauer, Art, Text, zweite Zeile, Höhe der Tafel]
## (kein „ß“ in Silkscreen-Texten: die Pixelschrift zeichnet es wie ein B)
const CARDS := [
	[12.05, 1.85, "word", "BRÜTE", "", 292.0],
	[14.0, 0.95, "word", "KÄMPFE", "", 180.0],
	[15.0, 0.95, "caption", "Echtzeit-Kämpfe auf dem Raster"],
	[16.1, 1.8, "caption", "Spiele Chips aus deinem Deck"],
	[18.1, 1.8, "caption", "Konter, wenn der Gegner ausholt"],
	[20.1, 1.8, "caption", "Sechs Zonen voller korrupter Daten"],
	[24.1, 1.8, "caption", "Entfessle Signatur-Attacken"],
	[26.1, 1.8, "caption", "Weich den goldenen Feldern aus"],
	[28.05, 1.9, "line", "DEINE SPIELWEISE", "BESTIMMT DIE EVOLUTION", 296.0],
	[40.1, 3.8, "caption", "Zieh sie in deiner Station auf"],
	[44.1, 1.8, "caption", "Verschmelze sie zu Fusionen"],
	[46.1, 1.8, "caption", "Finde legendäre Glitchlinge"],
	[48.1, 1.8, "caption", "Jede Reise ist anders"],
	[50.1, 1.8, "caption", "Wähle deinen Weg"],
]
const FLASHES := [[8.0, 0.35], [12.0, 0.4], [64.0, 0.6]]

var t := 0.0
var ci := -1
var screen: Node
var overlay
var cues: Array = []   # [Zeit, Callable] im laufenden Schnitt
var done := false
var saved_events := {}   # Tasten und Controller sind während der Aufnahme aus (ein leicht gedrückter Trigger löste sonst Signaturen aus)


func _ready() -> void:
	seed(20261009)
	for a in InputMap.get_actions():
		if not String(a).begins_with("ui_"):
			saved_events[a] = InputMap.action_get_events(a)
			InputMap.action_erase_events(a)
	SaveGame.persist = false
	_demo_save()
	PixelCanvas.cinematic = true
	Music.locked = false
	Music.play("trailer")
	Music.locked = true
	overlay = TrailerCanvas.new()
	overlay.scene = "overlay"
	for c in CARDS:
		overlay.cards.append({"at": c[0], "dur": c[1], "kind": c[2], "text": c[3], "text2": c[4] if c.size() > 4 else "", "y": c[5] if c.size() > 5 else 180.0})
	for f in FLASHES:
		overlay.flashes.append({"at": f[0], "dur": f[1]})
	add_child(overlay)
	_cut(0)


func _process(delta: float) -> void:
	if done:
		return
	t += delta
	while ci + 1 < CUTS.size() and t >= CUTS[ci + 1][0] * BAR:
		_cut(ci + 1)
	for c in cues:
		if not c[2] and t >= c[0]:
			c[2] = true
			c[1].call()
	if t >= END:
		done = true
		PixelCanvas.cinematic = false
		Music.locked = false
		for a in saved_events:
			for ev in saved_events[a]:
				InputMap.action_add_event(a, ev)
		finished.emit()


func _cut(i: int) -> void:
	ci = i
	var kind: String = CUTS[i][1]
	var p: Dictionary = CUTS[i][2]
	var t0: float = CUTS[i][0] * BAR
	cues = []
	if screen:
		screen.queue_free()
	match kind:
		"world", "corrupt", "egg", "chain", "tree", "legend", "title":
			screen = _cinema(kind, p)
		"fight":
			screen = _fight(p, t0)
		"evolve":
			screen = _evolve(p)
		"intro":
			screen = _intro(p)
		"home":
			screen = _home(t0)
		"fusion":
			screen = _fusion()
		"map":
			screen = _map(p)
		"route":
			screen = _route()
	add_child(screen)
	move_child(screen, 0)


func _cue(at: float, f: Callable) -> void:
	cues.append([at, f, false])


# ---------- Spielstand nur im Speicher ----------

const TEAM := [["Pixmiez", "Aurorlynx"], ["Funkling", "Glutfenrir"], ["Tröpfel", "Leviamander"], ["Kekso", "Cachy"], ["Lumi", "Strahlhase"],
	["Quakli", "Quakli"], ["Molchi", "Magmolch"], ["Brummbit", "Sporenpranke"], ["Kauzbit", "Phönixkauz"], ["Buddli", "Buddli"],
	["Bachli", "Wogotter"], ["Plapperli", "Sturmschwinge"]]


func _demo_save() -> void:
	SaveGame.new_game("Pixmiez")
	SaveGame.data.team = []
	for m in TEAM:
		var mm := SaveGame.add_monster(m[0])
		mm.form = m[1]
		mm.stage = GameData.FORMS[m[1]].stage
		SaveGame.see(m[1])
	SaveGame.data.frag = 480
	for k in ["tutorial_done", "station_guide_done", "map_tip_done", "deck_intro_done"]:
		SaveGame.data[k] = true
	var seen: Array = []
	for c in GameData.CHIPS:
		seen.append(c)
	SaveGame.data["seen_chips"] = seen
	SaveGame.data.cleared = ["wiesen", "vulkan", "see"]


func _monster(form: String) -> Dictionary:
	var sp: String = GameData.MONS.keys().filter(func(s): return _line_has(s, form))[0] if not GameData.MONS.has(form) else form
	var m := {"id": 900, "species": sp, "form": form, "stage": GameData.FORMS[form].stage, "praeg": {}, "chips": 0, "runs": 0, "wins": 0}
	return m


## Gehört die Form zur Linie (Baby, Rookies über evo, dann aufwärts)?
func _line_has(sp: String, form: String) -> bool:
	if sp == form:
		return true
	for el in GameData.MONS[sp].get("evo", {}):
		var f: String = GameData.MONS[sp].evo[el]
		while f != "":
			if f == form:
				return true
			f = GameData.FORMS[f].up
	return false


## Deck passend zum Element der Form: Angriffs-Chips des Elements, dazu Schutz und Heilung
func _deck_for(el: String) -> Array:
	var atk: Array = []
	for c in GameData.CHIPS:
		var C: Dictionary = GameData.CHIPS[c]
		if C.el == el and GameData.role(c) == 0 and C.rar != "Linie" and not c.ends_with("+"):
			atk.append(c)
	if atk.is_empty():
		atk = ["Pixelstrahl", "Byteschlag"]
	var deck: Array = []
	for i in 6:
		deck.append(atk[i % atk.size()])
	deck.append_array(["Firewall", "Heilpatch"])
	return deck


func _run_for(form: String, zone: String, seed_v: int) -> RunState:
	var r := RunState.from_monster(_monster(form), seed_v, zone)
	r.act = GameData.act_of(zone)
	r.deck = _deck_for(GameData.FORMS[form].el)
	r.max_hp = 160
	r.hp = 140
	r.floor_idx = 1   # Anzeige „Etage 2“ statt „Etage 0“
	r.pos = 0
	return r


# ---------- Kino-Bilder ----------

func _cinema(kind: String, p: Dictionary) -> Node:
	var c = TrailerCanvas.new()
	c.scene = kind
	c.text = p.get("text", "")
	c.form = p.get("form", "")
	match kind:
		"chain":
			c.chains = [_chain("Pixmiez", "Elektro"), _chain("Tröpfel", "Wasser")]
		"tree":
			var rows: Array = []
			for el in ["Code", "Virus", "Elektro"]:
				var ch := _chain("Pixmiez", el)
				rows.append(ch.forms.slice(1))
			c.tree = {"baby": "Pixmiez", "rows": rows, "count": StationScreen.DEX_ORDER.size()}
		"title":
			c.lineup = ["Glutfenrir", "Leviamander", "Aurorlynx", "Infernokauz", "Voltameles"]
	return c


func _chain(sp: String, el: String) -> Dictionary:
	var forms: Array = [sp]
	var f: String = GameData.MONS[sp].evo[el]
	while f != "" and forms.size() < 4:
		forms.append(f)
		f = GameData.FORMS[f].up
	return {"el": el, "forms": forms}


# ---------- Kämpfe ----------

func _fight(p: Dictionary, t0: float) -> Node:
	var zone: String = p.zone
	var type: String = p.get("type", "fight")
	var r := _run_for(p.form, zone, 11 + ci)
	var foe: Dictionary
	match type:
		"guard":
			foe = GameData.FOES[GameData.ZONES[zone].guards[0]].duplicate(true)
		"boss":
			foe = GameData.FOES[GameData.ZONES[zone].boss].duplicate(true)
		_:
			foe = r.foe_for({"type": "fight"}) if not p.has("foe") else GameData.FOES[p.foe].duplicate(true)
	var b := BattleScene.instantiate()
	# Geheimnis: der Ur-Glitch bleibt ein Umriss ohne Namen
	if p.get("mystery", false):
		foe.name = "???"
		b.mystery_foe = true
	b.setup(r, foe, type)
	b.skip_ready = true
	b._set_mode(b.Mode.FIGHT)
	b.st.min_e_hp = 1   # in zwei Sekunden soll niemand gewinnen oder verlieren
	b.st.min_p_hp = 1
	b.st.e.max *= 4     # zäher: keine Phasenwechsel mitten im Schnitt
	b.st.e.hp = b.st.e.max
	if type == "boss":
		b.st.e.hp = roundi(b.st.e.max * 0.45)   # Phase 2: Großangriffe
		b.st.e.phase = 2
	# Signatur nur dort, wo sie gezeigt werden soll (sonst friert sie z. B. den Gegner ein)
	var bot := BattleBot.new(0.12)
	bot.allow_special = false
	if float(p.pre) > 0.0:
		b.mat_t = 0.0
		b.simulate(p.pre, bot)
	b.autopilot = bot
	b.st.sp = 0.0
	b.st.e.frozen = 0.0
	match p.get("do", ""):
		"gold":
			# Goldener Großangriff läuft schon 0,8 s: im Bild die letzten Warnfelder, dann Ausweichen und „Überlastet!“
			b.st.start_special()
			b.simulate(0.8, bot)
		"counter":
			# Gegner holt gleich aus, ein Angriff liegt bereit: der Bot wartet auf das Fadenkreuz
			bot.counter_wait = true
			b.st.p.r = b.st.e.r
			b.st.e.atk_t = 0.35
			b.st.warns.clear()
			for s in b.st.hand:
				s.rem = 0.0
		"special":
			b.st.sp = 99.0
			_cue(t0 + float(p.get("at", 0.2)), func():
				b.st.sp = 100.0
				b.st.use_special()
			)
	return b


func _evolve(p: Dictionary) -> Node:
	var r := _run_for(p.form, p.zone, 31)
	var b := BattleScene.instantiate()
	b.setup(r, GameData.FOES[7].duplicate(true), "fight")
	b.skip_ready = true
	b._set_mode(b.Mode.FIGHT)
	b.mat_t = 0.0
	# Enthüllung genau auf dem Taktanfang nach zwei Sekunden (Abschnitt „evolve“ setzt dort ein)
	b.show_evolve_for_screenshot(b.EVO_REVEAL - BAR)
	return b


func _intro(p: Dictionary) -> Node:
	var r := _run_for("Aurorlynx", p.zone, 41 + ci)
	var b := BattleScene.instantiate()
	var foe: Dictionary = GameData.FOES[GameData.ZONES[p.zone].boss].duplicate(true)
	if p.get("mystery", false):
		foe.name = "???"
		b.mystery_foe = true
	b.setup(r, foe, "boss")
	# Enthüllung auf dem Taktanfang
	b.show_intro_for_screenshot(b.INTRO_REVEAL - 0.02)
	return b


# ---------- Station ----------

func _station() -> Node:
	var s = StationScreen.new()
	return s


func _home(t0: float) -> Node:
	SaveGame.data.nest = []
	var s = _station()
	s.ready.connect(func():
		s.tab = s.Tab.HOME
		s._sync_home()
		s.home.setup(SaveGame.team(), 7)
		s.home.daytime = "abend"
		for k in 360:
			s.home.update(1.0 / 60.0)
		s.anim_t = 6.0
		s.t_in = 1.0
	)
	_cue(t0 + 0.9, func():
		s.pet_msg = s.home.pet(s.home_sel)
		s.pet_t = 2.4
		Sfx.play("pop", 0.0)
	)
	return s


func _fusion() -> Node:
	var R: Dictionary = GameData.RECIPES[1]
	var a := SaveGame.add_monster(R.a)
	var b := SaveGame.add_monster(R.b)
	SaveGame.data.frag = 500
	SaveGame.data.nest = []
	var s = _station()
	s.ready.connect(func():
		s.tab = s.Tab.LAB
		s.t_in = 1.0
		s.fusion = SaveGame.try_fuse(int(a.id), int(b.id), RandomNumberGenerator.new())
		s.hatch_t = s.HATCH_REVEAL - 1.0
	)
	return s


# ---------- Karte und Weggabelung ----------

func _map(p: Dictionary) -> Node:
	var r := _run_for("Strahlhase", p.zone, 51)
	r.enter(r.next_choices()[0])
	r.enter(r.next_choices()[0])
	var m = MapScreen.new()
	m.setup(r)
	return m


func _route() -> Node:
	var r := _run_for("Aurorlynx", "wiesen", 52)
	r.bosses = ["wiesen"]
	r.route_pending = true
	var v = RouteScreen.new()
	v.setup(r)
	return v
