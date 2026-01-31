extends CanvasLayer

var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	get_tree().paused = false

func toggle_pause() -> void:
	visible = not visible
	get_tree().paused = not get_tree().paused

func _on_button_2_pressed() -> void:
	get_tree().reload_current_scene()

func _on_button_4_pressed() -> void:
	FadeToBlack.fade_to_scene("uid://cl28j0x4iq6s6", 2)


func _on_button_3_pressed() -> void:
	$SFX_Click.play()
	$Settings.visible = true
	$ColorRect/Main.visible = false
