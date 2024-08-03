extends Area2D


@export var requires_key = false

func _ready():
	$ControllerSprite2D.visible = false

func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && (!requires_key || area.get_parent().has_key):
		$ControllerSprite2D.visible = true

func _on_area_exited(area):
	if area.name == "PlayerHurtbox":
		$ControllerSprite2D.visible = false
