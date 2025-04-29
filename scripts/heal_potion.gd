extends Node2D
@onready var Area2 = $Area2D/CollisionShape2D


func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp = body.hp_max
	$Area2D/CollisionShape2D.set_deferred("disabled", true) 
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(60).timeout
	$Area2D/CollisionShape2D.set_deferred("disabled", false) 
	$AnimatedSprite2D.visible = true
