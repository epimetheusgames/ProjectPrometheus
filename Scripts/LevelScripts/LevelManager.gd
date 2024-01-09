extends Node2D

@export var level = 0
@export var floor = 0
var slot = -1
var graphics_efficiency = false
var is_max_level = true
var easy_mode = false

func _ready():
	$CanvasModulate.color = Color(0.27, 0.27, 0.27, 1)

func _on_ambiant_background_finished():
	$AmbiantBackground.play()
