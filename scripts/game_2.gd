#main level
extends Node2D


#handles health bar and resets the boss to full health if player dies
func _physics_process(_delta: float) -> void:
	$Player/Camera2D2/TextureProgressBar.max_value = $Player.hp_max
	$Player/Camera2D2/TextureProgressBar.value = $Player.hp
	if ($Player.hp <= 0):
		$Enemies/Treant.hp = 4000

#in case player manages to fall off the map
func _on_teleport_barrier_body_entered(body: Node2D) -> void:
	body.set_position(body.lastSafePos)
	body.hp -= 10
