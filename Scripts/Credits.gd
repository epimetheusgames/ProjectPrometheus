extends Node2D

var increase_orbitvel = false

func _ready():
	$FallingParticles.process_material.angular_velocity_max = 200
	$FallingParticles.process_material.spread = 40
	
func _process(_delta):
	if increase_orbitvel:
		$FallingParticles.process_material.orbit_velocity_max += 0.003

func _on_start_timer_timeout():
	$FallingParticles.emitting = true
	$Music.play()

func _on_left_beat_timer_timeout():
	$LeftExplosions.emitting = true
	$RightExplosions.emitting = true
	
func _on_drop_lead_up_timer_timeout():
	$FallingParticles.amount = 300
	$FallingParticles.process_material.direction.y = -1
	$FallingParticles.position.y = 670
	$FallingParticles4.emitting = true

func _on_just_before_drop_timer_timeout():
	$FallingParticles4.emitting = true
	$LeftExplosions.amount += 1
	$RightExplosions.amount += 1
	
func _on_drop_timer_timeout():
	$FallingParticles2.emitting = true
	$LeftExplosions2.emitting = true
	$RightExplosions2.emitting = true

func _on_drop_change_timer_timeout():
	$FallingParticles3.emitting = true
	$FallingParticles.emitting = false
	$LeftExplosions.process_material.damping_max = 500
	$RightExplosions.process_material.damping_max = 500
	$LeftExplosions.process_material.damping_min = 100
	$RightExplosions.process_material.damping_min = 100

func _on_end_melody_start_timer_timeout():
	increase_orbitvel = true
	$FallingParticles.emitting = true
	$FallingParticles.process_material.orbit_velocity_max = 0.05  
	$FallingParticles2.emitting = false
	$FallingParticles3.emitting = false

func _on_end_timer_timeout():
	increase_orbitvel = false
	$FallingParticles.process_material.orbit_velocity_max = 0
	$FallingParticles.one_shot = true 
	$LeftExplosions2.emitting = true
	$RightExplosions2.emitting = true
	$LeftExplosions.emitting = false
	$RightExplosions.emitting = false
