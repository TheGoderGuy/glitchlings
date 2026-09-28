extends Node
## Hintergrundmusik mit Überblendung. Aufruf: Music.play("battle"). Eigener Audio-Bus „Music“.

const FADE := 0.6

var players: Array[AudioStreamPlayer] = []
var active := 0
var current := ""


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


func play(key: String) -> void:
	if key == current:
		return
	current = key
	var path := "res://assets/music/%s.wav" % key
	if not ResourceLoader.exists(path):
		return
	var old := players[active]
	active = 1 - active
	var neu := players[active]
	var stream: AudioStreamWAV = load(path)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = stream.data.size() / 2
	neu.stream = stream
	neu.volume_db = -40.0
	neu.play()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(neu, "volume_db", 0.0, FADE)
	tw.tween_property(old, "volume_db", -80.0, FADE)
	tw.chain().tween_callback(old.stop)


func stop() -> void:
	current = ""
	for p in players:
		var tw := create_tween()
		tw.tween_property(p, "volume_db", -80.0, FADE)
		tw.tween_callback(p.stop)
