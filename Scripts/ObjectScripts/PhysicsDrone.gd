extends RigidBody2D

var set_queued_pos = false
var queued_position = Vector2.ZERO
var queued_rotation = 0

func _integrate_forces(state):
	if set_queued_pos:
		state.transform = Transform2D(queued_rotation, queued_position)
		set_queued_pos = false

func _on_despawn_timer_timeout():
	queue_free()

func _on_ground_fall_timer_timeout():
	$CollisionPolygon2D.disabled = true
