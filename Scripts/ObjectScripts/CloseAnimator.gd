# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# ----------------------------------------CloseAnimator.gd-----------------------------------------------|
# Death animation player.                                                                                |
# -------------------------------------------------------------------------------------------------------|


extends Node2D


# If the animation is closing right now.
var closing = false

# Check if we should start closing right now.
var start = false

func _process(delta):
	if closing && start:
		if !get_parent().get_parent().get_parent().is_multiplayer:
			get_tree().paused = true
			
		get_parent().get_parent().get_parent().self_modulate.r += 10 * delta * 60
		
		$BlackBarTop.scale.y += (1005 - $BlackBarTop.scale.y) * 0.1 * delta * 60
		$BlackBarBottom.scale.y += (1005 - $BlackBarBottom.scale.y) * 0.1 * delta * 60
		
		if $ColorRect.color.a < 0.8:
			$ColorRect.color.a += 0.05
		
		if $BlackBarTop.scale.y > 980:
			$WhiteLine.visible = true 
			$WhiteLine.scale.x -= $WhiteLine.scale.x * 0.1 * delta * 60
			
			if $WhiteLine.scale.x <= 1:
				$WhiteLine.visible = false
				
				if $DeathWaitTimer.time_left == 0:
					$DeathWaitTimer.start()
	elif closing:
		if $AnimDelayTimer.time_left == 0:
			$AnimDelayTimer.start()
			get_parent().get_parent().get_node("Player").dead = true
		
		if Engine.time_scale > 0.3:
			Engine.time_scale -= 0.01
			
		$ColorRect.color.a += 0.001 * delta * 60
		
	if closing:
		get_parent().get_parent().get_node("Player").get_node("PointLight2D").visible = false
		
		if get_parent().get_parent().get_parent().get_node_or_null("Fog"):
			get_parent().get_parent().get_parent().get_node("Fog").visible = false

func _on_death_wait_timer_timeout():
	if (get_parent().get_parent().get_parent().is_multiplayer && get_parent().get_parent().is_multiplayer_authority()) || !get_parent().get_parent().get_parent().is_multiplayer:
		get_parent().get_parent().get_node("Player").die()

func _on_anim_delay_timer_timeout():
	Engine.time_scale = 0.8
	start = true
