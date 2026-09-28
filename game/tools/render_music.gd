extends SceneTree
## Rendert die Platzhalter-Musik nach assets/music/*.wav.
## Aufruf: godot --headless --path game --script res://tools/render_music.gd


func _init() -> void:
	seed(42)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/music"))
	for key in MusicSynth.TRACKS:
		var t0 := Time.get_ticks_msec()
		var wav := MusicSynth.render(key)
		var path := "res://assets/music/%s.wav" % key
		wav.save_to_wav(ProjectSettings.globalize_path(path))
		print("%s: %.1f s Musik in %d ms" % [path, wav.data.size() / 2.0 / MusicSynth.RATE, Time.get_ticks_msec() - t0])
	quit()
