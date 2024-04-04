extends RayCast2D

var speed = 10
var max_bounces = 3
var bounces = 0 
var seconds_since_init = 0
var hit_hearing_point = false
var origin_node = null
@onready var loaded_audio_player = preload("res://Objects/StaticObjects/RaycastAudioPlayer.tscn")
var audio_stream = null
var total_distance = 0
var pixels_per_second = 10


func _process(delta):
	if bounces < max_bounces:
		var collision_normal = get_collision_normal()
		if get_collider() && collision_normal != Vector2.ZERO:
			total_distance += position.distance_to(get_collision_point())
			position = get_collision_point()
			target_position = -(target_position).normalized().reflect(collision_normal) * 100000
			bounces += 1
			
			if get_collider().name == "Player":
				bounces = 10
				hit_hearing_point = true
				seconds_since_init += total_distance / pixels_per_second
				
				get_tree().get_root().get_node("Root").get_node("Level").get_children()[0].last_100_raycasts.append(self)
		
				var instantiated_audio_player = loaded_audio_player.instantiate()
				instantiated_audio_player.stream = audio_stream
				add_child(instantiated_audio_player)
				instantiated_audio_player.play(seconds_since_init)
				
				if len(get_tree().get_root().get_node("Root").get_node("Level").get_children()[0].last_100_raycasts) > 100:
					if is_instance_valid(get_tree().get_root().get_node("Root").get_node("Level").get_children()[0].last_100_raycasts[0]):
						get_tree().get_root().get_node("Root").get_node("Level").get_children()[0].last_100_raycasts[0].queue_free()
					get_tree().get_root().get_node("Root").get_node("Level").get_children()[0].last_100_raycasts.pop_front()
		else: 
			position += (target_position).normalized() * delta * 60 * speed
		
	elif !hit_hearing_point:
		queue_free()
	
	seconds_since_init += delta

func _on_queue_free_timer_timeout():
	queue_free()
