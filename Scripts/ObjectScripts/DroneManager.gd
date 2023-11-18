extends Node2D

var current_line_point = 0
var movement_velocity = Vector2.ZERO
var rapid_bullet_num = 0

@onready var loaded_bullet = preload("res://Objects/StaticObjects/DroneBullet.tscn")
@export var velocity_smoothing = 0.01

func smooth(a, b, smoothing):
	return (a + ((b - a) * smoothing))

func _process(delta):
	var player = get_parent().get_node("Player").get_node("Player")
	
	var direction_to_player = (player.position - (position + $Drone.position)).normalized()
	var direction_to_player_radians = -atan2(direction_to_player.x, direction_to_player.y)
	$Drone/DroneTurret1.rotation = direction_to_player_radians - $Drone.rotation
	
	var direction_to_next_point = ($DronePatrolPoints.points[current_line_point] - $Drone.position).normalized() * delta * 60

	movement_velocity = Vector2(smooth(movement_velocity.x, direction_to_next_point.x, velocity_smoothing * 1.5),
								smooth(movement_velocity.y, direction_to_next_point.y / 1.5, velocity_smoothing))
	
	$Drone.position += movement_velocity
	$Drone.rotation = movement_velocity.x / 3
	
	if $Drone.position.distance_to($DronePatrolPoints.points[current_line_point]) < 30:
		if current_line_point < $DronePatrolPoints.points.size() - 1:
			current_line_point += 1
			
			if current_line_point == 1:
				var new_drone = duplicate()
				new_drone.get_node("Drone").position = Vector2.ZERO
				get_parent().add_child(new_drone)
		else:
			queue_free()
	
	if player.current_ability == "Weapon" && $RapidBulletCooldown.is_stopped() && $BulletCooldown.is_stopped():
		$BulletCooldown.start()
		
func _on_bullet_cooldown_timeout():
	var player = get_parent().get_node("Player").get_node("Player")
	if player.current_ability == "Weapon":
		$RapidBulletCooldown.start()

func _on_rapid_bullet_cooldown_timeout():
	var player = get_parent().get_node("Player").get_node("Player")
	
	if player.current_ability == "Weapon" && ($Drone.position + position).distance_to(player.position) < 200:
		var direction_to_player = (player.position - (position + $Drone.position)).normalized()

		if rapid_bullet_num < 2:
			rapid_bullet_num += 1
			$RapidBulletCooldown.start()
		else:
			rapid_bullet_num = 0
			$BulletCooldown.start()
			
		var bullet_to_add = loaded_bullet.instantiate()
		bullet_to_add.position = position + $Drone.position
		bullet_to_add.velocity = direction_to_player * 5
		get_parent().add_child(bullet_to_add)
