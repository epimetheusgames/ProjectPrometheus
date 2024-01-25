extends Area2D


func _on_area_entered(area):
	if area.name == "PlayerHurtbox":
		get_parent().points += 10
		$GPUParticles2D.emitting = true
		$ArtifactSprite.visible = false
		$DestroyTimer.start()

func _on_destroy_timer_timeout():
	queue_free()
