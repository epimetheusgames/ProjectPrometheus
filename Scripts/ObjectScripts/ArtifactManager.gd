# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Area2D

@export var uid = 0

func _ready():
	$AnimatedSprite2D.play("Animation")
	if get_parent().get_parent().get_parent().get_node("SaveLoadFramework").load_data(get_parent().slot)[4].has(str(uid)):
		queue_free()

func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").collect_artifact(get_parent().slot, uid)
		get_parent().points += 10
		$GPUParticles2D.emitting = true
		$AnimatedSprite2D.visible = false
		$DestroyTimer.start()

func _on_destroy_timer_timeout():
	queue_free()
