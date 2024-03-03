# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


@export var item_switch_type = "Weapon"
@onready var player = get_parent().get_node("Player").get_node("Player") if !get_parent().is_multiplayer else null
@export var dont_show_sprite = false
const next_item_key = {
	"Weapon": "RocketBoost",
	"RocketBoost": "ArmGun",
	"ArmGun": "Grapple",
	"Grapple": "Weapon"
}
var pulse_x = 0

func _ready():
	$Preview.visible = false
	$Preview2.visible = false
	
	if !dont_show_sprite:
		if item_switch_type == "Weapon":
			$SwordCollect.visible = true
			$SwordCollect2.visible = true
		if item_switch_type == "RocketBoost":
			$RocketBoostCollect.visible = true
			$RocketBoostCollect2.visible = true
		if item_switch_type == "ArmGun":
			$ArmGunCollect.visible = true
			$ArmGunCollect2.visible = true
		if item_switch_type == "Grapple":
			$GrappleCollect.visible = true
			$GrappleCollect2.visible = true

func _process(delta):
	pulse_x += 0.07 * delta * 60
	
	if get_parent().is_multiplayer:
		if multiplayer.is_server():
			player = get_parent().server_player.get_node("Player")
		else:
			player = get_parent().client_player.get_node("Player")
	
	if item_switch_type == next_item_key[player.current_ability]:
		modulate = Color(1.3 + sin(pulse_x) / 2, 1.3 + sin(pulse_x) / 2, 1.3 + sin(pulse_x) / 2, 1)
	else:
		modulate = Color(0.8, 0.8, 0.8, 1)

func wrong_item():
	$AnimationPlayer.play("WrongItem")

func right_item(): pass
