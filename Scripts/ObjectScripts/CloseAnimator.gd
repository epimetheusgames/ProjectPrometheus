extends Node2D


var closing = false
var start = false

func _process(delta):
	if closing && start:
		get_tree().paused = true
		get_parent().get_parent().get_parent().self_modulate.r += 10
		
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

func _on_death_wait_timer_timeout():
	if (get_parent().get_parent().get_parent().is_multiplayer && get_parent().get_parent().is_multiplayer_authority()) || !get_parent().get_parent().get_parent().is_multiplayer:
		get_parent().get_parent().get_node("Player").die()

func _on_anim_delay_timer_timeout():
	Engine.time_scale = 0.8
	start = true
