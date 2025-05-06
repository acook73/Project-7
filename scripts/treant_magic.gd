extends CharacterBody2D


var player = null
var first = true
@export var velocityY = -500
@export var attackPower = 25
@export var knockback = 250

#func _ready():
	
func _physics_process(delta: float) -> void:
	if player != null and first:
		velocity.x = (position.x-player.position.x)*-2
		velocity.y = (position.y-player.position.y)*-2
		first = false
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		body.hp -= attackPower
		body.knockback = knockback
		body.knockbackDir = -1
	$GPUParticlesExplode.emitting = true
	$Sprite2D.visible = false
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$Area2D2/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(0.3).timeout
	queue_free()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		player = body
