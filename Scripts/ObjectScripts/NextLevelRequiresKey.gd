# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D

var active = false

@export var disable_collision = false
@export var enable_collision = false
var do_enable_collision = false
var player_in_area = false

func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox" && area.get_parent().has_key && !disable_collision && !enable_collision:
		player_in_area = true
	
	if area.name == "PlayerHurtbox" && area.get_parent().has_key && disable_collision && !enable_collision:
		if $StaticBody2D:
			$StaticBody2D.queue_free()
		
	if area.name == "PlayerHurtbox" && area.get_parent().has_key && !disable_collision && enable_collision:
		# Only do this if the door is unlocked because it results in the key being freed even
		# if it hasn't done anything.
		if $StaticBody2D/CollisionShape2D.disabled:
			$StaticBody2D/CollisionShape2D.disabled = false
			do_enable_collision = true
		
func _on_area_2d_area_exited(area):
	if area.name == "PlayerHurtbox":
		player_in_area = false
		
func add_level():
	var level = get_parent().level
	var floor = get_parent().floor
	var floors_this_level = get_parent().get_parent().get_parent().get_node("SaveLoadFramework").level_node_names[level]
	var level_next = level
	var floor_next = floor
	var graphics_efficiency = get_parent().graphics_efficiency
	
	if floors_this_level[floor] == floors_this_level[-1]:
		level_next += 1
		floor_next = 0
	else:
		floor_next += 1
		
	get_parent().get_parent().get_parent().get_node("SaveLoadFramework").has_keycard = false
	get_parent().get_parent().get_parent().get_node("SaveLoadFramework").switch_to_level(level_next, floor_next, level, floor, get_parent().get_node("Player").get_node("Player").character_type, get_parent().slot, graphics_efficiency, get_parent().points, get_parent().time, get_parent().deaths, get_parent().is_max_level, null, null, null, null, get_parent().easy_mode, get_parent().difficulty)

func restart_level(respawn_pos, respawn_ability):
	var level = get_parent().level
	var floor = get_parent().floor
	var graphics_efficiency = get_parent().graphics_efficiency
		
	get_parent().get_parent().get_parent().get_node("SaveLoadFramework").switch_to_level(level, floor, level, floor, get_parent().get_node("Player").get_node("Player").character_type, get_parent().slot, graphics_efficiency, get_parent().points, get_parent().time, get_parent().deaths, get_parent().is_max_level, respawn_pos, respawn_ability, get_parent().easy_mode, get_parent().difficulty)

func _physics_process(delta):
	if do_enable_collision:
		$StaticBody2D/CollisionShape2D.disabled = false
		
	if Input.is_action_just_pressed("interact") && player_in_area:
		get_parent().get_node("Player").get_node("Camera").get_node("LevelTransitionAnimationPlayer").play("CloseLevel")
