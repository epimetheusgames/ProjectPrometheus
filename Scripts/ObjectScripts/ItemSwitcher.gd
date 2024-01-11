extends Node2D


@export var item_switch_type = "Weapon"

func _ready():
	$Preview.visible = false
	$Preview2.visible = false
	
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
