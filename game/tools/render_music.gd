extends SceneTree
## Rendert die Platzhalter-Musik nach assets/music/*.wav.
## Aufruf: godot --headless --path game --script res://tools/render_music.gd [-- stück …]
## Die alte Kampfmusik (battle.wav) gefällt dem Produzenten („episch“) und wird NICHT überschrieben;
## die neue Fassung landet zum Vergleich in battle_neu.wav.

const OUT := {"title": "title", "map": "map", "boss": "boss", "battle": "battle_neu", "victory": "victory"}


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/music"))
	var only := OS.get_cmdline_user_args()
	for key in MusicSynth.TRACKS:
		if not only.is_empty() and not only.has(key):
			continue
		var t0 := Time.get_ticks_msec()
		var wav := MusicSynth.render(key)
		var path := "res://assets/music/%s.wav" % OUT[key]
		wav.save_to_wav(ProjectSettings.globalize_path(path))
		print("%s: %.1f s (Intro %.1f s) in %d ms" % [path, wav.data.size() / 4.0 / MusicSynth.RATE,
			MusicSynth.intro_frames(key) / float(MusicSynth.RATE), Time.get_ticks_msec() - t0])
	quit()
