extends CharacterBody2D

@onready var animatedSprite := $TreantSprite
@onready var treantHitbox := $Hitbox
@onready var attackTimer := $attackTimer

# Hitboxes
@onready var verticalHitbox1 := $Roots/RootHitboxes/VerticalRoot1Hitbox
@onready var verticalHitbox2 := $Roots/RootHitboxes/VerticalRoot2Hitbox
@onready var verticalHitbox3 := $Roots/RootHitboxes/VerticalRoot3Hitbox
@onready var verticalHitbox4 := $Roots/RootHitboxes/VerticalRoot4Hitbox
@onready var verticalHitbox5 := $Roots/RootHitboxes/VerticalRoot5Hitbox
@onready var verticalHitbox6 := $Roots/RootHitboxes/VerticalRoot6Hitbox
@onready var verticalHitbox7 := $Roots/RootHitboxes/VerticalRoot7Hitbox
@onready var verticalHitbox8 := $Roots/RootHitboxes/VerticalRoot8Hitbox
@onready var verticalHitbox9 := $Roots/RootHitboxes/VerticalRoot9Hitbox
@onready var verticalHitbox10 := $Roots/RootHitboxes/VerticalRoot10Hitbox
@onready var lowHitbox := $Roots/RootHitboxes/LowHorizontalHitbox
@onready var midHitbox := $Roots/RootHitboxes/MidHorizontalHitbox

# Animators
@onready var verticalRoot1 := $Roots/RootHitboxes/VerticalRoot1Hitbox/VerticalRoot1
@onready var verticalRoot2 := $Roots/RootHitboxes/VerticalRoot2Hitbox/VerticalRoot2
@onready var verticalRoot3 := $Roots/RootHitboxes/VerticalRoot3Hitbox/VerticalRoot3
@onready var verticalRoot4 := $Roots/RootHitboxes/VerticalRoot4Hitbox/VerticalRoot4
@onready var verticalRoot5 := $Roots/RootHitboxes/VerticalRoot5Hitbox/VerticalRoot5
@onready var verticalRoot6 := $Roots/RootHitboxes/VerticalRoot6Hitbox/VerticalRoot6
@onready var verticalRoot7 := $Roots/RootHitboxes/VerticalRoot7Hitbox/VerticalRoot7
@onready var verticalRoot8 := $Roots/RootHitboxes/VerticalRoot8Hitbox/VerticalRoot8
@onready var verticalRoot9 := $Roots/RootHitboxes/VerticalRoot9Hitbox/VerticalRoot9
@onready var verticalRoot10 := $Roots/RootHitboxes/VerticalRoot10Hitbox/VerticalRoot10
@onready var horizontalRoot := $Roots/Horizontal/HorizontalRoot

@export var LOOPS_NEEDED_HORIZONTAL = 5
@export var LOOPS_NEEDED_VERTICAL = 5
@export var LOOPS_BEFORE_NEXT_VERTICAL = 2

var incomingKnockback
var attackCount = 0
var prevAttack
var currentAttack
var attacking = false
var attackEnded = true
var verticalCount = 0
var loop = 0
var verticalLoops = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var verticalHitboxes
var verticalComplete = 0
var hp = 4000
func _ready():
	animatedSprite.animation = "idle"
	attackTimer.start()
	verticalHitboxes = [verticalHitbox1, verticalHitbox2, verticalHitbox3, verticalHitbox4,
						verticalHitbox5, verticalHitbox6, verticalHitbox7, verticalHitbox8,
						verticalHitbox9, verticalHitbox10]

func attackChooser():
	attackCount += 1
	attackEnded = false
	loop = 0
	attacking = true
	
	if (attackCount == 6):
		attackCount = 0
		currentAttack = 4
		print("Rock")
	else:
		var choiche = randi_range(0, 3)
		if (choiche == 0 and prevAttack != 0):
			print ("low")
			currentAttack = 0
			horizontalRoot.visible = true
			horizontalRoot.animation = "lowRootPrepare"
			horizontalRoot.play()
			
		elif (choiche == 1 and prevAttack != 1):
			print ("mid")
			currentAttack = 1
			horizontalRoot.visible = true
			horizontalRoot.animation = "midRootPrepare"
			horizontalRoot.play()
			
		elif (choiche == 2 and prevAttack != 2):
			print ("vertical")
			currentAttack = 2
			verticalHitboxes.shuffle()
			verticalHitboxes[0].get_child(0).visible = true
			verticalHitboxes[0].get_child(0).animation = "verticalRootPrepare"
			verticalHitboxes[0].get_child(0).play()
			verticalCount = 1
			verticalComplete = 0
			
			
		elif (choiche == 3 and prevAttack != 3):
			print ("magic")
			currentAttack = 3
			animatedSprite.animation = "magicCharge"
			animatedSprite.play()
	
