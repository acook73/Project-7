#The player
extends CharacterBody2D

@onready var animated_sprite := $AnimatedSprite2D
@onready var grappleController := $grapple_controller
@onready var normalCollider := $NormalCollider
@onready var upHitbox1 := $AnimatedSprite2D/AttackHitbox/upHitbox1
@onready var upHitbox2 := $AnimatedSprite2D/AttackHitbox/upHitbox2
@onready var upHitbox3 := $AnimatedSprite2D/AttackHitbox/upHitbox3
@onready var sideHitbox1 := $AnimatedSprite2D/AttackHitbox/sideHitbox1
@onready var crouchHitbox1 := $AnimatedSprite2D/AttackHitbox/crouchHitbox1
@onready var downHitbox1 := $AnimatedSprite2D/AttackHitbox/downHitbox1
@onready var downHitbox2 := $AnimatedSprite2D/AttackHitbox/downHitbox2
@onready var downHitbox3 := $AnimatedSprite2D/AttackHitbox/downHitbox3
@onready var downHitbox4 := $AnimatedSprite2D/AttackHitbox/downHitbox4
@onready var label := $Labels/Label
@onready var exit := $Buttons/Button
@onready var button2 := $Buttons/Button2

#player stats
@export var SPEED = 150.0
@export var hp = 150.0
@export var hp_max = 150.0
@export var JUMP_VELOCITY = -300.0
@export var doubleJumpVelocity = -350.0
@export var dashImpulse = 400
@export var friction = 3.0
@export var longSlide = 2.0
@export var acceleration = 25.0
@export var maxJumps = 0
@export var maxDash = 0
@export var attackPower = 25
@export var outgoingKnockback = 200

signal endGrapple(isGrappleJumping)

#variables to track animation states, timers, pickups, and other important information
var checkpoint = false
var direction = 0
var numDashes = maxDash
var dashTimer = 0
var counter = 0
var dashCool = false
var dashed = false
var dashing = false
var wasDashing = false
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
var scan = 1
var lastSafePos = position
var knockback = 0
var knockbackDir = 0
var permaUpgrades: Array
var reset: Array
var hats: Array = ["none"]
var hitboxPos
var hitboxRot
var dir
var offset = 1
var dJump = false
var uDash = false
var selectedHat = 0

#when the player is instantiated
func _ready():
	
	#hitbox positions are loaded into dictionaries
	hitboxPos = {"upHitbox1": upHitbox1.position, "upHitbox2": upHitbox2.position, 
	"upHitbox3": upHitbox3.position, "sideHitbox1": sideHitbox1.position,
	"crouchHitbox1": crouchHitbox1.position, "downHitbox1": downHitbox1.position,
	"downHitbox2": downHitbox2.position, "downHitbox3": downHitbox3.position,
	"downHitbox4": downHitbox4.position}
	hitboxRot = {"upHitbox1": upHitbox1.rotation, "upHitbox2": upHitbox2.rotation,
	"upHitbox3": upHitbox3.rotation, "sideHitbox1": sideHitbox1.rotation,
	"crouchHitbox1": crouchHitbox1.rotation, "downHitbox1": downHitbox1.rotation,
	"downHitbox2": downHitbox2.rotation, "downHitbox3": downHitbox3.rotation,
	"downHitbox4": downHitbox4.rotation}
	
	#player is added to the player group
	add_to_group("Player", true)
	endGrapple.connect(grappleController.endGrappleEarly)

	#loadFlag is checked to see if a save file needs to be loaded from
	if not FileAccess.file_exists("res://loadFlag.save"):
		return
	else:
		var save_file = FileAccess.open("res://loadFlag.save", FileAccess.READ)
		if (save_file.get_line() == "1"):
			load_game()
	
	#player hats are loaded
	loadHats()
	
#handles whether the player is grappling or not
func isGrappling(data):
	grappling = data
	if (isGrappling):
		cancelled = true

