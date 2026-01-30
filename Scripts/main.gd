extends Node2D

@export var spawn_speed = 1.0
@export var distance_value: int = 1000
@export var json_path = "res://Scripts/item_tree.json"

@onready var distance = $Control/Distance/Value
@onready var control = $Control

var rng = RandomNumberGenerator.new()
var time_elapsed = 0.0
var texture_uuids = []
var current_uuid_index = 0
var spawned_buttons_count = 0

func _ready() -> void:
	distance.text = str(distance_value) + " m"
	UserData.set_difficulty(1.0)
	load_texture_uuids()

func load_texture_uuids():
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("Could not open JSON file: ", json_path)
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		print("Failed to parse JSON: ", json_path)
		return
	
	# Extract all UUIDs from the JSON structure
	var data = json.data
	extract_uuids_recursive(data)
	print("Loaded ", texture_uuids.size(), " texture UUIDs")

func extract_uuids_recursive(data):
	if data is Dictionary:
		for key in data.keys():
			var value = data[key]
			# Check if this is an item object with a texture property
			if value is Dictionary and "texture" in value:
				var texture_uuid = value["texture"]
				if texture_uuid is String and texture_uuid.begins_with("uid://"):
					texture_uuids.append(texture_uuid)
			# Recursively check nested dictionaries
			if value is Dictionary:
				extract_uuids_recursive(value)

func _process(delta):
	distance_value -= delta / UserData.difficulty_scaling_factor
	distance.text = str(int(distance_value)) + " m"
	if distance_value <= 0: $GameOver.toggle_pause()
	
	time_elapsed += delta
	var scaled_spawn_speed = spawn_speed / UserData.difficulty_scaling_factor
	if time_elapsed >= scaled_spawn_speed:	
		if texture_uuids.size() > 0 and spawned_buttons_count < 10:
			spawn_item_button()
			current_uuid_index = (current_uuid_index + 1) % texture_uuids.size()
		time_elapsed = 0.0

func spawn_item_button():
	var texture_uuid = texture_uuids[current_uuid_index]
	var texture = load(texture_uuid)
	
	if texture == null:
		print("Failed to load texture: ", texture_uuid)
		return
	
	# Create new TextureButton
	var button = TextureButton.new()
	button.texture_normal = texture
	button.scale = Vector2(0.0, 0.0)
	
	var position_x = int(rng.randf_range(360, 720))
	var position_y = int(rng.randf_range(75, 450))
	button.position = Vector2(position_x, position_y)
	
	# Attach object.gd script
	var object_script = load("res://Scripts/object.gd")
	button.set_script(object_script)
	
	# Connect signals
	button.button_down.connect(button._on_button_down)
	button.button_up.connect(button._on_button_up)
	
	# Add to scene
	control.add_child(button)
	spawned_buttons_count += 1
	
	# Animate pop-up
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.5, 0.5), 0.2)
