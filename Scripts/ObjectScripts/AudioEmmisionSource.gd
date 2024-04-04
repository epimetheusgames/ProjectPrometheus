extends Node2D


@onready var preloaded_audio_caster = preload("res://Objects/StaticObjects/AudioRaycast.tscn")
var time_since_started = 0
@export var audio_stream: AudioStream
var started = false


func _process(delta):
	if started:
		for j in range(200):
			var rng = RandomNumberGenerator.new()
			
			var audio_caster = preloaded_audio_caster.instantiate()
			audio_caster.position = position
			audio_caster.target_position = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized() * 100000
			audio_caster.origin_node = self
			audio_caster.seconds_since_init = time_since_started
			audio_caster.audio_stream = audio_stream
			get_parent().add_child(audio_caster)
			
		time_since_started += delta
	
	if time_since_started > audio_stream.get_length():
		queue_free()

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()

func play():
	started = true
