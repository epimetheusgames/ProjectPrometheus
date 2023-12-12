extends CharacterBody2D

# Speed multiplier for the player
var speed = 0.2
var jump_vel = 4
var rocket_jump_vel = 6
var gravity = 0.5
var gravity_low = 0.03
var friction_force = 1.2
var air_friction_force = 1.01
var max_speed = 3
var max_air_speed = 4.5
var jump_push_force = 0.225
var rocket_jump_push_force = 0.32
var speed_hard_cap = 5

var disable_speed_cap = false
var low_gravity = false
var physics_player = false
var grappling_effects = false
var dont_apply_friction = false
var could_jump = false
var was_in_air = false
var just_jumped = false
var wasnt_moving = false
var previous_direction = 0
var character_type = 0

var current_ability = "Weapon"

@onready var respawn_pos = position
@onready var respawn_ability = current_ability

func _ready():
	var player_type_1 = preload("res://Objects/StaticObjects/PlayerType1.tres")
	var player_type_2 = preload("res://Objects/StaticObjects/PlayerType2.tres")
	var player_type_3 = preload("res://Objects/StaticObjects/PlayerType3.tres")
	var player_type_4 = preload("res://Objects/StaticObjects/PlayerType4.tres")
	
	if character_type == 1:
		$PlayerAnimation.sprite_frames = player_type_1
	if character_type == 2:
		$PlayerAnimation.sprite_frames = player_type_2
	if character_type == 3:
		$PlayerAnimation.sprite_frames = player_type_3
	if character_type == 4:
		$PlayerAnimation.sprite_frames = player_type_4

# Figure out the velocity based on the inputs.
func getInputVelocity(can_jump):
	if $PlayerAnimation.animation != "AttackSword":
		var input_direction = Input.get_axis("left", "right")
		var max_movement_speed = max_speed
		
		if !can_jump:
			max_movement_speed = max_air_speed
		
		if abs(velocity.x) < max_movement_speed:
			return input_direction * speed
			
		return (abs(velocity.x) - max_movement_speed) * -input_direction
	
	return 0
	
func checkJump():
	return Input.is_action_just_pressed("jump")
	
func canJump():
	return is_on_floor()
	
func jump():
	just_jumped = true
	velocity.y = -jump_vel if current_ability != "RocketBoost" else -rocket_jump_vel
	$PlayerAnimation.play("StartJump")
			
	if current_ability == "RocketBoost":
		$PlayerAnimation.play("StartJumpRockets")
			
	if current_ability == "Weapon":
		$PlayerAnimation.play("StartJumpSword")

