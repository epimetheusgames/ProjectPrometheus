extends RigidBody2D

var set_queued_pos = false
var queued_position = Vector2.ZERO
var queued_rotation = 0

func _integrate_forces(state):
	if set_queued_pos:
		state.transform = Transform2D(queued_rotation, queued_position)
		set_queued_pos = false

func _process(delta):
	modulate.a -= delta * 0.2
	
	if modulate.a <= 0:
		queue_free()
