#checkpoint, saves player progress, stats, pickups, and hats.
extends Node2D
var player

#loads player stats into a dictionary for storage
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

#unlights campfire if not the active checkpoint
func _physics_process(_delta: float) -> void:
	if (player != null and player.checkpoint != self.name):
		$AnimatedSprite2D.play("default")

#saves player information to file, lights fire, deletes permanent upgrades picked up by player by clearing reset
func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	body.checkpoint = self.name
	$AnimatedSprite2D.play("lit")
	body.reset.clear()
	#there are 2 save files, "save_file" hold player stats and position data, "hat_file" saves hats collected
	#they're in different files since "hat_file" is persistent between games
	var save_file = FileAccess.open("res://savegame.save", FileAccess.WRITE)
	var hat_file = FileAccess.open("res://hats.save", FileAccess.WRITE)
	#creates a dictionary with the hats collected
	var save_dict = {
		"hats": body.hats
	}
	#converts to JSON and saves to the file
	var json_string2 = JSON.stringify(save_dict)
	hat_file.store_line(json_string2)
	
	#stores player stats in savegame.save which is also in JSON format
	var node_data = save(body)
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
