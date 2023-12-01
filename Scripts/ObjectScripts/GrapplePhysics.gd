extends CharacterBody2D


@onready var gravity = get_parent().get_parent().gravity / 5

func _physics_process(delta):
	velocity.y += gravity
	position += velocity * delta * 60
