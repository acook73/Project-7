extends CharacterBody2D

@onready var animated_sprite := $AnimatedSprite2D
@onready var grappleController := $grapple_controller
@onready var normalCollider := $NormalCollider
@onready var upHitbox1 := $AnimatedSprite2D/AttackHitbox/upHitbox1
@onready var upHitbox2 := $AnimatedSprite2D/AttackHitbox/upHitbox2
@onready var upHitbox3 := $AnimatedSprite2D/AttackHitbox/upHitbox3
@onready var label := $Label
@onready var exit := $Button
@onready var button2 := $Button2


@export var SPEED = 150.0
@export var hp = 150.0
@export var hp_max = 150.0
@export var JUMP_VELOCITY = -300.0
@export var doubleJumpVelocity = -350.0
@export var dashImpulse = 400
@export var friction = 3.0
@export var longSlide = 2.0
@export var acceleration = 25.0
@export var maxJumps = 2
@export var maxDash = 1
@export var attackPower = 25

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
var knockback = 0
var knockbackDir = 0
var permaUpgrades: Array
var reset: Array

func _ready():
	add_to_group("Player", true)
	endGrapple.connect(grappleController.endGrappleEarly)
	if not FileAccess.file_exists("res://loadFlag.save"):
		return
	else:
		var save_file = FileAccess.open("res://loadFlag.save", FileAccess.READ)
		if (save_file.get_line() == "1"):
			load_game()
		
	
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
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _on_button_2_pressed() -> void:
	get_tree().paused = false
	load_game()
	
func load_game():
	label.visible = false
	exit.visible = false
	exit.disabled = true
	button2.visible = false
	button2.disabled = true
	acceleration = 25.0
	velocity = Vector2.ZERO
	if not FileAccess.file_exists("res://savegame.save"):
		return
	else:
		var save_file = FileAccess.open("res://savegame.save", FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			var node_data = json.data
			position = Vector2(node_data["pos_x"], node_data["pos_y"])
			for i in reset.size():
				var path = NodePath(reset[i])
				get_parent().get_node(path).anim.visible = true
				get_parent().get_node(path).coll.disabled = false
			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
					continue
				elif i == "rem":
					permaUpgrades = node_data[i]
					for j in node_data[i].size():
						print(node_data[i][j])
						#print($Game)
						print(get_tree().get_root())
						var temp = get_parent().get_node(node_data[i][j])
						if (temp != null):
							temp.queue_free()
						#get_tree().get_root().remove_child(find_child(node_data[i][j]))
					continue
				set(i, node_data[i])


func _physics_process(delta: float) -> void:
	print(hp_max)
	$TextureProgressBar.max_value = hp_max
	$TextureProgressBar.value = hp
	if (hp <= 0):
		get_tree().paused = true
		
		label.visible = true
		exit.visible = true
		exit.disabled = false
		button2.visible = true
		button2.disabled = false
		acceleration = 0
		animated_sprite.play("idle")
		
		

	var direction := Input.get_axis("left", "right") #-1 = left, 1 = right
	var direction_y := Input.get_axis("up", "down") #-1 = up, 1 = down
	
	if (knockback != 0):
		#position.y += -15
		velocity.x += knockbackDir * knockback
		velocity.y += knockback * -1
		move_and_slide()
		#velocity.x = move_toward(velocity.x, knockback, SPEED)
		#velocity.y = move_toward(velocity.y, -1*knockback, SPEED)
		knockback = 0
		cancelled = true
		animated_sprite.play("falling")
		#squished = true
		#direction = 0
		#$KnockbackTimer.start()
	if (Input.is_action_just_pressed("pause")):
		get_tree().paused = true
		$Menu.visible = true
		$Menu.disabled = false
		$Reset.visible = true
		$Reset.disabled = false
		$Resume.visible = true
		$Resume.disabled = false
		$Pause.visible = true
		
	
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
		elif squished == true and $KnockbackTimer.is_stopped():
			unsquish()
	
		#run/dash begin
		else:
			#running acceleration (works in air)
			runAccel(direction)
		
			#dash/run animation handling on floor and in the air
			animationParser(direction)
	move_and_slide()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")




func _on_reset_pressed() -> void:
	get_tree().paused = false
	$Menu.visible = false
	$Menu.disabled = true
	$Reset.visible = false
	$Reset.disabled = true
	$Resume.visible = false
	$Resume.disabled = true
	$Pause.visible = false
	load_game()


func _on_resume_pressed() -> void:
	$Menu.visible = false
	$Menu.disabled = true
	$Reset.visible = false
	$Reset.disabled = true
	$Resume.visible = false
	$Resume.disabled = true
	$Pause.visible = false
	get_tree().paused = false
