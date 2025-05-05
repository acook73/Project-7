extends Node2D
@onready var anim = $Sprite2D
@onready var coll = $Area2D/CollisionShape2D
@export var filename: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (filename):
		$Sprite2D.set_texture(load(filename))


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		body.selectedHat = body.selectedHat % body.hats.size()
		body.hats.append(filename)
		body.reset.append(self.name)
		body.permaUpgrades.append(self.name)
		$Sprite2D.visible = false
		$Area2D/CollisionShape2D.set_deferred("disabled", true) 
