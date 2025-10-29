# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


var graphics_efficiency = false
var velocity = Vector2.ZERO

var stopped_moving = false

func _process(delta):
	position += velocity * (delta * 60)
	rotation = atan2(velocity.y, velocity.x) + (1.0/2.0 * PI)
	
	if !$BulletAmbientSFX.playing:
		$BulletAmbientSFX.play()

func _on_despawn_timer_timeout():
	queue_free()

func _on_bullet_hurter_body_entered(body):
	if body.name != "Player" && body.name != "DroneHitbox":
		$BulletSprite.queue_free()
		$BulletHurter.queue_free()
		$GPUParticles2D.emitting = false
		$PointLight2D.queue_free()
		stopped_moving = true
