extends Node2D

@onready var level = $Control/TextureRect

var level_data = {}
@onready var current_level = LevelManager.current_level
var color_palette = {}
var floor_broken = false
var transition_playing = false

func _ready() -> void:
	load_level_data()
	load_color_palette()
	load_level_texture()
	print(color_palette)
	# Background color is now set by main.gd from level_data.json
	# if has_node("Control/ColorRect"):
	# 	if LevelManager.current_level == 1 and "Brown" in color_palette:
	# 		change_level_background(color_palette["Brown"])

func _process(_delta):
	# Check if Total Weight has reached 100
	if not floor_broken and has_node("../Control/FloorHP"):
		var floor_hp = get_node("../Control/FloorHP")
		if floor_hp.value >= 100:
			floor_broken = true
			break_floor()

func break_floor():
	# Reset spawned items
	if has_node("../Main"):
		var main = get_node("../Main")
		if main.has_method("reset_items"):
			main.reset_items()
	
	# Change texture to broken
	if current_level in level_data:
		var level_info = level_data[current_level]
		if "texture_broken" in level_info:
			level.texture = load(level_info["texture_broken"])
	
	# Play transition once and stop looping
	if has_node("../Transition"):
		var timer = get_node("../Transition/Timer")
		var transition = get_node("../Transition")
		transition_playing = true
		transition.play()
		# Connect the timer timeout to handle level advancement and scene reload
		if not timer.timeout.is_connected(_on_timer_timeout):
			timer.timeout.connect(_on_timer_timeout)
		timer.start()
		get_node("../Transition").visible = true

func load_level_texture():
	if current_level in level_data:
		var level_info = level_data[current_level]
		if "texture" in level_info:
			level.texture = load(level_info["texture"])

func change_level_background(color: String) -> void:
	if has_node("Control/ColorRect"):
		$Control/ColorRect.color = Color.html(color)

func load_level_data():
	var file = FileAccess.open("res://Scripts/level_data.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			level_data = json.data

func load_color_palette():
	if current_level in level_data:
		var level_info = level_data[current_level]
		# Load all colors except softlock
		for key in level_info.keys():
			if key != "softlock":
				color_palette[key] = level_info[key]

func change_level(background):
	level.texture = load(background)

func advance_level():
	# Increment level and difficulty scaling
	UserData.increment_level()
	print("Advanced to level: ", UserData.current_level)


func _on_timer_timeout() -> void:
	LevelManager.increment_level()
	get_tree().reload_current_scene()
