extends Area2D

var active = true
var use_parent_add = false

func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && active:
		if !use_parent_add:
			add_level()
		else:
			get_parent().add_level
		
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

func restart_level(respawn_pos, respawn_ability):
	var level = get_parent().level
	var floor = get_parent().floor
	var graphics_efficiency = get_parent().graphics_efficiency
	
	if !get_parent().is_multiplayer:
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").switch_to_level(level, floor, level, floor, get_parent().get_node("Player").get_node("Player").character_type, get_parent().slot, graphics_efficiency, get_parent().points, get_parent().time, get_parent().deaths, get_parent().is_max_level, respawn_pos, respawn_ability, get_parent().easy_mode)
	else:
		var new_player_instance = preload("res://Objects/Player.tscn").instantiate()
		
		if multiplayer.is_server():
			get_parent().server_player.queue_free()
			new_player_instance.name = "ServerPlayer"
			get_parent().server_player = new_player_instance
		else:
			get_parent().client_player.queue_free()
			new_player_instance.name = "ClientPlayer"
			get_parent().client_player = new_player_instance
			new_player_instance.set_multiplayer_authority(multiplayer.get_unique_id())
			
		get_parent().call_deferred("add_child", new_player_instance)
