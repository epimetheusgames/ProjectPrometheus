extends Node2D


@export var speed = 1.0
var scrolling = false

func scroll(text):
	$TextHolder.position = $TextStartPos.position
	$TextHolder.text = text
	scrolling = true
	
func _process(delta):
	if scrolling:
		$TextHolder.position.x -= speed * delta * 60
