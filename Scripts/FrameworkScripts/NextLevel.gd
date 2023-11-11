extends Area2D

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		get_parent().get_parent().switch_to_level(get_parent().level + 1, get_parent().level, get_parent().slot)