#handles dashing
func dash():
	#only happens if player is not attacking
	if (!attacking):
		#cannot be hit while dashing
		set_collision_layer_value(4, false)
		
		played = true
		dashing = true
		
		#velocity is updated to dash speed
		velocity.x = dashImpulse * dir
		
		#dash count is decremented
		numDashes -= 1
		
		#hat is moved into correct position for the sprite
		if (dir == 1):
			$Hat.position.x = 6
		else:
			$Hat.position.x = -8
		
		#cooldowns start
		$Timers/DashCool.start()
		$Timers/DashTimer.start()

#handles player jumping
func jump():
	
	#player must have at least 1 jump available and not be grappling
	if (Input.is_action_just_pressed("jump") and is_on_floor() and not grappling) or (Input.is_action_just_pressed("jump") and numJumps > 0 and not grappling):
		
		#cancels dash if player is dashing
		if is_on_floor():
			$Timers/DashTimer.stop()
			cancelled = true
		
		#velocity update
		velocity.y = JUMP_VELOCITY
		
		#animation tracking
		if (numJumps > 0):
			played = false
		if not is_on_floor():
			numJumps -= 1
		if played == false:
			if (not attacking):
				animated_sprite.play("jump")
				played = true
	
	#wall jump if grappling
	if (Input.is_action_just_pressed("jump") and is_on_wall() and grappling) or (Input.is_action_just_pressed("jump") and is_on_ceiling() and grappling or (Input.is_action_just_pressed("jump") and grappling and velocity == Vector2.ZERO)):
		endGrapple.emit("wall")
		numJumps = maxJumps
		velocity.y = JUMP_VELOCITY
		grappling = false

#handles the four player attacks
func attack():
	if (!attacking and Input.is_action_pressed("up")):
		animated_sprite.play("upAttack")
		attacking = true
		attackUP = true
	elif (!attacking and squished and is_on_floor()):
		animated_sprite.play("crouchAttack")
		attacking = true
		attackCROUCH = true
		pass
	elif (!attacking and Input.is_action_pressed("down") and not is_on_floor()):
		animated_sprite.play("downAttack")
		attacking = true
		attackDOWN = true
		pass
	elif (!attacking):
		animated_sprite.play("sideAttack")
		attacking = true
		attackSIDE = true
	
#asymptopic acceleration curve relative to the vertical velocity component
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		if (velocity.y > 200):
			temp.y -= velocity.y/(2.5*temp.y)
		velocity += temp

