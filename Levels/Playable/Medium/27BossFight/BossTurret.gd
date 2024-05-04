extends Node2D


@onready var destroyed_explosion = preload("res://Objects/StaticObjects/Exploder.tscn")

func _on_turret_hurtbox_area_entered(area):
	if area.name == "PlayerBulletHurter":
		area.get_parent().call_deferred("queue_free")
		$HealthBar.value -= 7
		
func _process(delta):
	if $HealthBar.value <= 0:
		for i in range(10):
			var instantiated_explosion = destroyed_explosion.instantiate()
			instantiated_explosion.position = get_parent().position + position
			get_parent().get_parent().add_child(instantiated_explosion)
			instantiated_explosion._on_explosion_hitbox_body_entered(get_parent())
		queue_free()
