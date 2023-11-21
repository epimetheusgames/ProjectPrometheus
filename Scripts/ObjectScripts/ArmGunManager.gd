extends Node2D

@onready var loaded_bullet = preload("res://Objects/StaticObjects/PlayerBullet.tscn")
var active = false

func _process(delta):
	if active:
		visible = true
		
		var mouse_pos = get_viewport().get_mouse_position() - Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
		
		$Line2D.points[2].x = mouse_pos.x / 100 + (mouse_pos.y / 80) - 20
		$Line2D.points[2].y = -25 - (mouse_pos.x / 150) + (mouse_pos.y / 200)
		
		var mouse_direction = (get_global_mouse_position() - (get_parent().position + $Line2D.points[2])).normalized()
		
		$Line2D.points[3] = $Line2D.points[2] + (mouse_direction * 20)
		
		if Input.is_action_just_pressed("mouse_click") || Input.is_action_just_pressed("attack"):
			var bullet = loaded_bullet.instantiate()
			bullet.position = get_parent().position + $Line2D.points[2]
			bullet.direction = mouse_direction
			bullet.velocity = 5
			get_parent().get_parent().add_child(bullet)
	else:
		visible = false
