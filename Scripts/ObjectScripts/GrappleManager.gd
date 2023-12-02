extends Node2D

var active = false
var grapling = false
var hooked = false
var hook
@export var exit_grapple_vel_mult = 1.5
@export var porab_line_length = 300

func _physics_process(delta):
	if active && grapling:
		if hooked:
			$GrappleBody.hooked = true
			$GrappleBody.position = hook.position - get_parent().position
			
			get_parent().velocity += (hook.position - get_parent().position).normalized()
			get_parent().grappling_effects = true
		
		visible = true 
		
		if Input.is_action_just_pressed("mouse_click"):
			grapling = false
			hooked = false
			$GrappleBody.hooked = false
			
			get_parent().velocity *= exit_grapple_vel_mult
			get_parent().grappling_no_speed_cap = true
			get_parent().grappling_effects = false
			$NoSpeedCapTimer.start()
			
		$GrappleRope.points[0] = Vector2.ZERO 
		$GrappleRope.points[1] = $GrappleBody.position
		
		$GrappleRope.visible = true
		$LinePorabola.visible = false
	elif active:
		$GrappleBody.position = Vector2.ZERO
		$GrappleBody.velocity = Vector2.ZERO
		
		$GrappleRope.visible = false
		$LinePorabola.visible = true
		
		# Calc shot porab
		var mouse_direction = (get_viewport().get_mouse_position() - Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y)).normalized()
		var pos = Vector2.ZERO
		var shot_velocity = mouse_direction * 15 # the velocity of the shot

		for i in range(porab_line_length):
			$LinePorabola.set_point_position(i, pos)
			shot_velocity.y += $GrappleBody.gravity * delta * 60
			pos += shot_velocity
		
		if Input.is_action_just_pressed("mouse_click") && $CooldownTimer.time_left == 0:
			grapling = true
			
			$GrappleBody.velocity = mouse_direction * 15
			
	if active:
		visible = true
		get_parent().get_parent().target_zoom = Vector2(3, 3)
	else:
		visible = false
		get_parent().get_parent().target_zoom = get_parent().get_parent().start_zoom

func _on_no_speed_cap_timer_timeout():
	get_parent().grappling_no_speed_cap = false

