extends Node2D

var current_line_point = 0
var movement_velocity = Vector2.ZERO
var rapid_bullet_num = 0
var player_previous_ability = ""
var can_play_target_lost = false

@onready var loaded_bullet = preload("res://Objects/StaticObjects/DroneBullet.tscn")
@onready var loaded_physics_drone = preload("res://Objects/StaticObjects/PhysicsDrone.tscn")
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

	$Drone/PlayerRaycast.target_position = player.position - position - $Drone.position
	$AttackLine.points[0] = $Drone.position
	var player_cast = $Drone/PlayerRaycast.get_collider()
	if (player.current_ability == "Weapon" || player.current_ability == "ArmGun") && ($Drone.position + position).distance_to(player.position) < 200:
		if $TargetFoundTimer.time_left == 0:
			$TargetFoundTimer.start()
		
		if (player_previous_ability != "Weapon" && player_previous_ability != "ArmGun" &&
			$WeaponDetected.playing == false && $TargetLost.playing == false &&
			$TargetFoundCooldown.time_left == 0):
			$WeaponDetected.play()
		
		if player_cast == null || player_cast.name == "Player":
			$AttackLine.visible = true
			$AttackLine.points[1] = (player.position - position)
		else:
			$AttackLine.points[1] = ($Drone/PlayerRaycast.get_collision_point() - position)
		
		player_previous_ability = player.current_ability
	else:
		if (player_previous_ability == "Weapon" || player_previous_ability == "ArmGun"):
			$TargetFoundCooldown.start()
			
			if can_play_target_lost:
				can_play_target_lost = false
				$TargetLost.play()
		
		$AttackLine.visible = false
		player_previous_ability = "NoDistance"
	
	if (player.current_ability == "Weapon" || player.current_ability == "ArmGun") && $RapidBulletCooldown.is_stopped() && $BulletCooldown.is_stopped():
		$BulletCooldown.start()
		
func _on_bullet_cooldown_timeout():
	var player = get_parent().get_node("Player").get_node("Player")
	if (player.current_ability == "Weapon" || player.current_ability == "ArmGun"):
		$RapidBulletCooldown.start()

func _on_rapid_bullet_cooldown_timeout():
	var player = get_parent().get_node("Player").get_node("Player")
	
	if (player.current_ability == "Weapon" || player.current_ability == "ArmGun") && ($Drone.position + position).distance_to(player.position) < 200:
		var player_cast = $Drone/PlayerRaycast.get_collider()
		if player_cast == null || player_cast.name == "Player":
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
		else:
			$RapidBulletCooldown.start()

func _on_area_2d_body_entered(body):
	if body.name != "Player" && body.name != "DroneHitbox":
		$Drone/DroneSpritesheet.visible = false
		$Drone/DroneOutlineSpritesheet.visible = true

func _on_area_2d_body_exited(body):
	if body.name != "Player" && body.name != "DroneHitbox":
		$Drone/DroneSpritesheet.visible = true
		$Drone/DroneOutlineSpritesheet.visible = false

func _on_drone_hurtbox_area_entered(area):
	if area.name == "PlayerBulletHurter":
		var dead_drone = loaded_physics_drone.instantiate()
		dead_drone.queued_position = $Drone.position + position
		dead_drone.queued_rotation = $Drone.rotation
		dead_drone.set_queued_pos = true
		get_parent().call_deferred("add_child", dead_drone)
		queue_free()

func _on_target_found_timer_timeout():
	can_play_target_lost = true
