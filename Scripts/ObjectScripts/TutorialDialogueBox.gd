# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D

@export_multiline var text
@onready var loaded_dialogue_overlay = preload("res://Objects/StaticObjects/DialogueBoxOverlay.tscn")
var player_near = false

func _process(delta):
	if Input.is_action_just_pressed("interact") && player_near:
		var instantiated_dialogue_overlay = loaded_dialogue_overlay.instantiate()
		instantiated_dialogue_overlay.get_node("Text").text = text
		get_parent().get_node("Player").get_node("Camera").get_node("DialogueBoxContainer").add_child(instantiated_dialogue_overlay)
		get_parent().get_node("Player").get_node("Camera").open_dialogue_box()

func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox":
		$InteractText.visible = true
		$ControllerTextureRect.visible = true
		player_near = true

func _on_area_2d_area_exited(area):
	if area.name == "PlayerHurtbox":
		$InteractText.visible = false
		$ControllerTextureRect.visible = false
		player_near = false
