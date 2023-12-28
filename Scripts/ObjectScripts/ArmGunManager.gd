extends Node2D

@onready var loaded_bullet = preload("res://Objects/StaticObjects/PlayerBullet.tscn")
@onready var point_1_start_x = $Line2D.points[1].x

var active = false

func _process(delta):
	if active:
		visible = true
		
		var mouse_pos = get_viewport().get_mouse_position() - Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
		
		if get_parent().previous_direction == -1:
			mouse_pos.x = -mouse_pos.x
		
		$Line2D.points[2].x = mouse_pos.x / 100 + (mouse_pos.y / 80) - 20
		$Line2D.points[2].y = -25 - (mouse_pos.x / 150) + (mouse_pos.y / 200)
		
		var reversed_points_2 = Vector2(-$Line2D.points[2].x, $Line2D.points[2].y)
		var mouse_direction = (get_global_mouse_position() - (get_parent().position + ($Line2D.points[2] if get_parent().previous_direction == 1 else reversed_points_2))).normalized()
		var reversed_mouse_dir = Vector2(-mouse_direction.x, mouse_direction.y)
		
		# For controller
		if len(Input.get_connected_joypads()) > 0:
			var controller_joy_dir_x = Input.get_joy_axis(Input.get_connected_joypads()[0], JOY_AXIS_RIGHT_X)
			var controller_joy_dir_y = Input.get_joy_axis(Input.get_connected_joypads()[0], JOY_AXIS_RIGHT_Y)
			mouse_direction = Vector2(controller_joy_dir_x, controller_joy_dir_y)
			reversed_mouse_dir = Vector2(-mouse_direction.x, mouse_direction.y)
			mouse_pos = mouse_direction * 50
		
		$Line2D.points[3] = $Line2D.points[2] + ((mouse_direction if get_parent().previous_direction == 1 else reversed_mouse_dir) * 20)
		
		if get_parent().previous_direction == -1:
			$Line2D.points[3].x = -$Line2D.points[3].x
			$Line2D.points[2].x = -$Line2D.points[2].x
			$Line2D.points[1].x = -point_1_start_x
		else:
			$Line2D.points[1].x = point_1_start_x
		
		if Input.is_action_just_pressed("mouse_click") || Input.is_action_just_pressed("attack"):
			var bullet = loaded_bullet.instantiate()
			bullet.position = get_parent().position + $Line2D.points[3]
			bullet.direction = mouse_direction
			bullet.velocity = 7
			bullet.graphics_efficiency = get_parent().get_parent().graphics_efficiency
			get_parent().get_parent().add_child(bullet)
	else:
		visible = false
