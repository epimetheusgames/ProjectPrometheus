extends Area2D


func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		get_parent().get_node("AnimationPlayer").play("SmasherUp")
		get_parent().get_node("AnimationPlayer").queue("UP")

func _on_area_exited(area):
	if area.name == "PlayerHurtbox":
		get_parent().get_node("AnimationPlayer").play_backwards("SmasherUp")
		get_parent().get_node("AnimationPlayer").queue("DOWN")
