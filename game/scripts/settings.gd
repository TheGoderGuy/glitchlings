extends Node
## Spieler-Einstellungen, gespeichert in user://settings.cfg.

const PATH := "user://settings.cfg"

var fullscreen := false
var volume := 8          # 0–10 Gesamtlautstärke
var music := 6           # 0–10 Musik
var difficulty := 1      # 0 Entspannt, 1 Normal, 2 Knackig
var screen_shake := true
var lang := ""           # "de" / "en"; leer = beim ersten Start aus der Systemsprache


func _ready() -> void:
	load_settings()
	apply()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		lang = T.system_lang()
		return
	fullscreen = cfg.get_value("video", "fullscreen", fullscreen)
	volume = cfg.get_value("audio", "volume", volume)
	music = cfg.get_value("audio", "music", music)
	difficulty = cfg.get_value("game", "difficulty", difficulty)
	screen_shake = cfg.get_value("comfort", "screen_shake", screen_shake)
	lang = cfg.get_value("game", "lang", "")
	if not T.LANGS.has(lang):
		lang = T.system_lang()


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("audio", "volume", volume)
	cfg.set_value("audio", "music", music)
	cfg.set_value("game", "difficulty", difficulty)
	cfg.set_value("comfort", "screen_shake", screen_shake)
	cfg.set_value("game", "lang", lang)
	cfg.save(PATH)


func apply() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(volume / 10.0) if volume > 0 else -80.0)
	AudioServer.set_bus_mute(bus, volume == 0)
	var mb := AudioServer.get_bus_index("Music")
	if mb >= 0:
		AudioServer.set_bus_volume_db(mb, linear_to_db(music / 10.0) - 4.0 if music > 0 else -80.0)
		AudioServer.set_bus_mute(mb, music == 0)
