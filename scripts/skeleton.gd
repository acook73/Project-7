extends CharacterBody2D
@export var ARROW = preload("res://scenes/arrow.tscn")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hp = 100
var player = null
var playerChase = false
var direction = 0
var JumpY = -300
@export var acceleration = 25
@export var SPEED = 50
var airborne = false
var slashDelayPlayed = false
var playerShoot = false
var incomingKnockback = 0
var knockbackDir = 0
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp

func chase():
	#position += (player.position-position)/JumpX
	if (direction * velocity.x < 0 or slashDelayPlayed):
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		$AnimatedSprite2D.play("walk")
		if (velocity.x != 0):
			velocity.x += acceleration*direction*(1-((abs(velocity.x))/SPEED))
		else:
			velocity.x += acceleration*direction

func _physics_process(delta: float) -> void:
	
	if (hp <= 0):
		queue_free()
	if (incomingKnockback != 0):
		#position.y += -15
		velocity.y = incomingKnockback * -1 
		velocity.x = incomingKnockback * knockbackDir
		move_and_slide()
		#velocity.x = move_toward(velocity.x, knockback, SPEED)
		#velocity.y = move_toward(velocity.y, -1*knockback, SPEED)
		incomingKnockback = 0
	
	print($RayCast2D.is_colliding())
	
	doGravity(delta)
	if (is_on_floor()):
		velocity.y = 0
	if (playerChase):
		#sprite flipping
		if(player.position.x-position.x < 0):
			print($RayCast2D.position.x)
			direction = -1
			$RayCast2D.position.x = -15
			animated_sprite.flip_h = false
		else:
			print($RayCast2D.position.x)
			direction = 1
			$RayCast2D.position.x = 17
			animated_sprite.flip_h = true
		
		#decides whether to shoot an arrow
		if (abs(player.position.x-position.x) < 250 and abs(player.position.y-position.y) < 40):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if ($shootDelay.is_stopped()):
				$AnimatedSprite2D.play("shoot")
				$shootDelay.start()
				await get_tree().create_timer(0.95).timeout
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


func _on_detection_range_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		player = body
		playerChase = true
	


func _on_detection_range_body_exited(body: Node2D) -> void:
	if (body.name == "Player"):
		player = null
		playerChase = false
		velocity.x = move_toward(velocity.x, 0, SPEED)


func _on_area_2d_body_entered(_body: Node2D) -> void:
	playerShoot = true


func _on_area_2d_body_exited(_body: Node2D) -> void:
	playerShoot = false