func _physics_process(_delta):
	if physics_player:
		return
	
	# Apply gravity if not grappling
	if !grappling_effects:
		velocity.y += gravity
	
	dont_apply_friction = false
	just_jumped = false
	
	# Apply keyboard inputs.
	var can_jump = canJump()
	var input_velocity = getInputVelocity(can_jump)
	velocity.x += input_velocity
	
	# Check if we can jump
	if checkJump() and (can_jump || $CoyoteJumpTimer.time_left > 0):
		jump()
		
	# Implement coyote jumping system.
	if could_jump && !can_jump:
		$CoyoteJumpTimer.start() 
		
	# If the player is holding the jump button, apply a slight upwards push.
	if Input.is_action_pressed("jump"):
		velocity.y -= jump_push_force if current_ability != "RocketBoost" else rocket_jump_push_force
		
	if Input.is_action_just_pressed("attack") && current_ability == "Weapon" && $NewDashCooldown.time_left == 0:
		$PlayerAnimation.play("AttackSword")
		$DashStopCooldown.start()
		$NewDashCooldown.start()
		
		velocity.x = previous_direction * 5
		
	# Hard cap the speed to supress speed glitches.
	if abs(velocity.x) > speed_hard_cap && !disable_speed_cap:
		velocity.x = max_speed if velocity.x > 1 else -max_speed
	if abs(velocity.y) > rocket_jump_vel + 1 && !disable_speed_cap:
		velocity.y = rocket_jump_vel if velocity.y > 1 else -rocket_jump_vel
		
	# Apply friction.
	if input_velocity == 0:
		# Don't apply friction if the player is moving.
		if can_jump && (abs(velocity.x) != max_speed && Input.get_axis("left", "right") == 0):
			velocity.x /= friction_force
		else:
			velocity.x /= air_friction_force
	
	# If the player hits the ground, apply a slight decrement to the velocity.
	if was_in_air && can_jump:
		velocity.x /= 1.3
		
	# Add velocity to position.
	position += velocity
	
	# Collisions.
	move_and_slide()
	
	if get_parent().get_node("MetalWalkBoots1").playing && !current_ability == "RocketBoost":
		get_parent().get_node("MetalWalk1").play()
		get_parent().get_node("MetalWalkBoots1").stop()
	if get_parent().get_node("MetalWalk1").playing && current_ability == "RocketBoost":
		get_parent().get_node("MetalWalkBoots1").play()
		get_parent().get_node("MetalWalk1").stop()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if !get_parent().graphics_efficiency:
			$GravelWalkingParticles.emitting = false
		var play_metal_walk = false
		
		if collision && collision.get_collider() is TileMap:
			if (velocity.x > 1 || velocity.x < -1):
				if collision.get_collider().name == "Gravel" && !get_parent().graphics_efficiency:
					$GravelWalkingParticles.emitting = true
				if collision.get_collider().name == "Ingame":
					play_metal_walk = true
					
					if get_parent().get_node("MetalWalk1").volume_db < 7:
						get_parent().get_node("MetalWalk1").volume_db += 1
						get_parent().get_node("MetalWalk2").volume_db += 1
					if get_parent().get_node("MetalWalkBoots1").volume_db < 2:
						get_parent().get_node("MetalWalkBoots1").volume_db += 0.5
						
						if get_parent().get_node("MetalWalkBoots1").volume_db < -8:
							get_parent().get_node("MetalWalkBoots1").volume_db = -8
					
					if get_parent().get_node("MetalWalk1").playing == false && get_parent().get_node("MetalWalk2").playing == false && get_parent().get_node("MetalWalkBoots1").playing == false:
						if current_ability == "RocketBoost":
							get_parent().get_node("MetalWalkBoots1").play()
						else: 
							get_parent().get_node("MetalWalk1").play()
		
		if !play_metal_walk:
			if get_parent().get_node("MetalWalk1").volume_db > -20:
				get_parent().get_node("MetalWalk1").volume_db -= 1
				get_parent().get_node("MetalWalk2").volume_db -= 1
				get_parent().get_node("MetalWalkBoots1").volume_db -= 1
	
	if !can_jump:
		if get_parent().get_node("MetalWalk1").volume_db > -20:
			get_parent().get_node("MetalWalk1").volume_db -= 1
			get_parent().get_node("MetalWalk2").volume_db -= 1
			get_parent().get_node("MetalWalkBoots1").volume_db -= 1
		
	if !(Input.is_action_pressed("left") && Input.is_action_pressed("right")):
		# Set player to be in the direction that it's moving.
		if Input.is_action_pressed("left"):
			$PlayerAnimation.scale.x = -1
			$AntennaAnimation.scale.x = -1
			if !get_parent().graphics_efficiency:
				$SparkParticles.position.x = 7
			if previous_direction == 1:
				if current_ability == "RocketBoost":
					$PlayerAnimation.play("SwitchDirectionsRockets")
				
				elif current_ability == "Weapon":
					$PlayerAnimation.play("SwitchDirectionsSword")
				
				else:
					$PlayerAnimation.play("SwitchDirections")
		elif Input.is_action_pressed("right"):
			$PlayerAnimation.scale.x = 1
			$AntennaAnimation.scale.x = 1
			if !get_parent().graphics_efficiency:
				$SparkParticles.position.x = -11
			
			if previous_direction == -1:
				if current_ability == "RocketBoost":
					$PlayerAnimation.play("SwitchDirectionsRockets")
				
				elif current_ability == "Weapon":
					$PlayerAnimation.play("SwitchDirectionsSword")
				
				else:
					$PlayerAnimation.play("SwitchDirections")
		elif ($PlayerAnimation.animation != "Landing" && 
			$PlayerAnimation.animation != "LandingRockets" && 
			$PlayerAnimation.animation != "LandingSword" && 
			$PlayerAnimation.animation != "AttackSword" && 
			$PlayerAnimation.animation != "StartJump" && 
			$PlayerAnimation.animation != "StartJumpRockets" && 
			$PlayerAnimation.animation != "StartJumpSword"):
			#Reusing code here.
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("IdleRockets")
				
			elif current_ability == "Weapon":
				$PlayerAnimation.play("IdleSword")
				
			else:
				$PlayerAnimation.play("Idle")
				
	
		if (($PlayerAnimation.animation == "InAirUp" || 
			$PlayerAnimation.animation == "InAirUpRockets" ||
			$PlayerAnimation.animation == "InAirUpSword") && can_jump):
			
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("IdleRockets")
				
			elif current_ability == "Weapon":
				$PlayerAnimation.play("IdleSword")
				
			else:
				$PlayerAnimation.play("Idle")
			
	if Input.is_action_pressed("jump") && current_ability == "RocketBoost" && !can_jump:
		$FireParticlesBootsLeft.emitting = true
		$FireParticlesBootsRight.emitting = true
		
		if get_parent().get_node("RocketBoost").playing == false:
			get_parent().get_node("RocketBoost").play()
	else:
		$FireParticlesBootsLeft.emitting = false
		$FireParticlesBootsRight.emitting = false
		get_parent().get_node("RocketBoost").playing = false
		
	# Play start walk animation when left or right is pressed.
	var direction_just_pressed = Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")
	var direction_pressed = Input.is_action_pressed("left") || Input.is_action_pressed("right")
	var both_pressed = Input.is_action_pressed("left") && Input.is_action_pressed("right")
	if (direction_just_pressed && !both_pressed && ($PlayerAnimation.animation != "SwitchDirections" &&
		$PlayerAnimation.animation != "SwitchDirectionsRockets" &&
		$PlayerAnimation.animation != "SwitchDirectionsSword")):
		$PlayerAnimation.play("StartWalk")
				
		if current_ability == "RocketBoost":
			$PlayerAnimation.play("StartWalkRockets")
				
		if current_ability == "Weapon":
			$PlayerAnimation.play("StartWalkSword")
		
	# You cannot walk in the air.
	if !can_jump && velocity.y > 2:
		if velocity.y < 0:
			$PlayerAnimation.play("InAirUp")
				
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("InAirUpRockets")
				
			if current_ability == "Weapon":
				$PlayerAnimation.play("InAirUpSword")
		if velocity.y > 0 && current_ability == "RocketBoost":
			$PlayerAnimation.play("InAirDown")
				
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("InAirDownRockets")
				
			if current_ability == "Weapon":
				$PlayerAnimation.play("InAirDownSword")
		
	# If you were in the air but hit the ground, go back to walking without 
	# start walk anim.
	if was_in_air && can_jump && ($PlayerAnimation.animation == "InAirDown"
								  || $PlayerAnimation.animation == "InAirDownRockets"
								  || $PlayerAnimation.animation == "InAirDownSword"):
		$PlayerAnimation.play("Landing")
				
		if current_ability == "RocketBoost":
			$PlayerAnimation.play("LandingRockets")
				
		if current_ability == "Weapon":
			$PlayerAnimation.play("LandingSword")
		
	# Play animations for walking.var active = false
	if both_pressed:
		$PlayerAnimation.play("Idle")
				
		if current_ability == "RocketBoost":
			$PlayerAnimation.play("IdleRockets")
				
		if current_ability == "Weapon":
			$PlayerAnimation.play("IdleSword")
	elif direction_pressed && ($PlayerAnimation.animation == "Idle" ||$PlayerAnimation.animation == "IdleRockets" || $PlayerAnimation.animation == "IdleSword"):
		$PlayerAnimation.play("StartWalk")
				
		if current_ability == "RocketBoost":
			$PlayerAnimation.play("StartWalkRockets")
				
		if current_ability == "Weapon":
			$PlayerAnimation.play("StartWalkSword")
		
	# If the player starts moving, play the antenna's start moving animation.
	if direction_just_pressed && !(velocity.x < 0.1 && velocity.x > -0.1) && $AntennaAnimation.animation == "Idle":
		$AntennaAnimation.play("StartMoving")
		
	# Sometimes the antenna can be stuck in Idle for whatever reason.
	if (velocity.x > 2 || velocity.x < -2) && $AntennaAnimation.animation == "Idle":
		$AntennaAnimation.play("StartMoving")
	
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
	
	# For coyote jumping, check if we can jump.
	if can_jump && !just_jumped:
		could_jump = true
	else:
		could_jump = false
		
	if !(Input.is_action_pressed("left") && Input.is_action_pressed("right")):
		if Input.is_action_pressed("left"):
			previous_direction = -1
		elif Input.is_action_pressed("right"):
			previous_direction = 1

