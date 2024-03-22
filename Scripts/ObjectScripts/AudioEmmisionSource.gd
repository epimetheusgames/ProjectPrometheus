extends Node2D


@onready var preloaded_audio_caster = preload("res://Objects/StaticObjects/AudioRaycast.tscn")

func _ready():
	$AudioStreamPlayer2D.play()

func _process(delta):
	for j in range(5):
		var rng = RandomNumberGenerator.new()
		
		var audio_caster = preloaded_audio_caster.instantiate()
		audio_caster.position = position
		audio_caster.target_position = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized() * 15
		audio_caster.get_node("AudioStreamPlayer2D").stream = $AudioStreamPlayer2D.stream
		get_parent().add_child(audio_caster)
		audio_caster.get_node("AudioStreamPlayer2D").play($AudioStreamPlayer2D.get_playback_position())

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()
