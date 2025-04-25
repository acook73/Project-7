extends RayCast2D

func _ready():
	add_exception(get_parent().get_parent())
