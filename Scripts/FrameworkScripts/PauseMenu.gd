# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


# This should be a child of the Player node inside of PlayerManager.
extends Node2D


var showing = false


func _process(delta):
	# Open and close options menu.
	if Input.is_action_just_pressed("esc") && !get_parent().was_open:
		if showing:
			get_parent().get_parent().get_node("Blur").get_node("AnimationPlayer").play("FadeoutBlur")
			$AnimationPlayer.play("FadeoutPauseMenu")
		else:
			get_parent().get_parent().get_node("Blur").get_node("AnimationPlayer").play("FadeinBlur")
			$AnimationPlayer.play("FadeinPauseMenu")
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
		get_parent().get_parent().get_node("Blur").get_node("AnimationPlayer").play("FadeinBlur")
		$AnimationPlayer.play("FadeinPauseMenu")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "ExitMenu":
		# Exit to menu, don't question it.
		get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").exit_to_menu(get_parent().get_parent().get_parent().level, get_parent().get_parent().get_parent().floor, get_parent().get_parent().get_parent().slot, get_parent().get_parent().get_parent().points, get_parent().get_parent().get_parent().time, get_parent().get_parent().get_parent().is_max_level, get_parent().get_parent().get_parent().deaths)


func _on_resume_button_button_up():
	if showing && get_tree().paused:
		get_tree().paused = false
		showing = false
		get_parent().get_parent().get_node("Blur").get_node("AnimationPlayer").play("FadeoutBlur")
		$AnimationPlayer.play("FadeoutPauseMenu")
		$CanvasLayer/ForManipulatingTheseNodes/SettingsMenu.visible = false

func _on_settings_button_button_up():
	$CanvasLayer/ForManipulatingTheseNodes/SettingsMenu.visible = true

func _on_exit_button_button_up():
	get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").has_keycard = false
	$AnimationPlayer.play("ExitMenu")
