# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends CharacterBody2D

var position_y_offset = 0
var smashing = false
var retracting = false

@onready var start_position = position
@export var horizontal_smash = false

func _physics_process(delta):
	position = start_position + Vector2(position_y_offset if horizontal_smash else 0, position_y_offset if !horizontal_smash else 0)
	
	if position_y_offset < 96 && smashing:
		position_y_offset += 10 * delta * 60
	elif smashing:
		$WaitRetractTimer.start()
		smashing = false
	
	if position_y_offset > 0 && retracting:
		position_y_offset -= 1 * delta * 60

func _on_smash_timer_timeout():
	smashing = true
	retracting = false

func _on_wait_retract_timer_timeout():
	retracting = true
	$SmashTimer.start()

func _on_start_delay_timer_timeout():
	$SmashTimer.start()
