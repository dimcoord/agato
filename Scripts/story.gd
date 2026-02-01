extends Node2D

@export var json_path = "res://Scripts/alt_item_tree.json"
@export var level_data_path = "res://Scripts/level_data.json"
@export var base_distance_decrease_rate = 10.0  # Base amount to decrease per second

@onready var spawn_speed = 1.0 / LevelManager.difficulty_scaling  # Time interval between spawns
@onready var distance_value: int = 5000 / LevelManager.difficulty_scaling
@onready var distance = $Control/Distance/Value
@onready var control = $Control
@onready var current_level = $Control/Level/Value

var rng = RandomNumberGenerator.new()
var time_elapsed = 0.0
var items_data = []
var level_5_items = []
var current_item_index = 0
var spawned_buttons_count = 0
var crack_spawn_timer = 0.0
var crack_spawn_interval = 3.0  # Spawn a crack every 3 seconds
var max_cracks = 5
var level_data = {}

# Score system
var item_count = 0  # Count of items placed/dropped
var item_limit = 5  # Base limit for items (can be modified per level)
var score_index = 0  # 0=A, 1=B, 2=C, 3=D, 4=E, 5=F (game over)
var score_grades = ["A", "B", "C", "D", "E", "F"]


func _ready() -> void:
	# Load level data
	load_level_data()
	
	# Automatically set mask from level data for story mode
	apply_level_mask()
	
	# Set background from level data
	apply_level_background()
	
	# Set journal texture from level data
	apply_level_journal()
	
	# Update UI to show current level from LevelManager
	current_level.text = str(LevelManager.current_level)
	distance.text = str(distance_value) + " m"
	
	# Initialize score display
	item_count = 0
	update_score_display()
	
	# Set background color from level data
	set_background_color()
	
	load_items_data()

	LevelManager.is_story = true

func apply_buff_multipliers() -> void:
	# Apply spawn rate multiplier (Paper Mask)
	spawn_speed = spawn_speed / LevelManager.spawn_rate_multiplier
	
	# Apply item limit multiplier (Normal Mask)
	item_limit = int(item_limit * LevelManager.jar_capacity_multiplier)
	
	print("Applied multipliers:")
	print("  Spawn speed: ", spawn_speed)
	print("  Item limit: ", item_limit)

