# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


func _ready():
	$CreditsAnimationPlayer.play("CreditsAnimation")

func _process(delta):
	if Input.is_action_just_pressed("esc"):
		get_parent().queue_free()
	
