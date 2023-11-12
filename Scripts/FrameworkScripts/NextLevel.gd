extends Area2D

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		var level = get_parent().level
		var floor = get_parent().floor
		var floors_this_level = get_parent().get_parent().level_node_names[level]
		var level_next = level
		var floor_next = floor
		
		if floors_this_level[floor] == floors_this_level[-1]:
			level_next += 1
		else:
			floor_next += 1
			
		get_parent().get_parent().switch_to_level(level_next, floor_next, level, floor, get_parent().slot)
