extends TextureRect

var dragging = false
var drag_offset = Vector2.ZERO
var parent_main = null
var can_drag = true
var drag_cooldown = 0.0

func _ready():
	gui_input.connect(_on_gui_input)
	parent_main = get_parent().get_parent()
	# Don't block mouse events by default - let drops pass through to Attack node
	mouse_filter = Control.MOUSE_FILTER_PASS
	# Add to group for instance ID lookups
	add_to_group("spawned_items")

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and can_drag:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
			# Set to IGNORE so items underneath can receive drop events
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			# Show attack prompt
			parent_main.get_node("Control/AttackPrompt").visible = true
		elif dragging:
			dragging = false
			can_drag = false
			drag_cooldown = 0.2  # 200ms cooldown before allowing drag again
			# Return to PASS so this item can receive future drag starts
			mouse_filter = Control.MOUSE_FILTER_PASS
			modulate = Color.WHITE  # Restore normal color when done dragging
			# Hide attack prompt
			parent_main.get_node("Control/AttackPrompt").visible = false
			# Item stays at current position

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
		modulate = Color.WHITE * 0.8  # Slightly dim while dragging
		
		# Check for 'e' key to place item
		if Input.is_action_just_pressed("ui_focus_next"):  # 'e' key
			dragging = false
			can_drag = false
			drag_cooldown = 0.2
			mouse_filter = Control.MOUSE_FILTER_PASS
			modulate = Color.WHITE
			parent_main.get_node("Control/AttackPrompt").visible = false
		# Check for spacebar to attack with item
		elif Input.is_action_just_pressed("ui_accept"):  # spacebar
			if has_meta("item_data"):
				var item_data = get_meta("item_data")
				print("Attacking with held item: ", item_data.get("name", "Item"))
				if parent_main and parent_main.has_method("attack_with_item"):
					parent_main.attack_with_item(item_data)
				# Hide attack prompt
				parent_main.get_node("Control/AttackPrompt").visible = false
				queue_free()
	# When not dragging, keep the current position (don't revert)
	
	# Handle drag cooldown
	if not can_drag:
		drag_cooldown -= delta
		if drag_cooldown <= 0:
			can_drag = true

func _get_drag_data(at_position: Vector2):
	if has_meta("item_data"):
		var item_data = get_meta("item_data")
		
		# Create a label preview showing the item name
		var preview = Label.new()
		preview.text = item_data.get("name", "Item")
		preview.anchor_left = 1.0
		preview.anchor_top = 1.0
		preview.anchor_right = 1.0
		preview.anchor_bottom = 1.0
		preview.offset_left = -10
		preview.offset_top = -20
		preview.add_theme_font_size_override("font_size", 14)
		set_drag_preview(preview)
		
		# Include reference to the source node using instance ID (more reliable than node reference)
		var drag_data = item_data.duplicate()
		drag_data["source_instance_id"] = get_instance_id()
		return drag_data
	return null

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Must have item data to accept drops
	if not has_meta("item_data"):
		return false
	
	# Must be dropping from another item
	if not (data is Dictionary and "source_instance_id" in data):
		return false
	
	var source_id = data["source_instance_id"]
	var my_id = get_instance_id()
	
	# Source must not be self
	if source_id == my_id:
		return false
	
	# Both must be from the same level
	var this_path = get_meta("item_data").get("path", "")
	var this_parts = this_path.split("/")
	var this_parent = "/".join(this_parts.slice(0, -1))
	
	# Get source node from tree to verify it still exists and get its path
	var source = get_tree().get_nodes_in_group("spawned_items").filter(func(node): return node.get_instance_id() == source_id)
	
	if source.is_empty():
		return false
	
	source = source[0]
	var source_path = source.get_meta("item_data").get("path", "")
	var source_parts = source_path.split("/")
	var source_parent = "/".join(source_parts.slice(0, -1))
	
	var result = this_parent == source_parent
	return result

func _drop_data(at_position: Vector2, data: Variant) -> void:
	# Only handle drops from other spawned items (crafting)
	if data is Dictionary and "source_instance_id" in data:
		var source_id = data["source_instance_id"]
		
		# Don't mix item with itself
		if source_id == get_instance_id():
			return
		
		# Find the source node by instance ID
		var source_nodes = get_tree().get_nodes_in_group("spawned_items").filter(func(node): return node.get_instance_id() == source_id)
		if source_nodes.is_empty():
			return
		
		var source = source_nodes[0]
		# Only craft if source is another spawned item
		if source is TextureRect and source.has_meta("item_data"):
			if has_meta("item_data"):
				var dropped_item = data
				var this_item = get_meta("item_data")
				
				# Check if items are from the same level
				var this_path = this_item.get("path", "")
				var dropped_path = dropped_item.get("path", "")
				
				var this_parts = this_path.split("/")
				var dropped_parts = dropped_path.split("/")
				
				# Get parent level paths (all parts except the last item name)
				var this_parent = "/".join(this_parts.slice(0, -1))
				var dropped_parent = "/".join(dropped_parts.slice(0, -1))
				
				# Only allow crafting if items are from the same level
				if this_parent != dropped_parent:
					print("Cannot craft: items are from different levels!")
					print("Item 1 level: ", this_parent)
					print("Item 2 level: ", dropped_parent)
					return
				
				if parent_main and parent_main.has_method("craft_and_spawn"):
					print("Crafting: ", this_item.get("name", "Item"), " + ", dropped_item.get("name", "Item"))
					# Hide attack prompt before crafting
					parent_main.get_node("Control/AttackPrompt").visible = false
					parent_main.craft_and_spawn(this_item, dropped_item, global_position)
					queue_free()
					
					# Remove the dragged item
					if is_instance_valid(source):
						source.queue_free()
