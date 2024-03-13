# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Area2D

var player = null
var target_position = Vector2.ZERO


func _process(delta):
	if player:
		target_position = player.position + player.get_parent().position
		position += (target_position - position) * 0.02

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		player = area.get_parent()
		player.has_key = true
