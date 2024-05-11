extends Area2D


var player_in_area = false

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		player_in_area = true

func _on_area_exited(area):
	if area.name == "PlayerHurtbox":
		player_in_area = false
		
func _process(delta):
	if player_in_area && Input.is_action_just_pressed("interact"):
		get_parent().get_node("NextLevel").previous_level()
