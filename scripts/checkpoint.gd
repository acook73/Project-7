extends Node2D
var player
func save(body: Node2D):
	var save_dict = {
		"filename" : body.get_parent().get_scene_file_path(),
		"parent" : body.get_parent().get_path(),
		"pos_x" : body.position.x, # Vector2 is not supported by JSON
		"pos_y" : body.position.y,
		"hp" : body.hp,
		"hp_max" : body.hp_max,
		"rem" : body.permaUpgrades,
		"maxJumps": body.maxJumps,
		"maxDash": body.maxDash,
		"selectedHat": body.selectedHat
	}
	return save_dict

func _physics_process(delta: float) -> void:
	if (player != null and player.checkpoint != self.name):
		$AnimatedSprite2D.play("default")

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	body.checkpoint = self.name
	$AnimatedSprite2D.play("lit")
	body.reset.clear()
	var save_file = FileAccess.open("res://savegame.save", FileAccess.WRITE)
	var hat_file = FileAccess.open("res://hats.save", FileAccess.WRITE)
	var save_dict = {
		"hats": body.hats
	}
	var json_string2 = JSON.stringify(save_dict)
	hat_file.store_line(json_string2)
	var node_data = save(body)
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
