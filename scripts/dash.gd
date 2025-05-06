#dash pickup, gives the player 1 additional dash charge
extends Node2D

#allows pickup to be restored if player returns to checkpoint
@onready var anim = $AnimatedSprite2D
@onready var coll = $Area2D/CollisionShape2D

#plays idle animation
func _ready() -> void:
	$AnimatedSprite2D.play("idle")




#gives player 1 more dash and then disables itself
func _on_area_2d_body_entered(body: Node2D) -> void:
	
	body.maxDash += 1
	body.uDash = true
	body.permaUpgrades.append(self.name)
	body.reset.append(self.name)
	$AnimatedSprite2D.visible = false
	$Area2D/CollisionShape2D.set_deferred("disabled", true) 
	
