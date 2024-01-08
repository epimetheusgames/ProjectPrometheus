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
	_on_spin_box_changed()
	var global_data = get_parent().load_data("global")
	
	$CheckBox.button_pressed = global_data[0]
	$MusicSlider.value = global_data[1]
	$SFXSlider.value = global_data[2]
	$CheckBox2.button_pressed = global_data[3]

func _process(_delta):
	if $CheckBox2.button_pressed:
		$CheckBox2.text = "L Mode"
	else:
		$CheckBox2.text = "W Mode"
	
	if Input.is_action_just_pressed("ui_down"):
		get_parent().save_game("[" + str($CheckBox.button_pressed) + "," + str($MusicSlider.value) + "," + str($SFXSlider.value) + "," + str($CheckBox2.button_pressed) + "]", "global")
		get_parent().start_game($SpinBox.value, $SpinBox2.value, $CheckBox.button_pressed, null, null, $SpinBox3.value - 1, 0)
		
	if Input.is_action_just_pressed("ui_up"):
		get_tree().quit()
		
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), $MusicSlider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), $SFXSlider.value)
	_on_spin_box_changed()

func _on_button_pressed():
	get_parent().save_game("[" + str($CheckBox.button_pressed) + "," + str($MusicSlider.value) + "," + str($SFXSlider.value) + "," + str($CheckBox2.button_pressed) + "]", "global")
	get_parent().start_game($SpinBox.value, $SpinBox2.value, $CheckBox.button_pressed, null, null, $SpinBox3.value - 1, 0, $CheckBox2.button_pressed)

func _on_spin_box_changed():
	var loaded_data = get_parent().load_data($SpinBox.value)
	$SpinBox3.max_value = loaded_data[0]
