#barrier that changes level to the file specified
extends Node2D

#filename filled in for each local instance
@export var filename = "temp"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		var save_file = FileAccess.open("res://loadFlag.save", FileAccess.WRITE)
		var node_data = "0"
		save_file.store_line(node_data)
		get_tree().change_scene_to_file(filename)
