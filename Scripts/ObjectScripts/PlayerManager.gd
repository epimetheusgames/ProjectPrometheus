extends Node2D

var target_zoom = Vector2.ZERO

func _process(delta):
	# Camera follows player.
	$Camera.position += ($Player.position - $Camera.position) * 0.2
	
	var player_vel = 0
