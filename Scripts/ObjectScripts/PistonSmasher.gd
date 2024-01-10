extends CharacterBody2D

var position_y_offset = 0
var smashing = false
var retracting = false

@onready var start_position = position

func _physics_process(delta):
	position = start_position + Vector2(0, position_y_offset)
	
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
