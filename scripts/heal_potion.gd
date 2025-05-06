#pickup that restores player to full health
extends Node2D
@onready var Area2 = $Area2D/CollisionShape2D


func _ready() -> void:
	$AnimatedSprite2D.play("idle")

#disables itself and sets player to their max hp, respawns after 60 seconds
func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp = body.hp_max
	$Area2D/CollisionShape2D.set_deferred("disabled", true) 
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(60).timeout
	$Area2D/CollisionShape2D.set_deferred("disabled", false) 
	$AnimatedSprite2D.visible = true
