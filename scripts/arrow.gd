extends CharacterBody2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var Part: GPUParticles2D = $GPUParticles2D
@onready var Part2: GPUParticles2D = $GPUParticlesExplode
var SPEED = 200
var player = null
var direction = 0
func _physics_process(delta: float) -> void:
	#enables arrow trail
	position.x += SPEED*delta*direction
	if (direction == -1):
		sprite.flip_h = false
		Part.position.x = 8
	else:
		sprite.flip_h = true
		Part.position.x = -8
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	remove_child(sprite)
	direction = 0
	$GPUParticles2D.emitting = false
	Part2.emitting = true
	await get_tree().create_timer(0.95).timeout
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	remove_child(sprite)
	$GPUParticles2D.emitting = false
	Part2.emitting = true
	direction = 0
	await get_tree().create_timer(0.95).timeout
	queue_free()
