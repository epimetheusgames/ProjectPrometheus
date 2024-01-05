extends Node2D

var current_line_point = 0
var movement_velocity = Vector2.ZERO
var rapid_bullet_num = 0
var player_previous_ability = ""
var can_play_target_lost = false
var precalculated_flight_path = null
var flight_index = 0
var fly_to_correct = false
var temp_disabled = false
var started_path_drone = false
var flight_path_length = 0
var player_follower_position = Vector2.ZERO
var physics_drone_ingame = null

@onready var flight_position = Vector2.ZERO 
@onready var flight_rotation = Vector2.ZERO
@onready var calc_close_to_checkpoint = false
@onready var loaded_bullet = preload("res://Objects/StaticObjects/DroneBullet.tscn")
@onready var loaded_physics_drone = preload("res://Objects/StaticObjects/PhysicsDrone.tscn")
@onready var graphics_efficiency = get_parent().graphics_efficiency
@onready var player = get_parent().get_node("Player").get_node("Player")
@onready var patrol_points_size = $DronePatrolPoints.points.size()

@export var velocity_smoothing = 0.01
@export var big_drone = false
@export var speed = 1.0

const ninety_deg_rad = deg_to_rad(90)

func smooth(a, b, smoothing):
	return (a + ((b - a) * smoothing))
	
func _ready():
	$LineRaycast.add_exception(player)
	
	if precalculated_flight_path == null:
		precalculated_flight_path = []
		
		while true:
			var finished = calculate_flight_frame()
			
			if finished == "finished":
				break
			
			precalculated_flight_path.append([flight_position, flight_rotation, calc_close_to_checkpoint])
			
		# Disperse drones along the track.
		if !big_drone:
			var distance_to_first_point = $Drone.position.distance_to($DronePatrolPoints.points[0])
			for i in range(int(len(precalculated_flight_path) / (distance_to_first_point * 2))):
				if i > 0:
					var new_drone = duplicate()
					new_drone.get_node("Drone").position = precalculated_flight_path[int(i * distance_to_first_point)][0]
					new_drone.precalculated_flight_path = precalculated_flight_path
					new_drone.flight_index = int(i * distance_to_first_point * 2)
					new_drone.started_path_drone = true
					get_parent().add_child.call_deferred(new_drone)
	
	current_line_point = 0
	
	flight_path_length = len(precalculated_flight_path)
	
	if graphics_efficiency:
		$Drone/GPUParticles2D.queue_free()
		
func calculate_flight_frame():
	var direction_to_next_point = ($DronePatrolPoints.points[current_line_point] - flight_position).normalized()

	movement_velocity = Vector2(smooth(movement_velocity.x, direction_to_next_point.x, velocity_smoothing * 1.5),
								smooth(movement_velocity.y, direction_to_next_point.y / 1.5, velocity_smoothing))
								
	flight_position += movement_velocity * speed
	flight_rotation = movement_velocity.x / (3 if !big_drone else 15)
	calc_close_to_checkpoint = false
	
	if flight_position.distance_to($DronePatrolPoints.points[current_line_point]) < 30:
		calc_close_to_checkpoint = true
		if current_line_point < $DronePatrolPoints.points.size() - 1:
			current_line_point += 1
		else:
			return "finished"

