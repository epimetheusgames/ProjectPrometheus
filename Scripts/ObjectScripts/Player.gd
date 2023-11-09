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
var just_jumped = false

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
		
	# Add velocity to position.
	position += velocity
	
	# Collisions.
	move_and_slide()
	
	# For coyote jumping, check if we can jump.
	if can_jump && !just_jumped:
		could_jump = true
	else:
		could_jump = false

func _on_area_2d_area_entered(area):
	if area.name == "DeathZone":
		position = get_parent().get_parent().get_node("RespawnPos").position
