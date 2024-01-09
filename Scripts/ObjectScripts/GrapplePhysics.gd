extends CharacterBody2D


@onready var gravity = get_parent().get_parent().gravity
var hooked = false

func _physics_process(delta):
	if !hooked:
		position += velocity * delta * 60 - get_parent().get_parent().velocity
	elif get_parent().hook:
		position = get_parent().hook.position - get_parent().get_parent().get_parent().position - get_parent().get_parent().position
		rotation = get_parent().hook.rotation
