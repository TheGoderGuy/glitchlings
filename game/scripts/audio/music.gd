extends Node
## Hintergrundmusik mit Überblendung. Aufruf: Music.play("battle"). Eigener Audio-Bus „Music“.
## Karte und Titel spielen beim Zurückkehren dort weiter, wo sie aufgehört haben;
## Kampf, Boss und Siegesfanfare beginnen immer von vorn (mit ihrem Intro).

const RESUME := ["map", "title"]
## Einblendzeit je Stück: Kämpfe starten knackig, die Karte blendet weich ein
const FADE_IN := {"map": 1.2, "title": 1.0, "battle": 0.05, "boss": 0.05, "victory": 0.02, "intro": 2.0, "finale": 0.05, "ending": 1.5}
const FADE_OUT := 0.45

var players: Array[AudioStreamPlayer] = []
var active := 0
var current := ""
var positions := {}   # gemerkte Abspielposition je Stück
var tween: Tween      # laufende Überblendung (wird bei jedem Wechsel abgebrochen)


func _ready() -> void:
	if AudioServer.get_bus_index("Music") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		p.volume_db = -80.0
		add_child(p)
		players.append(p)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.apply()  # Musik-Bus existiert erst jetzt


## Stück der Zone, falls vorhanden („map_vulkan“), sonst das allgemeine („map“)
func zone_key(kind: String, zone: String) -> String:
	var k := "%s_%s" % [kind, zone]
	return k if ResourceLoader.exists("res://assets/music/%s.wav" % k) else kind


## Karten und Titel (auch die Zonen-Fassungen) spielen dort weiter, wo sie aufgehört haben
func _resumes(key: String) -> bool:
	return RESUME.has(key.get_slice("_", 0))


func play(key: String) -> void:
	if key == current:
		return
	var path := "res://assets/music/%s.wav" % key
	if not ResourceLoader.exists(path):
		return
	var old := players[active]
	if current != "" and old.playing and _resumes(current):
		positions[current] = old.get_playback_position()
	current = key
	active = 1 - active
	var neu := players[active]
	var stream: AudioStreamWAV = load(path)
	# Schleife in Frames; neue Stereo-Stücke spielen das Intro nur einmal, danach A+B in Schleife
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = roundi(stream.get_length() * stream.mix_rate)
	stream.loop_begin = MusicSynth.intro_frames(key) if stream.stereo and MusicSynth.TRACKS.has(key) else 0
	neu.stream = stream
	var fade_in: float = FADE_IN.get(key.get_slice("_", 0), 0.6)
	# Laufende Blenden des vorigen Wechsels abbrechen – sonst stoppt ihr verspäteter
	# Stopp-Befehl genau den Abspieler, der gerade das neue Stück spielt (Musik bleibt stumm).
	_kill_tween()
	neu.volume_db = -30.0 if fade_in > 0.1 else 0.0
	neu.play(positions.get(key, 0.0) if _resumes(key) else 0.0)
	tween = create_tween().set_parallel(true)
	if fade_in > 0.1:
		tween.tween_property(neu, "volume_db", 0.0, fade_in).set_trans(Tween.TRANS_SINE)
	tween.tween_property(old, "volume_db", -80.0, FADE_OUT).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(_stop_if_inactive.bind(old))


func stop() -> void:
	var old := players[active]
	if current != "" and old.playing and _resumes(current):
		positions[current] = old.get_playback_position()
	current = ""
	_kill_tween()
	tween = create_tween().set_parallel(true)
	for p in players:
		tween.tween_property(p, "volume_db", -80.0, FADE_OUT * 2.0)
	tween.chain().tween_callback(func():
		# nur stoppen, wenn inzwischen kein neues Stück gestartet wurde
		if current == "":
			for p in players:
				p.stop()
	)


func _kill_tween() -> void:
	if tween != null and tween.is_valid():
		tween.kill()


## Stoppt einen Abspieler nur, wenn er nicht (wieder) der aktive ist
func _stop_if_inactive(p: AudioStreamPlayer) -> void:
	if p != players[active] or current == "":
		p.stop()
