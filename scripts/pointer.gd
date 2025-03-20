extends AnimatedSprite2D

var mousePos

func _process(delta: float) -> void:
	mousePos = get_global_mouse_position()
	position = mousePos
