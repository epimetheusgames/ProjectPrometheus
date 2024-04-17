# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Player physics and animations script. Probably should be seperated into two scripts. Handles death,    |
# attacks, and runs animations of antenna and player. Grapple and ArmGun scripts are seperated into      |
# child nodes.                                                                                           |
# -------------------------------------------------------------------------------------------------------|


extends CharacterBody2D


# ------------------------ NUMBER VALUES ------------------------

# Speed multiplier for the player
var speed = 0.2

# One-time jump velocity
var jump_vel = 4.5

# One-time rocket jump velocity.
var rocket_jump_vel = 6

# Maximum speed when jumping with rocket boosts.
var max_jump_speed_rocket = 8

# Per-frame gravity.
var gravity = 0.5

# Friction divider when slowing down.
var friction_force = 1.4

# Friction divider when slowing down in the air.
var air_friction_force = 1.3

# Maximum walking speed.
var max_speed = 3

# Maximum air speed (this allows you to go faster in the air)
var max_air_speed = 4.5

# Per frame jump force when holding jump button.
var jump_push_force = 0.225

# Per frame jump force when holding jump button and using rocket boots.
var rocket_jump_push_force = 0.32

# Hard speed cap to avoid glitches. This is for everywhere.
var speed_hard_cap = 5

# The previous direction the player is going (-1, 0, or 1)
var previous_direction = 0

# Character type (for example white, black, male, or female)
var character_type = 0

# The speed of the conveyor set by the conveyor the player steps on.
var conveyor_speed = 0

# The direction of the conveyor.
var conveyor_direction = 0

# The force of the player when impacting physics objects.
var push_force = 100


# ------------------------ BOOLIAN VALUES ------------------------

# Check if we're in two ladder areas at once.
var in_second_ladder_area = false

# Check if we're in one ladder area (or two).
var in_ladder_area = false

# Check if we're climbing a ladder right now.
var climbing = false

# If we're grappling right now.
var grappling = false

# Disable speed cap for grappling (not hard speed cap though)
var disable_speed_cap = false

# Low gravity doesn't do anything but I think it might be set from another 
# scene and I want to avoid errors lol.
var low_gravity = false

# Doesn't do anything, probably never will.
var physics_player = false

# Check if the effects of grappling are in effect (lol idk what i'm talking
# about.)
var grappling_effects = false

# Don't applay friction to the player, in some cases we want this.
var dont_apply_friction = false

# If we could jump in the previous frame.
var could_jump = false

# Line 100!

# If we were in the air in the previous frame.
var was_in_air = false

# If we just jumped in the previous frame.
var just_jumped = false

# If we weren't moving in the previous frame.
var wasnt_moving = false

# If we were climbing in the previous frame.
var was_climbing = false

# Check if the player is dead.
var dead = false

# If we're IN a conveyor belt???
var in_conveyor_belt = false

# I have a feeling this does nothing but maybe the conveyor likes it.
var dont_reset_conveyor = false

# Check if we have a key right now.
var has_key = false

# The node of the key (ik this isn't a boolian cope).
var key = null

# Check if we're swording right now.
var is_swiping_sword = false

# Disable controls for death.
var disable_controlls = false


# The string value of the current ability.
var current_ability = "Weapon"


# ------------------------ ON READY VALUES ------------------------

# The position that we respawn at.
@onready var respawn_pos = position

# The ability we respawn with.
@onready var respawn_ability = current_ability

# Preloaded keycard scene.
@onready var loaded_keycard = preload("res://Objects/StaticObjects/Key.tscn")

# Nodes for dash sound effects to randomly switch between.
@onready var dash_sound_effects = [
	$"../SwordDash1",
	$"../SwordDash2",
	$"../SwordDash3",
	$"../SwordDash4",
]


