# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


@onready var loaded_bullet = preload("res://Objects/StaticObjects/DroneBullet.tscn")
@onready var graphics_efficiency = get_parent().graphics_efficiency

@export var shoot_velocity = 0.0
@export var boss_turret = false

func _process(delta):
	if $Sprite2D.scale.x == -1:
		$Turret.scale.y = -1
		
	var player
	
	if boss_turret:
		player = get_parent().get_parent().get_node("Player").get_node("Player")
	else:
		player = get_parent().get_node("Player").get_node("Player")
	
	var direction_to_player = (player.position - position + player.get_parent().position - $Turret.position).normalized()
	var direction_to_player_radians = -atan2(direction_to_player.x, direction_to_player.y) 
	$Turret.rotation = direction_to_player_radians - (1.0/2.0 * PI)
	
	var distance_to_player = player.position.distance_to(position)
	
	if distance_to_player < 300 && $NewBulletTimer.time_left == 0 && (player.current_ability == "ArmGun" || player.current_ability == "Weapon"):
		$NewBulletTimer.start()
		
		var bullet_to_add = loaded_bullet.instantiate()
		bullet_to_add.position = (position + $Turret.position * scale)
		bullet_to_add.velocity = direction_to_player * shoot_velocity
		bullet_to_add.graphics_efficiency = graphics_efficiency
		get_parent().add_child(bullet_to_add)
