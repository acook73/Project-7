extends Node2D
@onready var start: Button = $Button
@onready var options: Button = $Button1
@onready var quit: Button = $Button2





func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	



func _on_button_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
	



func _on_button_2_pressed() -> void:
	get_tree().quit()
