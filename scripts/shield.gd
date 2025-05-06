#shield pickup, increases player max hp
extends Node2D

#allows pickup to be restored if player returns to checkpoint
@onready var anim = $AnimatedSprite2D
@onready var coll = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")





func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp_max += 50
	body.hp += 50
	
	#saves to player that this upgrade was picked up
	body.permaUpgrades.append(self.name)
	body.reset.append(self.name)
	$AnimatedSprite2D.visible = false
	$Area2D/CollisionShape2D.set_deferred("disabled", true) 
	
