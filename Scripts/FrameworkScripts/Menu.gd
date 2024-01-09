extends Node2D

var character_type = 1
var deactivated = false
var credits_open = false
@onready var credits_instance = preload("res://Levels/Cutscenes/Credits.tscn")

func deactivate():
	hide()
	deactivated = true
	# Deactivate all menu nodes!
	
func activate():
	show()
	deactivated = false 
	# Activate all menu nodes!
	
func _ready():
	if name == "SettingsMenu":
		var global_data = get_parent().get_parent().load_data("global")
		$MusicSlider.value = global_data[1]
		$SFXSlider.value = global_data[2]
		$CheckButton.button_pressed = global_data[0]
		$Difficulty.button_pressed = global_data[3]

func _process(_delta):
	if name == "SettingsMenu":
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), $MusicSlider.value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), $SFXSlider.value)

func _on_play_button_button_up():
	$SettingsMenu.visible = false
	$StartGameMenu.visible = true
	
func _on_settings_button_button_up():
	$SettingsMenu.visible = true
	$StartGameMenu.visible = false

func _on_credits_button_button_up():
	if !credits_open:
		credits_open = true
		call_deferred("add_child", credits_instance.instantiate())

func _on_quit_button_button_up():
	get_tree().quit()

func _on_settings_back_button_button_up():
	visible = false

func _on_start_button_up():
	var global_data = get_parent().get_parent().load_data("global")
	get_parent().get_parent().start_game($SpinBox.value, character_type, global_data[0])

func _on_type_1_button_down():
	character_type = 1

func _on_type_2_button_down():
	character_type = 2

func _on_type_3_button_down():
	character_type = 3

func _on_type_4_button_down():
	character_type = 4

