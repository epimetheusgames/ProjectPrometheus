# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Area2D

var player = null


func _process(delta):
	if player:
		position = player.position + player.get_parent().position

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		player = area.get_parent()
		player.has_key = true
