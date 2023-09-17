extends Node2D

func _process(delta):
	# Camera follows player.
	$Camera.position += ($Player.position - $Camera.position) * 0.1
	
	var player_vel = 0
	
	# Camera zooms out as player moves faster.
	if $Camera.zoom.x > 1:
		player_vel = (1 - abs($Player.velocity.x) / 20) + 1
	else:
		player_vel = 1.00001
		
	$Camera.zoom += (Vector2(player_vel, player_vel) - $Camera.zoom) * 0.05
	
	if $Camera.zoom.x < 1:
		$Camera.zoom = Vector2(1, 1)
