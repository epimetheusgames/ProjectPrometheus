# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


@onready var loaded_broken_floodlight = preload("res://Assets/Images/Objects/Props/FloodlightBroken.png")

func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox" || area.name == "PlayerBulletHurter":
		$FloodlightSprite.texture = loaded_broken_floodlight
		$FloodlightSprite.self_modulate = Color.WHITE
		$SparkParticles.emitting = false