func _process(delta):
	var flight_index_int = int(flight_index) - 1
	var is_close_to_player = ($Drone.position + position).distance_to(player.position) < 250
	
	if flight_index_int >= flight_path_length:
		queue_free()
		return
	
	var current_pos_data = precalculated_flight_path[flight_index_int]
	
	if !fly_to_correct:
		$Drone.position = current_pos_data[0]
		$Drone.rotation = current_pos_data[1]
	else:
		temp_disabled = false
		$Drone.visible = true
		$Drone.position += (current_pos_data[0] - $Drone.position).normalized() * speed * delta * 60
		$Drone.rotation -= $Drone.rotation * 0.1 * delta * 60
		
		# This distance call is okay because only one or two drones should be in fly_to_correct at one time.
		if $Drone.position.distance_to(current_pos_data[0]) < 3:
			fly_to_correct = false
	
	flight_index += delta * 60
	
	if current_pos_data[2] && current_line_point < patrol_points_size - 1:
		current_line_point += 1
		
		if current_line_point == 1 && !big_drone && !started_path_drone:
			var new_drone = duplicate()
			new_drone.get_node("Drone").position = Vector2.ZERO
			new_drone.precalculated_flight_path = precalculated_flight_path
			new_drone.get_node("AttackLine").points[0] = Vector2.ZERO
			new_drone.get_node("AttackLine").points[1] = Vector2.ZERO
			get_parent().add_child(new_drone)
	
	if !temp_disabled:
		physics_drone_ingame = null
			
	if !big_drone && is_close_to_player:
		$Drone/Turret.rotation = (($Drone.position + position) - player.position).normalized().angle() + ninety_deg_rad
		player_follower_position += (player.position - player_follower_position) * 0.05 * delta * 60
		$PlayerRaycast.target_position = (player_follower_position - position - $PlayerRaycast.position).normalized() * 1000
		
		$PlayerRaycast.position = $Drone.position
		$AttackLine.points[0] = $Drone.position
		
		if physics_drone_ingame:
			$AttackLine.points[0] = physics_drone_ingame.position
			$PlayerRaycast.position = physics_drone_ingame.position
			$PlayerRaycast.target_position = Vector2(cos(physics_drone_ingame.rotation), sin(physics_drone_ingame.rotation)).normalized() * 1000
		
		$LineRaycast.target_position = $PlayerRaycast.target_position
		$LineRaycast.position = $PlayerRaycast.position
		
		var player_cast = $PlayerRaycast.get_collider()
		if (player.current_ability == "Weapon" || player.current_ability == "ArmGun") && ($Drone.position + position).distance_to(player.position) < 250:
			if $TargetFoundTimer.time_left == 0:
				$TargetFoundTimer.start()
			
			if (player_previous_ability != "Weapon" && player_previous_ability != "ArmGun" &&
				$WeaponDetected.playing == false && $TargetLost.playing == false &&
				$TargetFoundCooldown.time_left == 0):
				$WeaponDetected.play()
				
			$AttackLine.visible = true
			if $AttackLine.modulate.a < 1:
				$AttackLine.modulate.a += 0.02 * delta * 60
			
			$AttackLine.points[1] = ($LineRaycast.get_collision_point() - position)
			
			player_previous_ability = player.current_ability
		else:
			if (player_previous_ability == "Weapon" || player_previous_ability == "ArmGun"):
				$TargetFoundCooldown.start()
				
				if can_play_target_lost:
					can_play_target_lost = false
					$TargetLost.play()
			
			player_previous_ability = "NoDistance"
	elif !big_drone:
		if $AttackLine.modulate.a > 0:
			$AttackLine.modulate.a -= 0.04 * delta * 60
	
	if !big_drone && (player.current_ability == "Weapon" || player.current_ability == "ArmGun") && $RapidBulletCooldown.is_stopped() && $BulletCooldown.is_stopped():
		$BulletCooldown.start()
		
func _on_bullet_cooldown_timeout():
	if (player.current_ability == "Weapon" || player.current_ability == "ArmGun"):
		$RapidBulletCooldown.start()

func _on_rapid_bullet_cooldown_timeout():
	if (player.current_ability == "Weapon" || player.current_ability == "ArmGun") && ($Drone.position + position).distance_to(player.position) < 200:
		var player_cast = $PlayerRaycast.get_collider()
		if player_cast != null && (player_cast.name == "Player" || player_cast.name == "PlayerAccurateCollider") && !big_drone && !temp_disabled && !fly_to_correct:
			var direction_to_player = (player.position - (position + $Drone.position)).normalized()

			if rapid_bullet_num < 2:
				rapid_bullet_num += 1
				$RapidBulletCooldown.start()
			else:
				rapid_bullet_num = 0
				$BulletCooldown.start()
				
			var bullet_to_add = loaded_bullet.instantiate()
			bullet_to_add.position = position + $Drone.position
			bullet_to_add.velocity = direction_to_player * 3
			bullet_to_add.graphics_efficiency = graphics_efficiency
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
	if area.name == "PlayerBulletHurter" || area.name == "PlayerHurtbox" && !big_drone && !temp_disabled:
		get_parent().get_node("Player").get_node("Player").get_node("BulletBadHurtcooldown").stop()
		get_parent().get_node("Player").get_node("Player").get_node("PlayerAnimation").modulate = Color.WHITE
		var dead_drone = loaded_physics_drone.instantiate()
		dead_drone.queued_position = $Drone.position + position
		dead_drone.queued_rotation = $Drone.rotation
		dead_drone.set_queued_pos = true
		physics_drone_ingame = dead_drone
		if area.name == "PlayerHurtbox":
			call_deferred("add_child", dead_drone)
			$Drone.visible = false
			fly_to_correct = false
			temp_disabled = true
		if area.name == "PlayerBulletHurter":
			dead_drone.no_respawn = true
			call_deferred("add_child", dead_drone)
			$Drone.visible = false
			fly_to_correct = false
			temp_disabled = true

func _on_target_found_timer_timeout():
	can_play_target_lost = true
