extends Node2D

@export var json_path = "res://Scripts/alt_item_tree.json"
@export var base_distance_decrease_rate = 10.0  # Base amount to decrease per second

@onready var spawn_speed = 1.0 / UserData.difficulty_scaling_factor  # Time interval between spawns
@onready var distance_value: int = 5000 / UserData.difficulty_scaling_factor
@onready var distance = $Control/Distance/Value
@onready var control = $Control

var rng = RandomNumberGenerator.new()
var time_elapsed = 0.0
var items_data = []
var level_5_items = []
var current_item_index = 0
var spawned_buttons_count = 0
var crack_spawn_timer = 0.0
var crack_spawn_interval = 3.0  # Spawn a crack every 3 seconds
var max_cracks = 5


func _ready() -> void:
	distance.text = str(distance_value) + " m"
	UserData.set_difficulty(1.0)
	load_items_data()


func load_items_data():
	items_data.clear()
	level_5_items.clear()
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("Could not open JSON file: ", json_path)
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		print("Failed to parse JSON: ", json_path)
		return
	
	# Extract all items from the JSON structure
	var data = json.data
	extract_items_recursive(data, "")
	print("Total items loaded: ", items_data.size())
	
	# Debug: print all paths
	for item in items_data:
		print("Item path: ", item["path"], " - ", item["name"])
	
	# Filter to only level_5 items for spawning
	for item in items_data:
		var parts = item["path"].split("/")
		if parts.size() >= 2 and parts[-2] == "level_5":
			level_5_items.append(item)

	print("Loaded ", level_5_items.size(), " items from level_5")

func extract_items_recursive(data, path: String):
	if data is Dictionary:
		for key in data.keys():
			var value = data[key]
			var current_path = path + "/" + key if path else key
			
			# Check if this is an item object with texture property
			if value is Dictionary and "texture" in value:
				var item = value.duplicate()
				item["path"] = current_path
				items_data.append(item)
			
			# Recursively check nested dictionaries
			if value is Dictionary:
				extract_items_recursive(value, current_path)

func _process(delta):
	var decrease_amount = base_distance_decrease_rate * delta * UserData.difficulty_scaling_factor
	distance_value -= decrease_amount
	distance.text = str(int(distance_value)) + " m"
	if distance_value <= 0: $GameOver.toggle_pause()
	
	time_elapsed += delta
	var scaled_spawn_speed = spawn_speed
	if time_elapsed >= scaled_spawn_speed:	
		# Count spawned items (TextureRects with item_data meta)
		var current_item_count = 0
		for child in control.get_children():
			if child.has_meta("item_data"):
				current_item_count += 1
		
		# Spawn items until we have 10
		if level_5_items.size() > 0 and current_item_count < 10:
			spawn_item_button()
			current_item_index = (current_item_index + 1) % level_5_items.size()
		time_elapsed = 0.0
	
	# Handle crack spawning
	crack_spawn_timer += delta
	if crack_spawn_timer >= crack_spawn_interval:
		# Count active cracks
		var current_crack_count = 0
		for child in control.get_children():
			if child.is_in_group("cracks"):
				current_crack_count += 1
		
		print("Crack count: ", current_crack_count, "/", max_cracks)
		
		# Spawn crack if under max
		if current_crack_count < max_cracks:
			spawn_crack()
		
		crack_spawn_timer = 0.0

func spawn_item_button():
	var item_data = level_5_items[current_item_index]
	var texture = load(item_data["texture"])
	
	if texture == null:
		print("Failed to load texture: ", item_data["texture"])
		return
	
	# Create TextureButton
	var button = TextureRect.new()
	button.texture = texture
	button.scale = Vector2(0.0, 0.0)
	button.modulate = Color.WHITE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.custom_minimum_size = Vector2(50, 50)
	
	var position_x = int(rng.randf_range(360, 720))
	var position_y = int(rng.randf_range(75, 450))
	button.position = Vector2(position_x, position_y)
	
	# Store item data on button
	button.set_meta("item_data", item_data.duplicate())
	
	# Load drag and drop script
	var script = load("res://Scripts/spawned_item.gd")
	button.set_script(script)
	
	# Add to scene
	control.add_child(button)
	
	# Animate pop-up
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.5, 0.5), 0.2)

