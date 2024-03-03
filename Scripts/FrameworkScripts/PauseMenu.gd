# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


# This should be a child of the Player node inside of PlayerManager.
extends Node2D


var showing = false


func _ready():
	$CanvasLayer.hide()

func _process(delta):
	if Input.is_action_just_released("ui_accept") and showing:
		# Exit to menu, don't question it.
		get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").exit_to_menu(get_parent().get_parent().get_parent().level, get_parent().get_parent().get_parent().floor, get_parent().get_parent().get_parent().slot, get_parent().get_parent().get_parent().points, get_parent().get_parent().get_parent().time, get_parent().get_parent().get_parent().is_max_level, get_parent().get_parent().get_parent().deaths)
		
	# Open and close options menu.
	if Input.is_action_just_pressed("esc") && !get_parent().was_open:
		if showing:
			get_parent().get_parent().blur_enabled = false
			get_parent().get_parent().get_parent().just_unpaused = true
			$CanvasLayer.hide()
		else:
			get_parent().get_parent().blur_enabled = true
			get_parent().get_parent().get_node("Blur").visible = true
			$CanvasLayer.show()
		showing = !showing
		
	if showing:
		get_tree().paused = true
	elif !get_parent().open_dialogue == true:
		get_tree().paused = false

func _on_hurt_pause_timer_timeout():
	get_tree().paused = false
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT && !get_parent().get_parent().get_parent().is_multiplayer:
		showing = true
		show()
