extends TextureRect

var parent_main = null

func _ready():
	parent_main = get_parent().get_parent()
	# Allow this node to receive mouse/drag events
	mouse_filter = Control.MOUSE_FILTER_STOP

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Accept any dictionary data that has "name" field (items)
	return data is Dictionary and "name" in data

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and "damage" in data:
		var item_name = data.get("name", "Item")
		var damage = data.get("damage", 0)
		
		print("Item dropped on Attack node: ", item_name, " with damage: ", damage)
		
		if parent_main and parent_main.has_method("attack_with_item"):
			parent_main.attack_with_item(data)
			
			# Remove the source item that was dragged
			if "source_node" in data and data["source_node"] and is_instance_valid(data["source_node"]):
				data["source_node"].queue_free()
