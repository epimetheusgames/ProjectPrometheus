extends Node2D


func _ready():
	if get_parent().get_parent().get_parent().is_cutscene:
		$AnimationPlayer.play("Open")
