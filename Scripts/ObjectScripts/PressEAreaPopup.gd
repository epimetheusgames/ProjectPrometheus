extends Area2D


func _ready():
	$ControllerSprite2D.visible = false

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		$ControllerSprite2D.visible = true

func _on_area_exited(area):
	if area.name == "PlayerHurtbox":
		$ControllerSprite2D.visible = false
