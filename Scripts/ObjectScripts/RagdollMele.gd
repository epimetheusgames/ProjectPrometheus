# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


var dont_fall = false

func _on_despawn_timer_timeout():
	if !dont_fall:
		modulate = Color(1, 1, 1, 0.5)
		$Head/CollisionShape2D.queue_free()
		$Body/CollisionShape2D2.queue_free()
		$Wheel/CollisionShape2D3.queue_free()
		
		if $SpearLeft:
			$SpearLeft.queue_free()
		if $SpearRight:
			$SpearRight.queue_free()

func _on_queue_free_timer_timeout():
	if !dont_fall:
		queue_free()
