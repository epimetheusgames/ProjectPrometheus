extends Node2D


@onready var original_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = original_pos + (get_parent().get_parent().get_parent().get_node("Player").position - get_parent().get_parent().position)
