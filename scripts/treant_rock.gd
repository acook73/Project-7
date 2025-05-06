extends CharacterBody2D


var player = null
var first = true
@export var velocityY = -500
@export var attackPower = 40
@export var knockback = 250
func doGravity(delta: float):
	if not is_on_floor():
		var temp = get_gravity() * delta
		velocity += temp

#func _ready():
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	doGravity(delta)
	if player != null and first:
		var temp = (-1*velocityY - sqrt(pow(velocityY, 2) - ((4*(position.y-player.position.y))*.5*get_gravity().y)))/(2*(position.y-player.position.y))
		temp = -1*(position.x-player.position.x)/abs(2*temp)
		print(temp)
		velocity.x = temp
		velocity.y = velocityY
		first = false
	if is_on_floor():
		velocity.x = 0
		$Sprite2D.visible = false
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play("default")
		await get_tree().create_timer(0.5).timeout
		queue_free()
		
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		body.hp -= attackPower
		body.knockback = knockback
		body.knockbackDir = -1


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		player = body
