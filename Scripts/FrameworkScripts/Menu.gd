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
	var global_data = get_parent().load_data("global")
	
	$CheckBox.button_pressed = global_data[0]
	$MusicSlider.value = global_data[1]
	$SFXSlider.value = global_data[2]

func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		get_parent().save_game("[" + str($CheckBox.button_pressed) + "," + str($MusicSlider.value) + "," + str($SFXSlider.value) + "]", "global")
		get_parent().start_game($SpinBox.value, $SpinBox2.value, $CheckBox.button_pressed)
		
	if Input.is_action_just_pressed("ui_up"):
		get_tree().quit()
		
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), $MusicSlider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), $SFXSlider.value)

func _on_button_pressed():
	get_parent().save_game("[" + str($CheckBox.button_pressed) + "," + str($MusicSlider.value) + "," + str($SFXSlider.value) + "]", "global")
	get_parent().start_game($SpinBox.value, $SpinBox2.value, $CheckBox.button_pressed)