#crouch/slide handling
func slideSquish():
	#hat position adjustment
	if squished == false and not attacking:
		$Hat.position.y = -31
		if (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-10.png"):
			$Hat.position.y = -28
		animated_sprite.play("squish")
		squished = true
		
	#short slide if holding no direction keys
	if (abs(velocity.x) > 9.0 and direction == velocity.x/abs(velocity.x)):
		if (velocity.x > 0.0):
			velocity.x -= friction
		else:
			velocity.x += friction
		if (abs(velocity.x) <= friction):
			velocity.x = 0.0
	
	#long slide if holding direction key corresponding to player movement direction
	else:
		if (velocity.x > 0.0):
			velocity.x -= longSlide*friction
		else:
			velocity.x += longSlide*friction
		if (abs(velocity.x) <= longSlide*friction):
			velocity.x = 0.0

#backwards crouch animation to stop crouching
func unsquish():
	
	#updates hat position
	if (not attacking):
		$Hat.position.y = -35
		if (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-10.png"):
			$Hat.position.y = -32
		animated_sprite.play("unsquish")
		squished = false

#accelerates player to their max speed using an asymptopic curve
func runAccel():
	if direction and $Timers/DashTimer.is_stopped():
		if (velocity.x != 0 and direction == abs(velocity.x)/velocity.x):
			velocity.x += acceleration*direction*(1-((abs(velocity.x))/SPEED))
		else:
			velocity.x += acceleration*direction
	#no direction input (stop)
	elif $Timers/DashTimer.is_stopped() and !cancelled:
		velocity.x = move_toward(velocity.x, 0, SPEED)

#figures out which animation to play
func animationParser():
	if (not attacking):
		if (squished):
			animated_sprite.play("squishing")
		elif (dashing):
			
			animated_sprite.play("dash")
		elif is_on_floor():
			if direction == 0 and played == false:
				animated_sprite.play("idle")
			elif played == false:
				animated_sprite.play("run")
		elif (not is_on_floor()):
			if (velocity.y < 0):
				animated_sprite.play("rising")
			elif (velocity.y > 0):
				animated_sprite.play("falling")

#moves hitboxes into correct position based on player direction
func moveHitboxes():
	upHitbox1.position.x = hitboxPos["upHitbox1"].x * dir
	upHitbox1.rotation = hitboxRot["upHitbox1"] * dir
	upHitbox2.position.x = hitboxPos["upHitbox2"].x * dir
	upHitbox2.rotation = hitboxRot["upHitbox2"] * dir
	upHitbox3.position.x = hitboxPos["upHitbox3"].x * dir
	upHitbox3.rotation = hitboxRot["upHitbox3"] * dir
	sideHitbox1.position.x = hitboxPos["sideHitbox1"].x * dir
	sideHitbox1.rotation = hitboxRot["sideHitbox1"] * dir
	crouchHitbox1.position.x = hitboxPos["crouchHitbox1"].x * dir
	crouchHitbox1.rotation = hitboxRot["crouchHitbox1"] * dir
	downHitbox1.position.x = hitboxPos["downHitbox1"].x * dir
	downHitbox1.rotation = hitboxRot["downHitbox1"] * dir
	downHitbox2.position.x = hitboxPos["downHitbox2"].x * dir
	downHitbox2.rotation = hitboxRot["downHitbox2"] * dir
	downHitbox3.position.x = hitboxPos["downHitbox3"].x * dir
	downHitbox3.rotation = hitboxRot["downHitbox3"] * dir
	downHitbox4.position.x = hitboxPos["downHitbox4"].x * dir
	downHitbox4.rotation = hitboxRot["downHitbox4"] * dir

#disables or enables correct hitboxes based on player attack input
func attackHit():
	if (attackUP): # Handles the hitboxes of attacking upwards
		if (animated_sprite.frame >= 4 and animated_sprite.frame < 6):
			upHitbox1.set_deferred("disabled", false)
		else:
			upHitbox1.set_deferred("disabled", true)
		if (animated_sprite.frame >= 6 and animated_sprite.frame < 8):
			upHitbox2.set_deferred("disabled", false)
		else:
			upHitbox2.set_deferred("disabled", true)
		if (animated_sprite.frame >= 8 and animated_sprite.frame < 10):
			upHitbox3.set_deferred("disabled", false)
		else:
			upHitbox3.set_deferred("disabled", true)
	if (animated_sprite.animation == "upAttack" and animated_sprite.frame == 12): # Ends upwards attack
		attackUP = false
		attacking = false
		
	if (attackCROUCH):
		if (animated_sprite.frame >= 6 and animated_sprite.frame < 10):
			crouchHitbox1.set_deferred("disabled", false)
		else:
			crouchHitbox1.set_deferred("disabled", true)
	if (animated_sprite.animation == "crouchAttack" and animated_sprite.frame == 10):
		attackCROUCH = false
		attacking = false
		
	if (attackDOWN):
		if (animated_sprite.frame >= 7 and animated_sprite.frame < 9):
			downHitbox1.set_deferred("disabled", false)
		else:
			downHitbox1.set_deferred("disabled", true)
		if (animated_sprite.frame >= 9 and animated_sprite.frame < 10):
			downHitbox2.set_deferred("disabled", false)
		else:
			downHitbox2.set_deferred("disabled", true)
		if (animated_sprite.frame >= 10 and animated_sprite.frame < 12):
			downHitbox3.set_deferred("disabled", false)
		else:
			downHitbox3.set_deferred("disabled", true)
		if (animated_sprite.frame >= 12 and animated_sprite.frame < 14):
			downHitbox4.set_deferred("disabled", false)
		else:
			downHitbox4.set_deferred("disabled", true)
	if (animated_sprite.animation == "downAttack" and animated_sprite.frame == 14):
		attackDOWN = false
		attacking = false
		
	if (attackSIDE): # Handles the hitbox of attacking to the side
		if (animated_sprite.frame >= 4 and animated_sprite.frame < 10):
			sideHitbox1.set_deferred("disabled", false)
		else:
			sideHitbox1.set_deferred("disabled", true)
	if (animated_sprite.animation == "sideAttack" and animated_sprite.frame == 10):
		attackSIDE = false
		attacking = false

#return to menu from death screen
func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

#return to checkpoint from death screen
func _on_button_2_pressed() -> void:
	get_tree().paused = false
	load_game()
	


#resets all variables to default values and loads back from save file
func load_game():
	direction = 0
	numDashes = maxDash
	dashTimer = 0
	counter = 0
	dashCool = false
	dashed = false
	dashing = false
	wasDashing = false
	numJumps = maxJumps
	played = false
	squished = false
	cancelled = false
	grappling = false
	attackUP = false
	attackSIDE = false
	attackDOWN = false
	attackCROUCH = false
	attacking = false
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
			#position = Vector2(node_data["pos_x"], node_data["pos_y"])
			for i in reset.size():
				var path = NodePath("Pickups/" + reset[i])
				get_parent().get_node(path).anim.visible = true
				get_parent().get_node(path).coll.disabled = false
			for i in node_data.keys():
				if i == "filename":
					if (node_data[i] != get_parent().get_scene_file_path()):
						var save_file2 = FileAccess.open("res://loadFlag.save", FileAccess.WRITE)
						var node_data2 = "1"
						save_file2.store_line(node_data2)
						get_tree().change_scene_to_file(node_data[i])
						break
				elif i == "pos_x":
					position.x = node_data[i]
				elif i == "pos_y":
					position.y = node_data[i]
				elif i == "parent":
					continue
				elif i == "rem":
					permaUpgrades = node_data[i]
					for j in node_data[i].size():
						print(node_data[i][j])
						#print($Game)
						print(get_tree().get_root())
						var temp = get_parent().get_node(NodePath("Pickups/" + str(node_data[i][j])))
						if (temp != null):
							temp.queue_free()
						#get_tree().get_root().remove_child(find_child(node_data[i][j]))
					continue
						
				elif i == "selectedHat":
					selectedHat = int(node_data[i])
					continue
				set(i, node_data[i])

#loads player hats into array and displays saved selected hat
func loadHats():
	hats.clear()
	if not FileAccess.file_exists("res://hats.save"):
		return
	else:
		var save_file = FileAccess.open("res://hats.save", FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			var node_data = json.data
			for i in node_data.keys():
				if i == "hats":
					for j in node_data[i].size():
						hats.append(node_data[i][j])
	if(hats[selectedHat%hats.size()] != "none"):
		$Hat.set_texture(load(hats[selectedHat%hats.size()]))
		if (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-10.png"):
			$Hat.position.y = -32
			$Hat.scale = Vector2(.4, .4)
			$PausePreview/Hat.scale = Vector2(.4, .4)
			$PausePreview/Hat.position.y = -18
		elif (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-7.png"):
			$Hat.position.y = -29
			$PausePreview/Hat.position.y = -16
		else:
			$Hat.scale = Vector2(1, 1)
			$PausePreview/Hat.scale = Vector2(1, 1)
			$PausePreview/Hat.position.y = -20
			$Hat.position.y = -35
	else:
		$Hat.visible = false
		$PausePreview/Hat.visible = false

#handles player physics looping every frame
func _physics_process(delta: float) -> void:
	#dash animation tracking
	wasDashing = dashing
	
	#dash unlocked/double jump unlocked pop up
	if (dJump and maxJumps == 1):
		$Labels/DJump.visible = true
		dJump = false
		await get_tree().create_timer(2).timeout
		$Labels/DJump.visible = false
	if (uDash and maxDash == 1):
		$Labels/uDash.visible = true
		uDash = false
		await get_tree().create_timer(2).timeout
		$Labels/uDash.visible = false
	
	#player death handling
	if (hp <= 0):
		label.visible = true
		exit.visible = true
		exit.disabled = false
		button2.visible = true
		button2.disabled = false
		get_tree().paused = true
		acceleration = 0
		animated_sprite.play("idle")
	
	#determines player inputs
	direction = Input.get_axis("left", "right") #-1 = left, 1 = right
	var direction_y := Input.get_axis("up", "down") #-1 = up, 1 = down
	
	#forces to be either -1 or 1 for dir
	if (animated_sprite.flip_h):
		dir = -1
	else:
		dir = 1
	moveHitboxes() # Make sure hitboxes are in the right spot
	attackHit() # Activate and deactivate hitboxes as needed
	
	#player dash input
	if Input.is_action_just_pressed("dash") and $Timers/DashCool.is_stopped() and numDashes != 0:
		dash()
	
	#player took knockback
	if (knockback != 0 and not grappling):
		velocity.x += knockbackDir * knockback
		velocity.y += knockback * -1
		move_and_slide()
		knockback = 0
		cancelled = true
	
	#no knockback if grappling
	else:
		knockback = 0
	
	#pause menu appears
	if (Input.is_action_just_pressed("pause")):
		get_tree().paused = true
		$Buttons/Menu.visible = true
		$Buttons/Menu.disabled = false
		$Buttons/Reset.visible = true
		$Buttons/Reset.disabled = false
		$Buttons/Resume.visible = true
		$Buttons/Resume.disabled = false
		$Buttons/Right.visible = true
		$Buttons/Right.disabled = false
		$Buttons/Left.visible = true
		$Buttons/Left.disabled = false
		$PausePreview.visible = true
		
		#hat selection position adjustment
		if (hats[selectedHat%hats.size()] != "none"):
			$PausePreview/Hat.visible = true
			$PausePreview/Hat.set_texture(load(hats[selectedHat%hats.size()]))
			if (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-10.png"):
				$Hat.position.y = -32
				$Hat.scale = Vector2(.4, .4)
				$PausePreview/Hat.scale = Vector2(.4, .4)
				$PausePreview/Hat.position.y = -18
			elif (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-7.png"):
				$Hat.position.y = -29
				$PausePreview/Hat.position.y = -16
			else:
				$Hat.scale = Vector2(1, 1)
				$PausePreview/Hat.scale = Vector2(1, 1)
				$PausePreview/Hat.position.y = -20
				$Hat.position.y = -35
		else:
			$PausePreview/Hat.visible = false
		$Labels/Pause.visible = true
	
	#attack handling
	if not grappling:
		doGravity(delta)
		if (Input.is_action_just_pressed("attack")):
			attack()
	
	#allows for momentum to be stored if player holds no direction keys while moving
	if cancelled and is_on_floor():
		cancelled = false
	
	#while dashing, gravity doesnt affect the player
	if !$Timers/DashTimer.is_stopped():
		velocity.y = 0
	else:
		played = false
		dashing = false
	
	#resets hat position to pre dashing state
	if (not dashing and wasDashing):
		velocity.x = SPEED * direction
		wasDashing = false
		if (dir == 1):
			$Hat.position.x = 2
		else:
			$Hat.position.x = -4
	
	#stores last safe position in case player falls off the map or hits a spike
	if (is_on_floor()):
		lastSafePos.x = position.x - 5*direction
		lastSafePos.y = position.y - 13
	
	#resets dahes and jumps if player is on ground
	if (is_on_floor() or (is_on_wall() and grappling)):
		numJumps = maxJumps
		numDashes = maxDash
	
	#ends grapple
	if (is_on_floor() and grappling):
		endGrapple.emit("ground")
	
	# Handle jump
	jump()
	
	if not grappling:
		#flips sprite and hat
		if direction == 1:
			animated_sprite.flip_h = false
			if(not dashing):
				$Hat.position.x = 2
				$Hat.flip_h = false
		elif direction == -1:
			animated_sprite.flip_h = true
			if(not dashing):
				$Hat.position.x = -4
				$Hat.flip_h = true
	
		#parses user input to determine which action needs to be played
		#crouch/slide begin
		if direction_y == 1:
			slideSquish()
	
		#crouch end animation
		elif squished == true and $Timers/KnockbackTimer.is_stopped():
			unsquish()
	
		#run/dash begin
		else:
			#running acceleration (works in air)
			runAccel()
		
		#dash/run animation handling on floor and in the air
		animationParser()
	if (not dashing):
		set_collision_layer_value(4, true)
	move_and_slide()

#loads menu from pause screen
func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")



#resets to last checkpoint from pause screen
func _on_reset_pressed() -> void:
	get_tree().paused = false
	$Buttons/Menu.visible = false
	$Buttons/Menu.disabled = true
	$Buttons/Reset.visible = false
	$Buttons/Reset.disabled = true
	$Buttons/Resume.visible = false
	$Buttons/Resume.disabled = true
	$Buttons/Right.visible = false
	$Buttons/Right.disabled = true
	$Buttons/Left.visible = false
	$Buttons/Left.disabled = true
	$PausePreview.visible = false
	$PausePreview/Hat.visible = true
	$Labels/Pause.visible = false
	load_game()

#resumes from pause screen
func _on_resume_pressed() -> void:
	$Buttons/Menu.visible = false
	$Buttons/Menu.disabled = true
	$Buttons/Reset.visible = false
	$Buttons/Reset.disabled = true
	$Buttons/Resume.visible = false
	$Buttons/Resume.disabled = true
	$Buttons/Right.visible = false
	$Buttons/Right.disabled = true
	$Buttons/Left.visible = false
	$Buttons/Left.disabled = true
	$PausePreview.visible = false
	$PausePreview/Hat.visible = true
	$Labels/Pause.visible = false
	get_tree().paused = false


#player hits enemy
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	body.hp -= attackPower
	body.incomingKnockback = outgoingKnockback
	body.knockbackDir = dir
	body.damaged = true

#spike hit (layer 6)
func _on_area_2d_body_entered(_body: Node2D) -> void:
	set_position(lastSafePos)
	velocity = Vector2.ZERO
	hp -= 25

#hat selection from pause menu, increment up
func _on_right_pressed() -> void:
	selectedHat += 1
	if (hats[selectedHat%hats.size()] != "none"):
		$PausePreview/Hat.visible = true
		$PausePreview/Hat.set_texture(load(hats[selectedHat%hats.size()]))
		if (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-10.png"):
			$Hat.position.y = -32
			$Hat.scale = Vector2(.4, .4)
			$PausePreview/Hat.scale = Vector2(.4, .4)
			$PausePreview/Hat.position.y = -18
		elif (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-7.png"):
			$Hat.position.y = -29
			$PausePreview/Hat.position.y = -16
		else:
			$Hat.scale = Vector2(1, 1)
			$PausePreview/Hat.scale = Vector2(1, 1)
			$PausePreview/Hat.position.y = -20
			$Hat.position.y = -35
		$Hat.set_texture(load(hats[selectedHat%hats.size()]))
		$Hat.visible = true
	else:
		$PausePreview/Hat.visible = false
		$Hat.visible = false

#hat selection from pause menu, increment down
func _on_left_pressed() -> void:
	selectedHat -= 1
	if (hats[selectedHat%hats.size()] != "none"):
		$PausePreview/Hat.visible = true
		$PausePreview/Hat.set_texture(load(hats[selectedHat%hats.size()]))
		$Hat.set_texture(load(hats[selectedHat%hats.size()]))
		if (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-10.png"):
			$Hat.position.y = -32
			$Hat.scale = Vector2(.4, .4)
			$PausePreview/Hat.scale = Vector2(.4, .4)
			$PausePreview/Hat.position.y = -18
		elif (hats[selectedHat%hats.size()] == "res://assets/Lila/Hat-7.png"):
			$Hat.position.y = -29
			$PausePreview/Hat.position.y = -16
		else:
			$Hat.scale = Vector2(1, 1)
			$PausePreview/Hat.scale = Vector2(1, 1)
			$PausePreview/Hat.position.y = -20
			$Hat.position.y = -35
		$Hat.visible = true
	else:
		$PausePreview/Hat.visible = false
		$Hat.visible = false
