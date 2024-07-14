extends Node2D


func _on_start_wait_time_timeout():
	$SteamEmissionTimer.start()

func _on_steam_emission_timer_timeout():
	$GPUParticles2D.emitting = true
	$PlayerBoostArea/CollisionShape2D.disabled = false
	$BoostAreaDisablerTimer.start()
	$SteamSparySFX.play()

func _on_boost_area_disabler_timer_timeout():
	$PlayerBoostArea/CollisionShape2D.disabled = true
