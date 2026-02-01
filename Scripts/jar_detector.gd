extends Area2D

var parent_main = null
var processed_items = []  # Track items we've already counted

func _ready():
	parent_main = get_parent().get_parent().get_parent()  # Control -> Jar -> JarDetector
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Check if the body is a falling item (RigidBody2D with item_data)
	if body is RigidBody2D and body.has_meta("item_data") and body in get_tree().get_nodes_in_group("falling_items"):
		# Avoid processing the same item twice
		if body.get_instance_id() not in processed_items:
			processed_items.append(body.get_instance_id())
			
			var item_data = body.get_meta("item_data")
			var weight = item_data.get("damage", 0)
			
			# Apply weight multiplier from selected mask (Wilson Mask)
			weight = int(weight * LevelManager.weight_per_item_multiplier)
			
			if parent_main.has_node("Control/FloorHP"):
				var weight_bar = parent_main.get_node("Control/FloorHP")
				weight_bar.value += weight
				print("Item entered jar: ", item_data.get("name", "Item"), " with weight: ", weight, " (Total Weight: ", weight_bar.value, ")")
			
			# Record the item for score tracking
			if parent_main and parent_main.has_method("record_item_placed"):
				parent_main.record_item_placed()