func attackManager():
	if (currentAttack == 0): # Low Root Attack
		if (horizontalRoot.animation == "lowRootPrepare" and horizontalRoot.frame == 5):
			horizontalRoot.animation = "lowRootLoop"
		if (horizontalRoot.animation == "lowRootLoop" and horizontalRoot.frame == 4):
			loop += 1
			if (loop == LOOPS_NEEDED_HORIZONTAL):
				horizontalRoot.animation = "lowRootAttack"
		if (horizontalRoot.animation == "lowRootAttack"):
			if (horizontalRoot.frame >= 4 and horizontalRoot.frame <= 6):
				lowHitbox.set_deferred("disabled", false)
			elif (horizontalRoot.frame == 7):
				lowHitbox.set_deferred("disabled", true)
			elif (horizontalRoot.frame == 9):
				horizontalRoot.visible = false
				attacking = false
				prevAttack = 0
				attackEnded = true
				
	elif (currentAttack == 1): # Mid Root Attack
		if (horizontalRoot.animation == "midRootPrepare" and horizontalRoot.frame == 5):
			horizontalRoot.animation = "midRootLoop"
		if (horizontalRoot.animation == "midRootLoop" and horizontalRoot.frame == 4):
			loop += 1
			if (loop == LOOPS_NEEDED_HORIZONTAL):
				horizontalRoot.animation = "midRootAttack"
		if (horizontalRoot.animation == "midRootAttack"):
			if (horizontalRoot.frame >= 4 and horizontalRoot.frame <= 6):
				midHitbox.set_deferred("disabled", false)
			elif (horizontalRoot.frame == 7):
				midHitbox.set_deferred("disabled", true)
			elif (horizontalRoot.frame == 9):
				horizontalRoot.visible = false
				attacking = false
				prevAttack = 1
				attackEnded = true
	
	
	elif (currentAttack == 2): # Vertical Root Attack
		
		for i in verticalCount:
			if (not i < verticalComplete):
				if (verticalHitboxes[i].get_child(0).animation == "verticalRootPrepare" and verticalHitboxes[i].get_child(0).frame == 1):
					verticalHitboxes[i].get_child(0).animation = "verticalRootLoop"
				elif (verticalHitboxes[i].get_child(0).animation == "verticalRootLoop" and verticalHitboxes[i].get_child(0).frame == 5):
					verticalLoops[i] += 1
					if (verticalLoops[i] == LOOPS_BEFORE_NEXT_VERTICAL):
						if (verticalCount != 10):
							verticalHitboxes[verticalCount].get_child(0).visible = true
							verticalHitboxes[verticalCount].get_child(0).animation = "verticalRootPrepare"
							verticalHitboxes[verticalCount].get_child(0).play()
							verticalCount += 1
					elif (verticalLoops[i] == LOOPS_NEEDED_VERTICAL):
						verticalHitboxes[i].get_child(0).animation = "verticalRootAttack"
				elif (verticalHitboxes[i].get_child(0).animation == "verticalRootAttack"):
					if (verticalHitboxes[i].get_child(0).frame >= 2 and verticalHitboxes[i].get_child(0).frame <= 4):
						verticalHitboxes[i].set_deferred("disabled", false)
					elif (verticalHitboxes[i].get_child(0).frame == 7):
						verticalHitboxes[i].set_deferred("disabled", true)
						verticalHitboxes[i].get_child(0).visible = false
						verticalComplete += 1
						print(i)
		
		if (verticalComplete == 10):
			attacking = false
			prevAttack = 2
			attackEnded = true
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	elif (currentAttack == 3): # Magic Projectile Attack
		if (animatedSprite.frame == 10):
			# Spawn Magic Projectile Here
			attacking = false
			prevAttack = 3
			attackEnded = true
			animatedSprite.animation = "idle"
			print("hi")
	
	elif (currentAttack == 4): # Rock Throw Attack
		attacking = false
		prevAttack = 4
		attackEnded = true

func _physics_process(delta: float) -> void:
	if (attackEnded == true and attackTimer.is_stopped()):
		attackTimer.start()
		
	if (attacking):
		attackManager()

func _on_attack_timer_timeout() -> void:
	attackChooser()