func craft_and_spawn(item1: Dictionary, item2: Dictionary, spawn_position: Vector2):
	var crafted_item = craft_items(item1, item2)
	
	if crafted_item.is_empty():
		print("Cannot craft ", item1["name"], " + ", item2["name"])
		return
	
	print("Crafted: ", item1["name"], " + ", item2["name"], " = ", crafted_item["name"])
	spawn_crafted_item(crafted_item, spawn_position)

func craft_items(item1: Dictionary, item2: Dictionary) -> Dictionary:
	var path1 = item1["path"]
	var path2 = item2["path"]
	
	# Extract path parts from both items
	var parts1 = path1.split("/")
	var parts2 = path2.split("/")
	
	var parent_path1 = get_parent_level(parts1)
	var parent_path2 = get_parent_level(parts2)
	if parent_path1 != parent_path2 or parent_path1 == "":
		return {}

	for item in items_data:
		var item_parts = item["path"].split("/")
		var item_parent = "/".join(item_parts.slice(0, -1))
		if item_parent == parent_path1:
			return item.duplicate()

	return {}

func get_parent_level(path_parts: PackedStringArray) -> String:
	# path_parts example: ["level_1", "level_2", "level_3", "level_4", "level_5", "item_1"]
	# Return the container path two levels above the item (e.g. level_1/level_2/level_3/level_4)
	
	if path_parts.size() < 3:
		return ""
	
	return "/".join(path_parts.slice(0, -2))

func spawn_crafted_item(item_data: Dictionary, spawn_position: Vector2 = Vector2.ZERO):
	var texture = load(item_data["texture"])
	
	if texture == null:
		print("Failed to load texture: ", item_data["texture"])
		return
	
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	texture_rect.scale = Vector2(0.0, 0.0)
	texture_rect.modulate = Color.WHITE
	texture_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	texture_rect.custom_minimum_size = Vector2(50, 50)
	texture_rect.position = spawn_position
	
	texture_rect.set_meta("item_data", item_data)
	
	var script = load("res://Scripts/spawned_item.gd")
	texture_rect.set_script(script)
	
	control.add_child(texture_rect)
	
	var tween = create_tween()
	tween.tween_property(texture_rect, "scale", Vector2(0.5, 0.5), 0.2)

func attack_with_item(item_data: Dictionary):
	var damage = item_data.get("damage", 0)
	distance_value += (10 * damage / UserData.difficulty_scaling_factor)
	distance.text = str(int(distance_value)) + " m"
	print("Attacked with ", item_data.get("name", "Item"), "! Damage: ", damage)

func spawn_crack():
	# Create a TextureRect for the crack
	var crack = TextureRect.new()
	# Randomly choose between the two crack textures
	var crack_textures = ["uid://f61o7cgk3v2b", "uid://rqcelx0drqag"]
	crack.texture = load(crack_textures[rng.randi() % crack_textures.size()])
	crack.scale = Vector2(0.8, 0.8)
	crack.custom_minimum_size = Vector2(100, 100)
	crack.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Position along circumference around center
	var center_x = 540
	var center_y = 300
	var radius = 200  # Distance from center
	var radius_variance = 30  # Randomness in the radius
	
	# Random angle around the circle (0 to 2π)
	var angle = rng.randf() * TAU
	
	# Random radius with variance
	var actual_radius = radius + rng.randf_range(-radius_variance, radius_variance)
	
	# Convert polar to cartesian coordinates
	var position_x = center_x + actual_radius * cos(angle)
	var position_y = center_y + actual_radius * sin(angle)
	
	crack.position = Vector2(position_x, position_y)
	
	print("Spawning crack at position: ", crack.position)
	
	# Add crack script
	var script = load("res://Scripts/crack.gd")
	crack.set_script(script)
	
	# Add to group for tracking
	crack.add_to_group("cracks")
	
	# Add to scene root, not to control (so it appears behind items)
	add_child(crack)
