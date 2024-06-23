# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Melee robot on a wheel that attacks the player.                                                        |
# -------------------------------------------------------------------------------------------------------|


extends CharacterBody2D


# Walking acceleration speed.
var speed = 0.15

# Maximum speed of melee.
var max_speed = 1.5

# Maximum falling speed (no protection against
# falling like the drill).
var max_fall_speed = 10

# One-time jump velocity. Sets to y value 
# of velocity.
var jump_vel = 6.5

# Per-frame gravity acceleration.
var gravity = 0.5

# Check if we're attacking the player right now.
var attacking = false

# Friction force for when we're not moving or 
# turning around.
var friction_force = 1.2

# Holds reference to player.
@onready var player = get_parent().get_node("Player").get_node("Player") if !get_parent().is_multiplayer else null

# Loaded ragdoll melee to spawn in when we die.
@onready var loaded_ragdoll = preload("res://Objects/StaticObjects/RagdollMele.tscn")

# Health value, decreases if the player attacks it.
@export var health = 4
@export var dont_fall = false

# The direction of the melee (-1 or 1)
var direction = 0

# Physics push force.
var push_force = 40

# Is the melee idle (e.g. the player doesn't have
# a weapon itme).
var is_idle = false


func _ready():
	# Set multiplayer authority.
	if get_parent().multiplayer:
		if multiplayer.is_server():
			set_multiplayer_authority(multiplayer.get_unique_id())
		else:
			set_multiplayer_authority(multiplayer.get_peers()[0])

func _physics_process(delta):
	# Run only if we're the multiplayer authority or not 
	# multiplayer at all.
	if (get_parent().is_multiplayer && is_multiplayer_authority()) || !get_parent().is_multiplayer:
		# Add the gravity.
		velocity.y += gravity * delta * 60
		
		# Get distance to the player.
		var player_distance = position.distance_to(player.position)

		# Get direction to the player.
		var player_direction = player.position - position
		
		# Set sprite scale to be based on direction.
		$Sprite2D.scale.x = -1 if velocity.x < 0 else 1
		
		# Set spear animation to be based on player direction.
		if !is_idle:
			$SpearAnimation.scale.x = -1 if player_direction.x < 0 else 1
		
		# Set idle based on player current ability.
		if player.current_ability == "Weapon" || player.current_ability == "ArmGun":
			is_idle = false
		else:
			is_idle = true

		# Run movement code only if we're alive.
		if health > 0:
			# If player is close to us, get ready to attack.
			if player_distance < 75 && (($SpearAnimation.animation == "Walking") || ($SpearAnimation.animation == "SpearReload" && !$SpearAnimation.is_playing())) && !is_idle:
				$SpearAnimation.play("SpearJustBeforeAttack")
			
			# If player moves away from us, stop being ready to attack.
			elif player_distance > 75 && $SpearAnimation.animation == "SpearJustBeforeAttack" && !$SpearAnimation.is_playing() && !is_idle:
				$SpearAnimation.play("SpearReload")
			
			# After reloading, play walking animation.
			elif player_distance > 75 && $SpearAnimation.animation == "SpearReload" && !$SpearAnimation.is_playing():
				$SpearAnimation.play("Walking")
			
			# Apply collisions to physics bodies.
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				
				if collision && collision.get_collider() is RigidBody2D:
					collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force)
			
			# Multiplayer code for handling two players.
			if get_parent().is_multiplayer:
				var distance_to_server_player = get_parent().server_player.get_node("Player").position.distance_to(position)
				var distance_to_client_player = get_parent().client_player.get_node("Player").position.distance_to(position)
					
				if distance_to_server_player > distance_to_client_player:
					player = get_parent().server_player.get_node("Player")
				else:
					player = get_parent().client_player.get_node("Player")
			
			# Set wheel animation speed to be based on velocity.
			$Sprite2D.sprite_frames.set_animation_speed("default", abs(velocity.x * 20))
			
			# Get raycast collisions.
			var down_col = $RayCastDown.get_collider() 
			var left_col = $RayCastLeft.get_collider()
			var right_col = $RayCastRight.get_collider()
			
			direction = 0

			# Set direction based on player direction.
			if player.position.x - position.x > 0:
				direction = 1
			if player.position.x - position.x < 0:
				direction = -1
			
			# Boolian for if we should jump right now.
			var jump = ((left_col && direction == -1 && !"Player" in left_col.name) || (right_col && direction == 1 && !"Player" in right_col.name)) && (left_col if direction == -1 else right_col)
			
			# Boolian for if the player is near.
			var player_near = (left_col && "Player" in left_col.name) || (right_col && "Player" in right_col.name)

			# Boolian for if another attack melee is near.
			var mele_near = (left_col && "AttackMele" in left_col.name && direction == -1) || (right_col && "AttackMele" in right_col.name && direction == 1)
			
			# If we should jump, jump.
			if is_on_floor() && jump && !player_near && !mele_near && !is_idle:
				velocity.y = -jump_vel
			
			# If the player is below us, jump and get off of them as 
			# fast as possible.
			if (down_col && ("Player" in down_col.name || "AttackMele" in down_col.name)) && !is_idle:
				velocity.y = -jump_vel
				velocity.x = -direction * speed * 2
				_on_jump_hurt_box_area_entered(down_col.get_node("PlayerHurtbox"))
			
			# Start timer to attack if the player is near.
			if player_near && $AttackTimer.time_left <= 0 && $AttackResetTimer.time_left <= 0:
				$AttackTimer.start()
			
			# Run towards the player.
			if direction && !player_near && !mele_near && !$AttackResetTimer.time_left > 0 && !is_idle:
				velocity.x += direction * speed
			
			# Set hurtbox to be enabled if we're attacking.
			if attacking && !is_idle:
				$JumpHurtBox/CollisionShape2D.disabled = false
			else:
				$JumpHurtBox/CollisionShape2D.disabled = true
			
			# Apply friction.
			if (absf(velocity.x) > max_speed):
				velocity.x /= friction_force
			
			# Don't fall faster than maximum fall speed.
			if velocity.y > max_fall_speed:
				velocity.y = max_fall_speed
			
			# Collisions.
			move_and_slide()
			
			# Hard speed caps.
			if abs(velocity.x) > 5:
				velocity.x = 2 if velocity.x > 0 else -2
			if abs(velocity.y) > 7:
				velocity.y = 7 if velocity.y > 0 else -7
			
			# Add velocity to position.
			position += velocity
		else:
			# Get everything ready for death.
			$Collision.disabled = true
			$Sprite2D.visible = false
			$SpearAnimation.visible = false
	
	# Set multiplayer position.
	if get_parent().is_multiplayer && is_multiplayer_authority():
		set_pos_and_motion_multiplayer.rpc(position, velocity, health)
	
	# Get everything ready for death.
	if health <= 0:
		$Collision.disabled = true
		$Sprite2D.visible = false

