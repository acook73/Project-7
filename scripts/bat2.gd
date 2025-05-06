#alternate bat enemy, attacks by flying directly at the player,  (idle is default flying animation)
extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hp = 100
@export var attackPower = 10
@export var knockback = 200
@export var maxVelocityX = 100
@export var maxVelocityY = 75
var damaged = false
var player = null
var playerChase = false
var direction = 0
var incomingKnockback = 0
var knockbackDir = 0

#accelerate towards the player
func chase():
	#above player
	if (velocity.y < maxVelocityY and player.position.y-20 > position.y):
		velocity.y += 25
	#below player
	elif (velocity.y > maxVelocityY*-1 and player.position.y < position.y-20):
		velocity.y -= 25
	#at player height
	else:
		velocity.y = 0
	#x axis movement
	if (abs(player.position.x-position.x) > 10 and velocity.x*direction < maxVelocityX):
		velocity.x += 25*direction


func _physics_process(_delta: float) -> void:
	#handles knockback after being hit
	if (incomingKnockback != 0):
		velocity.y = incomingKnockback * -1 
		velocity.x = incomingKnockback * knockbackDir
		move_and_slide()
		incomingKnockback = 0
	
	#handles on hit shader effect
	if (damaged and $AnimatedSprite2D != null):
		$AnimatedSprite2D.material.set_shader_parameter("solid_color", Color.WHITE)
		$hitEffect.start()
		damaged = false
		$GPUParticlesExplode.emitting = true
	if ($hitEffect.is_stopped() and $AnimatedSprite2D != null):
		$AnimatedSprite2D.material.set_shader_parameter("solid_color", Color.TRANSPARENT)
	
	#handles death
	if (hp <= 0):
		remove_child($DetectionRange)
		remove_child($AnimatedSprite2D)
		await get_tree().create_timer(0.3).timeout
		queue_free()
	
	#moves bat if player is in detection radius
	if (player != null):
		if(player.position.x-position.x < 0):
			direction = -1
			animated_sprite.flip_h = false
		else:
			direction = 1
			animated_sprite.flip_h = true
			chase()
	move_and_slide()


#player detected
func _on_detection_range_body_entered(body: Node2D) -> void:
	player = body
	playerChase = true
	

#player too far
func _on_detection_range_body_exited(_body: Node2D) -> void:
	player = null
	playerChase = false

#collision with player
func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hp -= attackPower
	body.knockback = knockback
	body.knockbackDir = direction
