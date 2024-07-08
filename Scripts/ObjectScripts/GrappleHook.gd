# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D
var area_entered = null
var hooked = false
@export var dont_use_swing_mode = false
@export var movement_point_1: Node2D
@export var movement_point_2: Node2D
@export var movement_speed = 5.0
var movement_progress = 0

func _ready():
	add_to_group("hooks")
	
func _physics_process(delta):
	if area_entered:
		if area_entered.name == "GrappleColider":
			area_entered.get_parent().get_parent().hooked = true
			area_entered.get_parent().get_parent().hook = self
			area_entered.get_parent().get_parent().handle_hooked()
			hooked = true
			
			if movement_point_1:
				position = movement_point_1.position
			
		if area_entered.name == "PlayerHurtbox" && !area_entered.get_parent().get_node("GrappleManager").air_grapling:
			area_entered.get_parent().get_node("GrappleManager").hooked = false
			area_entered.get_parent().get_node("GrappleManager").grapling = false
			area_entered.get_parent().get_node("GrappleManager").get_node("GrappleUp").stop()
			area_entered.get_parent().get_node("GrappleManager").get_node("GrappleCollide").play()
			area_entered.get_parent().get_node("GrappleManager").get_node("GrappleBody").hooked = false
			area_entered.get_parent().grappling_effects = false
			area_entered.get_parent().get_node("GrappleManager").hook = null
		
		area_entered = null
	
	if hooked && movement_point_1 && movement_point_2 && position.distance_to(movement_point_2.position) > 5:
		position += position.direction_to(movement_point_2.position) * movement_speed
	if movement_point_1 && movement_point_2:
		if position.distance_to(movement_point_2.position) <= 5 && !$DespawnTimer.time_left > 0:
			$DespawnTimer.start()

func _on_area_2d_area_entered(area):
	if area.name == "GrappleColider" || area.name == "PlayerHurtbox":
		area_entered = area

func _on_despawn_timer_timeout():
	queue_free()
