extends Node2D


@onready var loaded_broken_floodlight = preload("res://Assets/Images/Objects/Props/FloodlightBroken.png")

func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox" || area.name == "PlayerBulletHurter":
		$FloodlightSprite.texture = loaded_broken_floodlight
		$FloodlightSprite.self_modulate = Color.WHITE
