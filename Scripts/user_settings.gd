extends Node

const SETTINGS_PATH := "user://settings.cfg"

var master_volume := 1.0
var music_volume := 1.0
var sfx_volume := 1.0
var fullscreen := false

func _ready():
	load_settings()
	apply_settings()

func save_settings():
	var cfg := ConfigFile.new()

	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.set_value("video", "fullscreen", fullscreen)

	cfg.save(SETTINGS_PATH)

func load_settings():
	var cfg := ConfigFile.new()
	var err := cfg.load(SETTINGS_PATH)

	if err != OK:
		print("No settings file found, using defaults")
		return

	master_volume = cfg.get_value("audio", "master_volume", master_volume)
	music_volume  = cfg.get_value("audio", "music_volume", music_volume)
	sfx_volume    = cfg.get_value("audio", "sfx_volume", sfx_volume)
	fullscreen    = cfg.get_value("video", "fullscreen", fullscreen)

func apply_settings():
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(master_volume)
	)

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_volume)
	)

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx_volume)
	)

	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if fullscreen
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
