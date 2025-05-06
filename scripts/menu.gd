#menu screen
extends Node2D
@onready var start: Button = $Button
@onready var options: Button = $Button1
@onready var quit: Button = $Button2
@onready var cont: Button = $Button3


#disables continue button if savegame not found
func _ready() -> void:
	if not FileAccess.file_exists("res://savegame.save"):
		cont.disabled = true
		
#starts new game by setting loadFlag.save to 0, causing the player to not load the state on _ready
func _on_button_pressed() -> void:
	var save_file = FileAccess.open("res://loadFlag.save", FileAccess.WRITE)
	var node_data = "0"
	save_file.store_line(node_data)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	


#opens options menu
func _on_button_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
	


#quits game
func _on_button_2_pressed() -> void:
	get_tree().quit()

#loads level from save file and sets loadFlag to 1 in order to make the player load the save data on _ready
func _on_button_3_pressed() -> void:
	var save_file = FileAccess.open("res://loadFlag.save", FileAccess.WRITE)
	var node_data = "1"
	save_file.store_line(node_data)
	var save_file2 = FileAccess.open("res://savegame.save", FileAccess.READ)
	while save_file2.get_position() < save_file2.get_length():
		
		var json_string = save_file2.get_line()
		var json = JSON.new()
		var _parse_result = json.parse(json_string)
		var node_data2 = json.data
		for i in node_data2.keys():
			if i == "filename":
				#print(node_data2[i])
				get_tree().change_scene_to_file(node_data2[i])
	
