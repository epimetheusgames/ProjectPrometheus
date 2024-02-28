# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D



func _on_despawn_timer_timeout():
	modulate = Color(1, 1, 1, 0.5)
	$Body.collision_layer = 0
	$Head.collision_layer = 0
	$Wheel.collision_layer = 0
