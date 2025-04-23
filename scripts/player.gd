extends CharacterBody2D

@onready var animated_sprite := $AnimatedSprite2D
@onready var grappleController := $grapple_controller
@onready var normalCollider := $NormalCollider
@onready var upHitbox1 := $AnimatedSprite2D/AttackHitbox/upHitbox1
@onready var upHitbox2 := $AnimatedSprite2D/AttackHitbox/upHitbox2
@onready var upHitbox3 := $AnimatedSprite2D/AttackHitbox/upHitbox3
@onready var label := $Label
@onready var exit := $Button


@export var SPEED = 150.0
@export var hp = 150.0
@export var JUMP_VELOCITY = -300.0
@export var doubleJumpVelocity = -350.0
@export var dashImpulse = 400
@export var friction = 3.0
@export var longSlide = 2.0
@export var acceleration = 25.0
@export var maxJumps = 2
@export var maxDash = 1

signal endGrapple(isGrappleJumping)

var numDashes = maxDash
var dashTimer = 0
var counter = 0
var dashCool = false
var dashed = false
var numJumps = maxJumps
var played = false
var squished = false
var cancelled = false
var grappling = false
var attackUP = false
var attackSIDE = false
var attackDOWN = false
var attackCROUCH = false
var attacking = false
var lastSafePos = position


func _ready():
	add_to_group("Player", true)
	endGrapple.connect(grappleController.endGrappleEarly)
	
func isGrappling(data):
	grappling = data
	if (isGrappling):
		cancelled = true

func dash():
	#finds direction to dash based on sprite orientation
	if (!attacking):
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
	if (Input.is_action_just_pressed("jump") and is_on_floor() and not grappling) or (Input.is_action_just_pressed("jump") and numJumps > 0 and not grappling):
		if is_on_floor():
			$DashTimer.stop()
			cancelled = true
		velocity.y = JUMP_VELOCITY
		if (numJumps > 0):
			played = false
		if not is_on_floor():
			numJumps -= 1
		if played == false:
			if (not attacking):
				animated_sprite.play("jump")
				played = true
			
	if (Input.is_action_just_pressed("jump") and is_on_wall() and grappling) or (Input.is_action_just_pressed("jump") and is_on_ceiling() and grappling or (Input.is_action_just_pressed("jump") and grappling and velocity == Vector2.ZERO)):
		endGrapple.emit("wall")
		numJumps = maxJumps
		velocity.y = JUMP_VELOCITY
		grappling = false

func attack():
	if (!attacking and Input.is_action_pressed("up")):
		animated_sprite.play("upAttack")
		attacking = true
	elif (!attacking and squished):
		#animated_sprite.play("squishAttack")
		#attacking = true
		pass
	elif (!attacking and Input.is_action_pressed("down")):
		#animated_sprite.play("downAttack")
		#attacking = true
		pass
	if (!attacking):
		#animated_sprite.play("frontAttack")
		#attacking = true
		pass
	

func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			#allows for a asymptopic acceleration curve realtive to the vertical velocity component
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp

func slideSquish(direction: float ):
	if squished == false and not attacking:
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
	if (not attacking):
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
	if (not attacking):
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

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _physics_process(delta: float) -> void:
	
	if (hp <= 0):
		label.visible = true
		exit.visible = true
		exit.disabled = false
		acceleration = 0
		animated_sprite.play("idle")
		
		

	var direction := Input.get_axis("left", "right") #-1 = left, 1 = right
	var direction_y := Input.get_axis("up", "down") #-1 = up, 1 = down
	
	if (direction == -1): # Handles flipping the hitboxes when the character flips
		upHitbox1.apply_scale(Vector2(-1, 1))
		upHitbox2.apply_scale(Vector2(-1, 1))
		upHitbox3.apply_scale(Vector2(-1, 1))
	if (direction == 1):
		upHitbox1.apply_scale(Vector2(1, 1))
		upHitbox2.apply_scale(Vector2(1, 1))
		upHitbox3.apply_scale(Vector2(1, 1))
		
	print(direction)
	
	if (attackUP): # Handles the hitboxes of attacking upwards
		if (animated_sprite.frame >= 4 and animated_sprite.frame < 6):
			upHitbox1.disabled = false
		else:
			upHitbox1.disabled = true
		if (animated_sprite.frame >= 6 and animated_sprite.frame < 8):
			upHitbox2.disabled = false
		else:
			upHitbox2.disabled = true
		if (animated_sprite.frame >= 8 and animated_sprite.frame < 10):
			upHitbox3.disabled = false
		else:
			upHitbox3.disabled = true
	if (animated_sprite.animation == "upAttack" and animated_sprite.frame == 12): # Ends upwards attack
		attackUP = false
		attacking = false
	
	if (attackSIDE): # Handles the hitboxes of attacking to the side
		pass
	

	
	if not grappling:
		doGravity(delta)
		if (Input.is_action_just_pressed("attack")):
			attack()
	#dash cancelling momentum ends after player hits the ground again
	if cancelled and is_on_floor():
		cancelled = false
	
	if !$DashTimer.is_stopped():
		velocity.y = 0
	else:
		played = false
		
	
	
	if (is_on_floor()):
		lastSafePos = position
	#resets dahes and jumps if player is on ground
	if (is_on_floor() or (is_on_wall() and grappling)):
		numJumps = maxJumps
		numDashes = maxDash
	
	if (is_on_floor() and grappling):
		endGrapple.emit("ground")
	
	# Handle jump
	jump()
	
	if not grappling:
		#flips sprite
		if direction == 1:
			animated_sprite.flip_h = false
		elif direction == -1:
			animated_sprite.flip_h = true
	
		#parses user input to determine which action needs to be played
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
	move_and_slide()
