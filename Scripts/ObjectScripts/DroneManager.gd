extends Node2D

func between(a, b):
	return b - ((b - a) / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var player = get_parent().get_node("Player").get_node("Player")
	
	var direction_to_player_reversed = (player.position - (position + $DroneHinge2.points[0])).normalized()
	var direction_to_player_radians = -atan2(direction_to_player_reversed.x, direction_to_player_reversed.y)# - (1.0/2.0 * PI)
	var direction_to_player = Vector2(sin(direction_to_player_radians), cos(direction_to_player_radians))
	
	$DroneHinge2.points[1] = $DroneHinge2.points[0] + direction_to_player
	$DroneHinge3.points[0] = $DroneHinge2.points[1]
	$DroneHinge3.points[1] = $DroneHinge3.points[0] + direction_to_player_reversed * 1
	$DroneTurret1.rotation = direction_to_player_radians
	$DroneTurret1.position = $DroneHinge3.points[1]
