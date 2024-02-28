# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Area2D


var server_player_in_area = false
var client_player_in_area = false

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
	
	if !get_parent().is_multiplayer:
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").switch_to_level(level_next, floor_next, level, floor, get_parent().get_node("Player").get_node("Player").character_type, get_parent().slot, graphics_efficiency, get_parent().points, get_parent().time, get_parent().deaths, get_parent().is_max_level, null, null, null, null, get_parent().easy_mode)
	else:
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").switch_to_level(36, 0, 35, 0, 0, get_parent().slot, graphics_efficiency, get_parent().points, get_parent().time, get_parent().deaths, get_parent().is_max_level, null, null, null, null, get_parent().easy_mode)

func _process(delta):
	if server_player_in_area && client_player_in_area:
		add_level()

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		if area.get_parent().get_parent().name == "ServerPlayer":
			server_player_in_area = true
		if area.get_parent().get_parent().name == "ClientPlayer":
			client_player_in_area = true

func _on_area_exited(area):
	if area.name == "PlayerHurtbox":
		if area.get_parent().get_parent().name == "ServerPlayer":
			server_player_in_area = false
		if area.get_parent().get_parent().name == "ClientPlayer":
			client_player_in_area = false
