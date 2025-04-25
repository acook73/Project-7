extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")





func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp_max += 25
	body.hp += 25
	queue_free()
	
