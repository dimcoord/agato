extends TextureRect

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Accept drops from spawned items
	return data is Dictionary and "source_instance_id" in data

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("Hi")
	
	# Find and remove the source item by instance ID
	var source_id = data["source_instance_id"]
	var source_nodes = get_tree().get_nodes_in_group("spawned_items").filter(func(node): return node.get_instance_id() == source_id)
	
	if not source_nodes.is_empty():
		var source_node = source_nodes[0]
		# Get the damage from the item data
		var item_data = source_node.get_meta("item_data")
		var damage = item_data.get("damage", 0)
		
		# Decrease FloorHP by the damage amount
		if has_node("../Control/FloorHP"):
			get_node("../Control/FloorHP").value -= damage
		
		source_node.queue_free()
	
	# Hide the AttackPrompt
	var main = get_parent()
	if main.has_node("Control/AttackPrompt"):
		main.get_node("Control/AttackPrompt").visible = false
	
	# Remove the crack itself
	queue_free()
