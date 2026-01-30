extends Node


var difficulty_scaling_factor = 1.0
var high_score = 0

const SETTINGS_PATH := "user://save.cfg"

func _ready():
	load_settings()
	set_difficulty(difficulty_scaling_factor)
	set_high_score(high_score)

func save_settings():
	var cfg := ConfigFile.new()

	cfg.set_value("gameplay", "difficulty_scaling_factor", difficulty_scaling_factor)
	cfg.set_value("gameplay", "high_score", high_score)

	cfg.save(SETTINGS_PATH)

func load_settings():
	var cfg := ConfigFile.new()
	var err := cfg.load(SETTINGS_PATH)

	if err != OK:
		print("No settings file found, using defaults")
		return

	difficulty_scaling_factor = cfg.get_value("gameplay", "difficulty_scaling_factor", difficulty_scaling_factor)
	high_score = cfg.get_value("gameplay", "high_score", high_score)

func set_difficulty(factor: float):
	difficulty_scaling_factor = factor
	save_settings()

func get_scaled_value(base_value: float) -> float:
	return base_value * difficulty_scaling_factor

func set_high_score(score: int):
	if score > high_score:
		high_score = score
		save_settings()

func get_high_score() -> int:
	return high_score
