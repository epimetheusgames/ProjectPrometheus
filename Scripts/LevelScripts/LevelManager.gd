extends Node2D

@export var level = 0
@export var floor = 0
var slot = -1

func _on_ambiant_background_finished():
	$AmbiantBackground.play()
