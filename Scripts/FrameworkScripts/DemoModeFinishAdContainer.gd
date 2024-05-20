extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_button_button_up():
	get_parent().get_node("Player").get_node("Camera").get_node("PauseMenu")._on_animation_player_animation_finished("ExitMenu")

func _on_button_2_button_up():
	OS.shell_open("https://epimetheus.games/")
