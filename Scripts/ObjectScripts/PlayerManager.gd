extends Node2D

var target_zoom = Vector2.ZERO
@onready var graphics_efficiency = get_parent().graphics_efficiency

func _ready():
	if graphics_efficiency:
		$Player/PlayerAmbianceParticles.queue_free()

func _process(delta):
	# Camera follows player.
	$Camera/CameraCollider.position += ($Player.position - $Camera/CameraCollider.position) * 0.05 * (delta * 60)
	$Camera.position += ($Camera/CameraCollider.position - $Camera.position) * 0.1 * (delta * 60)
	
	var player_vel = 0
	
	$PointLight2D.position = $Player.position
