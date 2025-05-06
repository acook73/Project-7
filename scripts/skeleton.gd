#skeleton enemy, creates arrow projectiles to shoot at the player
extends CharacterBody2D
@export var ARROW = preload("res://scenes/arrow.tscn")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hp = 100
@export var acceleration = 25
@export var SPEED = 50
var playerShoot = false
var incomingKnockback = 0
var knockbackDir = 0
var damaged = false
var player = null
var playerChase = false
var direction = 0

func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp

#walk towards the player if out of range of bow
func chase():
	#allows the enemy to stop if moving the wrong direction
	if (direction * velocity.x < 0):
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
		remove_child($Area2D)
		remove_child($AnimatedSprite2D)
		$shootDelay.start()
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
	
	#tries to get in range of player to shoot
	if (playerChase):
		#sprite flipping
		if(player.position.x-position.x < 0):
			direction = -1
			$RayCast2D.position.x = -15
			animated_sprite.flip_h = false
		else:
			direction = 1
			$RayCast2D.position.x = 17
			animated_sprite.flip_h = true
		
		#decides whether to shoot an arrow
		if (abs(player.position.x-position.x) < 250 and abs(player.position.y-position.y) < 40):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			#shoots
			if ($shootDelay.is_stopped()):
				$AnimatedSprite2D.play("shoot")
				$shootDelay.start()
				await get_tree().create_timer(0.95).timeout
				#creates an arrow and makes it move towards the player
				var arrow = ARROW.instantiate()
				get_tree().current_scene.add_child(arrow)
				arrow.position.x = position.x + 11*direction
				arrow.position.y = position.y - 20
				arrow.direction = direction
		#out of range (y-axis)
		elif (abs(player.position.x-position.x) < 150 and abs(player.position.y-position.y) > 40 and $shootDelay.is_stopped()):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("idle")
		#out of range but still in visual range
		elif ($shootDelay.is_stopped() and $RayCast2D.is_colliding()):
			chase()
		elif (not $RayCast2D.is_colliding() and $shootDelay.is_stopped()):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("idle")
		
	#no sight of player
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.play("idle")
	move_and_slide()

#sees player
func _on_detection_range_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		player = body
		playerChase = true
	

#no longer sees player
func _on_detection_range_body_exited(body: Node2D) -> void:
	if (body.name == "Player"):
		player = null
		playerChase = false
		velocity.x = move_toward(velocity.x, 0, SPEED)

#within bow distance
func _on_area_2d_body_entered(_body: Node2D) -> void:
	playerShoot = true

#exited bow range
func _on_area_2d_body_exited(_body: Node2D) -> void:
	playerShoot = false
