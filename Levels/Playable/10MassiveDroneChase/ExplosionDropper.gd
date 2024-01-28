extends Node2D

@onready var explosion_loaded = preload("res://Objects/StaticObjects/Exploder.tscn")


func _on_timer_timeout():
	var explosion_instance = explosion_loaded.instantiate()
	explosion_instance.velocity.x = 10
	add_child(explosion_instance)
