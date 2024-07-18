# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Manages ArmGun ability and shoots bullets.                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


# Preloaded bullet to shoot.
@onready var loaded_bullet = preload("res://Objects/StaticObjects/PlayerBullet.tscn")

# The x position of point 1 for figuring out the Line2D of the ArmGun. From the line2D
# we can position the sprites to align to it.
@onready var point_1_start_x = $Line2D.points[1].x

# If the current player ability is the ArmGun.
var active = false

var mouse_direction = Vector2.ZERO

func _process(_delta):
	# Only run ArmGun if active.
	if active:
		# Set visible to true if active.
		visible = true
		
		# Get mouse_position in the viewport.
		var mouse_pos = get_viewport().get_mouse_position() - Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
		
		# Sometimes the player is backwards I think.
		if get_parent().previous_direction == -1:
			mouse_pos.x = -mouse_pos.x
		
		# Calculate the direction of the Line2D.
		$Line2D.points[2].x = mouse_pos.x / 100 + (mouse_pos.y / 80) - 20
		$Line2D.points[2].y = -25 - (mouse_pos.x / 150) + (mouse_pos.y / 200)
		
		var reversed_points_2 = Vector2(-$Line2D.points[2].x, $Line2D.points[2].y)
		
		var reversed_mouse_dir: Vector2

		if len(Input.get_connected_joypads()) == 0:
			# Get the direction from the ArmGun to the mouse.
			mouse_direction += ((get_global_mouse_position() - (get_parent().position + get_parent().get_parent().position + (Vector2(-12, -18) if get_parent().previous_direction == 1 else Vector2(8, -18)))).normalized() - mouse_direction) * 0.5
			
			# Reversed mouse direction because the player faces in two directions.
			reversed_mouse_dir = Vector2(-mouse_direction.x, mouse_direction.y)
		
		# For controller
		if len(Input.get_connected_joypads()) > 0:
			# Set mouse to be invisible when using controller.
			$CrosshairMouseOverlay.visible = false
			
			var controller_joy_dir_x
			var controller_joy_dir_y

			# On some systems there's a void inactive joypad. Ignore that.
			if len(Input.get_connected_joypads()) > 1:
				controller_joy_dir_x = Input.get_joy_axis(Input.get_connected_joypads()[1], JOY_AXIS_RIGHT_X)
				controller_joy_dir_y = Input.get_joy_axis(Input.get_connected_joypads()[1], JOY_AXIS_RIGHT_Y)
			else:
				controller_joy_dir_x = Input.get_joy_axis(Input.get_connected_joypads()[0], JOY_AXIS_RIGHT_X)
				controller_joy_dir_y = Input.get_joy_axis(Input.get_connected_joypads()[0], JOY_AXIS_RIGHT_Y)

			# Override mouse_direction with controller joystick direction.
			mouse_direction += (Vector2(controller_joy_dir_x, controller_joy_dir_y).normalized() - mouse_direction) * 0.25
			reversed_mouse_dir = Vector2(-mouse_direction.x, mouse_direction.y)

			# The mouse is actually a lot farther away than 1 pixel.
			mouse_pos = mouse_direction * 50
		
		# Set position of the end of the ArmGun on the Line2D.
		$Line2D.points[3] = $Line2D.points[2] + ((mouse_direction if get_parent().previous_direction == 1 else reversed_mouse_dir) * 20)
		
		# Based on direction set rotation.
		if get_parent().previous_direction == -1:
			$Line2D.points[3].x = -$Line2D.points[3].x
			$Line2D.points[2].x = -$Line2D.points[2].x
			$Line2D.points[1].x = -point_1_start_x
			
			# Maths to align sprites to Line2D.
			$Segment1.rotation_degrees = 48
			$Segment1.position.x = 10
			$Segment2.rotation_degrees = -27.4
			$Segment2.position.x = 12
			$Segment3.position = (Vector2(8, -18) + mouse_direction * 8)
			$Hinge1.position.x = 15
			$Hinge2.position.x = 7
			$Segment3.flip_h = false
		else:
			$Line2D.points[1].x = point_1_start_x
			
			$Segment1.rotation_degrees = -48
			$Segment1.position.x = -14
			$Segment2.rotation_degrees = 27.4
			$Segment2.position.x = -16
			$Segment3.position = (Vector2(-12, -18) + mouse_direction * 8)
			$Hinge1.position.x = -19
			$Hinge2.position.x = -14
			$Segment3.flip_h = true
			
		# This one's rotation is literally the direction of the mouse.
		$Segment3.rotation = atan2(mouse_direction.y, mouse_direction.x) - (1.0 / 2.0) * PI
		
		# Set position of mouse overlay sprite to be the position of the mouse.
		$CrosshairMouseOverlay.position = get_local_mouse_position()

		# Set rotation of mouse because that looks cool.
		$CrosshairMouseOverlay.rotation = $Segment3.rotation + deg_to_rad(225)
		
		# Point the laser in the direction of the mouse
		$LinePorabola.points[0] = $Segment3.position
		$LinePorabola.points[1] = $Segment3.position + mouse_direction * 500
		
		# Spawn a bullet if the player presses shoot.
		if (Input.is_action_pressed("mouse_click") || Input.is_action_pressed("attack")) && $CrosshairMouseOverlay.animation == "Idle":
			$ShootLaser.play()
			$CrosshairMouseOverlay.play("Shoot")
			var bullet = loaded_bullet.instantiate()
			bullet.position = get_parent().position + (Vector2(8, -18) if get_parent().previous_direction == -1 else Vector2(-12, -18)) + mouse_direction * 16
			bullet.direction = mouse_direction
			bullet.velocity = 7
			bullet.graphics_efficiency = get_parent().get_parent().graphics_efficiency
			get_parent().get_parent().add_child(bullet)
	else:
		# If inactive, become invisible.
		visible = false

# Set mouse shooting animation back to idle after finished shooting.
func _on_crosshair_mouse_overlay_animation_finished():
	if $CrosshairMouseOverlay.animation == "Shoot":
		$CrosshairMouseOverlay.play("Idle")
