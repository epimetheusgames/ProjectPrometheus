extends Node2D

@export var level = 0
@export var floor = 0
@export var boss = false
var slot = -1
var graphics_efficiency = false
var is_max_level = true
var easy_mode = false
var deaths_this_level = 0
var points = 0
var time = 0
var deaths = 0
@export var no_timer = false
@export var lights_off = false
@export var end_level = false

func _ready():
	if graphics_efficiency:
		$CanvasModulate.color = Color(0.8, 0.8, 0.8, 1)
	else:
		if lights_off:
			$CanvasModulate.color = Color(0.1, 0.1, 0.1, 1)
		else:
			$CanvasModulate.color = Color(0.6, 0.6, 0.6, 1)

func _process(delta):
	if !end_level:
		time += delta
	
	if boss:
		get_node("Player").target_zoom = Vector2(2.5, 2.5)
		
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

