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
		
func _process(delta):
	position += direction * velocity * (delta * 60)
	rotation = atan2(direction.y, direction.x) + (1.0/2.0 * PI)

func _on_despawn_timer_timeout():
	queue_free()

func _on_player_bullet_hurter_body_entered(body):
	if body.name != "Player":
		queue_free()

func _on_player_bullet_hurter_area_entered(area):
	if area.name == "DroneHurtbox":
		queue_free()
