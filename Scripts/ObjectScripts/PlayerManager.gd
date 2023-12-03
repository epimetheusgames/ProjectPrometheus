extends Node2D

@onready var start_zoom = $Camera.zoom
@onready var target_zoom = $Camera.zoom
@onready var graphics_efficiency = get_parent().graphics_efficiency

func _ready():
	if graphics_efficiency:
		$Player/PlayerAmbianceParticles.queue_free()

func _process(delta):
	# Camera follows player.
	var follow_position = $Player.position + ($PhysicsPlayerContainer.get_children()[0].position if $Player.physics_player else Vector2.ZERO)
	$Camera/CameraCollider.position += (follow_position - $Camera/CameraCollider.position) * 0.05 * (delta * 60)
	$Camera.position += ($Camera/CameraCollider.position - $Camera.position) * 0.1 * (delta * 60)
	$Camera.zoom += (target_zoom - $Camera.zoom) * 0.01
	
	var player_vel = 0
	
	$PointLight2D.position = $Player.position
