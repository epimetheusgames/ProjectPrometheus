# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D

@export var player_checkpoint_item = "Weapon"
@export var ignore_old_checkpoint = true
@export var switcher_checkpoint = false

func _ready():
	if ignore_old_checkpoint:
		$CheckpointCollision/CollisionPolygon2D.disabled = true
		$AnimatedSprite2D.visible = false

func activate():
	if !switcher_checkpoint && $AnimatedSprite2D.animation != "Activated":
		$AnimatedSprite2D.play("Activating")
		$AudioStreamPlayer.play()

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("Activated")
