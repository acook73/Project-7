extends CharacterBody2D
@export var hp = 100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var attackPower = 10
var player = null
var playerChase = false
var direction = 0
@export var JumpY = -300
@export var JumpX = 200
var jumpDelayPlayed = false
var airborne = false
@export var knockback = 200
var incomingKnockback = 0
var knockbackDir = 0
@export var maxVelocityX = 100
@export var maxVelocityY = 75
var cancelled = false
var damaged = false

func chase(direction: int):
	if (velocity.y < maxVelocityY and player.position.y-20 > position.y):
		velocity.y += 25
	elif (velocity.y > maxVelocityY*-1 and player.position.y < position.y-20):
		velocity.y -= 25
	else:
		velocity.y = 0
	if (abs(player.position.x-position.x) > 10 and velocity.x*direction < maxVelocityX):
		velocity.x += 25*direction

func _physics_process(delta: float) -> void:
	if (incomingKnockback != 0):
		velocity.y = incomingKnockback * -1 
		velocity.x = incomingKnockback * knockbackDir
		move_and_slide()
		incomingKnockback = 0
	if (damaged and $AnimatedSprite2D != null):
		$AnimatedSprite2D.material.set_shader_parameter("solid_color", Color.WHITE)
		$hitEffect.start()
		damaged = false
		$GPUParticlesExplode.emitting = true
	
	if ($hitEffect.is_stopped() and $AnimatedSprite2D != null):
		$AnimatedSprite2D.material.set_shader_parameter("solid_color", Color.TRANSPARENT)
	
	if (hp <= 0):
		remove_child($DetectionRange)
		remove_child($AnimatedSprite2D)
		await get_tree().create_timer(0.3).timeout
		queue_free()
	if (player != null):
		if(player.position.x-position.x < 0):
			direction = -1
			animated_sprite.flip_h = false
		else:
			direction = 1
			animated_sprite.flip_h = true
		if($AnimatedSprite2D != null):
			$AnimatedSprite2D.play("idle")
			chase(direction)
	elif($AnimatedSprite2D != null):
		$AnimatedSprite2D.play("idle")
		velocity = Vector2.ZERO
		
	move_and_slide()


func _on_detection_range_body_entered(body: Node2D) -> void:
	player = body
	playerChase = true
	


func _on_detection_range_body_exited(body: Node2D) -> void:
	player = null
	playerChase = false
	jumpDelayPlayed = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp -= attackPower
	body.knockback = knockback
	body.knockbackDir = direction
