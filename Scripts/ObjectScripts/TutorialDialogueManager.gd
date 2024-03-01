# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


var displaying_dialogue = false
var displaying_ind = -1
var displaying_opacity = 0
var dialogue_displaying = null
var fading_in = false
var fading_out = false

func enter_tutorial_area(tutorial_box_ind):
	if tutorial_box_ind == 1:
		dialogue_displaying = $ItemSwitcherDialogue
	if tutorial_box_ind == 2:
		dialogue_displaying = $MouseToShoot
	if tutorial_box_ind == 3:
		dialogue_displaying = $MouseToWeapon
	if tutorial_box_ind == 4:
		dialogue_displaying = $ShootSwitch
		
	dialogue_displaying.visible = true
	displaying_dialogue = true
	displaying_ind = tutorial_box_ind
	fading_in = true
	dialogue_displaying.modulate.a = 0
		
func _process(delta):
	if displaying_dialogue:
		if Input.is_action_just_pressed("interact"):
			fading_out = true
			
		if displaying_opacity < 1 && fading_in:
			displaying_opacity += 0.05 * delta * 60
		elif fading_in:
			fading_in = false
			
		if displaying_opacity > 0 && fading_out:
			displaying_opacity -= 0.05 * delta * 60
		elif fading_out:
			dialogue_displaying.visible = false
			displaying_dialogue = false
			dialogue_displaying = null
			displaying_ind = -1
			fading_out = false
			return
		
		dialogue_displaying.modulate.a = displaying_opacity
