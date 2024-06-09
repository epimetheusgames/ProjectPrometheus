# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# ------------------------------------------PlayerManager.gd---------------------------------------------|
# Main player manager for miscelanious settings and camera movement and collision.                       |
#--------------------------------------------------------------------------------------------------------|

extends Node2D


@onready var destroyed_explosion = preload("res://Objects/StaticObjects/Exploder.tscn")
@export var left_turret = false
@export var right_turret = false
var already_exploded = false

func _on_turret_hurtbox_area_entered(area):
	if area.name == "PlayerBulletHurter":
		area.get_parent().call_deferred("queue_free")
		$HealthBar.value -= 7
		$HealthBar.visible = true

func _ready():
	if left_turret:
		$HealthBar.value = get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").turret_one_health
	if right_turret:
		$HealthBar.value = get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").turret_two_health
		
	if $HealthBar.value <= 0:
		already_exploded = true
		queue_free()

func _process(delta):
	if left_turret:
		get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").turret_one_health = $HealthBar.value
	if right_turret:
		get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").turret_two_health = $HealthBar.value
		
	if $HealthBar.value <= 0 && !already_exploded:
		already_exploded = true
		
		for i in range(10):
			var instantiated_explosion = destroyed_explosion.instantiate()
			instantiated_explosion.position = get_parent().position + position
			get_parent().get_parent().add_child(instantiated_explosion)
			instantiated_explosion._on_explosion_hitbox_body_entered(get_parent())
			
		get_parent().health -= 24
		get_parent().player.get_parent().get_node("Camera").get_node("BossBar").value = get_parent().health
		queue_free()
