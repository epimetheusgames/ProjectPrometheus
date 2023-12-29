extends Node2D


var ability_index = 0
var switching_ability = false
var fading_in = false

@onready var original_pos = position
@onready var original_scale = scale

const ability_max = 3


func _ready():
	$TickerMask/Ticker.rotation -= ((1.0 / 2.0) * PI) / ($FadinHalfWaitTimer.wait_time * 60)

func _on_abililty_switch_timer_timeout():
	if ability_index < ability_max:
		ability_index += 1
	else:
		ability_index = 0
		
	switching_ability = true
	fading_in = true

func _process(delta):
	position = original_pos * (4 / get_parent().zoom.x)
	scale = original_scale * (4 / get_parent().zoom.x)
	$TickerMask/Ticker.rotation += ((1.0 / 2.0) * PI) / ($AbililtySwitchTimer.wait_time * 60) * delta * 60
	$TickerMask/Item.rotation = $TickerMask/Ticker.rotation
	
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
	get_parent().get_parent().get_node("Player").get_node("SparkParticles").emitting = true

func _on_fadin_half_wait_timer_timeout():
	if ability_index == 0:
		get_parent().get_parent().get_node("Player").current_ability = "Weapon"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkSword")
		get_parent().get_parent().get_node("Player").get_node("GrappleManager").active = false
	if ability_index == 1:
		get_parent().get_parent().get_node("Player").current_ability = "RocketBoost"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkRockets")
	if ability_index == 2:
		get_parent().get_parent().get_node("Player").current_ability = "ArmGun"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalk")
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = true
	if ability_index == 3:
		get_parent().get_parent().get_node("Player").current_ability = "Grapple"
		get_parent().get_parent().get_node("Player").get_node("GrappleManager").active = true
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = false
