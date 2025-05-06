#bat enemy, attacks by diving at the player, (idle is default flying animation)
extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hp = 100
@export var attackPower = 10
@export var knockback = 200
@export var maxHeight = 160
@export var minHeight = 125
var cancelled = false
var damaged = false
var diving = false
var first = false
var incomingKnockback = 0
var knockbackDir = 0
var player = null
var playerChase = false
var direction = 0

#acceleration while bat is diving
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component, this one is lower than other enemies
			temp.y -= velocity.y/(10*temp.y)
		velocity += temp

#gets the bat into position above the player, must have a minimum height reached above the player before diving
func chase():
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

#handles the dive animations and when to end them
func dive():
	#starts dive
	if (not first):
		$AnimatedSprite2D.play("dive")
		first = true
		$diveDelay.start()
	#middle of dive
	elif ($diveDelay.is_stopped() and $AnimatedSprite2D.animation == "dive"):
		$AnimatedSprite2D.play("swoosh")
	#horizontal correction while diving
	if (abs(velocity.x) < 75 or velocity.x/abs(velocity.x) != direction):
		velocity.x += 25*direction
	#end of dive
	@warning_ignore("integer_division")
	if ((player.position.y-position.y) < minHeight/2 and abs(player.position.y-position.y) > 20 and $diveDelay.is_stopped()):
		$AnimatedSprite2D.play("undive")
		$diveDelay.start()
	#return to default state
	elif (abs(player.position.y-position.y) < 20 and $diveDelay.is_stopped()):
		$AnimatedSprite2D.play("idle")
		velocity.y = 0
		diving = false
		first = false


func _physics_process(delta: float) -> void:
	#knockback handling
	if (incomingKnockback != 0):
		velocity.y = incomingKnockback * -1 
		velocity.x = incomingKnockback * knockbackDir
		move_and_slide()
		incomingKnockback = 0
	
	#on hit shader handling
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
		await get_tree().create_timer(0.3).timeout
		queue_free()
	
	#chases/dives at player if within radius
	if (player != null):
		if(player.position.x-position.x < 0):
			direction = -1
			animated_sprite.flip_h = false
		else:
			direction = 1
			animated_sprite.flip_h = true
		
		if (diving and $AnimatedSprite2D != null): 
			doGravity(delta)
			dive()
		elif($AnimatedSprite2D != null):
			$AnimatedSprite2D.play("idle")
			chase()
	elif($AnimatedSprite2D != null):
		$AnimatedSprite2D.play("idle")
		velocity = Vector2.ZERO
		diving = false
		first = false
		
	move_and_slide()

#player detected
func _on_detection_range_body_entered(body: Node2D) -> void:
	player = body
	playerChase = true
	

#player left detection radius
func _on_detection_range_body_exited(_body: Node2D) -> void:
	player = null
	playerChase = false

#player hit
func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp -= attackPower
	body.knockback = knockback
	body.knockbackDir = direction
