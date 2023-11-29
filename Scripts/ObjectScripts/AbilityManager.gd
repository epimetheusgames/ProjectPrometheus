extends Node2D


var ability_index = 0
var switching_ability = false
var fading_in = false
const ability_max = 3


func _on_abililty_switch_timer_timeout():
	if ability_index < ability_max:
		ability_index += 1
	else:
		ability_index = 0
		
	switching_ability = true
	fading_in = true

func _process(delta):
	if switching_ability && fading_in:
		if get_parent().get_node("DarkOverlay").color.a < 0.7:
			get_parent().get_node("DarkOverlay").color.a += 0.5 * delta
		elif $FadinWaitTimer.is_stopped():
			$FadinWaitTimer.start()
			$FadinHalfWaitTimer.start()
	elif switching_ability:
		if get_parent().get_node("DarkOverlay").color.a > 0:
			get_parent().get_node("DarkOverlay").color.a -= 0.5 * delta
		else:
			switching_ability = false

func _on_fadin_wait_timer_timeout():
	fading_in = false
	if !get_parent().get_parent().graphics_efficiency:
		get_parent().get_parent().get_node("Player").get_node("SparkParticles").emitting = true

func _on_fadin_half_wait_timer_timeout():
	if ability_index == 0:
		get_parent().get_parent().get_node("Player").current_ability = "Weapon"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalk")
		$RocketBoots.visible = false
		$Weapon.visible = true
	if ability_index == 1:
		get_parent().get_parent().get_node("Player").current_ability = "RocketBoost"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkRockets")
		$RocketBoots.visible = true
		$Weapon.visible = false
	if ability_index == 2:
		get_parent().get_parent().get_node("Player").current_ability = "ArmGun"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalk")
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = true
		$RocketBoots.visible = false
		$ArmGun.visible = true
	if ability_index == 3:
		get_parent().get_parent().get_node("Player").current_ability = "RocketBoost"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkRockets")
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = false
		$RocketBoots.visible = true
		$ArmGun.visible = false