# Run when the player spawns in (this includes respawning!)
func _ready():
	# Preload player types (for example white, black, male, female)
	var player_type_1 = preload("res://Objects/StaticObjects/PlayerType1.tres")
	var player_type_2 = preload("res://Objects/StaticObjects/PlayerType2.tres")
	var player_type_3 = preload("res://Objects/StaticObjects/PlayerType3.tres")
	var player_type_4 = preload("res://Objects/StaticObjects/PlayerType4.tres")
	
	# Set character type to PlayerAnimation. This is the only time we need
	# to mess with character type in the code.
	if character_type == 1:
		$PlayerAnimation.sprite_frames = player_type_1
	if character_type == 2:
		$PlayerAnimation.sprite_frames = player_type_2
	if character_type == 3:
		$PlayerAnimation.sprite_frames = player_type_3
	if character_type == 4:
		$PlayerAnimation.sprite_frames = player_type_4
	
	# Respawn with keycard spaghetti.
	if get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework").has_keycard:
		var instantiated_keycard = loaded_keycard.instantiate()
		instantiated_keycard.position = position + get_parent().position
		instantiated_keycard.replacement_keycard = true
		get_parent().get_parent().call_deferred("add_child", instantiated_keycard)

# Figure out the velocity based on the inputs.
func getInputVelocity(can_jump):
	if $PlayerAnimation.animation != "AttackSword" && !disable_controlls:
		var input_direction = Input.get_axis("left", "right")
		var max_movement_speed = max_speed
		
		if !can_jump:
			max_movement_speed = max_air_speed
		
		if absf(velocity.x) < max_movement_speed || (abs(velocity.x) >= max_movement_speed && ((velocity.x < 0 && input_direction > 0) || (velocity.x > 0 && input_direction < 0))):
			return input_direction * speed
			
		return (absf(velocity.x) - max_movement_speed) * -input_direction
	
	return 0

# Line 200!

# Check if the jump button is pressed.
func checkJump():
	return Input.is_action_just_pressed("jump") if !disable_controlls else false

# Check if the player can jump.
func canJump():
	return is_on_floor()

# Handle the action of jumping.
func jump():
	just_jumped = true
	velocity.y = (-jump_vel if current_ability != "RocketBoost" else -rocket_jump_vel)
	$PlayerAnimation.play("StartJump")
			
	if current_ability == "RocketBoost":
		$PlayerAnimation.play("StartJumpRockets")
			
	if current_ability == "Weapon":
		$PlayerAnimation.play("StartJumpSword")

