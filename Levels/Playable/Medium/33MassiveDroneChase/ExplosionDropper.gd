extends Node2D

@onready var explosion_loaded = preload("res://Objects/StaticObjects/Exploder.tscn")


func _on_timer_timeout():
	var explosion_instance = explosion_loaded.instantiate()
	explosion_instance.velocity.x = 10
	explosion_instance.position = get_parent().get_parent().position + get_parent().position + position
	get_parent().get_parent().get_parent().add_child(explosion_instance)
