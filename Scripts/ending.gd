extends Node2D

var is_next = 0

func _on_button_pressed() -> void:
	if is_next == 0:
		$Control/TextureRect.texture = load("uid://bqjtghys6wg5f")
		is_next += 1
	else:
		FadeToBlack.fade_to_scene("uid://cl28j0x4iq6s6", 2)


func _on_timer_timeout() -> void:
	$Control/Button.visible = true
