# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


var finished = false

func _ready():
	$CreditsAnimationPlayer.play("CreditsAnimation")

func _process(delta):
	if Input.is_action_just_pressed("esc") && !get_parent().get_parent().get_node("Player"):
		get_parent().queue_free()
	

func _on_credits_animation_player_animation_finished(anim_name):
	finished = true
