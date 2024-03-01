extends Node2D


func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox":
		$PropDoorSideways.visible = !$PropDoorSideways.visible
		$PropDoorFaceForward.visible = !$PropDoorFaceForward.visible
