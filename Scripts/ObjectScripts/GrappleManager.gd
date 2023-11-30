extends Node2D

var active = false
var grappeling = false
@export var porab_line_length = 300

func _process(delta):
	if active && grappeling:
		visible = true 
		
		if Input.is_action_just_pressed("mouse_click"):
			grappeling = false
			
		$GrappleRope.points[0] = Vector2.ZERO 
		$GrappleRope.points[1] = $GrappleBody.position
		print($GrappleBody.velocity)
	elif active:
		$GrappleBody.position = Vector2.ZERO
		$GrappleBody.velocity = Vector2.ZERO
		
		# Calc shot porab
		var mouse_direction = (get_viewport().get_mouse_position() - Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y)).normalized()
		var pos = Vector2.ZERO
		var shot_velocity = mouse_direction * 15 # the velocity of the shot

		for i in range(porab_line_length):
			$LinePorabola.set_point_position(i, pos)
			shot_velocity.y += $GrappleBody.gravity * delta * 60
			pos += shot_velocity
		
		if Input.is_action_just_pressed("mouse_click"):
			grappeling = true
			
			$GrappleBody.velocity = mouse_direction * 15
		
