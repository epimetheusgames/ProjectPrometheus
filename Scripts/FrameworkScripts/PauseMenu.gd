extends Node2D


var showing = false


func _ready():
	hide()

func _process(delta):
	if Input.is_action_just_released("ui_accept") and showing:
		get_parent().get_parent().get_parent().exit_to_menu()
		
	if Input.is_action_just_pressed("esc"):
		if showing:
			hide()
		else:
			show()
		showing = !showing
		
