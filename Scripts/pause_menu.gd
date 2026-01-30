extends CanvasLayer

var in_settings: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	get_tree().paused = false
	$Settings/MasterVol/Value.text = str(int(UserSettings.master_volume * 10))
	$Settings/MusicVol/Value.text = str(int(UserSettings.music_volume * 10))

func toggle_pause() -> void:
	if in_settings:
		$Settings.visible = false
		$ColorRect/Main.visible = true
	visible = not visible
	get_tree().paused = not get_tree().paused

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		if $Button.visible:
			$Button.visible = false

func _on_button_pressed() -> void:
	$SFX_Click.play()
	toggle_pause()
	$Button.visible = false

func _on_button_2_pressed() -> void:
	$SFX_Click.play()
	toggle_pause()
	#$Button.visible = true

func _on_button_mouse_entered() -> void:
	PauseGameController.is_in_pause_box = true

func _on_button_mouse_exited() -> void:
	PauseGameController.is_in_pause_box = false

func _on_button_4_pressed() -> void:
	$SFX_Click.play()
	FadeToBlack_Transition.fade_to_scene("res://Scenes/main_menu.tscn", 4)


func _on_button_3_pressed() -> void:
	$SFX_Click.play()
	$Settings.visible = true
	$ColorRect/Main.visible = false

func _on_dec_pressed() -> void:
	$SFX_Click.play()
	if UserSettings.master_volume > 0:
		UserSettings.master_volume -= 0.1
		$Settings/MasterVol/Value.text = str(int(UserSettings.master_volume * 10))
		UserSettings.apply_settings()

func _on_inc_pressed() -> void:
	$SFX_Click.play()
	if UserSettings.master_volume < 1.0:
		UserSettings.master_volume += 0.1
		$Settings/MasterVol/Value.text = str(int(UserSettings.master_volume * 10))
		UserSettings.apply_settings()

func _on_dec_2_pressed() -> void:
	$SFX_Click.play()
	if UserSettings.music_volume > 0:
		UserSettings.music_volume -= 0.1
		$Settings/MusicVol/Value.text = str(int(UserSettings.music_volume * 10))
		UserSettings.apply_settings()

func _on_inc_2_pressed() -> void:
	$SFX_Click.play()
	if UserSettings.music_volume < 1.0:
		UserSettings.music_volume += 0.1
		$Settings/MusicVol/Value.text = str(int(UserSettings.music_volume * 10))
		UserSettings.apply_settings()

func _on_button_5_pressed() -> void:
	$SFX_Click.play()
	$Settings.visible = false
	$ColorRect/Main.visible = true
	UserSettings.save_settings()
