extends Area2D


@export var tutorial_box_ind = -1

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		area.get_parent().get_parent().get_node("Camera").get_node("TutorialDialogues").enter_tutorial_area(tutorial_box_ind)