# Massive function to clean, runs every frame.
func _physics_process(delta):
	var can_jump = canJump()
	
	# Run everything in this if statement as long as we are either multiplayer
	# authority or the game isn't in multiplayer mode.
	if (get_parent().get_parent().is_multiplayer && get_parent().is_multiplayer_authority()) || !get_parent().get_parent().is_multiplayer:
		if Input.is_action_just_pressed("respawn"):
			get_parent().get_node("Camera").get_node("CloseAnimator").closing = true
			Engine.time_scale = 0.6
			get_node("HurtVibrationTimer").start()
		
		# Set the player's light to be invisible if we're on efficient graphics
		# mode.
		if get_parent().graphics_efficiency:
			$PointLight2D.visible = false
		
		# Move at conveyor belt speeds.
		if in_conveyor_belt:
			position.x += conveyor_speed * conveyor_direction * delta * 60
		
		# You.
		if dead:
			$AntennaAnimation.visible = false
		
		# Doesn't do anything, probably never will.
		if physics_player:
			return
		
		# Apply gravity if not grappling
		if !grappling_effects && !climbing:
			velocity.y += gravity * Engine.time_scale
		
		# Ladder sloow.
		if in_ladder_area:
			velocity.y /= 1.5
		
		dont_apply_friction = false
		just_jumped = false
		
		# Apply keyboard inputs.
		var input_velocity = getInputVelocity(can_jump)
		if !dead:
			velocity.x += input_velocity
		
		# Check if we can jump
		if checkJump() and (can_jump || $CoyoteJumpTimer.time_left > 0):
			if !in_ladder_area && !dead:
				jump()
		
		# Go down a ladder.
		if Input.is_action_pressed("down") && climbing && !dead:
			velocity.y += jump_push_force * 2
			
		# Implement coyote jumping system.
		if could_jump && !can_jump:
			$CoyoteJumpTimer.start() 
			
		# If the player is holding the jump button, apply a slight upwards push.
		if Input.is_action_pressed("jump") && !dead:
			if !climbing:
				velocity.y -= (jump_push_force if current_ability != "RocketBoost" else rocket_jump_push_force) * Engine.time_scale
			else:
				velocity.y -= jump_push_force * 2
			
			# But like in a ladder we should handle everything differently.
			if in_ladder_area:
				velocity.x /= 1.3
				$FireParticlesBootsLeft.emitting = false
				$FireParticlesBootsRight.emitting = false
				climbing = true
				
				if !was_climbing:
					$PlayerAnimation.play("Climbing")
					
				if $PlayerAnimation.animation != "Climbing":
					$PlayerAnimation.play("Climbing")
		
		# Sword attack.
		if Input.is_action_just_pressed("attack") && current_ability == "Weapon" && $NewDashCooldown.time_left == 0 && !dead:
			# Line 300!
			$PlayerAnimation.play("AttackSword")
			$DashStopCooldown.start()
			$NewDashCooldown.start()
			is_swiping_sword = true
			
			velocity.x = previous_direction * 7
			
			var rng = RandomNumberGenerator.new()
			var sword_woosh_ind = rng.randi_range(0, 3)
			dash_sound_effects[sword_woosh_ind].play()
		
		# Stop at the end of a sword attack, no matter what the player has
		# on their agenda. This game was not designed to make the player happy.
		# What is a game if not fun? This game.
		if $NewDashCooldown.time_left > 0 && $DashStopCooldown.time_left <= 0:
			velocity.x = 0
			
		# Hard cap the speed to supress speed glitches.
		if absf(velocity.x) > speed_hard_cap && !disable_speed_cap && !$DashStopCooldown.time_left > 0:
			velocity.x = max_speed if velocity.x > 1 else -max_speed
		if absf(velocity.y) > (max_jump_speed_rocket + 1) && !disable_speed_cap:
			velocity.y = rocket_jump_vel if velocity.y > 1 else -rocket_jump_vel
			
		# If speed cap is disabled, ignore that.
		if absf(velocity.x) > speed_hard_cap * 2 && (disable_speed_cap || $DashStopCooldown.time_left > 0):
			velocity.x = max_speed * 2 if velocity.x > 0 else -max_speed * 2
		if absf(velocity.y) > rocket_jump_vel * 2 && disable_speed_cap:
			velocity.y = rocket_jump_vel * 2 if velocity.y > 0 else -rocket_jump_vel * 2
			
		# Apply friction.
		if input_velocity == 0 && !$GrappleManager.air_grapling && Input.get_axis("left", "right") == 0 && (!$GrappleManager.grapling || can_jump):
			# Don't apply friction if the player is moving.
			if can_jump:
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
		
		# Get the audio sound effects because I thought that would make it
		# more efficient.
		var metal_walk_boots_1 = get_parent().get_node("MetalWalkBoots1")
		var metal_walk_1 = get_parent().get_node("MetalWalk1")
		
		# Play dumb audio.
		if metal_walk_boots_1.playing && !current_ability == "RocketBoost":
			metal_walk_1.play()
			metal_walk_boots_1.stop()
		if metal_walk_1.playing && current_ability == "RocketBoost":
			metal_walk_boots_1.play()
			metal_walk_1.stop()
		
		# More dumb audio. I would prefer not to explain this ravioli to you.
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if !get_parent().graphics_efficiency:
				$GravelWalkingParticles.emitting = false
			var play_metal_walk = false
			
			if collision && collision.get_collider() is RigidBody2D:
				collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force)
			
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
			# Line 400!
			if metal_walk_1.volume_db > -20:
				metal_walk_1.volume_db -= 1
				metal_walk_1.volume_db -= 1
				metal_walk_boots_1.volume_db -= 1
				
		# Get the save load framework node.
		var save_load_framework = get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework")
		
		# If the player isn't about to die, turn off the heartbeat.
		if $BulletBadHurtcooldown.time_left <= 0 && $BulletHurtCooldown.time_left <= 0 && get_parent().get_node("Camera").get_node("AbilityManager").get_node("AbililtySwitchTimer").time_left < 10:
			get_parent().get_node("Heartbeat").volume_db = -40
		
		# Set funny bulge effects.
		if $BulletBadHurtcooldown.time_left > 0:
			save_load_framework.bulge_amm = 1.0 + get_parent().bulge_adder
			save_load_framework.static_amm = 0.1 + get_parent().static_adder
			
			get_parent().get_node("Heartbeat").volume_db = 3
			get_parent().get_node("Heartbeat").pitch_scale = 2
			
			if !get_parent().get_node("Heartbeat").playing:
				get_parent().get_node("Heartbeat").play()
		
		# More funny bulge effects.
		elif $BulletHurtCooldown.time_left > 0:
			save_load_framework.bulge_amm = 0.4 + get_parent().bulge_adder
			save_load_framework.static_amm = 0.05 + get_parent().static_adder
		
		# More.
		elif get_parent().get_node("Camera").get_node("AbilityManager").get_node("AbililtySwitchTimer").time_left > 5 && !get_parent().get_parent().is_credits:
			save_load_framework.bulge_amm = 0 + get_parent().bulge_adder
			save_load_framework.static_amm = 0 + get_parent().static_adder
	
	# If the left button is pressed (to move the player left). 
	var left_pressed = Input.is_action_pressed("left")
	
	# Same with right.
	var right_pressed = Input.is_action_pressed("right")
	
	# If we aren't the multiplayer authority, don't let the other player move
	# us.
	if get_parent().get_parent().is_multiplayer && !get_parent().is_multiplayer_authority():
		left_pressed = velocity.x < 0
		right_pressed = velocity.x > 0
	
	# Play animations unless we're pressing both left and right.
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
		
		# Play idle animations if we aren't pressing left or right.
		elif ($PlayerAnimation.animation != "Landing" && 
			$PlayerAnimation.animation != "LandingRockets" && 
			$PlayerAnimation.animation != "LandingSword" && 
			$PlayerAnimation.animation != "AttackSword" && 
			$PlayerAnimation.animation != "StartJump" && 
			$PlayerAnimation.animation != "StartJumpRockets" && 
			$PlayerAnimation.animation != "StartJumpSword" &&
			$PlayerAnimation.animation != "Climbing") && !dead:
			#Reusing code here.
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("IdleRockets")
				
			elif current_ability == "Weapon":
				$PlayerAnimation.play("IdleSword")
				
			else:
				# Line 500!
				$PlayerAnimation.play("Idle")
			
		# Um.
		if (($PlayerAnimation.animation == "InAirUp" || 
			$PlayerAnimation.animation == "InAirUpRockets" ||
			$PlayerAnimation.animation == "InAirUpSword") &&
			$PlayerAnimation.animation != "Climbing" && can_jump) && !dead:
			
			if current_ability == "RocketBoost":
				$PlayerAnimation.play("IdleRockets")
				
			elif current_ability == "Weapon":
				$PlayerAnimation.play("IdleSword")
				
			else:
				$PlayerAnimation.play("Idle")
	
	# Emit fire particles in the air if we press jump, regardless if we're on the ground.
	if Input.is_action_pressed("jump") && current_ability == "RocketBoost" && !can_jump && !climbing:
		$FireParticlesBootsLeft.emitting = true
		$FireParticlesBootsRight.emitting = true
		
		if get_parent().get_node("RocketBoost").playing == false && !climbing:
			get_parent().get_node("RocketBoost").play()
	else:
		# Kill the fire particles.
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
		
	# You cannot walk in the air (No Jesus, shut up).
	if !can_jump && velocity.y > 2 && !dead:
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
	if both_pressed && $PlayerAnimation.animation != "Climbing" && !dead:
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
	
	# Slow down time if we're hurt. Causes goofy jump bugs.
	if $BulletBadHurtcooldown.time_left > 0 && !dead && $HurtVibrationTimer.time_left == 0:
		Engine.time_scale = 0.65
		
	# If we're not hurt set time to normal.
	elif !dead && $HurtVibrationTimer.time_left == 0:
		Engine.time_scale = 1
	
	# Death is eternal, even if my goofy ah animation code doesn't think so.
	if $PlayerAnimation.animation != "DeathAnim" && dead:
		$PlayerAnimation.play("DeathAnim")
	
	# Set wasnt_... variables.
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
	
	# Set mutliplayer position if we are the authority.
	if get_parent().get_parent().is_multiplayer && get_parent().is_multiplayer_authority():
		set_pos_and_motion_multiplayer.rpc(position, velocity, is_swiping_sword, $PlayerAnimation.modulate, dead)

