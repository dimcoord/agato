extends Node2D

@onready var level = $Control/TextureRect

var level_data = {}
var current_level = "Level_1"
var color_palette = {}
var floor_broken = false

func _ready() -> void:
	load_level_data()
	load_color_palette()
	load_level_texture()
	print(color_palette)
	# Only try to change background if the node exists
	if has_node("Control/ColorRect"):
		change_level_background(color_palette["Brown"])

func _process(delta):
	# Check if FloorHP has reached 0
	if not floor_broken and has_node("../Control/FloorHP"):
		var floor_hp = get_node("../Control/FloorHP")
		if floor_hp.value <= 0:
			floor_broken = true
			break_floor()

func break_floor():
	# Change texture to broken
	if current_level in level_data:
		var level_info = level_data[current_level]
		if "texture_broken" in level_info:
			level.texture = load(level_info["texture_broken"])
	
	# Play transition once and stop looping
	if has_node("../Transition"):
		var timer = get_node("../Transition/Timer")
		var transition = get_node("../Transition")
		transition.play()
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

func _on_transition_finished(anim_name):
	# Stop the transition from looping
	if has_node("../Transition"):
		get_node("../Transition").stop()


func _on_timer_timeout() -> void:
	get_node("../Transition").queue_free()
