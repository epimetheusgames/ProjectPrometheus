extends Node2D


var player_in_area = false
var going_up = false
@export var elevator_max_speed = 2
@export var acceleration = 0.05
@export var use_animation = false
@export var disable_collision_at_animation_end = false
var velocity = Vector2.ZERO

func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtbox":
		player_in_area = true

func _on_area_2d_area_exited(area):
	if area.name == "PlayerHurtbox":
		player_in_area = false
	
func _process(delta):
	if Input.is_action_just_pressed("interact") && player_in_area:
		if use_animation:
			$AnimationPlayer.play("ElevatorUp")
		else:
			going_up = true
		
		if $CharacterBody2D/CollisionPolygon2D2:
			$CharacterBody2D/CollisionPolygon2D2.disabled = false
		
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").start_special_music()
		
	if going_up:
		if abs(velocity.y) < elevator_max_speed:
			velocity.y -= acceleration * delta * 60
		
		position += velocity * delta * 60
	
	if !$ElevatorMusicPlayer.playing:
		$ElevatorMusicPlayer.play()

func _on_animation_player_animation_finished(anim_name):
	get_parent().get_parent().get_parent().get_node("SaveLoadFramework").end_special_music()
	
	if disable_collision_at_animation_end:
		$CharacterBody2D/CollisionPolygon2D2.disabled = true
