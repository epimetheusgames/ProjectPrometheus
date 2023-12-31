extends Node2D


@export var item_switch_type = "Weapon"

func _ready():
	$Preview.visible = false
	
	if item_switch_type == "Weapon":
		$SwordCollect.visible = true
	if item_switch_type == "RocketBoost":
		$RocketBoostCollect.visible = true
	if item_switch_type == "ArmGun":
		$ArmGunCollect.visible = true
	if item_switch_type == "Grapple":
		$GrappleCollect.visible = true
