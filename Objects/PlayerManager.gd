extends Node2D

func _process(delta):
	$Camera.position += ($Player.position - $Camera.position) * 0.1
	
	var player_vel = 0
	
	if $Camera.zoom.x > 0.75:
		player_vel = 1 - abs($Player.velocity.x) / 50
	else:
		player_vel = 0.75
	$Camera.zoom = Vector2(player_vel, player_vel)
	print($Camera.zoom)
