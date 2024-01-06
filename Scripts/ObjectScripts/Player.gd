extends CharacterBody2D

# Speed multiplier for the player
var speed = 0.2
var jump_vel = 4
var rocket_jump_vel = 6
var max_jump_speed_rocket = 8
var gravity = 0.5
var gravity_low = 0.03
var friction_force = 1.2
var air_friction_force = 1.01
var max_speed = 3
var max_air_speed = 4.5
var jump_push_force = 0.225
var rocket_jump_push_force = 0.32
var speed_hard_cap = 5
var previous_direction = 0
var character_type = 0

var in_second_ladder_area = false
var in_ladder_area = false
var climbing = false
var grappling = false
var disable_speed_cap = false
var low_gravity = false
var physics_player = false
var grappling_effects = false
var dont_apply_friction = false
var could_jump = false
var was_in_air = false
var just_jumped = false
var wasnt_moving = false
var was_climbing = false
var dead = false

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
		
		if absf(velocity.x) < max_movement_speed:
			return input_direction * speed
			
		return (absf(velocity.x) - max_movement_speed) * -input_direction
	
	return 0
	
func checkJump():
	return Input.is_action_just_pressed("jump")
	
func canJump():
	return is_on_floor()
	
func jump():
	just_jumped = true
	velocity.y = (-jump_vel if current_ability != "RocketBoost" else -rocket_jump_vel) * (1.2 if Engine.time_scale < 1 else 1)
	$PlayerAnimation.play("StartJump")
			
	if current_ability == "RocketBoost":
		$PlayerAnimation.play("StartJumpRockets")
			
	if current_ability == "Weapon":
		$PlayerAnimation.play("StartJumpSword")

