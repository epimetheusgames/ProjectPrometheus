extends Area2D

@onready var loaded_exploder = preload("res://Objects/StaticObjects/Exploder.tscn")


func _on_area_entered(area):
	if area.name == "DeathZone":
		get_parent().get_node("Player").get_node("Camera").get_node("BossBar").value -= 10
		
		for i in range(30):
			var rng = RandomNumberGenerator.new()
			var instantiated_exploder = loaded_exploder.instantiate()
			instantiated_exploder.position = position + $CollisionShape2D.position + Vector2(rng.randf_range(-100, 100), rng.randf_range(-100, 100))
			instantiated_exploder.velocity = Vector2(rng.randf_range(-5, 5), rng.randf_range(-5, 5))
			instantiated_exploder.no_damage = true
			get_parent().add_child(instantiated_exploder)