# Attack the player.
func _on_attack_timer_timeout():
	$AttackStopTimer.start()
	attacking = true

# Stop attacking the player.
func _on_attack_stop_timer_timeout():
	$AttackResetTimer.start()
	attacking = false

func _on_attack_reset_timer_timeout():
	$AttackTimer.start()

# If the player enters the hurtbox, make it jump. The player
# will handle hurting itself.
func _on_jump_hurt_box_area_entered(area):
	if area && area.name == "PlayerHurtbox" && health > 0 && !is_idle:
		area.get_parent().jump_vel = 5
		area.get_parent().rocket_jump_vel = 5
		area.get_parent().velocity.x = -area.get_parent().velocity.x
		
		area.get_parent().velocity.x = 4 * direction
		
		area.get_parent().jump()
		area.get_parent().jump_vel = 4
		area.get_parent().rocket_jump_vel = 6
		
		$SpearAnimation.play("SpearAttack")

# If the player hurts us, get hurt.
func _on_hurt_box_area_entered(area):
	if area && area.name == "PlayerHurtbox" && health > 0:
		if area.get_parent().get_node("DashStopCooldown").time_left > 0 || area.get_parent().is_swiping_sword:
			health -= 1
			velocity.x = -direction * 7
			velocity.y = -jump_vel / 1.7
			
			$SwordHit.play()
			
			if health == 0:
				$LightOccluder2D.visible = false
				get_parent().points += 5
				area.get_parent().get_node("BulletBadHurtcooldown").stop()
				area.get_parent().get_node("PlayerAnimation").modulate = Color.WHITE
				var ragdoll = loaded_ragdoll.instantiate()
				ragdoll.dont_fall = dont_fall
				ragdoll.get_node("Body").apply_central_force(velocity * 8000)
				ragdoll.get_node("SpearRight" if velocity.x > 0 else "SpearLeft").queue_free()
				add_child(ragdoll)
				
				var total_melee_kills = get_parent().get_parent().get_parent().get_node("SaveLoadFramework").load_achievement_tracking("melee_kills") + 1
				get_parent().get_parent().get_parent().get_node("SaveLoadFramework").save_achievement_tracking("melee_kills", total_melee_kills)
				
				if total_melee_kills == 50:
					get_parent().get_parent().get_parent().get_node("SaveLoadFramework").save_achievement("kill_50_melee")
				
	elif area && area.name == "PlayerBulletHurter" && health > 0:
		health -= 0.5
		velocity.x = -direction * 4
		velocity.y = -jump_vel / 2
		
		if health == 0:
				get_parent().points += 5
				var ragdoll = loaded_ragdoll.instantiate()
				ragdoll.get_node("Body").apply_central_force(velocity * 10)
				ragdoll.get_node("SpearRight" if velocity.x > 0 else "SpearLeft").queue_free()
				add_child(ragdoll)

func _on_switch_hurtbox_enabled_timer_timeout():
	$HurtBox/CollisionShape2D.disabled = !$HurtBox/CollisionShape2D.disabled
	
@rpc("unreliable")
func set_pos_and_motion_multiplayer(pos, motion, hp):
	position = pos
	velocity = motion
	health = hp

func _on_spike_hurt_box_body_entered(body):
	health = 0
	var ragdoll = loaded_ragdoll.instantiate()
	ragdoll.get_node("Body").apply_central_force(velocity * 1.5)
	ragdoll.get_node("SpearRight" if velocity.x > 0 else "SpearLeft").queue_free()
	add_child(ragdoll)
		

func _on_spear_animation_animation_finished():
	if position.distance_to(player.position) < 75 && ($SpearAnimation.animation == "Walking" || $SpearAnimation.animation == "SpearReload"):
		$SpearAnimation.play("SpearJustBeforeAttack")
		
	if $SpearAnimation.animation == "SpearAttack":
		$SpearAnimation.play("SpearReload")
		
