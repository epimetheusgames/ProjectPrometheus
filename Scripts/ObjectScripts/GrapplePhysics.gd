extends CharacterBody2D


@onready var gravity = get_parent().get_parent().gravity
var hooked = false

func _physics_process(delta):
	position += velocity * delta * 60 - get_parent().get_parent().velocity
