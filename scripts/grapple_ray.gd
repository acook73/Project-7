extends RayCast2D

func _ready(): # Make sure that the grapple ray cannot collide with the player
	add_exception(get_parent().get_parent())
