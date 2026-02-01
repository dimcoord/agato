extends Node

var current_level = 1
var difficulty_scaling = 1.0

# Buff system
var selected_mask: String = ""
var jar_capacity_multiplier: float = 1.0
var chase_speed_multiplier: float = 1.0
var spawn_rate_multiplier: float = 1.0
var weight_per_item_multiplier: float = 1.0

var buffs: Dictionary = {
	"default": {
		"jar_capacity_multiplier": 1.2,
		"chase_speed_multiplier": 1.0,
		"spawn_rate_multiplier": 1.0,
		"weight_per_item_multiplier": 1.0
	},
	"default_mask": {
		"jar_capacity_multiplier": 1.0,
		"chase_speed_multiplier": 0.8,
		"spawn_rate_multiplier": 1.0,
		"weight_per_item_multiplier": 1.0
	},
	"default_paper_mask": {
		"jar_capacity_multiplier": 1.0,
		"chase_speed_multiplier": 1.0,
		"spawn_rate_multiplier": 1.3,
		"weight_per_item_multiplier": 1.0
	},
	"default_wilson_mask": {
		"jar_capacity_multiplier": 1.0,
		"chase_speed_multiplier": 1.0,
		"spawn_rate_multiplier": 1.0,
		"weight_per_item_multiplier": 1.5
	}
}

func set_selected_mask(mask_name: String) -> void:
	selected_mask = mask_name
	if mask_name in buffs:
		var buff_data = buffs[mask_name]
		jar_capacity_multiplier = buff_data.get("jar_capacity_multiplier", 1.0)
		chase_speed_multiplier = buff_data.get("chase_speed_multiplier", 1.0)
		spawn_rate_multiplier = buff_data.get("spawn_rate_multiplier", 1.0)
		weight_per_item_multiplier = buff_data.get("weight_per_item_multiplier", 1.0)
		print("Buffs applied for mask: ", mask_name)
		print("Jar capacity: x", jar_capacity_multiplier)
		print("Chase speed: x", chase_speed_multiplier)
		print("Spawn rate: x", spawn_rate_multiplier)
		print("Weight per item: x", weight_per_item_multiplier)

func increment_level():
	current_level += 1
	difficulty_scaling += 0.35
