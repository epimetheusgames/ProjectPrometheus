extends Node2D


var active = false

func _process(delta):
	if active:
		var mouse_pos = get_viewport().get_mouse_position() - Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
		
		$Line2D.points[2].x = mouse_pos.x / 100 + (mouse_pos.y / 80) - 20
		$Line2D.points[2].y = -25 - (mouse_pos.x / 150) + (mouse_pos.y / 200)
		
		var mouse_direction = (mouse_pos - $Line2D.points[2]).normalized()
		
		$Line2D.points[3] = $Line2D.points[2] + (mouse_direction * 20)
