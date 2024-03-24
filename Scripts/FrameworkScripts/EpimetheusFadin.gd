# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

# This file handles the fadein animation at the start of the game.

extends Node2D


var finished = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Anim":
		finished = true
		Fade.fade_in()
		
func _process(delta):
	if Input.is_anything_pressed():
		finished = true
		Fade.fade_in()
