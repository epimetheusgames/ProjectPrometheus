extends StaticBody2D


func _on_hurt_box_area_entered(area):
	if area.name == "ExplosionArea":
		queue_free()
