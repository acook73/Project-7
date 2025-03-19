extends AnimatedSprite2D

var mousePos
var player
signal dataSent(data)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	dataSent.connect(player.grapple)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func send_data(data):
	dataSent.emit(data)

func _process(delta: float) -> void:
	mousePos = get_global_mouse_position()
	position = mousePos
	
	if Input.is_action_just_pressed("grapple"):
		send_data(mousePos)
		
		
		
		print("WASSUP")
		
