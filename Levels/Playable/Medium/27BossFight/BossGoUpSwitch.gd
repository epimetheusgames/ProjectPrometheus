# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


var player_in_area = false
var switched_up = false

@onready var loaded_switch_down_sprite = preload("res://Assets/Images/Objects/FunctionalProps/SwitchUpDownSprite1.png")
@onready var loaded_switch_up_sprite = preload("res://Assets/Images/Objects/FunctionalProps/SwitchUpDownSprite2.png")

func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox":
		player_in_area = true

func _on_area_2d_area_exited(area):
	if area.name == "PlayerHurtbox":
		player_in_area = false
		
func _process(delta):
	if Input.is_action_just_pressed("interact") && get_parent().get_node("Boss").health < 53:
		get_parent().get_node("Boss").health = 49
		get_parent().get_node("Boss").can_get_hurt_by_bullets = true
		switched_up = true
		
	if get_parent().get_node("Boss").health < 53:
		$PressEAreaPopup.visible = true
		$Switch.modulate = Color(1, 1, 1, 1)
	else:
		$PressEAreaPopup.visible = false
		$Switch.modulate = Color(1, 1, 1, 0.4)
		
	if !switched_up:
		$Switch.texture = loaded_switch_down_sprite
	else:
		$Switch.texture = loaded_switch_up_sprite
	
