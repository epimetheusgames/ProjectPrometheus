# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends RigidBody2D

var set_queued_pos = false
var queued_position = Vector2.ZERO
var queued_rotation = 0
var no_respawn = false

func _integrate_forces(state):
	if set_queued_pos:
		state.transform = Transform2D(queued_rotation, queued_position)
		set_queued_pos = false

func _on_ground_fall_timer_timeout():
	if no_respawn:
		$CollisionPolygon2D.disabled = true

func _on_despawn_timer_timeout():
	queue_free()

func _on_start_flying_timer_timeout():
	if !no_respawn:
		get_parent().get_node("Drone").position = position
		get_parent().get_node("Drone").rotation = rotation
		get_parent().fly_to_correct = true
		queue_free()