# If the player enters a death zone, respawn it.
func _on_area_2d_area_entered(area):
	if area.name == "CheckpointCollision":
		respawn_pos = position
		respawn_ability = current_ability
	if area.name == "DeathZone":
		get_parent().get_parent().get_node("NextLevel").restart_level(respawn_pos, respawn_ability)
	if area.name == "BulletHurter" || area.name == "JumpHurtBox":
		if area.name == "BulletHurter":
			area.get_parent().queue_free()
		elif area.name == "JumpHurtBox":
			if area.get_parent().health <= 0:
				return
		
		if $BulletBadHurtcooldown.time_left > 0:
			get_parent().get_parent().get_node("NextLevel").restart_level(respawn_pos, respawn_ability)
		elif $BulletHurtCooldown.time_left > 0:
			$BulletBadHurtcooldown.start()
			$PlayerAnimation.modulate.g = 0
			$PlayerAnimation.modulate.b = 0
		else:
			$BulletHurtCooldown.start()
			$PlayerAnimation.modulate.g = 0.8
			$PlayerAnimation.modulate.b = 0.6
			
# If start walk animation finishes, play walking animation.
func _on_animated_sprite_2d_animation_finished():
	if $PlayerAnimation.animation == "StartWalk" || $PlayerAnimation.animation == "Landing":
		$PlayerAnimation.play("Walking")
				
	if current_ability == "RocketBoost" && ($PlayerAnimation.animation == "StartWalkRockets" || $PlayerAnimation.animation == "LandingRockets"):
		$PlayerAnimation.play("WalkingRockets")
				
	if current_ability == "Weapon" && ($PlayerAnimation.animation == "StartWalkSword" || $PlayerAnimation.animation == "LandingSword"):
		$PlayerAnimation.play("WalkingSword")
			
	if $PlayerAnimation.animation == "SwitchDirections":
		$PlayerAnimation.play("StartWalk")
				
	if current_ability == "RocketBoost" && $PlayerAnimation.animation == "SwitchDirectionsRockets":
		$PlayerAnimation.play("StartWalkRockets")
				
	if current_ability == "Weapon" && $PlayerAnimation.animation == "SwitchDirectionsSword":
		$PlayerAnimation.play("StartWalkSword")
	
	if $PlayerAnimation.animation == "AttackSword":
		$PlayerAnimation.play("StartWalkSword")
			
	if $PlayerAnimation.animation == "StartJump":
		$PlayerAnimation.play("InAirUp")
				
	if current_ability == "RocketBoost" && $PlayerAnimation.animation == "StartJumpRockets":
		$PlayerAnimation.play("InAirUpRockets")
				
	if current_ability == "Weapon" && $PlayerAnimation.animation == "StartJumpSword":
		$PlayerAnimation.play("InAirUpSword")

# If the animation for ending movement is finished, switch to idle, if the
# animation for starting movement is finished, start moving.
func _on_antenna_animation_animation_finished():
	if $AntennaAnimation.animation == "EndMoving":
		$AntennaAnimation.play("Idle")
	if $AntennaAnimation.animation == "StartMoving":
		$AntennaAnimation.play("Moving")

func _on_metal_walk_1_finished():
	get_parent().get_node("MetalWalk2").play()
	
func _on_metal_walk_2_finished():
	get_parent().get_node("MetalWalk1").play()

func _on_metal_walk_boots_1_finished():
	get_parent().get_node("MetalWalkBoots1").play()

func _on_rocket_boost_finished():
	get_parent().get_node("RocketBoost").play()

func _on_bullet_hurt_cooldown_timeout():
	if $BulletBadHurtcooldown.time_left == 0:
		$PlayerAnimation.modulate.g = 1
		$PlayerAnimation.modulate.b = 1

func _on_bullet_bad_hurtcooldown_timeout():
	$PlayerAnimation.modulate.g = 1
	$PlayerAnimation.modulate.b = 1

func _on_dash_stop_cooldown_timeout():
	velocity.x = 0
