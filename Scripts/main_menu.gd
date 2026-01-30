extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	AudioFade.fade_in($BGM, 2)
	get_tree().paused = false
	$Settings/MasterVol/Value.text = str(int(UserSettings.master_volume * 10))
	$Settings/MusicVol/Value.text = str(int(UserSettings.music_volume * 10))

func _on_button_2_pressed() -> void:
	$Start_SFX_Click.play()
	AudioFade.fade_out($BGM, 4)
	#FadeToBlack_Transition.fade_to_scene("uid://bnbxspvlgp2tj", 4)

func _on_button_3_pressed() -> void:
	$SFX_Click.play()
	$Settings.visible = true
	$Main.visible = false

func _on_button_4_pressed() -> void:
	get_tree().quit()

func _on_button_5_pressed() -> void:
	$SFX_Click.play()
	$Settings.visible = false
	$Main.visible = true
	UserSettings.save_settings()

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


func _on_button_1_pressed() -> void:
	pass # Replace with function body.
