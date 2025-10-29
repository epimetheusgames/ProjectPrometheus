# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Code for drills and other goomba-like objects.                                                         |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


# The direction to start in, on the x axis.
@export var start_direction = 1

# The health the drill has, before it's dead.
@export var health = 3

# If we should disable the hitbox when health reaches zero,
# sometimes used on the boss levels.
@export var disable_hitbox_when_dead = false

# Per frame position increment for movement.
@onready var speed = 0.5
@onready var direction = speed * start_direction
@export var no_nockback = false
@export var tank = false
var gravity = 0.5
var velocity = Vector2.ZERO
var enabled = false

func _ready():
	if direction == speed:
		$JumpHurtBox/CollisionShape2D2.disabled = false
		$JumpHurtBox/CollisionShape2D3.disabled = true
		$DrillAnimation.scale.x = 1 if !tank else -1
		$DrillBreakOverlay.scale.x = 1
		
		if tank:
			$DrillCollider.scale.x = 1
	elif direction == -speed:
		$JumpHurtBox/CollisionShape2D2.disabled = true
		$JumpHurtBox/CollisionShape2D3.disabled = false
		$DrillAnimation.scale.x = -1 if !tank else 1
		$DrillBreakOverlay.scale.x = -1
		
		if tank:
			$DrillCollider.scale.x = -1
		
	if get_parent().multiplayer:
		if multiplayer.is_server():
			set_multiplayer_authority(multiplayer.get_unique_id())
		else:
			set_multiplayer_authority(multiplayer.get_peers()[0])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (get_parent().is_multiplayer && is_multiplayer_authority()) || !get_parent().is_multiplayer:
		if !enabled:
			return
		
		if health > 0:
			velocity.x = direction
			velocity.y += gravity
			
			var left_collision = $RayCastLeft.get_collider()
			var right_collision = $RayCastRight.get_collider()
			var down_collision = $RayCastDown.get_collider()
			var down_collision_2 = $RayCastDown2.get_collider()
			var ext_down_collision = $ExtRaycastDownLeft.get_collider()
			var ext_down_collision_2 = $ExtRaycastDownRight.get_collider()
			
			if !ext_down_collision && ext_down_collision_2 && direction == -speed:
				var node_with_name = Node.new()
				node_with_name.name = "Drill worked!"
				left_collision = node_with_name
			if !ext_down_collision_2 && ext_down_collision && direction == speed:
				var node_with_name = Node.new()
				node_with_name.name = "Drill worked!"
				right_collision = node_with_name
			
			if left_collision != null && left_collision.name != "Player" && left_collision.name != "DrillCollider" && direction == -speed:
				direction = speed
				$JumpHurtBox/CollisionShape2D2.disabled = false
				$JumpHurtBox/CollisionShape2D3.disabled = true
				$DrillAnimation.scale.x = 1 if !tank else -1
				$DrillBreakOverlay.scale.x = 1
				$DrillAnimation.play("LeftToRight")
				$DrillBreakOverlay.visible = false
				
				if tank:
					$DrillCollider.scale.x = 1
				
			elif right_collision != null && right_collision.name != "Player" && right_collision.name != "DrillCollider" && direction == speed:
				print(right_collision.name)
				direction = -speed
				$JumpHurtBox/CollisionShape2D2.disabled = true
				$JumpHurtBox/CollisionShape2D3.disabled = false
				$DrillAnimation.scale.x = -1 if !tank else 1
				$DrillBreakOverlay.scale.x = -1
				$DrillAnimation.play("LeftToRight")
				$DrillBreakOverlay.visible = false
				
				if tank:
					$DrillCollider.scale.x = -1
			
			if down_collision != null || down_collision_2 != null:
				velocity.y = -0.05
				
			position += velocity * (delta * 60)
		else:
			$DrillBreakOverlay.play("Break3")
			$DrillAnimation.play("Idle")
			$DrillBreakOverlay.visible = true
			
			if disable_hitbox_when_dead:
				$DrillCollider/CollisionPolygon2D.disabled = true
	
	if get_parent().is_multiplayer && is_multiplayer_authority():
		set_pos_and_motion_multiplayer.rpc(position, velocity, health, $DrillAnimation.scale.x)
	
	if health > 0:
		if health == 3:
			$DrillBreakOverlay.play("None")
		if health == 2:
			$DrillBreakOverlay.play("Break1")
		if health == 1:
			$DrillBreakOverlay.play("Break2")
	else:
		$DrillAnimation.play("Idle")

func _on_jump_hurt_box_area_entered(area):
	if area.name == "PlayerHurtbox" && health > 0:
		if area.get_parent().get_node("DashStopCooldown").time_left > 0 || area.get_parent().is_swiping_sword:
			if !no_nockback:
				var raycast = PhysicsRayQueryParameters2D.create(global_position, global_position - Vector2(velocity.x * 50, 0))
				raycast.exclude.append($DrillCollider.get_rid())
				raycast.exclude.append(area.get_parent().get_rid())
				var result = get_world_2d().direct_space_state.intersect_ray(raycast)
				if !result:
					position.x += -velocity.x * 50
				else:
					position.x = result.position.x
			
			if health == 0:
				area.get_parent().get_node("BulletBadHurtcooldown").stop()
				area.get_parent().get_node("PlayerAnimation").modulate = Color.WHITE
		
		area.get_parent().jump_vel = 5
		area.get_parent().rocket_jump_vel = 5
		area.get_parent().velocity.x = -area.get_parent().velocity. x
		
		if area.get_parent().velocity.x > 0:
			area.get_parent().velocity.x = 4
		if area.get_parent().velocity.x < 0:
			area.get_parent().velocity.x = -4
		if area.get_parent().velocity.x == 0:
			area.get_parent().velocity.x = 4 * (direction * (1 / speed))
		
		area.get_parent().jump()
		area.get_parent().jump_vel = 4
		area.get_parent().rocket_jump_vel = 6

func _on_drill_animation_animation_finished():
	if $DrillAnimation.animation == "LeftToRight" || $DrillAnimation.animation == "RightToLeft":
		$DrillBreakOverlay.visible = true
		$DrillAnimation.play("Moving")

func _on_jump_hurt_box_allways_active_area_entered(area):
	if area.name == "PlayerHurtbox" && health > 0 && !tank:
		if area.get_parent().get_node("DashStopCooldown").time_left > 0 || area.get_parent().is_swiping_sword:
			health -= 1
			$SwordHit.play()
			
			if health == 0:
				get_parent().points += 5
				area.get_parent().get_node("BulletBadHurtcooldown").stop()
				area.get_parent().get_node("PlayerAnimation").modulate = Color.WHITE
				
				var total_drill_kills = get_parent().get_parent().get_parent().get_node("SaveLoadFramework").load_achievement_tracking("drill_kills") + 1
				get_parent().get_parent().get_parent().get_node("SaveLoadFramework").save_achievement_tracking("drill_kills", total_drill_kills)
				
				if total_drill_kills == 50:
					get_parent().get_parent().get_parent().get_node("SaveLoadFramework").save_achievement("kill_50_drills")

func _on_player_in_range_detector_area_entered(area):
	if area.name == "PlayerHurtbox":
		enabled = true

@rpc("unreliable")
func set_pos_and_motion_multiplayer(pos, motion, hp, anim_scale):
	position = pos
	velocity = motion
	health = hp
	$DrillAnimation.scale.x = anim_scale
