extends Area2D


func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		get_parent().no_timer = true
		get_parent().boss = false
