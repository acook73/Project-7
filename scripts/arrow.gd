#arrow shot by skeletons, flies left or right in a straight line towards the player
extends CharacterBody2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var Part: GPUParticles2D = $GPUParticles2D
@onready var Part2: GPUParticles2D = $GPUParticlesExplode
@export var SPEED = 200
@export var knockback = 200
@export var attackPower = 15
var player = null
var direction = 0


#counts down until arrow despawns in case it never hits anything
func _ready() -> void:
	$Lifetime.start()


func _physics_process(delta: float) -> void:
	#if it has been alive for the length of its lifetime timer, the arrow deletes itself
	if ($Lifetime.is_stopped()):
		queue_free()
	
	#gives the arrow and the arrow trail the correct orientation relative to the player
	if (direction == -1):
		sprite.flip_h = false
		Part.position.x = 8
	else:
		sprite.flip_h = true
		Part.position.x = -8
	
	#moves arrow 
	position.x += SPEED*delta*direction
	move_and_slide()

#handles player collision
func _on_area_2d_body_entered(body: Node2D) -> void:
	var temp = body
	remove_child(sprite)
	$Area2D/CollisionShape2D.set_deferred("disabled", true) 
	temp.hp -= attackPower
	temp.knockback = knockback
	temp.knockbackDir = direction
	direction = 0
	
	#stops emitting trail and emits explode particles instead
	$GPUParticles2D.emitting = false
	Part2.emitting = true
	await get_tree().create_timer(0.95).timeout
	queue_free()



#handles wall collision
func _on_area_2d_2_body_entered(_body: Node2D) -> void:
	
	remove_child(sprite)
	$Area2D/CollisionShape2D.set_deferred("disabled", true) 
	$GPUParticles2D.emitting = false
	Part2.emitting = true
	await get_tree().create_timer(0.95).timeout
	queue_free()
