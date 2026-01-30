extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func show_monodialog(duration, speaker, sprite, text = "", options = {}, voice = null, reappearance = true):
	visible = true
	$Control/Panel/Options.visible = false
	$Control/Panel/TextureRect.texture = sprite
	$Control/Panel/CharacterName.text = speaker
	$Control/Panel/Text.text = text
	$Control/Panel/CharacterName.visible_characters = 0
	$Control/Panel/Text.visible_characters = 0
	if voice: $CharacterVoice.stream = voice
	
	for option in $Control/Panel/Options.get_children():
		$Control/Panel/Options.remove_child(option)
	
	for option in options.keys():
		var button = Button.new()
		button.text = option
		button.add_theme_font_override("font", load("res://Assets/Fonts/Fusion Pixel 10px Monospaced/fusion-pixel-10px-monospaced-zh_hans.otf"))
		button.add_theme_font_size_override("font_size", 10)
		button.pressed.connect(_on_option_selected.bind(option))
		$Control/Panel/Options.add_child(button)
	
	Constants.player["can_move"] = false
	if reappearance:
		$Control/Panel.size = Vector2(50, 48)
		var tween := create_tween()
		tween.tween_property($Control/Panel, "size", Vector2(196, 48), duration)
		tween.tween_property($Control/Panel/CharacterName, "visible_characters", $Control/Panel/CharacterName.get_total_character_count(), duration)
		await tween.finished
		var tween2 := create_tween()
		$CharacterVoice.play()
		tween2.tween_property($Control/Panel/Text, "visible_characters", $Control/Panel/Text.get_total_character_count(), duration*2)
		await tween2.finished
		$CharacterVoice.stop()
		$Control/Panel/Options.visible = true
	else:
		#$Control/Panel/CharacterName.visible_characters = $Control/Panel/CharacterName.get_total_character_count()
		#$Control/Panel/Text.visible_characters = $Control/Panel/Text.get_total_character_count()
		$Control/Panel/CharacterName.visible_characters = -1
		var tween := create_tween()
		$CharacterVoice.play()
		tween.tween_property($Control/Panel/Text, "visible_characters", $Control/Panel/Text.get_total_character_count(), duration*2)
		await tween.finished
		$CharacterVoice.stop()
		$Control/Panel/Options.visible = true
	

func hide_monodialog(duration):
	$Timer.wait_time = duration
	var tween := create_tween()
	tween.tween_property($Control/Panel, "size", Vector2(50, 48), duration)
	$Control/Panel/CharacterName.visible_characters = 0
	$Control/Panel/Text.visible_characters = 0
	$Control/Panel/Options.visible = false
	$Timer.start()
	await tween.finished
	Constants.player["can_move"] = true

func show_ending(which):
	if which == 1:
		FadeToBlack_Transition.fade_to_scene("uid://cnryahagj78dg", 5)
	elif which == 2:
		FadeToBlack_Transition.fade_to_scene("uid://ks5x6ke72iuu", 5)

#func _on_texture_button_pressed() -> void:
	#hide_monodialog(hide_duration)

func _on_timer_timeout() -> void:
	visible = false

#func _on_button_pressed() -> void:
	#hide_monodialog(hide_duration)

func _on_option_selected(option) -> void:
	get_parent().handle_monodialog_choices(option)
