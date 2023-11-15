extends Node2D

var target_zoom = Vector2.ZERO

func _process(delta):
	# Camera follows player.
	$Camera/CameraCollider.position += ($Player.position - $Camera/CameraCollider.position) * 0.05
	$Camera.position += ($Camera/CameraCollider.position - $Camera.position) * 0.1
	
	var player_vel = 0
