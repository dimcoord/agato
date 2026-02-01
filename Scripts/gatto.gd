extends AnimatedSprite2D

func _ready() -> void:
	# Don't auto-play - let apply_level_mask() set the animation
	# The animation will be set by story.gd's apply_level_mask() function
	pass
