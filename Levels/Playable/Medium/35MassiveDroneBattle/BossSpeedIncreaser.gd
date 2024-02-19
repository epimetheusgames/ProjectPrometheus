extends Area2D


@export var speed_mult = 1.0

func _on_area_entered(area):
	if area.name == "DeathZone":
		get_parent().get_node("DroneManager").speed *= speed_mult
