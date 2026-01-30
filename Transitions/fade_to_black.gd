extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect

func _ready():
	fade_rect.modulate.a = 0.0
	fade_rect.visible = true

func fade_to_scene(scene_path: String, duration := 0.5):
	fade_rect.modulate.a = 0.0
	fade_rect.visible = true

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished

	get_tree().change_scene_to_file(scene_path)

	var tween_in := create_tween()
	tween_in.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween_in.finished

	fade_rect.visible = false
