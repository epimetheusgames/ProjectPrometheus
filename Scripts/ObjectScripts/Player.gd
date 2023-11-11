extends CharacterBody2D

# Speed multiplier for the player
@export var speed = 0.2
@export var jump_vel = 6
@export var gravity = 0.5
@export var friction_force = 1.2
@export var air_friction_force = 1.01
@export var max_speed = 3
@export var max_air_speed = 4.5
@export var jump_push_force = 0.225
@export var speed_hard_cap = 3.5
@export var jump_speed_boost = 1.1
var dont_apply_friction = false
var could_jump = false
var was_in_air = false
var just_jumped = false
var wasnt_moving = false

# Figure out the velocity based on the inputs.
func getInputVelocity(can_jump):
	var input_direction = Input.get_axis("left", "right")
	var max_movement_speed = max_speed
	
	if !can_jump:
		max_movement_speed = max_air_speed
	
	if abs(velocity.x) < max_movement_speed:
		return input_direction * speed
		
	return (abs(velocity.x) - max_movement_speed) * -input_direction
	
func checkJump():
	return Input.is_action_just_pressed("jump")
	
func canJump():
	return is_on_floor() || $CoyoteJumpTimer.time_left > 0

func _physics_process(_delta):
	# Apply gravity
	velocity.y += gravity
	
	dont_apply_friction = false
	just_jumped = false
	
	# Apply keyboard inputs.
	var can_jump = canJump()
	var input_velocity = getInputVelocity(can_jump)
	velocity.x += input_velocity
	
	# Check if we can jump
	if checkJump() and can_jump:
		just_jumped = true
		velocity.x *= jump_speed_boost
		velocity.y = -jump_vel
		
	# Implement coyote jumping system.
	if could_jump && !can_jump:
		$CoyoteJumpTimer.start()
		
	# If the player is holding the jump button, apply a slight upwards push.
	if Input.is_action_pressed("jump"):
		velocity.y -= jump_push_force
		
	# Hard cap the speed to supress speed glitches.
	if abs(velocity.x) > speed_hard_cap:
		velocity.x = max_speed if velocity.x > 1 else -max_speed
		
	# Apply friction.
	if input_velocity == 0:
		# Don't apply friction if the player is moving.
		if can_jump && (abs(velocity.x) != max_speed && Input.get_axis("left", "right") == 0):
			velocity.x /= friction_force
		else:
			velocity.x /= air_friction_force
	
	if was_in_air && can_jump:
		velocity.x /= 1.15
		
	# Add velocity to position.
	position += velocity
	
	# Collisions.
	move_and_slide()
		
	# Set player to be in the direction that it's moving.
	if Input.is_action_pressed("left"):
		$PlayerAnimation.scale.x = -1
		$AntennaAnimation.scale.x = -1
	elif Input.is_action_pressed("right"):
		$PlayerAnimation.scale.x = 1
		$AntennaAnimation.scale.x = 1
	else:
		#Reusing code here.
		$PlayerAnimation.play("Idle")
		
	# Play start walk animation when left or right is pressed.
	var direction_just_pressed = Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")
	var direction_pressed = Input.is_action_pressed("left") || Input.is_action_pressed("right")
	var both_pressed = Input.is_action_pressed("left") && Input.is_action_pressed("right")
	if direction_just_pressed && !both_pressed:
		$PlayerAnimation.play("StartWalk")
		
	# You cannot walk in the air, in the future add an anim for this.
	if !can_jump:
		$PlayerAnimation.play("InAir")
		
	# If you were in the air but hit the ground, go back to walking without 
	# start walk anim.
	if can_jump && $PlayerAnimation.animation == "InAir":
		$PlayerAnimation.play("Walking")
		
	# Play animations for walking.
	if both_pressed:
		$PlayerAnimation.play("Idle")
	elif direction_pressed && $PlayerAnimation.animation == "Idle":
		$PlayerAnimation.play("StartWalk")
		
	# If the player starts moving, play the antenna's start moving animation.
	if direction_just_pressed && !(velocity.x < 0.1 && velocity.x > -0.1) && $AntennaAnimation.animation == "Idle":
		$AntennaAnimation.play("StartMoving")
		
	# Sometimes the antenna can be stuck in Idle for whatever reason.
	if (velocity.x > 2 || velocity.x < -2) && $AntennaAnimation.animation == "Idle":
		$AntennaAnimation.play("StartMoving")
	
	# For coyote jumping, check if we can jump.
	if can_jump && !just_jumped:
		could_jump = true
	else:
		could_jump = false
	
	# If the antenna is moving and needs to stop, set it to end moving.
	if (velocity.x < 2 && velocity.x > -2):
		if $AntennaAnimation.animation == "Moving":
			$AntennaAnimation.play("EndMoving")
	
	# If the antenna animation stops moving but a direction is still pressed,
	# (e.g. the player is still moving), presumably because the player turned
	# around, set the animation back to moving, else it would have to complete
	# the entire EndMoving animation before going back. In the future, maybe 
	if $AntennaAnimation.animation == "EndMoving" && direction_pressed && !(velocity.x > -0.5 && velocity.x < 0.5):
		$AntennaAnimation.play("Moving")
		
	if !direction_pressed:
		wasnt_moving = true
	else:
		wasnt_moving = false
		
	if !can_jump:
		was_in_air = true
	else:
		was_in_air = false

# If the player enters a death zone, respawn it.
func _on_area_2d_area_entered(area):
	if area.name == "DeathZone":
		position = get_parent().get_parent().get_node("RespawnPos").position

# If start walk animation finishes, play walking animation.
func _on_animated_sprite_2d_animation_finished():
	if $PlayerAnimation.animation == "StartWalk":
		$PlayerAnimation.play("Walking")

# If the animation for ending movement is finished, switch to idle, if the
# animation for starting movement is finished, start moving.
func _on_antenna_animation_animation_finished():
	if $AntennaAnimation.animation == "EndMoving":
		$AntennaAnimation.play("Idle")
	if $AntennaAnimation.animation == "StartMoving":
		$AntennaAnimation.play("Moving")
