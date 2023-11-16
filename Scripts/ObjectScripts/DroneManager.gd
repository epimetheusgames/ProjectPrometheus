extends Node2D

var current_line_point = 0

func between(a, b):
	return b - ((b - a) / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var player = get_parent().get_node("Player").get_node("Player")
	
	var direction_to_player_reversed = (player.position - (position + $DroneTurret1.position)).normalized()
	var direction_to_player_radians = -atan2(direction_to_player_reversed.x, direction_to_player_reversed.y)# - (1.0/2.0 * PI)
	$DroneTurret1.rotation = direction_to_player_radians
