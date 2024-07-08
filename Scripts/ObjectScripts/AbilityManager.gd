# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, Ranier Szatlocky.      |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Sets current ability, moves to next ability, and triggers death on timeout.                            |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


var ability_index = 0
var switching_ability = false
var fading_in = false
var ideal_rotation = 0
var ability_lost_volume = -40.0

@onready var original_pos = position
@onready var original_scale = scale
@onready var loaded_crosshair = preload("res://Assets/Images/Objects/Misc/Crosshair.png")
@onready var loaded_arrow = preload("res://Assets/Images/Objects/Misc/MouseCursor.png")

@export var start_ability = 0

const ability_max = 3


func _ready():
	ideal_rotation -= ((1.0 / 2.0) * PI) / ($FadinHalfWaitTimer.wait_time * 60) 
	$TextureProgressBar.texture_progress.fill_to.x = 0.714
	
	while start_ability != ability_index:
		next_ability()

# To prevent infinite recursion.
func ready_no_next():
	ideal_rotation -= ((1.0 / 2.0) * PI) / ($FadinHalfWaitTimer.wait_time * 60) 
	$TextureProgressBar.texture_progress.fill_to.x = 0.714

func _on_abililty_switch_timer_timeout():
	if (get_parent().get_parent().get_parent().is_multiplayer && get_parent().get_parent().is_multiplayer_authority()) || !get_parent().get_parent().get_parent().is_multiplayer:
		get_parent().get_node("CloseAnimator").closing = true
		Engine.time_scale = 0.6
		get_parent().get_parent().get_node("Player").get_node("HurtVibrationTimer").start()

func _process(delta):
	original_scale = Vector2(1.5, 1.5)
	original_pos = Vector2(0, 137)
	
	position = original_pos * (4 / get_parent().zoom.x)
	scale = original_scale * (4 / get_parent().zoom.x)
	
	if !get_parent().get_parent().get_parent().no_timer:
		ideal_rotation += ((1.0 / 2.0) * PI) / ($AbililtySwitchTimer.wait_time * 60) * delta * 60
	else:
		$AbililtySwitchTimer.start()
		
	if ability_index == 2:
		Input.set_custom_mouse_cursor(loaded_crosshair)
	else:
		Input.set_custom_mouse_cursor(loaded_arrow)
		
	$TickerMask/Ticker.rotation += (ideal_rotation - $TickerMask/Ticker.rotation) * 0.1 * delta * 60
	$TickerMask/Item.rotation = $TickerMask/Ticker.rotation
	
	$TextureProgressBar.value = 400 - $AbililtySwitchTimer.time_left * 20
	
	if $AbililtySwitchTimer.time_left < 10:
		$TextureProgressBar.texture_progress.fill_to.x += 0.0001 * delta * 60
		$TextureProgressBar.modulate.r += 0.001 * delta * 60
		get_parent().get_node("DarkOverlay").color.a += 0.0015 * delta * 60
		
		if ability_lost_volume < 5:
			ability_lost_volume += 0.08 * delta * 60
		
		if ability_lost_volume < -20:
			ability_lost_volume = -20
		
		if !get_parent().get_parent().get_parent().demo_max:
			get_parent().get_parent().get_node("ClockTick").volume_db = ability_lost_volume
			get_parent().get_parent().get_node("ClockTick").pitch_scale += 0.001
			
			if !get_parent().get_parent().get_node("ClockTick").playing:
				get_parent().get_parent().get_node("ClockTick").play()
		else:
			get_parent().get_parent().get_node("ClockTick").volume_db = -80
		
	elif get_parent().get_node("DarkOverlay").color.a > 0:
		get_parent().get_node("DarkOverlay").color.a -= 0.1
		ability_lost_volume = -40
	
	if $AbililtySwitchTimer.time_left > 10:
		get_parent().get_parent().get_node("ClockTick").pitch_scale = 0.0001
		
	get_parent().get_parent().static_adder = get_parent().get_node("DarkOverlay").color.a / 10
	get_parent().get_parent().bulge_adder = get_parent().get_node("DarkOverlay").color.a

func _on_fadin_wait_timer_timeout():
	fading_in = false
	get_parent().get_parent().get_node("Player").get_node("SparkParticles").emitting = true

func next_ability():
	$TextureProgressBar.texture_progress.fill_to.x = 0.714
	
	if ability_index == 3:
		ideal_rotation = deg_to_rad(0)
		get_parent().get_parent().get_node("Player").current_ability = "Weapon"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkSword")
		get_parent().get_parent().get_node("Player").get_node("GrappleManager").active = false
		get_parent().get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework").get_node("VoicelinePlayer").get_out_weapon()
		ready_no_next()
	elif ability_index == 0:
		ideal_rotation = deg_to_rad(90)
		get_parent().get_parent().get_node("Player").current_ability = "RocketBoost"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalkRockets")
		ready_no_next()
	elif ability_index == 1:
		ideal_rotation = deg_to_rad(180)
		get_parent().get_parent().get_node("Player").current_ability = "ArmGun"
		get_parent().get_parent().get_node("Player").get_node("PlayerAnimation").play("StartWalk")
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = true
		ready_no_next()
		get_parent().get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework").get_node("VoicelinePlayer").get_out_weapon()
	elif ability_index == 2:
		ideal_rotation = deg_to_rad(270)
		get_parent().get_parent().get_node("Player").current_ability = "Grapple"
		get_parent().get_parent().get_node("Player").get_node("GrappleManager").active = true
		get_parent().get_parent().get_node("Player").get_node("ArmGunManager").active = false
		ready_no_next()
	
	ability_index += 1
	
	if ability_index == 4:
		ability_index = 0
	$AbililtySwitchTimer.start()
	
	$AnimationPlayer.play("GotItem")

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

func _on_transparentifier_area_entered(area):
	if area.name == "PlayerHurtbox":
		$TransparentifierAnimationPlayer.play("Fadeout")

func _on_transparentifier_area_exited(area):
	if area.name == "PlayerHurtbox":
		$TransparentifierAnimationPlayer.play("Fadein")
