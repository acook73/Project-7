extends Node2D
@onready var grappleRay := $GrappleRay
@onready var grappleLine := $Line2D
@onready var stopMomentum := $stopMomentum
@onready var player := get_parent()
@onready var game := player.get_parent()

@export var grappleSpeed = 1000.0
@export var freezeTime = 0.1
@export var wallSlackRoom = 10.0
@export var ceilingSlackRoom = 25.0
@export var floorSlackRoom = 18.0
@export var swingLength = 200.0
@export var swingForce = 100.0
@export var minLength = 5.0

# Used to communicate with player script
signal grappleSignal(isGrappling)

var grappling = false
var grapplePoint;
var hasLeftGround = 0

# Connect with player
func _ready():
	grappleSignal.connect(player.isGrappling)
	stopMomentum.wait_time = freezeTime

func _physics_process(delta: float) -> void:
	
	# Set the ray to look at the mouse, then grapple if needed
	grappleRay.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("grapple"):
		launch()

	if Input.is_action_just_released("grapple"):
		retract()
		
	if grappling:
		grapple(delta)
	
	if not player.is_on_floor():
		hasLeftGround = 0
	else:
		hasLeftGround += 1

# Launches the grapple
func launch():
	if grappleRay.is_colliding():
		if grappleRay.get_collider().name == "Grapple Layer": # INteract with tiles
			grappling = true
			grapplePoint = grappleRay.get_collision_point()
			grappleLine.show()
			grappleSignal.emit(true)
			stopMomentum.start()
		elif "collision_layer" in grappleRay.get_collider(): # Interact with area2Ds
			if (grappleRay.get_collider().collision_layer & (1 << 1)):
				grappling = true
				grapplePoint = grappleRay.get_collision_point()
				grappleLine.show()
				grappleSignal.emit(true)
				stopMomentum.start()

	
func retract(): # Stop grappling
	grappling = false
	grappleSignal.emit(false)
	grappleLine.hide()
	grappleLine.set_point_position(1, Vector2(0, 0))
	
	
func endGrappleEarly(data): # Used by both th eplayer script and this script
	if data == "wall" or (data == "ground" and hasLeftGround <= 10):
		retract()

func grapple(delta): # Actually calculate the velocity needed while grappling
	if not stopMomentum.is_stopped():
		player.velocity = Vector2.ZERO
	else:
		var dir = global_position.direction_to(grapplePoint)
		var dist = global_position.distance_to(grapplePoint)

		var force = dir.normalized() * grappleSpeed

		if (player.is_on_wall() and wallSlackRoom > dist) or (player.is_on_ceiling() and ceilingSlackRoom > dist) or (player.is_on_floor() and floorSlackRoom > dist) or (dist < minLength):
			player.velocity = Vector2.ZERO
		else:
			player.velocity += force * delta
		
		updateRope()

func updateRope(): # Shorten the rope as needed
	grappleLine.set_point_position(1, to_local(grapplePoint))
