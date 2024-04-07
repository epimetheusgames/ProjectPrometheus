extends Node2D


var player_in_area = false


func _process(delta):
	if Input.is_action_just_pressed("interact") && player_in_area:
		$VoicelinePlayer.play()

func _on_e_area_area_entered(area):
	if area.name == "PlayerHurtbox":
		player_in_area = true

func _on_e_area_area_exited(area):
	if area.name == "PlayerHurtbox":
		player_in_area = false
