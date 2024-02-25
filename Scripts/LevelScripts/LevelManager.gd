extends Node2D

@export var level = 0
@export var floor = 0
@export var boss = false
@export var zoom_boss = false
@export var is_multiplayer = false
var slot = -1
var graphics_efficiency = false
var is_max_level = true
var easy_mode = false
var show_fps = false
var show_points = false
var show_timer = false
var deaths_this_level = 0
var points = 0
var time = 0
var deaths = 0
var just_unpaused = false
@export var no_timer = false
@export var lights_off = false
@export var end_level = false
@onready var server_player = $ServerPlayer
@onready var client_player = $ClientPlayer

func _ready():
	if graphics_efficiency:
		if lights_off:
			$CanvasModulate.color = Color(0.15, 0.15, 0.15, 1)
		else:
			$CanvasModulate.color = Color(0.8, 0.8, 0.8, 1)
	else:
		if lights_off:
			$CanvasModulate.color = Color(0.1, 0.1, 0.1, 1)
		else:
			$CanvasModulate.color = Color(0.6, 0.6, 0.6, 1)
	
	if !is_multiplayer:
		if !show_fps:
			$Player/Camera/FPSCounter.visible = false
		if !show_points:
			$Player/Camera/PointsCounter.visible = false
		if !show_timer:
			$Player/Camera/TimeCounter.visible = false

func _process(delta):
	if is_multiplayer:
		if multiplayer.is_server():
			client_player.set_multiplayer_authority(multiplayer.get_peers()[0])
			server_player.set_multiplayer_authority(multiplayer.get_unique_id())
			client_player.get_node("Camera").enabled = false
			client_player.get_node("Camera").visible = false
			client_player.modulate.a = 0.3
		else:
			server_player.set_multiplayer_authority(multiplayer.get_peers()[0])
			client_player.set_multiplayer_authority(multiplayer.get_unique_id())
			server_player.get_node("Camera").enabled = false
			server_player.get_node("Camera").visible = false
			server_player.modulate.a = 0.3
			
	if !end_level:
		time += delta
	
	if boss:
		get_node("Player").target_zoom = Vector2(2.5, 2.5)
		
	if zoom_boss:
		get_node("Player").target_zoom = Vector2(2, 2)
		
	if end_level:
		$Label2.text = "Points: " + str(points * 10) 
	
		var hours = int(time / 60 / 60)
		var minutes = int((time - hours * 60 * 60) / 60)
		var seconds = int(time - (hours * 60 * 60) - (minutes * 60))
		var extra = time - (hours * 60 * 60) - (minutes * 60) - (seconds)
		
		$Label3.text = "Time: " + (("0" if hours < 10 else "") + ("0" if hours < 100 else "") + str(hours) + ":" if hours > 0 else "") + ("0" if minutes < 10 else "") + str(minutes) + ":" + ("0" if seconds < 10 else "") + str(seconds) + "." + str($Player.round_place(extra, 2)).lstrip("0.")
		$Label4.text = "Deaths: " + str(deaths)

func _on_ambiant_background_finished():
	$AmbiantBackground.play()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "ExtractLargeDrone":
		$NextLevel.add_level()
