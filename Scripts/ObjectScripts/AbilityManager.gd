extends Node2D


var ability_index = 0
var switching_ability = false
var fading_in = false
var ideal_rotation = 0

@onready var original_pos = position
@onready var original_scale = scale

const ability_max = 3


func _ready():
	ideal_rotation -= ((1.0 / 2.0) * PI) / ($FadinHalfWaitTimer.wait_time * 60)

func _on_abililty_switch_timer_timeout():
	get_parent().get_node("CloseAnimator").closing = true
	Engine.time_scale = 0.6
	get_parent().get_parent().get_node("Player").get_node("HurtVibrationTimer").start()

func _process(delta):
	original_scale = Vector2(1.5, 1.5)
	original_pos = Vector2(0, 137)
	
	position = original_pos * (4 / get_parent().zoom.x)
	scale = original_scale * (4 / get_parent().zoom.x)
	ideal_rotation += ((1.0 / 2.0) * PI) / ($AbililtySwitchTimer.wait_time * 60) * delta * 60
	$TickerMask/Ticker.rotation += (ideal_rotation - $TickerMask/Ticker.rotation) * 0.1 * delta * 60
	$TickerMask/Item.rotation = $TickerMask/Ticker.rotation
	
	if $AbililtySwitchTimer.time_left < 10:
		get_parent().get_node("DarkOverlay").color.a += 0.0015 * delta * 60
		
	elif get_parent().get_node("DarkOverlay").color.a > 0:
		get_parent().get_node("DarkOverlay").color.a -= 0.1

func _on_fadin_wait_timer_timeout():
	fading_in = false
	get_parent().get_parent().get_node("Player").get_node("SparkParticles").emitting = true

func next_ability():
	if ability_index == 3:
		ideal_rotation = deg_to_rad(0)
		get_parent().get_parent().get_node("Player").current_ability = "Weapon"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkSword")
		get_parent().get_parent().get_node("Player").get_node("GrappleManager").active = false
		_ready()
	elif ability_index == 0:
		ideal_rotation = deg_to_rad(90)
		get_parent().get_parent().get_node("Player").current_ability = "RocketBoost"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkRockets")
		_ready()
	elif ability_index == 1:
		ideal_rotation = deg_to_rad(180)
		get_parent().get_parent().get_node("Player").current_ability = "ArmGun"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalk")
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = true
		_ready()
	elif ability_index == 2:
		ideal_rotation = deg_to_rad(270)
		get_parent().get_parent().get_node("Player").current_ability = "Grapple"
		get_parent().get_parent().get_node("Player").get_node("GrappleManager").active = true
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = false
		_ready()
	
	ability_index += 1
	
	if ability_index == 4:
		ability_index = 0
	$AbililtySwitchTimer.start()

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
