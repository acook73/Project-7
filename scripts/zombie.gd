extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hp = 150
@export var acceleration = 25
@export var SPEED = 50
@export var knockback = 200
@export var attackPower = 20
var player = null
var playerChase = false
var direction = 0
var hit = false
var incomingKnockback = 0
var knockbackDir = 0
var damaged = false

#does gravity
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp

#chases after player unless attacking
func chase():
	if (direction * velocity.x < 0 or not $slashDelay.is_stopped()):
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		$AnimatedSprite2D.play("walk")
		if (velocity.x != 0):
			velocity.x += acceleration*direction*(1-((abs(velocity.x))/SPEED))
		else:
			velocity.x += acceleration*direction


func _physics_process(delta: float) -> void:
	#hit shader handling
	if (damaged and $AnimatedSprite2D != null):
		$AnimatedSprite2D.material.set_shader_parameter("solid_color", Color.WHITE)
		$hitEffect.start()
		damaged = false
		$GPUParticlesExplode.emitting = true
	if ($hitEffect.is_stopped() and $AnimatedSprite2D != null):
		$AnimatedSprite2D.material.set_shader_parameter("solid_color", Color.TRANSPARENT)
	
	#death handling
	if (hp <= 0):
		remove_child($DetectionRange)
		remove_child($AnimatedSprite2D)
		playerChase = false
		$slashDelay.start()
		await get_tree().create_timer(0.3).timeout
		queue_free()
	
	#knockback handling
	if (incomingKnockback != 0):
		velocity.y = incomingKnockback * -1 
		velocity.x = incomingKnockback * knockbackDir
		move_and_slide()
		incomingKnockback = 0
		
	doGravity(delta)
	if (is_on_floor()):
		velocity.y = 0
	
	#determines whether to attack or walk towards player
	if (playerChase):
		#finds direction
		if(player.position.x-position.x < 0):
			direction = -1
			$RayCast2D.position.x = -10
			$AttackBox.position.x = -7
			animated_sprite.flip_h = true
		else:
			direction = 1
			$RayCast2D.position.x = 10
			$AttackBox.position.x = 7
			animated_sprite.flip_h = false
		
		#turns off hitbox if attack ends or player is hit
		if($slashDelayHit.is_stopped() and not $slashDelay.is_stopped() and not hit):
			$AttackBox/CollisionShape2D.set_deferred("disabled", false) 
		else:
			$AttackBox/CollisionShape2D.set_deferred("disabled", true) 
		
		#attack player
		if (abs(player.position.x-position.x) < 20 and abs(player.position.y-position.y) < 40):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("slash")
			if ($slashDelay.is_stopped()):
				hit = false
				$slashDelay.start()
				$slashDelayHit.start()
		#player is too high/low
		elif (abs(player.position.x-position.x) < 20 and abs(player.position.y-position.y) > 40):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("idle")
			
		#ledge detected
		elif (not $RayCast2D.is_colliding() and $slashDelay.is_stopped()):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("idle")
		#walk towards palyer
		else:
			chase()
	elif ($AnimatedSprite2D != null):
		#$AnimatedSprite2D.offset.y = -4
		$AnimatedSprite2D.play("idle")
	move_and_slide()

#player seen
func _on_detection_range_body_entered(body: Node2D) -> void:
	player = body
	playerChase = true
	

#player unseen
func _on_detection_range_body_exited(_body: Node2D) -> void:
	player = null
	playerChase = false
	velocity.x = move_toward(velocity.x, 0, SPEED)

#player hit
func _on_attack_box_body_entered(body: Node2D) -> void:
	body.hp -= attackPower
	body.knockback = knockback
	body.knockbackDir = direction
	$AttackBox/CollisionShape2D.set_deferred("disabled", true) 
	hit = true
	