func _physics_process(delta):
	if physics_player:
		return
	
	# Apply gravity if not grappling
	if !grappling_effects && !climbing:
		velocity.y += gravity
		
	if in_ladder_area:
		velocity.y /= 1.5
	
	dont_apply_friction = false
	just_jumped = false
	
	# Apply keyboard inputs.
	var can_jump = canJump()
	var input_velocity = getInputVelocity(can_jump)
	if !dead:
		velocity.x += input_velocity
	
	# Check if we can jump
	if checkJump() and (can_jump || $CoyoteJumpTimer.time_left > 0):
		if !in_ladder_area && !dead:
			jump()
			
	if Input.is_action_pressed("down") && climbing && !dead:
		velocity.y += jump_push_force
		
	# Implement coyote jumping system.
	if could_jump && !can_jump:
		$CoyoteJumpTimer.start() 
		
	# If the player is holding the jump button, apply a slight upwards push.
	if Input.is_action_pressed("jump") && !dead:
		if !climbing:
			velocity.y -= (jump_push_force if current_ability != "RocketBoost" else rocket_jump_push_force)
		else:
			velocity.y -= jump_push_force
			
		if in_ladder_area:
			velocity.x /= 1.3
			$FireParticlesBootsLeft.emitting = false
			$FireParticlesBootsRight.emitting = false
			climbing = true
			
			if !was_climbing:
				$PlayerAnimation.play("Climbing")
				
			if $PlayerAnimation.animation != "Climbing":
				$PlayerAnimation.play("Climbing")
		
	if Input.is_action_just_pressed("attack") && current_ability == "Weapon" && $NewDashCooldown.time_left == 0 && !dead:
		$PlayerAnimation.play("AttackSword")
		$DashStopCooldown.start()
		$NewDashCooldown.start()
		
		velocity.x = previous_direction * 5
		
	# Hard cap the speed to supress speed glitches.
	if absf(velocity.x) > speed_hard_cap && !disable_speed_cap:
		velocity.x = max_speed if velocity.x > 1 else -max_speed
	if absf(velocity.y) > (max_jump_speed_rocket + 1) && !disable_speed_cap:
		velocity.y = rocket_jump_vel if velocity.y > 1 else -rocket_jump_vel
		
	# If speed cap is disabled, ignore that.
	if absf(velocity.x) > speed_hard_cap * 2 && disable_speed_cap:
		velocity.x = max_speed * 2 if velocity.x > 0 else -max_speed * 2
	if absf(velocity.y) > rocket_jump_vel * 2 && disable_speed_cap:
		velocity.y = rocket_jump_vel * 2 if velocity.y > 0 else -rocket_jump_vel * 2
		
	# Apply friction.
	if input_velocity == 0:
		# Don't apply friction if the player is moving.
		if can_jump && (absf(velocity.x) != max_speed && Input.get_axis("left", "right") == 0):
			velocity.x /= friction_force
		else:
			velocity.x /= air_friction_force
	
	# If the player hits the ground, apply a slight decrement to the velocity.
	if was_in_air && can_jump:
		velocity.x /= 1.3
		
	# Add velocity to position.
	position += velocity * delta * 60
	
	# Collisions.
	move_and_slide()
	
	var metal_walk_boots_1 = get_parent().get_node("MetalWalkBoots1")
	var metal_walk_1 = get_parent().get_node("MetalWalk1")
	
	if metal_walk_boots_1.playing && !current_ability == "RocketBoost":
		metal_walk_1.play()
		metal_walk_boots_1.stop()
	if metal_walk_1.playing && current_ability == "RocketBoost":
		metal_walk_boots_1.play()
		metal_walk_1.stop()
	
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
					
					if metal_walk_1.volume_db < 7:
						metal_walk_1.volume_db += 1
						get_parent().get_node("MetalWalk2").volume_db += 1
					if metal_walk_boots_1.volume_db < 2:
						metal_walk_boots_1.volume_db += 0.5
						
						if metal_walk_boots_1.volume_db < -8:
							metal_walk_boots_1.volume_db = -8
					
					if metal_walk_1.playing == false && get_parent().get_node("MetalWalk2").playing == false && metal_walk_boots_1.playing == false:
						if current_ability == "RocketBoost":
							metal_walk_boots_1.play()
						else: 
							metal_walk_1.play()
		
		if !play_metal_walk:
			if metal_walk_1.volume_db > -20:
				metal_walk_1.volume_db -= 1
				get_parent().get_node("MetalWalk2").volume_db -= 1
				metal_walk_boots_1.volume_db -= 1
	
	if !can_jump:
		if metal_walk_1.volume_db > -20:
			metal_walk_1.volume_db -= 1
			metal_walk_1.volume_db -= 1
			metal_walk_boots_1.volume_db -= 1
			
	var save_load_framework = get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework")
	
	if $BulletBadHurtcooldown.time_left > 0:
		save_load_framework.bulge_amm = 1.0
		save_load_framework.static_amm = 0.1
	elif $BulletHurtCooldown.time_left > 0:
		save_load_framework.bulge_amm = 0.4
		save_load_framework.static_amm = 0.05
	elif get_parent().get_node("Camera").get_node("AbilityManager").get_node("AbililtySwitchTimer").time_left > 5:
		save_load_framework.bulge_amm = 0
		save_load_framework.static_amm = 0
		
	var left_pressed = Input.is_action_pressed("left")
	var right_pressed = Input.is_action_pressed("right")
		
	if !(left_pressed && right_pressed) && !dead:
		
		# Set player to be in the direction that it's moving.
		if left_pressed:
			$PlayerAnimation.scale.x = -1
			$AntennaAnimation.scale.x = -1
			
			if !get_parent().graphics_efficiency:
				$SparkParticles.position.x = 7
				
			if previous_direction == 1 && $PlayerAnimation.animation != "Climbing":
				if current_ability == "RocketBoost":
					$PlayerAnimation.play("SwitchDirectionsRockets")
				
				elif current_ability == "Weapon":
					$PlayerAnimation.play("SwitchDirectionsSword")
				
				else:
					$PlayerAnimation.play("SwitchDirections")
					
		elif right_pressed:
			$PlayerAnimation.scale.x = 1
			$AntennaAnimation.scale.x = 1
			if !get_parent().graphics_efficiency:
				$SparkParticles.position.x = -11
			
			if previous_direction == -1 && $PlayerAnimation.animation != "Climbing":
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
			$PlayerAnimation.animation != "StartJumpSword" &&
			$PlayerAnimation.animation != "Climbing"):
			#Reusing code here.
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("IdleRockets")
				
			elif current_ability == "Weapon":
				$PlayerAnimation.play("IdleSword")
				
			else:
				$PlayerAnimation.play("Idle")
				
		if (($PlayerAnimation.animation == "InAirUp" || 
			$PlayerAnimation.animation == "InAirUpRockets" ||
			$PlayerAnimation.animation == "InAirUpSword") &&
			$PlayerAnimation.animation != "Climbing" && can_jump):
			
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("IdleRockets")
				
			elif current_ability == "Weapon":
				$PlayerAnimation.play("IdleSword")
				
			else:
				$PlayerAnimation.play("Idle")
			
	if Input.is_action_pressed("jump") && current_ability == "RocketBoost" && !can_jump && !climbing:
		$FireParticlesBootsLeft.emitting = true
		$FireParticlesBootsRight.emitting = true
		
		if get_parent().get_node("RocketBoost").playing == false && !climbing:
			get_parent().get_node("RocketBoost").play()
	else:
		$FireParticlesBootsLeft.emitting = false
		$FireParticlesBootsRight.emitting = false
		get_parent().get_node("RocketBoost").playing = false
		
	# Play start walk animation when left or right is pressed.
	var direction_just_pressed = Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")
	var direction_pressed = left_pressed || right_pressed
	var both_pressed = left_pressed && right_pressed
	if (direction_just_pressed && !both_pressed && ($PlayerAnimation.animation != "SwitchDirections" &&
		$PlayerAnimation.animation != "SwitchDirectionsRockets" &&
		$PlayerAnimation.animation != "SwitchDirectionsSword")) && !dead:
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
		if velocity.y > 0:
			$FireParticlesBootsLeft.emitting = false 
			$FireParticlesBootsRight.emitting = false 
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
		
	# Play animations for walking.
	if both_pressed && $PlayerAnimation.animation != "Climbing":
		$PlayerAnimation.play("Idle")
				
		if current_ability == "RocketBoost":
			$PlayerAnimation.play("IdleRockets")
				
		if current_ability == "Weapon":
			$PlayerAnimation.play("IdleSword")
	elif direction_pressed && ($PlayerAnimation.animation == "Idle" ||$PlayerAnimation.animation == "IdleRockets" || $PlayerAnimation.animation == "IdleSword" && $PlayerAnimation.animation != "Climbing"):
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
	# the entire EndMoving animation before going back. 
	if $AntennaAnimation.animation == "EndMoving" && direction_pressed && !(velocity.x > -0.5 && velocity.x < 0.5):
		$AntennaAnimation.play("Moving")
	
	if $BulletBadHurtcooldown.time_left > 0 && !dead && $HurtVibrationTimer.time_left == 0:
		Engine.time_scale = 0.65
	elif !dead && $HurtVibrationTimer.time_left == 0:
		Engine.time_scale = 1
	
		
	wasnt_moving = !direction_pressed
	was_in_air = !can_jump
	was_climbing = climbing
	
	# For coyote jumping, check if we can jump.
	if can_jump && !just_jumped:
		could_jump = true
	else:
		could_jump = false
		
	if !(left_pressed && right_pressed):
		if left_pressed:
			previous_direction = -1
		elif right_pressed:
			previous_direction = 1

