# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends CharacterBody2D


@onready var gravity = get_parent().get_parent().gravity
var hooked = false

func _physics_process(delta):
	if !hooked:
		position += (velocity - (get_parent().get_parent().velocity * Engine.time_scale)) * delta * 60
	elif get_parent().hook:
		position = get_parent().hook.position - get_parent().get_parent().get_parent().position - get_parent().get_parent().position
		rotation = get_parent().hook.rotation
