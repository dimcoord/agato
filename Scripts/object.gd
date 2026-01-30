extends Sprite2D
var drag = false
var of = Vector2(0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if drag:
		position = get_global_mouse_position() - of


func _on_button_button_down() -> void:
	drag = true
	of = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
	drag = false 
