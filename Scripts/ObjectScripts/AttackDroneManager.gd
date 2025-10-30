# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Drone that runs towards you when it sees you.                                                          |
# Duplicate of DroneManager.gd                                                                           |
# -------------------------------------------------------------------------------------------------------|


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
var chasing_player = false

@onready var flight_position = Vector2.ZERO 
@onready var flight_rotation = Vector2.ZERO
@onready var calc_close_to_checkpoint = false
@onready var loaded_bullet = preload("res://Objects/StaticObjects/DroneBullet.tscn")
@onready var loaded_physics_drone = preload("res://Objects/StaticObjects/PhysicsDrone.tscn")
@onready var loaded_physics_bird = preload("res://Objects/StaticObjects/PhysicsBird.tscn")
@onready var loaded_bomb = preload("res://Objects/StaticObjects/Exploder.tscn")
@onready var graphics_efficiency = get_parent().graphics_efficiency
@onready var player = get_parent().get_node("Player").get_node("Player") if !get_parent().is_multiplayer else null
@onready var patrol_points_size = $DronePatrolPoints.points.size()

@export var velocity_smoothing = 0.01
@export var big_drone = false
@export var firefly = false
@export var drone_boss = false
@export var bird = false
@export var attack_drone = false
@export var ignore_ability_type = false
@export var speed = 1.0

const ninety_deg_rad = deg_to_rad(90)

func smooth(a, b, smoothing):
	return (a + ((b - a) * smoothing))
	
func _ready():
	if !big_drone:
		$LineRaycast.add_exception(player)
	
	if precalculated_flight_path == null:
		precalculated_flight_path = []
		
		while true:
			var finished = calculate_flight_frame()
			
			if finished == "finished":
				break
			
			precalculated_flight_path.append([flight_position, flight_rotation, calc_close_to_checkpoint])
			
		# Disperse drones along the track.
		if !big_drone || firefly:
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
		if big_drone:
			$Drone/GPUParticles2D2.queue_free()
		
func calculate_flight_frame():
	var direction_to_next_point = ($DronePatrolPoints.points[current_line_point] - flight_position).normalized()

	movement_velocity = Vector2(smooth(movement_velocity.x, direction_to_next_point.x, velocity_smoothing * 1.5),
								smooth(movement_velocity.y, direction_to_next_point.y / 1.5, velocity_smoothing))
	
	if get_parent().graphics_efficiency && !big_drone:
		$AttackLine.clip_children = false
		$AttackLine/Sprite2D.visible = false
	
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
	if get_parent().is_multiplayer:
		var distance_to_server_player = get_parent().server_player.get_node("Player").position.distance_to(position)
		var distance_to_client_player = get_parent().client_player.get_node("Player").position.distance_to(position)
			
		if distance_to_server_player < distance_to_client_player:
			player = get_parent().server_player.get_node("Player")
		else:
			player = get_parent().client_player.get_node("Player")
	
	if !big_drone:
		$AttackLine/Sprite2D.rotation += 0.01 * delta * 60
		$AttackLine/Sprite2D.position = $Drone.position
	
	var flight_index_int = int(flight_index) - 1
	var is_close_to_player = ($Drone.position + position).distance_to(player.position) < 250
	
	if flight_index_int >= flight_path_length:
		if !drone_boss:
			queue_free()
			return
		else:
			get_parent().get_node("DeadBoss").visible = true
			queue_free()
			return
	
	var current_pos_data = precalculated_flight_path[flight_index_int]
	
	if !chasing_player:
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
	else:
		var follow_velocity = (player.position - $Drone.position - position).normalized() * speed * 2 * delta * 60
		$Drone.position += follow_velocity
		$Drone.rotation = follow_velocity.x / 6
	
	flight_index += delta * 60
	
	if current_pos_data[2] && current_line_point < patrol_points_size - 1 && !chasing_player:
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
			
	if !big_drone && is_close_to_player && !temp_disabled:
		player_follower_position += (player.position - player_follower_position) * 0.2 * delta * 60
		$PlayerRaycast.target_position = (player_follower_position - position - $PlayerRaycast.position).normalized() * 300
		
		$PlayerRaycast.position = $Drone.position
		$AttackLine.points[0] = $Drone.position
		
		if physics_drone_ingame && is_instance_valid(physics_drone_ingame):
			$AttackLine.points[0] = physics_drone_ingame.position
			$PlayerRaycast.position = physics_drone_ingame.position
			$PlayerRaycast.target_position = Vector2(cos(physics_drone_ingame.rotation), sin(physics_drone_ingame.rotation)).normalized() * 1000
		
		$LineRaycast.target_position = $PlayerRaycast.target_position
		$LineRaycast.position = $PlayerRaycast.position
		
		if ((player.current_ability == "Weapon" || player.current_ability == "ArmGun") || ignore_ability_type) && ($Drone.position + position).distance_to(player.position) < 250:
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
			
			if $LineRaycast.get_collision_point().distance_to(player.position) < 30:
				chasing_player = true
			
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

func _on_area_2d_body_entered(body):
	if body.name != "Player" && body.name != "DroneHitbox":
		$Drone/DroneSpritesheet.visible = false
		$Drone/DroneOutlineSpritesheet.visible = true

func _on_area_2d_body_exited(body):
	if body.name != "Player" && body.name != "DroneHitbox":
		$Drone/DroneSpritesheet.visible = true
		$Drone/DroneOutlineSpritesheet.visible = false

func _on_drone_hurtbox_area_entered(area):
	if (area.name == "PlayerBulletHurter" || area.name == "PlayerHurtbox" || area.name == "DeathZone") && !temp_disabled:
		var instantiated_exploder = loaded_bomb.instantiate()
		instantiated_exploder.position = position + $Drone.position
		
		if get_parent().difficulty == 0:
			instantiated_exploder.no_damage = true
			
		get_parent().add_child(instantiated_exploder)
		instantiated_exploder._on_explosion_hitbox_body_entered(area)
		
		queue_free()

func _on_target_found_timer_timeout():
	can_play_target_lost = true
