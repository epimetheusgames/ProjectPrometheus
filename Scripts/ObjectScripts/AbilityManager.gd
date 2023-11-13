extends Node2D


var ability_index = 0
const ability_max = 1


func _on_abililty_switch_timer_timeout():
	if ability_index < ability_max:
		ability_index += 1
	else:
		ability_index = 0
		
	if ability_index == 0:
		get_parent().get_parent().get_node("Player").current_ability = "Weapon"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalk")
		$RocketBoots.visible = false
		$Weapon.visible = true
	if ability_index == 1:
		get_parent().get_parent().get_node("Player").current_ability = "RocketBoost"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalk")
		$RocketBoots.visible = true 
		$Weapon.visible = false