func load_level_data():
	var file = FileAccess.open(level_data_path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			level_data = json.data
			print("Level data loaded successfully")

func apply_level_mask() -> void:
	# Get the level key based on LevelManager's current level
	var level_key = "Level_" + str(LevelManager.current_level)
	
	if level_key in level_data:
		var level_info = level_data[level_key]
		if "mask" in level_info:
			var mask_name = level_info["mask"]
			var opponent_mask_name = level_info.get("opponent_mask", "default")
			print("DEBUG: Found mask_name: ", mask_name, " and opponent_mask: ", opponent_mask_name)
			# Map mask names to full LevelManager mask names
			var full_mask_name = ""
			var predaturr_animation = opponent_mask_name
			
			match mask_name:
				"paper":
					full_mask_name = "default_paper_mask"
					print("DEBUG: Matched paper mask")
				"facial_masked":
					full_mask_name = "default_mask"
					print("DEBUG: Matched facial_masked mask")
				"wilson":
					full_mask_name = "default_wilson_mask"
					print("DEBUG: Matched wilson mask")
				_:
					print("ERROR: Unknown mask type: ", mask_name)
					return
			
			print("DEBUG: After match - full_mask_name=", full_mask_name, " predaturr_animation=", predaturr_animation)
			
			LevelManager.set_selected_mask(full_mask_name)
			print("Applied mask from level data: ", mask_name, " (", full_mask_name, ")")
			
			# Try to get Gatto and Predaturr from the current scene
			var gatto = get_parent().find_child("Gatto", true, false)
			var predaturr = get_parent().find_child("Predaturr", true, false)
			
			print("Gatto found: ", gatto != null, " at path: ", gatto.get_path() if gatto else "N/A")
			print("Predaturr found: ", predaturr != null, " at path: ", predaturr.get_path() if predaturr else "N/A")
			
			if gatto:
				gatto.play(full_mask_name)
				print("Updated Gatto animation to: ", full_mask_name)
			
			if predaturr:
				print("Predaturr BEFORE - Current animation: ", predaturr.animation)
				predaturr.animation = predaturr_animation
				predaturr.play()
				print("Predaturr AFTER - Current animation: ", predaturr.animation)
				print("Updated Predaturr animation to: ", predaturr_animation)
				# Also set it deferred in case gatto.gd resets it
				predaturr.call_deferred("set", "animation", predaturr_animation)
				predaturr.call_deferred("play")
		else:
			print("WARNING: No mask found in level data for ", level_key)
	else:
		print("ERROR: Level key not found in level_data")

func apply_level_background() -> void:
	# Get the level key based on LevelManager's current level
	var level_key = "Level_" + str(LevelManager.current_level)
	
	print("DEBUG: Applying background for ", level_key)
	print("DEBUG: has_node(Control/Background): ", has_node("Control/Background"))
	
	if level_key in level_data:
		var level_info = level_data[level_key]
		print("DEBUG: level_info keys: ", level_info.keys())
		if "background" in level_info:
			var background_uid = level_info["background"]
			print("DEBUG: Found background UID: ", background_uid)
			
			# Load the background texture
			var background_texture = load(background_uid)
			print("DEBUG: Loaded texture: ", background_texture)
			if background_texture:
				# Apply to Level1's Control/Background TextureRect
				if has_node("Level1/Control/Background"):
					var background_node = get_node("Level1/Control/Background")
					print("DEBUG: Background node type: ", background_node.get_class())
					background_node.texture = background_texture
					print("Applied background texture to Level1/Control/Background")
				else:
					print("ERROR: Level1/Control/Background node not found")
			else:
				print("ERROR: Failed to load background texture: ", background_uid)
		else:
			print("WARNING: No background found in level data for ", level_key)
	else:
		print("ERROR: Level key not found in level_data")

func apply_level_journal() -> void:
	# Get the level key based on LevelManager's current level
	var level_key = "Level_" + str(LevelManager.current_level)
	
	if level_key in level_data:
		var level_info = level_data[level_key]
		if "journal" in level_info:
			var journal_uid = level_info["journal"]
			print("DEBUG: Found journal UID: ", journal_uid)
			
			# Load the journal texture
			var journal_texture = load(journal_uid)
			if journal_texture:
				# Find the Surat node in Control
				if has_node("Control/Surat"):
					var surat_node = $Control/Surat
					surat_node.texture_normal = journal_texture
					print("Applied journal texture to Control/Surat")
				else:
					print("ERROR: Control/Surat node not found")
			else:
				print("ERROR: Failed to load journal texture: ", journal_uid)
		else:
			print("WARNING: No journal found in level data for ", level_key)
	else:
		print("ERROR: Level key not found in level_data")

func set_background_color():
	# Get the level key based on LevelManager's current level
	var level_key = "Level_" + str(LevelManager.current_level)
	print("Looking for level key: ", level_key)
	print("Level data keys: ", level_data.keys())
	print("Has ColorRect node: ", has_node("Control/ColorRect"))
	
	if level_key in level_data:
		var level_info = level_data[level_key]
		print("Found level info: ", level_info.keys())
		# Get a random color from the level's available colors
		var color_keys = []
		for key in level_info.keys():
			if key != "softlock" and key != "texture" and key != "texture_broken" and key != "mask" and key != "background":
				color_keys.append(key)
		
		print("Available color keys: ", color_keys)
		
		if color_keys.size() > 0 and has_node("Control/ColorRect"):
			var random_color_key = color_keys[rng.randi() % color_keys.size()]
			var color_hex = level_info[random_color_key]
			$Control/ColorRect.color = Color.html(color_hex)
			print("Background color set to ", random_color_key, " (", color_hex, ")")
		else:
			print("ERROR: No color keys found or ColorRect node missing")
	else:
		print("ERROR: Level key not found in level_data")

func update_score_display():
	if has_node("Control/Score"):
		var score_label = get_node("Control/Score")
		if score_index >= score_grades.size():
			score_index = score_grades.size() - 1
		score_label.text = "Score: " + score_grades[score_index]
	
	if has_node("Control/ItemCount"):
		var item_count_label = get_node("Control/ItemCount")
		item_count_label.text = "Items: " + str(item_count) + "/" + str(item_limit)

func record_item_placed():
	item_count += 1
	print("Item placed. Count: ", item_count, "/", item_limit)
	
	# Check if item exceeds limit
	if item_count > item_limit:
		var excess = item_count - item_limit
		# Decrease score by the number of excess items
		score_index = min(excess - 1, score_grades.size() - 1)
		print("Item limit exceeded! Score changed to: ", score_grades[score_index])
		
		# Check if game over (F grade)
		if score_index >= score_grades.size() - 1:
			print("GAME OVER - F Grade reached!")
			if has_node("../Control/GameOver"):
				get_node("../Control/GameOver").toggle_pause()
	
	update_score_display()

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
	var decrease_amount = base_distance_decrease_rate * delta * LevelManager.difficulty_scaling * LevelManager.chase_speed_multiplier
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
		
		# Calculate max items based on level
		# Level 1: 3, Level 2: 4, Level 3+: 5
		var max_items = min(2 + LevelManager.current_level, 5)
		
		# Spawn items until we reach the max
		if level_5_items.size() > 0 and current_item_count < max_items:
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
	
	# Spawn items near the bottom of the jar (right side)
	var position_x = int(rng.randf_range(880, 1020))
	var position_y = int(rng.randf_range(500, 550))
	button.position = Vector2(position_x, position_y)
	
	# Store item data on button
	button.set_meta("item_data", item_data.duplicate())
	
	# Load drag and drop script
	var script = load("res://Scripts/spawned_item.gd")
	button.set_script(script)
	
	# Add to scene
	control.add_child(button)
	
	# Calculate scale based on current level (increases with each level)
	var item_scale = 0.25 + (UserData.current_level * 0.06)
	
	# Animate pop-up
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(item_scale, item_scale), 0.2)

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

	# Collect all matching items
	var matching_items = []
	for item in items_data:
		var item_parts = item["path"].split("/")
		var item_parent = "/".join(item_parts.slice(0, -1))
		if item_parent == parent_path1:
			matching_items.append(item)
	
	# Return a random item from the matching items
	if matching_items.size() > 0:
		return matching_items[rng.randi() % matching_items.size()].duplicate()
	
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
	
	# Calculate scale based on current level (increases with each level)
	var item_scale = 0.25 + (UserData.current_level * 0.06)
	
	var tween = create_tween()
	tween.tween_property(texture_rect, "scale", Vector2(item_scale, item_scale), 0.2)

