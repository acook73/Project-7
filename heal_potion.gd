extends Node2D



func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp = body.hp_max
	queue_free()
