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
	
func _ready():
	$CheckBox.button_pressed = get_parent().load_data("global")[0]

func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		get_parent().save_game("[" + str($CheckBox.button_pressed) + "]", "global")
		get_parent().start_game($SpinBox.value, $SpinBox2.value, $CheckBox.button_pressed)
		
	if Input.is_action_just_pressed("ui_up"):
		get_tree().quit()
