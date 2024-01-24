extends Node2D

var active = false
var grapling = false
var hooked = false
var hook
var air_grapling = false
var was_hooked = false
var grapple_lock_rope_len = -1
@export var exit_grapple_vel_mult = 1.5
@export var porab_line_length = 300
@export var max_hook_dist = 300

func calc_closest_hook():
	var closest_hook = null
	var closest_distance = 9999999999
	
	for test_hook in get_tree().get_nodes_in_group("hooks"):
		var distance = test_hook.position.distance_to(get_parent().position)
		if distance < closest_distance && test_hook.position.y < get_parent().get_parent().position.y + get_parent().position.y:
			closest_hook = test_hook
			closest_distance = distance
	
	return closest_hook

func _physics_process(delta):
	if get_parent().is_on_floor():
		if air_grapling:
			grapling = false
			hooked = false
			hook = null
		air_grapling = false
		get_parent().disable_speed_cap = false
		get_parent().low_gravity = false
	
	if !hooked && !air_grapling && get_parent().get_node("PlayerAnimation").animation == "GrappleHang":
		get_parent().get_node("PlayerAnimation").play("Idle")
	
	if active && grapling:
		if hooked && hook && air_grapling:
			if !was_hooked:
				var closest_hook_dist = calc_closest_hook().position.distance_to(get_parent().position)
				grapple_lock_rope_len = closest_hook_dist
			
			get_parent().disable_speed_cap = true
			get_parent().low_gravity = true
			
			# Transfer downwards energy into sideways energy when swinging.
			# Credit to the swing() function at 21:30 from https://www.youtube.com/watch?v=EDOLMZg-loQ
			# This uses math that is way over my head. Literally magic.
			var radius = get_parent().position - hook.position
			var angle = acos(radius.dot(get_parent().velocity) / (radius.length() * get_parent().velocity.length()))
			
			if Input.is_action_pressed("jump"):
				grapple_lock_rope_len -= 1.5 * delta * 60
				
			if Input.is_action_pressed("down"):
				grapple_lock_rope_len += 1.4 * delta * 60
			
			var rad_vel = cos(angle) * get_parent().velocity.length()
			get_parent().velocity += radius.normalized() * -rad_vel
			# End code I did not make.
			
			if hook.position.distance_to(get_parent().position) > grapple_lock_rope_len:
				get_parent().position = hook.position + (get_parent().position - hook.position).normalized() * grapple_lock_rope_len
		
		else:
			get_parent().disable_speed_cap = false
			get_parent().low_gravity = false
		
		if hooked && hook:
			$GrappleBody.hooked = true
			$GrappleBody.position = hook.position - get_parent().position
			
			get_parent().get_node("PlayerAnimation").play("GrappleHang") 
			
			if hook.position.x - get_parent().position.x < 0:
				get_parent().get_node("PlayerAnimation").scale.x = -1
			if hook.position.x - get_parent().position.x > 0:
				get_parent().get_node("PlayerAnimation").scale.x = 1
			
			if !air_grapling:
				get_parent().velocity += (hook.position - get_parent().position).normalized() / 2
				get_parent().grappling_effects = true
		else:
			hook = null
		
		visible = true 
		
		if Input.is_action_just_released("mouse_click"):
			if hook:
				if !air_grapling:
					get_parent().velocity = (hook.position - get_parent().position).normalized() * 5
				if air_grapling:
					get_parent().velocity *= 3
			
			get_parent().disable_speed_cap = false
			get_parent().low_gravity = false
			grapling = false
			hooked = false
			air_grapling = false
			$GrappleBody.hooked = false
			
		$GrappleRope.points[0] = Vector2.ZERO 
		$GrappleRope.points[1] = $GrappleBody.position - get_parent().get_parent().position
		
		$GrappleRope.visible = true
		$LinePorabola.visible = false
	elif active:
		hook = null
		hooked = false
		air_grapling = false
		get_parent().disable_speed_cap = false
		get_parent().grappling_effects = false
		get_parent().low_gravity = false
		$GrappleBody.position = Vector2.ZERO
		$GrappleBody.velocity = Vector2.ZERO
		
		$GrappleRope.visible = false
		$LinePorabola.visible = true
		
		var closest_hook = calc_closest_hook()
		
		var closest_hook_dist = null
		if closest_hook:
			closest_hook_dist = closest_hook.position.distance_to(get_parent().position)
		
		if closest_hook && closest_hook_dist < max_hook_dist:
			var mouse_direction = (closest_hook.position - get_parent().get_parent().position - get_parent().position).normalized()
			$LinePorabola.points[0] = Vector2.ZERO
			$LinePorabola.points[1] = mouse_direction * 10000
			$LinePorabola.visible = true
			
			if Input.is_action_just_pressed("mouse_click"):
				grapling = true
				
				if !get_parent().is_on_floor():
					air_grapling = true
				
				$GrappleBody.velocity = mouse_direction * 15
		else:
			$LinePorabola.visible = false
			
	if active:
		visible = true
		get_parent().get_parent().target_zoom = Vector2(3, 3)
	else:
		visible = false
		get_parent().grappling_effects = false
		get_parent().get_parent().target_zoom = get_parent().get_parent().start_zoom
		
	if hooked:
		was_hooked = true
	else:
		was_hooked = false

