# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Area2D


@export var door: Node2D
@export var door_collision_1: StaticBody2D
@export var door_collision_2: StaticBody2D
@export var mist_particles_1: GPUParticles2D
@export var mist_particles_2: GPUParticles2D
var already_entered = false

func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && !already_entered:
		already_entered = true
		door._on_area_2d_area_entered(area)
		door.locked = true
		door_collision_1.get_node("CollisionShape2D").set_deferred("disabled", false)
		door_collision_2.get_node("CollisionShape2D").set_deferred("disabled", false)
		$ParticlesStartTimer.start()

func _on_particles_stop_timer_timeout():
		mist_particles_1.emitting = false
		mist_particles_2.emitting = false
		door_collision_2.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_particles_start_timer_timeout():
		mist_particles_1.emitting = true
		mist_particles_2.emitting = true
		$ParticlesStopTimer.start()
