extends RigidBody2D

var queued_position = Vector2.ZERO

func _integrate_forces(state):
	if queued_position != Vector2.ZERO:
		position = queued_position
