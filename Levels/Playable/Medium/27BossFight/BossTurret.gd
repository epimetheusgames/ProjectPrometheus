extends Node2D


@onready var destroyed_explosion = preload("res://Objects/StaticObjects/Exploder.tscn")
@export var left_turret = false
@export var right_turret = false
var already_exploded = false

func _on_turret_hurtbox_area_entered(area):
	if area.name == "PlayerBulletHurter":
		area.get_parent().call_deferred("queue_free")
		$HealthBar.value -= 7
		
func _process(delta):
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
