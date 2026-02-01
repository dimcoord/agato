extends Node

var current_level = 1
var difficulty_scaling = 1.0

func increment_level():
	current_level += 1
	difficulty_scaling += 0.35
