extends Node2D


var deactivated = false

func deactivate():
	hide()
	deactivated = true
	# Deactivate all menu nodes!
	
func activate():
	show()
	deactivated = false 
	# Activate all menu nodes!

func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		get_parent().start_game($SpinBox.value, $SpinBox2.value)
		
	if Input.is_action_just_pressed("ui_up"):
		get_tree().quit()