func attack_with_item(item_data: Dictionary):
	var damage = item_data.get("damage", 0)
	distance_value += (10 * damage / LevelManager.difficulty_scaling)
	distance.text = str(int(distance_value)) + " m"
	print("Attacked with ", item_data.get("name", "Item"), "! Damage: ", damage)

func stack_item_in_jar(item_data: Dictionary, spawn_position: Vector2):
	# Create physics body for item to fall into jar
	var item_texture = load(item_data.get("texture", ""))
	if item_texture:
		# Create a RigidBody2D for physics simulation
		var rigid_body = RigidBody2D.new()
		rigid_body.gravity_scale = 2.0
		rigid_body.linear_velocity = Vector2(0, 0)
		rigid_body.mass = 1.0
		rigid_body.physics_material_override = PhysicsMaterial.new()
		rigid_body.physics_material_override.friction = 0.5
		rigid_body.physics_material_override.bounce = 0.1
		
		# Store item data on the rigid body so we can access it when it enters the jar
		rigid_body.set_meta("item_data", item_data.duplicate())
		
		# Add texture rect for visual
		var texture_rect = TextureRect.new()
		texture_rect.texture = item_texture
		
		# Calculate scale based on current level
		var item_scale = 0.25 + (UserData.current_level * 0.06)
		texture_rect.scale = Vector2(item_scale, item_scale)
		
		texture_rect.custom_minimum_size = Vector2(50, 50)
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.anchor_left = 0.5
		texture_rect.anchor_top = 0.5
		rigid_body.add_child(texture_rect)
		
		# Add collision shape - smaller and more stable
		var collision_shape = CollisionShape2D.new()
		var box_shape = RectangleShape2D.new()
		box_shape.size = Vector2(40, 40)
		collision_shape.shape = box_shape
		collision_shape.position = Vector2(0, 0)
		rigid_body.add_child(collision_shape)
		
		# Set position and add to scene
		rigid_body.global_position = spawn_position
		rigid_body.add_to_group("falling_items")
		add_child(rigid_body)
		
		# Set up a timer to check if item reached jar and clean up
		var timer = Timer.new()
		timer.wait_time = 3.0
		timer.one_shot = true
		timer.timeout.connect(func(): 
			if is_instance_valid(rigid_body):
				rigid_body.queue_free()
		)
		timer.start()
		add_child(timer)

func reset_items():
	# Clear all items and cracks
	for child in control.get_children():
		if child.has_meta("item_data") or child.is_in_group("cracks"):
			child.queue_free()
	
	# Reset score and item count for new level
	item_count = 0
	score_index = 0
	update_score_display()
	
	# Reset timers
	time_elapsed = 0.0
	crack_spawn_timer = 0.0
	
	# Reset distance value
	distance_value = int(5000 / LevelManager.difficulty_scaling)
	distance.text = str(distance_value) + " m"
	
	print("Items reset for new level")

func spawn_crack():
	# Create a TextureRect for the crack
	var crack = TextureRect.new()
	# Randomly choose between the two crack textures
	var crack_textures = ["uid://f61o7cgk3v2b", "uid://rqcelx0drqag"]
	crack.texture = load(crack_textures[rng.randi() % crack_textures.size()])
	crack.scale = Vector2(0.8, 0.8)
	crack.custom_minimum_size = Vector2(100, 100)
	crack.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Spawn cracks in a rectangular area at the top of the screen
	var position_x = int(rng.randf_range(50, 1030))  # Across the width
	var position_y = int(rng.randf_range(20, 150))   # Top part of screen
	
	crack.position = Vector2(position_x, position_y)
	
	print("Spawning crack at position: ", crack.position)
	
	# Add crack script
	var script = load("res://Scripts/crack.gd")
	crack.set_script(script)
	
	# Add to group for tracking
	crack.add_to_group("cracks")
	
	# Add to scene root, not to control (so it appears behind items)
	add_child(crack)


func _on_surat_trigger_pressed() -> void:
	$Control/Surat.visible = true
	$Control/SuratTrigger.visible = false

func _on_surat_pressed() -> void:
	$Control/Surat.visible = false
