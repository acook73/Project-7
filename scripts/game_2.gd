#main level
extends Node2D
var first = true

#handles health bar and resets the boss to full health if player dies
func _physics_process(_delta: float) -> void:
	if ($Player/Camera2D2.is_current()):
		$Player/Camera2D2/TextureProgressBar.max_value = $Player.hp_max
		$Player/Camera2D2/TextureProgressBar.value = $Player.hp
		$TextureProgressBar2.visible = false
		$Player/Camera2D2/TextureProgressBar.visible = true
	else:
		if (first):
			first = false
			$AudioStreamPlayer.get_stream_playback().switch_to_clip(1)
			await get_tree().create_timer(7.33).timeout
			$AudioStreamPlayer.get_stream_playback().switch_to_clip(2)
		$TextureProgressBar2.max_value = $Player.hp_max
		$TextureProgressBar2.value = $Player.hp
		$Player/Camera2D2/TextureProgressBar.visible = false
		$TextureProgressBar2.visible = true
	if ($Player.hp <= 0):
		$Enemies/Treant.hp = 4000

#in case player manages to fall off the map
func _on_teleport_barrier_body_entered(body: Node2D) -> void:
	body.set_position(body.lastSafePos)
	body.hp -= 10


func _on_win_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		$Win/WinLabel.visible = true
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		
