extends Node2D
@onready var start: Button = $Button
@onready var options: Button = $Button1
@onready var quit: Button = $Button2
@onready var cont: Button = $Button3



func _ready() -> void:
	if not FileAccess.file_exists("res://savegame.save"):
		cont.disabled = true
		

func _on_button_pressed() -> void:
	var save_file = FileAccess.open("res://loadFlag.save", FileAccess.WRITE)
	var node_data = "0"
	save_file.store_line(node_data)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	



func _on_button_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
	



func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_button_3_pressed() -> void:
	var save_file = FileAccess.open("res://loadFlag.save", FileAccess.WRITE)
	var node_data = "1"
	save_file.store_line(node_data)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
