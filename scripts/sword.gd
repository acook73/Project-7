#sword pickup, increases player attack
extends Node2D

#allows pickup to be restored if player returns to checkpoint
@onready var anim = $AnimatedSprite2D
@onready var coll = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")

#same as shield, jump, dash
func _on_area_2d_body_entered(body: Node2D) -> void:
	body.attackPower += 10
	body.permaUpgrades.append(self.name)
	body.reset.append(self.name)
	$AnimatedSprite2D.visible = false
	$Area2D/CollisionShape2D.set_deferred("disabled", true) 
