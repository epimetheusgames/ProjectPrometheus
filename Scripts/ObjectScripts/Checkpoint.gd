# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# The code for this is simple because checkpointing is handled in the player script.                     |
# -------------------------------------------------------------------------------------------------------|


extends Node2D

# The type of item that will be saved with the checkpoint.
@export var player_checkpoint_item = "Weapon"

# Checkpoints are deprecated, in most cases just ignore me.
@export var ignore_old_checkpoint = true

# Is the checkpoint integrated into an item switcher.
@export var switcher_checkpoint = false


# Handle item switcher integration.
func _ready():
	if ignore_old_checkpoint:
		$CheckpointCollision/CollisionPolygon2D.disabled = true
		$AnimatedSprite2D.visible = false

# Play activation animation.
func activate():
	if !switcher_checkpoint && $AnimatedSprite2D.animation != "Activated":
		$AnimatedSprite2D.play("Activating")
		$AudioStreamPlayer.play()

# Play final activated animation.
func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("Activated")
