extends Node2D


var label_progress = -2
var finished = false
var decreasing = false
var wait_decrease = false

func _process(delta):
	if !wait_decrease:
		label_progress += 0.02
	
	$CanvasModulate.color.r = max(label_progress, 0)
	$CanvasModulate.color.g = max(label_progress, 0)
	$CanvasModulate.color.b = max(label_progress, 0)
	
	if decreasing:
		label_progress -= 0.04
	
	if label_progress < -1 && decreasing:
		finished = true

func _on_timer_timeout():
	decreasing = true
