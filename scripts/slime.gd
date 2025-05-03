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
var cancelled = false
var damaged = false
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp

func chase(direction: int):
	#position += (player.position-position)/JumpX
	if (is_on_floor() and !jumpDelayPlayed):
		$jumpDelay.start()
		$AnimatedSprite2D.play("jump")
		jumpDelayPlayed = true
	elif (is_on_floor() and $jumpDelay.is_stopped()):
		velocity.y = JumpY
		var temp = (-1*direction)*(abs(player.position.x-position.x)/(2*JumpY/get_gravity().y)+abs(player.position.y-position.y))
		if (temp > 250):
			temp = 250
		velocity.x = temp
		jumpDelayPlayed = false

func _physics_process(delta: float) -> void:
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
		$jumpDelay.start()
		await get_tree().create_timer(0.3).timeout
		queue_free()
	doGravity(delta)
	if (is_on_floor()):
		velocity.x = 0
		velocity.y = 0
	#elif (is_on_floor()):
		#cancelled = false
	else:
		airborne = true
	
	if (incomingKnockback != 0):
		velocity.y = incomingKnockback * -1 
		velocity.x = incomingKnockback * knockbackDir
		move_and_slide()
		#velocity.x = move_toward(velocity.x, knockback, SPEED)
		#velocity.y = move_toward(velocity.y, -1*knockback, SPEED)
		incomingKnockback = 0
	#if (is_on_floor() and airborne):
		#$AnimatedSprite2D.offset.y = -4
		#$AnimatedSprite2D.play("land")
		#await get_tree().create_timer(.5).timeout
		#airborne = false
	if (playerChase):
		if(player.position.x-position.x < 0):
			direction = -1
			animated_sprite.flip_h = false
		else:
			direction = 1
			animated_sprite.flip_h = true
		chase(direction)
		
		
		
	elif ($AnimatedSprite2D != null):
		#$AnimatedSprite2D.offset.y = -4
		$AnimatedSprite2D.play("idle")
	move_and_slide()


func _on_detection_range_body_entered(body: Node2D) -> void:
	player = body
	playerChase = true
	


func _on_detection_range_body_exited(body: Node2D) -> void:
	player = null
	playerChase = false
	$jumpDelay.stop()
	jumpDelayPlayed = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp -= attackPower
	body.knockback = knockback
	body.knockbackDir = direction
