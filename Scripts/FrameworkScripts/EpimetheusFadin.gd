extends Node2D


var label_progress = -2
var finished = false

func _process(delta):
	label_progress += 0.02
	
	$Label.modulate.a = sin(label_progress)
	
	if label_progress > 4:
		finished = true