# If the player enters a death zone, respawn it.
func _on_area_2d_area_entered(area):
	# Handle entering a conveyor belt.
	if area.name == "PlayerPusher":
		if in_conveyor_belt:
			dont_reset_conveyor = true
			return
		
		in_conveyor_belt = true
		conveyor_speed = area.get_parent().speed
		conveyor_direction = area.get_parent().direction
	
	# Handle entering an item switcher (this generally means your item gets switched).
	if area.name == "ItemSwitcherArea":
		var ability_manager = get_parent().get_node("Camera").get_node("AbilityManager")
		var switch_ability = area.get_parent().item_switch_type
		if current_ability == "Weapon" && switch_ability == "RocketBoost":
			area.get_parent().right_item()
			ability_manager.next_ability()
			Input.start_joy_vibration(0, 1, 0.1)
			$HurtVibrationTimer.start()
		elif current_ability == "RocketBoost" && switch_ability == "ArmGun":
			area.get_parent().right_item()
			ability_manager.next_ability()
			Input.start_joy_vibration(0, 1, 0.1)
			$HurtVibrationTimer.start()
		elif current_ability == "ArmGun" && switch_ability == "Grapple":
			area.get_parent().right_item()
			ability_manager.next_ability()
			Input.start_joy_vibration(0, 1, 0.1)
			$HurtVibrationTimer.start()
		elif current_ability == "Grapple" && switch_ability == "Weapon":
			area.get_parent().right_item()
			ability_manager.next_ability()
			Input.start_joy_vibration(0, 1, 0.1)
			$HurtVibrationTimer.start()
		else:
			area.get_parent().wrong_item()
			get_parent().screenshake_enabled = true
	
	# Set variables for ladders, but don't actually climb them.
	if area.name == "LadderClimbArea":
		if in_ladder_area:
			in_second_ladder_area = true
		
		in_ladder_area = true
		
	# Checkpoints are deprecated but integrated in to the item switchers.
	if area.name == "CheckpointCollision":
		respawn_pos = position
		respawn_ability = area.get_parent().player_checkpoint_item
		area.get_parent().activate()
		
		if current_ability == respawn_ability:
			return
		
		current_ability = respawn_ability
		
		var ability_manager = get_parent().get_node("Camera").get_node("AbilityManager")
		
		if current_ability == "Weapon":
			ability_manager.ability_index = 3
		elif current_ability == "RocketBoost":
			ability_manager.ability_index = 0
		elif current_ability == "ArmGun":
			ability_manager.ability_index = 1
		elif current_ability == "Grapple":
			ability_manager.ability_index = 2
			
		ability_manager.next_ability()
		
	# This is actually where we die.
	if area.name == "DeathZone" || area.name == "PistonDeathZone":
		get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework").get_node("VoicelinePlayer").death_by_hazard()
		if area.name == "PistonDeathZone":
			visible = false
		
		get_parent().get_node("Camera/CloseAnimator").closing = true
		
	# Get hurt here but we don't die (unless we do).
	if area.name == "BulletHurter" || area.name == "JumpHurtBox" || area.name == "ExplosionHitbox":
		if area.name == "ExplosionHitbox" && area.get_parent().no_damage:
			return
		
		if area.name == "BulletHurter":
			area.get_parent().queue_free()
		elif area.name == "JumpHurtBox":
			if area.get_parent().health <= 0:
				return
			
			if $DashStopCooldown.time_left > 0:
				return
		
		# Special effects.
		Input.start_joy_vibration(0, 0.5, 1)
		Engine.time_scale = 0.6
		$HurtVibrationTimer.start()
		
		if $BulletBadHurtcooldown.time_left > 0:
			# This is the part where he kills you.
			if area.name == "JumpHurtBox":
				get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework").get_node("VoicelinePlayer").death_by_hazard()
			else:
				get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework").get_node("VoicelinePlayer").death_by_drone()
			get_parent().get_node("Camera/CloseAnimator").closing = true
		elif $BulletHurtCooldown.time_left > 0:
			$BulletBadHurtcooldown.start()
			$PlayerAnimation.modulate.g = 0
			$PlayerAnimation.modulate.b = 0
		else:
			$BulletHurtCooldown.start()
			$PlayerAnimation.modulate.g = 0.8
			$PlayerAnimation.modulate.b = 0.6

