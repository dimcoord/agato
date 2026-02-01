extends ColorRect

var gatto: AnimatedSprite2D
var selected_mask: String = ""
var mask_buttons: Array = []
var mask_info: Dictionary = {
	"default": {
		"name": "Normal",
		"description": "The unmasked Gatto. Increases jar capacity"
	},
	"default_mask": {
		"name": "Facial Mask",
		"description": "Clowny ahh. Decreases chase speed"
	},
	"default_paper_mask": {
		"name": "Paper Mask",
		"description": "Gatto's orphanage registration letter. Increases item spawn rate"
	},
	"default_wilson_mask": {
		"name": "Wilson Mask",
		"description": "WILSON! Lo siento. Increases weight per item"
	}
}

func _ready() -> void:
	# Set this panel to always process even when tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Find the Gatto node
	gatto = get_node("/root/Main/Gatto")
	
	# Get the mask buttons container and create buttons dynamically
	var buttons_container = $PanelContent/MaskButtonsContainer
	var confirm_button = $PanelContent/ConfirmButton
	var description_label = $PanelContent/MaskDescription
	
	# Clear any existing buttons
	for child in buttons_container.get_children():
		child.queue_free()
	
	var animations = gatto.sprite_frames.get_animation_names()
	
	# Create buttons for each animation
	for anim_name in animations:
		var button = Button.new()
		var info = mask_info.get(anim_name, {"name": anim_name, "description": ""})
		button.text = info["name"].to_upper()
		button.custom_minimum_size = Vector2(200, 60)
		button.process_mode = Node.PROCESS_MODE_ALWAYS
		button.toggled.connect(_on_mask_button_toggled.bind(anim_name, description_label, confirm_button))
		button.toggle_mode = true
		buttons_container.add_child(button)
		mask_buttons.append(button)
	
	# Connect confirm button
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Mouse filter to block clicks from going through
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_mask_button_toggled(is_pressed: bool, mask_name: String, description_label: Label, confirm_button: Button) -> void:
	if is_pressed:
		# Deselect other buttons
		for button in mask_buttons:
			var button_mask_name = ""
			for key in mask_info.keys():
				if mask_info[key]["name"].to_upper() == button.text:
					button_mask_name = key
					break
			if button_mask_name != mask_name:
				button.set_pressed_no_signal(false)
		
		selected_mask = mask_name
		gatto.animation = mask_name
		
		# Update description
		var info = mask_info.get(mask_name, {})
		description_label.text = info.get("name", mask_name) + ": " + info.get("description", "")
		
		# Enable confirm button
		confirm_button.disabled = false

func _on_confirm_pressed() -> void:
	if selected_mask == "":
		return
	
	# Apply buffs to LevelManager
	LevelManager.set_selected_mask(selected_mask)
	
	# Get the main node and apply multipliers
	var main = get_node("/root/Main")
	main.apply_buff_multipliers()
	
	# Hide the panel and allow game to start
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Unpause the game tree
	get_tree().paused = false
