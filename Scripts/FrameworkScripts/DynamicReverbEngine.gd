# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


@onready var raycasts = [
	$RayCast2D,
	$RayCast2D2,
	$RayCast2D3,
	$RayCast2D4,
	$RayCast2D5,
	$RayCast2D6,
	$RayCast2D7,
	$RayCast2D8,
]

@export var use_double_parent_position = false

func _ready():
	reload_distances()

func reload_distances():
	if use_double_parent_position:
		position = get_parent().get_parent().position
		
	var distances := []
	
	for raycast in raycasts:
		var collision_point = raycast.get_collision_point()
		var collision_point_local_space: Vector2 = collision_point - global_position
		var raycast_distance = collision_point_local_space.distance_to(Vector2.ZERO)
		
		distances.append(raycast_distance)
	
	var array_sum = 0
	for distance in distances:
		array_sum += distance
		
	var average_distance = array_sum / distances.size()
	
	# If average distance is less than 50, the room is way too small.
	var parent = get_parent()
	if average_distance > 50 && average_distance < 100:
		parent.bus = &"SmallSpaceSFX"
	if average_distance >= 100 && average_distance < 200:
		parent.bus = &"MediumSpaceSFX"
	if average_distance >= 200:
		parent.bus = &"LargeSpaceSFX"
