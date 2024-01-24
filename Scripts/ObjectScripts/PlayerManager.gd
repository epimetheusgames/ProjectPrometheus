extends Node2D

@onready var start_zoom = $Camera.zoom
@onready var target_zoom = $Camera.zoom
@onready var graphics_efficiency = get_parent().graphics_efficiency
var static_adder = 0
var bulge_adder = 0

func _ready():
	if graphics_efficiency:
		$Player/PlayerAmbianceParticles.queue_free()
		
	$Camera.position += get_parent().get_parent().get_parent().get_node("SaveLoadFramework").player_camera_position
	$CameraCollider.position += get_parent().get_parent().get_parent().get_node("SaveLoadFramework").player_camera_position

func _process(delta):
	# Camera follows player.
	var follow_position = $Player.position + ($PhysicsPlayerContainer.get_children()[0].position if $Player.physics_player else Vector2.ZERO)
	$CameraCollider.position += (follow_position - $CameraCollider.position) * 0.05 * (delta * 60)
	$Camera.position += ($CameraCollider.position - $Camera.position) * 0.1 * (delta * 60)
	$Camera.zoom += (target_zoom - $Camera.zoom) * 0.01 * delta * 60
	
	var player_vel = 0
	
	$PointLight2D.position = $Player.position
	
	# You may notice here that I multiply the points by 10. This is to 
	# employ a sneaky trick used in the brain called dopamine. Now this
	# is a very bad thing to do, but Elouan the Bad wanted it. He argued
	# and argued and I finally compromized, being my leniant and very 
	# nice and good self to multiply it by 10 but keep the save files
	# having the real points system. Even the points in the first place
	# I objected but I relented because he was being such an annoying
	# person about it that I just added it in because I didn't want him
	# to be pestering it about me anymore. Okay, now he is getting mad
	# at me for writing this so I'm going to go implement the sPeEdRuN
	# tImEr and the lEvEl SeLeCt that he insists that I make right at this
	# instant with no regard for my well-being or life. Now he's saying
	# that he changed his mind about the points just to make my life harder
	# and I'm not going to do it.
	$Camera/PointsCounter.text = "Points: " + str(get_parent().points * 10) 
	
	$Camera/TimeCounter.text = "Time: " + str(int(get_parent().time))
	
	get_parent().get_parent().get_parent().get_node("SaveLoadFramework").player_camera_position = $CameraCollider.position - follow_position
