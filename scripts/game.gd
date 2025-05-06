#tutorial level
extends Node2D

#health bar management
func _physics_process(_delta: float) -> void:
	$Player/Camera2D2/TextureProgressBar.max_value = $Player.hp_max
	$Player/Camera2D2/TextureProgressBar.value = $Player.hp

#teleports the player to their last safe position if they fall
func _on_area_2d_body_entered(body: Node2D) -> void:
	body.set_position(body.lastSafePos)
