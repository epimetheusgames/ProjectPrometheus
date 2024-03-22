extends RayCast2D

var speed = 10
var max_bounces = 3
var bounces = 0 
var seconds_since_init = 0


func _ready():
	add_exception(get_parent().get_node("Player").get_node("Player"))

func _process(delta):
	var collision_normal = get_collision_normal()
	if get_collider() && collision_normal != Vector2.ZERO:
		position = get_collision_point()
		target_position = -(target_position).normalized().reflect(collision_normal) * 2 * speed
		bounces += 1
		$AudioStreamPlayer2D.volume_db -= 5
	else:
		position += (target_position).normalized() * delta * 60 * speed
		
	if $AudioStreamPlayer2D.volume_db <= -40:
		queue_free()
		
	seconds_since_init += delta

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()

func _on_area_2d_area_entered(area):
	return
	if area.name == "PlayerHurtbox":
		$AudioStreamPlayer2D.play($AudioStreamPlayer2D.get_playback_position() - seconds_since_init)
