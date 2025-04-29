extends Node2D


func save(body: Node2D):
	var save_dict = {
		"filename" : body.get_parent().get_scene_file_path(),
		"parent" : body.get_parent().get_path(),
		"pos_x" : body.position.x, # Vector2 is not supported by JSON
		"pos_y" : body.position.y,
		"hp" : body.hp,
		"hp_max" : body.hp_max,
		"rem" : body.permaUpgrades
	}
	return save_dict


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.reset.clear()
	var save_file = FileAccess.open("res://savegame.save", FileAccess.WRITE)
	var node_data = save(body)
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
