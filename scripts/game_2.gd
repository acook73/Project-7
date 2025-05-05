extends Node2D



func _physics_process(delta: float) -> void:
	$Player/Camera2D2/TextureProgressBar.max_value = $Player.hp_max
	$Player/Camera2D2/TextureProgressBar.value = $Player.hp

func _on_teleport_barrier_body_entered(body: Node2D) -> void:
	body.set_position(body.lastSafePos)
	body.hp -= 10
