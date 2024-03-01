extends Node2D


@export var locked_door_node: Node2D

func _on_area_2d_area_entered(area):
	if area.name == "PlayerBulletHurter":
		if locked_door_node && $AnimatedSprite2D.animation == "Open":
			locked_door_node.get_node("StaticBody2D").get_node("CollisionShape2D").queue_free()
			locked_door_node.get_node("Area2D").get_node("CollisionShape2D").queue_free()
			
		$AnimatedSprite2D.play("Closing")
		area.get_parent().queue_free()

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Closing":
		$AnimatedSprite2D.play("Closed")
	if $AnimatedSprite2D.animation == "Opening":
		$AnimatedSprite2D.play("Open")
