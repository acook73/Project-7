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
var grapplePoint
var grappling = false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("Player", true)
	
func grapple(pos):
	grapplePoint = pos
	print("Received:", pos)
	position = pos
	
	grappling = true
	
	

	
func dash():
	#finds direction to dash based on sprite orientation
	var dashDirection
	if animated_sprite.flip_h:
		dashDirection = -1
	else:
		dashDirection = 1
	
	played = true
	animated_sprite.play("dash")
	velocity.x = dashImpulse * dashDirection
	numDashes -= 1
	$DashCool.start()
	$DashTimer.start()

func jump():
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and numJumps > 0):
		if is_on_floor():
			$DashTimer.stop()
			cancelled = true
		velocity.y = JUMP_VELOCITY
		if (numJumps > 0):
			played = false
		numJumps -= 1
		if played == false:
			animated_sprite.play("jump")
			played = true
	
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp

func slideSquish(direction: float ):
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

func unsquish():
	animated_sprite.play("unsquish")
	squished = false

func runAccel(direction: float):
	if direction and $DashTimer.is_stopped():
		if (velocity.x != 0 and direction == abs(velocity.x)/velocity.x):
			velocity.x += acceleration*direction*(1-((abs(velocity.x))/SPEED))
		else:
			velocity.x += acceleration*direction
		#no direction input (stop)
	elif $DashTimer.is_stopped() and !cancelled:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func animationParser(direction: float):
	if is_on_floor():
		if Input.is_action_just_pressed("dash") and $DashCool.is_stopped() and numDashes != 0:
			dash()
		elif direction == 0 and played == false:
			animated_sprite.play("idle")
		elif played == false:
			animated_sprite.play("run")
	else:
		if (Input.is_action_just_pressed("dash") and $DashCool.is_stopped() and numDashes != 0):
			dash()

func inputParser(direction_y: float, direction: float):
	
	#crouch/slide begin
	if direction_y == 1:
		slideSquish(direction)
	
	#crouch end animation
	elif squished == true:
		unsquish()
	
	#run/dash begin
	else:
		#running acceleration (works in air)
		runAccel(direction)
		
		#dash/run animation handling on floor and in the air
		animationParser(direction)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	doGravity(delta)
	
	#dash cancelling momentum ends after player hits the ground again
	if cancelled and is_on_floor():
		cancelled = false
	
	#
	if !$DashTimer.is_stopped():
		velocity.y = 0
	else:
		played = false
	
	# Handle jump
	jump()
	
	#resets dahes and jumps if player is on ground
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
	
	#parses user input to determine which action needs to be played
	inputParser(direction_y, direction)
			


	move_and_slide()
