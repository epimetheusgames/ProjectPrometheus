extends Node2D

func _on_start_timer_timeout():
	$FallingParticles.process_material.angular_velocity_max = 200
	$FallingParticles.process_material.spread = 30
	$Music.play()

func _on_left_beat_timer_timeout():
	$LeftExplosions.emitting = true

func _on_right_beat_timer_timeout():
	$RightExplosions.emitting = true

func _ready():
	$FallingParticles.emitting = true
