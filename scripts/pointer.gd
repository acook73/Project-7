extends AnimatedSprite2D

var mousePos

# Create a pointer that follows the mouse
func _process(_delta: float) -> void:
	mousePos = get_global_mouse_position()
	position = mousePos
