# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# ------------------------------------------PlayerManager.gd---------------------------------------------|
# Main player manager for miscelanious settings and camera movement and collision.                       |
#--------------------------------------------------------------------------------------------------------|


extends Node2D

@onready var start_zoom = $Camera.zoom
@onready var target_zoom = $Camera.zoom
@onready var graphics_efficiency = get_parent().graphics_efficiency
var static_adder = 0
var bulge_adder = 0
@export var smoothing_1 = 0.05
@export var smoothing_2 = 0.1
var screenshake_enabled = false
var body_in_camera_collider = false

func round_place(x, place):
	return round(x * pow(10, place)) / pow(10, place)

func _ready():
	if graphics_efficiency:
		$Player/PlayerAmbianceParticles.queue_free()
		$Camera/CrtOverlay.visible = false
		
	$Camera.position += get_parent().get_parent().get_parent().get_node("SaveLoadFramework").player_camera_position
	$CameraCollider.position += get_parent().get_parent().get_parent().get_node("SaveLoadFramework").player_camera_position

func _process(delta):
	# Camera follows player, but follows it better if the player is moving fast.
	var follow_position
	
	follow_position = $Player.position + ($PhysicsPlayerContainer.get_children()[0].position if $Player.physics_player else Vector2.ZERO)
	$CameraCollider.position += (follow_position - $CameraCollider.position) * smoothing_1 * (delta * 60)
	
	var camera_velocity = ($CameraCollider.position - $Camera.position) * smoothing_2 * (delta * 60)
	$Camera.position += camera_velocity
	$Camera.zoom += (target_zoom - $Camera.zoom) * 0.01 * delta * 60
	
	$Camera.rotation = camera_velocity.x / 200
	
	# Generally a stable camera is more important then allways being able to see the player at
	# one time. If there's a hitbox colliding with the CameraCollider, disable smoothing 
	# decrementation. The one caviat of this is that if the player is falling next to a wall
	# the camera will miss them for a short time.
	if $Camera.position.distance_to($Player.position) > 100 && !body_in_camera_collider:
		if smoothing_1 < 0.5:
			smoothing_1 += 0.001
		if smoothing_2 < 0.5:
			smoothing_2 += 0.001
	else:
		if smoothing_1 > 0.05:
			smoothing_1 -= 0.0003
		if smoothing_2 > 0.1:
			smoothing_2 -= 0.0003
	
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
	
	# Spogatios
	var hours = int(get_parent().time / 60 / 60)
	var minutes = int((get_parent().time - hours * 60 * 60) / 60)
	var seconds = int(get_parent().time - (hours * 60 * 60) - (minutes * 60))
	var extra = get_parent().time - (hours * 60 * 60) - (minutes * 60) - (seconds)
	
	$Camera/TimeCounter.text = "" + (("0" if hours > 10 else "") + ("0" if hours > 100 else "") + str(hours) + ":" if hours > 0 else "") + ("0" if minutes < 10 else "") + str(minutes) + ":" + ("0" if seconds < 10 else "") + str(seconds) + "." + str(round_place(extra, 2)).lstrip("0.")
	
	get_parent().get_parent().get_parent().get_node("SaveLoadFramework").player_camera_position = $CameraCollider.position - follow_position

	if $Camera/BossBar.value <= -30 && get_parent().boss:
		get_parent().get_node("DroneManager").get_node("Drone").get_node("DeathZone").get_node("CollisionPolygon2D").disabled = true

	if screenshake_enabled:
		$ScreenShake.visible = true
	else:
		$ScreenShake.visible = false
		
	if screenshake_enabled && $ScreenShakeDisableTimer.time_left <= 0:
		$ScreenShakeDisableTimer.start()

func _on_screen_shake_disable_timer_timeout():
	screenshake_enabled = false

func _on_camera_collider_collision_listener_body_entered(body):
	if body.name != "CameraCollider":
		body_in_camera_collider = true

func _on_camera_collider_collision_listener_body_exited(body):
	if body.name != "CameraCollider":
		body_in_camera_collider = false
