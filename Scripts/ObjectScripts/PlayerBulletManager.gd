# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D

var velocity = Vector2.ZERO
var direction = Vector2.ZERO

var graphics_efficiency = false
var stopped_moving = false
var drone_following = null
		
func _process(delta):
	if !stopped_moving:
		position += direction * velocity * (delta * 60)
		rotation = atan2(direction.y, direction.x) + (1.0/2.0 * PI)
		
		if drone_following && is_instance_valid(drone_following):
			var direction_to_drone = ((drone_following.get_parent().position + drone_following.position) - position).normalized()
			var direction_to_drone_to_direction = (direction_to_drone - direction).normalized()
			direction = (direction + direction_to_drone_to_direction / 10).normalized()

func _on_despawn_timer_timeout():
	queue_free()

func _on_player_bullet_hurter_body_entered(body):
	if body.name != "Player" && !stopped_moving:
		$BulletSprite.queue_free()
		$PlayerBulletHurter.queue_free()
		$GPUParticles2D.emitting = false
		stopped_moving = true

func _on_player_bullet_hurter_area_entered(area):
	if area.name == "DroneHurtbox" && !stopped_moving:
		$BulletSprite.queue_free()
		$PlayerBulletHurter.queue_free()
		$GPUParticles2D.emitting = false
		stopped_moving = true

func _on_enemy_detection_radius_area_entered(area):
	if area.name == "DroneHurtbox":
		drone_following = area.get_parent()
