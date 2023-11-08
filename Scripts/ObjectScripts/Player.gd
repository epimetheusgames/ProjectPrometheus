extends CharacterBody2D

# Speed multiplier for the player
@export var speed = 0.2
@export var jump_vel = 10
@export var gravity = 0.5
@export var friction_force = 1.1
@export var air_friction_force = 1.15
@export var max_speed = 5
@export var max_air_speed = 4.5

# Figure out the velocity based on the inputs.
func getInputVelocity(can_jump):
	var input_direction = Input.get_axis("left", "right")
	var max_movement_speed = max_speed
	
	if !can_jump:
		max_movement_speed = max_air_speed
	
	if abs(velocity.x) < max_movement_speed:
		return input_direction * speed
	return 0
	
func checkJump():
	return Input.is_action_just_pressed("jump")
	
func canJump():
	return is_on_floor()

func _physics_process(_delta):
	# Apply gravity
	velocity.y += gravity
	
	# Apply keyboard inputs.
	var can_jump = canJump()
	var input_velocity = getInputVelocity(can_jump)
	velocity.x += input_velocity
	if checkJump() and canJump():
		velocity.y = -jump_vel
		
	if input_velocity == 0 || (can_jump && ((input_velocity > 0 && velocity.x < 0) || (input_velocity < 0 && velocity.x > 0))):
		if can_jump:
			velocity.x /= friction_force	
		else:
			velocity.x /= air_friction_force
		
	# Add velocity to position.
	position += velocity
	
	# Collisions.
	move_and_slide()

func _on_area_2d_area_entered(area):
	position = get_parent().get_parent().get_node("RespawnPos").position
