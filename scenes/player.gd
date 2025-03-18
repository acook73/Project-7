extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -300.0
const doubleJumpVelocity = -350.0
const dashImpulse = 400
const friction = 3.0
const longSlide = 2.0
const acceleration = 25.0
const maxJumps = 1
const maxDash = 1
var numDashes = maxDash
var dashTimer = 0
var counter = 0
var dashCool = false
var dashed = false
var numJumps = maxJumps
var played = false
var squished = false
var cancelled = false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim = $animationplayer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp
	#dash cooldown
	if dashed == true:
		dashCool = true
	if (dashCool == true):
		dashTimer += 1
		if (dashTimer >= 30):
			dashTimer = 0
			dashCool = false
	if cancelled and is_on_floor():
		cancelled = false
	# Handle jump.
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and numJumps > 0):
		if is_on_floor():
			dashed = false
			counter = 0
			cancelled = true
		velocity.y = JUMP_VELOCITY
		if (numJumps > 0):
			played = false
		numJumps -= 1
	if (is_on_floor()):
		numJumps = maxJumps
		numDashes = maxDash
	#-1 = left, 1 = right
	var direction := Input.get_axis("left", "right")
	#-1 = up, 1 = down
	var direction_y := Input.get_axis("up", "down")
	
	#flips sprite
	if direction == 1:
		animated_sprite.flip_h = false
	elif direction == -1:
		animated_sprite.flip_h = true
		
	#crouch begin
	if direction_y == 1:
		if squished == false:
			animated_sprite.play("squish")
		squished = true
		if (abs(velocity.x) > 9.0 and direction == velocity.x/abs(velocity.x)):
			#short slide
			if (velocity.x > 0.0):
				velocity.x -= friction
			else:
				velocity.x += friction
			if (abs(velocity.x) <= friction):
				velocity.x = 0.0
		else:
			#long slide
			if (velocity.x > 0.0):
				velocity.x -= longSlide*friction
			else:
				velocity.x += longSlide*friction
			if (abs(velocity.x) <= longSlide*friction):
				velocity.x = 0.0
	#crouch end animation
	elif squished == true:
		animated_sprite.play("unsquish")
		squished = false
	else:
		
		if direction and !dashed:
			if (velocity.x != 0 and direction == abs(velocity.x)/velocity.x):
				velocity.x += acceleration*direction*(1-((abs(velocity.x))/SPEED))
			else:
				velocity.x += acceleration*direction
		elif !dashed and !cancelled:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			played = false
			
			if Input.is_action_just_pressed("dash") or dashed == true:
				var dashDirection
				if animated_sprite.flip_h:
					dashDirection = -1
				else:
					dashDirection = 1
				if (dashed != true and dashCool != true):
					animated_sprite.play("dash")
					velocity.x = dashImpulse * dashDirection
					dashed = true
				if dashed == true:
					counter += 1
					velocity.y = 0
				if (counter >= 15):
					dashed = false
					counter = 0
			elif direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			if ((Input.is_action_just_pressed("dash") or dashed == true)):
					var dashDirection
					if animated_sprite.flip_h:
						dashDirection = -1
					else:
						dashDirection = 1
					if (dashed != true and dashCool != true and numDashes > 0):
						animated_sprite.play("dash")
						velocity.x = dashImpulse * dashDirection
						dashed = true
						numDashes -= 1
					if dashed == true:
						counter += 1
						velocity.y = 0
					if (counter >= 15):
						dashed = false
						counter = 0
			if played == false:
				animated_sprite.play("jump")
				played = true
			


	move_and_slide()