# Kill the player, with no animations, just restart.
func die():
	get_parent().get_parent().cannot_stop_special_music = true
	get_parent().get_parent().deaths += 1
	get_parent().get_parent().get_node("NextLevel").restart_level(respawn_pos, respawn_ability)

# When an area exits the hurtbox.
func _on_player_hurtbox_area_exited(area):
	# When we exit a latter we would appreciate it if you stopped climbing.
	if area.name == "LadderClimbArea":
		if in_second_ladder_area:
			in_second_ladder_area = false
		else:
			in_ladder_area = false
			climbing = false
			
			# Jump for funzies.
			jump()
	
	# When we exit a conveyor belt we would appreciate if you stopped moving a
	# little bit.
	if area.name == "PlayerPusher":
		if dont_reset_conveyor:
			dont_reset_conveyor = false
		else:
			velocity.x = area.get_parent().speed * area.get_parent().direction
			in_conveyor_belt = false
			
# PlayerAnimation is never finished. The function name is a lie.
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

# When we want to regain some health, do that.
func _on_bullet_hurt_cooldown_timeout():
	if $BulletBadHurtcooldown.time_left == 0:
		$PlayerAnimation.modulate.g = 1
		$PlayerAnimation.modulate.b = 1

# Generally the player appreciates this.
func _on_bullet_bad_hurtcooldown_timeout():
	$PlayerAnimation.modulate.g = 1
	$PlayerAnimation.modulate.b = 1

# Stop the player when the dash stops.
func _on_dash_stop_cooldown_timeout():
	velocity.x = 0
	is_swiping_sword = false

# Stop joystick vibration when that's probably a good thing to do.
func _on_hurt_vibration_timer_timeout():
	Engine.time_scale = 1
	Input.stop_joy_vibration(0)
	
# Kill the player when they hit spikes (special hurtbox).
func _on_spike_hurt_box_body_entered(body):
	if body.name == "Spikes":
		get_parent().get_parent().get_parent().get_parent().get_node("SaveLoadFramework").get_node("VoicelinePlayer").death_by_hazard()
		get_parent().get_node("Camera/CloseAnimator").closing = true

# Set multiplayer, it's not unreliable this just makes it faster or something.
@rpc("unreliable")
func set_pos_and_motion_multiplayer(pos, motion, swiping, color_mod, death):
	position = pos
	velocity = motion
	is_swiping_sword = swiping
	$PlayerAnimation.modulate = color_mod
	dead = death
