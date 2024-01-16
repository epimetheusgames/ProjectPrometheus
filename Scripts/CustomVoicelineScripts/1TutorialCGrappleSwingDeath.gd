extends Area2D


func _on_area_entered(area):
	if !area.name == "PlayerHurtbox":
		return
		
	get_parent().get_parent().get_parent().get_node("SaveLoadFramework").get_node("VoicelinePlayer").one_tutorial_c_grapple_swing()
