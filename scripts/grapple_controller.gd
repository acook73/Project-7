extends Node2D
@onready var grappleRay := $GrappleRay
@onready var grappleLine := $Line2D
@onready var stopMomentum := $stopMomentum
@onready var player := get_parent()

@export var grappleSpeed = 1000.0
@export var freezeTime = 0.1
@export var wallSlackRoom = 10.0
@export var ceilingSlackRoom = 25.0
@export var floorSlackRoom = 18.0
@export var swingLength = 200.0
@export var swingForce = 100.0


signal grappleSignal(isGrappling)

var grappling = false
var grapplePoint;
var hasLeftGround = 0

func _ready():
	grappleSignal.connect(player.isGrappling)
	stopMomentum.wait_time = freezeTime

func _physics_process(delta: float) -> void:
	
	grappleRay.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("grapple"):
		launch("grapple")

	if Input.is_action_just_released("grapple"):
		retract()
		
	if grappling:
		grapple(delta)
	
	if not player.is_on_floor():
		hasLeftGround = 0
	else:
		hasLeftGround += 1
		
func launch(type):
	if grappleRay.is_colliding():
		grappling = true
		grapplePoint = grappleRay.get_collision_point()
		grappleLine.show()
		grappleSignal.emit(true)
		stopMomentum.start()

	
func retract():
	grappling = false
	grappleSignal.emit(false)
	grappleLine.hide()
	grappleLine.set_point_position(1, Vector2(0, 0))
	
	
func endGrappleEarly(data):
	if data == "wall" or (data == "ground" and hasLeftGround <= 10):
		retract()

func grapple(delta):
	if not stopMomentum.is_stopped():
		player.velocity = Vector2.ZERO
	else:
		var dir = global_position.direction_to(grapplePoint)
		var dist = global_position.distance_to(grapplePoint)

		var force = dir.normalized() * grappleSpeed

		if (player.is_on_wall() and wallSlackRoom > dist) or (player.is_on_ceiling() and ceilingSlackRoom > dist) or (player.is_on_floor() and floorSlackRoom > dist):
			player.velocity = Vector2.ZERO
		else:
			player.velocity += force * delta
		
		updateRope()

func updateRope():
	grappleLine.set_point_position(1, to_local(grapplePoint))
