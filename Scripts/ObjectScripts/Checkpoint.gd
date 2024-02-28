# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D

@export var player_checkpoint_item = "Weapon"

func activate():
	if $AnimatedSprite2D.animation != "Activated":
		$AnimatedSprite2D.play("Activating")
		$AudioStreamPlayer.play()

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("Activated")
