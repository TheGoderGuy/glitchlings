extends Node
## Spieler-Einstellungen, gespeichert in user://settings.cfg.

const PATH := "user://settings.cfg"

var fullscreen := false
var volume := 8          # 0–10
var screen_shake := true


func _ready() -> void:
	load_settings()
	apply()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	fullscreen = cfg.get_value("video", "fullscreen", fullscreen)
	volume = cfg.get_value("audio", "volume", volume)
	screen_shake = cfg.get_value("comfort", "screen_shake", screen_shake)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("audio", "volume", volume)
	cfg.set_value("comfort", "screen_shake", screen_shake)
	cfg.save(PATH)


func apply() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(volume / 10.0) if volume > 0 else -80.0)
	AudioServer.set_bus_mute(bus, volume == 0)
