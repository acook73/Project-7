extends CharacterBody2D
@export var hp = 150
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var attackPower = 20
var player = null
var playerChase = false
var direction = 0
var JumpY = -300
var hit = false
var incomingKnockback = 0
var knockbackDir = 0
@export var acceleration = 25
@export var SPEED = 50
var airborne = false
@export var knockback = 200
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
	if (direction * velocity.x < 0 or not $slashDelay.is_stopped()):
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		$AnimatedSprite2D.play("walk")
		if (velocity.x != 0):
			velocity.x += acceleration*direction*(1-((abs(velocity.x))/SPEED))
		else:
			velocity.x += acceleration*direction

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
		playerChase = false
		$slashDelay.start()
		await get_tree().create_timer(0.3).timeout
		queue_free()
	
	if (incomingKnockback != 0):
		velocity.y = incomingKnockback * -1 
		velocity.x = incomingKnockback * knockbackDir
		move_and_slide()
		#velocity.x = move_toward(velocity.x, knockback, SPEED)
		#velocity.y = move_toward(velocity.y, -1*knockback, SPEED)
		incomingKnockback = 0
	doGravity(delta)
	if (is_on_floor()):
		velocity.y = 0
	else:
		airborne = true
	if (playerChase):
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
		
		if($slashDelayHit.is_stopped() and not $slashDelay.is_stopped() and not hit):
			$AttackBox/CollisionShape2D.set_deferred("disabled", false) 
		else:
			$AttackBox/CollisionShape2D.set_deferred("disabled", true) 
		
		if (abs(player.position.x-position.x) < 20 and abs(player.position.y-position.y) < 40):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("slash")
			if ($slashDelay.is_stopped()):
				hit = false
				$slashDelay.start()
				$slashDelayHit.start()
		elif (abs(player.position.x-position.x) < 20 and abs(player.position.y-position.y) > 40):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("idle")
		elif (not $RayCast2D.is_colliding() and $slashDelay.is_stopped()):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("idle")
		else:
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
	velocity.x = move_toward(velocity.x, 0, SPEED)


func _on_attack_box_body_entered(body: Node2D) -> void:
	body.hp -= attackPower
	body.knockback = knockback
	body.knockbackDir = direction
	$AttackBox/CollisionShape2D.set_deferred("disabled", true) 
	hit = true
	
