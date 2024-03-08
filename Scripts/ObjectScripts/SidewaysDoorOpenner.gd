# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox":
		$PropDoorSideways.visible = !$PropDoorSideways.visible
		$PropDoorFaceForward.visible = !$PropDoorFaceForward.visible
