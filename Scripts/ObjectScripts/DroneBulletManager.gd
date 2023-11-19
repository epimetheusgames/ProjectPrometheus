extends Node2D


var velocity = Vector2.ZERO

func _process(delta):
	position += velocity
	rotation = atan2(velocity.y, velocity.x) + (1.0/2.0 * PI)

func _on_despawn_timer_timeout():
	queue_free()

func _on_bullet_hurter_body_entered(body):
	if body.name != "Player":
		queue_free()
