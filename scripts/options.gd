#options menu (not currently functional)
extends Node2D

@onready var start: Button = $Button
@onready var drop_down_menu = $OptionButton

func _ready() -> void:
	make_list()

func make_list():
	drop_down_menu.add_item("1080x1920")
	drop_down_menu.add_item("1440x2560")
	drop_down_menu.add_item("1600x2560")
	drop_down_menu.add_item("1440x3440")
	drop_down_menu.add_item("2160x3840")


	


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
