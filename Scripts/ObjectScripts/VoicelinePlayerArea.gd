extends Area2D


@export var voiceline_name = ""
var played = false

func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && !played:
		played = true
		area.get_parent().get_parent().get_node("VoicelinePlayer").play_voiceline(voiceline_name)
