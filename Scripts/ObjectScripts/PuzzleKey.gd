# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Area2D

var player = null
var target_position = Vector2.ZERO
var replacement_keycard = false


func _ready():
	if get_parent().get_parent().get_parent().get_node("SaveLoadFramework").has_keycard && !replacement_keycard:
		queue_free()

func _process(delta):
	if player:
		target_position = player.position + player.get_parent().position
		position += (target_position - position) * 0.03 * delta * 60

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		player = area.get_parent()
		player.has_key = true
		player.key = self
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").has_keycard = true
