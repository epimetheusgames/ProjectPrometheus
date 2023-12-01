extends CharacterBody2D


@onready var gravity = get_parent().get_parent().gravity
var hooked = false

func _physics_process(delta):
	if not hooked:
		velocity.y += gravity
	else:
		velocity = Vector2.ZERO
	position += velocity * delta * 60 - get_parent().get_parent().velocity
