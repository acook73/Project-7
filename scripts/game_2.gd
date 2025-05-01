extends Node2D





func _on_teleport_barrier_body_entered(body: Node2D) -> void:
	body.set_position(body.lastSafePos)
	body.hp -= 10
