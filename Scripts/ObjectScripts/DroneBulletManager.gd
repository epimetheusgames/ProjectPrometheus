extends Node2D


var velocity = Vector2.ZERO

func _process(delta):
	position += velocity


func _on_despawn_timer_timeout():
	queue_free()
