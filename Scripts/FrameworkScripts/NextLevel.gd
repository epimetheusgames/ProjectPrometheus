extends Area2D

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		add_levels(1)
		
func add_levels(add_num):
	var level = get_parent().level
	var floor = get_parent().floor
	var floors_this_level = get_parent().get_parent().level_node_names[level]
	var level_next = level
	var floor_next = floor
	
	if floors_this_level[floor] == floors_this_level[-1] && add_num > 0:
		level_next += 1
		floor_next = add_num
	else:
		floor_next += add_num
		
	get_parent().get_parent().switch_to_level(level_next, floor_next, level, floor, get_parent().get_node("Player").get_node("Player").character_type, get_parent().slot)
