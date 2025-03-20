extends Node2D
@onready var grappleRay := $GrappleRay
@onready var grappleLine := $Line2D
@onready var stopMomentum := $stopMomentum
@onready var player := get_parent()

@export var grappleSpeed = 100.0
@export var freezeTime = 0.1
@export var slackRoom = 2.0


signal grappleSignal(isGrappling)

var grappling = false
var grapplePoint;

func _ready():
	grappleSignal.connect(player.isGrappling)
	stopMomentum.wait_time = freezeTime

func _physics_process(delta: float) -> void:
	
	grappleRay.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("grapple"):
		launch()

	if Input.is_action_just_released("grapple"):
		retract()
		
	if grappling:
		grapple(delta)
		
func launch():
	if grappleRay.is_colliding():
		grappling = true
		grapplePoint = grappleRay.get_collision_point()
		grappleLine.show()
		grappleSignal.emit(true)
		stopMomentum.start()
	
func retract():
	grappling = false
	grappleLine.hide()
	grappleSignal.emit(false)
	grappleLine.set_point_position(1, Vector2(0, 0))
	
	
func endGrappleEarly(data):
	if data:
		retract()

func grapple(delta):
	if not stopMomentum.is_stopped():
		player.velocity = Vector2.ZERO
	else:
		var dir = player.global_position.direction_to(grapplePoint)
		var dist = player.global_position.distance_to(grapplePoint)

		var force = dir.normalized() * grappleSpeed

		if (player.is_on_wall() and slackRoom > dist) or (player.is_on_ceiling() and slackRoom > dist) or (player.is_on_floor() and slackRoom > dist):
			player.velocity = Vector2.ZERO
		else:
			player.velocity += force * delta
		
		updateRope()
	
func updateRope():
	grappleLine.set_point_position(1, to_local(grapplePoint))
