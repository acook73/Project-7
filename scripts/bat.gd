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
@export var maxHeight = 160
@export var minHeight = 125
var cancelled = false
var damaged = false
var diving = false
var first = false
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(10*temp.y)
		velocity += temp

func chase(direction: int):
	if ((player.position.y-position.y) > minHeight and abs(player.position.x-position.x) < 50):
		diving = true
	else:
		if (player.position.y-position.y < minHeight and velocity.y > -50):
			velocity.y += -25
		if (player.position.y-position.y > maxHeight and velocity.y < 50):
			velocity.y += 50
		if (abs(player.position.x-position.x) > 1 and velocity.x*direction < 150):
			velocity.x += 25*direction
		else:
			velocity.x = 0

func dive():
	if (not first):
		$AnimatedSprite2D.play("dive")
		first = true
		$diveDelay.start()
	elif ($diveDelay.is_stopped() and $AnimatedSprite2D.animation == "dive"):
		$AnimatedSprite2D.play("swoosh")
	if (abs(velocity.x) < 75 or velocity.x/abs(velocity.x) != direction):
		velocity.x += 25*direction
	if ((player.position.y-position.y) < minHeight/2 and abs(player.position.y-position.y) > 20 and $diveDelay.is_stopped()):
		print("played")
		$AnimatedSprite2D.play("undive")
		$diveDelay.start()
	elif (abs(player.position.y-position.y) < 20 and $diveDelay.is_stopped()):
		$AnimatedSprite2D.play("idle")
		velocity.y = 0
		diving = false
		first = false
	
func _physics_process(delta: float) -> void:
	print(diving)
	print(first)
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
		
		if (diving and $AnimatedSprite2D != null): 
			#$AnimatedSprite2D.play("dive")
			doGravity(delta)
			dive()
		elif($AnimatedSprite2D != null):
			$AnimatedSprite2D.play("idle")
			chase(direction)
	elif($AnimatedSprite2D != null):
		$AnimatedSprite2D.play("idle")
		velocity = Vector2.ZERO
		diving = false
		first = false
		
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
