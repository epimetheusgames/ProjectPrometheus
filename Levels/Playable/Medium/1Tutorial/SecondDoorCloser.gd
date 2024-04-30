# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Area2D


@export var door: Node2D
var already_entered = false

func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && !already_entered:
		already_entered = true
		door._on_area_2d_area_entered(area)