# If the player enters a death zone, respawn it.
func _on_area_2d_area_entered(area):
	if area.name == "ItemSwitcherArea":
		var ability_manager = get_parent().get_node("Camera").get_node("AbilityManager")
		var switch_ability = area.get_parent().item_switch_type
		if current_ability == "Weapon" && switch_ability == "RocketBoost":
			ability_manager.next_ability()
		elif current_ability == "RocketBoost" && switch_ability == "ArmGun":
			ability_manager.next_ability()
		elif current_ability == "ArmGun" && switch_ability == "Grapple":
			ability_manager.next_ability()
		elif current_ability == "Grapple" && switch_ability == "Weapon":
			ability_manager.next_ability()
	
	if area.name == "LadderClimbArea":
		if in_ladder_area:
			in_second_ladder_area = true
		
		in_ladder_area = true
	if area.name == "CheckpointCollision":
		respawn_pos = position
		respawn_ability = area.get_parent().player_checkpoint_item
		area.get_parent().activate()
	if area.name == "DeathZone":
		get_parent().get_node("Camera/CloseAnimator").closing = true
	if area.name == "BulletHurter" || area.name == "JumpHurtBox":
		if area.name == "BulletHurter":
			area.get_parent().queue_free()
		elif area.name == "JumpHurtBox":
			if area.get_parent().health <= 0:
				return
			
			if $DashStopCooldown.time_left > 0:
				return
				
		Input.start_joy_vibration(0, 1, 1)
		Engine.time_scale = 0.6
		$HurtVibrationTimer.start()
		
		if $BulletBadHurtcooldown.time_left > 0:
			get_parent().get_node("Camera/CloseAnimator").closing = true
		elif $BulletHurtCooldown.time_left > 0:
			$BulletBadHurtcooldown.start()
			$PlayerAnimation.modulate.g = 0
			$PlayerAnimation.modulate.b = 0
		else:
			$BulletHurtCooldown.start()
			$PlayerAnimation.modulate.g = 0.8
			$PlayerAnimation.modulate.b = 0.6
			
func die():
	get_parent().get_parent().get_node("NextLevel").restart_level(respawn_pos, respawn_ability)
			
func _on_player_hurtbox_area_exited(area):
	if area.name == "LadderClimbArea":
		if in_second_ladder_area:
			in_second_ladder_area = false
		else:
			in_ladder_area = false
			climbing = false
			jump()
			
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

func _on_hurt_vibration_timer_timeout():
	Engine.time_scale = 1
	Input.stop_joy_vibration(0)
