extends Node2D

@export var level = 0
@export var floor = 0
var slot = -1
var graphics_efficiency = false
var is_max_level = true
var easy_mode = false
var deaths_this_level = 0
@export var lights_off = false

func _ready():
	if graphics_efficiency:
		$CanvasModulate.color = Color(0.8, 0.8, 0.8, 1)
	else:
		if lights_off:
			$CanvasModulate.color = Color(0.25, 0.25, 0.25, 1)
		else:
			$CanvasModulate.color = Color(0.6, 0.6, 0.6, 1)

func _on_ambiant_background_finished():
	$AmbiantBackground.play()
