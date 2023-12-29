extends Node2D


var closing = false

func _process(delta):
	if closing:
		get_parent().get_parent().get_parent().self_modulate.r += 10
		
		$BlackBarTop.scale.y += 8 * delta * 60
		$BlackBarBottom.scale.y += 8 * delta * 60
		
		if $BlackBarTop.scale.y > 1000:
			$WhiteLine.visible = true 
			$WhiteLine.scale.x -= $WhiteLine.scale.x * 0.1 * delta * 60
			
			if $WhiteLine.scale.x <= 1:
				$WhiteLine.visible = false
				
				if $DeathWaitTimer.time_left == 0:
					$DeathWaitTimer.start()

func _on_death_wait_timer_timeout():
	get_parent().get_parent().get_node("Player").die()
