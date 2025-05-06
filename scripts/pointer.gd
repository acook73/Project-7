extends AnimatedSprite2D

var mousePos

func _process(_delta: float) -> void:
	mousePos = get_global_mouse_position()
	position = mousePos
